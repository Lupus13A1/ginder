import 'package:flutter/material.dart';

/// Bauhaus design system color palette
abstract final class BauhausColors {
  /// Off-white canvas background
  static const Color background = Color(0xFFF0F0F0);

  /// Stark black for text, icons, and sharp shadows
  static const Color foreground = Color(0xFF121212);

  /// Authentic Bauhaus Red
  static const Color primaryRed = Color(0xFFD02020);

  /// Authentic Bauhaus Blue
  static const Color primaryBlue = Color(0xFF1040C0);

  /// Authentic Bauhaus Yellow
  static const Color primaryYellow = Color(0xFFF0C020);

  /// Thick black border color (equivalent to foreground)
  static const Color border = Color(0xFF121212);

  /// Pure white surface for cards and text fields
  static const Color surface = Color(0xFFFFFFFF);

  /// Muted gray for dividers and subtle backgrounds
  static const Color muted = Color(0xFFE0E0E0);

  /// Light yellow highlight for badges and accent containers
  static const Color cardYellow = Color(0xFFFFF9C4);

  /// Light blue highlight
  static const Color cardBlue = Color(0xFFD6E4FF);

  /// Light red highlight
  static const Color cardRed = Color(0xFFFFD8D8);

  /// Secondary dark surface
  static const Color surfaceDark = Color(0xFF1E1E1E);
}
