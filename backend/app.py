"""Local recipe retrieval API. Run from backend: python -m uvicorn app:app."""
import csv
import json
import logging
import os
import struct
from contextlib import asynccontextmanager
from pathlib import Path
from threading import Lock

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field, field_validator
from generation import GeminiGenerator

log = logging.getLogger(__name__)
DEFAULT_AI_DIR = Path(__file__).resolve().parents[3] / "file ai"
if (DEFAULT_AI_DIR / "recovered-kaggle").is_dir():
    DEFAULT_AI_DIR = DEFAULT_AI_DIR / "recovered-kaggle"


def validate_assets(directory: Path):
    model_directory = directory / "model" if (directory / "model").is_dir() else directory
    required = ["config.json", "tokenizer.json", "modules.json",
                "model.safetensors", "recipe_faiss.index", "recipe_metadata.csv"]
    for name in required:
        root = directory if name in {"recipe_faiss.index", "recipe_metadata.csv"} else model_directory
        if not (root / name).is_file():
            raise ValueError(f"File AI belum tersedia: {name}")
    model = model_directory / "model.safetensors"
    with model.open("rb") as stream:
        raw = stream.read(8)
        if len(raw) != 8:
            raise ValueError("Header model.safetensors tidak lengkap.")
        length = struct.unpack("<Q", raw)[0]
        if length > 16_000_000:
            raise ValueError("Header model.safetensors tidak valid.")
        header = json.loads(stream.read(length))
    expected = 8 + length + max(
        item["data_offsets"][1] for key, item in header.items()
        if key != "__metadata__"
    )
    if model.stat().st_size != expected:
        raise ValueError(
            f"model.safetensors tidak lengkap: {model.stat().st_size} byte; "
            f"seharusnya {expected} byte. Salin ulang model lengkap."
        )
    modules = json.loads((model_directory / "modules.json").read_text(encoding="utf-8"))
    for module in modules:
        path = module.get("path", "")
        if path and not (model_directory / path).is_dir():
            raise ValueError(f"Folder model {path} belum tersedia. Salin folder model lengkap.")
    return model_directory


class RecipeEngine:
    def __init__(self, directory: Path):
        model_directory = validate_assets(directory)
        # Import only after validation, so incomplete assets have a useful error.
        import faiss
        from sentence_transformers import SentenceTransformer

        self.faiss = faiss
        self.lock = Lock()
        self.index = faiss.read_index(str(directory / "recipe_faiss.index"))
        # Export uses row offsets. Reject custom-ID indexes rather than mix up recipes.
        if not isinstance(self.index, faiss.IndexFlat):
            raise ValueError("Index harus IndexFlat dengan urutan yang sama seperti CSV.")
        with (directory / "recipe_metadata.csv").open(encoding="utf-8-sig", newline="") as file:
            reader = csv.DictReader(file)
            required = {"recipe_id", "Title", "ingredient_text", "Instructions"}
            if not required.issubset(reader.fieldnames or []):
                raise ValueError("Kolom metadata resep tidak lengkap.")
            self.rows = list(reader)
        if len(self.rows) != self.index.ntotal or not self.rows:
            raise ValueError("Jumlah metadata tidak cocok dengan jumlah vektor index.")
        self.model = SentenceTransformer(str(model_directory), local_files_only=True, device="cpu")
        self.model.max_seq_length = 384  # Matches training and corpus encoding in the notebook.
        if self.model.get_sentence_embedding_dimension() != self.index.d:
            raise ValueError("Dimensi model tidak cocok dengan index FAISS.")

    def search(self, question: str, top_k: int):
        import numpy as np

        with self.lock:
            # Prefix follows the E5 training examples in the source model card.
            query = question if question.startswith("query: ") else f"query: {question}"
            vector = self.model.encode([query], normalize_embeddings=True)
            _, ids = self.index.search(np.asarray(vector, dtype="float32"), min(top_k, len(self.rows)))
        recipes = []
        for index in ids[0]:
            if index < 0:
                continue
            row = self.rows[int(index)]
            recipes.append({"id": row["recipe_id"], "title": row["Title"],
                            "ingredients": row["ingredient_text"],
                            "instructions": row["Instructions"]})
        return recipes


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)
    top_k: int = Field(default=3, ge=1, le=5)

    @field_validator("message")
    @classmethod
    def strip_message(cls, value):
        value = value.strip()
        if not value:
            raise ValueError("Pertanyaan tidak boleh kosong.")
        return value


class RecipeSource(BaseModel):
    id: str
    title: str
    ingredients: str
    instructions: str


class ChatResponse(BaseModel):
    text: str
    recipes: list[RecipeSource]
    generation: str = "retrieval_only"


def create_app(engine_factory=None, generator_factory=None):
    @asynccontextmanager
    async def lifespan(api):
        api.state.engine = None
        api.state.load_error = None
        api.state.generator = None
        api.state.generation_status = "not_configured"
        key = os.getenv("GEMINI_API_KEY", "").strip()
        model = os.getenv("GEMINI_MODEL", "").strip()
        if generator_factory or (key and model):
            try:
                api.state.generator = generator_factory() if generator_factory else GeminiGenerator(key, model)
                api.state.generation_status = "configured"
            except ValueError:
                api.state.generation_status = "invalid_configuration"
        try:
            api.state.engine = (engine_factory() if engine_factory else
                                RecipeEngine(Path(os.getenv("AI_MODEL_DIR", str(DEFAULT_AI_DIR)))))
        except Exception as error:
            api.state.load_error = str(error)
            log.exception("Model AI belum siap")
        yield

    api = FastAPI(title="RacikAI", lifespan=lifespan)
    api.add_middleware(
        CORSMiddleware,
        allow_origins=[s.strip() for s in os.getenv("CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000").split(",") if s.strip()],
        allow_methods=["GET", "POST"], allow_headers=["Content-Type"],
    )

    @api.get("/health")
    def health():
        ready = api.state.engine is not None
        return {"status": "ready" if ready else "not_ready", "detail": api.state.load_error,
                "generation": api.state.generation_status}

    @api.post("/chat", response_model=ChatResponse)
    def chat(request: ChatRequest):
        if api.state.engine is None:
            raise HTTPException(503, "Model AI belum siap. Periksa /health di komputer server.")
        try:
            recipes = api.state.engine.search(request.message, request.top_k)
        except Exception:
            log.exception("Pencarian resep gagal")
            raise HTTPException(500, "Pencarian resep gagal. Silakan coba lagi.") from None
        text = ("Berikut resep terdekat dari koleksi resep untuk pertanyaanmu. "
                "Ketuk resep untuk melihat bahan dan langkah memasaknya. "
                "Periksa kembali kecocokan bahan dan kebutuhan makanmu."
                if recipes else "Belum ada resep yang ditemukan. Coba sebutkan bahan utama.")
        generation = "retrieval_only"
        if recipes and api.state.generator:
            try:
                text = api.state.generator.generate(request.message, recipes)
                generation = "gemini"
            except Exception:
                # Do not log provider payloads, credentials, or user questions.
                log.warning("Gemini gagal; hasil pencarian tetap tersedia.")
                text = "Penyusunan jawaban AI sedang gagal. " + text
                generation = "unavailable"
        elif recipes:
            text = "Mode pencarian resep; Gemini belum diaktifkan. " + text
        return {"text": text, "recipes": recipes, "generation": generation}

    return api


app = create_app()
