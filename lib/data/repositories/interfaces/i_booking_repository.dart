import '../../../domain/models/booking.dart';
import '../../../domain/enums/booking_status.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/user.dart';

abstract class IBookingRepository {
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
  });

  Future<List<Booking>> getParentBookings({BookingStatus? statusFilter});

  Future<List<Booking>> getSitterBookings({
    BookingStatus? statusFilter,
    String? sitterId,
  });

  Future<Booking> getBookingDetail(String bookingId);

  Future<Booking> acceptBooking(String bookingId);

  Future<Booking> rejectBooking(String bookingId, String reason);

  Future<Booking> cancelBooking(String bookingId, String reason);

  Future<Booking> checkIn(String bookingId);

  Future<Booking> checkOut(String bookingId);
}
