import ast
import csv
import json
import re
import shutil
from datetime import datetime
from pathlib import Path


RAW_DATASET = Path(
    r"D:\RacikAI\temp-dataset\Food Ingredients and Recipe Dataset with Image Name Mapping.csv"
)

METADATA = Path(
    r"D:\RacikAI\file ai\recovered-kaggle\recipe_metadata.csv"
)


def normalize_whitespace(value) -> str:
    if value is None:
        return ""

    return re.sub(
        r"\s+",
        " ",
        str(value),
    ).strip()


def parse_list_like(value) -> list[str]:
    """
    Meniru fungsi parse_list_like dari notebook RacikAI.

    Prioritas:
    1. Coba baca sebagai Python list dengan ast.literal_eval.
    2. Jika gagal, fallback split koma / newline / semicolon.
    """
    if value is None:
        return []

    text = str(value).strip()

    if not text:
        return []

    try:
        parsed = ast.literal_eval(text)

        if isinstance(parsed, (list, tuple)):
            return [
                str(item).strip()
                for item in parsed
                if str(item).strip()
            ]

    except Exception:
        pass

    return [
        item.strip()
        for item in re.split(r",|\n|;", text)
        if item.strip()
    ]


def rebuild_clean_dataset() -> list[dict]:
    """
    Mengulangi preprocessing yang dulu dilakukan notebook:

    - normalize Title
    - normalize Ingredients
    - normalize Instructions
    - hapus baris penting yang kosong
    - drop duplicate berdasarkan lowercase title
    - parse ingredient list
    - fallback ke Ingredients jika perlu
    - membuat recipe_id setelah cleaning
    """
    with RAW_DATASET.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                "Header dataset asli tidak ditemukan."
            )

        required = {
            "Title",
            "Ingredients",
            "Instructions",
        }

        if not required.issubset(reader.fieldnames):
            raise ValueError(
                "Dataset asli tidak memiliki kolom "
                "Title, Ingredients, dan Instructions."
            )

        has_cleaned_ingredients = (
            "Cleaned_Ingredients" in reader.fieldnames
        )

        cleaned_rows = []
        seen_titles = set()

        for raw_row in reader:
            title = normalize_whitespace(
                raw_row.get("Title")
            )

            ingredients_text = normalize_whitespace(
                raw_row.get("Ingredients")
            )

            instructions = normalize_whitespace(
                raw_row.get("Instructions")
            )

            # Sama seperti filter notebook.
            if (
                not title
                or not ingredients_text
                or not instructions
            ):
                continue

            title_key = title.lower().strip()

            # Sama seperti:
            # drop_duplicates(subset=["title_key"])
            # default-nya keep="first".
            if title_key in seen_titles:
                continue

            seen_titles.add(title_key)

            if has_cleaned_ingredients:
                ingredient_source = raw_row.get(
                    "Cleaned_Ingredients"
                )
            else:
                ingredient_source = ingredients_text

            ingredient_list = parse_list_like(
                ingredient_source
            )

            # Sama seperti fallback notebook.
            if not ingredient_list:
                ingredient_list = parse_list_like(
                    ingredients_text
                )

            ingredient_text = ", ".join(
                ingredient_list
            )

            recipe_id = len(cleaned_rows)

            cleaned_rows.append(
                {
                    "recipe_id": str(recipe_id),
                    "Title": title,
                    "ingredient_list": ingredient_list,
                    "ingredient_text": ingredient_text,
                }
            )

    return cleaned_rows


def load_metadata():
    with METADATA.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                "Header metadata tidak ditemukan."
            )

        return list(reader.fieldnames), list(reader)


