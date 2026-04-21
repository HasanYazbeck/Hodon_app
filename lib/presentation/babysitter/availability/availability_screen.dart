import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/babysitter/availability_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../shared/widgets/shared_widgets.dart';

const List<String> _timeSlots = [
  '6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM',
  '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM',
  '6 PM', '7 PM', '8 PM', '9 PM'
];

/// Provider to track which days are expanded in the UI
final _expandedDaysProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
});

class AvailabilityScreen extends ConsumerWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(sitterAvailabilityProvider);
    final expandedDays = ref.watch(_expandedDaysProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text(
              'Set Your Schedule',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Select which times you\'re available each day.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.xl),
            ...availability.daySlots.keys.map((day) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: _DayTimeSlotCard(
                  day: day,
                  isExpanded: expandedDays[day] ?? false,
                  selectedSlots: availability.daySlots[day] ?? {},
                  onExpandToggle: (expanded) {
                    ref.read(_expandedDaysProvider.notifier).update((state) {
                      final updated = Map<String, bool>.from(state);
                      updated[day] = expanded;
                      return updated;
                    });
                  },
                  onSlotToggle: (slot) {
                    ref.read(sitterAvailabilityProvider.notifier).toggleSlot(day, slot);
                  },
                ),
              );
            }),
            const SizedBox(height: AppSizes.xl),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(sitterAvailabilityProvider.notifier).saveAvailability();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Availability saved successfully.'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving availability: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
              ),
              child: const Text('Save Availability'),
            ),
             const SizedBox(height: AppSizes.xxl),
           ],
         ),
       ),
     );
  }
}

class _DayTimeSlotCard extends StatelessWidget {
  final String day;
  final bool isExpanded;
  final Set<String> selectedSlots;
  final Function(bool) onExpandToggle;
  final Function(String) onSlotToggle;

  const _DayTimeSlotCard({
    required this.day,
    required this.isExpanded,
    required this.selectedSlots,
    required this.onExpandToggle,
    required this.onSlotToggle,
  });

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: () => onExpandToggle(!isExpanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      selectedSlots.isEmpty
                          ? 'Not available'
                          : '${selectedSlots.length} slot${selectedSlots.length != 1 ? 's' : ''} selected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: selectedSlots.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.success,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          if (isExpanded) ...[
            const SizedBox(height: AppSizes.md),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppSizes.md),
            ..._timeSlots.map((slot) {
              final isSelected = selectedSlots.contains(slot);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSlotToggle(slot),
                      fillColor: WidgetStatePropertyAll(
                        isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        slot,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

