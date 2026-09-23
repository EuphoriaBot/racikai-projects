"""Check real model/index compatibility and run a recipe query (no Gemini calls)."""
import argparse
import json
from pathlib import Path

import numpy as np
from app import RecipeEngine


def verify(directory):
    engine = RecipeEngine(Path(directory))
    probes = [0, len(engine.rows) // 2, len(engine.rows) - 1]
    vectors = engine.model.encode(
        ["passage: " + engine.rows[i]["retrieval_document"] for i in probes],
        normalize_embeddings=True, convert_to_numpy=True,
    )
    similarities = [float(np.dot(vectors[n], engine.index.reconstruct(i))) for n, i in enumerate(probes)]
    if min(similarities) < 0.999:
        raise ValueError(f"Model tidak cocok dengan index: {similarities}")
    queries = ["Saya punya ayam, kentang, bawang putih dan cabai. Bisa masak apa?",
               "resep " + engine.rows[0]["Title"]]
    result = {"rows": len(engine.rows), "dimension": engine.index.d,
              "probe_cosine": similarities, "queries": {}}
    for query in queries:
        result["queries"][query] = [{"id": item["id"], "title": item["title"]}
                                     for item in engine.search(query, 3)]
    if result["queries"][queries[1]][0]["id"] != engine.rows[0]["recipe_id"]:
        raise ValueError("Query judul resep tidak menemukan resep sumber sebagai hasil pertama.")
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("directory")
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = verify(args.directory)
    content = json.dumps(result, indent=2, ensure_ascii=True)
    print(content)
    if args.output:
        args.output.write_text(content + "\n", encoding="utf-8")
