import csv
import json
import logging
import os
import re
import struct

from contextlib import asynccontextmanager
from pathlib import Path
from threading import Lock
from urllib.parse import quote

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field, field_validator

from generation import GeminiGenerator


log = logging.getLogger(__name__)

DEFAULT_WORKSPACE_DIR = Path(__file__).resolve().parents[2]

DEFAULT_ASSET_ROOT = (
    DEFAULT_WORKSPACE_DIR
    / "file ai"
)

DEFAULT_AI_DIR = DEFAULT_ASSET_ROOT

if (
    DEFAULT_ASSET_ROOT
    / "recovered-kaggle"
).is_dir():
    DEFAULT_AI_DIR = (
        DEFAULT_ASSET_ROOT
        / "recovered-kaggle"
    )


DEFAULT_IMAGE_DIR = (
    DEFAULT_ASSET_ROOT
    / "recipes-images"
)

IMAGE_ROUTE = "/recipe-images"

IMAGE_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
}

CATALOG_QUERY_TRANSLATIONS = {
    "kecap manis": "sweet soy sauce",
    "saus tomat": "ketchup",
    "daging sapi": "beef",
    "bawang putih": "garlic",
    "bawang merah": "shallot",
    "bawang bombai": "onion",
    "ayam": "chicken",
    "kecap": "soy sauce",
    "kentang": "potato",
    "telur": "egg",
    "keju": "cheese",
    "nasi": "rice",
    "sayur": "vegetable",
    "cokelat": "chocolate",
    "ikan": "fish",
    "udang": "shrimp",
    "susu": "milk",
    "tepung": "flour",
    "cabai": "chili",
    "wortel": "carrot",
    "brokoli": "broccoli",
}


CATALOG_STOP_WORDS = {
    "resep",
    "masak",
    "makanan",
    "dengan",
    "dan",
    "yang",
    "dari",
    "punya",
    "saya",
    "aku",
    "mau",
    "ingin",
    "cari",
    "buat",
    "recipe",
    "recipes",
    "with",
}


CATEGORY_KEYWORDS = {
    "Ayam": (
        "chicken",
    ),
    "Daging": (
        "beef",
        "steak",
        "pork",
        "lamb",
        "meat",
    ),
    "Nasi": (
        "rice",
    ),
    "Pasta": (
        "pasta",
        "spaghetti",
        "macaroni",
        "linguine",
        "fettuccine",
        "penne",
        "ravioli",
        "lasagna",
    ),
    "Sayur": (
        "vegetable",
        "broccoli",
        "carrot",
        "spinach",
        "cabbage",
        "zucchini",
        "eggplant",
        "cauliflower",
        "kale",
    ),
    "Dessert": (
        "dessert",
        "cake",
        "cookie",
        "brownie",
        "chocolate",
        "pudding",
        "pie",
        "tart",
        "cupcake",
        "ice cream",
    ),
}

def normalize_catalog_query(
    query: str,
) -> str:
    """
    Normalize simple Indonesian catalog queries.
    """

    result = query.strip().lower()

    translations = sorted(
        CATALOG_QUERY_TRANSLATIONS.items(),
        key=lambda item: len(item[0]),
        reverse=True,
    )

    for source, target in translations:
        result = re.sub(
            rf"\b{re.escape(source)}\b",
            target,
            result,
        )

    words = [
        word
        for word in re.findall(
            r"[a-z0-9]+",
            result,
        )
        if word not in CATALOG_STOP_WORDS
    ]

    return " ".join(words)


def _contains_catalog_keyword(
    text: str,
    keyword: str,
) -> bool:
    """
    Check category keyword using word boundaries.
    """

    return (
        re.search(
            rf"\b{re.escape(keyword.lower())}\b",
            text,
        )
        is not None
    )

def build_image_index(
    directory: Path,
) -> dict[str, str]:
    """
    Build mapping:
    Image_Name -> relative image file path.

    Example:
    soy-sauce-chicken
        ->
    soy-sauce-chicken.jpg
    """

    image_index: dict[str, str] = {}

    if not directory.is_dir():
        return image_index

    for image_path in directory.rglob("*"):
        if not image_path.is_file():
            continue

        if (
            image_path.suffix.lower()
            not in IMAGE_EXTENSIONS
        ):
            continue

        key = (
            image_path.stem
            .strip()
            .lower()
        )

        if not key:
            continue

        relative_path = (
            image_path
            .relative_to(directory)
            .as_posix()
        )

        image_index.setdefault(
            key,
            relative_path,
        )

    return image_index


