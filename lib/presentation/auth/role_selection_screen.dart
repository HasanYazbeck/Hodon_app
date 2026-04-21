import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/enums/user_role.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selected;
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selected == null) return;
    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).setRole(_selected!);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (_selected == UserRole.parent) {
      context.go('/parent/onboarding');
    } else {
      context.go('/babysitter/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSizes.xxl),
              Text(
                AppStrings.whatBringsYou,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                AppStrings.roleSelectionSubtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xxl),
              _RoleCard(
                emoji: '👨‍👩‍👧',
                title: AppStrings.iAmParent,
                subtitle: AppStrings.iAmParentSubtitle,
                isSelected: _selected == UserRole.parent,
                onTap: () => setState(() => _selected = UserRole.parent),
              ),
              const SizedBox(height: AppSizes.md),
              _RoleCard(
                emoji: '🤝',
                title: AppStrings.iAmBabysitter,
                subtitle: AppStrings.iAmBabysitterSubtitle,
                isSelected: _selected == UserRole.babysitter,
                onTap: () => setState(() => _selected = UserRole.babysitter),
              ),
              const Spacer(),
              AnimatedOpacity(
                opacity: _selected != null ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _selected != null && !_isLoading ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.continueLabel),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

