import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/bauhaus_colors.dart';

/// Provider managing system-wide Theme (Light/Dark/System) and Language (EN/TH)
class AppConfigProvider extends ChangeNotifier with WidgetsBindingObserver {
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLanguage = 'app_language';
  static const String _keyOnboardingCompleted = 'has_completed_onboarding';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en'; // Strictly 'en' or 'th'
  bool _hasCompletedOnboarding = false;

  AppConfigProvider(this._prefs) {
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      _syncThemeAndOverlay();
      notifyListeners();
    }
  }

  void _loadPreferences() {
    final savedTheme = _prefs.getString(_keyThemeMode);
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    final savedLanguage = _prefs.getString(_keyLanguage);
    if (savedLanguage == 'th') {
      _language = 'th';
    } else {
      _language = 'en';
    }

    _hasCompletedOnboarding = _prefs.getBool(_keyOnboardingCompleted) ?? false;
    _syncThemeAndOverlay();
  }

  ThemeMode get themeMode => _themeMode;

  /// Effective dark mode boolean resolving Light, Dark, and System modes
  bool get isDark {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // ThemeMode.system
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  String get language => _language;
  bool get isThai => _language == 'th';
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Translate helper: returns Thai text if Thai language is selected, otherwise English
  String tr(String en, String th) => isThai ? th : en;

  void _syncThemeAndOverlay() {
    final dark = isDark;
    BauhausColors.isDark = dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: dark ? const Color(0xFF0F172A) : Colors.white,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  /// Mark onboarding as completed permanently in local storage
  Future<void> completeOnboarding() async {
    if (_hasCompletedOnboarding) return;
    _hasCompletedOnboarding = true;
    await _prefs.setBool(_keyOnboardingCompleted, true);
    notifyListeners();
  }

  /// Update theme mode (Light, Dark, or System)
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    _syncThemeAndOverlay();

    final String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }

    await _prefs.setString(_keyThemeMode, modeString);
    notifyListeners();
  }

  /// Toggle between Light and Dark
  Future<void> toggleTheme() async {
    if (isDark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
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
