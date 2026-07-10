# 🌱 Sproutly

**Sproutly** adalah aplikasi konsultasi dan edukasi perawatan tanaman yang menghubungkan pengguna dengan ahli botani (expert) secara langsung melalui fitur chat berbayar, dilengkapi dengan artikel edukasi seputar dunia tanaman.

Dibangun sebagai proyek Ujian Akhir Semester (UAS) mata kuliah **Pemrograman Mobile**, Program Studi Sistem Informasi, Universitas Airlangga.

---

## 📱 Tentang Aplikasi

Sproutly mempertemukan dua peran pengguna dalam satu ekosistem:

- **User** — pencinta tanaman yang butuh saran perawatan dari ahli, membaca artikel edukasi, dan memesan sesi konsultasi.
- **Expert** — ahli botani yang menyediakan jasa konsultasi berbayar, menulis artikel, dan mengatur jadwal ketersediaannya sendiri.

Aplikasi terdiri dari dua bagian:
| Bagian | Repo/Folder | Tech Stack |
|---|---|---|
| **Frontend (Mobile App)** | `sproutly-frontend` | Flutter |
| **Backend (REST API)** | `BeSproutly` | Laravel + MySQL, di-deploy di Railway |

---

## ✨ Fitur Utama

### 👤 Sisi User
- 🔍 Cari & filter ahli botani berdasarkan nama atau spesialisasi tanaman
- 💬 Konsultasi real-time via chat dengan ahli, lengkap dengan kirim foto/video untuk diagnosis
- 💳 Pembayaran sesi konsultasi (upload bukti transfer) & histori pembayaran
- ⭐ Beri rating & ulasan setelah sesi konsultasi selesai
- 📰 Baca artikel edukasi seputar perawatan tanaman, dengan filter kategori
- 🔖 Bookmark artikel favorit
- 🕒 Riwayat konsultasi & riwayat rating

### 🌿 Sisi Expert
- 🗓️ Atur jadwal ketersediaan mingguan — status **Online/Offline** dihitung otomatis dari jadwal aktif
- 💰 Atur biaya & durasi sesi konsultasi
- ✅ Verifikasi/tolak pembayaran dari user
- 💬 Layani sesi konsultasi chat, sesi otomatis berakhir sesuai durasi yang disepakati
- ✍️ Tulis & publikasikan artikel edukasi (mendukung gambar di tengah tulisan)
- 📊 Riwayat pemasukan & riwayat konsultasi
- 🏦 Atur metode pembayaran (rekening bank)

### 🔐 Umum
- Registrasi & login terpisah untuk User dan Expert
- Autentikasi berbasis token (Laravel Sanctum)
- Reset password
- Edit profil & foto profil

---

## 🛠️ Tech Stack

**Frontend**
- [Flutter](https://flutter.dev/) — cross-platform mobile framework
- [Provider](https://pub.dev/packages/provider) — state management
- [Dio](https://pub.dev/packages/dio) — HTTP client
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) — penyimpanan token yang aman
- [image_picker](https://pub.dev/packages/image_picker) & [file_picker](https://pub.dev/packages/file_picker) — upload gambar/dokumen
- [google_fonts](https://pub.dev/packages/google_fonts) — tipografi
- [pdf](https://pub.dev/packages/pdf) & [printing](https://pub.dev/packages/printing) — ekspor dokumen

**Backend**
- [Laravel](https://laravel.com/) — REST API
- [Laravel Sanctum](https://laravel.com/docs/sanctum) — autentikasi berbasis token
- MySQL — basis data
- [Railway](https://railway.app/) — hosting & deployment

---

## 📂 Struktur Folder (Frontend)

```
lib/
├── config/          # Konfigurasi aplikasi (base URL API, dll)
├── models/          # Model data (User, Article, Consultation, dll)
├── providers/        # State management (Provider/ChangeNotifier)
├── services/         # Layer komunikasi ke REST API
├── utils/             # Helper & konverter data
├── widgets/          # Widget yang dipakai ulang di berbagai halaman
├── screens/
│   ├── auth/          # Login, register, splash, forgot password
│   ├── user/           # Semua halaman untuk role User
│   └── expert/         # Semua halaman untuk role Expert
└── main.dart
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi stabil terbaru)
- [PHP](https://www.php.net/) ≥ 8.1 & [Composer](https://getcomposer.org/) (untuk backend, jika ingin menjalankan lokal)
- MySQL

### Backend (Laravel)
```bash
git clone <url-repo-backend>
cd BeSproutly
composer install
cp .env.example .env
php artisan key:generate
# Sesuaikan konfigurasi database di .env
php artisan migrate --seed
php artisan storage:link
php artisan serve
```

### Frontend (Flutter)
```bash
git clone <url-repo-frontend>
cd sproutly-frontend
flutter pub get
```

Sesuaikan `baseUrl` di `lib/config/app_config.dart` agar mengarah ke backend yang ingin digunakan (lokal atau yang sudah di-deploy):
```dart
class AppConfig {
  static const String baseUrl = 'https://besproutly-production.up.railway.app/api';
}
```

Jalankan aplikasi:
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```
Hasil build tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

---

## 👥 Tim Pengembang

Dikembangkan oleh mahasiswa Sistem Informasi, Universitas Airlangga, sebagai proyek UAS mata kuliah Pemrograman Mobile.

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademik (tugas kuliah) dan bersifat non-komersial.