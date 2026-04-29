import 'dart:math';

import '../enums/booking_status.dart';
import '../enums/app_enums.dart';
import 'user.dart';

class BookingPricing {
  final double hourlyRate;
  final double durationHours;
  final double subtotal;
  final double platformCommission; // e.g. 0.15 = 15%
  final double emergencyFee;
  final double transportFee;
  final double total;
  final PaymentMethod paymentMethod;

  const BookingPricing({
    required this.hourlyRate,
    required this.durationHours,
    required this.subtotal,
    required this.platformCommission,
    required this.emergencyFee,
    required this.transportFee,
    required this.total,
    required this.paymentMethod,
  });

  factory BookingPricing.fromJson(Map<String, dynamic> json) => BookingPricing(
        hourlyRate: (json['hourlyRate'] as num).toDouble(),
        durationHours: (json['durationHours'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
        platformCommission: (json['platformCommission'] as num).toDouble(),
        emergencyFee: (json['emergencyFee'] as num).toDouble(),
        transportFee: (json['transportFee'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num).toDouble(),
        paymentMethod:
            PaymentMethod.values.byName(json['paymentMethod'] as String),
      );

  Map<String, dynamic> toJson() => {
        'hourlyRate': hourlyRate,
        'durationHours': durationHours,
        'subtotal': subtotal,
        'platformCommission': platformCommission,
        'emergencyFee': emergencyFee,
        'transportFee': transportFee,
        'total': total,
        'paymentMethod': paymentMethod.name,
      };

  static BookingPricing calculate({
    required double hourlyRate,
    required double durationHours,
    required bool isEmergency,
    required PaymentMethod paymentMethod,
    double transportFee = 0,
  }) {
    final subtotal = hourlyRate * durationHours;
    const commissionRate = 0.15;
    final commission = subtotal * commissionRate;
    final emergencyFee = isEmergency ? 5.0 : 0.0;
    return BookingPricing(
      hourlyRate: hourlyRate,
      durationHours: durationHours,
      subtotal: subtotal,
      platformCommission: commission,
      emergencyFee: emergencyFee,
      transportFee: transportFee,
      total: subtotal + commission + emergencyFee + transportFee,
      paymentMethod: paymentMethod,
    );
  }

  static double calculateDistanceKm({
    required UserAddress from,
    required UserAddress to,
  }) {
    const earthRadiusKm = 6371.0;
    final lat1 = _degreesToRadians(from.latitude);
    final lat2 = _degreesToRadians(to.latitude);
    final deltaLat = _degreesToRadians(to.latitude - from.latitude);
    final deltaLon = _degreesToRadians(to.longitude - from.longitude);

    final a =
        (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1) * cos(lat2) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) => degrees * (pi / 180);
}

class Booking {
  final String id;
  final String parentId;
  final String sitterId;
  final List<String> childrenIds;
  final ServiceType serviceType;
  final BookingType bookingType;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final BookingStatus status;
  final BookingPricing pricing;
  final UserAddress location;
  final CareLocationType careLocationType;
  final double transportDistanceKm;
  final String? notes;
  final String? allergiesNote;
  final bool usedTrustCircle;
  final String? cancellationReason;
  final bool platformFeeDeductedOnCancellation;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated on fetch (denormalized for display)
  final AppUser? parentUser;
  final AppUser? sitterUser;

  const Booking({
    required this.id,
    required this.parentId,
    required this.sitterId,
    required this.childrenIds,
    required this.serviceType,
    required this.bookingType,
    required this.startDatetime,
    required this.endDatetime,
    required this.status,
    required this.pricing,
    required this.location,
    this.careLocationType = CareLocationType.parentHomeVisit,
    this.transportDistanceKm = 0,
    this.notes,
    this.allergiesNote,
    required this.usedTrustCircle,
    this.cancellationReason,
    this.platformFeeDeductedOnCancellation = false,
    this.checkedInAt,
    this.checkedOutAt,
    required this.createdAt,
    required this.updatedAt,
    this.parentUser,
    this.sitterUser,
  });

  double get durationHours =>
      endDatetime.difference(startDatetime).inMinutes / 60.0;

  bool get isEmergency => bookingType == BookingType.emergency;

  double get deductedPlatformFeeAmount =>
      platformFeeDeductedOnCancellation ? pricing.platformCommission : 0;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        parentId: json['parentId'] as String,
        sitterId: json['sitterId'] as String,
        childrenIds: List<String>.from(json['childrenIds'] as List),
        serviceType: ServiceType.values.byName(json['serviceType'] as String),
        bookingType: BookingType.values.byName(json['bookingType'] as String),
        startDatetime: DateTime.parse(json['startDatetime'] as String),
        endDatetime: DateTime.parse(json['endDatetime'] as String),
        status: BookingStatus.values.byName(json['status'] as String),
        pricing:
            BookingPricing.fromJson(json['pricing'] as Map<String, dynamic>),
        location:
            UserAddress.fromJson(json['location'] as Map<String, dynamic>),
        careLocationType: json['careLocationType'] != null
            ? CareLocationType.values.byName(json['careLocationType'] as String)
            : CareLocationType.parentHomeVisit,
        transportDistanceKm:
            (json['transportDistanceKm'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        allergiesNote: json['allergiesNote'] as String?,
        usedTrustCircle: json['usedTrustCircle'] as bool? ?? false,
        cancellationReason: json['cancellationReason'] as String?,
        platformFeeDeductedOnCancellation:
            json['platformFeeDeductedOnCancellation'] as bool? ?? false,
        checkedInAt: json['checkedInAt'] != null
            ? DateTime.parse(json['checkedInAt'] as String)
            : null,
        checkedOutAt: json['checkedOutAt'] != null
            ? DateTime.parse(json['checkedOutAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'sitterId': sitterId,
        'childrenIds': childrenIds,
        'serviceType': serviceType.name,
        'bookingType': bookingType.name,
        'startDatetime': startDatetime.toIso8601String(),
        'endDatetime': endDatetime.toIso8601String(),
        'status': status.name,
        'pricing': pricing.toJson(),
        'location': location.toJson(),
        'careLocationType': careLocationType.name,
        'transportDistanceKm': transportDistanceKm,
        'notes': notes,
        'allergiesNote': allergiesNote,
        'usedTrustCircle': usedTrustCircle,
        'cancellationReason': cancellationReason,
        'platformFeeDeductedOnCancellation': platformFeeDeductedOnCancellation,
        'checkedInAt': checkedInAt?.toIso8601String(),
        'checkedOutAt': checkedOutAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Booking copyWith({
    BookingStatus? status,
    String? cancellationReason,
    bool? platformFeeDeductedOnCancellation,
    CareLocationType? careLocationType,
    double? transportDistanceKm,
    DateTime? checkedInAt,
    DateTime? checkedOutAt,
  }) =>
      Booking(
        id: id,
        parentId: parentId,
        sitterId: sitterId,
        childrenIds: childrenIds,
        serviceType: serviceType,
        bookingType: bookingType,
        startDatetime: startDatetime,
        endDatetime: endDatetime,
        status: status ?? this.status,
        pricing: pricing,
        location: location,
        careLocationType: careLocationType ?? this.careLocationType,
        transportDistanceKm: transportDistanceKm ?? this.transportDistanceKm,
        notes: notes,
        allergiesNote: allergiesNote,
        usedTrustCircle: usedTrustCircle,
        cancellationReason: cancellationReason ?? this.cancellationReason,
        platformFeeDeductedOnCancellation: platformFeeDeductedOnCancellation ??
            this.platformFeeDeductedOnCancellation,
        checkedInAt: checkedInAt ?? this.checkedInAt,
        checkedOutAt: checkedOutAt ?? this.checkedOutAt,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        parentUser: parentUser,
        sitterUser: sitterUser,
      );
}
