import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../models/assignment_model.dart';
import '../../services/schedule_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'manageScheduleScreen.dart';
import 'edit_schedule_screen.dart';
import 'edit_assignment_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  final ScheduleService _scheduleService = ScheduleService();
  final NotificationService _notificationService = NotificationService();

  List<Schedule> _schedules = [];
  List<Assignment> _assignments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get current month range
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      
      // Load schedules
      final schedules = await _scheduleService.getSchedulesByDateRange(firstDay, lastDay);
      
      // Load assignments with error handling
      List<Assignment> assignments = [];
      try {
        final assignmentsResult = await _scheduleService.getAssignments();
        if (assignmentsResult['success'] == true && assignmentsResult['data'] != null) {
          assignments = (assignmentsResult['data'] as List)
              .map((json) => Assignment.fromJson(json))
              .where((assignment) => !assignment.isDone) // Filter completed assignments
              .toList();
        }
      } catch (e) {
        debugPrint('Error loading assignments: $e');
        // Continue without assignments if fetch fails
      }
      
      setState(() {
        _schedules = schedules;
        _assignments = assignments;
        
        // Schedule notifications for upcoming schedules
        for (var schedule in _schedules) {
          if (!schedule.isCompleted && schedule.hasReminder) {
            _notificationService.scheduleReminder(schedule);
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    // Get schedules for the day
    final schedules = _schedules.where((s) {
      final scheduleDate = DateTime(s.date.year, s.date.month, s.date.day);
      return scheduleDate == normalizedDay;
    }).toList();
    
    // Get assignments for the day (based on deadline)
    final assignments = _assignments.where((a) {
      final assignmentDate = DateTime(a.deadline.year, a.deadline.month, a.deadline.day);
      return assignmentDate == normalizedDay;
    }).toList();
    
    // Combine both lists
    return [...schedules, ...assignments];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);
    final isToday = _isSameDay(_selectedDay, DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // === TOP HEADER SECTION ===
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color.fromARGB(255, 34, 3, 107), Color.fromARGB(255, 89, 147, 240)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Row(
                    children: [
                      // Back button with circle background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Title
                      const Expanded(
                        child: Text(
                          'My Schedule',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Spacer untuk balance
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),
            ),

            // === MAIN CONTENT AREA ===
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Calendar Section
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TableCalendar(
                                      firstDay: DateTime.utc(2020, 1, 1),
                                      lastDay: DateTime.utc(2030, 12, 31),
                                      focusedDay: _focusedDay,
                                      selectedDayPredicate: (day) {
                                        return _isSameDay(_selectedDay, day);
                                      },
                                      calendarFormat: _calendarFormat,
                                      startingDayOfWeek: StartingDayOfWeek.monday,
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        titleTextStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                        leftChevronIcon: Icon(
                                          Icons.chevron_left,
                                          color: Color(0xFF5B9FED),
                                        ),
                                        rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF5B9FED),
                                        ),
                                      ),
                                      daysOfWeekStyle: const DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                        weekendStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                      calendarStyle: CalendarStyle(
                                        outsideDaysVisible: false,
                                        defaultTextStyle: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                        weekendTextStyle: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                        selectedDecoration: BoxDecoration(
                                          color: const Color(0xFF5B9FED),
                                          shape: BoxShape.circle,
                                        ),
                                        todayDecoration: BoxDecoration(
                                          color: const Color(0xFF5B9FED).withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        selectedTextStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        todayTextStyle: const TextStyle(
                                          color:  Color(0xFF5B9FED),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        markerDecoration: BoxDecoration(
                                          color: const Color(0xFF5B9FED),
                                          shape: BoxShape.circle,
                                        ),
                                        markersMaxCount: 1,
                                        markerSize: 6,
                                      ),
                                      onDaySelected: (selectedDay, focusedDay) {
                                        setState(() {
                                          _selectedDay = selectedDay;
                                          _focusedDay = focusedDay;
                                        });
                                      },
                                      onPageChanged: (focusedDay) {
                                        setState(() {
                                          _focusedDay = focusedDay;
                                        });
                                        _loadData();
                                      },
                                      eventLoader: _getEventsForDay,
                                    ),
                                  ),
                                ),

                                // Schedule List Section
                                if (selectedEvents.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                                          child: Text(
                                            isToday ? 'Today\'s Schedule' : 'Schedules',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        // Items
                                        ...selectedEvents.map((event) {
                                          if (event is Schedule) {
                                            return _buildScheduleItem(event, isToday);
                                          } else if (event is Assignment) {
                                            return _buildAssignmentItem(event);
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                      ],
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.event_busy_outlined,
                                          size: 64,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No schedules for this day',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      // === BOTTOM NAVIGATION ===
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
      floatingActionButton: CustomFAB(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageScheduleScreen(
                selectedDate: _selectedDay,
              ),
            ),
          );
          
          if (result != null) {
            _loadData();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildScheduleItem(Schedule schedule, bool isToday) {
    final scheduleColor = Color(int.parse(schedule.color?.replaceAll('#', '0xFF') ?? '0xFF5B9FED'));
    
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
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: schedule.isCompleted 
                ? Colors.green.withValues(alpha: 0.3)
                : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheduleColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time badge with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheduleColor.withValues(alpha: 0.15),
                    scheduleColor.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheduleColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: scheduleColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    schedule.getFormattedStartTime(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: scheduleColor,
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: scheduleColor.withValues(alpha: 0.3),
                  ),
                  Text(
                    schedule.getFormattedEndTime(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheduleColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: schedule.isCompleted ? const Color(0xFF64748B) : const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (schedule.description != null && schedule.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        schedule.description!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (schedule.lecturer != null && schedule.lecturer!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheduleColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color: scheduleColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schedule.lecturer!,
                              style: TextStyle(
                                fontSize: 12,
                                color: scheduleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Checkbox
            Container(
              decoration: BoxDecoration(
                color: schedule.isCompleted 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: schedule.isCompleted,
                  onChanged: (value) async {
                    try {
                      await _scheduleService.toggleScheduleCompletion(schedule.id, value ?? false);
                      _loadData();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildAssignmentItem(Assignment assignment) {
    final assignmentColor = Color(int.parse(assignment.color.replaceAll('#', '0xFF')));
    
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditAssignmentScreen(assignment: assignment),
          ),
        );
        if (result == true) {
          _loadData(); // Reload if edited/deleted
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: assignment.isDone
                ? Colors.green.withValues(alpha: 0.3)
                : (assignment.isOverdue 
                    ? Colors.red.withValues(alpha: 0.3)
                    : const Color(0xFFE2E8F0)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: assignmentColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Assignment icon badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      assignmentColor.withValues(alpha: 0.15),
                      assignmentColor.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: assignmentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.assignment,
                  size: 24,
                  color: assignmentColor,
                ),
              ),
              const SizedBox(width: 14),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            assignment.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              decoration: assignment.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Priority badge with dynamic color
                        if (!assignment.isDone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: assignment.priorityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: assignment.priorityColor.withOpacity(0.3),
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
                                  size: 12,
                                  color: assignment.priorityColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  assignment.priorityLabel,
                                  style: TextStyle(
                                    color: assignment.priorityColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (assignment.description != null && assignment.description!.isNotEmpty)
                      Text(
                        assignment.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Deadline: ${DateFormat('MMM dd, HH:mm').format(assignment.deadline)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: assignmentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Assignment',
                            style: TextStyle(
                              fontSize: 10,
                              color: assignmentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Checkbox
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: assignment.isDone,
                    onChanged: assignment.isDone
                        ? null
                        : (value) async {
                            try {
                              await _scheduleService.markAsDone(assignment.id.toString());
                              _loadData();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                    activeColor: Colors.green,
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

