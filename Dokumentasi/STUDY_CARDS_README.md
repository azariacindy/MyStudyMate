# Study Cards - AI Quiz Generation Feature

## Overview
Study Cards adalah fitur pembelajaran interaktif yang menggunakan AI untuk menghasilkan quiz otomatis dari materi yang diinput oleh user. Fitur ini membantu mahasiswa belajar lebih efektif dengan membuat latihan soal berdasarkan catatan mereka.

## Features
- ✅ **Create Study Cards**: Input judul dan materi pembelajaran (minimum 50 karakter)
- ✅ **AI Quiz Generation**: Sistem otomatis membuat 5-20 soal pilihan ganda menggunakan AI (OpenAI atau Gemini)
- ✅ **Take Quiz**: Mengerjakan quiz dengan antarmuka yang user-friendly
- ✅ **Timer**: Melacak waktu yang dihabiskan saat mengerjakan quiz
- ✅ **Auto Grading**: Sistem otomatis menghitung score dan grade (A-F)
- ✅ **Detailed Review**: Melihat jawaban yang benar dan penjelasan untuk setiap soal
- ✅ **Quiz History**: Menyimpan riwayat attempt beserta score
- ✅ **Best Score Tracking**: Melacak score terbaik untuk setiap quiz

## Tech Stack

### Backend (Laravel 10.x)
- **Database**: PostgreSQL (Supabase)
- **AI Integration**: 
  - OpenAI API (gpt-3.5-turbo) - Default
  - Google Gemini API - Alternative
- **API Routes**: 7 endpoints untuk CRUD study cards dan quiz operations

