import 'package:flutter/material.dart';

/// Premium design system color palette
abstract final class BauhausColors {
  /// Off-white canvas background
  static const Color background = Color(0xFFF8F9FA);

  /// Soft dark for text and icons
  static const Color foreground = Color(0xFF1E293B);

  /// Premium accent colors (kept variable names for compatibility)
  static const Color primaryRed = Color(0xFFE11D48); // Elegant Rose
  static const Color primaryBlue = Color(0xFF4F46E5); // Deep Indigo
  static const Color primaryYellow = Color(0xFFF59E0B); // Amber

  /// Soft border color
  static const Color border = Color(0xFFE2E8F0);

  /// Pure white surface for cards and text fields
  static const Color surface = Color(0xFFFFFFFF);

  /// Muted gray for dividers and subtle backgrounds
  static const Color muted = Color(0xFFF1F5F9);

  /// Light highlights for cards
  static const Color cardYellow = Color(0xFFFEF3C7);
  static const Color cardBlue = Color(0xFFE0E7FF);
  static const Color cardRed = Color(0xFFFFE4E6);

  /// Secondary dark surface
  static const Color surfaceDark = Color(0xFF0F172A);

  /// Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
}
