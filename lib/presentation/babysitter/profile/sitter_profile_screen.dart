import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class SitterProfileScreen extends ConsumerWidget {
  const SitterProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.go('/babysitter/edit-profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go('/babysitter/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const StarRating(rating: 4.9, size: 16),
                      const SizedBox(width: 4),
                      Text('4.9 · 48 reviews', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TrustBadgeChip(label: 'ID Verified', icon: Icons.badge_rounded, color: AppColors.badgeVerified),
                      const SizedBox(width: 6),
                      TrustBadgeChip(label: 'CPR Certified', icon: Icons.health_and_safety_rounded, color: AppColors.badgeCPR),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
              child: Column(
                children: [
                  _menuSection(context, 'Profile', [
                    _MenuItem(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      onTap: () => context.go('/babysitter/edit-profile'),
                    ),
                      _MenuItem(
                        icon: Icons.shield_rounded,
                        label: 'Verification Center',
                        onTap: () => context.go('/babysitter/verification'),
                      ),
                      _MenuItem(
                        icon: Icons.calendar_month_rounded,
                        label: 'Availability',
                        onTap: () => context.go('/babysitter/availability'),
                      ),
                      _MenuItem(
                        icon: Icons.attach_money_rounded,
                        label: 'Rates & Services',
                        onTap: () => context.go('/babysitter/rates-services'),
                      ),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _menuSection(context, 'Account', [
                    _MenuItem(icon: Icons.star_rounded, label: 'My Reviews', onTap: () {}),
                    _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', onTap: () {}),
                    _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                  ]),
                  const SizedBox(height: AppSizes.md),
                  _menuSection(context, '', [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      color: AppColors.error,
                      onTap: () => ref.read(authProvider.notifier).logout(),
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

  Widget _menuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.sm),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(color: AppColors.border),
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
                  trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
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

class SitterOnboardingScreen extends ConsumerStatefulWidget {
  const SitterOnboardingScreen({super.key});

  @override
  ConsumerState<SitterOnboardingScreen> createState() => _SitterOnboardingState();
}

class _SitterOnboardingState extends ConsumerState<SitterOnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  void _next() {
    if (_page < 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _page++);
    } else {
      context.go('/babysitter/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.md),
              child: Row(children: List.generate(3, (i) => Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= _page ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ))),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ExperiencePage(onNext: _next),
                  _SkillsPage(onNext: _next),
                  _RatePage(onNext: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperiencePage extends StatefulWidget {
  final VoidCallback onNext;
  const _ExperiencePage({required this.onNext});

  @override
  State<_ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<_ExperiencePage> {
  double _years = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.lg),
          Text("Your Experience", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.xl),
          Center(child: Text('${_years.toInt()} years', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary))),
          Slider(value: _years, min: 0, max: 20, divisions: 20, activeColor: AppColors.primary, onChanged: (v) => setState(() => _years = v)),
          const Spacer(),
          ElevatedButton(onPressed: widget.onNext, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppSizes.buttonHeight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg))), child: const Text('Next')),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _SkillsPage extends StatefulWidget {
  final VoidCallback onNext;
  const _SkillsPage({required this.onNext});

  @override
  State<_SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<_SkillsPage> {
  final Set<String> _selected = {};
  static const _skills = ['First Aid & CPR', 'Storytelling', 'Patience & Calmness', 'Conflict Resolution', 'Feeding & Meal Prep', 'Homework Assistance', 'Arts & Crafts', 'Outdoor Activities'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.lg),
          Text("Your Skills", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.sm),
          Text("Select all that apply", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.xl),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: _skills.map((s) => FilterChip(
              label: Text(s),
              selected: _selected.contains(s),
              onSelected: (v) => setState(() => v ? _selected.add(s) : _selected.remove(s)),
              selectedColor: AppColors.primaryContainer,
            )).toList(),
          ),
          const Spacer(),
          ElevatedButton(onPressed: widget.onNext, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppSizes.buttonHeight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg))), child: const Text('Next')),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _RatePage extends StatefulWidget {
  final VoidCallback onNext;
  const _RatePage({required this.onNext});

  @override
  State<_RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<_RatePage> {
  final _rateCtrl = TextEditingController(text: '15');

  @override
  void dispose() { _rateCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.lg),
          Text("Set Your Rate", style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.sm),
          Text("You can change this at any time", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSizes.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('\$', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary)),
              const SizedBox(width: AppSizes.sm),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _rateCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              Text('/hr', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: widget.onNext,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, AppSizes.buttonHeight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg))),
            child: const Text("Let's Get Started! 🎉"),
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

