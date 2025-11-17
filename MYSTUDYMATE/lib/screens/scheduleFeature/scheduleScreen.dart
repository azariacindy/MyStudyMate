import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/app_colors.dart';
import '../../screens/home_screen.dart';
import '../../models/schedule_model.dart';
import '../../services/schedule_service.dart';
import '../../services/notification_service.dart';
import 'manageScheduleScreen.dart';

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
      
      setState(() {
        _schedules = schedules;
        
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

  List<Schedule> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    
    return _schedules.where((s) {
      final scheduleDate = DateTime(s.date.year, s.date.month, s.date.day);
      return scheduleDate == normalizedDay;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);
    final isToday = _isSameDay(_selectedDay, DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // === TOP HEADER SECTION ===
            Container(
              decoration: const BoxDecoration(
                color:  Color(0xFF5B9FED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Back button and title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        // Title
                        const Expanded(
                          child: Text(
                            'Plan a Schedule',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Spacer untuk balance
                        const SizedBox(width: 36),
                      ],
                    ),
                  ),
                ],
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
                            // Calendar Section
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  // Calendar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text,
                                        ),
                                        leftChevronIcon: Icon(
                                          Icons.chevron_left,
                                          color: AppColors.text,
                                          size: 20,
                                        ),
                                        rightChevronIcon: Icon(
                                          Icons.chevron_right,
                                          color: AppColors.text,
                                          size: 20,
                                        ),
                                      ),
                                      daysOfWeekStyle: const DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                        weekendStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
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
                                ],
                              ),
                            ),

                            // Schedule and Task List Section
                            if (selectedEvents.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B9FED).withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                        child: Text(
                                          isToday ? 'Today\'s Schedule' : 'Schedules',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color:  Color(0xFF5B9FED),
                                          ),
                                        ),
                                      ),
                                      // Items
                                      ...selectedEvents.map((event) {
                                        return _buildScheduleItem(event, isToday);
                                      }),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),

            // === BOTTOM NAVIGATION BAR ===
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF5B9FED),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // HOME
                      _buildNavItem(
                        icon: Icons.home,
                        isActive: false,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        },
                      ),

                      // schedule
                      _buildScheduleNav(true),

                      // TASKS
                      _buildNavItem(
                        icon: Icons.assignment,
                        isActive: false,
                        onTap: () {
                          Navigator.pushNamed(context, '/manage_task');
                        },
                      ),

                      // PROFILE
                      _buildNavItem(
                        icon: Icons.person,
                        isActive: false,
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button untuk add schedule
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManageScheduleScreen(
                selectedDate: _selectedDay,
              ),
            ),
          );
          
          // Reload data after adding schedule
          if (result != null) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFF5B9FED),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildScheduleNav(bool isActive) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: isActive ? Colors.white : const Color(0xFF6BA5EF),
      shape: BoxShape.circle,
    ),
    child: Icon(
      Icons.calendar_today,
      color: isActive ? const Color(0xFF5B9FED) : Colors.white,
      size: 24,
    ),
  );
}


  Widget _buildScheduleItem(Schedule schedule, bool isToday) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: schedule.isCompleted 
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(schedule.color?.replaceAll('#', '0xFF') ?? '0xFF5B9FED')),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday 
                      ? 'Today, ${schedule.getFormattedStartTime()} - ${schedule.getFormattedEndTime()}'
                      : '${schedule.getFormattedStartTime()} - ${schedule.getFormattedEndTime()}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 15,
                    color: schedule.isCompleted ? AppColors.textSecondary : AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: schedule.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (schedule.location != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          schedule.location!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Checkbox
          Checkbox(
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
            activeColor: const Color(0xFF5B9FED),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

