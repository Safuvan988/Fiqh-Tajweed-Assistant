import 'package:flutter/material.dart';

import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/widgets/language_toggle.dart';
import 'package:quranfiqh/models/chat_message.dart';

class AnswerCard extends StatefulWidget {
  final LocalizedContent data;
  final String? quranArabic;
  final String? quranReference;
  final String? hadithArabic;
  final String? hadithReference;
  final bool showTranslateButton;
  final VoidCallback? onTranslateTarget;

  const AnswerCard({
    super.key,
    required this.data,
    this.quranArabic,
    this.quranReference,
    this.hadithArabic,
    this.hadithReference,
    this.showTranslateButton = false,
    this.onTranslateTarget,
  });

  @override
  State<AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<AnswerCard> {
  // Read More toggles
  bool _isRulingExpanded = false;
  bool _isFiqhExpanded = false;

  final int _maxLines = 3;

  Widget _buildExpandableTextContent({
    required String text,
    required bool isExpanded,
    required VoidCallback onToggle,
    required TextStyle style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Text(
            text,
            style: style,
            maxLines: isExpanded ? null : _maxLines,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.fade,
          ),
        ),
        // If the text is short, we won't perfectly know without a TextPainter,
        // but for simplicity we rely on the expansion state and just show Read More always if it's potentially long.
        // In a real app we'd use a LayoutBuilder, but we will assume if it's over 100 chars it might need expansion.
        if (text.length > 120)
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isExpanded ? 'Show Less' : 'Read More',
                style: AppTextStyles.englishCaption(
                  fontSize: 12,
                  color: AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // The AnswerCard has exactly the layout of the rich payload.
      children: [
        // 1. Ruling
        if (widget.data.ruling != null) ...[
          _buildExpandableTextContent(
            text: widget.data.ruling!,
            isExpanded: _isRulingExpanded,
            onToggle: () =>
                setState(() => _isRulingExpanded = !_isRulingExpanded),
            style: AppTextStyles.englishBody(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 2. Qur'an
        if (widget.quranReference != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0ED), // Light Gray with a Golden tint
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.scriptureGold.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (widget.quranArabic != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.scriptureGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.quranArabic!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.arabicVerse(
                        fontSize: 30,
                        color: AppColors.scriptureGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '(${widget.quranReference!})',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.data.quranTranslation != null)
                  Text(
                    widget.data.quranTranslation!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.englishBody(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 3. Hadith
        if (widget.hadithReference != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0ED), // Light Gray with a Golden tint
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.scriptureGold.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (widget.hadithArabic != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.scriptureGold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.hadithArabic!,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.arabicVerse(
                        fontSize: 28,
                        color: AppColors.scriptureGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  '(${widget.hadithReference!})',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.data.hadithTranslation != null)
                  Text(
                    widget.data.hadithTranslation!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.englishBody(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 4. Fiqh Explanation
        if (widget.data.fiqhExplanation != null) ...[
          _buildExpandableTextContent(
            text: widget.data.fiqhExplanation!,
            isExpanded: _isFiqhExpanded,
            onToggle: () => setState(() => _isFiqhExpanded = !_isFiqhExpanded),
            style: AppTextStyles.englishBody(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],

        // 5. Other Views
        if (widget.data.otherViews != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Other Views',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E9DE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.data.otherViews!,
              style: AppTextStyles.englishBody(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],

        // 🌐 Translate Button (External logic)
        if (widget.showTranslateButton && widget.onTranslateTarget != null) ...[
          const SizedBox(height: 4),
          const Divider(height: 1),
          const SizedBox(height: 4),
          LanguageToggle(onToggle: widget.onTranslateTarget!),
        ],
      ],
    );
  }
}
