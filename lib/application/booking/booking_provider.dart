import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/booking.dart';
import '../../domain/models/user.dart';
import '../../domain/enums/booking_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/enums/app_enums.dart';
import '../auth/auth_provider.dart';
import '../providers.dart';

// ── Booking list ───────────────────────────────────────────────────────────

final parentBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  return ref.watch(bookingRepositoryProvider).getParentBookings();
});

final sitterBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != UserRole.babysitter) return const [];
  return ref
      .watch(bookingRepositoryProvider)
      .getSitterBookings(sitterId: user.id);
});

final upcomingParentBookingsProvider =
    FutureProvider<List<Booking>>((ref) async {
  final all = await ref.watch(bookingRepositoryProvider).getParentBookings();
  return all
      .where((b) =>
          b.status == BookingStatus.pending ||
          b.status == BookingStatus.accepted ||
          b.status == BookingStatus.parentConfirmed)
      .toList();
});

final activeParentBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  // Kept for backward compatibility where active-only jobs are needed.
  final all = await ref.watch(bookingRepositoryProvider).getParentBookings();
  return all.where((b) => b.status.isActive).toList();
});

final activeSitterBookingProvider = FutureProvider<Booking?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.role != UserRole.babysitter) return null;
  final all = await ref
      .watch(bookingRepositoryProvider)
      .getSitterBookings(sitterId: user.id);
  return all.where((b) => b.status.isActive).firstOrNull;
});

class ParentChildHistoryOverview {
  final int totalJobsFromParent;
  final int completedJobsFromParent;
  final int repeatChildrenCount;

  const ParentChildHistoryOverview({
    required this.totalJobsFromParent,
    required this.completedJobsFromParent,
    required this.repeatChildrenCount,
  });
}

final parentChildHistoryOverviewProvider =
    FutureProvider.family<ParentChildHistoryOverview?, String>(
        (ref, bookingId) async {
  final bookings = await ref.watch(sitterBookingsProvider.future);
  final booking = bookings.where((b) => b.id == bookingId).firstOrNull;
  if (booking == null) return null;

  final sameParent =
      bookings.where((b) => b.parentId == booking.parentId).toList();
  final historicalSameParent =
      sameParent.where((b) => b.id != booking.id).toList();
  final completed = sameParent
      .where((b) =>
          b.status == BookingStatus.completed ||
          b.status == BookingStatus.rated)
      .length;

  final childIdsSeen = <String>{};
  for (final b in historicalSameParent) {
    childIdsSeen.addAll(b.childrenIds);
  }
  final repeatedChildren =
      booking.childrenIds.where((id) => childIdsSeen.contains(id)).length;

  return ParentChildHistoryOverview(
    totalJobsFromParent: sameParent.length,
    completedJobsFromParent: completed,
    repeatChildrenCount: repeatedChildren,
  );
});

// ── Create booking form state ──────────────────────────────────────────────

class CreateBookingFormState {
  final String sitterId;
  final List<String> childrenIds;
  final ServiceType serviceType;
  final CareLocationType careLocationType;
  final BookingType bookingType;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final UserAddress? location;
  final PaymentMethod paymentMethod;
  final String notes;
  final bool useTrustCircle;
  final bool isSubmitting;
  final String? error;
  final Booking? result;

  const CreateBookingFormState({
    required this.sitterId,
    this.childrenIds = const [],
    this.serviceType = ServiceType.babysitting,
    this.careLocationType = CareLocationType.parentHomeVisit,
    this.bookingType = BookingType.scheduled,
    this.startDatetime,
    this.endDatetime,
    this.location,
    this.paymentMethod = PaymentMethod.cash,
    this.notes = '',
    this.useTrustCircle = false,
    this.isSubmitting = false,
    this.error,
    this.result,
  });

  CreateBookingFormState copyWith({
    List<String>? childrenIds,
    ServiceType? serviceType,
    CareLocationType? careLocationType,
    BookingType? bookingType,
    DateTime? startDatetime,
    DateTime? endDatetime,
    UserAddress? location,
    PaymentMethod? paymentMethod,
    String? notes,
    bool? useTrustCircle,
    bool? isSubmitting,
    String? error,
    Booking? result,
  }) =>
      CreateBookingFormState(
        sitterId: sitterId,
        childrenIds: childrenIds ?? this.childrenIds,
        serviceType: serviceType ?? this.serviceType,
        careLocationType: careLocationType ?? this.careLocationType,
        bookingType: bookingType ?? this.bookingType,
        startDatetime: startDatetime ?? this.startDatetime,
        endDatetime: endDatetime ?? this.endDatetime,
        location: location ?? this.location,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        notes: notes ?? this.notes,
        useTrustCircle: useTrustCircle ?? this.useTrustCircle,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        result: result ?? this.result,
      );

