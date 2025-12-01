import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/assignment_model.dart';
import '../../services/schedule_service.dart';
import '../../utils/app_colors.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({super.key});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Assignment> _assignments = [];
  Map<String, dynamic>? _weeklyProgress;
  bool _isLoading = false;
  String _selectedFilter = 'all'; // all, pending, done
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
    _loadWeeklyProgress();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    try {
      final result = await _scheduleService.getAssignments(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      );
      
      if (result['success']) {
        setState(() {
          _assignments = (result['data'] as List)
              .map((json) => Assignment.fromJson(json))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading assignments: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWeeklyProgress() async {
    try {
      final result = await _scheduleService.getWeeklyProgress();
      if (result['success']) {
        setState(() => _weeklyProgress = result['data']);
      }
    } catch (e) {
      debugPrint('Error loading weekly progress: $e');
    }
  }

  Future<void> _markAsDone(int scheduleId, bool isDone) async {
    try {
      final result = await _scheduleService.markAsDone(scheduleId.toString());
      if (result['success']) {
        await _loadAssignments();
        await _loadWeeklyProgress();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment marked as done!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text);
    _loadAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Weekly Progress Card
          if (_weeklyProgress != null) _buildWeeklyProgressCard(),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search assignments...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (_) => _onSearchChanged(),
            ),
          ),
          
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Done', 'done'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Assignment List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _assignments.isEmpty
                    ? const Center(
                        child: Text(
                          'No assignments found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadAssignments();
                          await _loadWeeklyProgress();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _assignments.length,
                          itemBuilder: (context, index) {
                            return _buildAssignmentCard(_assignments[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    final total = _weeklyProgress!['total'] ?? 0;
    final completed = _weeklyProgress!['completed'] ?? 0;
    final percentage = _weeklyProgress!['percentage'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Progress Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed of $total completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                if (_weeklyProgress!['pending'] > 0)
                  Text(
                    '${_weeklyProgress!['pending']} pending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
        _loadAssignments();
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    final deadline = assignment.deadline;
    final isOverdue = assignment.isOverdue;
    final isDueToday = assignment.isDueToday;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to edit assignment screen
          // For now, show a dialog or create EditAssignmentScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edit assignment feature coming soon')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: assignment.isDone,
                    onChanged: assignment.isDone
                        ? null
                        : (value) {
                            if (value == true) {
                              _markAsDone(assignment.id, value!);
                            }
                          },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  // Title
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: assignment.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: assignment.isDone
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  // Status Badge
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Overdue',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isDueToday && !assignment.isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Due Today',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (assignment.description != null && assignment.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 56, top: 4),
                  child: Text(
                    assignment.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 56, top: 8),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${DateFormat('MMM dd, yyyy').format(deadline)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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
