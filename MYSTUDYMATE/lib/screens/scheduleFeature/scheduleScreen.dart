import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../utils/app_colors.dart';
import '../../screens/home_screen.dart';
import 'manageScheduleScreen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Sample schedule data - nanti bisa diambil dari database
  final Map<DateTime, List<ScheduleItem>> _schedules = {};

  @override
  void initState() {
    super.initState();
    // Initialize with current month
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    
    // Sample data untuk testing
    final today = DateTime.now();
    _schedules[today] = [
      ScheduleItem(
        title: 'Management Project',
        startTime: '10:00',
        endTime: '11:00',
      ),
      ScheduleItem(
        title: 'Mobile Practicum',
        startTime: '13:30',
        endTime: '17:00',
      ),
    ];
  }

  List<ScheduleItem> _getSchedulesForDay(DateTime day) {
    // Normalize date to remove time component
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _schedules[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedSchedules = _getSchedulesForDay(_selectedDay);
    final isToday = _isSameDay(_selectedDay, DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // === TOP HEADER SECTION ===
            Container(
              decoration: const BoxDecoration(
                color: const Color(0xFF5B9FED),
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
              child: SingleChildScrollView(
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
                                  color: const Color(0xFF5B9FED),
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
                                _focusedDay = focusedDay;
                              },
                              eventLoader: (day) {
                                return _getSchedulesForDay(day);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Schedule List Section (muncul ketika ada schedule atau tanggal dipilih)
                    if (selectedSchedules.isNotEmpty)
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
                              // Schedule Title
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                                child: const Text(
                                  'Schedule',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5B9FED),
                                  ),
                                ),
                              ),
                              // Schedule Items
                              ...selectedSchedules.map((schedule) => _buildScheduleItem(schedule, isToday)),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                  ],
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
                        icon: Icons.person_outline,
                        isActive: false,
                        onTap: () {},
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
          
          // Handle schedule data yang dikembalikan
          if (result != null && result is Map) {
            final date = result['date'] as DateTime;
            final normalizedDate = DateTime(date.year, date.month, date.day);
            final startTime = result['startTime'] as TimeOfDay;
            final endTime = result['endTime'] as TimeOfDay;
            
            final scheduleItem = ScheduleItem(
              title: result['title'] as String,
              startTime: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              endTime: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
            );
            
            setState(() {
              if (_schedules.containsKey(normalizedDate)) {
                _schedules[normalizedDate]!.add(scheduleItem);
              } else {
                _schedules[normalizedDate] = [scheduleItem];
              }
              // Update selected day jika schedule ditambahkan untuk tanggal lain
              if (!_isSameDay(_selectedDay, normalizedDate)) {
                _selectedDay = normalizedDate;
                _focusedDay = normalizedDate;
              }
            });
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
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      Icons.calendar_today,
      color: isActive ? const Color(0xFF5B9FED) : Colors.white,
      size: 24,
    ),
  );
}


  Widget _buildScheduleItem(ScheduleItem schedule, bool isToday) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday 
                      ? 'Today, ${schedule.startTime} - ${schedule.endTime}'
                      : '${schedule.startTime} - ${schedule.endTime}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// Model untuk Schedule Item
class ScheduleItem {
  final String title;
  final String startTime;
  final String endTime;

  ScheduleItem({
    required this.title,
    required this.startTime,
    required this.endTime,
  });
}

