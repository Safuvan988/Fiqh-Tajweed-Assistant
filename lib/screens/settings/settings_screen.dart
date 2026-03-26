import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Text(
          'Settings Screen — Coming Soon',
          style: AppTextStyles.englishBody(color: AppColors.textLight),
        ),
      ),
    );
  }
}