def _image_lookup_key(
    image_name: str | None,
) -> str | None:
    if image_name is None:
        return None

    value = image_name.strip()

    if not value:
        return None

    if value.upper() == "#NAME?":
        return None

    key = value.lower()

    for extension in IMAGE_EXTENSIONS:
        if key.endswith(extension):
            key = key[
                : -len(extension)
            ]
            break

    key = key.strip()

    return key or None


def enrich_recipes_with_images(
    recipes: list[dict],
    image_index: dict[str, str],
    request: Request,
) -> list[dict]:
    base_url = str(
        request.base_url
    ).rstrip("/")

    enriched = []

    for recipe in recipes:
        item = dict(recipe)

        raw_image_name = (
            item.get("image_name")
        )

        key = _image_lookup_key(
            raw_image_name
        )

        relative_image_path = (
            image_index.get(key)
            if key
            else None
        )

        if relative_image_path:
            encoded_path = quote(
                relative_image_path,
                safe="/",
            )

            item["image_url"] = (
                f"{base_url}"
                f"{IMAGE_ROUTE}/"
                f"{encoded_path}"
            )

        else:
            item["image_url"] = None

        enriched.append(item)

    return enriched

def validate_assets(
    directory: Path,
):
    model_directory = (
        directory / "model"
        if (
            directory / "model"
        ).is_dir()
        else directory
    )

    required = [
        "config.json",
        "tokenizer.json",
        "modules.json",
        "model.safetensors",
        "recipe_faiss.index",
        "recipe_metadata.csv",
    ]

    for name in required:
        root = (
            directory
            if name in {
                "recipe_faiss.index",
                "recipe_metadata.csv",
            }
            else model_directory
        )

        if not (
            root / name
        ).is_file():
            raise ValueError(
                f"File AI belum tersedia: {name}"
            )

    model = (
        model_directory
        / "model.safetensors"
    )

    with model.open(
        "rb"
    ) as stream:
        raw = stream.read(8)

        if len(raw) != 8:
            raise ValueError(
                "Header model.safetensors "
                "tidak lengkap."
            )

        length = struct.unpack(
            "<Q",
            raw,
        )[0]

        if length > 16_000_000:
            raise ValueError(
                "Header model.safetensors "
                "tidak valid."
            )

        header = json.loads(
            stream.read(length)
        )

    expected = (
        8
        + length
        + max(
            item["data_offsets"][1]
            for key, item in header.items()
            if key != "__metadata__"
        )
    )

    if (
        model.stat().st_size
        != expected
    ):
        raise ValueError(
            "model.safetensors tidak lengkap: "
            f"{model.stat().st_size} byte; "
            f"seharusnya {expected} byte. "
            "Salin ulang model lengkap."
        )

    modules = json.loads(
        (
            model_directory
            / "modules.json"
        ).read_text(
            encoding="utf-8"
        )
    )

    for module in modules:
        path = module.get(
            "path",
            "",
        )

        if path and not (
            model_directory
            / path
        ).is_dir():
            raise ValueError(
                f"Folder model {path} "
                "belum tersedia. "
                "Salin folder model lengkap."
            )

    return model_directory

def parse_ingredient_list(
    value: str,
) -> list[str]:
    """
    Membaca ingredient_list yang disimpan sebagai JSON
    di dalam recipe_metadata.csv.
    """

    if not value:
        return []

    try:
        parsed = json.loads(value)

    except (
        json.JSONDecodeError,
        TypeError,
    ):
        return []

    if not isinstance(
        parsed,
        list,
    ):
        return []

    return [
        str(item).strip()
        for item in parsed
        if str(item).strip()
    ]

