# Assignment Notification System

## 📋 Overview
Sistem notifikasi otomatis untuk assignment dengan 3 tahap pengingat:
- **H-3**: 3 hari sebelum deadline (jam 08:00)
- **D-Day**: Hari deadline (jam 08:00)
- **H+3**: 3 hari setelah deadline jika belum selesai (jam 09:00)

## 🎯 Priority Levels

Assignment otomatis diberi label prioritas berdasarkan kedekatan deadline:

| Priority | Label | Kondisi | Warna | Icon |
|----------|-------|---------|-------|------|
| **Critical** | Overdue | Sudah lewat deadline | Red (#DC2626) | priority_high |
| **High** | Urgent | ≤ 1 hari (today/tomorrow) | Orange (#F59E0B) | alarm |
| **Medium** | Soon | 2-3 hari | Blue (#3B82F6) | schedule |
| **Low** | Upcoming | > 3 hari | Green (#10B981) | check_circle_outline |

## ⚙️ Backend Setup

### 1. Command yang Tersedia

```bash
# Check dan kirim notifikasi assignment
php artisan assignments:check-reminders

# Check schedule reminders (existing)
php artisan schedule:check-reminders
```

### 2. Scheduler Configuration

Sudah dikonfigurasi di `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule): void
{
    // Check assignment reminders setiap jam
    $schedule->command('assignments:check-reminders')->hourly();
    
    // Check schedule reminders setiap menit
    $schedule->command('schedule:check-reminders')->everyMinute();
}
```

### 3. Setup Cron Job (Production)

Tambahkan ke crontab server:

```bash
# Edit crontab
crontab -e

# Tambahkan baris ini:
* * * * * cd /path/to/PBLMobile && php artisan schedule:run >> /dev/null 2>&1
```

Ini akan menjalankan scheduler Laravel setiap menit, yang kemudian akan trigger command sesuai jadwal.

### 4. Test Manual

#### Test Notifikasi H-3:
```bash
# Buat assignment dengan deadline 3 hari dari sekarang
php artisan tinker
>>> $user = \App\Models\User::find(1);
>>> $assignment = \App\Models\Assignment::create([
    'user_id' => $user->id,
    'title' => 'Test H-3 Notification',
    'description' => 'Testing notification 3 days before',
    'deadline' => \Carbon\Carbon::now()->addDays(3)->endOfDay(),
    'color' => '#5B9FED',
    'has_reminder' => true,
    'reminder_minutes' => 30,
]);
>>> exit

# Jalankan command (pastikan jam >= 08:00)
php artisan assignments:check-reminders
```

#### Test Notifikasi D-Day:
```bash
php artisan tinker
>>> $assignment = \App\Models\Assignment::create([
    'user_id' => 1,
    'title' => 'Test D-Day Notification',
    'deadline' => \Carbon\Carbon::today()->endOfDay(),
    'has_reminder' => true,
]);
>>> exit

php artisan assignments:check-reminders
```

#### Test Notifikasi H+3:
```bash
php artisan tinker
>>> $assignment = \App\Models\Assignment::create([
    'user_id' => 1,
    'title' => 'Test Overdue Notification',
    'deadline' => \Carbon\Carbon::now()->subDays(3)->endOfDay(),
    'has_reminder' => true,
    'is_done' => false,
]);
>>> exit

php artisan assignments:check-reminders
```

### 5. Prevent Duplicate Notifications

Sistem menggunakan field `last_notification_type` untuk mencegah notifikasi duplikat:
- Setelah kirim H-3 → set `last_notification_type = 'h_minus_3'`
- Setelah kirim D-Day → set `last_notification_type = 'd_day'`
- Setelah kirim H+3 → set `last_notification_type = 'h_plus_3'`

## 📱 Frontend Features

### 1. Priority Display

Di `ScheduleScreen`, setiap assignment menampilkan badge prioritas:

```dart
// Priority badge dengan warna dinamis
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: assignment.priorityColor.withOpacity(0.15),
    border: Border.all(color: assignment.priorityColor),
  ),
  child: Row(
    children: [
      Icon(Icons.priority_high, color: assignment.priorityColor),
      Text(assignment.priorityLabel),
    ],
  ),
)
```

### 2. Assignment Model Properties

```dart
// Getter yang tersedia:
assignment.priority          // 'critical', 'high', 'medium', 'low'
assignment.priorityLabel     // 'Overdue', 'Urgent', 'Soon', 'Upcoming'
assignment.priorityColor     // Color object
assignment.daysUntilDeadline // int (negative jika overdue)
assignment.isOverdue         // bool
assignment.isDueToday        // bool
```

### 3. Filter Completed Assignments

Assignment yang sudah di-mark sebagai done otomatis hilang dari list:

```dart
assignments = (assignmentsResult['data'] as List)
    .map((json) => Assignment.fromJson(json))
    .where((assignment) => !assignment.isDone) // Filter completed
    .toList();
```

## 🔔 Notification Data Structure

Setiap notifikasi berisi data untuk deep linking:

```json
{
  "type": "assignment_reminder",
  "assignment_id": "123",
  "notification_type": "h_minus_3", // atau "d_day", "h_plus_3"
  "deadline": "2025-11-25T23:59:59+07:00"
}
```

## 🐛 Troubleshooting

### Notifikasi tidak terkirim?

1. **Cek FCM Token user**:
```bash
php artisan tinker
>>> $user = \App\Models\User::find(1);
>>> $user->fcm_token; // Harus ada value
```

2. **Cek Assignment has_reminder**:
```bash
>>> $assignment = \App\Models\Assignment::find(1);
>>> $assignment->has_reminder; // Harus true
```

3. **Cek Timezone**:
```bash
>>> \Carbon\Carbon::now('Asia/Jakarta')->format('Y-m-d H:i:s');
```

4. **Cek Laravel Log**:
```bash
tail -f storage/logs/laravel.log
```

### Assignment tidak muncul di app?

1. **Filter is_done**: Assignment yang done otomatis hidden
2. **Date range**: Calendar hanya load assignment dalam range bulan yang ditampilkan

## 📊 Monitoring

### Cek berapa notifikasi yang terkirim hari ini:

```sql
SELECT 
    last_notification_type,
    COUNT(*) as total
FROM assignments
WHERE last_notification_type IS NOT NULL
    AND updated_at >= CURRENT_DATE
GROUP BY last_notification_type;
```

### Cek assignment yang pending H-3:

```sql
SELECT id, title, deadline, last_notification_type
FROM assignments
WHERE is_done = false
    AND DATE(deadline) = CURRENT_DATE + INTERVAL '3 days'
    AND (last_notification_type IS NULL OR last_notification_type != 'h_minus_3');
```

## 🚀 Production Checklist

- [x] Command untuk H-3, D-day, H+3 sudah dibuat
- [x] Scheduler terkonfigurasi (hourly)
- [ ] Cron job di server production
- [ ] FCM credentials sudah di setup
- [ ] Test semua jenis notifikasi
- [ ] Monitor Laravel logs
- [ ] Setup error alerting (optional)

## 📝 Notes

- Notifikasi H-3 dan D-day dikirim mulai jam **08:00**
- Notifikasi H+3 dikirim mulai jam **09:00**
- Timezone: **Asia/Jakarta**
- Hanya kirim ke user yang punya FCM token
- Assignment completed tidak dapat notifikasi H+3
