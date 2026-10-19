import csv
import json
import getpass
from pathlib import Path

import psycopg

CSV_PATH = (
    Path(__file__).resolve().parents[2]
    / "file ai"
    / "recovered-kaggle"
    / "recipe_metadata.csv"
)

BATCH_SIZE = 250

INSERT_SQL = """
INSERT INTO public.recipes (
    faiss_position,
    recipe_id,
    title,
    ingredient_text,
    ingredient_list,
    instructions,
    image_name,
    raw_metadata
)
VALUES (
    %s, %s, %s, %s,
    %s::jsonb, %s, %s, %s::jsonb
)
ON CONFLICT (faiss_position)
DO UPDATE SET
    recipe_id = EXCLUDED.recipe_id,
    title = EXCLUDED.title,
    ingredient_text = EXCLUDED.ingredient_text,
    ingredient_list = EXCLUDED.ingredient_list,
    instructions = EXCLUDED.instructions,
    image_name = EXCLUDED.image_name,
    raw_metadata = EXCLUDED.raw_metadata
"""

def parse_ingredients(value: str) -> list[str]:
    if not value:
        return []

    parsed = json.loads(value)

    if not isinstance(parsed, list):
        raise ValueError(
            "ingredient_list bukan JSON array."
        )

    return [
        str(item).strip()
        for item in parsed
        if str(item).strip()
    ]


def import_recipes():
    if not CSV_PATH.is_file():
        raise FileNotFoundError(
            f"Dataset tidak ditemukan: {CSV_PATH}"
        )

    print("=== Import Database RacikAI ===")
    print(f"Dataset: {CSV_PATH}")
    print("Database: racikai_db")

    password = getpass.getpass(
        "Password PostgreSQL: "
    )

    total = 0

    with psycopg.connect(
        host="127.0.0.1",
        port=5432,
        dbname="racikai_db",
        user="postgres",
        password=password,
        connect_timeout=10,
    ) as conn:

        with conn.cursor() as cursor:

            with CSV_PATH.open(
                "r",
                encoding="utf-8-sig",
                newline="",
            ) as file:

                reader = csv.DictReader(file)

                required = {
                    "recipe_id",
                    "Title",
                    "ingredient_text",
                    "ingredient_list",
                    "Instructions",
                    "Image_Name",
                }

                if not required.issubset(
                    reader.fieldnames or []
                ):
                    raise ValueError(
                        "Kolom CSV tidak lengkap."
                    )

                batch = []

                for position, row in enumerate(reader):

                    ingredients = parse_ingredients(
                        row.get("ingredient_list", "")
                    )

                    batch.append(
                        (
                            position,
                            row["recipe_id"],
                            row["Title"],
                            row["ingredient_text"],
                            json.dumps(
                                ingredients,
                                ensure_ascii=False,
                            ),
                            row["Instructions"],
                            row.get("Image_Name") or None,
                            json.dumps(
                                row,
                                ensure_ascii=False,
                            ),
                        )
                    )

                    total += 1

                    if len(batch) >= BATCH_SIZE:
                        cursor.executemany(
                            INSERT_SQL,
                            batch,
                        )

                        batch.clear()

                        print(
                            f"Memproses {total} resep..."
                        )

                if batch:
                    cursor.executemany(
                        INSERT_SQL,
                        batch,
                    )

            cursor.execute(
                """
                SELECT
                    COUNT(*),
                    MIN(faiss_position),
                    MAX(faiss_position)
                FROM public.recipes
                """
            )

            db_count, first_pos, last_pos = (
                cursor.fetchone()
            )

            if (
                db_count != total
                or first_pos != 0
                or last_pos != total - 1
            ):
                raise ValueError(
                    "Jumlah atau posisi resep "
                    "di PostgreSQL tidak sesuai CSV."
                )

    print()
    print("=== IMPORT BERHASIL ===")
    print(f"Total resep: {total}")
    print("Posisi FAISS: 0 sampai", total - 1)
    print("Data tersimpan di PostgreSQL.")


if __name__ == "__main__":
    import_recipes()
