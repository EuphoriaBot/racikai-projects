# 🍳 RacikAI — AI Recipe Assistant

**Bahan biasa, rasa istimewa**

RacikAI adalah aplikasi pencarian, eksplorasi, dan rekomendasi resep makanan berbasis **Flutter** yang mengintegrasikan teknologi **Artificial Intelligence (AI)** menggunakan pendekatan **Retrieval-Augmented Generation (RAG)**

RacikAI membantu pengguna menemukan inspirasi masakan, mencari resep berdasarkan nama atau bahan, menyimpan resep favorit, menyusun rencana makan mingguan, serta mendapatkan rekomendasi resep melalui AI Assistant dalam Bahasa Indonesia

Aplikasi dikembangkan sebagai proyek mata kuliah **Pemrograman Piranti Bergerak**

**Teknologi utama:** Flutter · Dart · FastAPI · Python · Sentence Transformers · FAISS · Gemini · PostgreSQL · SharedPreferences

---

## 📖 Tentang RacikAI

Tidak semua orang mengetahui makanan apa yang dapat dibuat dari bahan yang tersedia di rumah. Mencari resep satu per satu juga membutuhkan waktu, terutama ketika pengguna hanya mengetahui bahan yang dimiliki, bukan nama masakannya

RacikAI dikembangkan untuk membantu permasalahan tersebut dengan menggabungkan katalog resep dan asisten AI dalam satu aplikasi

Pengguna dapat menjelajahi resep secara langsung atau mengajukan pertanyaan seperti:

> Saya punya telur dan kentang. Masak apa ya?

> Ada rekomendasi makanan dari ayam dan kecap?

> Mau masak apa lagi dari telur?

RacikAI akan mencari resep yang relevan dari dataset, memeriksa kecocokannya, kemudian menyusun jawaban yang mudah dipahami

Untuk permintaan lanjutan, aplikasi juga dapat menghindari resep yang baru saja direkomendasikan sehingga pengguna mendapatkan alternatif menu yang lebih bervariasi

## ✨ Fitur Utama

### 1. Home — Inspirasi Memasak

Halaman Home menjadi titik awal untuk menjelajahi RacikAI

Fitur yang tersedia:

- Hero header dengan gambar makanan yang dipilih secara acak.
- Akses cepat menuju pencarian resep.
- Kategori makanan untuk mempermudah eksplorasi.
- Carousel **Inspirasi Hari Ini** yang berpindah otomatis.
- Pilihan resep acak yang dapat berubah ketika data dimuat ulang.
- Bagian resep lainnya untuk menemukan inspirasi tambahan.
- Tombol favorit untuk menyimpan resep.
- Akses menuju fitur **Dari Bahan** dan **Rencana Makan**

Home dirancang menggunakan antarmuka yang sederhana, hangat, dan mudah digunakan

### 2. Search — Jelajahi Resep

Halaman Search terhubung dengan katalog resep melalui backend FastAPI.

Pengguna dapat mencari resep berdasarkan:

- Nama makanan
- Bahan masakan
- Kategori resep

Kategori yang tersedia:

| Kategori | Deskripsi                           |
| -------- | ----------------------------------- |
| Semua    | Menampilkan seluruh kategori resep  |
| Ayam     | Resep yang berkaitan dengan ayam    |
| Daging   | Resep berbahan daging               |
| Nasi     | Resep berbahan nasi                 |
| Pasta    | Berbagai resep pasta                |
| Sayur    | Resep yang berkaitan dengan sayuran |
| Dessert  | Aneka hidangan penutup              |

Search memiliki beberapa kemampuan tambahan:

- Pencarian otomatis setelah pengguna berhenti mengetik sejenak
- Filter kategori yang tetap berlaku ketika melakukan pencarian
- Normalisasi beberapa istilah Bahasa Indonesia ke Bahasa Inggris
- Pagination agar tidak memuat seluruh dataset sekaligus
- Pengacakan urutan resep pada halaman hasil yang diterima
- Tampilan gambar, judul, dan informasi resep
- Navigasi ke halaman detail resep

