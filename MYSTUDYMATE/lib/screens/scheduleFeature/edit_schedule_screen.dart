import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule_model.dart';
import '../../services/schedule_service.dart';

class EditScheduleScreen extends StatefulWidget {
  final Schedule schedule;

  const EditScheduleScreen({super.key, required this.schedule});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService _scheduleService = ScheduleService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _lecturerController;
  
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _selectedType;
  late String _selectedColor;
  bool _hasReminder = true;
  int _reminderMinutes = 30;
  bool _isLoading = false;

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
    _initializeFromSchedule();
  }

  void _initializeFromSchedule() {
    _titleController = TextEditingController(text: widget.schedule.title);
    _descriptionController = TextEditingController(text: widget.schedule.description ?? '');
    _lecturerController = TextEditingController(text: widget.schedule.lecturer ?? '');
    
    _selectedDate = widget.schedule.date;
    _startTime = widget.schedule.startTime;
    _endTime = widget.schedule.endTime;
    _selectedType = widget.schedule.type;
    _selectedColor = widget.schedule.color ?? '#5B9FED';
    _hasReminder = widget.schedule.hasReminder;
    _reminderMinutes = widget.schedule.reminderMinutes;
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
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For assignment type, use default times (00:00 - 23:59)
      final startTime = _selectedType == 'assignment' 
          ? const TimeOfDay(hour: 0, minute: 0) 
          : _startTime;
      final endTime = _selectedType == 'assignment' 
          ? const TimeOfDay(hour: 23, minute: 59) 
          : _endTime;
          
      await _scheduleService.updateSchedule(
        widget.schedule.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: startTime,
        endTime: endTime,
        location: null,
        lecturer: _lecturerController.text.trim(),
        type: _selectedType,
        color: _selectedColor,
        hasReminder: _hasReminder,
        reminderMinutes: _reminderMinutes,
      );

      // Notifikasi akan diupdate otomatis dari backend via FCM

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Future<void> _deleteSchedule() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
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

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Notifikasi akan dibatalkan otomatis dari backend
        
        await _scheduleService.deleteSchedule(widget.schedule.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate deletion
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Edit Schedule'),
        backgroundColor: const Color(0xFF5B9FED),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
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
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
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
                                  color: isSelected ? const Color(0xFF5B9FED) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF5B9FED) : const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF5B9FED).withOpacity(0.3),
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
                                      color: isSelected ? Colors.white : const Color(0xFF5B9FED),
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
                                    color: const Color(0xFF5B9FED).withOpacity(0.1),
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
                                        DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                                        style: const TextStyle(
                                          color: Color(0xFF1F2937),
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
                                  onTap: () => _selectTime(true),
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
                                          _startTime.format(context),
                                          style: const TextStyle(
                                            color: Color(0xFF1F2937),
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
                                  onTap: () => _selectTime(false),
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
                                          _endTime.format(context),
                                          style: const TextStyle(
                                            color: Color(0xFF1F2937),
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
                                          color: Color(int.parse(colorOption['value'].substring(1), radix: 16) + 0xFF000000).withOpacity(0.3),
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
                            activeColor: const Color(0xFF5B9FED),
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
                              value: _reminderMinutes,
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

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _deleteSchedule,
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Delete'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _updateSchedule,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Update Schedule'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B9FED),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: const Color(0xFF5B9FED).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
            color: Colors.black.withOpacity(0.05),
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
                  color: const Color(0xFF5B9FED).withOpacity(0.1),
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
