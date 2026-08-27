import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bauhaus_colors.dart';

/// Bauhaus typography styles using GoogleFonts Outfit
abstract final class BauhausTextStyles {
  /// Display / Hero text style (36pt, w900)
  static TextStyle display({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.0,
        height: 0.95,
        color: color,
      );

  /// Massive Hero title (48pt, w900)
  static TextStyle hero({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        height: 0.9,
        color: color,
      );

  /// Headline Large (26pt, w900)
  static TextStyle headlineLarge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        color: color,
      );

  /// Headline Medium (20pt, w800)
  static TextStyle headlineMedium({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
      );

  /// Subheading / Title (16pt, w700)
  static TextStyle title({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Body Large (15pt, w500)
  static TextStyle bodyLarge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  /// Body Medium (13pt, w500)
  static TextStyle bodyMedium({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: color,
      );

  /// Button / Label / Badge (14pt, w800, Uppercase letterspacing)
  static TextStyle button({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color,
      );

  /// Compact Badge label (11pt, w800)
  static TextStyle badge({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        color: color,
      );

  /// Caption (11pt, w600)
  static TextStyle caption({Color color = BauhausColors.foreground}) =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );
}