Contoh normalisasi pencarian:

| Kata Indonesia | Istilah dataset |
| -------------- | --------------- |
| Ayam           | chicken         |
| Telur          | egg             |
| Kentang        | potato          |
| Daging sapi    | beef            |
| Kecap          | soy sauce       |
| Kecap manis    | sweet soy sauce |
| Bawang putih   | garlic          |
| Sayur          | vegetable       |

Fitur Search bekerja melalui endpoint `/recipes` tanpa menggunakan Gemini

### 3. RacikAI Assistant — Rekomendasi Berbasis AI

RacikAI Assistant merupakan fitur utama yang menggabungkan pencarian resep berbasis embedding dengan kemampuan generatif Gemini

Pengguna dapat bertanya menggunakan bahasa natural, misalnya:

> Saya punya ayam dan kecap. Bisa masak apa?

AI Assistant kemudian menjalankan beberapa proses:

1. Memeriksa apakah pertanyaan masih berkaitan dengan makanan atau resep
2. Menulis ulang pertanyaan apabila diperlukan agar lebih sesuai dengan dataset
3. Mengubah query menjadi embedding menggunakan Sentence Transformers
4. Mengambil kandidat resep melalui pencarian FAISS
5. Memeriksa relevansi kandidat terhadap pertanyaan pengguna
6. Memilih resep yang sesuai dan belum termasuk dalam riwayat rekomendasi terbaru
7. Menyusun jawaban menggunakan Gemini berdasarkan resep yang ditemukan
8. Menampilkan jawaban beserta kartu resep yang dapat dibuka

Secara default, chatbot menampilkan **maksimal tiga rekomendasi resep** dalam satu respons

#### Smart Recipe Rotation

RacikAI memiliki mekanisme untuk mengurangi pengulangan rekomendasi

Contoh:

**Pertanyaan pertama:**

> Masak apa dari telur?

RacikAI memberikan tiga resep telur

**Pertanyaan kedua:**

> Masak apa lagi dari telur?

RacikAI mengirim ID resep sebelumnya ke backend, sehingga backend dapat mencari alternatif resep relevan yang berbeda

Riwayat rekomendasi disimpan menggunakan **SharedPreferences** pada perangkat pengguna

Sistem menyimpan hingga **60 ID resep terbaru**, sehingga riwayat tetap tersedia meskipun aplikasi ditutup dan dibuka kembali

Ketika kandidat relevan yang belum pernah ditampilkan sudah terbatas, jumlah rekomendasi dapat lebih sedikit daripada tiga

### 4. Recipe Detail

Pengguna dapat membuka detail resep dari berbagai bagian aplikasi, termasuk Home, Search, hasil pencarian bahan, dan AI Assistant

Informasi yang ditampilkan meliputi:

- Gambar makanan
- Nama resep
- Daftar bahan
- Jumlah bahan
- Langkah-langkah memasak
- Tombol untuk menyimpan atau menghapus favorit

Resep yang berasal dari katalog dan rekomendasi AI menggunakan model data yang terintegrasi dengan backend

### 5. Saved — Resep Favorit

Saved memungkinkan pengguna mengumpulkan resep yang ingin dibuka kembali

Fitur ini meliputi:

- Menambahkan dan menghapus resep favorit
- Menampilkan daftar resep yang telah disimpan
- Membuka kembali detail resep favorit
- Menampilkan gambar dan informasi resep
- Menampilkan preview koleksi favorit pada bagian header

ID favorit beserta data resep backend yang disimpan dikelola secara lokal menggunakan SharedPreferences

Dengan demikian, koleksi favorit dapat dipertahankan ketika aplikasi ditutup dan dibuka kembali

### 6. Ingredient Finder — Pencarian dari Bahan

Ingredient Finder membantu pengguna mencari resep berdasarkan bahan makanan yang tersedia

Pengguna dapat memilih beberapa bahan, misalnya:

- Ayam
- Telur
- Kentang
- Bawang putih
- Bawang merah
- Kecap
- Keju
- Sayuran

Bahan yang dipilih diterjemahkan menjadi istilah pencarian yang digunakan oleh backend

