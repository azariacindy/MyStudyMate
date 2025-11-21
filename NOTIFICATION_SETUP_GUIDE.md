# 📱 Panduan Setup Notifikasi Schedule - MyStudyMate

## ⚠️ PENTING: File yang TIDAK Di-commit ke GitHub

File berikut **HARUS** ada di server/local tapi **JANGAN** di-commit:

### 1. Firebase Service Account JSON
**Lokasi:** `PBLMobile/storage/app/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json`

**Cara Dapatkan:**
- Minta file ini dari admin project (Satriya/Cindy)
- Atau download dari Firebase Console → Project Settings → Service Accounts → Generate New Private Key

### 2. File `.env`
**Lokasi:** `PBLMobile/.env`

**Pastikan Ada:**
```env
APP_TIMEZONE=Asia/Jakarta
```

---

## 🚀 Langkah Setup (Setelah Git Pull)

### A. Setup Backend Laravel

```powershell
# 1. Masuk ke folder PBLMobile
cd D:\Flutter_Project\MyStudyMate\PBLMobile

# 2. Install dependencies (jika belum)
composer install

# 3. Pastikan Firebase service account JSON ada
# Cek file: storage/app/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json

# 4. Run migration (jika ada perubahan)
php artisan migrate

# 5. Clear cache
php artisan config:clear
php artisan cache:clear

# 6. PENTING: Jalankan scheduler (biarkan running)
php artisan schedule:work
# ATAU jika ingin test manual setiap menit:
php artisan schedule:check-reminders

# 7. Start Laravel server (terminal terpisah)
php artisan serve --host=0.0.0.0 --port=8000
```

---

### B. Setup Flutter App

```powershell
# 1. Masuk ke folder MYSTUDYMATE
cd D:\Flutter_Project\MyStudyMate\MYSTUDYMATE

# 2. Clean build
flutter clean
flutter pub get

# 3. Run app
flutter run
```

---

## 🔐 Langkah Login User (WAJIB untuk Notifikasi)

1. **Buka aplikasi** MyStudyMate
2. **Allow notification permission** saat diminta
3. **Login** dengan akun Anda
   - Saat login, FCM token otomatis tersimpan ke backend
4. **Buat schedule baru** dengan reminder 5-10 menit untuk test

---

## ✅ Cara Verifikasi Setup Berhasil

### 1. Cek FCM Token Tersimpan
```powershell
cd D:\Flutter_Project\MyStudyMate\PBLMobile
php artisan user:check-tokens
```

**Output yang Benar:**
```
✅ Users WITH FCM token (1):
  - ID: X, Name: Nama Anda, Email: email@gmail.com
```

Jika **TIDAK** muncul di list "Users WITH FCM token":
```powershell
# Logout dari app, lalu login lagi
# Atau clear token dan login ulang:
php artisan fcm:clear {user_id}
```

### 2. Test Kirim Notifikasi Manual
```powershell
php artisan notification:test {user_id}
```

Notifikasi harus muncul di device!

### 3. Test Schedule Reminder
```powershell
# Buat schedule dengan reminder 5 menit
# Tunggu sampai waktunya
# Atau cek manual:
php artisan schedule:check-reminders
```

---

## 🐛 Troubleshooting

### ❌ "No FCM token for user X"
**Solusi:**
1. Pastikan sudah login di app (bukan register doang)
2. Logout dan login lagi
3. Cek log Flutter saat login:
   ```
   [Auth] FCM token saved for user X
   ```

### ❌ Notifikasi Tidak Muncul Meski FCM Token Ada
**Cek:**
1. Scheduler berjalan? → `php artisan schedule:work`
2. Schedule sudah lewat waktu reminder? 
3. `notification_sent` masih `false`? 
   ```sql
   SELECT id, title, date, start_time, has_reminder, reminder_minutes, notification_sent 
   FROM schedules WHERE user_id = X;
   ```

### ❌ Error "Service account file not found"
**Solusi:**
```powershell
# Pastikan file ada di:
ls storage/app/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json

# Jika tidak ada, minta dari admin atau download dari Firebase Console
```

### ❌ Timezone Salah
**Cek:**
```powershell
php artisan tinker
>>> config('app.timezone')
# Harus return: "Asia/Jakarta"
```

**Fix:**
```env
# Di .env
APP_TIMEZONE=Asia/Jakarta
```
```powershell
php artisan config:clear
```

---

## 📊 Command Berguna

```powershell
# Cek siapa yang punya FCM token
php artisan user:check-tokens

# Clear FCM token user tertentu (untuk force re-login)
php artisan fcm:clear {user_id}

# Test kirim notifikasi ke user
php artisan notification:test {user_id}

# Manual check reminder (biasanya otomatis tiap menit)
php artisan schedule:check-reminders

# Cek Laravel logs
Get-Content storage/logs/laravel.log -Tail 50
```

---

## 📝 Cara Kerja Sistem

1. **User Login** → FCM token di-generate → Tersimpan ke database
2. **User Buat Schedule** dengan `has_reminder=true` dan `reminder_minutes` (5-60 menit)
3. **Scheduler Berjalan** setiap menit (`php artisan schedule:work`)
4. **CheckScheduleReminders** cek schedule yang perlu reminder:
   - `has_reminder = true`
   - `notification_sent = false`
   - Waktu sekarang >= (start_time - reminder_minutes)
5. **Kirim Notifikasi** via FCM API V1
6. **Set `notification_sent = true`** agar tidak kirim ulang

---

## 🎯 Fitur Notification

- ✅ Dynamic reminder time: 5, 10, 15, 30, 60 menit
- ✅ Auto-reset `notification_sent` saat edit schedule (waktu/tanggal berubah)
- ✅ Support multiple devices per user (FCM token per device)
- ✅ Timezone-aware (Asia/Jakarta)

---

## 👥 Kontak

Jika masih ada masalah, hubungi:
- **Satriya** - Backend Developer
- **Cindy/Azaria** - Team Lead

---

**Last Updated:** November 20, 2025