class RecipeEngine:
    def __init__(
        self,
        directory: Path,
    ):
        model_directory = (
            validate_assets(
                directory
            )
        )

        import faiss

        from sentence_transformers import (
            SentenceTransformer,
        )

        self.faiss = faiss

        self.lock = Lock()

        self.index = (
            faiss.read_index(
                str(
                    directory
                    / "recipe_faiss.index"
                )
            )
        )

        if not isinstance(
            self.index,
            faiss.IndexFlat,
        ):
            raise ValueError(
                "Index harus IndexFlat "
                "dengan urutan yang sama "
                "seperti CSV."
            )

        with (
            directory
            / "recipe_metadata.csv"
        ).open(
            encoding="utf-8-sig",
            newline="",
        ) as file:
            reader = csv.DictReader(
                file
            )

            required = {
                "recipe_id",
                "Title",
                "ingredient_text",
                "ingredient_list",
                "Instructions",
            }

            if not required.issubset(
                reader.fieldnames
                or []
            ):
                raise ValueError(
                    "Kolom metadata resep "
                    "tidak lengkap."
                )

            self.rows = list(
                reader
            )

        if (
            len(self.rows)
            != self.index.ntotal
            or not self.rows
        ):
            raise ValueError(
                "Jumlah metadata tidak cocok "
                "dengan jumlah vektor index."
            )

        self.model = (
            SentenceTransformer(
                str(
                    model_directory
                ),
                local_files_only=True,
                device="cpu",
            )
        )

        self.model.max_seq_length = 384

        if (
            self.model
            .get_sentence_embedding_dimension()
            != self.index.d
        ):
            raise ValueError(
                "Dimensi model tidak cocok "
                "dengan index FAISS."
            )

    def search(
        self,
        question: str,
        top_k: int,
    ):
        import numpy as np

        with self.lock:
            query = (
                question
                if question.startswith(
                    "query: "
                )
                else (
                    f"query: {question}"
                )
            )

            vector = (
                self.model.encode(
                    [query],
                    normalize_embeddings=True,
                )
            )

            _, ids = (
                self.index.search(
                    np.asarray(
                        vector,
                        dtype="float32",
                    ),
                    min(
                        top_k,
                        len(
                            self.rows
                        ),
                    ),
                )
            )

        recipes = []

        for index in ids[0]:
            if index < 0:
                continue

            row = self.rows[
                int(index)
            ]

            ingredient_list = (
                parse_ingredient_list(
                    row.get(
                        "ingredient_list",
                        "",
                    )
                )
            )

            image_name = (
                row.get(
                    "Image_Name",
                    "",
                )
                or ""
            ).strip()

            recipes.append(
                {
                    "id": row[
                        "recipe_id"
                    ],
                    "title": row[
                        "Title"
                    ],
                    "ingredients": row[
                        "ingredient_text"
                    ],
                    "ingredient_list": (
                        ingredient_list
                    ),
                    "instructions": row[
                        "Instructions"
                    ],
                    "image_name": (
                        image_name
                        if image_name
                        else None
                    ),
                    "image_url": None,
                }
            )

        return recipes

    def search_catalog(
        self,
        query: str,
        category: str,
        page: int,
        limit: int,
    ):
        normalized_query = (
            normalize_catalog_query(
                query
            )
        )

        query_terms = [
            term
            for term
            in normalized_query.split()
            if term
        ]

        category_keywords = (
            CATEGORY_KEYWORDS.get(
                category,
                (),
            )
            if category != "Semua"
            else ()
        )

        matches = []

        for row in self.rows:
            title = (
                row.get(
                    "Title",
                    "",
                )
                or ""
            ).strip()

            ingredients = (
                row.get(
                    "ingredient_text",
                    "",
                )
                or ""
            ).strip()

            instructions = (
                row.get(
                    "Instructions",
                    "",
                )
                or ""
            ).strip()

            title_lower = (
                title.lower()
            )

            ingredients_lower = (
                ingredients.lower()
            )

            search_text = (
                f"{title_lower} "
                f"{ingredients_lower}"
            )

            if category_keywords:
                category_match = any(
                    _contains_catalog_keyword(
                        search_text,
                        keyword,
                    )
                    for keyword
                    in category_keywords
                )

                if not category_match:
                    continue

            score = 0

            if query_terms:
                if not all(
                    term in search_text
                    for term in query_terms
                ):
                    continue

                if (
                    normalized_query
                    == title_lower
                ):
                    score += 100

                elif (
                    normalized_query
                    in title_lower
                ):
                    score += 40

                for term in query_terms:
                    if (
                        term
                        in title_lower
                    ):
                        score += 8

                    if (
                        term
                        in ingredients_lower
                    ):
                        score += 2

            image_name = (
                row.get(
                    "Image_Name",
                    "",
                )
                or ""
            ).strip()

            ingredient_list = (
                parse_ingredient_list(
                    row.get(
                        "ingredient_list",
                        "",
                    )
                )
            )

            # Hitung dari list asli, BUKAN split(",")
            ingredient_count = len(
                ingredient_list
            )

            recipe = {
                "id": row[
                    "recipe_id"
                ],
                "title": title,
                "ingredients": ingredients,
                "ingredient_list": (
                    ingredient_list
                ),
                "instructions": (
                    instructions
                ),
                "image_name": (
                    image_name
                    if image_name
                    else None
                ),
                "image_url": None,
                "ingredient_count": (
                    ingredient_count
                ),
            }

            matches.append(
                (
                    score,
                    title_lower,
                    recipe,
                )
            )

        if query_terms:
            matches.sort(
                key=lambda item: (
                    -item[0],
                    item[1],
                )
            )

        else:
            matches.sort(
                key=lambda item: (
                    item[1]
                )
            )

        total = len(
            matches
        )

        start = (
            page - 1
        ) * limit

        end = (
            start
            + limit
        )

        recipes = [
            item[2]
            for item
            in matches[
                start:end
            ]
        ]

        return (
            recipes,
            total,
        )

