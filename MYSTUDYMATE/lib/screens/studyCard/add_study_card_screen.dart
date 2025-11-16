import 'package:flutter/material.dart';

class AddStudyCardScreen extends StatefulWidget {
  const AddStudyCardScreen({super.key});

  @override
  State<AddStudyCardScreen> createState() => _AddStudyCardScreenState();
}

class _AddStudyCardScreenState extends State<AddStudyCardScreen> {
  final List<String> _titleOptions = [
    'Data Mining Quiz',
    'Mobile Programming Mid Term',
    'Management Project Quiz',
    'Business Intelligence Mid Term',
    'Mobile Programming Quiz',
  ];

  String? _selectedTitle;
  final TextEditingController _materialsController = TextEditingController();

  bool get _isContinueEnabled => _selectedTitle != null;

  @override
  void dispose() {
    _materialsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              // HEADER
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 24, bottom: 32, left: 16, right: 16),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(48),
                        bottomRight: Radius.circular(48),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                        ),
                        const Expanded(
                          child: Text(
                            'Study Cards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // IKON KARTU STUDI
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: const Icon(Icons.menu_book_rounded, size: 48, color: Colors.blue),
              ),

              const SizedBox(height: 32),

              // DROPDOWN TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedTitle,
                      onChanged: (value) {
                        setState(() {
                          _selectedTitle = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        hintText: 'Select a title',
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      items: _titleOptions.map((title) {
                        return DropdownMenuItem<String>(
                          value: title,
                          child: Text(title),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // LEARNING MATERIALS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learning Materials',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _materialsController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        hintText:
                            'e.g. The data mining stages consist of data collection, data cleaning, data integration, data transformation, data mining, and evaluation and interpretation of the results.',
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // TOMBOL CONTINUE & CANCEL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isContinueEnabled
                            ? () {
                                Navigator.pushNamed(context, '/quiz_question');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isContinueEnabled ? Colors.blue : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // BOTTOM NAVIGATION BAR — TANPA LINGKARAN PUTIH
              Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNavItem(
                      icon: Icons.home_filled,
                      label: 'Home',
                      isActive: false,
                      onTap: () {},
                    ),
                    _BottomNavItem(
                      icon: Icons.calendar_today,
                      label: 'Calendar',
                      isActive: false,
                      onTap: () {},
                    ),
                    _BottomNavItem(
                      icon: Icons.menu_book_rounded,
                      label: 'Book',
                      isActive: true,
                      onTap: () {},
                    ),
                    _BottomNavItem(
                      icon: Icons.person,
                      label: 'Profile',
                      isActive: false,
                      onTap: () {},
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

// ✅ BOTTOM NAV ITEM — TANPA LINGKARAN TRANSPARAN
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ HANYA IKON — TANPA BACKGROUND LINGKARAN
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}