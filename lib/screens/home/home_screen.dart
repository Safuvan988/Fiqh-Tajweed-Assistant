import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            const SizedBox(height: 12),

            // ── Greeting Header ──────────────────────────────
            _GreetingHeader(),

            const SizedBox(height: 20),

            // ── Verse of the Day banner ──────────────────────
            _VerseBanner(),

            const SizedBox(height: 24),

            // ── Section Title ────────────────────────────────
            Text(
              'Your Daily Corner',
              style: AppTextStyles.englishDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 12),

            // ── Daily Cards ──────────────────────────────────
            _DailyMasalaCard(screenWidth: size.width),
            const SizedBox(height: 12),
            _TajweedTipCard(screenWidth: size.width),
            const SizedBox(height: 12),
            _SavedItemsCard(screenWidth: size.width),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Greeting Header
// ─────────────────────────────────────────────────────────────
class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamu Alaikum 👋',
                style: AppTextStyles.englishDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'What would you like to explore today?',
                style: AppTextStyles.englishBody(
                  fontSize: 13,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded,
              color: AppColors.textOnPrimary, size: 24),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Verse Banner
// ─────────────────────────────────────────────────────────────
class _VerseBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Arabic verse
          Text(
            'إِنَّ هَٰذَا الْقُرْآنَ يَهْدِي لِلَّتِي هِيَ أَقْوَمُ',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabicVerse(
              fontSize: 20,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withOpacity(0.2),
          ),
          const SizedBox(height: 10),
          // Translation
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '"Indeed, this Quran guides to that which is most suitable."',
              style: AppTextStyles.englishBody(
                fontSize: 13,
                color: AppColors.textOnPrimary.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Surah Al-Isra 17:9',
                style: AppTextStyles.englishCaption(
                  color: AppColors.gold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shared Card Wrapper
// ─────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String title;
  final String subtitle;
  final String? badge;
  final double screenWidth;
  final VoidCallback? onTap;

  const _InfoCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.screenWidth,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.englishCaption(
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.englishCaption(
                              color: AppColors.gold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: AppTextStyles.englishDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.englishBody(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Daily Masa'la Card
// ─────────────────────────────────────────────────────────────
class _DailyMasalaCard extends StatelessWidget {
  final double screenWidth;
  const _DailyMasalaCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.menu_book_rounded,
      iconBg: AppColors.primary.withOpacity(0.1),
      iconColor: AppColors.primary,
      label: 'DAILY MASA\'LA',
      badge: 'New',
      title: 'Ruling on combining prayers',
      subtitle:
          'Is it permissible to combine Dhuhr and Asr when traveling? '
          'Scholars discuss the conditions…',
      screenWidth: screenWidth,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Tajweed Tip Card
// ─────────────────────────────────────────────────────────────
class _TajweedTipCard extends StatelessWidget {
  final double screenWidth;
  const _TajweedTipCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.headphones_rounded,
      iconBg: AppColors.gold.withOpacity(0.12),
      iconColor: AppColors.gold,
      label: 'TAJWEED TIP',
      title: 'Ikhfa — Concealment',
      subtitle:
          'When a noon sakinah or tanween is followed by one of the 15 Ikhfa letters, '
          'apply a nasal sound with ghunna…',
      screenWidth: screenWidth,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Saved Items Card
// ─────────────────────────────────────────────────────────────
class _SavedItemsCard extends StatelessWidget {
  final double screenWidth;
  const _SavedItemsCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.bookmark_rounded,
      iconBg: AppColors.lightGreen.withOpacity(0.12),
      iconColor: AppColors.lightGreen,
      label: 'SAVED ITEMS',
      title: '4 items bookmarked',
      subtitle: 'Rulings on fasting, Surah Yasin, Ghunnah rules, Wudu fatwas',
      screenWidth: screenWidth,
    );
  }
}