Setelah pengguna menekan tombol pencarian, RacikAI menampilkan hasil resep berdasarkan kombinasi bahan tersebut

Hasil pencarian menggunakan katalog resep yang sama dengan fitur Search

### 7. Meal Planner — Rencana Makan Mingguan

Meal Planner digunakan untuk mengatur menu makanan selama satu minggu

Fitur ini menyediakan:

- Daftar rencana makan berdasarkan hari
- Pemilihan resep dari katalog backend
- Tampilan resep yang telah dijadwalkan
- Indikator jumlah hari yang sudah memiliki menu
- Penggantian resep pada hari tertentu
- Penghapusan seluruh rencana makan

Data rencana makan disimpan secara lokal menggunakan SharedPreferences agar tetap tersedia setelah aplikasi ditutup

---

## 🎨 Desain Antarmuka

RacikAI menggunakan konsep desain **Fresh & Warm**, dengan pendekatan visual yang bersih, hangat, dan nyaman dilihat

Palet warna utama:

| Warna      | Kode      | Penggunaan               |
| ---------- | --------- | ------------------------ |
| Sage Green | `#66775A` | Identitas utama aplikasi |
| Dark Sage  | `#4F6046` | Aksen hijau lebih gelap  |
| Ivory      | `#F7F5F0` | Latar belakang           |
| Warm White | `#FFFDF9` | Permukaan dan kartu      |
| Peach      | `#D9895B` | Aksen visual             |
| Dark Text  | `#252722` | Teks utama               |

Karakteristik UI:

- Hero header dengan visual makanan
- Kartu resep dengan sudut membulat
- Penggunaan gambar untuk memperkuat identitas kuliner
- Navigasi utama yang sederhana
- Desain yang menyesuaikan lebar layar
- Konsistensi warna pada Home, Search, AI Chat, dan Saved

Navigasi utama terdiri dari empat halaman:

**Home · Search · AI · Saved**

Ingredient Finder dan Meal Planner dapat diakses melalui navigasi tambahan dari Home

---

## 🏗️ Arsitektur Sistem

RacikAI menggunakan Flutter sebagai antarmuka pengguna dan FastAPI sebagai backend untuk menyediakan katalog resep serta pemrosesan AI

```text
                    ┌─────────────────────┐
                    │    Flutter App      │
                    │                     │
                    │  Home / Search      │
                    │  AI Chat / Saved    │
                    │  Ingredient Finder  │
                    │  Meal Planner       │
                    └──────────┬──────────┘
                               │
                         HTTP / JSON
                               │
                    ┌──────────▼──────────┐
                    │   FastAPI Backend   │
                    │                     │
                    │  GET /health        │
                    │  GET /recipes       │
                    │  POST /chat         │
                    │  /recipe-images     │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼─────────────────┐
              │                │                 │
       ┌──────▼──────┐  ┌──────▼──────┐  ┌───────▼───────┐
       │ Recipe Data │  │ E5 + FAISS  │  │  Gemini API   │
       │             │  │             │  │               │
       │ CSV /       │  │ Retrieval   │  │ Query Rewrite │
       │ PostgreSQL  │  │ Embedding   │  │ Relevance     │
       └─────────────┘  └─────────────┘  │ Generation    │
                                         └───────────────┘
```

### Frontend — Flutter

Flutter menangani:

- Tampilan dan navigasi aplikasi
- Input pencarian pengguna
- Penyajian hasil katalog dan AI Chat
- Interaksi favorit
- Rencana makan mingguan
- Penyimpanan preferensi dan riwayat rekomendasi
- Komunikasi HTTP dengan backend

### Backend — FastAPI

FastAPI menangani:

- Pencarian dan pagination katalog resep
- Pemfilteran berdasarkan kategori
- Normalisasi query pencarian
- Pembacaan metadata resep
- Pencarian vektor menggunakan FAISS
- Integrasi dengan model embedding
- Komunikasi dengan Gemini
- Pemeriksaan relevansi rekomendasi
- Pengecualian ID resep yang sudah direkomendasikan
- Penyediaan URL gambar resep
- Pemeriksaan kesiapan layanan

