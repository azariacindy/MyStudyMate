# 📚 MyStudyMate — Smart Academic Organizer for Polinema JTI Students

> **MyStudyMate** adalah aplikasi mobile berbasis **Flutter** yang dikembangkan khusus untuk membantu mahasiswa **JTI Polinema** dalam mengatur kegiatan akademiknya secara efisien.  
> Aplikasi ini menghadirkan fitur-fitur seperti manajemen tugas, jadwal kuliah, catatan belajar, hingga pemantauan progres akademik dengan tampilan modern dan notifikasi cerdas.

---

## 🧭 Deskripsi Singkat
MyStudyMate dirancang untuk menjadi asisten belajar digital mahasiswa dengan berbagai fitur yang mendukung produktivitas dan konsistensi belajar.  
Selain fitur utama seperti **Dashboard, Tugas, Jadwal, Study Plan, dan Nilai**, aplikasi ini juga menyediakan mode **Pomodoro** dan fitur **Community** (opsional) untuk belajar bersama dalam komunitas resmi Polinema JTI seperti **WRI** dan **ITDEC**.

---

## ✨ Fitur Utama

### 🏠 1. Dashboard
- Menampilkan:
  - 🔥 *Streak* harian belajar
  - 📈 Progress belajar mingguan
  - 📅 Kalender mingguan (bukan bulanan) yang menampilkan jadwal & tugas secara real-time
  - 📱 Menu navigasi menuju fitur utama
- 🎖️ *Reward badge (opsional):* muncul jika pengguna berhasil mencapai target streak, misalnya streak 10 hari berturut-turut.

---

### 📝 2. Tugas (Assignment Manager)
- CRUD (Create, Read, Update, Delete) data tugas.
- Fitur pencarian tugas berdasarkan nama/keyword.
- Notifikasi otomatis pada:
  - H-3 sebelum deadline,
  - Hari-H (D-day),
  - H+3 setelah deadline (selama belum “mark as done”).
- Menampilkan *progress tugas mingguan* (dalam persen) di halaman tugas & dashboard.

---

### 🗓️ 3. Jadwal (Schedule Manager)
- Menambahkan jadwal kuliah atau kegiatan per hari.
- Pengingat otomatis **30 menit sebelum kelas dimulai**.
- Tugas yang memiliki deadline akan otomatis tampil pada kalender mingguan.
- CRUD jadwal + tampilan terintegrasi dengan dashboard.

---

### 🎯 4. Study Plan (Learning Goal Generator)
- Membantu pengguna mencapai *learning goals* dengan mengunggah materi belajar.
- Sistem akan menghasilkan soal latihan (*auto-generated quiz*) berdasarkan file yang diunggah.
- Dapat memantau tingkat pemahaman pengguna terhadap materi yang diunggah.

---

### ⏳ 5. Pomodoro Timer
- Meningkatkan fokus belajar menggunakan teknik **Pomodoro (25 menit fokus, 5 menit istirahat)**.
- Jika pengguna keluar dari aplikasi sebelum waktu habis:
  - Muncul *alert warning*.
  - “Streak api” (🔥) akan hilang jika keluar sebelum sesi selesai.

---

### 👥 6. Community (Optional)
- Fitur opsional untuk mahasiswa Polinema JTI.
- Secara default, tersedia dua komunitas resmi:
  - **WRI (Workshop & Riset Informatika)**
  - **ITDEC (Information Technology Development Community)**
- Pengguna dapat berdiskusi, berbagi materi, atau belajar bersama layaknya komunitas Facebook.

---

## 🧩 Teknologi yang Digunakan
| Komponen | Teknologi |
|-----------|------------|
| Framework | Flutter (Dart) |
| Database | Firebase Firestore |
| Authentication | Firebase Auth |
| State Management | Provider / Bloc |
| Notifikasi | flutter_local_notifications |
| Grafik Nilai | fl_chart / charts_flutter |
| Penyimpanan File | Firebase Storage |
| Version Control | Git & GitHub |

---

## 👥 Tim Pengembang

| Nama | Peran | Tanggung Jawab |
|------|--------|----------------|
| **Sabrina Rahmadini** | Project Manager & Database | Mengatur perencanaan proyek, pembagian tugas, serta membantu dalam perancangan dan pengelolaan database aplikasi. |
| **Ahmad Yazid Ilham Zulfiqor** | UI/UX Designer & FrontEnd | Mendesain antarmuka aplikasi dan mengimplementasikan tampilan Flutter sesuai rancangan UI/UX. |
| **Satriya Viar Citta Purnama** | Backend, API & UI/UX Designer | Mengembangkan logika backend, API Firebase, integrasi database, serta membantu desain UI. |
| **Azaria Cindy Sahasika** | Database & Quality Assurance | Menyusun struktur database, melakukan pengujian aplikasi, serta membuat laporan QA (PMPL). |

---

## 🧪 Quality Assurance (PMPL)
| Level Pengujian | Tujuan | Tools |
|------------------|--------|-------|
| Unit Test | Menguji fungsi dan model data | `flutter test` |
| Integration Test | Menguji CRUD Firebase & UI | `flutter drive` |
| UI/E2E Test | Menguji alur pengguna | Cypress / Appium |
| Metrics | Code Coverage, Fault Detection Rate | — |

---
