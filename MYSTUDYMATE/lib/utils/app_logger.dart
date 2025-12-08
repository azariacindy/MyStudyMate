import 'package:flutter/foundation.dart';

/// Centralized logging utility
/// Set kDebugMode to false in release builds automatically
class AppLogger {
  // Enable/disable logging globally
  static const bool _enableLogging = kDebugMode;
  
  /// Log info messages (only in debug mode)
  static void info(String message) {
    if (_enableLogging) {
      debugPrint('ℹ️ $message');
    }
  }
  
  /// Log error messages (always show)
  static void error(String message, [Object? error]) {
    if (error != null) {
      debugPrint('❌ ERROR: $message - $error');
    } else {
      debugPrint('❌ ERROR: $message');
    }
  }
  
  /// Log warning messages (only in debug mode)
  static void warning(String message) {
    if (_enableLogging) {
      debugPrint('⚠️ WARNING: $message');
    }
  }
  
  /// Log success messages (only in debug mode)
  static void success(String message) {
    if (_enableLogging) {
      debugPrint('✅ $message');
    }
  }
  
  /// Log network requests (disabled by default for performance)
  static void network(String message) {
    // Disabled for performance - uncomment if needed for debugging
    // if (_enableLogging) {
    //   debugPrint('🌐 $message');
    // }
  }
}
