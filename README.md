# 📚 MyStudyMate — Smart Academic Organizer App

> **MyStudyMate** adalah aplikasi mobile berbasis **Flutter** yang membantu mahasiswa mengatur kehidupan akademiknya dalam satu tempat.  
> Aplikasi ini menggabungkan fitur **pencatatan materi kuliah, manajemen jadwal, dan pengingat tugas** agar mahasiswa tetap produktif setiap hari.

---

## ✨ Fitur Utama

### 🗓️ 1. Manajemen Jadwal
- Tambah, ubah, dan hapus jadwal kuliah atau kegiatan.
- Tersedia pengingat otomatis sebelum kelas dimulai.
- Tampilan harian/mingguan dengan warna berbeda untuk tiap kegiatan.

### 📝 2. Catatan Materi
- Simpan dan kelola catatan kuliah atau topik belajar.
- Dapat dikategorikan berdasarkan judul, tanggal, atau mata kuliah.
- Mendukung format teks sederhana dan poin-poin.

### 🎯 3. Pencatatan Tugas & Target Belajar
- Tambah tugas atau target belajar dengan *deadline reminder*.
- Tandai sebagai “selesai” atau “belum”.
- Dapat digunakan untuk tugas kuliah, PR, atau milestone belajar mandiri.

### 📊 4. Dashboard Utama
- Menampilkan ringkasan semua hal penting:
  - Jadwal hari ini
  - Tugas mendekati deadline
  - Catatan terbaru
  - Progress belajar minggu ini

## ✨ Fitur Tambahan
 
### 📈 5. Nilai & Progress Akademik
- Catat nilai per mata pelajaran/mata kuliah dengan input manual.
- Menampilkan **grafik kotak naik-turun (bar chart)** untuk memantau progres akademik.
- Fitur **rata-rata otomatis (average)**:
  - Siswa → nilai rata-rata per pelajaran.
  - Mahasiswa → konversi ke **Indeks Prestasi (IP) per semester**.
- Dapat menampilkan tren performa dari waktu ke waktu secara visual.

---

## 🎯 Tujuan Proyek
Proyek **MyStudyMate** dikembangkan sebagai bagian dari **Project Based Learning (PBL)** semester 5 yang mengintegrasikan tiga mata kuliah:

| Mata Kuliah | Fokus Kontribusi |
|--------------|------------------|
| 📘 Manajemen Proyek | Perencanaan, timeline, dan dokumentasi proyek |
| 💻 Pemrograman Mobile | Implementasi aplikasi menggunakan Flutter |
| 🧪 PMPL (Pengujian & QA) | Pengujian fungsional, integrasi, dan metrik kualitas perangkat lunak |

---

## 👥 Tim Pengembang 
| Nama | Peran | Tanggung Jawab |
|------|--------|----------------|
| **Ahmad Yazid Ilham Zulfiqor** | UI/UX Designer & FrontEnd | Mendesain antarmuka aplikasi, mengimplementasikan tampilan Flutter, serta memastikan pengalaman pengguna yang konsisten dan menarik. |
| **Azaria Cindy Sahasika** | Database & Quality Assurance | Mengelola struktur dan relasi data di Firebase, memastikan integrasi berjalan lancar, serta melakukan pengujian fungsional dan dokumentasi hasil QA. |
| **Sabrina Rahmadini** | Project Manager & Database | Mengatur perencanaan proyek, pembagian tugas, serta membantu dalam perancangan dan pengelolaan database aplikasi. |
| **Satriya Viar Citta Purnama** | Backend & UI/UX Designer | Mengembangkan logika backend, integrasi Firebase Authentication dan Firestore, serta membantu desain visual antarmuka. |

---

## 🧪 Quality Assurance (PMPL)
| Level Pengujian | Tujuan | Tools |
|------------------|--------|-------|
| Unit Test | Menguji fungsi dan model | `flutter test` |
| Integration Test | Menguji CRUD Firestore & UI | `flutter drive` |
| UI/E2E Test | Menguji alur pengguna | Cypress |
| Metrics | Code Coverage, Fault Detection Rate | – |
