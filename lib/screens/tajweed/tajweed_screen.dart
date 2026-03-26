import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class TajweedScreen extends StatelessWidget {
  const TajweedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tajweed')),
      body: Center(
        child: Text(
          'Tajweed Screen — Coming Soon',
          style: AppTextStyles.englishBody(color: AppColors.textLight),
        ),
      ),
    );
  }
}
