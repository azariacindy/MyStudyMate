# Quiz Review Feature Documentation

## Overview
Fitur Review Answers memungkinkan user untuk melihat kembali jawaban mereka setelah menyelesaikan quiz, lengkap dengan:
- Jawaban yang benar
- Jawaban yang user pilih (jika salah)
- Penjelasan untuk setiap soal

## Screens

### 1. QuizReviewScreen
**Path:** `lib/screens/studyCards/quiz_review_screen.dart`

**Features:**
- **Page-based Navigation**: Swipe atau gunakan tombol Previous/Next untuk navigasi antar soal
- **Progress Indicator**: Menampilkan progress "Question X of Y" dengan linear progress bar
- **Result Badge**: Badge "Correct" (hijau) atau "Incorrect" (merah) di setiap soal
- **Answer Options dengan Color Coding**:
  - ✅ **Green border + check icon**: Jawaban yang benar
  - ❌ **Red border + cancel icon**: Jawaban salah yang dipilih user
  - ⚪ **Grey border**: Jawaban salah yang tidak dipilih
- **Explanation Section**: Box biru dengan icon lightbulb menampilkan penjelasan dari AI
- **Question Navigator**: Bottom sheet untuk jump ke soal tertentu (tap icon list di AppBar)

**Props:**
```dart
QuizReviewScreen({
  required StudyCard studyCard,
  required Map<String, dynamic> quizData,
  required Map<int, int> userAnswers,
})
```

**Navigation:**
- Dipanggil dari `QuizResultScreen` saat user tap tombol "Review Answers"
- User bisa navigate dengan:
  - Swipe left/right
  - Tombol Previous/Next
  - Jump to question (icon list di AppBar)

## UI Design

### Color Scheme
- **Primary Purple**: `#8B5CF6` - AppBar, buttons
- **Success Green**: `Colors.green` - Correct answers
- **Error Red**: `Colors.red` - Wrong answers
- **Info Blue**: `#3B82F6` - Explanation box
- **Background**: `#F8F9FE` - Screen background

### Answer Options Visual States

1. **Correct Answer (Always Shown)**
   - Green border (2px)
   - Green background tint (10% opacity)
   - Green check circle icon
   - Bold text

2. **User's Wrong Answer**
   - Red border (2px)
   - Red background tint (10% opacity)
   - Red cancel icon
   - Bold text

3. **Other Options**
   - Grey border (1px)
   - White background
   - No icon
   - Normal text

### Explanation Box
- Light blue background (`#F0F9FF`)
- Blue border (`#3B82F6`, 1.5px)
- Lightbulb icon
- Clear readable text with 1.6 line height

## Navigation Flow

```
QuizResultScreen
    |
    | [User taps "Review Answers"]
    v
QuizReviewScreen
    |
    | [User swipes/navigates through questions]
    | [User views correct answers + explanations]
    |
    | [User taps back button]
    v
QuizResultScreen
    |
    | [User taps "Back to Home"]
    v
Home Screen (popUntil first route)
```

## Question Navigator Modal

**Triggered by:** Icon list button di AppBar

**Features:**
- Grid view 5 kolom
- Setiap cell menampilkan nomor soal (1, 2, 3, ...)
- Color coding:
  - **Purple**: Soal yang sedang ditampilkan
  - **Green tint**: Soal yang dijawab benar
  - **Red tint**: Soal yang dijawab salah
- Tap cell untuk jump ke soal tersebut

## Data Structure

### quizData Structure
```dart
{
  'questions': [
    {
      'question_text': 'What is Laravel?',
      'question_type': 'multiple_choice',
      'points': 10,
      'explanation': 'Laravel is a PHP framework...',
      'answers': [
        {'answer_text': 'A PHP framework', 'is_correct': true},
        {'answer_text': 'A database', 'is_correct': false},
        {'answer_text': 'A programming language', 'is_correct': false},
        {'answer_text': 'An operating system', 'is_correct': false}
      ]
    },
    // ... more questions
  ]
}
```

### userAnswers Structure
```dart
{
  0: 2,  // Question 0: User selected answer index 2
  1: 0,  // Question 1: User selected answer index 0
  2: 1,  // Question 2: User selected answer index 1
  // ... more answers
}
```

## Key Features Implementation

### 1. Answer Validation Logic
```dart
bool isCorrect = false;
if (userAnswerIndex != null && userAnswerIndex < answers.length) {
  isCorrect = answers[userAnswerIndex]['is_correct'] == true;
}
```

### 2. Color Determination Logic
```dart
if (isCorrect) {
  // Show green - this is the correct answer
} else if (isUserAnswer) {
  // Show red - user selected this wrong answer
} else {
  // Show grey - other wrong options
}
```

### 3. PageView with Synced State
- PageController untuk swipe navigation
- setState untuk sync _currentQuestionIndex
- onPageChanged callback untuk update state

## Testing Checklist

- [ ] Review screen displays all questions correctly
- [ ] Correct answers shown in green with check icon
- [ ] User's wrong answers shown in red with cancel icon
- [ ] Explanation displays when available
- [ ] Previous/Next buttons work correctly
- [ ] Previous button disabled on first question
- [ ] Next button disabled on last question
- [ ] Swipe navigation works
- [ ] Question navigator modal works
- [ ] Jump to question works correctly
- [ ] Progress bar updates correctly
- [ ] Result badge shows correct status

## Future Enhancements

1. **Statistics per Question**: Show how many users answered correctly
2. **Bookmark Questions**: Allow users to bookmark difficult questions
3. **Share Results**: Share quiz results to social media
4. **Retry Wrong Questions**: Generate new quiz with only wrong questions
5. **Detailed Analytics**: Time spent per question, confidence level, etc.