---

## 🧠 Arsitektur RAG

RacikAI menggunakan pendekatan **Retrieval-Augmented Generation (RAG)** untuk menghubungkan model bahasa dengan informasi resep yang berasal dari dataset

Alur pemrosesan AI:

```text
Pertanyaan pengguna
        │
        ▼
Intent Checking
        │
        ▼
Gemini Query Rewriting
        │
        ▼
Sentence Transformer (E5)
        │
        ▼
Query Embedding
        │
        ▼
FAISS Similarity Search
        │
        ▼
Candidate Recipes
        │
        ▼
Exclude Previously Recommended IDs
        │
        ▼
Relevance Filtering
        │
        ▼
Maximum 3 Recipes
        │
        ▼
Gemini Answer Generation
        │
        ▼
JSON Response
        │
        ▼
Flutter AI Chat
```

### Model Embedding

Model Sentence Transformer berbasis E5 digunakan untuk mengubah pertanyaan pengguna menjadi representasi vektor

### FAISS

FAISS digunakan untuk melakukan pencarian berdasarkan kemiripan antara embedding pertanyaan dan embedding resep

### Gemini

Gemini digunakan untuk mendukung pemahaman pertanyaan, query rewriting, pemeriksaan relevansi, dan penyusunan jawaban berdasarkan resep yang berhasil ditemukan

### Recommendation History

Riwayat ID resep dikirim dari Flutter melalui parameter `exclude_recipe_ids`

Backend kemudian mencoba memilih alternatif resep yang relevan tanpa mengulang ID dalam daftar tersebut

Pendekatan ini membantu mengurangi rekomendasi berulang tanpa perlu melakukan pelatihan ulang model atau pembangunan ulang FAISS index

---

## 📊 Dataset dan Penyimpanan Data

RacikAI menggunakan dataset Kaggle:

**Food Ingredients and Recipes Dataset with Images**

Dataset berisi sekitar **13 ribu resep**, termasuk informasi:

- Judul resep
- Bahan makanan
- Daftar bahan terstruktur
- Langkah memasak
- Nama atau metadata gambar

Metadata yang digunakan dalam pipeline RAG antara lain:

```text
recipe_id
Title
ingredient_text
ingredient_list
Instructions
Image_Name
```

### Sumber Data Backend

Backend dapat menggunakan dua sumber metadata resep:

**CSV**

Metadata dibaca dari `recipe_metadata.csv` dan disesuaikan dengan urutan vektor pada FAISS index

**PostgreSQL**

Backend juga mendukung pembacaan data dari PostgreSQL menggunakan konfigurasi `RECIPE_DATA_SOURCE=postgres`

Ketika mode PostgreSQL digunakan, backend memeriksa kesesuaian metadata dan urutan data terhadap indeks FAISS. Jika pembacaan atau validasi gagal, backend dapat menggunakan CSV sebagai sumber cadangan

### Pengelolaan Gambar

Gambar resep disediakan melalui backend menggunakan endpoint:

```text
/recipe-images/{filename}
```

Sistem melakukan pemeriksaan gambar dan menggunakan cache validasi untuk mengurangi pemeriksaan ulang file yang tidak berubah

Resep dengan referensi gambar yang tidak valid dapat dilewati dalam pencarian agar gambar rusak tidak ditampilkan kepada pengguna

Berkas model, FAISS index, metadata berukuran besar, dan koleksi gambar tidak disertakan langsung dalam repository GitHub

---

## 🧰 Teknologi yang Digunakan

| Komponen                 | Teknologi                      |
| ------------------------ | ------------------------------ |
| Frontend                 | Flutter                        |
| Bahasa frontend          | Dart                           |
| Backend                  | FastAPI                        |
| Bahasa backend           | Python                         |
| State management         | Flutter BLoC / Cubit           |
| Routing                  | go_router                      |
| Dependency injection     | get_it                         |
| HTTP client              | http                           |
| Penyimpanan lokal        | shared_preferences             |
| Model embedding          | Sentence Transformers / E5     |
| Vector similarity search | FAISS                          |
| Arsitektur AI            | Retrieval-Augmented Generation |
| Large Language Model     | Gemini                         |
| Metadata resep           | CSV / PostgreSQL               |
| Database PostgreSQL      | psycopg                        |
| Pengolahan gambar        | Pillow                         |
| Pengujian backend        | pytest                         |
| Version control          | Git / GitHub                   |

