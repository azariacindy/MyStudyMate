
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../services/profile_service.dart';

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
  static const int focusDuration = 1; // menit
  static const int restDuration = 1; // menit

  TimerMode _currentMode = TimerMode.focus;
  int _currentCycle = 1; // mulai dari cycle 1
  int _minutes = focusDuration;
  int _seconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _resetAll();
  }

  Future<void> _initAudioPlayer() async {
    // Set audio player mode ke MEDIA (bukan LOW_LATENCY)
    // Ini akan pakai media volume system, bukan ringer volume
    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Method untuk play notification sound - SIMPLIFIED VERSION
  Future<void> _playNotificationSound() async {
    try {
      debugPrint('🔊 Starting to play notification sound...');
      
      // Stop any playing sound first
      await _audioPlayer.stop();
      
      // Set audio context untuk ensure pakai media volume dengan max gain
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification, // Content type untuk notification/alarm
            usageType: AndroidUsageType.alarm, // Usage type ALARM akan pakai alarm volume (paling keras!)
            audioFocus: AndroidAudioFocus.gainTransient, // Temporary focus untuk notification
          ),
        ),
      );
      
      // Set volume MAX
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Play sound dari URL online (notification beep)
      await _audioPlayer.play(UrlSource('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3'));
      
      debugPrint('✅ Sound played successfully!');
      
      // Triple vibration untuk extra notice
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.heavyImpact();
      
    } catch (e) {
      debugPrint('❌ Error playing sound: $e');
      // Last resort: Multiple strong vibrations
      for (int i = 0; i < 5; i++) {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  // Method untuk show notification dialog
  void _showTransitionNotification(String title, String message, Color color) {
    if (!mounted) return;
    
    // Show dialog dengan auto dismiss
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: color,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _currentMode == TimerMode.rest 
                  ? Icons.coffee_outlined 
                  : Icons.psychology_outlined,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
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
    // Play sound dan vibrate
    _playNotificationSound();
    
    if (_currentMode == TimerMode.focus) {
      // selesai fokus → masuk rest (cycle yang sama)
      if (_currentCycle <= totalCycles) {
        _setRest();
        // Show notification untuk rest time
        _showTransitionNotification(
          '☕ Rest Time!',
          'Great job! Take a 5-minute break and relax.',
          const Color(0xFF5B9FED),
        );
        startTimer(); // auto lanjut rest
      } else {
        _onAllCompleted();
      }
    } else {
      // selesai rest → naikkan cycle & balik fokus
      if (_currentCycle < totalCycles) {
        _currentCycle++;
        _setFocus();
        // Show notification untuk focus time
        _showTransitionNotification(
          '🔥 Focus Time!',
          'Break is over! Time to focus for 25 minutes.',
          const Color(0xFFFFA726),
        );
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

    // Record streak when user completes 2 Pomodoro cycles
    _recordStreak();

    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Congrats! You just finished a full Pomodoro session!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _recordStreak() async {
    try {
      final result = await _profileService.recordStreak();
      
      if (result['success'] == true) {
        final streak = result['streak'] ?? 0;
        final alreadyRecorded = result['already_recorded'] ?? false;
        final isConsecutive = result['is_consecutive'] ?? false;
        
        if (!mounted) return;
        
        // Show streak dialog
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  alreadyRecorded
                      ? 'Streak Maintained!'
                      : (isConsecutive ? 'Streak +1!' : 'New Streak!'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B6B),
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$streak',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      streak == 1 ? 'day' : 'days',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  alreadyRecorded
                      ? 'Keep up the great work!'
                      : (isConsecutive
                          ? 'You\'re on fire! Keep the momentum going!'
                          : 'Great start! Complete tomorrow to continue!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error recording streak: $e');
      // Don't show error to user, streak recording is optional
    }
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
    // Jika sudah selesai, langsung keluar tanpa warning
    if (_isCompleted) {
      return true;
    }

    // Jika timer tidak berjalan dan belum ada progress, langsung keluar
    if (!_isRunning && _currentCycle == 1 && _minutes == focusDuration) {
      return true;
    }

    // Tampilkan warning yang sama dengan navigation
    final shouldPop = await _showNavigationWarning();
    if (shouldPop) {
      _timer?.cancel();
    }
    return shouldPop;
  }

  Future<void> _handleNavigation(BuildContext context, String routeName) async {
    // Jika sudah selesai, langsung navigasi tanpa warning
    if (_isCompleted) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
      return;
    }

    // Jika timer tidak berjalan dan belum ada progress, langsung navigasi
    if (!_isRunning && _currentCycle == 1 && _minutes == focusDuration) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
      return;
    }

    // Tampilkan warning jika ada progress
    final shouldLeave = await _showNavigationWarning();
    
    if (shouldLeave && context.mounted) {
      _timer?.cancel();
      Navigator.pushReplacementNamed(context, routeName);
    }
  }

  Future<bool> _showNavigationWarning() async {
    if (!mounted) return false;
    
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false, // Penting untuk nested navigator
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
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
            onPressed: () => Navigator.of(dialogContext).pop(true),
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
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () async {
                          final shouldPop = await _onWillPop();
                          if (shouldPop && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
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
