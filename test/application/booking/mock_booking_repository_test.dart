import 'package:flutter_test/flutter_test.dart';
import 'package:hodon_app/data/repositories/mock/mock_booking_repository.dart';
import 'package:hodon_app/data/repositories/mock/mock_sitter_repository.dart';
import 'package:hodon_app/domain/enums/app_enums.dart';
import 'package:hodon_app/domain/enums/booking_status.dart';
import 'package:hodon_app/domain/models/booking.dart';
import 'package:hodon_app/domain/models/user.dart';

void main() {
  test('accepted booking cancellation deducts platform fee from payment',
      () async {
    final repo = MockBookingRepository(MockSitterRepository());

    final cancelled = await repo.cancelBooking('bk_demo_1', 'Plans changed');

    expect(cancelled.status, BookingStatus.cancelledByParent);
    expect(cancelled.platformFeeDeductedOnCancellation, isTrue);
    expect(
      cancelled.deductedPlatformFeeAmount,
      closeTo(cancelled.pricing.platformCommission, 0.0001),
    );
  });

  test('pending booking cancellation remains fee-free', () async {
    final repo = MockBookingRepository(MockSitterRepository());
    const location = UserAddress(
      id: 'addr_test_1',
      label: 'Home',
      fullAddress: 'Beirut, Lebanon',
      latitude: 33.8938,
      longitude: 35.5018,
      isDefault: true,
    );

    final pending = await repo.createBooking(
      sitterId: 'user_sitter_1',
      childrenIds: const ['child_1'],
      serviceType: ServiceType.babysitting,
      careLocationType: CareLocationType.sitterHomeHosting,
      bookingType: BookingType.scheduled,
      startDatetime: DateTime.now().add(const Duration(days: 1)),
      endDatetime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      location: location,
      paymentMethod: PaymentMethod.cash,
    );

    final cancelled = await repo.cancelBooking(pending.id, 'No longer needed');

    expect(cancelled.status, BookingStatus.cancelledByParent);
    expect(cancelled.platformFeeDeductedOnCancellation, isFalse);
    expect(cancelled.deductedPlatformFeeAmount, 0);
  });

  test('booking cannot be cancelled by parent after check-in', () async {
    final repo = MockBookingRepository(MockSitterRepository());

    await repo.checkIn('bk_demo_1');

    await expectLater(
      () => repo.cancelBooking('bk_demo_1', 'Too late'),
      throwsA(isA<Exception>()),
    );
  });

  test('sitter only sees bookings assigned to their sitter id', () async {
    final repo = MockBookingRepository(MockSitterRepository());

    final sitterOneBookings =
        await repo.getSitterBookings(sitterId: 'user_sitter_1');
    final sitterThreeBookings =
        await repo.getSitterBookings(sitterId: 'user_sitter_3');

    expect(sitterOneBookings, isNotEmpty);
    expect(
        sitterOneBookings.every((b) => b.sitterId == 'user_sitter_1'), isTrue);
    expect(sitterThreeBookings.length, 1);
    expect(sitterThreeBookings.single.sitterId, 'user_sitter_3');
  });

  test('transport fee is added for parent-home visit based on distance',
      () async {
    final sitterRepo = MockSitterRepository();
    final repo = MockBookingRepository(sitterRepo);
    const location = UserAddress(
      id: 'addr_test_2',
      label: 'Home',
      fullAddress: 'Achrafieh, Beirut, Lebanon',
      latitude: 33.8869,
      longitude: 35.5131,
      isDefault: true,
    );

    final sitter = await sitterRepo.getSitterDetail('user_sitter_1');
    final expectedDistance = BookingPricing.calculateDistanceKm(
      from: sitter.user.address!,
      to: location,
    );
    final booking = await repo.createBooking(
      sitterId: 'user_sitter_1',
      childrenIds: const ['child_1'],
      serviceType: ServiceType.babysitting,
      careLocationType: CareLocationType.parentHomeVisit,
      bookingType: BookingType.scheduled,
      startDatetime: DateTime.now().add(const Duration(days: 2)),
      endDatetime: DateTime.now().add(const Duration(days: 2, hours: 3)),
      location: location,
      paymentMethod: PaymentMethod.cash,
    );

    expect(booking.careLocationType, CareLocationType.parentHomeVisit);
    expect(booking.transportDistanceKm, closeTo(expectedDistance, 0.01));
    expect(booking.pricing.transportFee, greaterThan(0));
    expect(
      booking.pricing.transportFee,
      closeTo(
        sitter.profile.estimateTransportFee(
          careLocationType: CareLocationType.parentHomeVisit,
          distanceKm: expectedDistance,
        ),
        0.01,
      ),
    );
  });
}
