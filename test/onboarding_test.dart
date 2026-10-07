import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:ginder/providers/app_config_provider.dart';
import 'package:ginder/providers/auth_provider.dart';
import 'package:ginder/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Onboarding Persistence Tests', () {
    test('fresh install has has_completed_onboarding as false', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final appConfig = AppConfigProvider(prefs);
      final auth = AuthProvider(prefs);

      expect(appConfig.hasCompletedOnboarding, isFalse);
      expect(auth.isOnboarded, isFalse);
      expect(prefs.getBool('has_completed_onboarding'), isNull);
    });

    test('completeOnboarding sets flag permanently in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final appConfig = AppConfigProvider(prefs);
      final auth = AuthProvider(prefs);

      await appConfig.completeOnboarding();
      await auth.completeOnboarding();

      expect(appConfig.hasCompletedOnboarding, isTrue);
      expect(auth.isOnboarded, isTrue);
      expect(prefs.getBool('has_completed_onboarding'), isTrue);

      // Simulate app restart by creating new providers with the same prefs
      final restartedAppConfig = AppConfigProvider(prefs);
      final restartedAuth = AuthProvider(prefs);

      expect(restartedAppConfig.hasCompletedOnboarding, isTrue);
      expect(restartedAuth.isOnboarded, isTrue);
    });

    test('logout does NOT reset has_completed_onboarding flag', () async {
      SharedPreferences.setMockInitialValues({'has_completed_onboarding': true});
      final prefs = await SharedPreferences.getInstance();

      final auth = AuthProvider(prefs);
      expect(auth.isOnboarded, isTrue);

      await auth.logout();

      expect(auth.isOnboarded, isTrue);
      expect(prefs.getBool('has_completed_onboarding'), isTrue);
    });

    test('simulating clear app data resets flag', () async {
      SharedPreferences.setMockInitialValues({'has_completed_onboarding': true});
      final prefs = await SharedPreferences.getInstance();

      expect(prefs.getBool('has_completed_onboarding'), isTrue);

      // User clears app data from Android/iOS settings
      await prefs.clear();

      final freshConfig = AppConfigProvider(prefs);
      final freshAuth = AuthProvider(prefs);

      expect(freshConfig.hasCompletedOnboarding, isFalse);
      expect(freshAuth.isOnboarded, isFalse);
      expect(prefs.getBool('has_completed_onboarding'), isNull);
    });
  });

  group('OnboardingScreen Widget Tests', () {
    testWidgets('renders SKIP button and tapping it saves onboarding status', (tester) async {
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
          child: MaterialApp(
            routes: {
              '/login': (_) => const Scaffold(body: Text('LOGIN_SCREEN')),
            },
            home: const OnboardingScreen(),
          ),
        ),
      );

      // Verify SKIP button exists
      final skipFinder = find.text('SKIP');
      expect(skipFinder, findsOneWidget);

      // Tap SKIP
      await tester.tap(skipFinder);
      await tester.pumpAndSettle();

      // Verify navigated to login
      expect(find.text('LOGIN_SCREEN'), findsOneWidget);

      // Verify onboarding status is saved permanently in prefs
      expect(prefs.getBool('has_completed_onboarding'), isTrue);
      expect(appConfig.hasCompletedOnboarding, isTrue);
      expect(auth.isOnboarded, isTrue);
    });
  });
}
