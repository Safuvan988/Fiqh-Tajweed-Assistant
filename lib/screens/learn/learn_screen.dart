import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: Center(
        child: Text(
          'Learn Screen — Coming Soon',
          style: AppTextStyles.englishBody(color: AppColors.textLight),
        ),
      ),
    );
  }
}
