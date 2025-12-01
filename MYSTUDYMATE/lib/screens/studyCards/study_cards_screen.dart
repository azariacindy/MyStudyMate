import 'package:flutter/material.dart';
import '../../models/study_card_model.dart';
import '../../services/study_card_service.dart';
import 'create_study_card_screen.dart';
import 'take_quiz_screen.dart';

class StudyCardsScreen extends StatefulWidget {
  const StudyCardsScreen({super.key});

  @override
  State<StudyCardsScreen> createState() => _StudyCardsScreenState();
}

class _StudyCardsScreenState extends State<StudyCardsScreen> {
  final StudyCardService _service = StudyCardService();
  late Future<List<StudyCard>> _studyCardsFuture;
  bool _isGeneratingQuiz = false;

  @override
  void initState() {
    super.initState();
    _loadStudyCards();
  }

  void _loadStudyCards() {
    setState(() {
      _studyCardsFuture = _service.getStudyCards();
    });
  }

  Future<void> _generateQuiz(StudyCard card) async {
    setState(() => _isGeneratingQuiz = true);
    
    try {
      final quiz = await _service.generateQuiz(
        studyCardId: card.id,
        questionCount: 5,
      );

      if (mounted) {
        setState(() => _isGeneratingQuiz = false);
        
        // Navigate to quiz screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TakeQuizScreen(
              quizId: quiz.id,
              studyCardTitle: card.title,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingQuiz = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate quiz: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1625),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1625),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<StudyCard>>(
        future: _studyCardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStudyCards,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final studyCards = snapshot.data ?? [];

          if (studyCards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No study cards yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first study card to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadStudyCards(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with Tabs
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'math exam',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tabs
                        Row(
                          children: [
                            _buildTab('Material', true),
                            const SizedBox(width: 12),
                            _buildTab('Study Plan', false),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // All topics dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2438),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.refresh, color: Colors.white54, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'All topics',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 20),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Section Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Flashcards',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[300],
                          ),
                        ),
                        Text(
                          '${studyCards.length}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Horizontal Scrollable Cards
                  SizedBox(
                    height: 320,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: studyCards.length,
                      itemBuilder: (context, index) {
                        final card = studyCards[index];
                        return _buildFlashcardStyle(card, index);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStudyCardScreen(),
            ),
          );

          if (result == true) {
            _loadStudyCards();
          }
        },
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildFlashcardStyle(StudyCard card, int index) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(
        right: 16,
        left: index == 0 ? 0 : 0,
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8B5CF6),
                const Color(0xFF7C3AED),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                          onTap: () => Future.delayed(
                            Duration.zero,
                            () => _showDeleteConfirmation(card),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  card.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  children: [
                    _buildWhiteStatChip(Icons.quiz, '${card.quizCount} quizzes'),
                    const SizedBox(width: 8),
                    _buildWhiteStatChip(Icons.text_fields, '${card.wordCount} words'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Notes preview
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      card.notes.length > 80
                          ? '${card.notes.substring(0, 80)}...'
                          : card.notes,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Generate Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingQuiz ? null : () => _generateQuiz(card),
                    icon: _isGeneratingQuiz
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_isGeneratingQuiz ? 'Generating...' : 'Learn 5 Questions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWhiteStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2D2438) : Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isActive ? Colors.transparent : const Color(0xFF3D3449),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          color: isActive ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }



  void _showDeleteConfirmation(StudyCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Card'),
        content: Text('Are you sure you want to delete "${card.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                await _service.deleteStudyCard(card.id);
                _loadStudyCards();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Study card deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
