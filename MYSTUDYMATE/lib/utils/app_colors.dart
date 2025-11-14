import 'package:flutter/material.dart';

/// AppColors - Sesuai dengan palet warna Figma MyStudyMate
class AppColors {
  // Primary Colors
  static const primary = Color(0xFF4C84F1); // Biru utama
  static const primaryDark = Color(0xFF3B6FD8);
  static const primaryLight = Color(0xFF6B9BF5);
  
  // Background & Surface
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F9FB);
  static const surfaceLight = Color(0xFFFCFCFD);
  
  // Text Colors
  static const text = Color(0xFF0F172A); // Text primary
  static const textSecondary = Color(0xFF64748B); // Text secondary
  static const textLight = Color(0xFF94A3B8); // Text light/disabled
  
  // Status Colors
  static const success = Color(0xFF10B981); // Hijau untuk success
  static const warning = Color(0xFFF59E0B); // Orange untuk warning
  static const error = Color(0xFFEF4444); // Merah untuk error
  static const info = Color(0xFF3B82F6); // Biru untuk info
  
  // Neutral Colors
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFF1F5F9);
  static const disabled = Color(0xFFCBD5E1);
  
  // Special Colors
  static const onPrimary = Colors.white;
  static const shadow = Color(0x1A000000); // 10% black
  
  // Gradient
  static const gradientStart = Color(0xFF4C84F1);
  static const gradientEnd = Color(0xFF3B6FD8);
  
  /// Primary gradient untuk background atau button special
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
}
