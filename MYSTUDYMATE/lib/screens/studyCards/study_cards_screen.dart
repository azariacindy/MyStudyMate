import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../models/study_card_model.dart';
import '../../services/study_card_service.dart';
import 'create_study_card_screen.dart';
import 'study_card_detail_screen.dart';

class StudyCardsScreen extends StatefulWidget {
  const StudyCardsScreen({super.key});

  @override
  State<StudyCardsScreen> createState() => _StudyCardsScreenState();
}

class _StudyCardsScreenState extends State<StudyCardsScreen> {
  final StudyCardService _service = StudyCardService();
  List<StudyCard> _studyCards = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoad();
  }

  Future<void> _checkAuthAndLoad() async {
    // Check if user is authenticated
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    
    print('DEBUG: Auth token exists: ${token != null}');
    print('DEBUG: Token: ${token?.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    if (token == null || token.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first to access study cards'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        // Navigate back or to login
        Navigator.pushReplacementNamed(context, '/signin');
      }
      return;
    }
    
    _loadStudyCards();
  }

  Future<void> _loadStudyCards() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final cards = await _service.getStudyCards();
      if (mounted) {
        setState(() {
          _studyCards = cards;
        });
      }
    } catch (e) {
      print('DEBUG: Error details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading study cards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateQuiz(StudyCard card) async {
    // Show dialog to select number of questions
    final questionCount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Quiz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generate quiz for "${card.title}"'),
            const SizedBox(height: 16),
            const Text('Number of questions:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [3, 5, 10].map((count) {
                return ChoiceChip(
                  label: Text('$count'),
                  selected: false,
                  onSelected: (_) => Navigator.pop(context, count),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (questionCount == null) return;

    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating quiz with AI...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    try {
      final quizData = await _service.generateQuiz(card.id, questionCount: questionCount);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quiz generated successfully with $questionCount questions!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // TODO: Navigate to quiz screen with quizData
        print('Quiz generated: ${quizData['id']}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _deleteStudyCard(StudyCard card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study Card'),
        content: Text('Are you sure you want to delete "${card.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteStudyCard(card.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Study card deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadStudyCards();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting study card: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Study Cards'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _studyCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Study Cards Yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create your first study card to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
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
                        icon: const Icon(Icons.add),
                        label: const Text('Create Study Card'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudyCards,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _studyCards.length,
                    itemBuilder: (context, index) {
                      final card = _studyCards[index];
                      return _buildStudyCardItem(card);
                    },
                  ),
                ),
      floatingActionButton: _studyCards.isNotEmpty
          ? FloatingActionButton.extended(
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
              icon: const Icon(Icons.add),
              label: const Text('New Card'),
            )
          : null,
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildStudyCardItem(StudyCard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudyCardDetailScreen(studyCard: card),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      card.isFileType ? Icons.insert_drive_file : Icons.text_fields,
                      color: const Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(card.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteStudyCard(card);
                      } else if (value == 'generate_quiz') {
                        _generateQuiz(card);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'generate_quiz',
                        child: Row(
                          children: [
                            Icon(Icons.quiz, color: Color(0xFF8B5CF6)),
                            SizedBox(width: 8),
                            Text('Generate Quiz'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (card.description != null && card.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  card.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (card.isFileType && card.materialFileName != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.attachment,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.materialFileName!,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.fileSizeFormatted != null)
                        Text(
                          card.fileSizeFormatted!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generateQuiz(card),
                      icon: const Icon(Icons.quiz, size: 18),
                      label: const Text('Generate Quiz'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: const BorderSide(color: Color(0xFF8B5CF6)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: View quiz history
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
