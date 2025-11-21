# Schedule Manager - Dokumentasi Lengkap

## 📋 Overview
Fitur Schedule Manager yang terintegrasi penuh dengan:
- ✅ CRUD jadwal kuliah/kegiatan per hari
- ✅ Pengingat otomatis 30 menit sebelum kelas (Notifications)
- ✅ Integrasi Task dengan deadline di kalender mingguan
- ✅ Dashboard terintegrasi dengan statistik
- ✅ Deteksi konflik jadwal otomatis

---

## 🏗️ Struktur Backend (Laravel)

### Models
1. **`Schedule.php`** (`app/Models/Schedule.php`)
   - Fields: `user_id`, `title`, `description`, `date`, `start_time`, `end_time`, `location`, `color`, `type`, `has_reminder`, `reminder_minutes`, `is_completed`
   - Relationships: `belongsTo(User)`
   - Scopes: `forUser()`, `onDate()`, `betweenDates()`, `upcoming()`, `completed()`, `incomplete()`
   - Methods: `hasConflictWith()`, `checkConflict()`

2. **`Task.php`** (`app/Models/Task.php`)
   - Fields: `user_id`, `title`, `description`, `deadline`, `category`, `priority`, `is_completed`
   - Relationships: `belongsTo(User)`
   - Scopes: `forUser()`, `withDeadline()`, `betweenDeadlines()`, `completed()`, `incomplete()`

### Controllers
1. **`ScheduleController.php`** (`app/Http/Controllers/ScheduleController.php`)
   - `index()` - Get all schedules
   - `store()` - Create schedule (with conflict check)
   - `show($id)` - Get single schedule
   - `update($id)` - Update schedule (with conflict check)
   - `destroy($id)` - Delete schedule
   - `getByDate($date)` - Get schedules for specific date
   - `getByDateRange()` - Get schedules for date range
   - `getUpcoming()` - Get upcoming schedules
   - `toggleComplete($id)` - Mark schedule as complete/incomplete
   - `checkConflict()` - Check if schedule conflicts with existing
   - `getStats()` - Get schedule statistics

2. **`TaskController.php`** (`app/Http/Controllers/TaskController.php`)
   - `index()` - Get all tasks
   - `store()` - Create task
   - `show($id)` - Get single task
   - `update($id)` - Update task
   - `destroy($id)` - Delete task
   - `getByDeadlineRange()` - Get tasks for date range (for calendar integration)
   - `getUpcoming()` - Get upcoming tasks
   - `toggleComplete($id)` - Mark task as complete/incomplete
   - `getStats()` - Get task statistics

### API Routes (`routes/api.php`)

#### Schedule Routes
```
GET    /api/schedules                 - Get all schedules
POST   /api/schedules                 - Create schedule
GET    /api/schedules/stats           - Get statistics
GET    /api/schedules/upcoming        - Get upcoming schedules
GET    /api/schedules/date/{date}     - Get schedules by date
GET    /api/schedules/range           - Get schedules by date range
POST   /api/schedules/check-conflict  - Check schedule conflict
GET    /api/schedules/{id}            - Get single schedule
PUT    /api/schedules/{id}            - Update schedule
PATCH  /api/schedules/{id}/toggle-complete - Toggle completion
DELETE /api/schedules/{id}            - Delete schedule
```

#### Task Routes
```
GET    /api/tasks                     - Get all tasks
POST   /api/tasks                     - Create task
GET    /api/tasks/stats               - Get statistics
GET    /api/tasks/upcoming            - Get upcoming tasks
GET    /api/tasks/range               - Get tasks by deadline range
GET    /api/tasks/{id}                - Get single task
PUT    /api/tasks/{id}                - Update task
PATCH  /api/tasks/{id}/toggle-complete - Toggle completion
DELETE /api/tasks/{id}                - Delete task
```

