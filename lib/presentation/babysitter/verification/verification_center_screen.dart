import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';

class VerificationCenterScreen extends ConsumerStatefulWidget {
  const VerificationCenterScreen({super.key});

  @override
  ConsumerState<VerificationCenterScreen> createState() => _VerificationCenterScreenState();
}

class _VerificationCenterScreenState extends ConsumerState<VerificationCenterScreen> {
  // Tracks the live ID verification status within this session.
  // In a real app this would come from a provider/repository.
  VerificationStatus _idStatus = VerificationStatus.notSubmitted;

  bool get _selfieUnlocked =>
      _idStatus == VerificationStatus.submitted ||
      _idStatus == VerificationStatus.underReview ||
      _idStatus == VerificationStatus.approved;

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Center')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text(
              'Build Trust & Credibility',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Complete verification steps to increase your visibility and earn badges that families trust.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
            ),
            const SizedBox(height: AppSizes.xl),
            // ID Verification — always accessible
            _VerificationItem(
              title: 'ID Verification',
              subtitle: 'Government-issued ID',
              status: _idStatus,
              icon: Icons.badge_rounded,
              onTap: () async {
                await context.push('/babysitter/verification/id');
                // After returning, promote status to underReview if it was notSubmitted
                // (in a real app this would be driven by the repository)
                if (_idStatus == VerificationStatus.notSubmitted && mounted) {
                  setState(() => _idStatus = VerificationStatus.underReview);
                }
              },
            ),
            const SizedBox(height: AppSizes.md),
            // Selfie Verification — locked until ID is at least submitted
            _VerificationItem(
              title: 'Selfie Verification',
              subtitle: _selfieUnlocked
                  ? 'Face match with ID'
                  : 'Complete ID Verification first',
              status: VerificationStatus.notSubmitted,
              icon: Icons.face_rounded,
              locked: !_selfieUnlocked,
              onTap: _selfieUnlocked
                  ? () => context.push('/babysitter/verification/selfie')
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Please submit your ID verification first before proceeding with selfie verification.'),
                          backgroundColor: AppColors.warning,
                        ),
                      ),
            ),
            const SizedBox(height: AppSizes.md),
            _VerificationItem(
              title: 'Background Check',
              subtitle: 'Criminal history check',
              status: VerificationStatus.underReview,
              icon: Icons.security_rounded,
              onTap: () => context.push('/babysitter/verification/background-check'),
            ),
            const SizedBox(height: AppSizes.md),
            _VerificationItem(
              title: 'CPR Certification',
              subtitle: 'Upload certificate',
              status: VerificationStatus.notSubmitted,
              icon: Icons.health_and_safety_rounded,
              onTap: () => context.push('/babysitter/verification/cpr'),
            ),
            const SizedBox(height: AppSizes.md),
            _VerificationItem(
              title: 'First Aid Certificate',
              subtitle: 'Upload certificate',
              status: VerificationStatus.notSubmitted,
              icon: Icons.local_hospital_rounded,
              onTap: () => context.push('/babysitter/verification/first-aid'),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _VerificationItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VerificationStatus status;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  const _VerificationItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == VerificationStatus.approved;
    final isUnderReview = status == VerificationStatus.underReview;
    final hintColor = context.appTextHint;
    final secondaryTextColor = context.appTextSecondary;

    final Color statusColor = locked
        ? hintColor
        : isApproved
            ? AppColors.success
            : isUnderReview
                ? AppColors.warning
                : hintColor;
    final statusText = locked ? 'Locked' : status.label;

    return Opacity(
      opacity: locked ? 0.55 : 1.0,
      child: HodonCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                locked ? Icons.lock_rounded : icon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: locked
                              ? AppColors.warning
                              : secondaryTextColor,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            StatusChip(
              label: statusText,
              color: locked ? AppColors.warning : statusColor,
            ),
          ],
        ),
      ),
    );
  }
}