class ChatRequest(
    BaseModel
):
    message: str = Field(
        min_length=1,
        max_length=2000,
    )

    top_k: int = Field(
        default=3,
        ge=1,
        le=5,
    )

    @field_validator(
        "message"
    )
    @classmethod
    def strip_message(
        cls,
        value,
    ):
        value = (
            value.strip()
        )

        if not value:
            raise ValueError(
                "Pertanyaan tidak "
                "boleh kosong."
            )

        return value


class RecipeSource(
    BaseModel
):
    id: str

    title: str

    ingredients: str

    ingredient_list: list[str] = Field(
        default_factory=list
    )

    instructions: str

    image_name: str | None = None

    image_url: str | None = None


class ChatResponse(
    BaseModel
):
    text: str

    recipes: list[
        RecipeSource
    ]

    generation: str = (
        "retrieval_only"
    )


class CatalogRecipe(
    BaseModel
):
    id: str

    title: str

    ingredients: str

    ingredient_list: list[str] = Field(
        default_factory=list
    )

    instructions: str

    image_name: str | None = None

    image_url: str | None = None

    ingredient_count: int


class CatalogResponse(
    BaseModel
):
    recipes: list[
        CatalogRecipe
    ]

    page: int

    limit: int

    total: int

    has_more: bool

