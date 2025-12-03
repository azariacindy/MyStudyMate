import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/schedule_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class ManageScheduleScreen extends StatefulWidget {
  final DateTime? selectedDate;

  const ManageScheduleScreen({super.key, this.selectedDate});

  @override
  State<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends State<ManageScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lecturerController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _selectedType = 'lecture';
  String _selectedColor = '#5B9FED';
  bool _hasReminder = true;
  int _reminderMinutes = 30;
  final ScheduleService _scheduleService = ScheduleService();

  final List<Map<String, dynamic>> _scheduleTypes = [
    {'value': 'assignment', 'label': 'Assignment', 'icon': Icons.assignment},
    {'value': 'lecture', 'label': 'Lecture', 'icon': Icons.school},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event},
  ];

  final List<Map<String, dynamic>> _colorOptions = [
    {'value': '#5B9FED', 'label': 'Blue'},
    {'value': '#8B5CF6', 'label': 'Purple'},
    {'value': '#10B981', 'label': 'Green'},
    {'value': '#F59E0B', 'label': 'Orange'},
    {'value': '#EF4444', 'label': 'Red'},
    {'value': '#EC4899', 'label': 'Pink'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF5B9FED),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF5B9FED),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select a date')));
        return;
      }
      
      // For non-assignment types, validate time
      if (_selectedType != 'assignment') {
        if (_startTime == null || _endTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select start and end time')),
          );
          return;
        }
      }

      try {
        dynamic result;
        
        // Check if type is assignment - save to assignments table
        if (_selectedType == 'assignment') {
          result = await _scheduleService.createAssignment(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            deadline: _selectedDate!,
            color: _selectedColor,
            hasReminder: _hasReminder,
            reminderMinutes: _reminderMinutes,
          );
          result = result['data']; // Extract data from response
        } else {
          // For other types (lecture, event), save to schedules table
          result = await _scheduleService.createSchedule(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            date: _selectedDate!,
            startTime: _startTime!,
            endTime: _endTime!,
            location: null,
            lecturer: _lecturerController.text.isEmpty ? null : _lecturerController.text,
            color: _selectedColor,
            type: _selectedType,
            hasReminder: _hasReminder,
            reminderMinutes: _reminderMinutes,
          );
        }

        // Notifikasi akan dikirim otomatis dari backend via FCM
        // saat waktu reminder tercapai

        // Menampilkan snackbar untuk konfirmasi sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_selectedType == 'assignment' 
                  ? 'Assignment saved successfully' 
                  : 'Schedule saved successfully'),
              backgroundColor: AppColors.success,
            ),
          );

          // Mengirimkan data kembali ke screen sebelumnya
          Navigator.pop(context, result);
        }
      } catch (e) {
        if (mounted) {
          // Log detailed error for debugging
          debugPrint('Error saving schedule/assignment: $e');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create ${_selectedType == 'assignment' ? 'assignment' : 'schedule'}: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  // Back button with circle background
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
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
                      'Add Daily Board',
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Card
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.info_outline,
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g., Management Project',
                      prefixIcon: const Icon(Icons.title, color: Color(0xFF5B9FED)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF5B9FED), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter schedule title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add notes or details...',
                      prefixIcon: const Icon(Icons.description, color: Color(0xFF5B9FED)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF5B9FED), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Schedule Type Card
              _buildSectionCard(
                title: 'Schedule Type',
                icon: Icons.category_outlined,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _scheduleTypes.length,
                    itemBuilder: (context, index) {
                      final type = _scheduleTypes[index];
                      final isSelected = _selectedType == type['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedType = type['value']);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withAlpha(77),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                color: isSelected ? Colors.white : const Color(0xFF8B5CF6),
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type['label'] as String,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date & Time Card
              _buildSectionCard(
                title: _selectedType == 'assignment' ? 'Deadline' : 'Date & Time',
                icon: _selectedType == 'assignment' ? Icons.event_note : Icons.schedule,
                children: [
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9FED).withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.calendar_today, color: Color(0xFF5B9FED), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedType == 'assignment' ? 'Deadline Date' : 'Date',
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedDate != null ? _formatDate(_selectedDate!) : 'Select date',
                                  style: TextStyle(
                                    color: _selectedDate != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                        ],
                      ),
                    ),
                  ),
                  // Show time pickers only for non-assignment types
                  if (_selectedType != 'assignment') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _selectStartTime,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, color: const Color(0xFF5B9FED), size: 18),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Start',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _startTime != null ? _formatTime(_startTime!) : '--:--',
                                    style: TextStyle(
                                      color: _startTime != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: _selectEndTime,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_filled, color: const Color(0xFF5B9FED), size: 18),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'End',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _endTime != null ? _formatTime(_endTime!) : '--:--',
                                    style: TextStyle(
                                      color: _endTime != null ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),

              // Additional Details Card (Only for Lecture)
              if (_selectedType == 'lecture') ...[
                _buildSectionCard(
                  title: 'Additional Details',
                  icon: Icons.person_outline,
                  children: [
                    TextFormField(
                      controller: _lecturerController,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        labelText: 'Lecturer / Instructor',
                        hintText: 'e.g., Dr. John Doe',
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF5B9FED)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF5B9FED), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // Color Selection Card
              _buildSectionCard(
                title: 'Color Theme',
                icon: Icons.palette_outlined,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _colorOptions.map((colorOption) {
                      final isSelected = _selectedColor == colorOption['value'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = colorOption['value']);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Color(int.parse(colorOption['value'].substring(1), radix: 16) + 0xFF000000),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF1F2937) : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(int.parse(colorOption['value'].substring(1), radix: 16) + 0xFF000000).withAlpha(77),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                                  : null,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              colorOption['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reminder Card
              _buildSectionCard(
                title: 'Reminder Settings',
                icon: Icons.notifications_outlined,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Enable Reminder',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        _hasReminder ? 'You will be notified before the schedule' : 'No reminder will be sent',
                        style: const TextStyle(fontSize: 13),
                      ),
                      value: _hasReminder,
                      activeThumbColor: const Color(0xFF5B9FED),
                      activeTrackColor: const Color(0xFF5B9FED).withAlpha(128),
                      onChanged: (value) {
                        setState(() => _hasReminder = value);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    ),
                  ),
                  if (_hasReminder) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: DropdownButtonFormField<int>(
                        initialValue: _reminderMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Remind me before',
                          prefixIcon: Icon(Icons.timer_outlined, color: Color(0xFF5B9FED)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                          DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                          DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                          DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                          DropdownMenuItem(value: 60, child: Text('1 hour before')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderMinutes = value);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _saveSchedule,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save Schedule'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B9FED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 5), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9FED).withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF5B9FED), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
