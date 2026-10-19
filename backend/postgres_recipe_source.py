import json
import os

import psycopg


def load_rows_from_postgres() -> list[dict]:
    password = os.getenv("PGPASSWORD")

    if not password:
        raise ValueError(
            "PGPASSWORD belum dikonfigurasi."
        )

    rows = []

    with psycopg.connect(
        host=os.getenv("PGHOST", "127.0.0.1"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE", "racikai_db"),
        user=os.getenv("PGUSER", "racikai_reader"),
        password=password,
        connect_timeout=10,
    ) as conn:

        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT
                    faiss_position,
                    recipe_id,
                    title,
                    ingredient_text,
                    ingredient_list,
                    instructions,
                    image_name
                FROM public.recipes
                ORDER BY faiss_position ASC
                """
            )

            for record in cursor:
                (
                    position,
                    recipe_id,
                    title,
                    ingredient_text,
                    ingredient_list,
                    instructions,
                    image_name,
                ) = record

                if position != len(rows):
                    raise ValueError(
                        "Urutan metadata PostgreSQL "
                        f"tidak sesuai pada posisi {position}."
                    )

                if not isinstance(ingredient_list, list):
                    raise ValueError(
                        "ingredient_list PostgreSQL "
                        "harus berbentuk array."
                    )

                rows.append(
                    {
                        "recipe_id": recipe_id,
                        "Title": title,
                        "ingredient_text": ingredient_text,
                        "ingredient_list": json.dumps(
                            ingredient_list,
                            ensure_ascii=False,
                        ),
                        "Instructions": instructions,
                        "Image_Name": image_name or "",
                    }
                )

    return rows
