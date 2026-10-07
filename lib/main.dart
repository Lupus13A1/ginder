import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/bauhaus_colors.dart';
import 'theme/bauhaus_theme.dart';
import 'providers/app_config_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/discover_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'routes/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Google Sign-In (required for google_sign_in v7+)
  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize(hostedDomain: 'email.kmutnb.ac.th');
  }

  final prefs = await SharedPreferences.getInstance();
  final appConfig = AppConfigProvider(prefs);
  BauhausColors.isDark = appConfig.isDark;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: appConfig.isDark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: appConfig.isDark
          ? const Color(0xFF0F172A)
          : Colors.white,
      systemNavigationBarIconBrightness: appConfig.isDark
          ? Brightness.light
          : Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appConfig),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => DiscoverProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const GinderApp(),
    ),
  );
}

class GinderApp extends StatelessWidget {
  const GinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appConfig = Provider.of<AppConfigProvider?>(context);
    final themeMode = appConfig?.themeMode ?? ThemeMode.system;
    final language = appConfig?.language ?? 'en';

    if (appConfig != null) {
      BauhausColors.isDark = appConfig.isDark;
    }

    return MaterialApp(
      title: 'GINDER',
      debugShowCheckedModeBanner: false,
      theme: BauhausTheme.lightTheme,
      darkTheme: BauhausTheme.darkTheme,
      themeMode: themeMode,
      locale: Locale(language),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
