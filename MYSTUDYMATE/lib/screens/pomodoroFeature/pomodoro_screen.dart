
import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';

// enum harus di luar class
enum TimerMode { focus, rest }

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  // Konfigurasi - Total 1 jam (60 menit)
  // 2 cycles: (25 min focus + 5 min rest) x 2 = 60 min
  static const int totalCycles = 2;
  static const int focusDuration = 25; // menit
  static const int restDuration = 5; // menit

  TimerMode _currentMode = TimerMode.focus;
  int _currentCycle = 1; // mulai dari cycle 1
  int _minutes = focusDuration;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  Timer? _timer;

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
      _currentCycle = 1;
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
      // selesai fokus → masuk rest (cycle yang sama)
      if (_currentCycle <= totalCycles) {
        _setRest();
        startTimer(); // auto lanjut rest
      } else {
        _onAllCompleted();
      }
    } else {
      // selesai rest → naikkan cycle & balik fokus
      if (_currentCycle < totalCycles) {
        _currentCycle++;
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
      _isRunning = false;
      _minutes = 0;
      _seconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Congrats! You just finished a full 1-hour Pomodoro session. Time to recharge!'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  String _formatTime(int minutes, int seconds) {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_isCompleted) return 1.0;
    
    int totalSeconds = _currentMode == TimerMode.focus
        ? focusDuration * 60
        : restDuration * 60;
    int currentSeconds = (_minutes * 60) + _seconds;
    
    return 1.0 - (currentSeconds / totalSeconds);
  }

  Color get _timerColor {
    if (_isCompleted) return Colors.green;
    return _currentMode == TimerMode.focus
        ? const Color(0xFFFFA726) // Orange untuk focus
        : const Color(0xFF5B9FED); // Blue untuk rest
  }

  Color get _buttonColor {
    if (_isCompleted) return Colors.green;
    return _currentMode == TimerMode.focus 
        ? const Color(0xFFFFA726) 
        : const Color(0xFF5B9FED);
  }

  String get _message {
    if (_isCompleted) return 'Well Done!';
    return _currentMode == TimerMode.focus ? 'Keep Going!' : 'Chill dulu bro!';
  }

  String get _title {
    if (_isCompleted) return 'Session Complete! 🎉';
    return _currentMode == TimerMode.focus ? 'Focus Time!' : 'Rest Time!';
  }

  String get _cycleInfo {
    if (_isCompleted) return '2/2 cycles completed';
    return 'Cycle $_currentCycle of $totalCycles';
  }

  Future<bool> _onWillPop() async {
    // Jika timer tidak berjalan atau sudah selesai, langsung keluar
    if (!_isRunning && !_isCompleted) {
      return true;
    }

    // Jika timer sedang berjalan atau ada progress, tampilkan warning
    if (_isRunning || (_currentCycle > 1 || _minutes < focusDuration)) {
      final shouldPop = await showDialog<bool>(
        context: context,
        barrierDismissible: false, // User harus pilih salah satu opsi
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Exit Pomodoro?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            _isRunning
                ? 'Your timer is still running. Are you sure you want to exit? Your progress will be lost.'
                : 'You have made progress in this session. Exit anyway?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Stay',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }

    return true;
  }

  Future<void> _handleNavigation(BuildContext context, String routeName) async {
    // Cek apakah ada progress yang perlu disimpan
    if (_isRunning || (_currentCycle > 1 || _minutes < focusDuration)) {
      final shouldLeave = await _showNavigationWarning();
      
      if (shouldLeave && context.mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, routeName);
      }
    } else {
      // Langsung navigasi jika tidak ada progress
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    }
  }

  Future<bool> _showNavigationWarning() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.timer_off_outlined,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Leave Pomodoro?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRunning
                  ? 'Your Pomodoro timer is currently running!'
                  : 'You have an ongoing Pomodoro session.',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Leaving now will stop the timer and you\'ll lose all progress. Are you sure?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay & Continue',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: const Text(
              'Leave Anyway',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: SafeArea(
        child: Column(
          children: [
            // === TOP HEADER SECTION (sama seperti Schedule) ===
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
                          onPressed: () async {
                            final shouldPop = await _onWillPop();
                            if (shouldPop && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      // Title
                      const Expanded(
                        child: Text(
                          'Pomodoro',
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

            const SizedBox(height: 20),

            // === MAIN CONTENT ===
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TITLE
                    Text(
                      _title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CYCLE INFO
                    Text(
                      _cycleInfo,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // TIMER CIRCLE WITH PROGRESS
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress circle
                        SizedBox(
                          width: 260,
                          height: 260,
                          child: CircularProgressIndicator(
                            value: _progress,
                            strokeWidth: 10,
                            backgroundColor: _timerColor.withOpacity(0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                          ),
                        ),
                        // Timer display
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _formatTime(_minutes, _seconds),
                              style: const TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _message,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: _timerColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // CONTROL BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Play/Pause Button (Main - Center)
                        GestureDetector(
                          onTap: _isCompleted
                              ? null
                              : _isRunning
                                  ? pauseTimer
                                  : startTimer,
                          child: Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _buttonColor,
                              boxShadow: [
                                BoxShadow(
                                  color: _buttonColor.withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRunning ? Icons.pause : Icons.play_arrow,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(width: 35),

                        // Reset Button (Side)
                        GestureDetector(
                          onTap: resetTimer,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCompleted 
                                  ? Colors.grey.shade300 
                                  : Colors.yellow.shade100,
                              boxShadow: _isCompleted ? null : [
                                BoxShadow(
                                  color: Colors.yellow.shade200.withOpacity(0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.refresh,
                              size: 34,
                              color: _isCompleted 
                                  ? Colors.grey.shade500 
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
        ),
        // Bottom Navigation dengan custom handler untuk warning
        bottomNavigationBar: CustomBottomNav(
          currentIndex: -1,
          onTap: (index) {
            // Handle navigation dengan warning
            switch (index) {
              case 0:
                _handleNavigation(context, '/home');
                break;
              case 1:
                _handleNavigation(context, '/schedule');
                break;
              case 2:
                _handleNavigation(context, '/manage_task');
                break;
              case 3:
                _handleNavigation(context, '/profile');
                break;
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
