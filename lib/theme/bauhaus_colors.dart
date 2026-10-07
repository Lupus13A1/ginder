import 'package:flutter/material.dart';

/// Premium design system color palette supporting dynamic Light & Dark themes
abstract final class BauhausColors {
  /// System-wide dark mode flag
  static bool isDark = false;

  /// Off-white canvas background in light; deep charcoal slate in dark
  static Color get background =>
      isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);

  /// Soft dark for text in light; crisp light text in dark
  static Color get foreground =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

  /// Secondary text color (readable in both light & dark modes)
  static Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  /// Muted / placeholder text color
  static Color get textMuted =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  /// Premium accent colors (kept variable names for compatibility)
  static const Color primaryRed = Color(0xFFE11D48); // Elegant Rose
  static const Color primaryBlue = Color(0xFF4F46E5); // Deep Indigo
  static const Color primaryYellow = Color(0xFFF59E0B); // Amber

  /// Soft border color
  static Color get border =>
      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  /// Subtle border / divider color
  static Color get borderSubtle =>
      isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1);

  /// Pure white surface in light; rich slate surface in dark
  static Color get surface =>
      isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  /// Muted gray for dividers and subtle backgrounds
  static Color get muted =>
      isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

  /// Card highlights
  static Color get cardYellow =>
      isDark ? const Color(0xFF2E230D) : const Color(0xFFFEF3C7);
  static Color get cardBlue =>
      isDark ? const Color(0xFF1E224A) : const Color(0xFFE0E7FF);
  static Color get cardRed =>
      isDark ? const Color(0xFF35121D) : const Color(0xFFFFE4E6);

  /// Secondary dark surface
  static Color get surfaceDark =>
      isDark ? const Color(0xFF020617) : const Color(0xFF0F172A);

  /// Status Colors (Semantic Hierarchy)
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successDark = Color(0xFF047857);
  static Color get successLight =>
      isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
  static Color get successBorder =>
      isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFF59E0B); // Amber Warning
  static const Color warningDark = Color(0xFFB45309);
  static Color get warningLight =>
      isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
  static Color get warningBorder =>
      isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A);

  static const Color error = Color(0xFFEF4444); // Crimson Error
  static const Color errorDark = Color(0xFFB91C1C);
  static Color get errorLight =>
      isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFFE4E6);
  static Color get errorBorder =>
      isDark ? const Color(0xFF991B1B) : const Color(0xFFFECDD3);

  static const Color info = Color(0xFF3B82F6); // Azure Info
  static const Color infoDark = Color(0xFF1D4ED8);
  static Color get infoLight =>
      isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
  static Color get infoBorder =>
      isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE);

  /// Semantic text colors with high contrast in both light and dark mode
  static Color get successText =>
      isDark ? const Color(0xFF6EE7B7) : successDark;
  static Color get warningText =>
      isDark ? const Color(0xFFFDE68A) : warningDark;
  static Color get errorText => isDark ? const Color(0xFFFECACA) : errorDark;
  static Color get infoText => isDark ? const Color(0xFFBAE6FD) : infoDark;
}
