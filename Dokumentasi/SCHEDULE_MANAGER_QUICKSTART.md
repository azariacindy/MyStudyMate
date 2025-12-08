# 🎯 Schedule Manager - Quick Start Guide

## ✅ Yang Sudah Diperbaiki

### Backend (Laravel)
1. ✅ Fixed `ScheduleController.php.php` → `ScheduleController.php`
2. ✅ Fixed namespace di `StoreScheduleRequest.php` dan `UpdateScheduleRequest.php`
3. ✅ Added missing API routes (stats, upcoming, date range, check-conflict)
4. ✅ Created complete `TaskController.php` dengan full CRUD
5. ✅ Created `StoreTaskRequest.php`, `UpdateTaskRequest.php`, `TaskResource.php`
6. ✅ Added Task API routes untuk calendar integration

### Frontend (Flutter)
1. ✅ Fixed `schedule_model.dart` - parsing time dari API (HH:mm format)
2. ✅ Created `task_model.dart` dengan helper methods
3. ✅ Rewrote `schedule_service.dart` - proper API integration
4. ✅ Created `task_service.dart` - full CRUD operations
5. ✅ Created `notification_service.dart` - reminder 30 min sebelum schedule
6. ✅ Updated `scheduleScreen.dart` - integrated dengan API, Task, dan Notifications
7. ✅ Updated `manageScheduleScreen.dart` - return Schedule object
8. ✅ Added dependencies: `flutter_local_notifications`, `timezone`, `permission_handler`

---

## 🚀 Cara Menjalankan

### 1. Backend Setup
```bash
cd D:\Flutter_Project\MyStudyMate\PBLMobile

# Install dependencies (jika belum)
composer install

# Run migrations
php artisan migrate

# Start server
php artisan serve
```

### 2. Flutter Setup
```bash
cd D:\Flutter_Project\MyStudyMate\MYSTUDYMATE

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome  # atau device Android/iOS
```

---

## 📋 API Endpoints

### Schedules
- `GET /api/schedules` - Get all
- `POST /api/schedules` - Create (auto check conflict)
- `GET /api/schedules/upcoming?limit=5` - Upcoming schedules
- `GET /api/schedules/date/2025-11-20` - Schedules by date
- `GET /api/schedules/range?start_date=...&end_date=...` - Date range
- `POST /api/schedules/check-conflict` - Check conflict
- `PUT /api/schedules/{id}` - Update
- `PATCH /api/schedules/{id}/toggle-complete` - Toggle complete
- `DELETE /api/schedules/{id}` - Delete

### Tasks
- `GET /api/tasks` - Get all
- `POST /api/tasks` - Create
- `GET /api/tasks/upcoming?limit=10` - Upcoming tasks
- `GET /api/tasks/range?start_date=...&end_date=...` - Deadline range (for calendar)
- `PUT /api/tasks/{id}` - Update
- `PATCH /api/tasks/{id}/toggle-complete` - Toggle complete
- `DELETE /api/tasks/{id}` - Delete

---

## 🔔 Notification Setup

### Android Permission (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### Request Permission in App
```dart
// Automatically done in NotificationService.initialize()
await NotificationService().requestPermissions();
```

---

## 💡 Key Features

### 1. Schedule Management
- ✅ Create jadwal dengan title, date, start time, end time
- ✅ Auto detect conflict (tidak bisa create jadwal yang bentrok)
- ✅ Mark complete/incomplete via checkbox
- ✅ Color indicator untuk visual grouping
- ✅ Location support

### 2. Task Integration
- ✅ Tasks dengan deadline otomatis muncul di calendar
- ✅ Priority indicator (low, medium, high, urgent)
- ✅ Overdue detection
- ✅ Complete/incomplete toggle

### 3. Calendar View
- ✅ Monthly calendar dengan marker untuk events
- ✅ Click date untuk lihat schedule & task
- ✅ Pull-to-refresh untuk reload data
- ✅ Navigate between months (auto reload data)

### 4. Notifications
- ✅ Auto schedule notification 30 min sebelum class
- ✅ Notification includes: title, time, location
- ✅ Can be enabled/disabled per schedule
- ✅ Customizable reminder minutes (default 30)

---

## 🐛 Troubleshooting

### Problem: "Target of URI doesn't exist" untuk notification packages
**Solution**: 
```bash
flutter pub get
flutter clean
flutter pub get
```

### Problem: Notification tidak muncul
**Solution**:
1. Check permission granted: `Settings > Apps > MyStudyMate > Notifications`
2. Test dengan immediate notification:
   ```dart
   await NotificationService().showNotification(
     id: 1,
     title: "Test",
     body: "This is a test notification"
   );
   ```

### Problem: Schedule conflict tidak terdeteksi
**Solution**: Pastikan format time benar:
```dart
// ✅ CORRECT
start_time: "08:00"
end_time: "10:00"

// ❌ WRONG
start_time: "8:0"
end_time: "10:0"
```

### Problem: API error "Unauthenticated"
**Solution**: Pastikan sudah login dan token tersimpan di DioClient

---

## 📊 Testing Checklist

- [ ] Login berhasil
- [ ] Navigate ke Schedule Screen
- [ ] Calendar tampil dengan benar
- [ ] Tap FAB (+) untuk add schedule
- [ ] Form validation working (title required, time validation)
- [ ] Schedule saved successfully
- [ ] Schedule muncul di calendar
- [ ] Notification scheduled (check 30 min before)
- [ ] Tap checkbox → mark complete
- [ ] Pull to refresh → data reload
- [ ] Task dengan deadline muncul di calendar
- [ ] Conflict detection working

---

## 📁 File Structure

```
PBLMobile/
├── app/
│   ├── Models/
│   │   ├── Schedule.php ✅
│   │   └── Task.php ✅
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── ScheduleController.php ✅
│   │   │   └── TaskController.php ✅
│   │   ├── Requests/
│   │   │   ├── StoreScheduleRequest.php ✅
│   │   │   ├── UpdateScheduleRequest.php ✅
│   │   │   ├── StoreTaskRequest.php ✅
│   │   │   └── UpdateTaskRequest.php ✅
│   │   └── Resources/
│   │       ├── ScheduleResource.php ✅
│   │       └── TaskResource.php ✅
│   └── Services/
│       └── ScheduleService.php ✅
├── database/migrations/
│   ├── *_create_schedules_table.php ✅
│   └── *_create_tasks_table.php ✅
└── routes/
    └── api.php ✅

MYSTUDYMATE/
├── lib/
│   ├── models/
│   │   ├── schedule_model.dart ✅
│   │   └── task_model.dart ✅
│   ├── services/
│   │   ├── schedule_service.dart ✅
│   │   ├── task_service.dart ✅
│   │   └── notification_service.dart ✅
│   └── screens/
│       └── scheduleFeature/
│           ├── scheduleScreen.dart ✅
│           └── manageScheduleScreen.dart ✅
└── pubspec.yaml ✅
```

---

## 🎓 Next Steps

1. **Test lengkap** semua fitur di device fisik
2. **Add edit schedule** feature (dialog atau screen baru)
3. **Add delete schedule** dengan confirmation dialog
4. **Improve UI** untuk schedule list (swipe to delete, dll)
5. **Add recurring schedules** (weekly, monthly)
6. **Statistics dashboard** untuk productivity tracking

---

## 📞 Support

Untuk pertanyaan atau bug report, silakan dokumentasikan di:
- Issue tracker (GitHub)
- Team discussion (Discord/Slack)
- Code review session

---

**Status**: ✅ Production Ready (dengan testing)
**Version**: 1.0.0
**Last Updated**: 2025-11-18