---

## 🔌 Backend API

### 1. Health Check

```http
GET /health
```

Digunakan untuk melihat kesiapan backend, sumber data resep, konfigurasi AI, dan status gambar

### 2. Recipe Catalog

```http
GET /recipes
```

Parameter utama:

| Parameter  | Deskripsi                |
| ---------- | ------------------------ |
| `q`        | Kata kunci pencarian     |
| `category` | Kategori resep           |
| `page`     | Nomor halaman            |
| `limit`    | Jumlah resep per halaman |

Contoh:

```http
GET /recipes?page=1&limit=24
GET /recipes?q=telur
GET /recipes?category=Ayam
GET /recipes?q=kentang&category=Sayur
```

Respons berisi daftar resep beserta informasi pagination seperti `page`, `limit`, `total`, dan `has_more`

### 3. AI Chat

```http
POST /chat
Content-Type: application/json
```

Contoh request:

```json
{
  "message": "Masak apa dari telur?",
  "top_k": 3,
  "exclude_recipe_ids": []
}
```

Contoh request lanjutan:

```json
{
  "message": "Masak apa lagi dari telur?",
  "top_k": 3,
  "exclude_recipe_ids": ["5645", "10575", "2089"]
}
```

Respons berisi:

- `text` — Jawaban chatbot
- `recipes` — Rekomendasi resep yang terpilih
- `generation` — Status generation

Field `exclude_recipe_ids` bersifat opsional dan digunakan untuk menghindari rekomendasi berulang

### 4. Recipe Images

```http
GET /recipe-images/{filename}
```

Endpoint ini melayani gambar resep yang sudah tersedia di direktori gambar backend

---

## 📁 Struktur Proyek

Struktur utama repository:

```text
racikai-projects/
│
├── android/
│   └── ...
│
├── assets/
│   ├── icons/
│   └── images/
│
├── backend/
│   ├── app.py
│   ├── generation.py
│   ├── postgres_recipe_source.py
│   ├── requirements.txt
│   ├── requirements-api.txt
│   ├── start.ps1
│   ├── start-dev.ps1
│   └── test_app.py
│
├── lib/
│   ├── controllers/
│   ├── core/
│   ├── features/
│   │   ├── ai/
│   │   ├── favorite/
│   │   └── recipe/
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── main.dart
│
├── web/
├── pubspec.yaml
└── README.md
```

Pada bagian Flutter, proyek memanfaatkan organisasi berbasis fitur untuk AI, Favorite, dan Recipe

Backend ditempatkan terpisah agar pengolahan dataset, kredensial Gemini, serta proses retrieval tidak dijalankan langsung pada aplikasi pengguna

---

## 🚀 Cara Menjalankan Proyek

### Persyaratan

Pastikan lingkungan pengembangan menyediakan:

- Flutter SDK dan Dart SDK
- Python 3 dengan versi yang kompatibel dengan dependency backend
- Android SDK atau Google Chrome
- Model embedding dan FAISS index RacikAI
- Metadata resep
- Direktori gambar resep
- Gemini API Key yang valid
- PostgreSQL jika ingin menggunakan mode sumber data PostgreSQL

### 1. Clone Repository

```bash
git clone https://github.com/EuphoriaBot/racikai-projects.git
cd racikai-projects
```

### 2. Instal Dependency Flutter

```bash
flutter pub get
flutter doctor
```

### 3. Siapkan Python Environment

Contoh menggunakan Windows PowerShell dari root proyek:

```powershell
python -m venv backend/.venv
.\backend\.venv\Scripts\Activate.ps1
python -m pip install -r backend/requirements.txt
```

### 4. Siapkan Model dan Dataset

