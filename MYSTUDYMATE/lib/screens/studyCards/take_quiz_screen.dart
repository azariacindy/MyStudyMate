import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/study_card_model.dart';
import 'quiz_result_screen.dart';

class TakeQuizScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final StudyCard studyCard;

  const TakeQuizScreen({
    super.key,
    required this.quizData,
    required this.studyCard,
  });

  @override
  State<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends State<TakeQuizScreen> {
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {}; // questionIndex -> answerIndex
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isSubmitting = false;

  List<dynamic> get _questions => widget.quizData['questions'] ?? [];
  
  dynamic get _currentQuestion => _questions[_currentQuestionIndex];
  
  bool get _isLastQuestion => _currentQuestionIndex == _questions.length - 1;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  Future<void> _submitQuiz() async {
    // Check if all questions answered
    if (_userAnswers.length < _questions.length) {
      final unanswered = _questions.length - _userAnswers.length;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Incomplete Quiz'),
          content: Text(
            'You have $unanswered unanswered question(s). Do you want to submit anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
              child: const Text('Continue'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);
    _timer?.cancel();

    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (!_userAnswers.containsKey(i)) continue;
      
      final question = _questions[i];
      final answers = question['answers'] as List<dynamic>;
      final userAnswerIndex = _userAnswers[i]!;
      
      if (userAnswerIndex < answers.length &&
          answers[userAnswerIndex]['is_correct'] == true) {
        correctAnswers++;
      }
    }

    final score = (correctAnswers / _questions.length * 100).round();

    // Navigate to result screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            studyCard: widget.studyCard,
            quizData: widget.quizData,
            userAnswers: _userAnswers,
            correctAnswers: correctAnswers,
            totalQuestions: _questions.length,
            score: score,
            timeElapsed: _secondsElapsed,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    final answers = _currentQuestion['answers'] as List<dynamic>;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text('Your progress will be lost if you exit now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        
        if (confirm == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: SafeArea(
          child: Column(
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 34, 3, 107),
                      Color.fromARGB(255, 89, 147, 240),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Exit Quiz?'),
                            content: const Text('Your progress will be lost if you exit now.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                                child: const Text('Stay'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Exit'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Text(
                        'Quiz - ${widget.studyCard.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_secondsElapsed),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Body content
              Expanded(
                child: Column(
                  children: [
                    // Progress Bar
                    Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${_userAnswers.length}/${_questions.length} answered',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF3B82F6),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),

                    // Question and Answers
                    Expanded(
                      child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _currentQuestion['question_text'] ?? 'No question',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Answer Options
                    ...List.generate(answers.length, (index) {
                      final answer = answers[index];
                      final isSelected = _userAnswers[_currentQuestionIndex] == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectAnswer(index),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF3B82F6).withOpacity(0.1)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF3B82F6)
                                      : Colors.grey[300]!,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF3B82F6)
                                          : Colors.grey[200],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index), // A, B, C, D
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      answer['answer_text'] ?? '',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isSelected
                                            ? const Color(0xFF3B82F6)
                                            : Colors.grey[800],
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF3B82F6),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

                    // Navigation Buttons
                    Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentQuestionIndex > 0) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _previousQuestion,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B82F6),
                            side: const BorderSide(color: Color(0xFF3B82F6)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: _currentQuestionIndex > 0 ? 1 : 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : (_isLastQuestion ? _submitQuiz : _nextQuestion),
                        icon: Icon(
                          _isLastQuestion ? Icons.check : Icons.arrow_forward,
                        ),
                        label: Text(
                          _isLastQuestion ? 'Submit' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
