import 'package:flutter/material.dart';
import 'plan_task_screen.dart';

class ManageTaskScreen extends StatefulWidget {
  const ManageTaskScreen({super.key});

  @override
  State<ManageTaskScreen> createState() => _ManageTaskScreenState();
}

class _ManageTaskScreenState extends State<ManageTaskScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Management Project',
      'category': 'PPT',
      'deadline': 'Deadline: 12 November 2025',
    },
    {
      'title': 'Management Project',
      'category': 'Subject',
      'deadline': 'Deadline: 12 November 2025',
    },
    {
      'title': 'Mobile Practicum',
      'category': 'Subject',
      'deadline': 'Deadline: 12 November 2025',
    },
    {
      'title': 'Data Warehouse',
      'category': 'Database II',
      'deadline': 'Deadline: 12 November 2025',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER WITH ROUNDED BOTTOM ===
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF5B9FED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Top bar with back button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Manage Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // === CONTENT SECTION ===
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Section
                    const Text(
                      'Today Progress',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    ),
                    const SizedBox(height: 8),

                    Stack(
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.5,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9FED),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                '50 %',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    const Text(
                      '3 of 5 Task',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),

                    const SizedBox(height: 20),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF5B9FED),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF5B9FED),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Task List
                    Expanded(
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9FED),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.15),
                                  spreadRadius: 0,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task['title'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task['category'] as String,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task['deadline'] as String,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.file_copy_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        // TODO: handle copy task
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        // TODO: handle edit task
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        // TODO: handle delete task
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // === FLOATING ACTION BUTTON ===
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlanTaskScreen()),
          );
        },
        backgroundColor: const Color(0xFF5B9FED),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),

      // === BOTTOM NAVIGATION BAR ===
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF5B9FED),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: _buildNavItem(Icons.home_outlined, false),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to Calendar
                  },
                  child: _buildNavItem(Icons.calendar_today_outlined, false),
                ),
                GestureDetector(
                  onTap: () {
                    // Already in Manage Task
                  },
                  child: _buildNavItem(Icons.assignment, true),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to Profile
                  },
                  child: _buildNavItem(Icons.person_outline, false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : const Color(0xFF6BA5EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive ? const Color(0xFF5B9FED) : Colors.white,
        size: 24,
      ),
    );
  }
}
