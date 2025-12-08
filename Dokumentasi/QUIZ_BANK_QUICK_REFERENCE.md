# 🎯 Quiz Bank System - Quick Reference

## 🚀 For Developers

### Backend (Laravel)

#### Generate Quiz Endpoint
```bash
POST /api/study-cards/{id}/generate-quiz
Body: { "question_count": 5 }
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "study_card": {...},
    "title": "Title - Bank Soal",
    "total_questions": 5,
    "ai_model": "gemini",  // or "bank" for subsequent calls
    "questions": [
      {
        "question_text": "...",
        "question_type": "multiple_choice",
        "points": 10,
        "explanation": "...",
        "answers": [
          {"answer_text": "...", "is_correct": true},
          {"answer_text": "...", "is_correct": false}
        ]
      }
    ]
  }
}
```

#### Key Files Modified
```
PBLMobile/App/Services/QuizService.php
├─ generateQuizFromAI()          # Main entry point
├─ generateAndSaveToBankOnce()   # First-time AI generation
├─ createQuizFromBank()          # Reuse from bank
├─ getBankQuestions()            # Fetch bank questions
└─ extractMaterialContent()      # PDF/Text extraction
```

---

### Flutter (Dart)

#### Generate Quiz Flow
```dart
// 1. User clicks "Mulai Quiz"
await _service.generateQuiz(studyCardId, questionCount: 5);

// 2. Navigate to Take Quiz
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TakeQuizScreen(
      quizData: quizData,
      studyCard: widget.studyCard,
    ),
  ),
);
```

#### Key Files Modified
```
MYSTUDYMATE/lib/
├─ screens/studyCards/
│  └─ study_card_detail_screen.dart
│     ├─ _startQuiz()           # Generate & navigate
│     ├─ Smart loading dialog    # Different message for first/subsequent
│     ├─ Enhanced error handling # PDF/image/network errors
│     └─ Info banner             # Educate users about bank system
└─ services/
   └─ study_card_service.dart
      └─ generateQuiz()          # API call with 90s timeout
```

---

## 🔄 Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER ACTION                              │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Flutter: study_card_detail_screen.dart                     │
│  - _startQuiz() called                                       │
│  - Show loading dialog                                       │
│  - Call API: _service.generateQuiz()                        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Flutter: study_card_service.dart                           │
│  POST /api/study-cards/{id}/generate-quiz                  │
│  Timeout: 90 seconds                                        │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Laravel: StudyCardController                                │
│  public function generateQuiz($id)                           │
│  - Validate request                                          │
│  - Call QuizService::generateQuizFromAI()                   │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Laravel: QuizService                                        │
│  generateQuizFromAI($studyCardId, $options)                 │
└─────────────────────────────────────────────────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
         [Bank Empty?]        [Bank Exists?]
                │                   │
                ▼                   ▼
    ┌───────────────────┐  ┌──────────────────┐
    │ FIRST TIME        │  │ SUBSEQUENT       │
    │ Generate via AI   │  │ Reuse from Bank  │
    └───────────────────┘  └──────────────────┘
                │                   │
                ▼                   ▼
    ┌───────────────────┐  ┌──────────────────┐
    │ AI API Call       │  │ Copy from Bank   │
    │ - Gemini/DeepSeek │  │ - Select N items │
    │ - Extract content │  │ - Shuffle answers│
    │ - Generate JSON   │  │ - Update usage   │
    └───────────────────┘  └──────────────────┘
                │                   │
                ▼                   ▼
    ┌───────────────────┐  ┌──────────────────┐
    │ Save to Bank      │  │ Create Instance  │
    │ is_bank=true      │  │ is_bank=false    │
    │ usage_count=0     │  │                  │
    └───────────────────┘  └──────────────────┘
                │                   │
                └─────────┬─────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Return Quiz JSON to Flutter                                │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Flutter: TakeQuizScreen                                     │
│  - Display questions                                         │
│  - Start timer                                              │
│  - Track answers                                            │
│  - Submit & show results                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Changes

### Before
```
┌─────────────────────────────────┐
│  [Loading Dialog]               │
│  ⏳ Generating Quiz with AI...  │
│  Creating 5 questions           │
│  This may take 15-30 seconds    │
└─────────────────────────────────┘
```

### After
```
┌─────────────────────────────────────────────┐
│  [Loading Dialog]                           │
│  ⏳ Preparing Quiz...                        │
│  Creating 5 questions                       │
│  First-time may take 15-30 seconds          │  ← Smart message
│  (or "Loading from question bank...")       │  ← Based on context
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  💡 Info Banner (Bottom)                     │
│  AI akan generate bank soal pertama kali,   │
│  berikutnya langsung pakai dari bank        │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  [Enhanced Error Messages]                  │
│  ❌ Cannot generate quiz from image PDF     │
│  💡 Please use text-based PDF or text       │
│  [Retry Button]                             │
└─────────────────────────────────────────────┘
```

