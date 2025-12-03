import 'package:flutter/material.dart';
import '../../models/study_card_model.dart';

class QuizReviewScreen extends StatefulWidget {
  final StudyCard studyCard;
  final Map<String, dynamic> quizData;
  final Map<int, int> userAnswers;

  const QuizReviewScreen({
    super.key,
    required this.studyCard,
    required this.quizData,
    required this.userAnswers,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  int _currentQuestionIndex = 0;
  final PageController _pageController = PageController();

  List<dynamic> get _questions => widget.quizData['questions'] ?? [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Review Answers'),
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No questions available'),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushNamedAndRemoveUntil('/study_cards', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: const Text('Review Answers'),
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/study_cards', (route) => false);
            },
          ),
          actions: [
            IconButton(
              onPressed: () => _showQuestionNavigator(context),
              icon: const Icon(Icons.list),
              tooltip: 'Jump to question',
            ),
          ],
        ),
      body: Column(
        children: [
          // Progress indicator
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    _buildResultBadge(),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          // Question content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentQuestionIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildQuestionReview(index);
              },
            ),
          ),
          // Navigation buttons
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _currentQuestionIndex > 0
                        ? () => _goToQuestion(_currentQuestionIndex - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: _currentQuestionIndex > 0
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey,
                      ),
                      foregroundColor: _currentQuestionIndex > 0
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentQuestionIndex < _questions.length - 1
                        ? () => _goToQuestion(_currentQuestionIndex + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentQuestionIndex < _questions.length - 1
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey,
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
    );
  }

  Widget _buildResultBadge() {
    final question = _questions[_currentQuestionIndex];
    final answers = question['answers'] as List<dynamic>? ?? [];
    final userAnswerIndex = widget.userAnswers[_currentQuestionIndex];
    
    bool isCorrect = false;
    if (userAnswerIndex != null && userAnswerIndex < answers.length) {
      isCorrect = answers[userAnswerIndex]['is_correct'] == true;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 6),
          Text(
            isCorrect ? 'Correct' : 'Incorrect',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(int questionIndex) {
    final question = _questions[questionIndex];
    final answers = question['answers'] as List<dynamic>? ?? [];
    final userAnswerIndex = widget.userAnswers[questionIndex];
    final questionText = question['question_text'] ?? 'No question text';
    final explanation = question['explanation'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
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
              questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Answers
          const Text(
            'Answer Options',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(answers.length, (index) {
            return _buildAnswerOption(
              index: index,
              answer: answers[index],
              userAnswerIndex: userAnswerIndex,
              questionIndex: questionIndex,
            );
          }),
          // Explanation
          if (explanation != null && explanation.toString().isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF3B82F6),
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    explanation.toString(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption({
    required int index,
    required Map<String, dynamic> answer,
    required int? userAnswerIndex,
    required int questionIndex,
  }) {
    final answerText = answer['answer_text'] ?? '';
    final isCorrect = answer['is_correct'] == true;
    final isUserAnswer = userAnswerIndex == index;

    Color borderColor;
    Color backgroundColor;
    IconData? icon;
    Color? iconColor;

    if (isCorrect) {
      // Correct answer - always show in green
      borderColor = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isUserAnswer) {
      // User selected wrong answer - show in red
      borderColor = Colors.red;
      backgroundColor = Colors.red.withOpacity(0.1);
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else {
      // Other wrong answers
      borderColor = Colors.grey[300]!;
      backgroundColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isCorrect || isUserAnswer ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCorrect || isUserAnswer
                ? borderColor.withOpacity(0.2)
                : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              String.fromCharCode(65 + index), // A, B, C, D
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCorrect || isUserAnswer ? borderColor : Colors.grey[700],
              ),
            ),
          ),
        ),
        title: Text(
          answerText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCorrect || isUserAnswer ? FontWeight.w600 : FontWeight.normal,
            color: const Color(0xFF1E293B),
          ),
        ),
        trailing: icon != null
            ? Icon(icon, color: iconColor, size: 28)
            : null,
      ),
    );
  }

  void _showQuestionNavigator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jump to Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final answers = question['answers'] as List<dynamic>? ?? [];
                  final userAnswerIndex = widget.userAnswers[index];
                  
                  bool isCorrect = false;
                  if (userAnswerIndex != null && userAnswerIndex < answers.length) {
                    isCorrect = answers[userAnswerIndex]['is_correct'] == true;
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      _goToQuestion(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _currentQuestionIndex == index
                            ? const Color(0xFF8B5CF6)
                            : isCorrect
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _currentQuestionIndex == index
                              ? const Color(0xFF8B5CF6)
                              : isCorrect
                                  ? Colors.green
                                  : Colors.red,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentQuestionIndex == index
                                ? Colors.white
                                : isCorrect
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
