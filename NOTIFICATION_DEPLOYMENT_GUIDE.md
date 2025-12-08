# 🚀 Panduan Deploy Sistem Notifikasi MyStudyMate

## 📊 Status Saat Ini
Sistem notifikasi **berjalan LOKAL** dengan Laravel Scheduler yang memerlukan:
- `php artisan schedule:work` running terus menerus
- FCM service account file lokal
- Database connection aktif

## ✅ Langkah Deploy ke Production (Laravel Cloud)

### 1. **Setup Environment Variables di Laravel Cloud**

Masuk ke Laravel Cloud Dashboard → Environment → Tambahkan:

```env
# Database (Supabase)
DB_CONNECTION=pgsql
DB_HOST=aws-1-ap-southeast-1.pooler.supabase.com
DB_PORT=6543
DB_DATABASE=postgres
DB_USERNAME=postgres.jgeinhjimnsqkhkzojhd
DB_PASSWORD=Masganteng32

# atau gunakan DB_URL
DB_URL=postgresql://postgres.jgeinhjimnsqkhkzojhd:Masganteng32@aws-1-ap-southeast-1.pooler.supabase.com:6543/postgres

# Firebase (untuk FCM)
FIREBASE_PROJECT_ID=mystudymate-acfbe
FIREBASE_CREDENTIALS_PATH=/app/storage/app/firebase-credentials.json

# Cache & Session
CACHE_DRIVER=database
SESSION_DRIVER=database
QUEUE_CONNECTION=database
```

### 2. **Upload Firebase Service Account ke Laravel Cloud**

#### Option A: Via Laravel Cloud Dashboard
1. Buka Laravel Cloud Dashboard
2. Pilih project `laravelmystudymate-main-2ftdg6`
3. Masuk ke **Files** atau **Storage**
4. Upload file `mystudymate-acfbe-firebase-adminsdk-fbsvc-2c2e8800a0.json` ke folder `storage/app/`

#### Option B: Via Deployment Script
Tambahkan di `.laravel-cloud/deploy`:
```bash
# Copy Firebase credentials from environment variable
echo "$FIREBASE_CREDENTIALS_JSON" > storage/app/firebase-credentials.json
```

Lalu set environment variable `FIREBASE_CREDENTIALS_JSON` dengan isi file JSON.

### 3. **Aktifkan Scheduler di Laravel Cloud**

Laravel Cloud **otomatis menjalankan scheduler** setiap menit. Tidak perlu setup manual!

File `App/Console/Kernel.php` sudah dikonfigurasi:
```php
protected function schedule(Schedule $schedule): void
{
    // Check schedule reminders every minute
    $schedule->command('schedule:check-reminders')->everyMinute();
    
    // Check assignment reminders every hour
    $schedule->command('assignments:check-reminders')->hourly();
}
```

### 4. **Verifikasi Setup**

#### Test Connection ke Database
```bash
curl https://laravelmystudymate-main-2ftdg6.laravel.cloud/api/test
```

#### Test API Assignments (harus sukses jika DB connected)
```bash
curl https://laravelmystudymate-main-2ftdg6.laravel.cloud/api/assignments
```

#### Check Logs
Di Laravel Cloud Dashboard → **Logs** → Cari:
- `🔍 Checking for schedules that need reminders...`
- `FCM: Notification sent successfully`

### 5. **Run Migrations di Production**

```bash
# Di Laravel Cloud dashboard → Terminal
php artisan migrate --force

# Atau via Laravel Cloud CLI
laravel-cloud ssh
php artisan migrate
```

### 6. **Test Notifikasi**

1. **Buat Schedule dengan Reminder di App**
2. **Set reminder 5 menit ke depan**
3. **Tunggu dan cek apakah notifikasi masuk**

#### Manual Test via Artisan:
```bash
# Test command langsung
php artisan schedule:check-reminders

# Test dengan debug
php artisan schedule:debug-notifications
```

## 🔧 Update FCMService untuk Production

File sudah siap, tapi pastikan path service account benar:

```php
// App/Services/FCMService.php
public function __construct()
{
    $this->projectId = env('FIREBASE_PROJECT_ID', 'mystudymate-acfbe');
    $this->fcmUrl = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";
    
    // Support both local and production paths
    $this->serviceAccountPath = env(
        'FIREBASE_CREDENTIALS_PATH',
        storage_path('app/mystudymate-acfbe-firebase-adminsdk-fbsvc-2c2e8800a0.json')
    );
}
```

## 📱 Update Flutter App untuk Production

File `lib/config/api_constant.dart` sudah pointing ke production:
```dart
String get baseUrl {
  return 'https://laravelmystudymate-main-2ftdg6.laravel.cloud';
}
```

## 🎯 Checklist Deployment

### Pre-Deployment
- [x] Database Supabase sudah dikonfigurasi
- [ ] Firebase service account file ready
- [ ] Environment variables disiapkan
- [x] Code sudah di push ke Git

### During Deployment
- [ ] Set semua environment variables di Laravel Cloud
- [ ] Upload Firebase credentials ke storage/app/
- [ ] Run migrations di production
- [ ] Verify scheduler berjalan (check logs)

### Post-Deployment
- [ ] Test API endpoints (assignments, schedules)
- [ ] Create test schedule dengan reminder
- [ ] Verify FCM notification diterima di app
- [ ] Monitor logs untuk errors

## 🐛 Troubleshooting

### Notifikasi Tidak Masuk

**1. Check Scheduler Running**
```bash
# Di Laravel Cloud logs, harus ada:
🔍 Checking for schedules that need reminders...
```

**2. Check Database Connection**
```bash
curl https://laravelmystudymate-main-2ftdg6.laravel.cloud/api/assignments
# Harus return data, bukan "Connection refused"
```

**3. Check FCM Credentials**
```bash
# Di logs, jangan ada error:
FCM: Service account file not found
FCM: Failed to get access token
```

**4. Check User FCM Token**
```sql
-- Di Supabase SQL Editor
SELECT id, email, fcm_token FROM users WHERE fcm_token IS NOT NULL;
```

### Scheduler Tidak Jalan

Laravel Cloud **otomatis** menjalankan scheduler. Jika tidak jalan:
1. Check Laravel Cloud status
2. Check logs untuk error
3. Contact Laravel Cloud support

### Database Connection Error

```bash
# Verify credentials di .env
DB_HOST=aws-1-ap-southeast-1.pooler.supabase.com
DB_PORT=6543
DB_DATABASE=postgres
DB_USERNAME=postgres.jgeinhjimnsqkhkzojhd
DB_PASSWORD=Masganteng32
```

## 🔐 Security Notes

1. **JANGAN** commit Firebase credentials ke Git
2. **JANGAN** hardcode DB credentials di code
3. **GUNAKAN** environment variables untuk semua secrets
4. **ROTATE** credentials secara berkala

## 📊 Monitoring

### Laravel Cloud Dashboard
- **Logs**: Real-time application logs
- **Metrics**: CPU, Memory, Response time
- **Scheduler**: Task execution history

### Supabase Dashboard
- **Database**: Query monitoring
- **API**: Request logs
- **Auth**: User activity

### Firebase Console
- **Cloud Messaging**: Notification delivery stats
- **Analytics**: User engagement

## 🎓 Best Practices

1. **Test di Staging First**: Jangan langsung deploy ke production
2. **Backup Database**: Sebelum run migrations
3. **Monitor Logs**: Terutama 24 jam pertama setelah deploy
4. **Gradual Rollout**: Test dengan user terbatas dulu
5. **Have Rollback Plan**: Siapkan cara rollback jika ada masalah

## 📞 Support

- **Laravel Cloud**: https://cloud.laravel.com/support
- **Supabase**: https://supabase.com/support
- **Firebase**: https://firebase.google.com/support

---

**Last Updated**: December 7, 2025
**Version**: 1.0
**Status**: Production Ready ✅
