import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quranfiqh/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quranfiqh/models/user_model.dart';
import 'package:quranfiqh/services/settings_service.dart';
import 'package:quranfiqh/services/chat_history_service.dart';
import 'package:quranfiqh/providers/settings_provider.dart';
import 'package:quranfiqh/providers/auth_provider.dart';
import 'package:quranfiqh/services/auth_service.dart';
import 'package:quranfiqh/services/firestore_service.dart';
import 'package:quranfiqh/screens/bookmarks/bookmarks_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── 👤 Profile ───────────────────────────────────
          const _ProfileHeader(),
          const SizedBox(height: 32),

          // ── 🕌 Fiqh ─────────────────────────────────────
          _SectionHeader(
            title: 'Fiqh',
            icon: 'assets/icons/book-open-02-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _DropdownSetting<Madhab>(
                title: 'Default Madhab',
                subtitle: "Primary school of jurisprudence (Option only - currently not fully working)",
                value: settings.madhab,
                items: const [
                  DropdownMenuItem(
                    value: Madhab.shafii,
                    child: Text("Shafi'i"),
                  ),
                  DropdownMenuItem(value: Madhab.hanafi, child: Text("Hanafi")),
                  DropdownMenuItem(value: Madhab.maliki, child: Text("Maliki")),
                  DropdownMenuItem(
                    value: Madhab.hanbali,
                    child: Text("Hanbali"),
                  ),
                ],
                onChanged: (val) => settingsNotifier.setMadhab(val!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 🌍 Language ─────────────────────────────────
          _SectionHeader(
            title: 'Language',
            icon: 'assets/icons/language-circle-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _DropdownSetting<AppLanguage>(
                title: 'App Language',
                subtitle: 'Interface and content language (Option only - currently not fully working)',
                value: settings.language,
                items: const [
                  DropdownMenuItem(
                    value: AppLanguage.english,
                    child: Text("English"),
                  ),
                  DropdownMenuItem(
                    value: AppLanguage.malayalam,
                    child: Text("Malayalam (മലയാളം)"),
                  ),
                  DropdownMenuItem(
                    value: AppLanguage.arabic,
                    child: Text("Arabic (العربية)"),
                  ),
                ],
                onChanged: (val) => settingsNotifier.setLanguage(val!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 🎨 Appearance ──────────────────────────────
          _SectionHeader(
            title: 'Appearance',
            icon: 'assets/icons/settings-03-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text('Toggle between Light and Dark'),
                value: settings.themeMode == ThemeMode.dark,
                activeThumbColor: colorScheme.primary,
                onChanged: (val) => settingsNotifier.setTheme(
                  val ? ThemeMode.dark : ThemeMode.light,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Adjust app-wide text scale'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('A', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Slider(
                            value: settings.fontSizeFactor,
                            min: 0.8,
                            max: 1.4,
                            divisions: 6,
                            activeColor: colorScheme.primary,
                            onChanged: (val) =>
                                settingsNotifier.setFontSize(val),
                          ),
                        ),
                        const Text(
                          'A',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 🤖 AI ──────────────────────────────────────
          _SectionHeader(
            title: 'AI Assistant',
            icon: 'assets/icons/bubble-chat-add-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _DropdownSetting<AnswerStyle>(
                title: 'Answer Style',
                subtitle: 'Complexity of AI responses (Option only - currently not fully working)',
                value: settings.answerStyle,
                items: const [
                  DropdownMenuItem(
                    value: AnswerStyle.concise,
                    child: Text("Concise"),
                  ),
                  DropdownMenuItem(
                    value: AnswerStyle.detailed,
                    child: Text("Detailed"),
                  ),
                  DropdownMenuItem(
                    value: AnswerStyle.scholarly,
                    child: Text("Scholarly"),
                  ),
                ],
                onChanged: (val) => settingsNotifier.setAnswerStyle(val!),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 📂 Data ─────────────────────────────────────
          _SectionHeader(
            title: 'Data & Privacy',
            icon: 'assets/icons/bookmark-02-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.bookmarks_outlined,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  'Saved Bookmarks',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.blueAccent),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Clear Chat History',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showClearChatDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── ℹ️ About ────────────────────────────────────
          _SectionHeader(
            title: 'About',
            icon: 'assets/icons/stars-02-stroke-rounded.svg',
            iconColor: AppColors.gold,
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text(
                  'QuranFiqh Assistant',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Version 1.2.0'),
                trailing: const Icon(Icons.info_outline),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text('Log Out'),
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authNotifierProvider).logout();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will delete all your local chat history and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ChatHistoryService().clearHistory();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared.')),
              );
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String icon;
  final Color iconColor;
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            icon,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(AppColors.gold, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: AppTextStyles.englishDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 0.8),
      ),
      child: Column(children: children),
    );
  }
}

class _DropdownSetting<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<UserModel?>(
      valueListenable: AuthService().currentUser,
      builder: (context, user, _) {
        final authUser = FirebaseAuth.instance.currentUser;
        final email = authUser?.email ?? user?.email ?? '';
        final isGuest = user?.isGuest ?? authUser?.isAnonymous ?? true;

        final displayName = isGuest ? 'Guest User' : (user?.name ?? 'User');
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

        return Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    if (!isGuest)
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _showEditNameDialog(context, displayName),
                      ),
                  ],
                ),
                if (email.isNotEmpty) Text(email, style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Enter your name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              final navigator = Navigator.of(dialogContext);
              if (newName.isNotEmpty) {
                final authUser = FirebaseAuth.instance.currentUser;
                if (authUser != null) {
                  await authUser.updateDisplayName(newName);
                  final userModel = UserModel(
                    name: newName,
                    email: authUser.email ?? '',
                    isGuest: authUser.isAnonymous,
                    createdAt: authUser.metadata.creationTime,
                  );
                  await FirestoreService.saveUser(authUser.uid, userModel);
                  AuthService().currentUser.value = userModel;
                }
              }
              navigator.pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
