# Setup Supabase untuk MyStudyMate

## 📋 Langkah-langkah Setup Supabase

### 1. Buat Project di Supabase

1. Kunjungi [https://supabase.com](https://supabase.com)
2. Sign up atau login
3. Klik **"New Project"**
4. Isi detail project:
   - **Name**: MyStudyMate
   - **Database Password**: (buat password yang kuat)
   - **Region**: Pilih yang terdekat (Singapore)
   - **Pricing Plan**: Free
5. Klik **"Create new project"**
6. Tunggu beberapa menit hingga project siap

### 2. Dapatkan API Keys

1. Setelah project siap, buka **Settings** (ikon gear di sidebar)
2. Pilih **API** di menu sebelah kiri
3. Di bagian **Project URL** dan **Project API keys**, copy:
   - **URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 3. Konfigurasi di Flutter

Buka file `lib/utils/supabase_config.dart` dan isi credentials:

```dart
const String kSupabaseUrl = 'https://xxxxx.supabase.co'; // Ganti dengan URL kamu
const String kSupabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Ganti dengan anon key kamu
```

### 4. Setup Database Schema (Optional - untuk fitur tambahan)

Jika ingin menyimpan data profile user, buat table di Supabase:

1. Buka **SQL Editor** di dashboard Supabase
2. Klik **"New query"**
3. Paste dan jalankan SQL ini:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public profiles are viewable by everyone."
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile."
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile."
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- Create function to handle new user profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'username', 'user_' || substring(new.id::text, 1, 8)),
    COALESCE(new.raw_user_meta_data->>'full_name', 'User')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create profile
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 5. Email Settings (Optional - untuk verification)

Untuk email verification dan password reset:

1. Buka **Authentication** > **Email Templates**
2. Customize template jika perlu
3. Untuk testing, bisa disable email confirmation:
   - **Authentication** > **Settings**
   - Uncheck **"Enable email confirmations"**

### 6. Test Authentication

Jalankan aplikasi dan test:

1. **Sign Up**: Buat akun baru
2. **Sign In**: Login dengan akun yang baru dibuat
3. **Forgot Password**: Test reset password
4. **Logout**: Test logout functionality

## 🔐 Fitur Authentication yang Sudah Terimplementasi

✅ **Sign Up**
- Email & password registration
- Store full name & username di user metadata
- Auto create profile (jika SQL trigger sudah dijalankan)
- Error handling & validation

✅ **Sign In**
- Email & password login
- Remember login session
- Auto redirect jika sudah login
- Error handling dengan pesan user-friendly

✅ **Forgot Password**
- Send password reset email
- Dialog UI untuk input email
- Error handling

✅ **Logout**
- Confirmation dialog
- Clear session
- Redirect ke welcome screen

✅ **Session Management**
- Auto check auth state di splash screen
- Persist login across app restarts
- Secure session dengan Supabase

## 🚀 Next Steps

Setelah authentication berfungsi, kamu bisa lanjut ke:

1. **User Profile Management** - Edit profile, upload avatar
2. **Dashboard** - Streak, progress, kalender
3. **Fitur Tugas** - CRUD tugas dengan database
4. **Fitur Jadwal** - Kelola jadwal kuliah
5. **Study Plan** - Generate soal dari materi
6. **Pomodoro Timer** - Timer fokus belajar

## 📝 Notes

- Jika `kSupabaseUrl` dan `kSupabaseAnonKey` kosong, app akan tetap jalan tapi fitur auth tidak akan bekerja
- Untuk production, jangan commit credentials ke Git (gunakan environment variables)
- Supabase free tier: 500MB database, 1GB file storage, 2GB bandwidth/month

## 🆘 Troubleshooting

**Error: "Supabase not configured"**
- Pastikan sudah mengisi `kSupabaseUrl` dan `kSupabaseAnonKey`

**Error: "Invalid login credentials"**
- Cek email & password benar
- Pastikan user sudah terdaftar

**Error: "Email not confirmed"**
- Cek inbox email untuk confirmation link
- Atau disable email confirmation di settings

**Email tidak diterima**
- Cek spam folder
- Untuk testing, disable email confirmation
