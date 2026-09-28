import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/bauhaus_colors.dart';

/// Provider managing system-wide Theme (Light/Dark) and Language (EN/TH)
class AppConfigProvider extends ChangeNotifier {
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLanguage = 'app_language';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;
  String _language = 'en'; // Strictly 'en' or 'th'

  AppConfigProvider(this._prefs) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final savedTheme = _prefs.getString(_keyThemeMode);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
      BauhausColors.isDark = true;
    } else {
      _themeMode = ThemeMode.light;
      BauhausColors.isDark = false;
    }

    final savedLanguage = _prefs.getString(_keyLanguage);
    if (savedLanguage == 'th') {
      _language = 'th';
    } else {
      _language = 'en';
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  String get language => _language;
  bool get isThai => _language == 'th';

  /// Translate helper: returns Thai text if Thai language is selected, otherwise English
  String tr(String en, String th) => isThai ? th : en;

  /// Update theme mode (Light / Dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final isDarkMode = mode == ThemeMode.dark;
    BauhausColors.isDark = isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    await _prefs.setString(_keyThemeMode, isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }

  /// Toggle between Light and Dark
  Future<void> toggleTheme() async {
    await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set application language (Strictly 'en' or 'th')
  Future<void> setLanguage(String lang) async {
    if (lang != 'en' && lang != 'th') return;
    if (_language == lang) return;

    _language = lang;
    await _prefs.setString(_keyLanguage, lang);
    notifyListeners();
  }
}
