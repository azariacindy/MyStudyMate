# ⚡ Quick Deployment Checklist - Notifikasi MyStudyMate

## 🎯 Ringkasan Masalah
**Status**: Notifikasi berjalan LOKAL (memerlukan `php artisan schedule:work`)
**Solusi**: Deploy ke Laravel Cloud dengan auto-scheduler

---

## ✅ Langkah Deploy (5 Menit)

### 1️⃣ Set Environment di Laravel Cloud Dashboard

```env
FIREBASE_PROJECT_ID=mystudymate-acfbe
FIREBASE_CREDENTIALS_PATH=/app/storage/app/firebase-credentials.json

DB_URL=postgresql://postgres.jgeinhjimnsqkhkzojhd:Masganteng32@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres
CACHE_DRIVER=database
QUEUE_CONNECTION=database
```

### 2️⃣ Upload Firebase Credentials

**File**: `mystudymate-acfbe-firebase-adminsdk-fbsvc-2c2e8800a0.json`
**Location**: `storage/app/` di Laravel Cloud

**Cara Upload**:
- Laravel Cloud Dashboard → Files → Upload ke `storage/app/`
- Atau via environment variable `FIREBASE_CREDENTIALS_JSON`

### 3️⃣ Deploy & Migrate

```bash
# Push code ke Git (Laravel Cloud auto-deploy)
git push origin add-streak-cindy

# Run migration di Laravel Cloud terminal
php artisan migrate --force
```

### 4️⃣ Verify

```bash
# Test API
curl https://laravelmystudymate-main-2ftdg6.laravel.cloud/api/test

# Check scheduler logs di Laravel Cloud Dashboard
# Harus muncul: "🔍 Checking for schedules..."
```

---

## 🔥 Perbedaan Local vs Production

| Aspek | Local (Sekarang) | Production (Laravel Cloud) |
|-------|------------------|----------------------------|
| **Scheduler** | Manual (`schedule:work`) | ✅ Otomatis setiap menit |
| **Database** | Local MySQL | ✅ Supabase PostgreSQL |
| **FCM File** | `storage/app/` lokal | ✅ Env var / storage cloud |
| **Cron** | Tidak jalan Windows | ✅ Built-in Laravel Cloud |
| **Uptime** | Harus selalu run | ✅ 24/7 automatic |

---

## 🚨 Jika Ada Masalah

### Error: "Connection refused" (Database)
```bash
# Set DB credentials di Laravel Cloud environment
DB_URL=postgresql://postgres.jgeinhjimnsqkhkzojhd:Masganteng32@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres
```

### Error: "Service account file not found"
```bash
# Upload firebase JSON ke storage/app/
# Set: FIREBASE_CREDENTIALS_PATH=/app/storage/app/firebase-credentials.json
```

### Scheduler tidak jalan
```bash
# Check di Laravel Cloud Logs
# Harus muncul log setiap menit
```

---

## 📱 Flutter App - Sudah Siap Production

File `api_constant.dart` sudah pointing ke production URL:
```dart
return 'https://laravelmystudymate-main-2ftdg6.laravel.cloud';
```

✅ **Tidak perlu ubah apa-apa di Flutter**

---

## ✨ After Deploy

1. ✅ Buat schedule baru di app dengan reminder 5 menit
2. ✅ Tunggu 5 menit
3. ✅ Notifikasi harus masuk ke device

**Done!** 🎉

---

**Note**: Laravel Cloud **automatically** runs scheduler every minute. Tidak perlu setup cron atau `schedule:work` manual!
