import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/widgets/main_scaffold.dart';
import 'package:quranfiqh/services/settings_service.dart';
import 'package:quranfiqh/services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quranfiqh/providers/settings_provider.dart';
import 'package:quranfiqh/providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quranfiqh/screens/auth/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase (requires google-services.json or firebase_options.dart)
      try {
        await Firebase.initializeApp();
        // Pass all uncaught "fatal" errors from the framework to Crashlytics
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (e) {
        debugPrint("Firebase initialization failed: $e");
      }

      await dotenv.load(fileName: ".env");

      // Initialize Services (Async load from SharedPreferences)
      await SettingsService().init();
      AudioService.init();

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      debugPrint('Zoned Error: $error');
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Fiqh & Tajweed Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: const AuthWrapper(),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(settings.fontSizeFactor),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainScaffold();
        } else {
          return const LoginScreen();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      ),
      error: (e, stack) => Scaffold(
        body: Center(
          child: Text(
            "Authentication Error: \n$e",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
