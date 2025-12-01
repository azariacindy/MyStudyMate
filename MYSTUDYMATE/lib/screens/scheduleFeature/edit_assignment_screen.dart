import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/assignment_model.dart';
import '../../services/schedule_service.dart';

class EditAssignmentScreen extends StatefulWidget {
  final Assignment assignment;

  const EditAssignmentScreen({super.key, required this.assignment});

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleService _scheduleService = ScheduleService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  late DateTime _deadline;
  late String _selectedColor;
  bool _hasReminder = true;
  int _reminderMinutes = 30;
  bool _isLoading = false;

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
    _initializeFromAssignment();
  }

  void _initializeFromAssignment() {
    _titleController = TextEditingController(text: widget.assignment.title);
    _descriptionController = TextEditingController(text: widget.assignment.description ?? '');
    
    _deadline = widget.assignment.deadline;
    _selectedColor = widget.assignment.color;
    _hasReminder = widget.assignment.hasReminder;
    _reminderMinutes = widget.assignment.reminderMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline),
      );
      
      if (pickedTime != null) {
        setState(() {
          _deadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _updateAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _scheduleService.updateAssignment(
        widget.assignment.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _deadline,
        color: _selectedColor,
        hasReminder: _hasReminder,
        reminderMinutes: _reminderMinutes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assignment updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAssignment() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: const Text('Are you sure you want to delete this assignment?'),
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
        await _scheduleService.deleteAssignment(widget.assignment.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
        title: const Text('Edit Assignment'),
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
                            hintText: 'e.g., Math Homework',
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

                    // Deadline Card
                    _buildSectionCard(
                      title: 'Deadline',
                      icon: Icons.event_note,
                      children: [
                        InkWell(
                          onTap: _selectDeadline,
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
                                      const Text(
                                        'Deadline Date & Time',
                                        style: TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat('EEEE, MMM dd, yyyy - HH:mm').format(_deadline),
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
                      ],
                    ),
                    const SizedBox(height: 20),

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
                              _hasReminder ? 'You will be notified before deadline' : 'No reminder will be sent',
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
                              onPressed: _isLoading ? null : _deleteAssignment,
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
                              onPressed: _isLoading ? null : _updateAssignment,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Update Assignment'),
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
