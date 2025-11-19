# Firebase Cloud Messaging Setup Guide

## 📱 Setup Firebase untuk MyStudyMate

### 1. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add project"** atau gunakan project yang sudah ada
3. Nama project: `MyStudyMate` (atau nama lain)
4. Enable Google Analytics (optional)
5. Klik **"Create project"**

### 2. Tambahkan Android App

1. Di Firebase Console, klik **ikon Android** untuk menambahkan app
2. Isi form:
   - **Package name**: `com.example.my_study_mate` (sesuaikan dengan `applicationId` di `android/app/build.gradle`)
   - **App nickname**: MyStudyMate
   - **Debug signing certificate SHA-1**: (optional untuk development)
3. Download file **`google-services.json`**
4. Copy file tersebut ke folder: `android/app/google-services.json`

### 3. Setup Android Configuration

File sudah dikonfigurasi otomatis, tapi pastikan:

#### `android/build.gradle`
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

#### `android/app/build.gradle`
```gradle
plugins {
    id 'com.google.gms.google-services'
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:33.0.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### 4. Tambahkan Web App (untuk Chrome)

1. Klik **ikon Web** di Firebase Console
2. Isi app nickname
3. Copy **Firebase configuration object**
4. Buat file `web/firebase-config.js`:

```javascript
// Import Firebase SDK
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.0.0/firebase-app.js";
import { getMessaging } from "https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging.js";

const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);
```

5. Generate **VAPID key**:
   - Firebase Console → Project Settings → Cloud Messaging → Web Push certificates
   - Klik **"Generate key pair"**
   - Copy VAPID key
   - Update di `lib/services/firebase_messaging_service.dart`:
     ```dart
     _fcmToken = await _firebaseMessaging.getToken(
       vapidKey: 'YOUR_VAPID_KEY_HERE', // Paste di sini
     );
     ```

### 5. Run Flutter Commands

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (otomatis generate konfigurasi)
flutterfire configure

# Run app
flutter run -d chrome  # Untuk web
flutter run -d <device-id>  # Untuk Android
```

### 6. Test Notifications

#### Test dari Firebase Console:
1. Firebase Console → Cloud Messaging → Send test message
2. Masukkan FCM token (akan terprint di console saat app run)
3. Kirim notifikasi test

#### Test dari Backend Laravel:
Schedule akan otomatis kirim notifikasi via backend cron job.

---

## 🔧 Backend Configuration (Laravel)

Backend sudah dikonfigurasi dengan:
- ✅ `FCMService.php` - Service untuk kirim push notification
- ✅ `CheckScheduleReminders` - Cron job cek schedule setiap menit
- ✅ Migration untuk `fcm_token` di tabel users
- ✅ API endpoint `/save-fcm-token`

### Setup Server Key di Backend:

1. Firebase Console → Project Settings → Cloud Messaging
2. Copy **Server key**
3. Update di `app/Services/FCMService.php`:
```php
private $serverKey = 'YOUR_SERVER_KEY_HERE';
```

### Run Scheduler:
```bash
php artisan schedule:work
```

---

## ✅ Cara Kerja Push Notification

1. **User Login** → FCM token disimpan ke backend
2. **Create Schedule** dengan reminder → Disimpan ke database
3. **Backend Cron** (jalan setiap menit) → Cek schedule yang reminder-nya 30 menit lagi
4. **Kirim FCM** → Push notification ke device user
5. **User Tap** → Buka app dan lihat schedule detail

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Support | Full FCM support |
| iOS | ✅ Support | Perlu APNs certificate |
| Web (Chrome) | ✅ Support | Perlu VAPID key |
| Windows | ❌ Not support | FCM web hanya untuk browser |

---

## 🐛 Troubleshooting

### Token tidak muncul:
```dart
print('[FCM] Token: $_fcmToken'); // Check di console
```

### Notifikasi tidak muncul:
1. Check permission granted
2. Check FCM token tersimpan di backend
3. Check cron job running: `php artisan schedule:work`
4. Check Firebase Console logs

### Error "Default FirebaseApp is not initialized":
```bash
# Re-run flutterfire configure
flutterfire configure
```

---

## 📚 Resources

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [FCM Setup Guide](https://firebase.google.com/docs/cloud-messaging/flutter/client)
