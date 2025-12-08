# 📱 Push Notification Setup - MyStudyMate

Dokumentasi lengkap setup Firebase Cloud Messaging (FCM) untuk notifikasi pengingat jadwal 30 menit sebelum kelas dimulai (seperti Gojek).

---

## 📋 Daftar Isi

1. [Arsitektur Sistem](#arsitektur-sistem)
2. [Prerequisites](#prerequisites)
3. [Setup Backend (Laravel)](#setup-backend-laravel)
4. [Setup Frontend (Flutter)](#setup-frontend-flutter)
5. [Testing](#testing)
6. [Production Deployment](#production-deployment)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Arsitektur Sistem

```
User membuat jadwal → FCM Token tersimpan di database
                              ↓
Laravel Scheduler (setiap 1 menit) → Cek jadwal yang perlu reminder
                              ↓
30 menit sebelum kelas → Kirim push notification via FCM API V1
                              ↓
Device menerima notifikasi → Mark notification_sent = true
```

**Key Points:**
- ✅ Notifikasi **hanya dikirim 1 kali** per jadwal
- ✅ Menggunakan **FCM API V1** (bukan Legacy API yang deprecated)
- ✅ Timezone: **Asia/Jakarta** (WIB)
- ✅ Reminder: **30 menit** sebelum jadwal dimulai

---

## 📦 Prerequisites

### Backend Requirements:
- PHP >= 8.1
- Laravel 10.x
- PostgreSQL
- Composer
- Google Auth Library: `composer require google/auth`

### Frontend Requirements:
- Flutter >= 3.35.2
- Firebase Core: `^3.15.2`
- Firebase Messaging: `^15.2.10`
- flutter_local_notifications: `^18.0.1`

### Firebase Setup:
1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Add Android app dengan package name: `com.example.my_study_mate`
3. Download `google-services.json` → `android/app/`
4. Download Service Account Key → `storage/app/firebase/`

---

## 🔧 Setup Backend (Laravel)

### 1. Install Dependencies

```bash
composer require google/auth
```

### 2. Database Migrations

**Migration 1: Add FCM Token & Notification Sent**
```bash
php artisan make:migration add_fcm_token_to_users_and_notification_sent_to_schedules
```

```php
// database/migrations/2025_11_19_155447_add_fcm_token_to_users_and_notification_sent_to_schedules.php

Schema::table('users', function (Blueprint $table) {
    $table->text('fcm_token')->nullable()->after('password');
});

Schema::table('schedules', function (Blueprint $table) {
    $table->boolean('notification_sent')->default(false);
});
```

**Migration 2: Add Reminder Column**
```bash
php artisan tinker --execute="DB::statement('ALTER TABLE schedules ADD COLUMN IF NOT EXISTS reminder BOOLEAN DEFAULT TRUE');"
```

### 3. Update Schedule Model

**File:** `app/Models/Schedule.php`

```php
protected $fillable = [
    'user_id',
    'title',
    'description',
    'date',
    'start_time',
    'end_time',
    'location',
    'lecturer',
    'color',
    'type',
    'has_reminder',
    'reminder_minutes',
    'is_completed',
    'reminder',              // ← ADD
    'notification_sent',     // ← ADD
];

protected $casts = [
    'date' => 'date',
    'has_reminder' => 'boolean',
    'is_completed' => 'boolean',
    'reminder_minutes' => 'integer',
    'reminder' => 'boolean',             // ← ADD
    'notification_sent' => 'boolean',    // ← ADD
];
```

### 4. FCM Service

**File:** `app/Services/FCMService.php`

```php
<?php

namespace App\Services;

use Google\Auth\Credentials\ServiceAccountCredentials;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FCMService
{
    private $projectId;
    private $serviceAccountPath;

    public function __construct()
    {
        $this->projectId = 'mystudymate-acfbe';
        $this->serviceAccountPath = storage_path('app/firebase/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json');
    }

    private function getAccessToken()
    {
        $credentials = new ServiceAccountCredentials(
            'https://www.googleapis.com/auth/firebase.messaging',
            $this->serviceAccountPath
        );

        $token = $credentials->fetchAuthToken();
        return $token['access_token'];
    }

    public function sendNotification($fcmToken, $title, $body, $data = [])
    {
        $accessToken = $this->getAccessToken();
        $url = "https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send";

        $message = [
            'message' => [
                'token' => $fcmToken,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
                'android' => [
                    'priority' => 'high',
                ],
            ],
        ];

        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post($url, $message);

            if ($response->successful()) {
                Log::info('FCM notification sent successfully', ['response' => $response->json()]);
                return true;
            } else {
                Log::error('FCM notification failed', [
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
                return false;
            }
        } catch (\Exception $e) {
            Log::error('FCM notification exception', ['error' => $e->getMessage()]);
            return false;
        }
    }
}
```

### 5. Check Schedule Reminders Command

**File:** `app/Console/Commands/CheckScheduleReminders.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Schedule;
use App\Services\FCMService;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CheckScheduleReminders extends Command
{
    protected $signature = 'schedule:check-reminders';
    protected $description = 'Check for schedules that need reminder notifications';
    protected $fcmService;

    public function __construct(FCMService $fcmService)
    {
        parent::__construct();
        $this->fcmService = $fcmService;
    }

    public function handle()
    {
        $this->info('🔍 Checking for schedules that need reminders...');
        $now = Carbon::now();

        $schedules = Schedule::where('reminder', true)
            ->where('notification_sent', false)
            ->where('date', '>=', $now->toDateString())
            ->get()
            ->filter(function ($schedule) use ($now) {
                $dateString = Carbon::parse($schedule->date)->format('Y-m-d');
                $timeString = Carbon::parse($schedule->start_time)->format('H:i:s');
                $scheduleDateTime = Carbon::parse($dateString . ' ' . $timeString);
                $reminderTime = $scheduleDateTime->copy()->subMinutes(30);
                
                return $now->greaterThanOrEqualTo($reminderTime) && $now->lessThan($scheduleDateTime);
            });

        if ($schedules->isEmpty()) {
            $this->info('✅ No schedules need reminders at this time.');
            return Command::SUCCESS;
        }

        $this->info("📋 Found {$schedules->count()} schedule(s) to notify.");

        foreach ($schedules as $schedule) {
            $this->sendReminder($schedule);
        }

        $this->info('✅ Reminder check completed!');
        return Command::SUCCESS;
    }

    protected function sendReminder(Schedule $schedule)
    {
        $user = DB::table('users')->where('id', $schedule->user_id)->first();

        if (!$user || empty($user->fcm_token)) {
            $this->warn("⚠️ No FCM token for user {$schedule->user_id}");
            return;
        }

        $scheduleTime = Carbon::parse($schedule->start_time)->format('H:i');
        $title = '⏰ Kelas Akan Dimulai!';
        $body = "{$schedule->title} dimulai dalam 30 menit ({$scheduleTime})";
        
        if ($schedule->location) {
            $body .= "\n📍 {$schedule->location}";
        }

        $data = [
            'type' => 'schedule_reminder',
            'schedule_id' => (string) $schedule->id,
            'title' => $schedule->title,
            'start_time' => $schedule->start_time,
            'location' => $schedule->location ?? '',
        ];

        $sent = $this->fcmService->sendNotification(
            $user->fcm_token,
            $title,
            $body,
            $data
        );

        if ($sent) {
            $schedule->update(['notification_sent' => true]);
            $this->info("✅ Notification sent: {$schedule->title} for user {$user->name}");
        } else {
            $this->error("❌ Failed to send notification for: {$schedule->title}");
        }
    }
}
```

### 6. Register Scheduler

**File:** `app/Console/Kernel.php`

```php
protected function schedule(Schedule $schedule): void
{
    $schedule->command('schedule:check-reminders')->everyMinute();
}
```

### 7. API Route untuk Save FCM Token

**File:** `routes/api.php`

```php
Route::post('/save-fcm-token', [AuthController::class, 'saveFCMToken']);
```

**File:** `app/Http/Controllers/AuthController.php`

```php
public function saveFCMToken(Request $request)
{
    $request->validate([
        'user_id' => 'required|exists:users,id',
        'fcm_token' => 'required|string',
    ]);

    $user = User::find($request->user_id);
    $user->update(['fcm_token' => $request->fcm_token]);

    return response()->json([
        'success' => true,
        'message' => 'FCM token saved successfully.',
    ]);
}
```

### 8. Config Timezone

**File:** `config/app.php`

```php
'timezone' => 'Asia/Jakarta',
```

Jalankan:
```bash
php artisan config:clear
```

---

## 📱 Setup Frontend (Flutter)

### 1. Add Dependencies

**File:** `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.15.2
  firebase_messaging: ^15.2.10
  flutter_local_notifications: ^18.0.1
```

### 2. Android Configuration

**File:** `android/app/build.gradle.kts`

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // Required for flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    
    <application>
        <!-- FCM Service -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT"/>
            </intent-filter>
        </service>
    </application>
</manifest>
```

### 3. Firebase Messaging Service

**File:** `lib/services/firebase_messaging_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    // Request permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('🔥 FCM Token: $_fcmToken');

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('🔥 FCM Token Refreshed: $newToken');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Foreground Message: ${message.notification?.title}');
    
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'schedule_reminders',
          'Schedule Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background Message: ${message.notification?.title}');
}
```

### 4. Update AuthService

**File:** `lib/services/auth_service.dart`

```dart
Future<void> _saveFCMToken() async {
  final fcmToken = FirebaseMessagingService().fcmToken;
  final user = await getCurrentUser();  // IMPORTANT: Get user_id first
  
  if (fcmToken != null && user != null) {
    try {
      await _dio.post('/save-fcm-token', data: {
        'user_id': user.id,      // REQUIRED
        'fcm_token': fcmToken,
      });
      print('✅ FCM token saved to backend');
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }
}
```

Call `_saveFCMToken()` after successful login.

### 5. Main App Initialization

**File:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessagingService().initialize();
  
  runApp(const MyApp());
}
```

---

## 🧪 Testing

### 1. Test FCM Token Generation

```bash
# Flutter app (check console logs)
flutter run
# Look for: "🔥 FCM Token: ..."
```

### 2. Test FCM Token Saved to Database

```bash
cd PBLMobile
php artisan tinker --execute="echo \App\Models\User::whereNotNull('fcm_token')->count();"
# Should return: 1 or more
```

### 3. Test Send Notification

**Create test command:**

```bash
php artisan make:command TestFCMNotification
```

**File:** `app/Console/Commands/TestFCMNotification.php`

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\FCMService;
use App\Models\User;

class TestFCMNotification extends Command
{
    protected $signature = 'fcm:test';
    protected $description = 'Test FCM notification delivery';

    public function handle()
    {
        $this->info('🔍 Finding user with FCM token...');
        
        $user = User::whereNotNull('fcm_token')->first();
        
        if (!$user) {
            $this->error('❌ No user with FCM token found!');
            return Command::FAILURE;
        }

        $this->info("✅ Found user: {$user->name} (ID: {$user->id})");
        $this->info("📱 FCM Token: {$user->fcm_token}");
        
        $this->info('📤 Sending test notification...');
        
        $fcmService = app(FCMService::class);
        $sent = $fcmService->sendNotification(
            $user->fcm_token,
            '🧪 Test Notification',
            'Ini adalah test notifikasi dari MyStudyMate!',
            ['type' => 'test']
        );

        if ($sent) {
            $this->info('✅ Notification sent successfully!');
            $this->info('📱 Check your device now!');
            return Command::SUCCESS;
        } else {
            $this->error('❌ Failed to send notification!');
            return Command::FAILURE;
        }
    }
}
```

**Run test:**

```bash
php artisan fcm:test
```

### 4. Test Schedule Reminder

```bash
# Create schedule 35 minutes from now
# Notification should arrive 5 minutes from now (30 min before)

# Check what will be sent
php artisan schedule:debug

# Manually trigger check
php artisan schedule:check-reminders
```

### 5. Test Automatic Scheduler

```bash
# Run scheduler (keeps running)
php artisan schedule:work
```

---

## 🚀 Production Deployment

### 1. Setup Cron Job (Linux/Mac)

```bash
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

### 2. Setup Windows Task Scheduler

1. Open **Task Scheduler**
2. Create Basic Task
3. Trigger: **Daily** at **00:00**
4. Action: **Start a Program**
   - Program: `C:\php\php.exe`
   - Arguments: `artisan schedule:run`
   - Start in: `D:\Flutter_Project\MyStudyMate\PBLMobile`
5. Settings:
   - ✅ Run task as soon as possible after a scheduled start is missed
   - ✅ Stop the task if it runs longer than: 1 hour
   - Repeat task every: **1 minute** for a duration of **1 day**

### 3. Alternative: Keep Scheduler Running

```bash
# Production (use process manager like Supervisor)
php artisan schedule:work
```

**Supervisor Config:** `/etc/supervisor/conf.d/laravel-scheduler.conf`

```ini
[program:laravel-scheduler]
process_name=%(program_name)s
command=php /path-to-your-project/artisan schedule:work
autostart=true
autorestart=true
user=www-data
redirect_stderr=true
stdout_logfile=/var/log/laravel-scheduler.log
```

---

## 🐛 Troubleshooting

### Problem: Notifikasi tidak masuk

**Check 1: FCM Token tersimpan?**
```bash
php artisan tinker --execute="echo \App\Models\User::whereNotNull('fcm_token')->count();"
```

**Check 2: Timezone benar?**
```bash
php artisan tinker --execute="echo now() . PHP_EOL; echo config('app.timezone');"
# Should show: Asia/Jakarta
```

**Check 3: Scheduler berjalan?**
```bash
php artisan schedule:debug
# Check: "⚠️ Should send notification NOW!"
```

**Check 4: Column exists?**
```sql
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'schedules' AND column_name IN ('reminder', 'notification_sent');
```

### Problem: Notifikasi berulang

**Check: notification_sent di fillable?**

```php
// app/Models/Schedule.php
protected $fillable = [
    // ...
    'reminder',
    'notification_sent',  // ← Must exist!
];
```

### Problem: Legacy API disabled

Firebase Legacy API sudah deprecated. Pastikan menggunakan **FCM API V1** dengan Service Account authentication.

### Problem: Gradle build error (AAR metadata)

```bash
# Enable desugaring
# android/app/build.gradle.kts
isCoreLibraryDesugaringEnabled = true
coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
```

---

## 📊 Debug Commands

### Check schedules status
```bash
php artisan schedule:debug
```

### Manually trigger reminder check
```bash
php artisan schedule:check-reminders
```

### Test FCM notification
```bash
php artisan fcm:test
```

### View Laravel logs
```bash
tail -f storage/logs/laravel.log
```

---

## 📝 Database Schema

```sql
-- users table
ALTER TABLE users ADD COLUMN fcm_token TEXT NULL;

-- schedules table
ALTER TABLE schedules ADD COLUMN reminder BOOLEAN DEFAULT TRUE;
ALTER TABLE schedules ADD COLUMN notification_sent BOOLEAN DEFAULT FALSE;
```

---

## 🎯 Key Features

✅ Push notification 30 menit sebelum kelas  
✅ Notifikasi hanya dikirim 1 kali per jadwal  
✅ Bekerja bahkan saat app closed  
✅ FCM API V1 (future-proof)  
✅ Timezone Asia/Jakarta  
✅ Automatic scheduler  
✅ Production-ready  

---

## 📞 Support

Jika ada masalah, cek:
1. Laravel logs: `storage/logs/laravel.log`
2. Flutter console logs
3. Firebase Console → Cloud Messaging
4. Database: `notification_sent` status

---

**Created:** November 20, 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready
