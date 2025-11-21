# 🔔 Assignment Notification Troubleshooting Guide

## ❌ Masalah: Notifikasi Tidak Keluar

### 🔍 Diagnosis

Jalankan script diagnosa:
```bash
php check_notification_status.php
```

### 3 Penyebab Utama:

#### 1. ⏰ **Waktu Belum Tepat**
**Masalah**: Command hanya kirim notifikasi di jam tertentu
- H-3 & D-Day: Hanya kirim jika jam **>= 08:00**
- H+3: Hanya kirim jika jam **>= 09:00**

**Status Saat Ini**:
- Command cek setiap jam (via scheduler)
- Tapi notifikasi baru terkirim setelah jam 08:00/09:00

**Solusi**:
- ✅ **Test tanpa tunggu**: Gunakan `force_send_notification.php`
- ✅ **Production**: Biarkan scheduler jalan otomatis

```bash
# Force send untuk testing (bypass time check)
php force_send_notification.php
```

#### 2. ❌ **User Tidak Punya FCM Token**
**Masalah**: Dari 9 users, hanya 1 yang punya FCM token

**Status**:
```
✅ User ID 1 (asdd): PUNYA TOKEN
❌ User ID 2 (asdf): NO TOKEN  ← Test assignments ada di sini
❌ User ID 3-10: NO TOKEN
```

**Kenapa User 2 Tidak Dapat Notif?**
Assignment test milik User ID 2, tapi user ini belum login di app/belum set FCM token!

**Solusi**:
```bash
# Option 1: Update assignment ke user yang punya token
php artisan tinker
>>> \App\Models\Assignment::whereIn('id', [5, 6, 7, 8])->update(['user_id' => 1]);

# Option 2: Set FCM token untuk user 2 (login dulu di app)
# FCM token otomatis di-set saat user login di Flutter app
```

#### 3. ✅ **Firebase Credentials (SUDAH OK)**
**Status**: ✅ File ada di `storage/app/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json`

---

## ✅ Test Results

### Manual Force Send Test:
```bash
php force_send_notification.php
```

**Result**:
```
✅ Notification sent successfully! (D-Day: wgmsgm)
✅ Notification sent successfully! (H-3: Test Assignment)
Total: 2 notifications sent
```

**Laravel Log**:
```
[2025-11-22 00:45:36] FCM: Notification sent successfully 
  {"title":"🔥 Assignment Due Today!","response":{"name":"projects/mystudymate-acfbe/messages/..."}}

[2025-11-22 00:45:38] FCM: Notification sent successfully 
  {"title":"⏰ Assignment Due in 3 Days!","response":{"name":"projects/mystudymate-acfbe/messages/..."}}
```

---

## 🔧 Cara Fix Notifikasi Tidak Keluar

### Fix 1: Update Test Assignments ke User yang Punya Token

```bash
php artisan tinker
```

```php
// Update assignment test ke user ID 1 (yang punya FCM token)
\App\Models\Assignment::whereIn('id', [5, 6, 7, 8])
    ->update(['user_id' => 1]);

// Verify
\App\Models\Assignment::where('user_id', 1)->count(); // Should increase
```

### Fix 2: Set FCM Token untuk User Lain

**Di Flutter App**:
1. Login dengan user lain (User ID 2, 3, dst)
2. FCM token otomatis di-save saat login
3. Cek dengan:

```bash
php artisan tinker
>>> $user = \App\Models\User::find(2);
>>> $user->fcm_token; // Should have value
```

### Fix 3: Test dengan Waktu yang Tepat

**Option A**: Tunggu sampai jam 08:00
```bash
# Scheduler akan otomatis jalankan
php artisan schedule:run
```

**Option B**: Force send tanpa tunggu (untuk testing)
```bash
php force_send_notification.php
```

---

## 📊 Monitoring Commands

### Check Status Lengkap:
```bash
php check_notification_status.php
```

Output akan menunjukkan:
- ✅/❌ FCM token per user
- 📋 Assignment yang perlu notifikasi (H-3, D-Day, H+3)
- ⏰ Waktu sekarang vs requirement
- 🔑 Firebase credentials status
- 📈 Summary siap kirim atau tidak

### Check Laravel Log:
```bash
# Windows
Get-Content storage\logs\laravel.log -Tail 50

# Linux/Mac
tail -f storage/logs/laravel.log
```

Look for:
- ✅ `FCM: Notification sent successfully`
- ❌ `FCM: Failed to send notification`
- ❌ `FCM: Token is empty`

### Check Scheduler:
```bash
# Run scheduler manually (test)
php artisan schedule:run

# List scheduled commands
php artisan schedule:list
```

---

## 🎯 Production Checklist

- [x] Command berfungsi (tested with force_send)
- [x] FCM credentials tersedia
- [x] Scheduler configured (hourly)
- [ ] **Cron job di server** (BELUM - untuk production)
- [ ] **Semua user punya FCM token** (baru 1/9)
- [x] Time check di command (08:00 & 09:00)
- [x] Prevent duplicate notif dengan `last_notification_type`

---

## 🚀 Next Steps

### Untuk Development:
1. ✅ Test dengan `force_send_notification.php` (SUDAH BERHASIL)
2. ⚠️ Update test assignments ke user 1: `user_id = 1`
3. ✅ Verify notif muncul di app

### Untuk Production:
1. Setup cron job di server:
   ```bash
   * * * * * cd /path/to/PBLMobile && php artisan schedule:run >> /dev/null 2>&1
   ```

2. Pastikan semua user login di app (auto set FCM token)

3. Monitor Laravel logs untuk error

---

## 📝 Summary

**Kenapa Notif Tidak Keluar Tadi?**
1. ⏰ Jam 00:44 (belum sampai 08:00)
2. ❌ Test assignments milik User ID 2 yang tidak punya FCM token
3. ✅ Firebase credentials OK

**Solusi**:
- ✅ Force send berhasil kirim notif ke User ID 1
- ✅ FCM service working properly
- ⏭️ Tinggal update user_id atau tunggu jam 08:00

**Next**: User perlu login di Flutter app untuk set FCM token!
