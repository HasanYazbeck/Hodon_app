import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/theme/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final hintColor = context.appTextHint;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        children: [
          _Section(title: 'Preferences', items: [
            _SettingsItem(
                icon: Icons.language_rounded,
                label: 'Language',
                trailing: const Text('English')),
            _SettingsItem(
              icon: Icons.dark_mode_rounded,
              label: 'Dark Mode',
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
              ),
            ),
            _SettingsItem(
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                trailing: const Switch(value: true, onChanged: null)),
          ]),
          // const SizedBox(height: AppSizes.md),
          // _Section(title: 'Support', items: [
          //   // _SettingsItem(
          //   //   icon: Icons.help_outline_rounded,
          //   //   label: 'Help & Support',
          //   //   onTap: () => context.push('/help-support'),
          //   // ),
          //   // _SettingsItem(icon: Icons.chat_rounded, label: 'Contact Us', onTap: () => context.push('/contact-us')),
          //   _SettingsItem(icon: Icons.bug_report_rounded, label: 'Report a Bug', onTap: () {}),
          // ]),
          const SizedBox(height: AppSizes.md),
          _Section(title: 'Legal', items: [
            _SettingsItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => context.push('/terms-and-conditions')),
            _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {}),
          ]),
          const SizedBox(height: AppSizes.md),
          _Section(items: [
            _SettingsItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: AppColors.error,
              onTap: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
          ]),
          const SizedBox(height: AppSizes.lg),
          Center(
            child: Text(
              'Hodon v1.0.0\nMade with ❤️ in Lebanon',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: hintColor),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String? title;
  final List<_SettingsItem> items;

  const _Section({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.appSurface;
    final borderColor = context.appBorder;
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: secondaryTextColor)),
          const SizedBox(height: AppSizes.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item.color ?? AppColors.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(item.icon,
                        size: 18, color: item.color ?? AppColors.primary),
                  ),
                  title: Text(item.label,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: item.color)),
                  trailing: item.trailing ??
                      (item.onTap != null
                          ? Icon(Icons.chevron_right_rounded,
                              size: 18, color: hintColor)
                          : null),
                  onTap: item.onTap,
                ),
                if (!isLast) const Divider(height: 1, indent: 56),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsItem(
      {required this.icon,
      required this.label,
      this.trailing,
      this.onTap,
      this.color});
}
