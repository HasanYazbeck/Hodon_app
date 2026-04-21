import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/babysitter/availability_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late final List<String> _hourSlots;
  String _selectedDay = 'Monday';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _hourSlots = List.generate(24, (h) {
      final suffix = h >= 12 ? 'PM' : 'AM';
      final hour = h % 12 == 0 ? 12 : h % 12;
      return '$hour $suffix';
    });
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(sitterAvailabilityProvider.notifier).saveAvailability();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved successfully.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save availability: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availability = ref.watch(sitterAvailabilityProvider);
    final selectedSlots = availability.daySlots[_selectedDay] ?? <String>{};
    final totalHours = availability.daySlots.values.fold<int>(
      0,
      (sum, slots) => sum + slots.length,
    );
    final activeDays = availability.daySlots.values.where((slots) => slots.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pageHorizontal,
                AppSizes.md,
                AppSizes.pageHorizontal,
                AppSizes.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set Your Schedule', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Choose any hour in each day to define when you can take bookings.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  HodonCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Week Summary', style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 4),
                              Text(
                                '$activeDays active day${activeDays == 1 ? '' : 's'} - $totalHours total hour${totalHours == 1 ? '' : 's'}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: totalHours == 0 ? 'Offline' : 'Available',
                          color: totalHours == 0 ? AppColors.textHint : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: _days.map((day) {
                      final selected = day == _selectedDay;
                      final slotCount = availability.daySlots[day]?.length ?? 0;
                      return ChoiceChip(
                        label: Text('${day.substring(0, 3)} ($slotCount)'),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedDay = day),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Text(_selectedDay, style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => ref
                            .read(sitterAvailabilityProvider.notifier)
                            .setDaySlots(_selectedDay, _hourSlots.toSet()),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Select All'),
                      ),
                      TextButton.icon(
                        onPressed: () => ref
                            .read(sitterAvailabilityProvider.notifier)
                            .setDaySlots(_selectedDay, <String>{}),
                        icon: const Icon(Icons.clear_all_rounded, size: 18),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: _hourSlots.map((hour) {
                      final selected = selectedSlots.contains(hour);
                      return FilterChip(
                        label: Text(hour),
                        selected: selected,
                        onSelected: (_) => ref
                            .read(sitterAvailabilityProvider.notifier)
                            .toggleSlot(_selectedDay, hour),
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: AppColors.primary,
                        side: BorderSide(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pageHorizontal,
                AppSizes.sm,
                AppSizes.pageHorizontal,
                AppSizes.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Availability'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

