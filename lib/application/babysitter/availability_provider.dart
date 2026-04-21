import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model to hold sitter availability by day and time slot.
class SitterAvailability {
  final Map<String, Set<String>> daySlots;

  const SitterAvailability({required this.daySlots});

  SitterAvailability copyWith({
    Map<String, Set<String>>? daySlots,
  }) =>
      SitterAvailability(
        daySlots: daySlots ?? this.daySlots,
      );

  /// Check if sitter is available on a given day
  bool isAvailableOnDay(String day) => daySlots[day]?.isNotEmpty ?? false;

  /// Get list of available slots for a day
  List<String> getAvailableSlotsForDay(String day) =>
      (daySlots[day] ?? {}).toList()..sort();
}

/// Default availability: Mon-Fri 6 AM - 6 PM, Sat-Sun not available
final _defaultAvailability = SitterAvailability(
  daySlots: {
    'Monday': {'6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'},
    'Tuesday': {'6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'},
    'Wednesday': {'6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'},
    'Thursday': {'6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'},
    'Friday': {'6 AM', '7 AM', '8 AM', '9 AM', '10 AM', '11 AM', '12 PM', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'},
    'Saturday': <String>{},
    'Sunday': <String>{},
  },
);

/// Provider to manage sitter availability state
final sitterAvailabilityProvider = StateNotifierProvider<
    SitterAvailabilityNotifier,
    SitterAvailability>((ref) {
  return SitterAvailabilityNotifier(_defaultAvailability);
});

class SitterAvailabilityNotifier extends StateNotifier<SitterAvailability> {
  SitterAvailabilityNotifier(super.initial) : super();

  /// Toggle a time slot for a specific day
  void toggleSlot(String day, String slot) {
    final updated = Map<String, Set<String>>.from(state.daySlots);
    updated[day] ??= {};
    if (updated[day]!.contains(slot)) {
      updated[day]!.remove(slot);
    } else {
      updated[day]!.add(slot);
    }
    state = state.copyWith(daySlots: updated);
  }

  /// Set all slots for a specific day
  void setDaySlots(String day, Set<String> slots) {
    final updated = Map<String, Set<String>>.from(state.daySlots);
    updated[day] = slots;
    state = state.copyWith(daySlots: updated);
  }

  /// Get current availability
  SitterAvailability getAvailability() => state;

  /// Save availability (in a real app, this would persist to backend)
  Future<void> saveAvailability() async {
    // Simulate save delay
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, you'd call an API here to persist the availability
  }
}