### Database Migrations
1. **schedules** table:
   ```sql
   - id (bigint)
   - user_id (bigint, FK to users)
   - title (string)
   - description (text, nullable)
   - date (date)
   - start_time (time)
   - end_time (time)
   - location (string, nullable)
   - color (string, nullable)
   - type (enum: lecture, lab, meeting, event, assignment, other)
   - has_reminder (boolean, default true)
   - reminder_minutes (integer, default 30)
   - is_completed (boolean, default false)
   - timestamps
   - soft_deletes
   ```

2. **tasks** table:
   ```sql
   - id (bigint)
   - user_id (bigint, FK to users)
   - title (string)
   - description (text, nullable)
   - deadline (datetime, nullable)
   - category (string, nullable)
   - priority (enum: low, medium, high, urgent)
   - is_completed (boolean, default false)
   - timestamps
   - soft_deletes
   ```

---

## 📱 Struktur Frontend (Flutter)

### Models
1. **`schedule_model.dart`** (`lib/models/schedule_model.dart`)
   - Properties: `id`, `userId`, `title`, `description`, `date`, `startTime`, `endTime`, `location`, `color`, `type`, `hasReminder`, `reminderMinutes`, `isCompleted`
   - Methods: 
     - `fromJson()` - Parse dari API response
     - `toJson()` - Convert untuk API request
     - `getFormattedStartTime()` - Get formatted time string
     - `getFormattedEndTime()` - Get formatted time string
     - `isToday()` - Check if schedule is today
     - `getReminderDateTime()` - Get reminder time

2. **`task_model.dart`** (`lib/models/task_model.dart`)
   - Properties: `id`, `userId`, `title`, `description`, `deadline`, `category`, `priority`, `isCompleted`
   - Methods:
     - `fromJson()` - Parse dari API response
     - `toJson()` - Convert untuk API request
     - `hasDeadline()` - Check if task has deadline
     - `isOverdue()` - Check if task is overdue
     - `isDueToday()` - Check if task deadline is today
     - `getFormattedDeadline()` - Get formatted deadline string

### Services
1. **`schedule_service.dart`** (`lib/services/schedule_service.dart`)
   - `getSchedules()` - Get all schedules
   - `getSchedulesByDateRange(startDate, endDate)` - Get schedules for calendar
   - `getSchedulesByDate(date)` - Get schedules for specific date
   - `getUpcomingSchedules({limit})` - Get upcoming schedules
   - `createSchedule({...})` - Create new schedule
   - `updateSchedule(id, {...})` - Update existing schedule
   - `toggleScheduleCompletion(id, isCompleted)` - Toggle completion
   - `deleteSchedule(id)` - Delete schedule
   - `checkConflict({...})` - Check schedule conflict
   - `getStats()` - Get statistics

2. **`task_service.dart`** (`lib/services/task_service.dart`)
   - `getTasks()` - Get all tasks
   - `getTasksByDeadlineRange(startDate, endDate)` - Get tasks for calendar
   - `getUpcomingTasks({limit})` - Get upcoming tasks
   - `createTask({...})` - Create new task
   - `updateTask(id, {...})` - Update existing task
   - `toggleTaskCompletion(id, isCompleted)` - Toggle completion
   - `deleteTask(id)` - Delete task
   - `getStats()` - Get statistics

3. **`notification_service.dart`** (`lib/services/notification_service.dart`)
   - `initialize()` - Initialize notification plugin
   - `scheduleReminder(schedule)` - Schedule reminder for schedule (30 min before)
   - `cancelReminder(scheduleId)` - Cancel specific reminder
   - `cancelAllReminders()` - Cancel all reminders
   - `showNotification({...})` - Show immediate notification
   - `requestPermissions()` - Request notification permissions
   - `areNotificationsEnabled()` - Check if notifications are enabled

### Screens
1. **`scheduleScreen.dart`** (`lib/screens/scheduleFeature/scheduleScreen.dart`)
   - Calendar view dengan marker untuk schedules & tasks
   - List view untuk schedules dan tasks per hari
   - Pull-to-refresh untuk reload data
   - Integrasi dengan notification service
   - Checkbox untuk mark complete/incomplete
   - Color indicator untuk priority/type
   - Location display untuk schedules

