import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.go('/parent/edit-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go('/parent/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                children: [
                  UserAvatar(
                    imageUrl: user?.avatarUrl,
                    name: user?.fullName,
                    size: AppSizes.avatarXl,
                    showBorder: true,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(user?.fullName ?? '', style: Theme.of(context).textTheme.headlineMedium),
                  Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor)),
                  if (user?.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: hintColor),
                        Text(user!.address!.fullAddress, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
              child: Column(
                children: [
                  _menuSection(context, 'Profile', [
                    _MenuItem(icon: Icons.edit_rounded, label: 'Edit Profile', onTap: () => context.go('/parent/edit-profile')),
                    _MenuItem(icon: Icons.child_care_rounded, label: 'My Children', onTap: () => context.go('/parent/children')),
                    _MenuItem(icon: Icons.people_rounded, label: 'Trust Circle', onTap: () => context.go('/parent/trust-circle')),
                    _MenuItem(icon: Icons.calendar_today_rounded, label: 'Booking History', onTap: () => context.go('/parent/bookings')),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _menuSection(context, 'Account', [
                    _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () => context.go('/parent/notifications')),
                    _MenuItem(icon: Icons.payment_rounded, label: 'Payment Methods', onTap: () => context.push('/parent/payment-methods')),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _menuSection(context, 'Support', [
                    _MenuItem( icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () => context.push('/help-support')),
                  ]),

                  const SizedBox(height: AppSizes.lg),
                  _menuSection(context, '', [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      color: AppColors.error,
                      onTap: () => _confirmLogout(context, ref),
                    ),
                  ]),
                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _menuSection(BuildContext context, String title, List<_MenuItem> items) {
    final secondaryTextColor = context.appTextSecondary;
    final surfaceColor = context.appSurface;
    final borderColor = context.appBorder;
    final hintColor = context.appTextHint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: secondaryTextColor)),
          const SizedBox(height: AppSizes.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item.color ?? AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(item.icon, size: 18, color: item.color ?? AppColors.primary),
                  ),
                  title: Text(item.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: item.color)),
                  trailing: Icon(Icons.chevron_right_rounded, size: 18, color: hintColor),
                  onTap: item.onTap,
                ),
                if (i < items.length - 1) const Divider(height: 1, indent: 56),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});
}
