import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/widgets/main_scaffold.dart';
import 'package:quranfiqh/services/theme_service.dart';

import 'package:quranfiqh/services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Services
  await ThemeService.init();
  AudioService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Fiqh & Tajweed Assistant',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const MainScaffold(),
        );
      },
    );
  }
}
