# 🍳 RacikAI — AI Recipe Assistant

Aplikasi pencarian dan rekomendasi resep berbasis Flutter dengan integrasi Artificial Intelligence menggunakan pendekatan Retrieval-Augmented Generation (RAG)

## Tim Pengembang

| **Nama**                  | **NIM**    | **Peran**                      |
| ------------------------- | ---------- | ------------------------------ |
| Dimas Firjatullah Islamay | 2409106057 | Flutter / Frontend Application |
| Richard Dante Gunawan     | 2409106061 | AI / RAG / Backend             |

Mata kuliah **Pemrograman Piranti Bergerak**

---

## Tentang Aplikasi

**RacikAI** adalah aplikasi pencarian dan rekomendasi resep yang membantu pengguna menemukan makanan berdasarkan resep yang tersedia maupun bahan yang dimiliki

Aplikasi tidak hanya menyediakan katalog resep biasa, tetapi juga memiliki **AI Assistant** yang memungkinkan pengguna bertanya menggunakan bahasa natural seperti:

> "Saya punya ayam dan kecap, bisa masak apa?"

RacikAI kemudian mencari resep yang relevan dari dataset menggunakan sistem Retrieval-Augmented Generation (RAG), lalu AI menyusun jawaban yang lebih mudah dipahami dalam Bahasa Indonesia

RacikAI dikembangkan menggunakan Flutter untuk sisi aplikasi dan FastAPI untuk backend. Sistem AI menggunakan Sentence Transformer sebagai model embedding, FAISS untuk pencarian vector, dan Gemini sebagai Large Language Model untuk menghasilkan jawaban

Dataset yang digunakan berisi sekitar **13 ribu resep** lengkap dengan judul, bahan, langkah memasak, dan metadata gambar

---

## Masalah yang Diselesaikan

RacikAI dikembangkan untuk membantu beberapa permasalahan yang umum dialami pengguna ketika mencari resep makanan:

1. Pengguna sering memiliki bahan makanan di rumah tetapi tidak mengetahui makanan apa yang dapat dibuat dari bahan tersebut
2. Pencarian resep secara manual membutuhkan waktu karena pengguna harus membuka dan membandingkan banyak resep
3. Banyak sumber resep menggunakan Bahasa Inggris sehingga kurang praktis bagi sebagian pengguna Indonesia
4. Pencarian berbasis kata kunci biasa belum dapat memahami kebutuhan pengguna dalam bentuk kalimat natural
5. Pengguna membutuhkan satu aplikasi yang dapat digunakan untuk menjelajahi resep, menyimpan resep, mendapatkan rekomendasi AI, dan merencanakan menu makanan

---

## Sasaran Pengguna

RacikAI ditujukan untuk pengguna yang membutuhkan bantuan dalam mencari ide masakan, terutama mahasiswa, anak kos, pengguna yang sedang belajar memasak, maupun pengguna yang ingin memanfaatkan bahan makanan yang tersedia di rumah

Aplikasi dirancang agar pengguna tetap dapat melakukan pencarian resep biasa tanpa AI, sedangkan AI Assistant digunakan ketika pengguna membutuhkan rekomendasi yang lebih fleksibel berdasarkan pertanyaan atau kondisi tertentu

---

# Fitur dan Status

Pengembangan RacikAI dilakukan secara bertahap. Beberapa fitur telah terintegrasi dengan backend dan dataset asli, sedangkan beberapa fitur lainnya masih berada dalam tahap pengembangan

## 1. Home

Home merupakan halaman utama aplikasi RacikAI yang menyediakan akses cepat ke berbagai fitur aplikasi

Fitur pada Home meliputi:

- Akses ke pencarian resep
- Akses ke pencarian berdasarkan bahan
- Kategori makanan
- AI Assistant
- Meal Planner
- Navigasi menuju fitur utama RacikAI

---

## 2. Recipe Search

Fitur Search memungkinkan pengguna mencari resep secara langsung dari dataset RacikAI

Pencarian dapat dilakukan berdasarkan:

- Nama resep
- Bahan makanan
- Kategori makanan

Kategori yang tersedia antara lain:

