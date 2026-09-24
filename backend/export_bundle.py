"""Run in Kaggle after training to export the full model and matching index."""
import csv
import hashlib
import json
import tempfile
import zipfile
from pathlib import Path


def export_bundle(model, index_path, metadata_path, output_path):
    import faiss
    import numpy as np
    from sentence_transformers import SentenceTransformer
    from safetensors import safe_open

    index_path, metadata_path, output_path = map(Path, (index_path, metadata_path, output_path))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    index = faiss.read_index(str(index_path))
    with metadata_path.open(encoding="utf-8-sig", newline="") as stream:
        rows = list(csv.DictReader(stream))
    if not rows or len(rows) != index.ntotal:
        raise ValueError("Jumlah baris metadata berbeda dengan index.")
    with tempfile.TemporaryDirectory(prefix="racikai-export-", dir=output_path.parent) as folder:
        root = Path(folder)
        model.save_pretrained(str(root / "model"), safe_serialization=True)
        with safe_open(root / "model" / "model.safetensors", framework="pt", device="cpu") as tensors:
            if not list(tensors.keys()):
                raise ValueError("Model kosong.")
        reloaded = SentenceTransformer(str(root / "model"), device="cpu", local_files_only=True)
        reloaded.max_seq_length = 384
        probes = [0, len(rows) // 2, len(rows) - 1]
        encoded = reloaded.encode(["passage: " + rows[i]["retrieval_document"] for i in probes],
                                  normalize_embeddings=True, convert_to_numpy=True)
        similarities = [float(np.dot(encoded[n], index.reconstruct(i))) for n, i in enumerate(probes)]
        if min(similarities) < 0.999:
            raise ValueError(f"Model dan index tidak cocok: {similarities}")
        files = {p.relative_to(root).as_posix(): p for p in (root / "model").rglob("*") if p.is_file()}
        files.update({"recipe_faiss.index": index_path, "recipe_metadata.csv": metadata_path})
        manifest = {"rows": len(rows), "dimension": index.d, "max_seq_length": 384,
                    "probe_cosine": similarities, "sha256": {}}
        for name, path in files.items():
            with path.open("rb") as stream:
                manifest["sha256"][name] = hashlib.file_digest(stream, "sha256").hexdigest()
        temporary_zip = root / "bundle.zip"
        with zipfile.ZipFile(temporary_zip, "w", zipfile.ZIP_DEFLATED, allowZip64=True) as archive:
            for name, path in files.items():
                archive.write(path, name)
            archive.writestr("manifest.json", json.dumps(manifest, indent=2))
        with zipfile.ZipFile(temporary_zip) as archive:
            if archive.testzip() is not None:
                raise ValueError("Pemeriksaan ZIP gagal.")
        temporary_zip.replace(output_path)
    print(f"Bundle terverifikasi: {output_path} ({output_path.stat().st_size:,} byte)")
    return output_path
