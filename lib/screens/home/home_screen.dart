import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/services/daily_content_service.dart';
import 'package:quranfiqh/screens/home/daily_detail_screen.dart';
import 'package:quranfiqh/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ─────────────────────────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────────────────────────

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

  void _navigateToDetail({
    required String category,
    required String title,
    required String subtitle,
    required String details,
    required Color iconColor,
    required String assetPath,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DailyDetailScreen(
          category: category,
          title: title,
          subtitle: subtitle,
          details: details,
          iconColor: iconColor,
          assetPath: assetPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDailyContent,
          color: colorScheme.primary,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const SizedBox(height: 12),

              // ── Greeting Header ──────────────────────────────
              const _GreetingHeader(),

              const SizedBox(height: 20),

              // ── Verse of the Day banner ──────────────────────
              if (_isLoading)
                const _ShimmerBanner()
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
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(height: 12),

              // ── Daily Cards ──────────────────────────────────
              if (_isLoading) ...[
                const _ShimmerCard(),
                const SizedBox(height: 12),
                const _ShimmerCard(),
              ] else ...[
                // Masa'la Card
                _DailyMasalaCard(
                  title: _dailyContent?['masala']?['title'] ?? 'Daily Masa\'la',
                  subtitle: _dailyContent?['masala']?['subtitle'] ?? 'Loading...',
                  onTap: () => _navigateToDetail(
                    category: 'DAILY MASA\'LA',
                    title: _dailyContent?['masala']?['title'] ?? 'Daily Masa\'la',
                    subtitle: _dailyContent?['masala']?['subtitle'] ?? '',
                    details: _dailyContent?['masala']?['details'] ?? 'Detailed explanation loading...',
                    iconColor: const Color(0xFF5378F7),
                    assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tajweed Card
                _TajweedTipCard(
                  title: _dailyContent?['tajweed']?['title'] ?? 'Tajweed Tip',
                  subtitle: _dailyContent?['tajweed']?['subtitle'] ?? 'Loading...',
                  onTap: () => _navigateToDetail(
                    category: 'TAJWEED TIP',
                    title: _dailyContent?['tajweed']?['title'] ?? 'Tajweed Tip',
                    subtitle: _dailyContent?['tajweed']?['subtitle'] ?? '',
                    details: _dailyContent?['tajweed']?['details'] ?? 'Detailed explanation loading...',
                    iconColor: const Color(0xFFF77853),
                    assetPath: 'assets/icons/microphone-01-stroke-rounded.svg',
                  ),
                ),
                const SizedBox(height: 12),
                
                // Dhikr Card
                _DailyDhikrCard(
                  title: _dailyContent?['dhikr']?['title'] ?? 'SubhanAllah wa Bihamdihi',
                  subtitle: _dailyContent?['dhikr']?['subtitle'] ?? 'Praise Allah 100 times for immense rewards.',
                  onTap: () => _navigateToDetail(
                    category: 'DAILY DHIKR',
                    title: _dailyContent?['dhikr']?['title'] ?? 'Daily Dhikr',
                    subtitle: _dailyContent?['dhikr']?['subtitle'] ?? '',
                    details: _dailyContent?['dhikr']?['details'] ?? 'Detailed explanation loading...',
                    iconColor: const Color(0xFF53F778),
                    assetPath: 'assets/icons/stars-02-stroke-rounded.svg',
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Internal Widgets
// ─────────────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authUser = FirebaseAuth.instance.currentUser;
    final user = AuthService().currentUser.value;
    final email = authUser?.email ?? user?.email ?? '';
    final isGuest = user?.isGuest ?? authUser?.isAnonymous ?? true;

    final rawPrefix = email.isNotEmpty ? email.split('@').first : '';
    final emailPrefix = rawPrefix.replaceAll(RegExp(r'\d'), '');
    final fallbackName = user?.name ?? 'User';

    final displayName = isGuest 
        ? 'Brother/Sister' 
        : (emailPrefix.isNotEmpty ? emailPrefix : fallbackName);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assalamu Alaikum,',
              style: AppTextStyles.englishCaption(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            Text(
              displayName,
              style: AppTextStyles.englishDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.scriptureGold.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: SvgPicture.asset(
                  'assets/icons/book-open-02-stroke-rounded.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.scriptureGold,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'VERSE OF THE DAY',
                style: AppTextStyles.englishCaption(
                  color: colorScheme.brightness == Brightness.dark 
                      ? AppColors.scriptureGold 
                      : AppColors.gold,
                  fontSize: 12,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.arabicVerse(
              fontSize: 28,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            translation,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            reference,
            style: AppTextStyles.englishCaption(
              color: AppColors.scriptureGold,
              fontSize: 11,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DailyMasalaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DailyMasalaCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      label: 'DAILY MASA\'LA',
      title: title,
      subtitle: subtitle,
      assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
      iconBg: const Color(0xFFF1F4FF),
      iconColor: const Color(0xFF5378F7),
      badge: 'Shafi\'i',
      onTap: onTap,
    );
  }
}

class _TajweedTipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TajweedTipCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      label: 'TAJWEED TIP',
      title: title,
      subtitle: subtitle,
      assetPath: 'assets/icons/headphones-stroke-rounded.svg',
      iconBg: const Color(0xFFFFF3F1),
      iconColor: const Color(0xFFF77853),
      onTap: onTap,
    );
  }
}

class _DailyDhikrCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DailyDhikrCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      label: 'DAILY DHIKR',
      title: title,
      subtitle: subtitle,
      assetPath: 'assets/icons/bookmark-02-stroke-rounded.svg',
      iconBg: const Color(0xFFF1FFF4),
      iconColor: const Color(0xFF53F778),
      onTap: onTap,
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final String assetPath;
  final Color iconBg;
  final Color iconColor;
  final String? badge;
  final VoidCallback onTap;

  const _InfoCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.iconBg,
    required this.iconColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.brightness == Brightness.dark 
                        ? iconColor.withValues(alpha: 0.1) 
                        : iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: SvgPicture.asset(
                        assetPath,
                        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBanner extends StatelessWidget {
  const _ShimmerBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