Model dan dataset AI tidak disertakan langsung dalam repository karena ukuran file yang besar

Backend membutuhkan artefak seperti:

```text
AI_MODEL_DIR/
├── model/
│   ├── config.json
│   ├── tokenizer.json
│   ├── modules.json
│   └── model.safetensors
├── recipe_faiss.index
└── recipe_metadata.csv
```

Model embedding dan indeks FAISS harus kompatibel dengan metadata resep yang digunakan

### 5. Konfigurasi Backend

Buat file berikut:

```text
backend/.env
```

Contoh struktur konfigurasi untuk pengembangan lokal di Windows:

```dotenv
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
GEMINI_MODEL=YOUR_SUPPORTED_GEMINI_MODEL

AI_MODEL_DIR="D:\RacikAI\file ai\recovered-kaggle"
RECIPE_IMAGE_DIR="D:\RacikAI\file ai\recipes-images"

RECIPE_DATA_SOURCE=csv
```

Ganti seluruh contoh nilai dengan lokasi dan konfigurasi sebenarnya

Jika menggunakan PostgreSQL, ubah `RECIPE_DATA_SOURCE` menjadi `postgres` dan siapkan variabel lingkungan koneksi PostgreSQL seperti `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, dan `PGPASSWORD`

### 6. Jalankan Backend

Dari root proyek pada Windows PowerShell:

```powershell
.\backend\start-dev.ps1
```

Script ini membaca konfigurasi `.env`, memvalidasi akses Gemini, lalu menjalankan backend

Backend lokal secara default dapat diakses melalui:

```text
http://localhost:8000
```

Periksa statusnya:

```text
http://localhost:8000/health
```

Backend harus berhasil memuat model, FAISS index, dan metadata resep agar layanan AI siap digunakan

### 7. Jalankan Flutter Web

Buka terminal baru:

```bash
flutter run -d chrome --web-port 5000
```

Untuk menentukan alamat backend secara eksplisit:

```bash
flutter run -d chrome --web-port 5000 --dart-define=AI_BASE_URL=http://localhost:8000
```

### 8. Menjalankan di Android Emulator

Jika backend berjalan pada komputer yang sama, Android Emulator dapat mengakses host melalui alamat

```text
http://10.0.2.2:8000
```

Contoh:

```bash
flutter run --dart-define=AI_BASE_URL=http://10.0.2.2:8000
```

### 9. Menjalankan di HP Android Fisik

Gunakan URL backend yang dapat dijangkau oleh perangkat Android

Untuk pengembangan dalam jaringan lokal, alamat IP komputer dapat digunakan apabila server dan HP saling terhubung

Untuk distribusi APK ke perangkat lain, gunakan alamat backend yang dapat diakses secara publik melalui HTTPS

---

## 📱 Build APK Android

Untuk membuat APK release, jalankan:

```bash
flutter build apk --release --dart-define=AI_BASE_URL=https://YOUR-BACKEND-URL
```

Ganti `https://YOUR-BACKEND-URL` dengan alamat backend yang sebenarnya dan dapat diakses oleh HP pengguna

Nama aplikasi Android yang ditampilkan kepada pengguna adalah **RacikAI**

### Hal Penting untuk APK Release

- Jangan menggunakan `localhost` sebagai backend URL untuk APK yang dibagikan
- Jangan menggunakan alamat `10.0.2.2` pada HP fisik
- Pastikan layanan backend tetap aktif ketika aplikasi digunakan
- Pastikan endpoint katalog, AI Chat, dan gambar dapat diakses
- Simpan Gemini API Key hanya di backend

---

## 💾 Penyimpanan Lokal

RacikAI menggunakan SharedPreferences untuk menyimpan beberapa data di perangkat

| Data                                  | Penyimpanan       |
| ------------------------------------- | ----------------- |
| ID resep favorit                      | SharedPreferences |
| Informasi resep favorit yang disimpan | SharedPreferences |
| Rencana makan mingguan                | SharedPreferences |
| Riwayat ID rekomendasi AI             | SharedPreferences |