2. **`manageScheduleScreen.dart`** (`lib/screens/scheduleFeature/manageScheduleScreen.dart`)
   - Form untuk create schedule
   - Date picker
   - Time picker (start & end)
   - Title input
   - Validation
   - Error handling

---

## 🔔 Fitur Notifikasi

### Setup Requirements
```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
  permission_handler: ^11.3.1
```

### Cara Kerja
1. Saat schedule dibuat dengan `has_reminder: true`
2. System otomatis schedule notification 30 menit sebelum `start_time`
3. Notification muncul dengan:
   - Title: "Upcoming: {schedule_title}"
   - Body: "{start_time} - {end_time} at {location}"
4. User bisa tap notification untuk buka schedule detail (future enhancement)

### Platform-Specific Setup

#### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

#### iOS (`ios/Runner/Info.plist`)
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

---

## 🚀 Testing & Usage

### Backend Testing
```bash
# Run migrations
cd PBLMobile
php artisan migrate

# Test API dengan Postman/Insomnia
POST http://localhost:8000/api/schedules
Headers: 
  Authorization: Bearer {token}
Body:
{
  "title": "Mobile Programming",
  "date": "2025-11-20",
  "start_time": "08:00",
  "end_time": "10:00",
  "type": "lecture",
  "has_reminder": true,
  "reminder_minutes": 30
}
```

### Flutter Testing
```bash
cd MYSTUDYMATE
flutter pub get
flutter run -d chrome  # atau device lain
```

### Workflow Testing
1. **Login** ke aplikasi
2. **Navigate** ke Schedule Screen
3. **Tap FAB (+)** untuk add schedule
4. **Fill form**: Title, Date, Start Time, End Time
5. **Save** → Schedule muncul di calendar
6. **Pull to refresh** untuk reload data
7. **Tap checkbox** untuk mark complete
8. **Check notification** 30 menit sebelum schedule

---

## ⚠️ Known Issues & Solutions

### Issue 1: Notification tidak muncul di Android 13+
**Solution**: Request permission di runtime
```dart
await NotificationService().requestPermissions();
```

### Issue 2: Schedule conflict tidak terdeteksi
**Solution**: Backend sudah implement `checkConflict()`. Pastikan:
- `start_time` format: "HH:mm" (24-hour)
- `end_time` > `start_time`
- `date` format: "yyyy-MM-dd"

### Issue 3: Task tidak muncul di calendar
**Solution**: Pastikan task memiliki `deadline` yang valid

---

## 📊 Database Schema Diagram

```
users
  ├── schedules (1:N)
  │     ├── id
  │     ├── user_id (FK)
  │     ├── title
  │     ├── date
  │     ├── start_time
  │     ├── end_time
  │     └── ...
  │
  └── tasks (1:N)
        ├── id
        ├── user_id (FK)
        ├── title
        ├── deadline
        └── ...
```

---

## 🎯 Future Enhancements

1. **Recurring Schedules** - Jadwal berulang (setiap Senin, dsb)
2. **Schedule Categories** - Custom categories untuk schedules
3. **Task Priority Colors** - Visual indicator untuk priority
4. **Export/Import** - Export jadwal ke calendar (.ics)
5. **Collaboration** - Share schedule dengan teman
6. **Statistics Dashboard** - Visual charts untuk productivity
7. **Dark Mode** - Theme support
8. **Offline Mode** - Local database dengan sync

---

## 📝 Change Log

### Version 1.0.0 (2025-11-18)
- ✅ Initial release
- ✅ CRUD Schedule
- ✅ CRUD Task
- ✅ Calendar integration
- ✅ Notification system
- ✅ Conflict detection
- ✅ Statistics API

---

## 👨‍💻 Developer Notes

### Code Style
- Backend: PSR-12 (Laravel standard)
- Frontend: Effective Dart guidelines
- API: RESTful conventions

### Testing
- Backend: PHPUnit (future)
- Frontend: Flutter test (future)

### Documentation
- API: Postman collection (future)
- Code: Inline comments
- Architecture: This README

---

Dibuat dengan ❤️ untuk MyStudyMate Project
