import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class LanguageToggle extends StatelessWidget {
  final VoidCallback onToggle;

  const LanguageToggle({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      onPressed: onToggle,
      icon: SizedBox(
        width: 16,
        height: 16,
        child: SvgPicture.asset(
          'assets/icons/language-circle-stroke-rounded.svg',
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
      label: Text(
        'Translate Answer',
        style: AppTextStyles.englishCaption(
          fontSize: 12,
          color: AppColors.primary,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}


