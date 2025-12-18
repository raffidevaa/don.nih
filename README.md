# ☕ Kedai Don.Nih!

Aplikasi **Kedai Don.Nih!** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mendigitalisasi proses pemesanan pada kedai kopi. Aplikasi ini menghubungkan **pelanggan** dan **admin** dalam satu ekosistem terintegrasi untuk pemesanan, pengelolaan menu, dan pemantauan pesanan secara real-time.

---

## 📌 Deskripsi Proyek

Kedai Don.Nih! hadir sebagai solusi atas permasalahan pemesanan manual di kedai kopi, seperti antrean panjang, kesalahan pencatatan, dan kurangnya transparansi status pesanan.

### Fitur Utama:

* Autentikasi pengguna (Login & Register)
* Eksplorasi menu berdasarkan kategori
* Detail menu & kustomisasi topping
* Favorit (Wishlist)
* Keranjang & checkout
* Status dan riwayat pesanan real-time
* Manajemen profil & upload avatar
* Dashboard admin (CRUD menu & update status pesanan)

### Tech Stack:

* **Frontend**: Flutter (Dart)
* **Backend**: Supabase (PostgreSQL, Auth, Storage)
* **Arsitektur**: Clean Architecture (disederhanakan)

---

## Cara Instalasi

### 1️⃣ Prasyarat

Pastikan sudah terinstal:

* Flutter SDK (stable)
* Android Studio / VS Code
* Emulator Android atau perangkat fisik
* Akun Supabase

### 2️⃣ Clone Repository

```bash
git clone 
cd kedai-don-nih
```

### 3️⃣ Install Dependency

```bash
flutter pub get
```

### 4️⃣ Konfigurasi Supabase

Buat project di Supabase lalu siapkan:

* **SUPABASE_URL**
* **SUPABASE_ANON_KEY**

Simpan konfigurasi tersebut pada file konstanta (misalnya di `core/constants`).

---

## ▶️ Cara Menjalankan Aplikasi

1. Pastikan emulator atau device sudah aktif
2. Jalankan perintah berikut:

```bash
flutter run
```

3. Aplikasi akan otomatis ter-build dan dijalankan di perangkat

💡 *Login sebagai admin atau user akan menampilkan halaman yang berbeda sesuai role.*

---

## 📁 Struktur Folder

Struktur proyek dirancang berdasarkan prinsip **Clean Architecture** agar kode lebih rapi, terstruktur, dan mudah dikembangkan.

```text
lib/
├── presentation/
│   ├── pages/        # Halaman utama aplikasi (UI)
│   └── widgets/      # Komponen UI reusable
│
├── domain/
│   └── entities/     # Entity inti (pure Dart)
│
├── data/
│   ├── datasources/  # Akses langsung ke Supabase
│   └── models/       # Model & parsing JSON
│
└── core/
    └── constants/    # Konstanta global & konfigurasi
```

### Penjelasan Singkat:

* **presentation** → fokus pada tampilan & interaksi pengguna
* **domain** → logika bisnis inti (tidak tergantung framework)
* **data** → pengolahan dan pengambilan data dari backend
* **core** → konfigurasi dan kebutuhan umum aplikasi

---

## 🚀 Penutup

Aplikasi **Kedai Don.Nih!** dikembangkan sebagai media pembelajaran sekaligus solusi digital untuk UMKM di bidang F&B. Dengan Flutter dan Supabase, aplikasi ini siap dikembangkan lebih lanjut dengan fitur seperti pembayaran online, notifikasi real-time, dan manajemen stok.

✨ Selamat mencoba dan semoga bermanfaat!
