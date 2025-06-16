import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animation/restartlang.dart';
import 'animation/splash.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Alarm.init();
  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Set up system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Load the saved language from shared preferences
  final locale = await _loadSavedLocale();

  // Run the application
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: locale,
      child: const RestartWidget(
        child: MyApp(),
      ),
    ),
  );
}

// Function to load saved locale from shared preferences
Future<Locale> _loadSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'en';
  final countryCode = prefs.getString('country_code') ?? 'US';
  return Locale(languageCode, countryCode);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to update and save the language preference
  Future<void> setLanguage(Locale locale, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');

    // Restart the app to apply changes
    // ignore: use_build_context_synchronously
    context.setLocale(locale);
    // ignore: use_build_context_synchronously
    RestartWidget.restartApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dawini",
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