- Semua
- Ayam
- Daging
- Nasi
- Pasta
- Sayur
- Dessert

Search telah terhubung dengan backend FastAPI dan menggunakan resep asli dari dataset, bukan data dummy

RacikAI juga memiliki normalisasi sederhana untuk beberapa kata Bahasa Indonesia agar tetap dapat mencari dataset yang sebagian besar menggunakan Bahasa Inggris

Contoh:

```text
ayam          → chicken
kecap         → soy sauce
kecap manis   → sweet soy sauce
kentang       → potato
telur         → egg
keju          → cheese
nasi          → rice
sayur         → vegetable
```

Hasil pencarian menggunakan sistem pagination sehingga aplikasi tidak perlu memuat seluruh ribuan resep sekaligus

---

## 3. RacikAI Assistant

RacikAI Assistant merupakan fitur utama berbasis Artificial Intelligence

Pengguna dapat memberikan pertanyaan dalam Bahasa Indonesia seperti:

```text
Saya punya ayam dan kecap
```

atau:

```text
Saya ingin resep sederhana tanpa oven
```

RacikAI kemudian akan mencari beberapa resep yang paling relevan dari dataset dan menyusun jawaban berdasarkan resep tersebut

AI Assistant menggunakan pendekatan **Retrieval-Augmented Generation (RAG)** agar jawaban AI tetap menggunakan resep yang terdapat pada dataset sebagai sumber utama

---

## 4. Recipe Detail

Setiap resep dapat dibuka pada halaman detail

Informasi yang tersedia meliputi:

- Nama resep
- Jumlah bahan
- Daftar bahan
- Langkah memasak
- Informasi asal rekomendasi
- Area gambar resep

Halaman Recipe Detail digunakan oleh hasil Search maupun hasil rekomendasi AI

---

## 5. Saved / Favorite

Fitur Saved memungkinkan pengguna menyimpan resep yang disukai agar dapat dibuka kembali dengan lebih mudah

Versi awal sistem Favorite menggunakan data recipe lokal. Sistem ini sedang dikembangkan agar dapat menggunakan resep yang berasal langsung dari backend dan dataset asli

Untuk akun Free, konsep pembatasan yang digunakan adalah maksimal 10 resep favorit

---

## 6. Ingredient Finder

Ingredient Finder memungkinkan pengguna memilih bahan makanan yang sedang tersedia

Contoh bahan:

```text
Ayam
Daging sapi
Telur
Nasi
Pasta
Bawang putih
Bawang merah
Kecap
Kentang
Keju
Sayuran
```

Tujuan fitur ini adalah membantu pengguna menemukan resep berdasarkan kombinasi bahan yang dimiliki

---

## 7. Meal Planner

Meal Planner digunakan untuk membantu pengguna membuat rencana menu makanan

Data Meal Planner disimpan secara lokal sehingga perencanaan pengguna dapat tetap tersedia setelah aplikasi ditutup

Dalam konsep RacikAI, Meal Planner menjadi salah satu fitur yang dapat digunakan pada paket Premium

---

## 8. Sistem Free dan Premium

RacikAI memiliki konsep sistem berlangganan dengan dua jenis pengguna.

### Free

Pengguna Free memiliki beberapa batasan, seperti:

- Maksimal 5 pertanyaan AI per hari
- Maksimal 10 resep favorit

### Premium

Konsep Premium menyediakan:

- Penggunaan AI tanpa batas
- Akses Meal Planner
- Batas fitur yang lebih tinggi dibandingkan pengguna Free

> Sistem subscription saat ini masih berupa simulasi/prototype dan belum menggunakan sistem pembayaran Google Play secara nyata

---

## 9. Light Mode dan Dark Mode

RacikAI mendukung beberapa pilihan tampilan:

- Light Mode
- Dark Mode
- Mengikuti tema sistem perangkat

Pengaturan tema disimpan secara lokal agar pilihan pengguna tetap digunakan ketika aplikasi dibuka kembali

---

# Arsitektur Sistem

Secara umum RacikAI terdiri dari dua bagian utama:

