import 'package:flutter/material.dart';
import '../models/student_profile.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile_setup/profile_setup_screen.dart';
import '../screens/main_nav_shell.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/safety/safety_report_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/discover/match_screen.dart';

/// Centralized route name constants for URL-based navigation.
class AppRoutes {
  AppRoutes._();

  // ── Auth & Onboarding ──────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String profileSetup = '/profile-setup';

  // ── Main Tabs (Shell) ──────────────────────────────────
  static const String home = '/home';
  static const String discover = '/discover';
  static const String explore = '/explore';
  static const String matches = '/matches';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // ── Sub-screens ────────────────────────────────────────
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String safety = '/safety';
  static const String chat = '/chat';        // argument: String conversationId
  static const String matchFound = '/match'; // argument: StudentProfile peer

  /// Route table for simple (no-argument) screens.
  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        profileSetup: (_) => const ProfileSetupScreen(),
        home: (_) => const MainNavShell(),
        discover: (_) => const MainNavShell(initialIndex: 0),
        explore: (_) => const MainNavShell(initialIndex: 1),
        matches: (_) => const MainNavShell(initialIndex: 2),
        notifications: (_) => const MainNavShell(initialIndex: 3),
        profile: (_) => const MainNavShell(initialIndex: 4),
        editProfile: (_) => const EditProfileScreen(),
        settings: (_) => const SettingsScreen(),
        safety: (_) => const SafetyReportScreen(),
      };

  /// Handle routes that require arguments (chat, match celebration).
  static Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    // First check the simple routes table
    final builder = routes[routeSettings.name];
    if (builder != null) {
      return MaterialPageRoute(
        settings: routeSettings,
        builder: builder,
      );
    }

    // Parameterized routes
    switch (routeSettings.name) {
      case chat:
        final conversationId = routeSettings.arguments as String?;
        if (conversationId == null) {
          return _errorRoute('Chat requires a conversationId argument.');
        }
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => ChatScreen(conversationId: conversationId),
        );

      case matchFound:
        final peer = routeSettings.arguments as StudentProfile?;
        if (peer == null) {
          return _errorRoute('Match screen requires a StudentProfile argument.');
        }
        return MaterialPageRoute(
          settings: routeSettings,
          fullscreenDialog: true,
          builder: (_) => MatchScreen(peer: peer),
        );

      default:
        return null;
    }
  }

  /// Fallback error route for unknown paths.
  static Route<dynamic> onUnknownRoute(RouteSettings routeSettings) {
    return _errorRoute('Page not found: ${routeSettings.name}');
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message, style: const TextStyle(fontSize: 16))),
      ),
    );
  }
}
