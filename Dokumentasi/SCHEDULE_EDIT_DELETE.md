# Schedule Feature - Edit & Delete Documentation

## ✨ Fitur Baru

### 1. **Edit Schedule**
- User dapat mengedit jadwal yang sudah dibuat
- Semua field dapat diubah: title, date, time, location, lecturer, color, dll
- Validasi conflict checking untuk mencegah bentrok jadwal
- Real-time update setelah edit berhasil

### 2. **Delete Schedule**
- User dapat menghapus jadwal dengan konfirmasi dialog
- Soft delete di backend (data tetap ada di database dengan deleted_at)
- Auto refresh setelah delete berhasil

### 3. **User Isolation**
- Setiap user hanya melihat jadwal mereka sendiri
- Backend menggunakan `forUser()` scope untuk filter by user_id
- Auth ID default ke user 1 untuk testing (bisa diganti dengan proper auth nanti)

## 🎯 Cara Menggunakan

### Di Home Screen:
1. Tap pada schedule card di bagian "Schedule" section
2. Otomatis membuka Edit Schedule Screen
3. Ubah data yang diinginkan
4. Tap "Update Schedule" untuk simpan atau icon delete untuk hapus

### Di Schedule Screen (Calendar):
1. Pilih tanggal di calendar
2. Tap pada schedule item di list bawah
3. Edit atau delete schedule
4. Checkbox untuk toggle completion status tetap bisa digunakan langsung

## 🔧 Technical Details

### Backend (Laravel)
- **Controller**: `ScheduleController@update` & `ScheduleController@destroy`
- **Model**: Schedule dengan scope `forUser()` untuk isolasi user
- **Validation**: Conflict checking sebelum update
- **Auth**: Menggunakan `Auth::id() ?? 1` (default user 1 untuk testing)

### Frontend (Flutter)
- **Service**: `ScheduleService.updateSchedule()` & `deleteSchedule()`
- **Screen**: `EditScheduleScreen` untuk UI edit/delete
- **State Management**: `setState()` dengan `Future` refresh

### API Endpoints
```
PUT    /api/schedules/{id}     - Update schedule
DELETE /api/schedules/{id}     - Delete schedule
GET    /api/schedules/range    - Get schedules by date range (filtered by user)
```

## 📝 Database Structure
```sql
schedules table:
- id (primary key)
- user_id (foreign key) --> ISOLASI USER
- title, description, date, start_time, end_time
- location, lecturer, color, type
- has_reminder, reminder_minutes
- is_completed
- timestamps, deleted_at (soft delete)
```

## 🧪 Testing

### Test Users Created:
1. **User 1 (Satriya)**
   - Email: satriya@example.com
   - Password: password123
   - 5 schedules seeded

2. **User 2 (Azaria)**
   - Email: azaria@example.com  
   - Password: password123
   - 3 schedules seeded

### Run Seeder:
```bash
cd PBLMobile
php artisan db:seed --class=ScheduleSeeder
```

## 🎨 UI Features

### Edit Schedule Screen
- ✅ Form lengkap dengan validation
- ✅ Date picker & time picker
- ✅ Dropdown untuk type (lecture, lab, meeting, etc)
- ✅ Color picker dengan 6 pilihan warna
- ✅ Reminder settings
- ✅ Delete button di AppBar
- ✅ Loading state saat update/delete

### Integration dengan Home & Schedule Screen
- ✅ Tap schedule card → Edit Screen
- ✅ Auto refresh setelah edit/delete
- ✅ Success/error snackbar feedback
- ✅ Smooth navigation

## 🚀 Next Steps

1. **Implement proper authentication** - Ganti `Auth::id() ?? 1` dengan real auth
2. **Add undo delete** - Gunakan soft delete untuk restore
3. **Add duplicate schedule** - Quick action untuk duplicate
4. **Add batch operations** - Multiple select & delete
5. **Add schedule sharing** - Share schedule antar user

## 📱 Screenshots Flow

```
Home Screen → Schedule Card (Tap)
    ↓
Edit Schedule Screen
    ├── Update Button → Success → Refresh → Home Screen
    └── Delete Icon → Confirm Dialog → Delete → Refresh → Home Screen

Schedule Screen → Schedule Item (Tap)
    ↓
Edit Schedule Screen (same flow)
```

## ⚠️ Important Notes

1. **User ID hardcoded to 1** for testing - Implement proper auth later
2. **Soft delete enabled** - Schedules not permanently deleted
3. **Conflict checking** - Backend validates time conflicts
4. **Auto refresh** - Uses `Future` and `setState()` for real-time update

## 🔐 Security Considerations

- ✅ User isolation di backend (`forUser()` scope)
- ✅ Validation di controller
- ✅ Foreign key constraint dengan cascade delete
- ⚠️ TODO: Implement proper JWT/Sanctum authentication
- ⚠️ TODO: Add rate limiting untuk API
