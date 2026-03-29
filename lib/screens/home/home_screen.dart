import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/services/daily_content_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _dailyContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyContent();
  }

  Future<void> _loadDailyContent() async {
    try {
      final content = await DailyContentService.getDailyContent();
      if (mounted) {
        setState(() {
          _dailyContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDailyContent,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const SizedBox(height: 12),

              // ── Greeting Header ──────────────────────────────
              _GreetingHeader(),

              const SizedBox(height: 20),

              // ── Verse of the Day banner ──────────────────────
              if (_isLoading)
                _ShimmerBanner()
              else
                _VerseBanner(
                  arabic: _dailyContent?['verse']?['arabic'] ?? '',
                  translation: _dailyContent?['verse']?['translation'] ?? '',
                  reference: _dailyContent?['verse']?['reference'] ?? '',
                ),

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
              if (_isLoading) ...[
                _ShimmerCard(),
                const SizedBox(height: 12),
                _ShimmerCard(),
              ] else ...[
                _DailyMasalaCard(
                  screenWidth: size.width,
                  title: _dailyContent?['masala']?['title'] ?? 'Daily Masa\'la',
                  subtitle:
                      _dailyContent?['masala']?['subtitle'] ?? 'Loading...',
                ),
                const SizedBox(height: 12),
                _TajweedTipCard(
                  screenWidth: size.width,
                  title: _dailyContent?['tajweed']?['title'] ?? 'Tajweed Tip',
                  subtitle:
                      _dailyContent?['tajweed']?['subtitle'] ?? 'Loading...',
                ),
              ],
              const SizedBox(height: 12),
              _SavedItemsCard(screenWidth: size.width),

              const SizedBox(height: 24),
            ],
          ),
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
                'السلام عليكم 👋',
                textAlign: TextAlign.left,
                style: AppTextStyles.arabicDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ).copyWith(height: 1.2),
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
        const SizedBox(width: 14),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                'assets/icons/user-03-stroke-rounded.svg',
                semanticsLabel: 'Profile',
                colorFilter: const ColorFilter.mode(
                  AppColors.textOnPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Verse Banner
// ─────────────────────────────────────────────────────────────
class _VerseBanner extends StatelessWidget {
  final String arabic;
  final String translation;
  final String reference;

  const _VerseBanner({
    required this.arabic,
    required this.translation,
    required this.reference,
  });

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
            color: AppColors.primary.withValues(alpha: 0.3),
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
            arabic,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabicVerse(
              fontSize: 24,
              color: AppColors.scriptureGold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 10),
          // Translation
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '"$translation"',
              style: AppTextStyles.englishBody(
                fontSize: 13,
                color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                reference,
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
  final String assetPath;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String title;
  final String subtitle;
  final String? badge;
  final double screenWidth;

  const _InfoCard({
    required this.assetPath,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.screenWidth,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
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
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: SvgPicture.asset(
                  assetPath,
                  semanticsLabel: label,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
            ),
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
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
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

          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Daily Masa'la Card
// ─────────────────────────────────────────────────────────────
class _DailyMasalaCard extends StatelessWidget {
  final double screenWidth;
  final String title;
  final String subtitle;

  const _DailyMasalaCard({
    required this.screenWidth,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
      iconBg: AppColors.primary.withValues(alpha: 0.1),
      iconColor: AppColors.primary,
      label: 'DAILY MASA\'LA',
      badge: 'New',
      title: title,
      subtitle: subtitle,
      screenWidth: screenWidth,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Tajweed Tip Card
// ─────────────────────────────────────────────────────────────
class _TajweedTipCard extends StatelessWidget {
  final double screenWidth;
  final String title;
  final String subtitle;

  const _TajweedTipCard({
    required this.screenWidth,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      assetPath: 'assets/icons/headphones-stroke-rounded.svg',
      iconBg: AppColors.gold.withValues(alpha: 0.12),
      iconColor: AppColors.gold,
      label: 'TAJWEED TIP',
      title: title,
      subtitle: subtitle,
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
      assetPath: 'assets/icons/bookmark-02-stroke-rounded.svg',
      iconBg: AppColors.goldAccent.withValues(alpha: 0.12),
      iconColor: AppColors.goldAccent,
      label: 'SAVED ITEMS',
      title: '4 items bookmarked',
      subtitle: 'Rulings on fasting, Surah Yasin, Ghunnah rules, Wudu fatwas',
      screenWidth: screenWidth,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shimmer / Loading UI
// ─────────────────────────────────────────────────────────────
class _ShimmerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 10,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 14,
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