Riwayat rekomendasi AI dibatasi hingga 60 ID terbaru agar penyimpanan tetap terkendali

Katalog utama dan pemrosesan AI tetap membutuhkan koneksi ke backend

---

## 🧪 Pengujian

### Pemeriksaan Flutter

```bash
flutter analyze
```

### Pengujian Backend

Dari root proyek dengan Python environment backend yang telah aktif:

```bash
python -m pytest backend/test_app.py -q
```

### Pemeriksaan Sintaks Python

```bash
python -m py_compile backend/app.py
```

### Pemeriksaan Git

```bash
git diff --check
```

Pengujian pengembangan terakhir berhasil dijalankan dengan:

- Flutter analyzer tanpa masalah
- Delapan pengujian backend berhasil
- Pengujian endpoint AI dengan resep sebelumnya yang dikecualikan
- Pengujian rekomendasi alternatif dengan ID yang berbeda
- Pengujian aplikasi Flutter pada perangkat

Hasil pengujian dapat berubah ketika kode diperbarui

---

## 🔐 Keamanan dan Batasan

RacikAI menggunakan pemisahan antara frontend dan backend

Prinsip keamanan utama:

- **Gemini API Key hanya disimpan di backend**, bukan di dalam aplikasi Flutter atau APK
- File `.env` dan kredensial database tidak dimasukkan ke repository GitHub
- Komunikasi antara aplikasi Android dan backend publik menggunakan HTTPS
- Aplikasi tidak mengakses Gemini secara langsung; seluruh permintaan AI diproses melalui FastAPI
- File model embedding, FAISS index, dan dataset berukuran besar disimpan terpisah dari repository
- Backend melakukan validasi data resep dan gambar sebelum menampilkan hasil kepada pengguna

### Batasan Sistem

Meskipun fitur utama RacikAI sudah terintegrasi, terdapat beberapa batasan:

1. **Koneksi internet diperlukan** untuk mengakses katalog resep dan rekomendasi AI dari backend
2. **Backend harus aktif** agar layanan pencarian, gambar, dan AI Chat dapat digunakan
3. **Rekomendasi AI tidak selalu sempurna.** Kualitas hasil bergantung pada ketersediaan dan relevansi resep dalam dataset
4. **Smart Recipe Rotation** menghindari ID resep yang tersimpan dalam riwayat terbaru, tetapi tidak menjamin bahwa resep tidak akan pernah berulang
5. **Penyimpanan lokal** tidak otomatis tersinkronisasi ke perangkat lain
6. Jika kandidat resep relevan yang belum pernah direkomendasikan tidak mencukupi, AI dapat menghasilkan kurang dari tiga rekomendasi

---

## 🧪 Pengujian dan Validasi

RacikAI melalui pengujian frontend, backend, dan integrasi untuk memastikan fitur utama berjalan dengan baik

### 1. Flutter Static Analysis

Pemeriksaan dilakukan menggunakan:

```bash
flutter analyze
```

Hasil pengujian terakhir:

```text
No issues found!
```

### 2. Backend Testing

Pengujian backend menggunakan pytest:

```bash
python -m pytest backend/test_app.py -q
```

Hasil pengujian terakhir:

```text
8 passed, 1 warning
```

Peringatan berasal dari penggunaan API lama pada dependency Starlette/httpx dan tidak menyebabkan pengujian gagal

### 3. Python Syntax Validation

```bash
python -m py_compile backend/app.py
```

### 4. Pengujian Rekomendasi AI

Salah satu skenario pengujian adalah meminta rekomendasi resep menggunakan bahan yang sama secara berulang

**Pertanyaan pertama:**

> Masak apa dari telur?

Contoh hasil:

- Egg in the Middle
- Easy Egg Custard
- Hard-Boiled Eggs

**Pertanyaan kedua:**

> Masak apa lagi dari telur?

Contoh hasil:

- Avocado Egg-in-a-Hole
- Egg Foo Yung
- Eggs Caviar

Hasil pengujian:

```text
Jumlah resep berulang: 0
Jumlah rekomendasi kedua: 3
```