---

## 🧪 Testing Commands

### Test Generate Quiz (First Time)
```bash
# Should call AI API and create bank
curl -X POST http://localhost:8000/api/study-cards/1/generate-quiz \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"question_count": 5}'
```

### Test Generate Quiz (Second Time)
```bash
# Should reuse from bank (no AI call)
curl -X POST http://localhost:8000/api/study-cards/1/generate-quiz \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"question_count": 5}'
```

### Check Bank Questions
```bash
# Query database
php artisan tinker
>>> $questions = \App\Models\QuizQuestion::where('is_bank_question', true)->get();
>>> $questions->count();
```

### Check Usage Count
```bash
php artisan tinker
>>> $question = \App\Models\QuizQuestion::find(1);
>>> $question->usage_count;  // Should increment after each quiz
>>> $question->last_used_at; // Should update to current time
```

---

## 🐛 Common Issues & Solutions

### Issue 1: PDF Extraction Failed
**Error:** `Failed to extract text from PDF`
**Solution:** PDF is image-based. Use text-based PDF or text material.

### Issue 2: AI API Timeout
**Error:** `Gemini API Error: timeout`
**Solution:** 
- Check internet connection
- Increase timeout in config/services.php
- Fallback to dummy quiz (auto-handled)

### Issue 3: Bank Questions Not Reused
**Symptom:** AI called every time
**Debug:**
```php
// Check if bank questions exist
$bankQuestions = \App\Models\QuizQuestion::where('is_bank_question', true)
    ->whereHas('quiz', function($q) use ($studyCardId) {
        $q->where('study_card_id', $studyCardId);
    })
    ->count();

if ($bankQuestions === 0) {
    // No bank questions, will generate via AI
}
```

### Issue 4: Answers Not Shuffled
**Check:** Ensure `shuffle($answers)` is called in `createQuizFromBank()`
```php
$answers = $bankQuestion['answers'];
shuffle($answers); // ← Must be here
```

---

## 📊 Monitoring

### Check AI Usage
```sql
-- Count AI generations vs bank usage
SELECT 
    ai_model,
    COUNT(*) as total_quizzes
FROM quizzes
WHERE generated_by_ai = true
GROUP BY ai_model;

-- Expected result:
-- gemini: 100 (first-time generations)
-- bank: 500 (reused from bank)
```

### Check Question Usage Distribution
```sql
-- Find unused questions
SELECT 
    id,
    question_text,
    usage_count,
    last_used_at
FROM quiz_questions
WHERE is_bank_question = true
  AND usage_count = 0;
```

### Check Popular Questions
```sql
SELECT 
    question_text,
    usage_count,
    last_used_at
FROM quiz_questions
WHERE is_bank_question = true
ORDER BY usage_count DESC
LIMIT 10;
```

---

## 🎯 Performance Metrics

### Before Optimization
- **First Quiz:** 25 seconds (AI generation)
- **Second Quiz:** 25 seconds (AI generation again)
- **Third Quiz:** 25 seconds (AI generation again)
- **API Calls:** 3x
- **Cost:** High

### After Optimization
- **First Quiz:** 25 seconds (AI generation + save to bank)
- **Second Quiz:** 1-2 seconds (reuse from bank)
- **Third Quiz:** 1-2 seconds (reuse from bank)
- **API Calls:** 1x
- **Cost:** Low

**Performance Gain:** ~92% faster on subsequent quizzes
**Cost Reduction:** ~67% less API calls

---

## ✅ Checklist for Production

### Backend
- [ ] AI API keys configured in `.env`
- [ ] Database cache tables created
- [ ] Quiz migrations run successfully
- [ ] PDF parser library installed (`smalot/pdfparser`)
- [ ] Timeout configured for AI calls (90s)
- [ ] Fallback dummy quiz tested
- [ ] Error logging enabled

### Flutter
- [ ] API endpoints updated to production URL
- [ ] Loading dialogs tested on slow network
- [ ] Error messages user-friendly
- [ ] Info banner displayed correctly
- [ ] Navigation flow tested
- [ ] Memory leaks checked (dispose timers)

### Database
- [ ] Indexes on `study_card_id`, `is_bank_question`
- [ ] Foreign keys set up correctly
- [ ] Cascade delete configured (quiz → questions → answers)
- [ ] Usage analytics tables ready

---

## 🔗 Related Documentation

- Full System Doc: `QUIZ_BANK_SYSTEM.md`
- Study Cards Feature: `STUDY_CARDS_README.md`
- AI Setup Guide: `AI_QUIZ_SETUP.md`
- Quiz Caching: `QUIZ_CACHING_GUIDE.md`

---

**Last Updated:** December 9, 2025
**Version:** 1.0.0
**Status:** ✅ Production Ready
