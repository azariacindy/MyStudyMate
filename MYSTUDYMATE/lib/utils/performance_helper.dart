import 'package:flutter/foundation.dart';
import 'dart:async';

/// Performance helper untuk monitoring dan optimization
class PerformanceHelper {
  static final PerformanceHelper _instance = PerformanceHelper._internal();
  factory PerformanceHelper() => _instance;
  PerformanceHelper._internal();

  final Map<String, DateTime> _timers = {};
  final Map<String, int> _buildCounts = {};

  /// Start timer untuk measure operation duration
  void startTimer(String key) {
    _timers[key] = DateTime.now();
  }

  /// Stop timer dan print duration (debug only)
  void stopTimer(String key) {
    if (!kDebugMode) return;
    
    final startTime = _timers[key];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      debugPrint('⏱️ $key took ${duration.inMilliseconds}ms');
      _timers.remove(key);
    }
  }

  /// Track widget build counts (debug only)
  void trackBuild(String widgetName) {
    if (!kDebugMode) return;
    
    _buildCounts[widgetName] = (_buildCounts[widgetName] ?? 0) + 1;
    
    // Warn if widget rebuilds too frequently
    if (_buildCounts[widgetName]! > 100) {
      debugPrint('⚠️ Warning: $widgetName has rebuilt ${_buildCounts[widgetName]} times');
    }
  }

  /// Print build statistics (debug only)
  void printBuildStats() {
    if (!kDebugMode) return;
    
    debugPrint('\n📊 Widget Build Statistics:');
    _buildCounts.forEach((widget, count) {
      debugPrint('  $widget: $count builds');
    });
    debugPrint('');
  }

  /// Reset all statistics
  void reset() {
    _timers.clear();
    _buildCounts.clear();
  }

  /// Measure async operation duration
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    if (!kDebugMode) return await operation();
    
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();
      debugPrint('⏱️ $operationName took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }

  /// Measure sync operation duration
  static T measure<T>(
    String operationName,
    T Function() operation,
  ) {
    if (!kDebugMode) return operation();
    
    final stopwatch = Stopwatch()..start();
    try {
      final result = operation();
      stopwatch.stop();
      debugPrint('⏱️ $operationName took ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } catch (e) {
      stopwatch.stop();
      debugPrint('❌ $operationName failed after ${stopwatch.elapsedMilliseconds}ms: $e');
      rethrow;
    }
  }
}

/// Debouncer class untuk debouncing function calls
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttle helper untuk prevent rapid function calls
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  void throttle(VoidCallback callback) {
    if (_isThrottled) return;
    
    _isThrottled = true;
    callback();
    
    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Helper untuk lazy initialization
class LazyValue<T> {
  T Function() _builder;
  T? _value;
  bool _initialized = false;

  LazyValue(this._builder);

  T get value {
    if (!_initialized) {
      _value = _builder();
      _initialized = true;
    }
    return _value!;
  }

  void reset() {
    _value = null;
    _initialized = false;
  }
}

/// Memory cache dengan size limit
class MemoryCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _keys = [];

  MemoryCache({this.maxSize = 100});

  V? get(K key) => _cache[key];

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing
      _cache[key] = value;
      return;
    }

    // Add new
    if (_keys.length >= maxSize) {
      // Remove oldest
      final oldestKey = _keys.removeAt(0);
      _cache.remove(oldestKey);
    }

    _keys.add(key);
    _cache[key] = value;
  }

  void remove(K key) {
    _cache.remove(key);
    _keys.remove(key);
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }

  int get length => _cache.length;
  bool get isEmpty => _cache.isEmpty;
  bool get isNotEmpty => _cache.isNotEmpty;
}