def create_app(
    engine_factory=None,
    generator_factory=None,
    image_directory=None,
):
    configured_image_directory = (
        Path(
            image_directory
            if image_directory
            is not None
            else os.getenv(
                "RECIPE_IMAGE_DIR",
                str(
                    DEFAULT_IMAGE_DIR
                ),
            )
        )
        .expanduser()
        .resolve()
    )

    @asynccontextmanager
    async def lifespan(
        api,
    ):
        api.state.engine = None

        api.state.load_error = None

        api.state.generator = None

        api.state.generation_status = (
            "not_configured"
        )

        api.state.image_index = (
            build_image_index(
                configured_image_directory
            )
        )

        api.state.image_status = (
            "ready"
            if api.state.image_index
            else "not_found"
        )

        if api.state.image_index:
            log.info(
                "Recipe images ready: %s",
                len(
                    api.state.image_index
                ),
            )

        else:
            log.warning(
                "Folder gambar resep "
                "tidak ditemukan atau kosong: %s",
                configured_image_directory,
            )

        key = os.getenv(
            "GEMINI_API_KEY",
            "",
        ).strip()

        model = os.getenv(
            "GEMINI_MODEL",
            "",
        ).strip()

        if (
            generator_factory
            or (
                key
                and model
            )
        ):
            try:
                api.state.generator = (
                    generator_factory()
                    if generator_factory
                    else GeminiGenerator(
                        key,
                        model,
                    )
                )

                api.state.generation_status = (
                    "configured"
                )

            except ValueError:
                api.state.generation_status = (
                    "invalid_configuration"
                )

        try:
            api.state.engine = (
                engine_factory()
                if engine_factory
                else RecipeEngine(
                    Path(
                        os.getenv(
                            "AI_MODEL_DIR",
                            str(
                                DEFAULT_AI_DIR
                            ),
                        )
                    )
                )
            )

        except Exception as error:
            api.state.load_error = (
                str(error)
            )

            log.exception(
                "Model AI belum siap"
            )

        yield

    api = FastAPI(
        title="RacikAI",
        lifespan=lifespan,
    )

    if (
        configured_image_directory
        .is_dir()
    ):
        api.mount(
            IMAGE_ROUTE,
            StaticFiles(
                directory=str(
                    configured_image_directory
                )
            ),
            name="recipe-images",
        )

    api.add_middleware(
        CORSMiddleware,
        allow_origins=[
            item.strip()
            for item
            in os.getenv(
                "CORS_ORIGINS",
                (
                    "http://localhost:3000,"
                    "http://127.0.0.1:3000"
                ),
            ).split(",")
            if item.strip()
        ],
        allow_methods=[
            "GET",
            "POST",
        ],
        allow_headers=[
            "Content-Type",
        ],
    )

    @api.get(
        "/health"
    )
    def health():
        ready = (
            api.state.engine
            is not None
        )

        return {
            "status": (
                "ready"
                if ready
                else "not_ready"
            ),
            "detail": (
                api.state.load_error
            ),
            "generation": (
                api.state
                .generation_status
            ),
            "images": {
                "status": (
                    api.state
                    .image_status
                ),
                "count": len(
                    api.state
                    .image_index
                ),
            },
        }

    @api.get(
        "/recipes",
        response_model=CatalogResponse,
    )
    def recipes(
        request: Request,
        q: str = "",
        category: str = "Semua",
        page: int = 1,
        limit: int = 24,
    ):
        if (
            api.state.engine
            is None
        ):
            raise HTTPException(
                503,
                "Katalog resep "
                "belum siap.",
            )

        page = max(
            page,
            1,
        )

        limit = max(
            1,
            min(
                limit,
                48,
            ),
        )

        if (
            category != "Semua"
            and category
            not in CATEGORY_KEYWORDS
        ):
            category = "Semua"

        try:
            results, total = (
                api.state
                .engine
                .search_catalog(
                    query=q,
                    category=category,
                    page=page,
                    limit=limit,
                )
            )

            results = (
                enrich_recipes_with_images(
                    results,
                    api.state
                    .image_index,
                    request,
                )
            )

        except Exception:
            log.exception(
                "Katalog resep gagal dimuat"
            )

            raise HTTPException(
                500,
                "Katalog resep "
                "gagal dimuat.",
            ) from None

        return {
            "recipes": results,
            "page": page,
            "limit": limit,
            "total": total,
            "has_more": (
                page * limit
                < total
            ),
        }

    @api.post(
        "/chat",
        response_model=ChatResponse,
        response_model_exclude_none=True,
    )
    def chat(
        request: ChatRequest,
        http_request: Request,
    ):
        if (
            api.state.engine
            is None
        ):
            raise HTTPException(
                503,
                (
                    "Model AI belum siap. "
                    "Periksa /health "
                    "di komputer server."
                ),
            )

        search_query = (
            request.message
        )

        if api.state.generator:
            try:
                search_query = (
                    api.state
                    .generator
                    .rewrite_query(
                        request.message
                    )
                )

                log.info(
                    "Query rewrite berhasil."
                )

            except Exception:
                log.warning(
                    (
                        "Gemini query rewrite gagal; "
                        "menggunakan pertanyaan asli."
                    )
                )

                search_query = (
                    request.message
                )

        try:
            recipes = (
                api.state
                .engine
                .search(
                    search_query,
                    request.top_k,
                )
            )

        except Exception:
            log.exception(
                "Pencarian resep gagal"
            )

            raise HTTPException(
                500,
                (
                    "Pencarian resep gagal. "
                    "Silakan coba lagi."
                ),
            ) from None

        text = (
            (
                "Berikut resep terdekat "
                "dari koleksi resep untuk "
                "pertanyaanmu. "
                "Ketuk resep untuk melihat "
                "bahan dan langkah memasaknya. "
                "Periksa kembali kecocokan bahan "
                "dan kebutuhan makanmu."
            )
            if recipes
            else (
                "Belum ada resep yang ditemukan. "
                "Coba sebutkan bahan utama."
            )
        )

        generation = (
            "retrieval_only"
        )

        if (
            recipes
            and api.state.generator
        ):
            try:
                text = (
                    api.state
                    .generator
                    .generate(
                        request.message,
                        recipes,
                    )
                )

                generation = (
                    "gemini"
                )

            except Exception:
                log.warning(
                    (
                        "Gemini gagal; "
                        "hasil pencarian "
                        "tetap tersedia."
                    )
                )

                text = (
                    "Penyusunan jawaban AI "
                    "sedang gagal. "
                    + text
                )

                generation = (
                    "unavailable"
                )

        elif recipes:
            text = (
                "Mode pencarian resep; "
                "Gemini belum diaktifkan. "
                + text
            )

        response_recipes = (
            enrich_recipes_with_images(
                recipes,
                api.state
                .image_index,
                http_request,
            )
        )

        return {
            "text": text,
            "recipes": (
                response_recipes
            ),
            "generation": (
                generation
            ),
        }

    return api

app = create_app()