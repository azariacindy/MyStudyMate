# Quiz Caching System - Documentation

## 📋 Overview

Sistem quiz sekarang **menyimpan soal di database** dan tidak perlu generate ulang setiap kali user ingin belajar. Quiz akan di-generate sekali dan bisa digunakan berulang kali.

## 🎯 Cara Kerja

### 1️⃣ **Generate/Get Quiz (Smart Endpoint)**

```http
POST /api/study-cards/{id}/generate-quiz
```

**Behavior:**
- ✅ **Jika quiz sudah ada**: Return quiz yang sudah disimpan (instant, no API call to Gemini)
- ✅ **Jika quiz belum ada**: Generate quiz baru menggunakan AI dan simpan ke database
- ✅ **Force regenerate**: Tambahkan parameter `force_regenerate=true` untuk generate ulang

**Request Body:**
```json
{
  "question_count": 10,           // Optional, default: 10 soal
  "duration_minutes": 30,         // Optional, default: 30 menit
  "force_regenerate": false       // Optional, default: false
}
```

**Response (Quiz sudah ada):**
```json
{
  "success": true,
  "message": "Quiz already exists. Use force_regenerate=true to generate new quiz.",
  "from_cache": true,
  "data": {
    "id": 1,
    "title": "Matematika Dasar - Quiz",
    "total_questions": 10,
    "study_card_id": 5,
    "created_at": "2025-12-08T10:30:00Z",
    "questions": [
      {
        "id": 1,
        "question_text": "Berapa hasil dari 2 + 2?",
        "question_type": "multiple_choice",
        "points": 10,
        "explanation": "2 + 2 = 4",
        "answers": [
          {"id": 1, "answer_text": "4", "is_correct": true},
          {"id": 2, "answer_text": "3", "is_correct": false},
          {"id": 3, "answer_text": "5", "is_correct": false},
          {"id": 4, "answer_text": "6", "is_correct": false}
        ]
      }
    ]
  }
}
```

**Response (Quiz baru di-generate):**
```json
{
  "success": true,
  "message": "Quiz generated successfully",
  "from_cache": false,
  "data": {
    // ... sama seperti di atas
  }
}
```

---

### 2️⃣ **Get List of Quizzes**

Untuk melihat semua quiz yang sudah dibuat untuk study card tertentu:

```http
GET /api/study-cards/{id}/quizzes
```

**Response:**
```json
{
  "success": true,
  "message": "Quizzes retrieved successfully",
  "count": 2,
  "data": [
    {
      "id": 1,
      "title": "Matematika Dasar - Quiz",
      "description": "Quiz generated automatically by AI from text material",
      "total_questions": 10,
      "duration_minutes": 30,
      "generated_by_ai": true,
      "ai_model": "gemini-2.0-flash-exp",
      "created_at": "2025-12-08T10:30:00Z",
      "updated_at": "2025-12-08T10:30:00Z"
    },
    {
      "id": 2,
      "title": "Matematika Dasar - Quiz",
      "description": "Quiz generated automatically by AI from text material",
      "total_questions": 15,
      "duration_minutes": 45,
      "generated_by_ai": true,
      "ai_model": "gemini-2.0-flash-exp",
      "created_at": "2025-12-08T11:00:00Z",
      "updated_at": "2025-12-08T11:00:00Z"
    }
  ]
}
```

---

### 3️⃣ **Get Quiz Detail**

Untuk mengambil detail quiz tertentu dengan semua soal dan jawaban:

```http
GET /api/quizzes/{quiz_id}
```

**Response:**
```json
{
  "success": true,
  "message": "Quiz retrieved successfully",
  "data": {
    "id": 1,
    "title": "Matematika Dasar - Quiz",
    "description": "Quiz generated automatically by AI from text material",
    "total_questions": 10,
    "duration_minutes": 30,
    "study_card_id": 5,
    "shuffle_questions": true,
    "shuffle_answers": true,
    "show_correct_answers": true,
    "generated_by_ai": true,
    "ai_model": "gemini-2.0-flash-exp",
    "created_at": "2025-12-08T10:30:00Z",
    "questions": [
      // ... array of questions with answers
    ]
  }
}
```

---

## 🔄 Use Cases

### ✅ **Use Case 1: First Time Generate Quiz**

User belum pernah generate quiz untuk study card ini.

```dart
// Flutter code
final response = await dio.post('/api/study-cards/5/generate-quiz', data: {
  'question_count': 10,
  'duration_minutes': 30,
});

// Response: from_cache = false (quiz baru dibuat)
if (response.data['from_cache'] == false) {
  print('Quiz baru berhasil dibuat!');
}
```

**Backend:** Generate quiz baru menggunakan Gemini AI → Simpan ke database → Return quiz

---

### ✅ **Use Case 2: User Kembali Belajar Quiz**

User sudah pernah generate quiz, sekarang mau belajar lagi.

```dart
// Flutter code (request yang sama)
final response = await dio.post('/api/study-cards/5/generate-quiz', data: {
  'question_count': 10,
});

// Response: from_cache = true (quiz dari database)
if (response.data['from_cache'] == true) {
  print('Menggunakan quiz yang sudah ada');
}
```

**Backend:** Cek database → Quiz sudah ada → Return quiz langsung (**instant, no AI call**)

---

### ✅ **Use Case 3: User Ingin Generate Quiz Baru**

