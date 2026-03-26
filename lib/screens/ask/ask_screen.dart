import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask')),
      body: Center(
        child: Text(
          'Ask Screen — Coming Soon',
          style: AppTextStyles.englishBody(color: AppColors.textLight),
        ),
      ),
    );
  }
}
