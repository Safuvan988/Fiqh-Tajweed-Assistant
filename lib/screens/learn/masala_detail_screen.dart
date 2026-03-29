import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/screens/learn/learn_screen.dart';

class MasalaDetailScreen extends StatelessWidget {
  final MasalaCategory category;
  const MasalaDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${category.emoji}  ${category.title}'),
        leading: const BackButton(),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: category.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _MasalaCard(
          item: category.items[i],
          accentColor: category.accentColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Masa'la detail card with expandable sections
// ─────────────────────────────────────────────────────────────

class _MasalaCard extends StatefulWidget {
  final MasalaItem item;
  final Color accentColor;
  const _MasalaCard({required this.item, required this.accentColor});

  @override
  State<_MasalaCard> createState() => _MasalaCardState();
}

class _MasalaCardState extends State<_MasalaCard> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: AppTextStyles.englishDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Short Ruling ─────────────────────────────────────
          _SectionTile(
            emoji: '✅',
            label: 'Short Ruling',
            content: widget.item.shortRuling,
            isExpanded: true,
            accentColor: widget.accentColor,
          ),

          // ── Qur'an ───────────────────────────────────────────
          _SectionTile(
            emoji: '📖',
            label: 'Qur\'an',
            content: widget.item.quranRef,
            isExpanded: false,
            accentColor: widget.accentColor,
          ),

          // ── Hadith ───────────────────────────────────────────
          _SectionTile(
            emoji: '🗣️',
            label: 'Hadith',
            content: widget.item.hadithRef,
            isExpanded: false,
            accentColor: widget.accentColor,
          ),

          // ── Details expand ───────────────────────────────────
          const Divider(height: 1),
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            onTap: () => setState(() => _showDetails = !_showDetails),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _showDetails
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showDetails
                        ? 'Hide scholar details'
                        : 'View scholar details',
                    style: AppTextStyles.englishBody(
                      fontSize: 13,
                      color: widget.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.details,
                style: AppTextStyles.englishBody(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            crossFadeState: _showDetails
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _SectionTile extends StatefulWidget {
  final String emoji;
  final String label;
  final String content;
  final bool isExpanded;
  final Color accentColor;

  const _SectionTile({
    required this.emoji,
    required this.label,
    required this.content,
    required this.isExpanded,
    required this.accentColor,
  });

  @override
  State<_SectionTile> createState() => _SectionTileState();
}

class _SectionTileState extends State<_SectionTile> {
  late bool _open;

  @override
  void initState() {
    super.initState();
    _open = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _open = !_open),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.label,
                    style: AppTextStyles.englishDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLight,
                    size: 18,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  widget.content,
                  style: AppTextStyles.englishBody(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
