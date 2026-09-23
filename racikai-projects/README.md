# RacikAI Flutter + Python AI

Tab AI memanggil `POST /chat`: query → model E5 hasil fine-tuning → FAISS → resep sumber → Gemini (opsional). Panjang maksimum 384 token, prefix `query: `, dan embedding ternormalisasi mengikuti notebook. Tanpa Gemini, pencarian resep tetap berfungsi. Fitur selain tab AI masih memakai data lokal aplikasi.

## Jalankan backend

```powershell
cd D:\Codingan\Mobile\tugas_uts\racikai-projects\backend
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\start.ps1
```

Jika dependensi sudah terpasang, cukup jalankan `start.ps1`.
Folder default adalah `D:\Codingan\Mobile\file ai\recovered-kaggle` jika ada, atau `D:\Codingan\Mobile\file ai` sebagai fallback. Lokasi lain: `.\start.ps1 -ModelDir 'D:\lokasi\bundle'`, atau environment `AI_MODEL_DIR`.
Bundle berisi `model/`, `recipe_faiss.index`, dan `recipe_metadata.csv`. Susunan lama dengan file model di folder utama juga didukung.

Buka `http://localhost:8000/health` untuk status model dan `http://localhost:8000/docs` untuk mencoba API. Aset rusak menghasilkan `not_ready` dan respons chat 503. Restart server setelah mengganti aset.

### Gemini (opsional)

Jalankan `.\start.ps1 -GeminiModel 'ID_MODEL_YANG_AKTIF_DI_AKUNMU'`.
Ganti ID dengan model yang tersedia di akunmu; notebook asli memakai `gemini-3.5-flash-lite`. Script meminta API key secara tersembunyi di terminal. Alternatifnya set environment `GEMINI_API_KEY` dan `GEMINI_MODEL` sebelum start.
Key Kaggle Secrets tidak otomatis tersedia di komputer lokal. Jangan simpan key di Flutter atau Git.

Saat aktif, pertanyaan dan resep hasil pencarian dikirim ke Gemini untuk menyusun jawaban Bahasa Indonesia. `/health` melaporkan konfigurasi, bukan validitas key. Jika Gemini gagal, hasil pencarian tetap dikembalikan dengan penjelasan. Respons `generation` menunjukkan `gemini`, `retrieval_only`, atau `unavailable`.

## Jalankan Flutter

Dari root project:

```powershell
flutter pub get
flutter run --dart-define=AI_BASE_URL=http://10.0.2.2:8000
```

Default Android memakai alamat emulator `10.0.2.2`. Untuk HP fisik, ganti dengan IP LAN komputer, misalnya `http://192.168.1.10:8000`. Perangkat harus bisa saling terhubung; izinkan port 8000 pada firewall jaringan privat jika diperlukan. HTTP lokal hanya diizinkan pada build debug; release memakai HTTPS.

Untuk web:

```powershell
flutter run -d chrome --web-port=3000 --dart-define=AI_BASE_URL=http://localhost:8000
```

CORS mengizinkan localhost dan 127.0.0.1 port 3000. Origin lain dapat diatur melalui `CORS_ORIGINS` (dipisahkan koma). Backend ini untuk pengembangan lokal dan belum memakai autentikasi. Kuota AI tetap disimpan di aplikasi dan bertambah setelah respons berhasil. Hasil pencarian terdekat bukan jaminan semua bahan atau pantangan sesuai.

## Pemulihan model dan perbaikan notebook

Model lengkap dipulihkan dari output https://www.kaggle.com/code/dantegunawan/ragresep ke `file ai/recovered-kaggle`, bersama index dan CSV dari output yang sama. File lama tidak ditimpa. Script pemulihan ada di `file ai/recover_kaggle.py`.

Masalah ekspor sebelumnya:

- Bobot lokal dan Hugging Face berukuran 272.613.376 byte, padahal header tensor memerlukan 1.112.197.064 byte. Bobot lengkap di Kaggle memiliki ukuran yang diperlukan.
- Sel ZIP notebook hanya memilih file di tingkat utama, sehingga folder `1_Pooling` dan `2_Normalize` tertinggal. Ini menjelaskan konfigurasi yang hilang, tetapi bukan bukti penyebab bobot terpotong.

`notebooks/ragresep_backend_fixed.ipynb` adalah salinan dengan ekspor lengkap di bagian 18. Notebook asli tidak diubah. Ekspor menyertakan seluruh subfolder model, index, CSV, checksum SHA-256, pemeriksaan ZIP, dan uji kecocokan embedding. Kode ekspor juga tersedia di `backend/export_bundle.py`.

## Verifikasi

```powershell
flutter analyze
flutter test
cd backend
.\.venv\Scripts\python.exe -m unittest -v
.\.venv\Scripts\python.exe verify_bundle.py 'D:\Codingan\Mobile\file ai\recovered-kaggle' --output verification.json
```

Unit test menguji kontrak API, error model, dan Gemini memakai provider tiruan. `verify_bundle.py` memuat model asli, membandingkan tiga embedding dokumen terhadap index (cosine minimal 0,999), serta menguji query Bahasa Indonesia dan judul resep. Ini bukan evaluasi kualitas untuk seluruh dataset. Untuk tes API tanpa model, cukup pasang `requirements-api.txt`.
