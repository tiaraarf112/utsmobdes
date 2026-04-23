# 📚 Book Catalog App

Aplikasi Katalog Buku interaktif yang dibangun menggunakan **Flutter**. Proyek ini dikembangkan untuk memenuhi kriteria Ujian Tengah Semester (UTS) mata kuliah Pengembangan Aplikasi Mobile.

Aplikasi ini menyajikan koleksi buku internasional dan nasional secara dinamis dengan mengintegrasikan dua layanan public API, dilengkapi dengan sistem caching offline dan manajemen state berbasis blok untuk menghasilkan pengalaman pengguna (UX) yang sangat mulus.

---

## ✨ Fitur Utama

1. **Integrasi Dual API**
   - **Open Library API**: Menyediakan data buku-buku mancanegara berdasarkan kategori populer.
   - **Google Books API**: Menyuplai metadata kumpulan literatur berbahasa Indonesia (Novel, Sejarah, dsb).
   
2. **Sistem Caching Offline (Hive)**
   - Semua telusuran data akan disimpan otomatis secara lokal.
   - Apabila perangkat terputus dari jaringan, aplikasi akan secara cerdas memuat data terakhir dari memori fisik beserta menampilkan pesan *"Indikator Offline"*.
   
3. **Pencarian Cerdas Cepat (Real-time)**
   - Anda dapat menelusuri ragam judul atau penulis lintas API menggunakan kolom pencarian dan BLoC debounce.

4. **Koleksi Favorit Pribadi**
   - Menyimpan seluruh buku yang Anda sukai ke dalam direktori favorit (menggunakan `hive_flutter` cache permanen).

5. **Penanganan Error Visual yang Komprehensif (UX)**
   - **Shimmer Loading**: Mencegah tampilan blank selama memuat sumber daya dari API.
   - **Error Snackbar & Fallback**: Pesan interaktif saat peladen menolak koneksi.
   - **Empty States**: Panduan visual jika buku dengan kategori yang Anda cari tidak tersedia.

---

## 🏗️ Arsitektur Aplikasi

Proyek ini menggunakan adaptasi **Clean Architecture** ringan berbasis fitur agar modul terstruktur, terprediksi, dan mudah untuk proses `debug`:

```text
lib/
├── models/         # Struktur obyek Data (BookModel). Konversi Payload JSON.
├── services/       # Layer logika HTTP Request API (Google+OpenLibrary) dan I/O Hive.
├── blocs/          # State Management terpisah spesifik (Book, Search, Auth, Bookmark).
├── pages/          # Seluruh tampilan antarmuka UI utama aplikasi (Screen level).
├── widgets/        # Komponen UI independen dan reusable (Card, Shimmer, Error).
└── main.dart       # Entry Point & MultiBlocProvider Setup.
```

---

## 🛠️ Teknologi yang Digunakan

* **Flutter SDK**: `>=3.0.0`
* **State Management**: `flutter_bloc`
* **Network / Networking**: `http`
* **Basis Data Lokal / Cache**: `hive` & `hive_flutter`
* **Keamanan Kredensial**: `flutter_secure_storage`
* **Network Status**: `connectivity_plus`
* **Pemroses Gambar**: `cached_network_image`

---

## 🚀 Cara Menjalankan Proyek Secara Lokal

1. **Kloning Proyek atau Buka Folder Akses:**
   Pastikan Anda sudah berada di lokasi direktori `book_catalog`.
   
2. **Unduh Paket Dependensi:**
   Buka terminal di root proyek dan jalankan perintah:
   ```bash
   flutter pub get
   ```

3. **Verifikasi Perangkat yang Tersedia:**
   Cek apakah emulator Android/iOS Anda atau opsi Chrome (Web) telah siap dipakai:
   ```bash
   flutter devices
   ```

4. **Jalankan Aplikasi:**
   Ketik perintah berikut untuk menyalakan proyek di perangkat Anda:
   ```bash
   flutter run
   ```
   > **Catatan:** Terkadang dibutuhkan otorisasi USB Debugging jika diuji menggunakan SmartPhone fisik Android.

---