```text
┌───────────────────────────────┐
│          Flutter App          │
│                               │
│ Home                          │
│ Search                        │
│ AI Assistant                  │
│ Saved                         │
│ Meal Planner                  │
│ Profile                       │
└──────────────┬────────────────┘
               │
               │ HTTP Request
               ▼
┌───────────────────────────────┐
│        FastAPI Backend        │
│                               │
│ Recipe Catalog API            │
│ RAG Retrieval                 │
│ Gemini Integration            │
└──────────────┬────────────────┘
               │
        ┌──────┴───────┐
        ▼              ▼
┌───────────────┐  ┌───────────────┐
│ Recipe Dataset│  │ Gemini API    │
│ + FAISS Index │  │               │
└───────────────┘  └───────────────┘
```

Flutter bertugas sebagai antarmuka pengguna, sedangkan FastAPI menangani katalog resep, pencarian data, proses RAG, serta komunikasi dengan Gemini

---

# Alur AI / Retrieval-Augmented Generation

RacikAI menggunakan pendekatan **Retrieval-Augmented Generation (RAG)**

Alur AI secara sederhana adalah sebagai berikut:

```text
Pertanyaan Pengguna
        │
        ▼
Gemini Query Rewriter
        │
        ▼
Query Retrieval
        │
        ▼
Sentence Transformer
        │
        ▼
Embedding Query
        │
        ▼
FAISS Vector Search
        │
        ▼
Top-K Recipe
        │
        ▼
Recipe Metadata
        │
        ▼
Gemini
        │
        ▼
Jawaban Bahasa Indonesia
        │
        ▼
Flutter Application
```

Sebagai contoh, pengguna memasukkan:

```text
Saya punya ayam dan kecap
```

Sebelum melakukan pencarian ke FAISS, query dapat ditulis ulang menjadi bentuk yang lebih sesuai dengan dataset:

```text
chicken soy sauce
```

Sentence Transformer kemudian mengubah query tersebut menjadi vector embedding

FAISS melakukan pencarian berdasarkan kemiripan vector dan mengambil beberapa resep yang paling relevan

Contoh resep yang dapat ditemukan:

```text
Soy Sauce Chicken
Spicy Asian Chicken Soup
Soy-Glazed Chicken with Broccoli
```

Resep hasil retrieval selanjutnya diberikan kepada Gemini sebagai context

Gemini kemudian menyusun jawaban dalam Bahasa Indonesia berdasarkan resep yang ditemukan

Dengan metode ini, Gemini tidak hanya menghasilkan jawaban berdasarkan pengetahuan umum, tetapi diarahkan menggunakan resep yang terdapat pada dataset RacikAI sebagai sumber utama

---

# Alur Recipe Search

Fitur Search biasa dipisahkan dari fitur AI

Search tidak menggunakan Gemini dan tidak mengurangi batas penggunaan AI harian

Alurnya adalah:

```text
Pengguna
   │
   ▼
Flutter Search Screen
   │
   ▼
GET /recipes
   │
   ▼
FastAPI
   │
   ▼
recipe_metadata.csv
   │
   ▼
Search / Category Filter
   │
   ▼
Pagination
   │
   ▼
Recipe Grid
   │
   ▼
Recipe Detail
```

Dengan pemisahan ini, pencarian resep biasa tetap ringan, sedangkan AI digunakan ketika pengguna membutuhkan rekomendasi berbasis bahasa natural

---

# Dataset

RacikAI menggunakan dataset resep dari Kaggle:

**Food Ingredients and Recipes Dataset with Images**

Dataset berisi informasi resep seperti:

```text
Title
Ingredients
Instructions
Image_Name
Cleaned_Ingredients
```

Setelah melalui proses preprocessing untuk kebutuhan RAG, metadata yang digunakan backend antara lain:

```text
recipe_id
Title
Image_Name
ingredient_text
Instructions
rag_document
retrieval_document
```

Pada pengujian backend saat ini, katalog RacikAI dapat membaca sekitar **13 ribu resep** dari metadata hasil preprocessing

Data tersebut digunakan oleh:

- Recipe Search
- AI retrieval
- Recommendation source
- Recipe Detail

