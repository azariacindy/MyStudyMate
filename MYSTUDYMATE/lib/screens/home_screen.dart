import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/custom_bottom_nav.dart';
import '../services/schedule_service.dart';
import '../services/auth_service.dart';
import '../models/schedule_model.dart';
import '../models/assignment_model.dart';
import 'scheduleFeature/edit_schedule_screen.dart';
import 'scheduleFeature/edit_assignment_screen.dart';

/// HomeScreen - Halaman utama MyStudyMate (Fixed Overflow)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  late Future<List<Schedule>> _schedulesFuture;
  late Future<List<Assignment>> _assignmentsFuture;
  String _userName = 'User';
  String? _cachedProfilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = _loadSchedules();
    _assignmentsFuture = _loadAssignments();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userName = user.name;
          _cachedProfilePhotoUrl = user.profilePhotoUrl;
        });
      }
    } catch (e) {
      // Silent fail - keep default name
    }
  }

  Future<List<Schedule>> _loadSchedules() async {
    try {
      // Load schedules for the next 7 days
      final today = DateTime.now();
      final endDate = today.add(const Duration(days: 7));
      final schedules = await _scheduleService.getSchedulesByDateRange(today, endDate);
      
      return schedules;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading schedules: $e')),
        );
      }
      return [];
    }
  }

  Future<List<Assignment>> _loadAssignments() async {
    try {
      final result = await _scheduleService.getAssignments(status: 'pending');
      if (result['success'] == true && result['data'] != null) {
        final assignments = (result['data'] as List)
            .map((json) => Assignment.fromJson(json))
            .where((a) => !a.isDone) // Filter out marked/done assignments
            .toList();
        
        // Sort by priority: critical > high > medium > low
        assignments.sort((a, b) {
          const priorityOrder = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3};
          return (priorityOrder[a.priority] ?? 99).compareTo(priorityOrder[b.priority] ?? 99);
        });
        
        return assignments;
      }
      return [];
    } catch (e) {
      debugPrint('Error loading assignments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === HEADER CARD ===
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // === QUICK ACTIONS ===
              _buildQuickActions(context),
              const SizedBox(height: 20),

              // === SCHEDULE SECTION ===
              _buildScheduleSection(screenWidth),
              const SizedBox(height: 20),

              // === ASSIGNMENTS SECTION ===
              _buildAssignmentsSection(),
            ],
          ),
        ),
      ),

      // === BOTTOM NAVIGATION ===
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          if (index == 1) Navigator.pushNamed(context, '/schedule');
          if (index == 2) Navigator.pushNamed(context, '/study_cards');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
      ),
      // No FAB on home screen
    );
  }

  /// Header Card - Fixed Icons
  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 34, 3, 107), Color.fromARGB(255, 89, 147, 240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row - FIXED
          Row(
            children: [
              // Avatar with Profile Photo or Icon
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(38),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _cachedProfilePhotoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: _cachedProfilePhotoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              CupertinoIcons.person,
                              color: Color(0xFF8B5CF6),
                              size: 28,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              CupertinoIcons.person,
                              color: Color(0xFF8B5CF6),
                              size: 28,
                            ),
                            memCacheWidth: 96, // Optimize memory
                            memCacheHeight: 96,
                            maxWidthDiskCache: 96,
                            maxHeightDiskCache: 96,
                          )
                        : const Icon(
                            CupertinoIcons.person,
                            color: Color(0xFF8B5CF6),
                            size: 28,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Greeting - FIXED Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.sun_max,
                          color: Color(0xFFFFA726),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress - FIXED
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress
              SizedBox(
                width: 65,
                height: 65,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        value: 0.6,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withAlpha(51),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '60%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Progress Text - FIXED Overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3 of 5 Tasks',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.graph_circle,
                          color: Color(0xFF10B981),
                          size: 19,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Keep going!',
                            style: TextStyle(
                              color: Colors.white.withAlpha(204),
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick Actions - Fixed Layout
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.calendar,
                'Daily Board',
                'View All',
                const Color(0xFF3B82F6),
                '/schedule',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.clock_fill,
                'Pomodoro',
                '25 min',
                const Color(0xFFEC4899),
                '/pomodoro',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Notes feature temporarily disabled for demo
            // Expanded(
            //   child: _buildActionCard(
            //     context,
            //     CupertinoIcons.create,
            //     'Notes',
            //     '8 Notes',
            //     const Color(0xFF8B5CF6),
            //     '/notes',
            //   ),
            // ),
            // const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                context,
                CupertinoIcons.news_solid,
                'Study Cards',
                'Learn More',
                const Color(0xFF10B981),
                '/study_cards',
              ),
            ),
            const SizedBox(width: 10),
            // Empty space to match Daily Board / Pomodoro layout
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(38),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.withAlpha(179),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Schedule Section - FIXED OVERFLOW
  Widget _buildScheduleSection(double screenWidth) {
    return RepaintBoundary(
      child: FutureBuilder<List<Schedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final schedules = snapshot.data ?? [];
        
        // Group schedules by date for the next 7 days
        final today = DateTime.now();
        final Map<String, List<Schedule>> groupedSchedules = {};
        
        for (int i = 0; i < 7; i++) {
          final date = today.add(Duration(days: i));
          final daySchedules = schedules.where((s) => _isSameDay(s.date, date)).toList();
          
          String label;
          if (i == 0) {
            label = 'Today';
          } else if (i == 1) {
            label = 'Tomorrow';
          } else {
            // Format: "Wed, Nov 20"
            final weekday = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
            final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
            label = '$weekday, $month ${date.day}';
          }
          
          groupedSchedules[label] = daySchedules;
        }

        final scheduleColors = [
          [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
          [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
          [const Color(0xFF10B981), const Color(0xFF3B82F6)],
          [const Color(0xFFEF4444), const Color(0xFFF59E0B)],
          [const Color(0xFF06B6D4), const Color(0xFF8B5CF6)],
          [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
          [const Color(0xFF8B5CF6), const Color(0xFF3B82F6)],
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/schedule'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 210,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: groupedSchedules.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final dateKey = groupedSchedules.keys.elementAt(index);
                  final daySchedules = groupedSchedules[dateKey]!;
                  
                  return Container(
                    width: screenWidth * 0.65,
                    margin: EdgeInsets.only(right: index < 6 ? 10 : 0),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: scheduleColors[index % scheduleColors.length],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: scheduleColors[index % scheduleColors.length][0].withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                dateKey,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(38),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${daySchedules.length} ${daySchedules.length == 1 ? 'Class' : 'Classes'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (daySchedules.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No schedules',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(179),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        else
                          ...daySchedules.take(3).map((schedule) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _buildScheduleItem(
                              _getIconForScheduleType(schedule.type),
                              schedule.title,
                              '${schedule.getFormattedStartTime()} - ${schedule.getFormattedEndTime()}',
                              schedule,
                            ),
                          )),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      ),
    );
  }

  IconData _getIconForScheduleType(String? type) {
    switch (type?.toLowerCase()) {
      case 'class':
        return Icons.business;
      case 'meeting':
        return Icons.group;
      case 'study':
        return Icons.book;
      case 'exam':
        return Icons.assignment;
      case 'lab':
        return Icons.science;
      default:
        return Icons.event;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildScheduleItem(IconData icon, String title, String time, Schedule schedule) {
  return GestureDetector(
    onTap: () async {
      // Navigate to edit schedule
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditScheduleScreen(schedule: schedule),
        ),
      );
      
      // Refresh data if schedule was updated or deleted
      if (result == true && mounted) {
        setState(() {
          _schedulesFuture = _loadSchedules();
        });
      }
    },
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit,
            color: Colors.white.withAlpha(204),
            size: 14,
          ),
        ],
      ),
    ),
  );
}

  /// Assignments Section with Priority
  Widget _buildAssignmentsSection() {
    return RepaintBoundary(
      child: FutureBuilder<List<Assignment>>(
        future: _assignmentsFuture,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final assignments = snapshot.data ?? [];
        final displayAssignments = assignments.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Assignments',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (assignments.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${assignments.length}',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    final result = await Navigator.pushNamed(context, '/schedule');
                    if (result == true && mounted) {
                      setState(() {
                        _assignmentsFuture = _loadAssignments();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (displayAssignments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 48,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No pending assignments',
                        style: TextStyle(
                          color: Colors.grey.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...displayAssignments.map((assignment) => _buildAssignmentCard(assignment)),
          ],
        );
      },
    ),
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAssignmentScreen(assignment: assignment),
          ),
        );
        if (result == true && mounted) {
          setState(() {
            _assignmentsFuture = _loadAssignments();
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: assignment.priorityColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: assignment.priorityColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Priority Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    assignment.priorityColor.withValues(alpha: 0.2),
                    assignment.priorityColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: assignment.priorityColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.assignment,
                size: 20,
                color: assignment.priorityColor,
              ),
            ),
            const SizedBox(width: 12),

            // Assignment Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: assignment.priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: assignment.priorityColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              assignment.priority == 'critical'
                                  ? Icons.priority_high
                                  : assignment.priority == 'high'
                                      ? Icons.alarm
                                      : assignment.priority == 'medium'
                                          ? Icons.schedule
                                          : Icons.check_circle_outline,
                              size: 10,
                              color: assignment.priorityColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              assignment.priorityLabel,
                              style: TextStyle(
                                color: assignment.priorityColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 11,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Deadline: ${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.withValues(alpha: 0.7),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.grey.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        assignment.daysUntilDeadline >= 0
                            ? '${assignment.daysUntilDeadline}d left'
                            : '${-assignment.daysUntilDeadline}d overdue',
                        style: TextStyle(
                          fontSize: 11,
                          color: assignment.daysUntilDeadline >= 0
                              ? Colors.grey.withValues(alpha: 0.7)
                              : const Color(0xFFEF4444),
                          fontWeight: assignment.daysUntilDeadline < 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
