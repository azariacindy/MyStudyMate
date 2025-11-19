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
  late TextEditingController _locationController;
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
    {'value': 'lecture', 'label': 'Lecture', 'icon': Icons.school},
    {'value': 'lab', 'label': 'Lab', 'icon': Icons.science},
    {'value': 'meeting', 'label': 'Meeting', 'icon': Icons.people},
    {'value': 'assignment', 'label': 'Assignment', 'icon': Icons.assignment},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
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
    _locationController = TextEditingController(text: widget.schedule.location ?? '');
    _lecturerController = TextEditingController(text: widget.schedule.lecturer ?? '');
    
    _selectedDate = widget.schedule.date;
    _startTime = widget.schedule.startTime;
    _endTime = widget.schedule.endTime;
    _selectedType = widget.schedule.type ?? 'lecture';
    _selectedColor = widget.schedule.color ?? '#5B9FED';
    _hasReminder = widget.schedule.hasReminder ?? true;
    _reminderMinutes = widget.schedule.reminderMinutes ?? 30;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
      await _scheduleService.updateSchedule(
        widget.schedule.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        location: _locationController.text.trim(),
        type: _selectedType,
        color: _selectedColor,
        hasReminder: _hasReminder,
        reminderMinutes: _reminderMinutes,
      );

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteSchedule,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        child: Text(
                          DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Time
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Time *',
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(_startTime.format(context)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Time *',
                                prefixIcon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(_endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type *',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _scheduleTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'] as String,
                          child: Row(
                            children: [
                              Icon(type['icon'] as IconData, size: 20),
                              const SizedBox(width: 8),
                              Text(type['label'] as String),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lecturer (if type is lecture or lab)
                    if (_selectedType == 'lecture' || _selectedType == 'lab')
                      Column(
                        children: [
                          TextFormField(
                            controller: _lecturerController,
                            decoration: InputDecoration(
                              labelText: 'Lecturer',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // Color
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: _colorOptions.map((colorOption) {
                        final isSelected = _selectedColor == colorOption['value'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = colorOption['value']);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(int.parse(colorOption['value'].substring(1), radix: 16) + 0xFF000000),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Reminder
                    SwitchListTile(
                      title: const Text('Enable Reminder'),
                      value: _hasReminder,
                      onChanged: (value) {
                        setState(() => _hasReminder = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_hasReminder)
                      DropdownButtonFormField<int>(
                        value: _reminderMinutes,
                        decoration: InputDecoration(
                          labelText: 'Remind me before',
                          prefixIcon: const Icon(Icons.notifications),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 minutes')),
                          DropdownMenuItem(value: 10, child: Text('10 minutes')),
                          DropdownMenuItem(value: 15, child: Text('15 minutes')),
                          DropdownMenuItem(value: 30, child: Text('30 minutes')),
                          DropdownMenuItem(value: 60, child: Text('1 hour')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderMinutes = value);
                          }
                        },
                      ),
                    const SizedBox(height: 24),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Update Schedule',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
}