File gambar resep belum dimasukkan langsung ke repository karena ukuran dataset yang cukup besar. Sistem telah dipersiapkan agar gambar nantinya dapat dilayani melalui backend.

---

# Teknologi

RacikAI dibangun menggunakan teknologi berikut:

| **Bagian**               | **Teknologi**         | **Keterangan**                         |
| ------------------------ | --------------------- | -------------------------------------- |
| Frontend                 | Flutter               | Framework utama aplikasi               |
| Bahasa Frontend          | Dart                  | Bahasa pemrograman Flutter             |
| Backend                  | FastAPI               | REST API RacikAI                       |
| Bahasa Backend           | Python                | Backend dan AI                         |
| State Management         | Flutter BLoC / Cubit  | Pengelolaan state aplikasi             |
| Dependency Injection     | get_it                | Service locator                        |
| Routing                  | go_router             | Navigasi halaman                       |
| HTTP Client              | http                  | Komunikasi Flutter dengan backend      |
| Vector Database / Search | FAISS                 | Pencarian vector resep                 |
| Embedding                | Sentence Transformers | Mengubah query menjadi embedding       |
| AI Architecture          | RAG                   | Retrieval-Augmented Generation         |
| LLM                      | Gemini                | Query rewriting dan penyusunan jawaban |
| Gemini API               | Interactions API      | Komunikasi backend dengan Gemini       |
| Dataset                  | Kaggle Recipe Dataset | Sumber data resep                      |
| Local Storage            | Local Storage         | Preferensi dan data lokal aplikasi     |
| Version Control          | Git dan GitHub        | Kolaborasi dan version control         |

---

# Backend API

Backend RacikAI menggunakan FastAPI

Endpoint utama yang tersedia adalah sebagai berikut

## Health Check

```http
GET /health
```

Digunakan untuk mengecek apakah backend, model embedding, FAISS index, dan konfigurasi generation berhasil dimuat

---

## Recipe Catalog

```http
GET /recipes
```

Digunakan oleh halaman Search.

Contoh:

```text
/recipes?page=1&limit=24
/recipes?q=ayam
/recipes?q=kecap
/recipes?category=Pasta
```

Endpoint ini melakukan pencarian katalog tanpa menggunakan Gemini

Response berisi informasi seperti:

```json
{
  "recipes": [
    {
      "id": "2261",
      "title": "Soy Sauce Chicken",
      "ingredients": "...",
      "instructions": "...",
      "image_name": "soy-sauce-chicken",
      "image_url": null,
      "ingredient_count": 10
    }
  ],
  "page": 1,
  "limit": 24,
  "total": 100,
  "has_more": true
}
```

---

## AI Chat

```http
POST /chat
```

Contoh request:

```json
{
  "message": "Saya punya ayam dan kecap",
  "top_k": 3
}
```

Proses pada endpoint ini:

```text
User Question
→ Query Rewrite
→ Sentence Transformer
→ FAISS Retrieval
→ Top-K Recipe
→ Gemini Generation
→ Response
```

---

# Cara Menjalankan Project

## Persyaratan

Project membutuhkan:

```text
Flutter SDK
Dart SDK
Python 3
Google Chrome / Android Emulator / Android Device
Model Sentence Transformer
FAISS Index
Recipe Metadata
Gemini API Key
```

---

## 1. Clone Repository

```bash
git clone https://github.com/EuphoriaBot/racikai-projects.git
```

Masuk ke folder project:

```bash
cd racikai-projects
```

---

## 2. Install Dependency Flutter

Jalankan:

```bash
flutter pub get
```

Periksa Flutter environment:

```bash
flutter doctor
```

---

## 3. Buat Python Virtual Environment

Masuk ke folder backend:

```bash
cd backend
```

Buat virtual environment:

```bash
python -m venv .venv
```

Aktifkan pada Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install dependency backend:

```bash
pip install -r requirements-api.txt
pip install -r requirements.txt
```

---

## 4. Siapkan Model RAG

File model dan dataset AI tidak disimpan langsung di GitHub karena ukurannya cukup besar

