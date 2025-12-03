# Setup AI Quiz Generation dengan Gemini

## 📋 Arsitektur
Flutter App → Laravel API → Google Gemini AI → Database

## 🔧 Setup Backend (Laravel)

### 1. Dapatkan Gemini API Key (GRATIS)
1. Buka: https://aistudio.google.com/apikey
2. Login dengan Google account
3. Klik **"Create API Key"**
4. Copy API key yang didapat

### 2. Update .env File
```env
# AI Service Configuration
AI_PROVIDER=gemini

# Google Gemini API (FREE - 15 requests/minute)
GEMINI_API_KEY=your_actual_api_key_here
GEMINI_ENDPOINT=https://generativelanguage.googleapis.com/v1beta/models
GEMINI_MODEL=gemini-1.5-flash
GEMINI_TEMPERATURE=0.7

# DeepSeek API (Optional - if you have paid account)
DEEPSEEK_API_KEY=sk-xxxxx
DEEPSEEK_ENDPOINT=https://api.deepseek.com/v1/chat/completions
DEEPSEEK_MODEL=deepseek-chat
DEEPSEEK_MAX_TOKENS=4000
DEEPSEEK_TEMPERATURE=0.7
```

### 3. Clear Config Cache
```bash
cd PBLMobile
php artisan config:clear
```

### 4. Test API
```bash
php artisan tinker
```

Jalankan di tinker:
```php
$service = app(\App\Services\QuizService::class);
$quiz = $service->generateQuizFromAI(1, ['num_questions' => 3]);
echo "Quiz generated with " . $quiz->questions->count() . " questions!\n";
```

## 📱 Flutter Setup

### File yang sudah dikonfigurasi:
1. ✅ `lib/services/study_card_service.dart` - Service untuk hit API Laravel
2. ✅ `lib/screens/studyCards/study_cards_screen.dart` - UI dengan button Generate Quiz
3. ✅ `lib/services/dio_client.dart` - HTTP client dengan authentication

### Endpoint yang digunakan:
```
POST /api/study-cards/{id}/generate-quiz
Body: { "question_count": 5 }
Headers: { "Authorization": "Bearer <token>" }
```

## 🚀 Cara Menggunakan

### Di Flutter App:
1. Login ke aplikasi
2. Buka **Study Cards** screen
3. Klik **"Generate Quiz"** pada card yang diinginkan
4. Pilih jumlah pertanyaan (3, 5, atau 10)
5. Tunggu AI generate quiz (~5-10 detik)
6. Quiz tersimpan otomatis di database

### Material Type Support:
- ✅ **TEXT** - Langsung diproses AI
- ✅ **PDF** - Extracted text dengan smalot/pdfparser
- ❌ **IMAGE** - Not supported yet

## 🔍 Troubleshooting

### Error: "Insufficient Balance"
**Solusi:** 
- Pastikan `AI_PROVIDER=gemini` di .env
- Gemini API key valid dan active
- Clear config: `php artisan config:clear`

### Error: "Failed to extract text from PDF"
**Kemungkinan:**
- PDF adalah scan/image-based (gunakan OCR)
- PDF ter-encrypt
- File corrupt

**Solusi:**
- Gunakan material TEXT untuk hasil terbaik
- Convert PDF ke text terlebih dahulu

### Quiz tidak tersimpan
**Cek:**
1. Database connection: `php artisan tinker` → `DB::connection()->getPdo();`
2. Migration sudah run: `php artisan migrate:status`
3. Log error: `storage/logs/laravel.log`

## 📊 Database Schema

### Tables:
- `study_cards` - Study materials
- `quizzes` - Generated quizzes
- `questions` - Quiz questions  
- `answers` - Answer options

### Relationships:
```
StudyCard → hasMany → Quiz
Quiz → hasMany → Question
Question → hasMany → Answer
```

## 💡 Tips Optimization

1. **Rate Limiting**: Gemini free tier = 15 requests/minute
   - Add queue/delay untuk batch generation

2. **Caching**: Cache quiz yang sudah di-generate
   ```php
   Cache::remember("quiz_{$studyCardId}", 3600, fn() => $quiz);
   ```

3. **Fallback**: Sudah ada `generateDummyQuiz()` jika API fail

## 🔐 Security

✅ API Key tersembunyi di backend (tidak exposed ke Flutter)
✅ Authentication dengan Laravel Sanctum
✅ Rate limiting di Laravel routes
✅ Input validation di StudyCardRequest

## 📝 Next Steps

- [ ] Implement Take Quiz screen
- [ ] Implement Quiz Result screen  
- [ ] Add Quiz History/Attempts
- [ ] Add Quiz Analytics
- [ ] Support image-based materials (OCR)