### Frontend (Flutter)
- **HTTP Client**: Dio (timeout 30s untuk AI generation)
- **UI**: Material Design dengan purple theme (#8B5CF6)
- **State Management**: StatefulWidget dengan FutureBuilder

## Database Schema

### study_cards
```sql
- id (primary key)
- user_id (foreign key)
- title (string, max 255)
- notes (text)
- quiz_count (integer, default 0)
- created_at
- updated_at
```

### quizzes
```sql
- id (primary key)
- study_card_id (foreign key)
- user_id (foreign key)
- questions (JSON array)
- total_questions (integer)
- times_attempted (integer, default 0)
- best_score (integer, nullable)
- created_at
- updated_at
```

### quiz_attempts
```sql
- id (primary key)
- quiz_id (foreign key)
- user_id (foreign key)
- user_answers (JSON array)
- score (integer)
- total_questions (integer)
- correct_answers (integer)
- time_spent (integer, in seconds)
- created_at
- updated_at
```

## API Endpoints

### Study Cards
1. **GET** `/api/study-cards` - Get all study cards for authenticated user
2. **POST** `/api/study-cards` - Create new study card
   ```json
   {
     "title": "Introduction to Flutter",
     "notes": "Flutter is an open-source UI software development kit..."
   }
   ```
3. **DELETE** `/api/study-cards/{id}` - Delete study card

### Quiz Operations
4. **POST** `/api/study-cards/{id}/generate-quiz` - Generate quiz using AI
   ```json
   {
     "question_count": 10
   }
   ```
   Response includes quiz_id and questions array

5. **GET** `/api/quizzes/{id}` - Get quiz details and questions

6. **POST** `/api/quizzes/{id}/submit` - Submit quiz answers
   ```json
   {
     "answers": [0, 2, 1, 3, 0],
     "time_spent": 180
   }
   ```
   Response includes score, percentage, grade, and detailed results

7. **GET** `/api/quizzes/{id}/attempts` - Get quiz attempt history

## AI Quiz Generation

### Question Format
```json
{
  "question": "What is Flutter?",
  "options": [
    "A programming language",
    "A UI development framework",
    "A database system",
    "An operating system"
  ],
  "correct_answer": 1,
  "explanation": "Flutter is an open-source UI software development kit created by Google..."
}
```

### AI Providers

#### Option 1: OpenAI (Default)
```env
AI_PROVIDER=openai
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_MODEL=gpt-3.5-turbo
```

#### Option 2: Google Gemini
```env
AI_PROVIDER=gemini
GEMINI_API_KEY=your-gemini-api-key-here
```

### Fallback Mechanism
Jika AI service gagal, sistem akan generate quiz fallback dengan soal-soal dasar berdasarkan materi yang diinput.

## Setup Instructions

### Backend Setup

1. **Configure Environment**
   ```bash
   cd PBLMobile
   cp .env.example .env
   ```

2. **Add AI Configuration to .env**
   ```env
   AI_PROVIDER=openai
   OPENAI_API_KEY=your-actual-api-key-here
   OPENAI_MODEL=gpt-3.5-turbo
   ```

3. **Run Migrations**
   ```bash
   php artisan migrate
   ```

4. **Start Laravel Server**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

### Flutter Setup

1. **Install Dependencies**
   ```bash
   cd MYSTUDYMATE
   flutter pub get
   ```

2. **Configure API Base URL**
   Update `lib/config/api_constant.dart` dengan IP address Laravel server:
   ```dart
   // For Android emulator
   return 'http://10.107.198.235:8000';
   ```

3. **Run Flutter App**
   ```bash
   flutter run
   ```

## Usage Flow

### 1. Create Study Card
- User navigates to Study Cards screen
- Tap FAB (+) button
- Fill in title and study material (min 50 chars)
- System validates and saves

### 2. Generate Quiz
- From study cards list, tap "Generate Quiz" button
- System calls AI service to generate questions
- Loading indicator shows generation progress (30s timeout)
- Quiz created and saved to database

### 3. Take Quiz
- Tap on generated quiz or "Generate Quiz" button
- Answer questions one by one
- Timer tracks time spent
- Submit all answers when done

### 4. View Results
- See score, percentage, and grade
- Review each question with:
  - User's answer (marked red if wrong)
  - Correct answer (marked green)
  - Explanation for better understanding
- Option to retry or go back to study cards

## Grading System
- **A**: 90-100%
- **B**: 80-89%
- **C**: 70-79%
- **D**: 60-69%
- **F**: Below 60%

**Passing Score**: 60% or higher

## UI Screens

### 1. StudyCardsScreen
- List of all study cards with stats (quiz count, word count)
- Pull-to-refresh support
- Generate quiz and delete actions
- Empty state handling

### 2. CreateStudyCardScreen
- Title input field
- Notes input field (multi-line, min 50 chars)
- Real-time word counter
- Form validation
- AI generation info card

### 3. TakeQuizScreen
- Question display with progress bar
- Multiple choice options (A, B, C, D)
- Timer display in AppBar
- Previous/Next navigation
- Submit confirmation dialog
- Exit confirmation (prevents accidental exits)

### 4. QuizResultScreen
- Score card with gradient background (green for pass, red for fail)
- Score statistics (score, percentage, grade)
- Detailed question review with color-coded answers
- Explanation for each question
- Retry and back navigation buttons

## Error Handling
- Network errors with retry option
- Validation errors with clear messages
- AI generation failures with fallback quiz
- Loading states for all async operations
- Confirmation dialogs for destructive actions

## Performance Considerations
- 30 second timeout for AI quiz generation
- Efficient JSON parsing with try-catch
- Optimized list rendering with ListView.builder
- Minimal API calls with proper caching
- Graceful error handling

## Future Enhancements
- [ ] Difficulty level selection (easy, medium, hard)
- [ ] Multiple quiz formats (true/false, fill-in-blank)
- [ ] Share study cards with friends
- [ ] Export quiz results as PDF
- [ ] Study card categories/tags
- [ ] Quiz leaderboard
- [ ] Offline mode support
- [ ] Push notifications for quiz reminders

## Testing Checklist
- [ ] Create study card with valid input
- [ ] Validation for title and notes
- [ ] AI quiz generation with real API key
- [ ] Quiz submission and scoring
- [ ] Answer review with correct highlighting
- [ ] Delete study card
- [ ] Quiz attempt history
- [ ] Timer accuracy
- [ ] Error scenarios (network, API failures)
- [ ] UI responsiveness on different screen sizes

## Troubleshooting

### AI Generation Fails
1. Check if API key is correctly configured in `.env`
2. Verify API key has sufficient credits
3. Check network connectivity
4. Review Laravel logs: `storage/logs/laravel.log`

### Flutter Connection Issues
1. Verify Laravel server is running
2. Check IP address in `api_constant.dart`
3. Ensure Android emulator can reach host machine
4. Test with Postman first

### Database Issues
1. Run migrations: `php artisan migrate:fresh`
2. Check database connection in `.env`
3. Verify Supabase credentials

## Credits
- **Backend**: Laravel 10.x with OpenAI/Gemini integration
- **Frontend**: Flutter with Material Design
- **AI**: OpenAI GPT-3.5-turbo / Google Gemini
- **Database**: PostgreSQL (Supabase)

---

**Last Updated**: January 2025
**Version**: 1.0.0
