import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bauhaus_colors.dart';
import 'bauhaus_text_styles.dart';

/// Premium application ThemeData configuration supporting Light & Dark themes
abstract final class BauhausTheme {
  static ThemeData get lightTheme => _buildTheme(isDark: false);
  static ThemeData get darkTheme => _buildTheme(isDark: true);
  static ThemeData get themeData =>
      BauhausColors.isDark ? darkTheme : lightTheme;

  static ThemeData _buildTheme({required bool isDark}) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FA);
    final fg = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);
    final surface = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: BauhausColors.primaryBlue,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      dividerColor: border,
      textTheme: baseTextTheme.copyWith(
        displayLarge: BauhausTextStyles.display(color: fg),
        headlineLarge: BauhausTextStyles.headlineLarge(color: fg),
        headlineMedium: BauhausTextStyles.headlineMedium(color: fg),
        titleLarge: BauhausTextStyles.title(color: fg),
        bodyLarge: BauhausTextStyles.bodyLarge(color: fg),
        bodyMedium: BauhausTextStyles.bodyMedium(color: fg),
        labelLarge: BauhausTextStyles.button(color: fg),
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: BauhausColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: BauhausColors.primaryRed,
        onSecondary: Colors.white,
        tertiary: BauhausColors.primaryYellow,
        onTertiary: isDark ? Colors.black : fg,
        error: BauhausColors.error,
        onError: Colors.white,
        surface: surface,
        onSurface: fg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: BauhausTextStyles.headlineMedium(color: fg),
        shape: Border(bottom: BorderSide(color: border, width: 1.0)),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1.0, space: 1.0),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 10,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1.0),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        elevation: 10,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: BauhausColors.primaryBlue, width: 2.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: BauhausColors.error, width: 1.0),
        ),
      ),
    );
  }
}

/// System-wide design system radius constants ensuring consistent rounded geometry
abstract final class AppRadius {
  static const double sm = 8.0; // Sub-chips, tags, inner icon containers
  static const double md =
      12.0; // Buttons, text fields, dropdowns, input elements
  static const double card = 16.0; // Cards, stat tiles, dialog containers
  static const double lg = 24.0; // Swipe cards, bottom sheets, hero headers
  static const double pill = 999.0; // Badges, status pills, filter chips
}

/// System-wide spacing scale
abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
}

/// System-wide subtle, premium elevation shadows
abstract final class AppShadows {
  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      offset: const Offset(0, 4),
      blurRadius: 14,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
