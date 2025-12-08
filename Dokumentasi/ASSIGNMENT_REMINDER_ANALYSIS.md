# 📝 Analisis: Reminder Setting pada Add Daily Board (Assignment)

## ❓ Pertanyaan User
**"Fungsi dari reminder setting untuk apa dilakukan 30 menit apakah dia sudah melakukan secara otomatis dalam penambahan notifikasi?"**

---

## 🔍 Current Implementation Analysis

### 1. **Reminder Setting di Flutter (Frontend)**

Di `manageScheduleScreen.dart`, user bisa set:
- **Enable Reminder**: Toggle ON/OFF (default: ON)
- **Reminder Time**: 5, 10, 15, 30, 60, 120 menit sebelumnya (default: 30 menit)

```dart
// Ketika save assignment:
await _scheduleService.createAssignment(
  title: _titleController.text,
  deadline: _selectedDate!,
  hasReminder: _hasReminder,        // true/false
  reminderMinutes: _reminderMinutes, // 30 (default)
);
```

**Data tersimpan di database:**
- `has_reminder`: boolean
- `reminder_minutes`: integer (30)

---

## ⚠️ MASALAH: Assignment Reminder TIDAK Otomatis!

### 2. **Backend Notification System**

Ada **2 jenis** reminder system di backend:

#### A. **Schedule/Lecture Reminder** ✅ (OTOMATIS - BEKERJA)

**File:** `PBLMobile/App/Console/Commands/CheckScheduleReminders.php`

**Cara Kerja:**
1. Cron job jalan **setiap menit** (`everyMinute()`)
2. Cek schedule yang `has_reminder = true`
3. Hitung: `start_time - reminder_minutes`
4. Jika waktu sekarang >= waktu reminder → **kirim notifikasi FCM**

**Status:** ✅ **BERFUNGSI OTOMATIS**

```php
// Di Kernel.php
$schedule->command('schedule:check-reminders')->everyMinute();
```

---

#### B. **Assignment Reminder** ⚠️ (TIDAK SESUAI SETTING USER!)

**File:** `PBLMobile/App/Console/Commands/CheckAssignmentReminders.php`

**Cara Kerja:**
1. Cron job jalan **1x sehari jam 07:00 AM** (`dailyAt('07:00')`)
2. Kirim notifikasi di waktu yang **FIXED**:
   - **H-3** (3 hari sebelum deadline) → "Due in 3 days"
   - **H-2** (2 hari sebelum deadline) → "Due in 2 days"
   - **H-1** (1 hari sebelum deadline) → "Due tomorrow"
   - **D-Day** (hari deadline) → "Due TODAY!"
   - **H+1, H+2, H+3** (overdue) → "X days overdue"

**MASALAH:**
❌ **Field `reminder_minutes` DIABAIKAN!**
❌ User set "30 menit sebelum deadline" tapi **tidak dipakai**
❌ Notifikasi tetap dikirim H-3, H-2, H-1 (fixed schedule)

```php
// Di CheckAssignmentReminders.php - TIDAK PAKAI reminder_minutes!
$threeDaysBefore = $today->copy()->addDays(3);
$this->sendReminders($threeDaysBefore, 'h_minus_3', ...); // Fixed H-3
```

---

## 🎯 Kesimpulan

### ✅ Yang Sudah Bekerja Otomatis:
1. **Schedule/Lecture**: Notifikasi dikirim sesuai `reminder_minutes` (30 menit sebelum start_time)
2. **Backend sudah ada FCM Service** untuk kirim push notification

### ❌ Yang BELUM Bekerja Sesuai Harapan:
1. **Assignment Reminder**: Setting `reminder_minutes` (30 menit) **tidak digunakan**
2. Assignment menggunakan sistem H-3, H-2, H-1 yang **fixed**, bukan custom

---

## 💡 Rekomendasi Perbaikan

### **Opsi 1: Gunakan Setting User (reminder_minutes)**

Ubah `CheckAssignmentReminders.php` untuk respect setting `reminder_minutes`:

