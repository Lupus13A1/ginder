import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ginder/providers/app_config_provider.dart';
import 'package:ginder/providers/auth_provider.dart';
import 'package:ginder/theme/bauhaus_colors.dart';
import 'package:ginder/screens/settings/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Theme System Unit Tests', () {
    test(
      'Initializes with ThemeMode.system by default when no preference saved',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final appConfig = AppConfigProvider(prefs);

        expect(appConfig.themeMode, equals(ThemeMode.system));
        expect(prefs.getString('app_theme_mode'), isNull);
      },
    );

    test(
      'Loads saved ThemeMode.dark correctly from SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
        final prefs = await SharedPreferences.getInstance();
        final appConfig = AppConfigProvider(prefs);

        expect(appConfig.themeMode, equals(ThemeMode.dark));
        expect(appConfig.isDark, isTrue);
        expect(BauhausColors.isDark, isTrue);
      },
    );

    test(
      'Loads saved ThemeMode.light correctly from SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({'app_theme_mode': 'light'});
        final prefs = await SharedPreferences.getInstance();
        final appConfig = AppConfigProvider(prefs);

        expect(appConfig.themeMode, equals(ThemeMode.light));
        expect(appConfig.isDark, isFalse);
        expect(BauhausColors.isDark, isFalse);
      },
    );

    test(
      'Switching ThemeMode updates state, BauhausColors, and persists to SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final appConfig = AppConfigProvider(prefs);

        // Switch to Light
        await appConfig.setThemeMode(ThemeMode.light);
        expect(appConfig.themeMode, equals(ThemeMode.light));
        expect(appConfig.isDark, isFalse);
        expect(BauhausColors.isDark, isFalse);
        expect(prefs.getString('app_theme_mode'), equals('light'));

        // Switch to Dark
        await appConfig.setThemeMode(ThemeMode.dark);
        expect(appConfig.themeMode, equals(ThemeMode.dark));
        expect(appConfig.isDark, isTrue);
        expect(BauhausColors.isDark, isTrue);
        expect(prefs.getString('app_theme_mode'), equals('dark'));

        // Switch to System
        await appConfig.setThemeMode(ThemeMode.system);
        expect(appConfig.themeMode, equals(ThemeMode.system));
        expect(prefs.getString('app_theme_mode'), equals('system'));
      },
    );

    test(
      'BauhausColors semantic getters adapt between light and dark modes',
      () {
        BauhausColors.isDark = false;
        expect(BauhausColors.background, equals(const Color(0xFFF8F9FA)));
        expect(BauhausColors.surface, equals(const Color(0xFFFFFFFF)));
        expect(BauhausColors.foreground, equals(const Color(0xFF1E293B)));
        expect(BauhausColors.textSecondary, equals(const Color(0xFF64748B)));

        BauhausColors.isDark = true;
        expect(BauhausColors.background, equals(const Color(0xFF0F172A)));
        expect(BauhausColors.surface, equals(const Color(0xFF1E293B)));
        expect(BauhausColors.foreground, equals(const Color(0xFFF8FAFC)));
        expect(BauhausColors.textSecondary, equals(const Color(0xFF94A3B8)));
        expect(BauhausColors.successText, equals(const Color(0xFF6EE7B7)));
      },
    );
  });

  group('SettingsScreen Theme UI Tests', () {
    testWidgets(
      'Displays Theme choices strictly in Light -> Dark -> System order',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final appConfig = AppConfigProvider(prefs);
        final auth = AuthProvider(prefs);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: appConfig),
              ChangeNotifierProvider.value(value: auth),
            ],
            child: const MaterialApp(home: SettingsScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Find all segment pills in Theme section
        final lightFinder = find.text('LIGHT');
        final darkFinder = find.text('DARK');
        final systemFinder = find.text('SYSTEM');

        expect(lightFinder, findsOneWidget);
        expect(darkFinder, findsOneWidget);
        expect(systemFinder, findsOneWidget);

        // Verify order on screen: Light (x1) < Dark (x2) < System (x3)
        final lightX = tester.getCenter(lightFinder).dx;
        final darkX = tester.getCenter(darkFinder).dx;
        final systemX = tester.getCenter(systemFinder).dx;

        expect(lightX, lessThan(darkX), reason: 'LIGHT must precede DARK');
        expect(darkX, lessThan(systemX), reason: 'DARK must precede SYSTEM');
      },
    );

    testWidgets('Tapping Dark pill switches theme to Dark and highlights it', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final appConfig = AppConfigProvider(prefs);
      final auth = AuthProvider(prefs);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appConfig),
            ChangeNotifierProvider.value(value: auth),
          ],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Initially in System mode
      expect(appConfig.themeMode, equals(ThemeMode.system));

      // Tap DARK
      await tester.tap(find.text('DARK'));
      await tester.pumpAndSettle();

      expect(appConfig.themeMode, equals(ThemeMode.dark));
      expect(appConfig.isDark, isTrue);

      // Tap LIGHT
      await tester.tap(find.text('LIGHT'));
      await tester.pumpAndSettle();

      expect(appConfig.themeMode, equals(ThemeMode.light));
      expect(appConfig.isDark, isFalse);

      // Tap SYSTEM
      await tester.tap(find.text('SYSTEM'));
      await tester.pumpAndSettle();

      expect(appConfig.themeMode, equals(ThemeMode.system));
    });
  });
}