def validate_alignment(
    rebuilt_rows: list[dict],
    metadata_rows: list[dict],
):
    print(
        f"Hasil preprocessing dataset asli: "
        f"{len(rebuilt_rows)} resep"
    )

    print(
        f"Metadata backend: "
        f"{len(metadata_rows)} resep"
    )

    if len(rebuilt_rows) != len(metadata_rows):
        raise RuntimeError(
            "Jumlah resep berbeda. "
            "Metadata BELUM diubah."
        )

    rebuilt_by_id = {
        row["recipe_id"]: row
        for row in rebuilt_rows
    }

    title_mismatches = []
    ingredient_mismatches = []
    invalid_ids = []

    for metadata_row in metadata_rows:
        recipe_id = str(
            metadata_row.get(
                "recipe_id",
                "",
            )
        ).strip()

        rebuilt = rebuilt_by_id.get(recipe_id)

        if rebuilt is None:
            invalid_ids.append(recipe_id)
            continue

        metadata_title = normalize_whitespace(
            metadata_row.get("Title")
        )

        rebuilt_title = rebuilt["Title"]

        if metadata_title != rebuilt_title:
            title_mismatches.append(
                (
                    recipe_id,
                    metadata_title,
                    rebuilt_title,
                )
            )

        metadata_ingredients = normalize_whitespace(
            metadata_row.get("ingredient_text")
        )

        rebuilt_ingredients = normalize_whitespace(
            rebuilt["ingredient_text"]
        )

        if metadata_ingredients != rebuilt_ingredients:
            ingredient_mismatches.append(
                (
                    recipe_id,
                    metadata_title,
                )
            )

    print(
        f"Recipe ID tidak valid: "
        f"{len(invalid_ids)}"
    )

    print(
        f"Title mismatch: "
        f"{len(title_mismatches)}"
    )

    print(
        f"Ingredient text mismatch: "
        f"{len(ingredient_mismatches)}"
    )

    if invalid_ids:
        print("\nContoh Recipe ID tidak valid:")

        for recipe_id in invalid_ids[:10]:
            print(f"- {recipe_id}")

    if title_mismatches:
        print("\nContoh Title mismatch:")

        for (
            recipe_id,
            metadata_title,
            rebuilt_title,
        ) in title_mismatches[:10]:
            print(
                f"- ID {recipe_id}\n"
                f"  metadata : {metadata_title}\n"
                f"  rebuilt  : {rebuilt_title}"
            )

    if ingredient_mismatches:
        print(
            "\nContoh Ingredient mismatch:"
        )

        for (
            recipe_id,
            title,
        ) in ingredient_mismatches[:10]:
            print(
                f"- ID {recipe_id}: {title}"
            )

    if (
        invalid_ids
        or title_mismatches
        or ingredient_mismatches
    ):
        raise RuntimeError(
            "\nValidasi gagal. "
            "Metadata BELUM diubah."
        )

    print(
        "\nVALIDASI SUKSES: "
        "dataset asli dan metadata backend "
        "100% sejajar."
    )


def write_ingredient_lists(
    fieldnames: list[str],
    metadata_rows: list[dict],
    rebuilt_rows: list[dict],
):
    rebuilt_by_id = {
        row["recipe_id"]: row
        for row in rebuilt_rows
    }

    for metadata_row in metadata_rows:
        recipe_id = str(
            metadata_row["recipe_id"]
        ).strip()

        ingredient_list = rebuilt_by_id[
            recipe_id
        ]["ingredient_list"]

        metadata_row["ingredient_list"] = (
            json.dumps(
                ingredient_list,
                ensure_ascii=False,
            )
        )

    if "ingredient_list" not in fieldnames:
        if "ingredient_text" in fieldnames:
            insert_at = (
                fieldnames.index(
                    "ingredient_text"
                )
                + 1
            )

            fieldnames.insert(
                insert_at,
                "ingredient_list",
            )

        else:
            fieldnames.append(
                "ingredient_list"
            )

    timestamp = datetime.now().strftime(
        "%Y%m%d-%H%M%S"
    )

    backup_path = METADATA.with_name(
        f"{METADATA.stem}"
        f".backup-{timestamp}"
        f"{METADATA.suffix}"
    )

    shutil.copy2(
        METADATA,
        backup_path,
    )

    print(
        f"\nBackup dibuat:\n"
        f"{backup_path}"
    )

    temp_path = METADATA.with_suffix(
        ".tmp.csv"
    )

    with temp_path.open(
        "w",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(
            metadata_rows
        )

    temp_path.replace(
        METADATA
    )

    print(
        "\nSUKSES: kolom ingredient_list "
        "sudah ditambahkan."
    )


def main():
    if not RAW_DATASET.is_file():
        raise FileNotFoundError(
            f"Dataset asli tidak ditemukan:\n"
            f"{RAW_DATASET}"
        )

    if not METADATA.is_file():
        raise FileNotFoundError(
            f"Metadata tidak ditemukan:\n"
            f"{METADATA}"
        )

    rebuilt_rows = rebuild_clean_dataset()

    fieldnames, metadata_rows = (
        load_metadata()
    )

    validate_alignment(
        rebuilt_rows,
        metadata_rows,
    )

    write_ingredient_lists(
        fieldnames,
        metadata_rows,
        rebuilt_rows,
    )


if __name__ == "__main__":
    main()