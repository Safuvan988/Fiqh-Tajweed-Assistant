import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:quranfiqh/services/theme_service.dart';

// ─────────────────────────────────────────────────────────────
//  Settings Screen
// ─────────────────────────────────────────────────────────────

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedMadhab = 'Shafi\'i';
  bool _showOtherMadhabs = true;

  final List<String> _languages = [
    'English',
    'Malayalam (മലയാളം)',
    'Arabic (العربية)',
  ];
  final List<String> _madhabs = ['Shafi\'i', 'Hanafi', 'Maliki', 'Hanbali'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── App Preferences ───────────────────────────────
          const _SectionHeader(
            title: 'App Preferences',
            assetPath: 'assets/icons/settings-03-stroke-rounded.svg',
          ),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              // Language Selection
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/icons/language-circle-stroke-rounded.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Language',
                  style: AppTextStyles.englishDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'App interface language',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      borderRadius: BorderRadius.circular(24),
                      dropdownColor: AppColors.surface,
                      focusColor: Colors.transparent,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      elevation: 16,
                      style: AppTextStyles.englishBody(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _selectedLanguage = value);
                        }
                      },
                      items: _languages.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),

              // Theme Selection
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    ThemeService.themeNotifier.value == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: AppColors.gold,
                  ),
                ),
                title: Text(
                  'Theme',
                  style: AppTextStyles.englishDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Switch between Light and Dark',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeService.themeNotifier,
                    builder: (context, mode, _) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<ThemeMode>(
                          value: mode,
                          borderRadius: BorderRadius.circular(24),
                          dropdownColor: AppColors.surface,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          style: AppTextStyles.englishBody(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: (ThemeMode? newMode) {
                            if (newMode != null) {
                              ThemeService.setTheme(newMode);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _SectionHeader(
            title: 'Fiqh Options',
            assetPath: 'assets/icons/book-open-02-stroke-rounded.svg',
          ),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              // Default Madhab
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: SvgPicture.asset(
                        'assets/icons/book-open-02-stroke-rounded.svg',
                        colorFilter: const ColorFilter.mode(
                          AppColors.goldAccent,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Default Madhab',
                  style: AppTextStyles.englishDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Primary school of jurisprudence',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.divider, width: 0.8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMadhab,
                      borderRadius: BorderRadius.circular(24),
                      dropdownColor: AppColors.surface,
                      focusColor: Colors.transparent,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      elevation: 16,
                      style: AppTextStyles.englishBody(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() => _selectedMadhab = value);
                        }
                      },
                      items: _madhabs.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),

              // Show other madhabs toggle
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                activeThumbColor: AppColors.primary,
                title: Text(
                  'Show Other Madhabs',
                  style: AppTextStyles.englishDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Display alternative rulings below the default one in the Ask tab.',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                value: _showOtherMadhabs,
                onChanged: (bool value) {
                  setState(() => _showOtherMadhabs = value);
                },
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── About ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'Fiqh & Tajweed Assistant',
                  style: AppTextStyles.englishDisplay(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.englishCaption(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Helper Widgets
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String assetPath;

  const _SectionHeader({required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: SvgPicture.asset(
              assetPath,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.englishDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
