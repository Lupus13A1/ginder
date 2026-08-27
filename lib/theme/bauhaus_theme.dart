import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bauhaus_colors.dart';
import 'bauhaus_text_styles.dart';

/// Bauhaus application ThemeData configuration
abstract final class BauhausTheme {
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BauhausColors.primaryRed,
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
        primary: BauhausColors.primaryRed,
        onPrimary: Colors.white,
        secondary: BauhausColors.primaryBlue,
        onSecondary: Colors.white,
        tertiary: BauhausColors.primaryYellow,
        onTertiary: BauhausColors.foreground,
        error: BauhausColors.primaryRed,
        onError: Colors.white,
        surface: BauhausColors.surface,
        onSurface: BauhausColors.foreground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BauhausColors.surface,
        foregroundColor: BauhausColors.foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: BauhausTextStyles.headlineMedium(),
        shape: const Border(
          bottom: BorderSide(color: BauhausColors.border, width: 3.0),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: BauhausColors.border,
        thickness: 3.0,
        space: 3.0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: BauhausColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: BauhausColors.border, width: 3.5),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BauhausColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: BauhausColors.border, width: 3.5),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: BauhausColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: BauhausColors.border, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: BauhausColors.border, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: BauhausColors.primaryBlue, width: 3.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: BauhausColors.primaryRed, width: 2.5),
        ),
      ),
    );
  }
}
