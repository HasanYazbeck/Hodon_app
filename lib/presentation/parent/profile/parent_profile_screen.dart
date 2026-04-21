import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
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
                  Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  if (user?.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textHint),
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
                  _MenuSection(items: [
                    _MenuItem(icon: Icons.child_care_rounded, label: 'My Children', onTap: () => context.go('/parent/children')),
                    _MenuItem(icon: Icons.people_rounded, label: 'Trust Circle', onTap: () => context.go('/parent/trust-circle')),
                    _MenuItem(icon: Icons.calendar_today_rounded, label: 'Booking History', onTap: () => context.go('/parent/bookings')),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _MenuSection(items: [
                    _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () => context.go('/parent/notifications')),
                    _MenuItem(icon: Icons.payment_rounded, label: 'Payment Methods', onTap: () {}),
                    _MenuItem(icon: Icons.language_rounded, label: 'Language', onTap: () {}),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _MenuSection(items: [
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Help & Support',
                      onTap: () => context.push('/help-support'),
                    ),
                    _MenuItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
                    _MenuItem(icon: Icons.description_outlined, label: 'Terms of Service', onTap: () {}),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _MenuSection(items: [
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
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
                trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
                onTap: item.onTap,
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
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