```php
public function handle()
{
    $this->info('🔍 Checking assignment reminders...');
    
    $now = Carbon::now('Asia/Jakarta');
    
    // Get assignments dengan reminder enabled
    $assignments = Assignment::where('is_done', false)
        ->where('has_reminder', true)
        ->where('notification_sent', false) // Tambahkan field ini
        ->with('user')
        ->get()
        ->filter(function ($assignment) use ($now) {
            // Hitung reminder time dari deadline
            $deadline = Carbon::parse($assignment->deadline);
            $reminderMinutes = $assignment->reminder_minutes ?? 30;
            $reminderTime = $deadline->copy()->subMinutes($reminderMinutes);
            
            // Kirim jika sekarang >= reminder_time dan < deadline
            return $now->greaterThanOrEqualTo($reminderTime) 
                && $now->lessThan($deadline);
        });
    
    foreach ($assignments as $assignment) {
        $this->sendReminderNotification($assignment);
    }
}
```

**Kebutuhan:**
- Tambah field `notification_sent` di table `assignments`
- Ubah cron schedule dari `dailyAt('07:00')` ke `everyMinute()` atau `everyFiveMinutes()`

---

### **Opsi 2: Hybrid System (Recommended)**

Gabungkan kedua sistem:
1. **Custom reminder** (30 menit sebelum deadline) - sekali kirim
2. **Fixed reminders** (H-3, H-2, H-1) - sebagai backup reminder

```php
public function handle()
{
    $now = Carbon::now();
    
    // 1. Custom Reminder (sesuai user setting)
    $this->sendCustomReminders($now);
    
    // 2. Fixed Milestone Reminders (H-3, H-2, H-1)
    if ($now->hour == 7) { // Hanya jam 7 pagi
        $this->sendMilestoneReminders($now);
    }
}
```

---

## 📊 Comparison

| Aspek | System Sekarang | Setelah Fix |
|-------|----------------|-------------|
| **Reminder Time** | Fixed (H-3, H-2, H-1) jam 7 pagi | Custom (30 menit sebelum deadline) |
| **Frequency** | 1x/hari (07:00) | Setiap menit/5 menit |
| **User Control** | Tidak ada | User bisa pilih 5-120 menit |
| **Field `reminder_minutes`** | Diabaikan ❌ | Dipakai ✅ |
| **Milestone Reminders** | Ada (H-3, H-2, H-1) | Optional (bisa dipertahankan) |

---

## 🔧 Migration Needed (Jika Opsi 1/2)

```sql
-- Tambahkan field notification_sent di assignments table
ALTER TABLE assignments 
ADD COLUMN notification_sent BOOLEAN DEFAULT FALSE;
```

---

## 🎯 Jawaban Singkat

**Q: "Apakah reminder 30 menit sudah otomatis?"**

**A: TIDAK untuk Assignment!** 

- ❌ Assignment: Setting `reminder_minutes` (30 menit) **tidak dipakai**. Notifikasi dikirim fixed di H-3, H-2, H-1 jam 07:00 pagi.
- ✅ Schedule/Lecture: Setting `reminder_minutes` **dipakai** dan berfungsi otomatis setiap menit.

---

## ✅ RESOLUTION (December 9, 2025)

**Decision:** Gunakan sistem fixed reminder yang sudah ada (lebih baik untuk assignment).

**Action Taken:**
1. ✅ Update UI di `manageScheduleScreen.dart` untuk menampilkan informasi yang benar
2. ✅ Assignment sekarang menampilkan info box tentang jadwal reminder otomatis
3. ✅ Lecture/Event tetap menampilkan dropdown custom reminder time

**Changes Made:**

### 1. Assignment Reminder Info Box
Ditampilkan ketika user pilih "Assignment" dan enable reminder:

```
📋 Automatic Reminder Schedule
You will receive reminders at 07:00 AM on:
📅 3 days before deadline
📅 2 days before deadline
⏰ 1 day before deadline
🔥 On the deadline day
⚠️ If not completed, overdue reminders will continue for 3 days.
```

### 2. Lecture/Event Custom Reminder
Tetap menampilkan dropdown untuk pilih waktu reminder (5, 10, 15, 30, 60 menit).

### 3. Benefits
- ✅ User tidak bingung tentang cara kerja reminder
- ✅ UI sekarang menjelaskan dengan jelas sistem yang digunakan
- ✅ Tidak perlu ubah backend logic yang sudah stabil
- ✅ Fixed reminder lebih cocok untuk assignment (H-3, H-2, H-1, D-Day)

---

**Dokumentasi dibuat:** December 8, 2025  
**Updated:** December 9, 2025  
**Status:** ✅ Resolved - UI Updated to Match Backend Logic
