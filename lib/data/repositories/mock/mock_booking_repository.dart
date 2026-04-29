import '../../../domain/models/booking.dart';
import '../../../domain/models/user.dart';
import '../../../domain/enums/booking_status.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/user_role.dart';
import '../interfaces/i_sitter_repository.dart';
import '../interfaces/i_booking_repository.dart';

class MockBookingRepository implements IBookingRepository {
  MockBookingRepository(this._sitterRepository);

  final ISitterRepository _sitterRepository;
  final List<Booking> _bookings = _buildInitialBookings();

  @override
  Future<Booking> createBooking({
    required String sitterId,
    required List<String> childrenIds,
    required ServiceType serviceType,
    required CareLocationType careLocationType,
    required BookingType bookingType,
    required DateTime startDatetime,
    required DateTime endDatetime,
    required UserAddress location,
    required PaymentMethod paymentMethod,
    String? notes,
    String? allergiesNote,
    bool useTrustCircle = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final sitter = await _sitterRepository.getSitterDetail(sitterId);
    final sitterAddress = sitter.user.address;
    final distanceKm = sitterAddress != null
        ? BookingPricing.calculateDistanceKm(from: sitterAddress, to: location)
        : (sitter.distanceKm ?? 0);

    if (careLocationType.requiresTransportFee &&
        sitter.profile.coverageRadiusKm != null &&
        distanceKm > sitter.profile.coverageRadiusKm!) {
      throw Exception(
        'This address is outside the sitter\'s ${sitter.profile.coverageRadiusKm!.toStringAsFixed(0)} km service radius.',
      );
    }

    final hourlyRate = sitter.profile.rateForService(serviceType);
    final transportFee = sitter.profile.estimateTransportFee(
      careLocationType: careLocationType,
      distanceKm: distanceKm,
    );
    final pricing = BookingPricing.calculate(
      hourlyRate: hourlyRate,
      durationHours: endDatetime.difference(startDatetime).inMinutes / 60.0,
      isEmergency: bookingType == BookingType.emergency,
      paymentMethod: paymentMethod,
      transportFee: transportFee,
    );
    final booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      parentId: 'user_parent_1',
      sitterId: sitterId,
      childrenIds: childrenIds,
      serviceType: serviceType,
      bookingType: bookingType,
      startDatetime: startDatetime,
      endDatetime: endDatetime,
      status: bookingType == BookingType.emergency
          ? BookingStatus.notifyingTrustCircle
          : BookingStatus.pending,
      pricing: pricing,
      location: location,
      careLocationType: careLocationType,
      transportDistanceKm: distanceKm,
      notes: notes,
      allergiesNote: allergiesNote,
      usedTrustCircle: useTrustCircle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _bookings.add(booking);
    return booking;
  }

  @override
  Future<List<Booking>> getParentBookings({BookingStatus? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (statusFilter != null) {
      return _bookings.where((b) => b.status == statusFilter).toList();
    }
    return List.unmodifiable(_bookings);
  }

  @override
  Future<List<Booking>> getSitterBookings({
    BookingStatus? statusFilter,
    String? sitterId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final effectiveSitterId = sitterId ?? 'user_sitter_1';
    final sitterBookings =
        _bookings.where((b) => b.sitterId == effectiveSitterId).toList();
    if (statusFilter != null) {
      return sitterBookings.where((b) => b.status == statusFilter).toList();
    }
    return sitterBookings;
  }

  @override
  Future<Booking> getBookingDetail(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.firstWhere((b) => b.id == bookingId);
  }

  @override
  Future<Booking> acceptBooking(
    String bookingId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _updateStatus(bookingId, BookingStatus.accepted);
  }

  @override
  Future<Booking> rejectBooking(String bookingId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _updateStatus(bookingId, BookingStatus.cancelledBySitter,
        cancellationReason: reason);
  }

  @override
  Future<Booking> cancelBooking(String bookingId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) throw Exception('Booking not found');

    final booking = _bookings[idx];
    if (!booking.status.canCancelByParent) {
      throw Exception('This booking can no longer be cancelled.');
    }

    final deductPlatformFee =
        booking.status.requiresPlatformFeeDeductionOnParentCancellation;

    final updated = booking.copyWith(
      status: BookingStatus.cancelledByParent,
      cancellationReason: reason,
      platformFeeDeductedOnCancellation: deductPlatformFee,
    );
    _bookings[idx] = updated;
    return updated;
  }

  @override
  Future<Booking> checkIn(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    final updated = _bookings[idx].copyWith(
      status: BookingStatus.checkedIn,
      checkedInAt: DateTime.now(),
    );
    _bookings[idx] = updated;
    return updated;
  }

  @override
  Future<Booking> checkOut(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    final updated = _bookings[idx].copyWith(
      status: BookingStatus.completed,
      checkedOutAt: DateTime.now(),
    );
    _bookings[idx] = updated;
    return updated;
  }

  Booking _updateStatus(String id, BookingStatus status,
      {String? cancellationReason}) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    final updated = _bookings[idx]
        .copyWith(status: status, cancellationReason: cancellationReason);
    _bookings[idx] = updated;
    return updated;
  }

  static List<Booking> _buildInitialBookings() {
    final loc = const UserAddress(
      id: 'addr_1',
      label: 'Home',
      fullAddress: 'Achrafieh, Beirut, Lebanon',
      latitude: 33.8869,
      longitude: 35.5131,
      isDefault: true,
    );
    return [
      Booking(
        id: 'bk_demo_1',
        parentId: 'user_parent_1',
        sitterId: 'user_sitter_1',
        childrenIds: ['child_1'],
        serviceType: ServiceType.babysitting,
        bookingType: BookingType.scheduled,
        startDatetime: DateTime.now().add(const Duration(days: 2, hours: 14)),
        endDatetime: DateTime.now().add(const Duration(days: 2, hours: 18)),
        status: BookingStatus.accepted,
        pricing: BookingPricing.calculate(
          hourlyRate: 15,
          durationHours: 4,
          isEmergency: false,
          paymentMethod: PaymentMethod.cash,
          transportFee: 1.2 * 1.4,
        ),
        location: loc,
        careLocationType: CareLocationType.parentHomeVisit,
        transportDistanceKm: 1.2,
        usedTrustCircle: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        sitterUser: AppUser(
          id: 'user_sitter_1',
          email: 'lara@test.com',
          fullName: 'Lara Haddad',
          role: UserRole.babysitter,
          avatarUrl: 'https://i.pravatar.cc/150?img=47',
          isEmailVerified: true,
          isProfileComplete: true,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime.now(),
        ),
      ),
      Booking(
        id: 'bk_demo_new_1',
        parentId: 'user_parent_2',
        sitterId: 'user_sitter_1',
        childrenIds: ['child_3'],
        serviceType: ServiceType.babysitting,
        bookingType: BookingType.scheduled,
        startDatetime: DateTime.now().add(const Duration(days: 1, hours: 9)),
        endDatetime: DateTime.now().add(const Duration(days: 1, hours: 13)),
        status: BookingStatus.pending,
        pricing: BookingPricing.calculate(
          hourlyRate: 16,
          durationHours: 4,
          isEmergency: false,
          paymentMethod: PaymentMethod.cash,
          transportFee: 1.2 * 1.4,
        ),
        location: loc,
        careLocationType: CareLocationType.parentPickupFromSitter,
        transportDistanceKm: 1.2,
        notes: 'Please arrive 15 minutes early.',
        usedTrustCircle: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      Booking(
        id: 'bk_demo_new_2',
        parentId: 'user_parent_3',
        sitterId: 'user_sitter_1',
        childrenIds: ['child_4', 'child_5'],
        serviceType: ServiceType.babysitting,
        bookingType: BookingType.emergency,
        startDatetime: DateTime.now().add(const Duration(hours: 5)),
        endDatetime: DateTime.now().add(const Duration(hours: 8)),
        status: BookingStatus.pending,
        pricing: BookingPricing.calculate(
          hourlyRate: 20,
          durationHours: 3,
          isEmergency: true,
          paymentMethod: PaymentMethod.cash,
          transportFee: 1.2 * 1.4,
        ),
        location: loc,
        careLocationType: CareLocationType.parentHomeVisit,
        transportDistanceKm: 1.2,
        notes: 'Emergency: parents are delayed at hospital.',
        usedTrustCircle: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Booking(
        id: 'bk_demo_2',
        parentId: 'user_parent_1',
        sitterId: 'user_sitter_3',
        childrenIds: ['child_1', 'child_2'],
        serviceType: ServiceType.babysitting,
        bookingType: BookingType.scheduled,
        startDatetime: DateTime.now().subtract(const Duration(days: 7)),
        endDatetime: DateTime.now()
            .subtract(const Duration(days: 7))
            .add(const Duration(hours: 3)),
        status: BookingStatus.completed,
        pricing: BookingPricing.calculate(
          hourlyRate: 18,
          durationHours: 3,
          isEmergency: false,
          paymentMethod: PaymentMethod.cash,
          transportFee: 0,
        ),
        location: loc,
        careLocationType: CareLocationType.sitterHomeHosting,
        transportDistanceKm: 0,
        usedTrustCircle: true,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
