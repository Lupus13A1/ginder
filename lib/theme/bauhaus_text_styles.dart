import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bauhaus_colors.dart';

/// Premium typography styles using GoogleFonts Inter
abstract final class BauhausTextStyles {
  /// Display / Hero text style (36pt, w700)
  static TextStyle display({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.1,
        color: color,
      );

  /// Massive Hero title (48pt, w700)
  static TextStyle hero({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
        color: color,
      );

  /// Headline Large (26pt, w700)
  static TextStyle headlineLarge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  /// Headline Medium (20pt, w600)
  static TextStyle headlineMedium({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      );

  /// Subheading / Title (16pt, w600)
  static TextStyle title({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Body Large (15pt, w400)
  static TextStyle bodyLarge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  /// Body Medium (14pt, w400)
  static TextStyle bodyMedium({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  /// Button / Label (14pt, w600, mild letterspacing)
  static TextStyle button({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  /// Compact Badge label (12pt, w600)
  static TextStyle badge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  /// Caption (12pt, w500)
  static TextStyle caption({Color color = BauhausColors.foreground}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
