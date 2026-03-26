import 'package:flutter/material.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/screens/ask/ask_screen.dart';
import 'package:quranfiqh/screens/home/home_screen.dart';
import 'package:quranfiqh/screens/learn/learn_screen.dart';
import 'package:quranfiqh/screens/settings/settings_screen.dart';
import 'package:quranfiqh/screens/tajweed/tajweed_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Keep screens alive when switching tabs
  static const List<Widget> _screens = [
    HomeScreen(),
    AskScreen(),
    LearnScreen(),
    TajweedScreen(),
    SettingsScreen(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_rounded,
      outlineIcon: Icons.home_outlined,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.chat_bubble_rounded,
      outlineIcon: Icons.chat_bubble_outline_rounded,
      label: 'Ask',
    ),
    _NavItem(
      icon: Icons.auto_stories_rounded,
      outlineIcon: Icons.auto_stories_outlined,
      label: 'Learn',
    ),
    _NavItem(
      icon: Icons.headphones_rounded,
      outlineIcon: Icons.headphones_outlined,
      label: 'Tajweed',
    ),
    _NavItem(
      icon: Icons.settings_rounded,
      outlineIcon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves scroll position on each tab
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _AppBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Nav Item model
// ─────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData outlineIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.outlineIcon,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────
//  Custom Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────
class _AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _AppBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return _NavButton(
                icon: selected ? item.icon : item.outlineIcon,
                label: item.label,
                selected: selected,
                onTap: () => onTap(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Individual nav button with animated indicator
// ─────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(selected),
                color: selected ? AppColors.primary : AppColors.textLight,
                size: 24,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style:
                  AppTextStyles.englishCaption(
                    fontSize: 11,
                    color: selected ? AppColors.primary : AppColors.textLight,
                  ).copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