User ingin soal baru yang berbeda.

```dart
// Flutter code
final response = await dio.post('/api/study-cards/5/generate-quiz', data: {
  'question_count': 15,           // Bisa ubah jumlah soal
  'duration_minutes': 45,
  'force_regenerate': true,       // 🔑 Force generate ulang
});

// Response: from_cache = false (quiz baru dibuat)
```

**Backend:** Generate quiz baru menggunakan AI → Simpan ke database → Return quiz baru

---

## 🎨 Flutter UI Recommendations

### **Study Card Detail Screen**

```dart
// Tampilkan status quiz
Widget _buildQuizSection() {
  return FutureBuilder(
    future: _loadQuizzes(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final quizzes = snapshot.data as List;
        
        if (quizzes.isEmpty) {
          return ElevatedButton(
            onPressed: _generateQuiz,
            child: Text('Generate Quiz (10 soal)'),
          );
        } else {
          return Column(
            children: [
              Text('${quizzes.length} Quiz tersedia'),
              ElevatedButton(
                onPressed: () => _startQuiz(quizzes.first),
                child: Text('Mulai Quiz'),
              ),
              TextButton(
                onPressed: _generateNewQuiz,
                child: Text('Generate Quiz Baru'),
              ),
            ],
          );
        }
      }
      return CircularProgressIndicator();
    },
  );
}

// Function untuk generate quiz
Future<void> _generateQuiz() async {
  setState(() => _isLoading = true);
  
  try {
    final response = await dio.post(
      '/api/study-cards/$studyCardId/generate-quiz',
      data: {'question_count': 10},
    );
    
    if (response.data['from_cache'] == true) {
      _showMessage('Quiz sudah tersedia!');
    } else {
      _showMessage('Quiz berhasil dibuat!');
    }
    
    // Navigate to quiz screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(quiz: response.data['data']),
      ),
    );
  } catch (e) {
    _showError('Gagal generate quiz: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}

// Function untuk generate quiz baru (force regenerate)
Future<void> _generateNewQuiz() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Generate Quiz Baru?'),
      content: Text('Quiz yang lama akan tetap tersimpan. Yakin ingin generate quiz baru?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Ya, Generate'),
        ),
      ],
    ),
  );
  
  if (confirm == true) {
    setState(() => _isLoading = true);
    
    try {
      final response = await dio.post(
        '/api/study-cards/$studyCardId/generate-quiz',
        data: {
          'question_count': 10,
          'force_regenerate': true, // 🔑 Force regenerate
        },
      );
      
      _showMessage('Quiz baru berhasil dibuat!');
      
      // Navigate to quiz screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(quiz: response.data['data']),
        ),
      );
    } catch (e) {
      _showError('Gagal generate quiz: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## 📊 Database Schema

### **quizzes table**
```sql
id                   BIGINT PRIMARY KEY
study_card_id        BIGINT (FK to study_cards)
title                VARCHAR
description          TEXT
total_questions      INTEGER
duration_minutes     INTEGER
generated_by_ai      BOOLEAN
ai_model             VARCHAR
shuffle_questions    BOOLEAN
shuffle_answers      BOOLEAN
show_correct_answers BOOLEAN
created_at           TIMESTAMP
updated_at           TIMESTAMP
deleted_at           TIMESTAMP (soft delete)
```

### **quiz_questions table**
```sql
id              BIGINT PRIMARY KEY
quiz_id         BIGINT (FK to quizzes)
question_text   TEXT
question_type   VARCHAR (multiple_choice, true_false, etc)
order_number    INTEGER
points          INTEGER
explanation     TEXT
created_at      TIMESTAMP
```

### **quiz_answers table**
```sql
id             BIGINT PRIMARY KEY
question_id    BIGINT (FK to quiz_questions)
answer_text    TEXT
is_correct     BOOLEAN
order_number   INTEGER
created_at     TIMESTAMP
```

---

## 🚀 Benefits

1. ✅ **Instant Load**: Quiz yang sudah ada langsung di-load dari database (tidak perlu API call ke Gemini)
2. ✅ **Cost Efficient**: Hemat biaya Gemini API karena tidak generate berulang kali
3. ✅ **Consistent Experience**: User bisa belajar quiz yang sama berkali-kali
4. ✅ **Multiple Quizzes**: Bisa buat beberapa quiz dengan jumlah soal berbeda
5. ✅ **Force Regenerate**: User bisa generate quiz baru kalau mau soal yang berbeda

---

## ⚠️ Important Notes

1. **First Generate**: First time generate akan lambat (15-30 detik) karena call Gemini API
2. **Subsequent Loads**: Load quiz yang sudah ada sangat cepat (< 1 detik) karena dari database
3. **Multiple Quizzes**: Satu study card bisa punya banyak quiz dengan konfigurasi berbeda
4. **Soft Delete**: Quiz yang dihapus tidak hilang permanen (menggunakan soft delete)

---

## 🧪 Testing Checklist

- [ ] Generate quiz pertama kali (should be slow, from_cache=false)
- [ ] Load quiz yang sudah ada (should be instant, from_cache=true)
- [ ] Force regenerate quiz baru (from_cache=false)
- [ ] Get list of quizzes untuk study card
- [ ] Get detail quiz by ID
- [ ] Pastikan ownership check berfungsi (user A tidak bisa akses quiz user B)
