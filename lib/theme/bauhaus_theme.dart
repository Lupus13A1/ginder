import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bauhaus_colors.dart';
import 'bauhaus_text_styles.dart';

/// Premium application ThemeData configuration
abstract final class BauhausTheme {
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BauhausColors.primaryBlue,
      scaffoldBackgroundColor: BauhausColors.background,
      canvasColor: BauhausColors.background,
      dividerColor: BauhausColors.border,
      textTheme: baseTextTheme.copyWith(
        displayLarge: BauhausTextStyles.display(),
        headlineLarge: BauhausTextStyles.headlineLarge(),
        headlineMedium: BauhausTextStyles.headlineMedium(),
        titleLarge: BauhausTextStyles.title(),
        bodyLarge: BauhausTextStyles.bodyLarge(),
        bodyMedium: BauhausTextStyles.bodyMedium(),
        labelLarge: BauhausTextStyles.button(),
      ),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: BauhausColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: BauhausColors.primaryRed,
        onSecondary: Colors.white,
        tertiary: BauhausColors.primaryYellow,
        onTertiary: BauhausColors.foreground,
        error: BauhausColors.error,
        onError: Colors.white,
        surface: BauhausColors.surface,
        onSurface: BauhausColors.foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BauhausColors.surface,
        foregroundColor: BauhausColors.foreground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: BauhausTextStyles.headlineMedium(),
        shape: const Border(
          bottom: BorderSide(color: BauhausColors.border, width: 1.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BauhausColors.border,
        thickness: 1.0,
        space: 1.0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BauhausColors.surface,
        elevation: 10,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: BauhausColors.border, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BauhausColors.surface,
        elevation: 10,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BauhausColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BauhausColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BauhausColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: BauhausColors.primaryBlue,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BauhausColors.error, width: 1.0),
        ),
      ),
    );
  }
}
