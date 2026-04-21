import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';

class RatesServicesScreen extends ConsumerWidget {
  const RatesServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rates & Services')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text(
              'Set Your Rates',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Manage your hourly rates and service offerings.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.xl),
            _RateCard(
              serviceType: ServiceType.babysitting,
              rate: 15.0,
              onEdit: () {},
            ),
            const SizedBox(height: AppSizes.md),
            _RateCard(
              serviceType: ServiceType.fullTimeNanny,
              rate: 18.0,
              onEdit: () {},
            ),
            const SizedBox(height: AppSizes.md),
            _RateCard(
              serviceType: ServiceType.newbornInfantCare,
              rate: 20.0,
              onEdit: () {},
            ),
            const SizedBox(height: AppSizes.md),
            _RateCard(
              serviceType: ServiceType.childhoodEducation,
              rate: 22.0,
              onEdit: () {},
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              'Services Offered',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Select the services you provide to families.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: ServiceType.values
                  .map(
                    (service) => FilterChip(
                      label: Text(service.label),
                      selected: true,
                      onSelected: (value) {},
                      selectedColor: AppColors.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  final ServiceType serviceType;
  final double rate;
  final VoidCallback onEdit;

  const _RateCard({
    required this.serviceType,
    required this.rate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: onEdit,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceType.label,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          Text(
            '\$$rate/hr',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppSizes.sm),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

