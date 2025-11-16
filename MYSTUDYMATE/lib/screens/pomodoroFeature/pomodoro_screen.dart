
import 'dart:async';
import 'package:flutter/material.dart';

// enum harus di luar class
enum TimerMode { focus, rest }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Konfigurasi
  static const int totalCycles = 2; // 2 focus + 2 rest
  static const int focusDuration = 25; // menit
  static const int restDuration = 5; // menit

  TimerMode _currentMode = TimerMode.focus;
  int _currentCycle = 0; // 0 = belum mulai
  int _minutes = focusDuration;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  Timer? _timer; // pakai nullable

  @override
  void initState() {
    super.initState();
    _resetAll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _currentMode = TimerMode.focus;
      _currentCycle = 0;
      _minutes = focusDuration;
      _seconds = 0;
      _isRunning = false;
      _isCompleted = false;
    });
  }

  void startTimer() {
    if (_isRunning || _isCompleted) return;

    // 🔹 trigger rebuild supaya ikon langsung berubah jadi "pause"
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else if (_minutes > 0) {
          _minutes--;
          _seconds = 59;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _handlePeriodEnd();
        }
      });
    });
  }

  void pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();

    // 🔹 biar ikon berubah kembali ke "play"
    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _resetAll(); // _resetAll kamu sudah pakai setState di dalamnya, aman
  }

  void _handlePeriodEnd() {
    if (_currentMode == TimerMode.focus) {
      // selesai fokus → naikkan cycle & masuk rest
      _currentCycle++;
      if (_currentCycle <= totalCycles) {
        _setRest();
        startTimer(); // auto lanjut rest
      } else {
        _onAllCompleted();
      }
    } else {
      // selesai rest → balik fokus jika masih ada cycle
      if (_currentCycle < totalCycles) {
        _setFocus();
        startTimer();
      } else {
        _onAllCompleted();
      }
    }
  }

  void _setFocus() {
    _currentMode = TimerMode.focus;
    _minutes = focusDuration;
    _seconds = 0;
  }

  void _setRest() {
    _currentMode = TimerMode.rest;
    _minutes = restDuration;
    _seconds = 0;
  }

  void _onAllCompleted() {
    setState(() {
      _isCompleted = true;
      _minutes = 0;
      _seconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Great job! You nailed this focus session. Now take a moment to rest and reset 🚀'),
      ),
    );
  }

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_isCompleted) return Colors.grey;
    return _currentMode == TimerMode.focus
        ? Colors.orange
        : const Color(0xFF5B9FED).withOpacity(0.7);
  }

  Color get _buttonColor {
    if (_isCompleted) return Colors.grey;
    return _currentMode == TimerMode.focus ? Colors.orange : const Color(0xFF5B9FED);
  }

  String get _message {
    if (_isCompleted) return 'Done!';
    return _currentMode == TimerMode.focus ? 'Keep Going!' : 'Chill dulu bro!';
  }

  String get _title {
    if (_isCompleted) return 'Done!';
    return _currentMode == TimerMode.focus ? 'Focus Time!' : 'Rest Time!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.only(
                top: 24,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              decoration: const BoxDecoration(
                color: const Color(0xFF5B9FED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Pomodoro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // biar judul tetap center
                ],
              ),
            ),

            const SizedBox(height: 32),

            // TITLE
            Text(
              _title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            // TIMER CIRCLE
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _timerColor, width: 6),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_minutes, _seconds),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _timerColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _timerColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // CONTROL BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: resetTimer,
                  backgroundColor: Colors.yellow.shade100,
                  foregroundColor:
                      _isCompleted ? Colors.grey : Colors.grey.shade700,
                  mini: true,
                  child: const Icon(Icons.close, size: 24),
                ),
                FloatingActionButton(
                  onPressed:
                      _isCompleted
                          ? null
                          : _isRunning
                          ? pauseTimer
                          : startTimer,
                  backgroundColor: _isCompleted ? Colors.grey : _buttonColor,
                  foregroundColor: Colors.white,
                  mini: true,
                  child: Icon(
                    _isRunning ? Icons.pause : Icons.play_arrow,
                    size: 28,
                  ),
                ),
                FloatingActionButton(
                  onPressed: resetTimer,
                  backgroundColor: Colors.yellow.shade100,
                  foregroundColor:
                      _isCompleted ? Colors.grey : Colors.grey.shade700,
                  mini: true,
                  child: const Icon(Icons.refresh, size: 24),
                ),
              ],
            ),

            const Spacer(),

            // BOTTOM NAV (dummy)
            Container(
              decoration: const BoxDecoration(
                color: const Color(0xFF5B9FED),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    child: const _BottomNavItem(
                      icon: Icons.home_rounded,
                      isActive: false,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/schedule'),
                    child: const _BottomNavItem(
                      icon: Icons.calendar_today,
                      isActive: false,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/manage_task'),
                    child: const _BottomNavItem(
                      icon: Icons.assignment,
                      isActive: false,
                    ),
                  ),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: const _BottomNavItem(
                      icon: Icons.person,
                      isActive: false,
                    ),
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