  BookingPricing? get pricing {
    if (startDatetime == null || endDatetime == null) return null;
    return BookingPricing.calculate(
      hourlyRate: 15, // would come from sitter profile
      durationHours: endDatetime!.difference(startDatetime!).inMinutes / 60.0,
      isEmergency: bookingType == BookingType.emergency,
      paymentMethod: paymentMethod,
    );
  }
}

class CreateBookingNotifier extends StateNotifier<CreateBookingFormState> {
  CreateBookingNotifier(this._ref, String sitterId)
      : super(CreateBookingFormState(sitterId: sitterId)) {
    _loadDefaultPaymentMethod();
  }

  final Ref _ref;

  void setChildren(List<String> ids) =>
      state = state.copyWith(childrenIds: ids);
  void setServiceType(ServiceType t) => state = state.copyWith(serviceType: t);
  void setCareLocationType(CareLocationType t) =>
      state = state.copyWith(careLocationType: t);
  void setBookingType(BookingType t) => state = state.copyWith(bookingType: t);
  void setStart(DateTime dt) => state = state.copyWith(startDatetime: dt);
  void setEnd(DateTime dt) => state = state.copyWith(endDatetime: dt);
  void setLocation(UserAddress a) => state = state.copyWith(location: a);
  void setPaymentMethod(PaymentMethod m) =>
      state = state.copyWith(paymentMethod: m);
  void setNotes(String n) => state = state.copyWith(notes: n);
  void setUseTrustCircle(bool v) => state = state.copyWith(useTrustCircle: v);

  Future<void> _loadDefaultPaymentMethod() async {
    try {
      final methods =
          await _ref.read(paymentRepositoryProvider).getPaymentMethods();
      final defaultMethod =
          methods.where((method) => method.isDefault).firstOrNull;
      if (!mounted || defaultMethod == null) return;
      state = state.copyWith(paymentMethod: defaultMethod.type);
    } catch (_) {
      // Keep the booking form usable with its existing fallback if payments fail to load.
    }
  }

  Future<bool> submit() async {
    if (state.startDatetime == null ||
        state.endDatetime == null ||
        state.location == null) {
      state = state.copyWith(error: 'Please fill all required fields.');
      return false;
    }
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final repo = _ref.read(bookingRepositoryProvider);
      final booking = await repo.createBooking(
        sitterId: state.sitterId,
        childrenIds: state.childrenIds,
        serviceType: state.serviceType,
        careLocationType: state.careLocationType,
        bookingType: state.bookingType,
        startDatetime: state.startDatetime!,
        endDatetime: state.endDatetime!,
        location: state.location!,
        paymentMethod: state.paymentMethod,
        notes: state.notes.isEmpty ? null : state.notes,
        useTrustCircle: state.useTrustCircle,
      );
      state = state.copyWith(isSubmitting: false, result: booking);
      // Invalidate booking lists
      _ref.invalidate(parentBookingsProvider);
      _ref.invalidate(upcomingParentBookingsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final createBookingProvider = StateNotifierProvider.family<
    CreateBookingNotifier, CreateBookingFormState, String>((ref, sitterId) {
  return CreateBookingNotifier(ref, sitterId);
});

// ── Booking actions ────────────────────────────────────────────────────────

final bookingActionProvider =
    StateNotifierProvider<BookingActionNotifier, AsyncValue<void>>((ref) {
  return BookingActionNotifier(ref);
});

class BookingActionNotifier extends StateNotifier<AsyncValue<void>> {
  BookingActionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> accept(String bookingId) => _act(() async {
        await _ref.read(bookingRepositoryProvider).acceptBooking(bookingId);
        _ref.invalidate(sitterBookingsProvider);
      });

  Future<bool> reject(String bookingId, String reason) => _act(() async {
        await _ref
            .read(bookingRepositoryProvider)
            .rejectBooking(bookingId, reason);
        _ref.invalidate(sitterBookingsProvider);
      });

  Future<bool> cancel(String bookingId, String reason) => _act(() async {
        await _ref
            .read(bookingRepositoryProvider)
            .cancelBooking(bookingId, reason);
        _ref.invalidate(parentBookingsProvider);
        _ref.invalidate(upcomingParentBookingsProvider);
        _ref.invalidate(activeParentBookingsProvider);
        _ref.invalidate(sitterBookingsProvider);
      });

  Future<bool> checkIn(String bookingId) => _act(() async {
        await _ref.read(bookingRepositoryProvider).checkIn(bookingId);
        _ref.invalidate(sitterBookingsProvider);
        _ref.invalidate(activeSitterBookingProvider);
      });

  Future<bool> checkOut(String bookingId) => _act(() async {
        await _ref.read(bookingRepositoryProvider).checkOut(bookingId);
        _ref.invalidate(sitterBookingsProvider);
        _ref.invalidate(activeSitterBookingProvider);
      });

  Future<bool> _act(Future<void> Function() fn) async {
    state = const AsyncValue.loading();
    try {
      await fn();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
