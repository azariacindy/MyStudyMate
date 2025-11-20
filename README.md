# 📚 MyStudyMate — Smart Academic Organizer for Polinema JTI Students

> **MyStudyMate** adalah aplikasi mobile berbasis **Flutter + Supabase** yang dikembangkan khusus untuk membantu mahasiswa **JTI Polinema** dalam mengatur kegiatan akademiknya secara efisien.  
> Aplikasi ini menghadirkan fitur seperti manajemen tugas, jadwal kuliah, catatan belajar, study cards, hingga pemantauan progres akademik dengan tampilan modern dan notifikasi cerdas.

---

## 🧭 Deskripsi Singkat
MyStudyMate dirancang untuk menjadi asisten belajar digital mahasiswa dengan berbagai fitur yang mendukung produktivitas, fokus, dan konsistensi belajar.  
Fitur utama meliputi **Dashboard, Tugas, Jadwal, Study Cards, Pomodoro, Notes, dan Profile**, serta tambahan **Reward Badges** untuk memotivasi pengguna menjaga streak belajar.

---

## ✨ Fitur Utama

---

### 🧑‍💻 0. Authentication & User Flow
#### **Splashscreen → Onboarding → Welcomescreen**
- Splashscreen menampilkan logo
- Onboarding menjelaskan fitur aplikasi
- Welcomescreen menuju Sign In / Sign Up

#### **Sign In**
- Login menggunakan username/email + password

#### **Sign Up**
Input data lengkap:
- Nama lengkap  
- Username  
- Email  
- Password  
- Confirm password  

---

### 👤 1. Profile
- Update foto profil  
- Edit nama, username, dan email  
- Change Password  
- Melihat seluruh badge reward yang didapat  

---

### 🏠 2. Dashboard
Menampilkan informasi utama:
- 🔥 Streak harian (bertambah saat user menyelesaikan tugas)
- 📈 Progress belajar mingguan  
- 📅 Kalender mingguan (scroll kiri/kanan) berisi jadwal & deadline tugas  
- 📱 Menu fitur:
  - Schedule  
  - Study Cards  
  - Pomodoro  
  - Notes  
- 🎖️ Reward Badges (opsional)

---

### 📝 3. Tugas (Assignment Manager)
- CRUD tugas  
- Pencarian tugas  
- Notifikasi otomatis:
  - H-3 sebelum deadline  
  - D-day  
  - H+3 setelah deadline (selama belum selesai)  
- Progress belajar mingguan (dalam persen)
- Mark as done:
  - Streak +1  
  - Progress meningkat  

**Input tugas:**
- Assignment Name  
- Subject (mata kuliah)  
- Deadline  
- Notes  

---

### 🗓️ 4. Jadwal (Schedule Manager)
- CRUD jadwal harian/kuliah  
- Notifikasi otomatis **30 menit sebelum kelas**  
- Jadwal muncul di kalender dashboard  

**Input jadwal:**
- Activity name  
- Date (auto dari kalender)  
- Time  
- Description  

---

### 🧠 5. Study Cards (Generate Quiz)
- User memasukkan materi text  
- Sistem menghasilkan quiz secara otomatis  
- User bisa mengerjakan quiz langsung  

**Input Study Cards:**
- Title  
- Notes  

---

### ⏳ 6. Pomodoro Timer
- Timer fokus belajar (25 menit fokus, 5 menit istirahat)
- Jika user keluar aplikasi sebelum timer selesai:
  - Muncul alert  
  - Streak tidak bertambah  
- Jika selesai:
  - Streak +1  

---

### 📒 7. Notes (Optional)
Fitur untuk mencatat/merangkum materi:
- CRUD Notes  
- Input:  
  - Title  
  - Description  

---

## 🧩 Teknologi yang Digunakan
| Komponen | Teknologi |
|-----------|------------|
| Framework | Flutter (Dart) |
| Backend | Supabase (PostgreSQL, Auth, Storage, Realtime) |
| Authentication | Supabase Auth |
| State Management | Provider / Riverpod / Bloc |
| Notifikasi | flutter_local_notifications |
| Penyimpanan File | Supabase Storage |
| Version Control | Git & GitHub |

---

## 👥 Tim Pengembang

| Nama | Peran | Tanggung Jawab |
|------|--------|----------------|
| **Sabrina Rahmadini** | Project Manager & Database | Mengatur perencanaan, timeline, serta perancangan database. |
| **Ahmad Yazid Ilham Zulfiqor** | UI/UX Designer & FrontEnd | Mendesain UI dan mengimplementasikan tampilan Flutter. |
| **Satriya Viar Citta Purnama** | Backend, API & UI/UX Designer | Mengelola Supabase (DB, Auth, Storage), API, dan membantu UI. |
| **Azaria Cindy Sahasika** | Database & Quality Assurance | Mendesain database, melakukan pengujian, serta dokumentasi QA PMPL. |

---

## 🧪 Quality Assurance (PMPL)

| Level Pengujian | Tujuan | Tools |
|------------------|--------|-------|
| Unit Test | Validasi logika kecil, validator, model | `flutter test` |
| Integration Test | CRUD Supabase + UI | `flutter drive` |
| UI/E2E Test | Flow pengguna | Appium / custom driver |
| Metrics | Code Coverage, Fault Detection Rate | — |

---

## 🎨 UI Design (Preview From Figma)

Berikut adalah beberapa tampilan UI yang telah diimplementasikan ke dalam project:

### 🟦 Splash Screen
![Splash Screen](assets/ui_design/vector/SplasScreen.png)

### 🟦 Welcome Screen
![Welcome Screen](assets/ui_design/vector/Welcome Screen.png)

### 🟦 Sign In Screen
![Sign In Screen](assets/ui_design/vector/SignIn Screen.png)

### 🟦 Onboarding Screens
![Onboarding 1](assets/ui_design/vector/Onboarding.png)
![Onboarding 2](assets/ui_design/vector/Onboarding 2.png)
![Onboarding 3](assets/ui_design/vector/Onboarding 3.png)
![Onboarding 4](assets/ui_design/vector/Onboarding 4.png)
![Onboarding 5](assets/ui_design/vector/Onboarding 5.png)