Pengujian ini menunjukkan bahwa backend dapat memberikan rekomendasi berbeda ketika menerima daftar ID resep yang telah ditampilkan

### 5. Pengujian APK Android

Pengujian aplikasi Android mencakup:

- Menjalankan APK release pada perangkat Android
- Memastikan navigasi utama berjalan
- Mengakses katalog dan detail resep
- Menampilkan gambar makanan dari backend
- Menggunakan AI Chat untuk meminta rekomendasi
- Meminta rekomendasi alternatif dari bahan yang sama
- Menutup dan membuka kembali aplikasi untuk memeriksa penyimpanan riwayat
- Menguji penyimpanan favorit dan rencana makan mingguan

---

## 📱 Distribusi Aplikasi

RacikAI dapat dibangun menjadi APK Android menggunakan Flutter

```bash
flutter build apk --release --dart-define=AI_BASE_URL=https://YOUR-BACKEND-URL
```

APK hasil build dapat ditemukan pada:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Untuk kebutuhan demonstrasi atau pameran, file APK dapat dibagikan melalui layanan penyimpanan berkas seperti Google Drive

Alamat backend pada APK harus dapat dijangkau dari perangkat pengguna

**Catatan:** Repository ini berisi source code aplikasi. APK release, file model AI, metadata dataset, dan gambar resep dapat didistribusikan secara terpisah

---

## 🔄 Pengembangan Selanjutnya

RacikAI masih dapat dikembangkan lebih lanjut melalui sejumlah peningkatan

Beberapa pengembangan yang memungkinkan:

- **Autentikasi pengguna:** Menambahkan sistem akun untuk menyimpan informasi pengguna
- **Cloud synchronization:** Menyinkronkan favorit dan rencana makan antarperangkat
- **Peningkatan pencarian semantik:** Mengoptimalkan retrieval untuk kombinasi bahan yang lebih kompleks
- **Rekomendasi personal:** Mempertimbangkan preferensi makanan pengguna
- **Deployment dan monitoring:** Mengembangkan pengelolaan backend agar lebih stabil untuk penggunaan dalam skala besar
- **Peningkatan kualitas dataset:** Menambahkan kurasi data, kategori, dan evaluasi relevansi resep

Fitur-fitur tersebut merupakan rencana atau kemungkinan pengembangan, bukan bagian dari fitur yang diklaim sudah tersedia pada versi saat ini

---

## 👨‍💻 Tim Pengembang

RacikAI dikembangkan oleh dua mahasiswa untuk memenuhi proyek mata kuliah **Pemrograman Piranti Bergerak**.

| Nama                      | NIM        | Fokus Pengembangan             |
| ------------------------- | ---------- | ------------------------------ |
| Dimas Firjatullah Islamay | 2409106057 | Flutter / Frontend Application |
| Richard Dante Gunawan     | 2409106061 | AI / RAG / Backend             |

Pengembangan dilakukan secara kolaboratif menggunakan Git dan GitHub untuk pengelolaan source code, integrasi fitur, serta pemeliharaan proyek

---

## 🔗 Repository

**GitHub:** https://github.com/EuphoriaBot/racikai-projects

Repository ini digunakan untuk dokumentasi dan pengembangan aplikasi RacikAI

---

## 📌 Kesimpulan

RacikAI menggabungkan katalog resep digital dan Artificial Intelligence untuk membantu pengguna menemukan inspirasi makanan dengan lebih mudah

Melalui integrasi **Flutter, FastAPI, E5 Sentence Transformers, FAISS, Gemini, dan penyimpanan lokal**, RacikAI dapat menyediakan pencarian resep, rekomendasi berbasis bahasa natural, koleksi favorit, serta perencanaan menu mingguan dalam satu aplikasi

Fitur **Smart Recipe Rotation** juga membantu pengguna menemukan alternatif masakan tanpa terus mendapatkan rekomendasi yang sama

RacikAI diharapkan dapat menjadi contoh penerapan teknologi mobile dan Retrieval-Augmented Generation untuk menyelesaikan permasalahan sehari-hari secara praktis

---
