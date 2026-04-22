import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total earnings card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
              child: Column(
                children: [
                      Text('Total Earned', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 8),
                  Text('\$1,840', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                      Text('145 jobs completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.85))),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            // This month
            Row(
              children: [
                Expanded(child: _EarningSummaryCard(label: 'This Month', value: '\$320', jobs: 12, color: AppColors.success)),
                const SizedBox(width: AppSizes.sm),
                Expanded(child: _EarningSummaryCard(label: 'Last Month', value: '\$285', jobs: 10, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            SectionHeader(title: 'Monthly Breakdown'),
            const SizedBox(height: AppSizes.sm),
            ..._months.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: HodonCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: Center(child: Text(m['month']!.substring(0, 3), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary))),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['month']!, style: Theme.of(context).textTheme.titleSmall),
                              Text('${m['jobs']} jobs', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor)),
                            ],
                          ),
                        ),
                        Text(m['amount']!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.success)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static const _months = [
    {'month': 'April 2026', 'jobs': '12', 'amount': '\$320'},
    {'month': 'March 2026', 'jobs': '10', 'amount': '\$285'},
    {'month': 'February 2026', 'jobs': '8', 'amount': '\$230'},
    {'month': 'January 2026', 'jobs': '11', 'amount': '\$310'},
  ];
}

class _EarningSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final int jobs;
  final Color color;

  const _EarningSummaryCard({required this.label, required this.value, required this.jobs, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.appTextSecondary)),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
            Text('$jobs jobs', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      );
}