Backend membutuhkan beberapa artifact seperti:

```text
config.json
tokenizer.json
modules.json
model.safetensors
recipe_faiss.index
recipe_metadata.csv
```

Struktur umumnya:

```text
AI_MODEL_DIR/
│
├── model/
│   ├── config.json
│   ├── tokenizer.json
│   ├── modules.json
│   └── model.safetensors
│
├── recipe_faiss.index
└── recipe_metadata.csv
```

Lokasi model dapat diarahkan menggunakan environment variable:

```text
AI_MODEL_DIR
```

---

## 5. Siapkan Gemini API Key

AI Assistant membutuhkan Gemini API Key

API key harus disimpan sebagai environment variable:

```text
GEMINI_API_KEY
```

Model Gemini yang digunakan selama pengembangan:

```text
gemini-3.5-flash-lite
```

ID model juga dapat diatur menggunakan:

```text
GEMINI_MODEL
```

---

## 6. Jalankan Backend

Dari root project pada environment pengembangan yang sudah dikonfigurasi:

```powershell
.\backend\start-dev.ps1
```

Backend secara default berjalan pada:

```text
http://localhost:8000
```

Untuk mengecek backend:

```text
http://localhost:8000/health
```

Jika backend berhasil dijalankan, status akan menunjukkan bahwa model siap digunakan

---

## 7. Jalankan Flutter Web

Buka terminal baru dan jalankan:

```bash
flutter run -d chrome --web-port 5000
```

Flutter Web kemudian dapat berkomunikasi dengan backend pada:

```text
http://localhost:8000
```

---

## 8. Menjalankan pada Android Emulator

Pada Android Emulator, localhost komputer tidak dapat langsung diakses menggunakan `localhost`

RacikAI menggunakan alamat:

```text
http://10.0.2.2:8000
```

untuk mengakses backend dari Android Emulator

---

## 9. Menjalankan pada HP Android Fisik

Untuk HP fisik, gunakan alamat IP lokal komputer

Contoh:

```bash
flutter run --dart-define=AI_BASE_URL=http://192.168.1.10:8000
```

Alamat IP harus disesuaikan dengan IP komputer yang menjalankan backend

Komputer dan HP harus berada pada jaringan yang sama

---

# Penyimpanan Data

RacikAI menggunakan penyimpanan lokal untuk beberapa data aplikasi, seperti:

```text
Theme Preference
Subscription Prototype
AI Daily Usage
Meal Planner
Favorite / Saved Data
Profile Preference
```

Sementara itu, katalog resep dan data yang digunakan AI diperoleh melalui FastAPI backend

---

# Keamanan

Pada pengembangan RacikAI, credential AI tidak diletakkan di dalam aplikasi Flutter

Arsitektur yang digunakan:

```text
Flutter
   │
   ▼
FastAPI
   │
   ▼
Gemini API
```

Dengan desain ini:

- Gemini API Key hanya digunakan oleh backend
- API Key tidak dikirim ke aplikasi Flutter
- API Key tidak disimpan di repository
- File model berukuran besar tidak dimasukkan ke Git
- Flutter hanya menerima hasil yang telah diproses backend

---

# Pengujian

Sebelum perubahan kode dianggap selesai, project diperiksa menggunakan:

```bash
flutter analyze
```

Backend juga memiliki file pengujian untuk memastikan endpoint dan proses Gemini dapat berjalan dengan benar:

```text
backend/test_app.py
backend/test_generation.py
```

Contoh menjalankan test backend:

```powershell
cd backend
.\.venv\Scripts\python.exe -m unittest test_generation.py -v
```

---

# Version Control

Project RacikAI menggunakan Git dan GitHub sebagai version control

Repository:

```text
https://github.com/EuphoriaBot/racikai-projects
```

Pengembangan dilakukan secara bertahap menggunakan commit agar setiap perubahan fitur dapat dilacak

Beberapa bagian pengembangan utama meliputi:

```text
Flutter UI
Recipe Architecture
AI Backend Integration
Gemini Integration
Query Rewrite
AI Recommendation UI
Backend Recipe Catalog
Real Dataset Search
```
