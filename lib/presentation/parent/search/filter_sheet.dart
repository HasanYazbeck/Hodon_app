import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/sitter/sitter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/repositories/interfaces/i_sitter_repository.dart';
import '../../../domain/enums/app_enums.dart';

class FilterSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const FilterSheet({super.key, required this.scrollController});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late SitterFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = ref.read(sitterFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.appSurface;
    final borderColor = context.appBorder;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSizes.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: Theme.of(context).textTheme.headlineSmall),
                TextButton(
                  onPressed: () => setState(() => _filter = const SitterFilter()),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(AppSizes.pageHorizontal),
              children: [
                _SectionTitle('Sort By'),
                Wrap(
                  spacing: AppSizes.sm,
                  children: SitterSortBy.values.map((s) => ChoiceChip(
                    label: Text(_sortLabel(s)),
                    selected: _filter.sortBy == s,
                    onSelected: (_) => setState(() => _filter = _filter.copyWith(sortBy: s)),
                    selectedColor: AppColors.primaryContainer,
                  )).toList(),
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionTitle('Trust & Verification'),
                _SwitchRow(
                  label: 'Verified Sitters Only',
                  icon: Icons.verified_rounded,
                  value: _filter.verifiedOnly,
                  onChanged: (v) => setState(() => _filter = _filter.copyWith(verifiedOnly: v)),
                ),
                _SwitchRow(
                  label: 'CPR / First Aid Trained',
                  icon: Icons.health_and_safety_rounded,
                  value: _filter.cprOnly,
                  onChanged: (v) => setState(() => _filter = _filter.copyWith(cprOnly: v)),
                ),
                _SwitchRow(
                  label: 'Trust Circle First',
                  icon: Icons.people_rounded,
                  value: _filter.trustCircleFirst,
                  onChanged: (v) => setState(() => _filter = _filter.copyWith(trustCircleFirst: v)),
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionTitle('Max Hourly Rate'),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _filter.maxHourlyRate ?? 50,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: '\$${(_filter.maxHourlyRate ?? 50).toInt()}/hr',
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _filter = _filter.copyWith(maxHourlyRate: v)),
                      ),
                    ),
                    Text(
                      '\$${(_filter.maxHourlyRate ?? 50).toInt()}/hr',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionTitle('Minimum Rating'),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _filter.minRating ?? 0,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        label: '${_filter.minRating?.toStringAsFixed(1) ?? 'Any'} ★',
                        activeColor: AppColors.badgeGold,
                        onChanged: (v) => setState(() => _filter = _filter.copyWith(minRating: v)),
                      ),
                    ),
                    Text(
                      _filter.minRating != null && _filter.minRating! > 0
                          ? '${_filter.minRating!.toStringAsFixed(1)} ★'
                          : 'Any',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionTitle('Services'),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: ServiceType.values.map((s) {
                    final selected = _filter.services?.contains(s) ?? false;
                    return FilterChip(
                      label: Text(s.label),
                      selected: selected,
                      onSelected: (v) {
                        final services = List<ServiceType>.from(_filter.services ?? []);
                        if (v) {
                          services.add(s);
                        } else {
                          services.remove(s);
                        }
                        setState(() => _filter = _filter.copyWith(services: services));
                      },
                      selectedColor: AppColors.primaryContainer,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.lg),
                _SectionTitle('Age Groups'),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: ChildAgeGroup.values.map((a) {
                    final selected = _filter.ageGroups?.contains(a) ?? false;
                    return FilterChip(
                      label: Text(a.label),
                      selected: selected,
                      onSelected: (v) {
                        final groups = List<ChildAgeGroup>.from(_filter.ageGroups ?? []);
                        if (v) {
                          groups.add(a);
                        } else {
                          groups.remove(a);
                        }
                        setState(() => _filter = _filter.copyWith(ageGroups: groups));
                      },
                      selectedColor: AppColors.primaryContainer,
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.xxxl),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.pageHorizontal, AppSizes.sm,
              AppSizes.pageHorizontal, AppSizes.md + MediaQuery.of(context).padding.bottom,
            ),
            child: ElevatedButton(
              onPressed: () {
                ref.read(sitterFilterProvider.notifier).state = _filter;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(SitterSortBy s) => switch (s) {
        SitterSortBy.topRated => 'Top Rated',
        SitterSortBy.nearest => 'Nearest',
        SitterSortBy.lowestPrice => 'Lowest Price',
        SitterSortBy.fastestAvailable => 'Fastest',
      };
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
        child: Row(
          children: [
            Icon(icon, size: AppSizes.iconMd, color: context.appTextSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      );
}

