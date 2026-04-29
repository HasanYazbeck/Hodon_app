import '../enums/app_enums.dart';
import 'user.dart';

class BabysitterProfile {
  final String userId;
  final int yearsOfExperience;
  final double hourlyRate;
  final Map<ServiceType, double> serviceHourlyRates;
  final List<SitterSkill> skills;
  final List<ServiceType> services;
  final List<CareLocationType> supportedCareLocations;
  final List<ChildAgeGroup> ageGroups;
  final List<String> languages;
  final List<TrustBadge> badges;
  final VerificationStatus verificationStatus;
  final double rating;
  final int reviewsCount;
  final int completedJobs;
  final String? averageResponseTime; // e.g. "~15 min"
  final double? coverageRadiusKm;
  final double transportFeePerKm;
  final List<AvailabilitySlot> availability;
  final String? idDocumentUrl;
  final String? selfieUrl;
  final String? certificateUrl;
  final String? referenceDetails;
  final DateTime? approvedAt;

  const BabysitterProfile({
    required this.userId,
    required this.yearsOfExperience,
    required this.hourlyRate,
    this.serviceHourlyRates = const {},
    required this.skills,
    required this.services,
    this.supportedCareLocations = const [CareLocationType.parentHomeVisit],
    required this.ageGroups,
    required this.languages,
    required this.badges,
    required this.verificationStatus,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobs,
    this.averageResponseTime,
    this.coverageRadiusKm,
    this.transportFeePerKm = 0,
    required this.availability,
    this.idDocumentUrl,
    this.selfieUrl,
    this.certificateUrl,
    this.referenceDetails,
    this.approvedAt,
  });

  bool get isVerified => verificationStatus == VerificationStatus.approved;
  bool get hasCPR => badges.contains(TrustBadge.cprCertified);
  bool get isTopRated => badges.contains(TrustBadge.topRated);
  double get startingHourlyRate {
    if (services.isEmpty) return hourlyRate;
    final rates = services.map(rateForService).toList()..sort();
    return rates.isEmpty ? hourlyRate : rates.first;
  }

  double rateForService(ServiceType serviceType) =>
      serviceHourlyRates[serviceType] ?? hourlyRate;

  bool supportsCareLocation(CareLocationType careLocationType) =>
      supportedCareLocations.contains(careLocationType);

  double estimateTransportFee({
    required CareLocationType careLocationType,
    required double distanceKm,
  }) {
    if (!careLocationType.requiresTransportFee) return 0;
    final effectiveDistance = distanceKm.isNegative ? 0 : distanceKm;
    return effectiveDistance * transportFeePerKm;
  }

  factory BabysitterProfile.fromJson(Map<String, dynamic> json) => BabysitterProfile(
        userId: json['userId'] as String,
        yearsOfExperience: json['yearsOfExperience'] as int,
        hourlyRate: (json['hourlyRate'] as num).toDouble(),
        serviceHourlyRates:
            (json['serviceHourlyRates'] as Map<String, dynamic>?)?.map(
                  (key, value) => MapEntry(
                    ServiceType.values.byName(key),
                    (value as num).toDouble(),
                  ),
                ) ??
                const {},
        skills: (json['skills'] as List<dynamic>)
            .map((e) => SitterSkill.values.byName(e as String))
            .toList(),
        services: (json['services'] as List<dynamic>)
            .map((e) => ServiceType.values.byName(e as String))
            .toList(),
        supportedCareLocations:
            (json['supportedCareLocations'] as List<dynamic>?)
                ?.map((e) => CareLocationType.values.byName(e as String))
                .toList() ??
            const [CareLocationType.parentHomeVisit],
        ageGroups: (json['ageGroups'] as List<dynamic>)
            .map((e) => ChildAgeGroup.values.byName(e as String))
            .toList(),
        languages: List<String>.from(json['languages'] as List),
        badges: (json['badges'] as List<dynamic>)
            .map((e) => TrustBadge.values.byName(e as String))
            .toList(),
        verificationStatus:
            VerificationStatus.values.byName(json['verificationStatus'] as String),
        rating: (json['rating'] as num).toDouble(),
        reviewsCount: json['reviewsCount'] as int,
        completedJobs: json['completedJobs'] as int,
        averageResponseTime: json['averageResponseTime'] as String?,
        coverageRadiusKm: (json['coverageRadiusKm'] as num?)?.toDouble(),
        transportFeePerKm: (json['transportFeePerKm'] as num?)?.toDouble() ?? 0,
        availability: (json['availability'] as List<dynamic>)
            .map((e) => AvailabilitySlot.fromJson(e as Map<String, dynamic>))
            .toList(),
        idDocumentUrl: json['idDocumentUrl'] as String?,
        selfieUrl: json['selfieUrl'] as String?,
        certificateUrl: json['certificateUrl'] as String?,
        referenceDetails: json['referenceDetails'] as String?,
        approvedAt: json['approvedAt'] != null
            ? DateTime.parse(json['approvedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'yearsOfExperience': yearsOfExperience,
        'hourlyRate': hourlyRate,
        'serviceHourlyRates': serviceHourlyRates.map(
          (key, value) => MapEntry(key.name, value),
        ),
        'skills': skills.map((e) => e.name).toList(),
        'services': services.map((e) => e.name).toList(),
        'supportedCareLocations':
            supportedCareLocations.map((e) => e.name).toList(),
        'ageGroups': ageGroups.map((e) => e.name).toList(),
        'languages': languages,
        'badges': badges.map((e) => e.name).toList(),
        'verificationStatus': verificationStatus.name,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'completedJobs': completedJobs,
        'averageResponseTime': averageResponseTime,
        'coverageRadiusKm': coverageRadiusKm,
        'transportFeePerKm': transportFeePerKm,
        'availability': availability.map((e) => e.toJson()).toList(),
        'idDocumentUrl': idDocumentUrl,
        'selfieUrl': selfieUrl,
        'certificateUrl': certificateUrl,
        'referenceDetails': referenceDetails,
        'approvedAt': approvedAt?.toIso8601String(),
      };

  BabysitterProfile copyWith({
    int? yearsOfExperience,
    double? hourlyRate,
    Map<ServiceType, double>? serviceHourlyRates,
    List<SitterSkill>? skills,
    List<ServiceType>? services,
    List<CareLocationType>? supportedCareLocations,
    List<ChildAgeGroup>? ageGroups,
    List<String>? languages,
    List<TrustBadge>? badges,
    VerificationStatus? verificationStatus,
    double? rating,
    int? reviewsCount,
    int? completedJobs,
    String? averageResponseTime,
    double? coverageRadiusKm,
    double? transportFeePerKm,
    List<AvailabilitySlot>? availability,
    String? idDocumentUrl,
    String? selfieUrl,
    String? certificateUrl,
    String? referenceDetails,
    DateTime? approvedAt,
  }) =>
      BabysitterProfile(
        userId: userId,
        yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        serviceHourlyRates: serviceHourlyRates ?? this.serviceHourlyRates,
        skills: skills ?? this.skills,
        services: services ?? this.services,
        supportedCareLocations:
            supportedCareLocations ?? this.supportedCareLocations,
        ageGroups: ageGroups ?? this.ageGroups,
        languages: languages ?? this.languages,
        badges: badges ?? this.badges,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        rating: rating ?? this.rating,
        reviewsCount: reviewsCount ?? this.reviewsCount,
        completedJobs: completedJobs ?? this.completedJobs,
        averageResponseTime: averageResponseTime ?? this.averageResponseTime,
        coverageRadiusKm: coverageRadiusKm ?? this.coverageRadiusKm,
        transportFeePerKm: transportFeePerKm ?? this.transportFeePerKm,
        availability: availability ?? this.availability,
        idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
        selfieUrl: selfieUrl ?? this.selfieUrl,
        certificateUrl: certificateUrl ?? this.certificateUrl,
        referenceDetails: referenceDetails ?? this.referenceDetails,
        approvedAt: approvedAt ?? this.approvedAt,
      );
}

/// A single weekly availability slot.
class AvailabilitySlot {
  final int weekday; // 1=Mon, 7=Sun
  final String startTime; // "09:00"
  final String endTime; // "18:00"

  const AvailabilitySlot({
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) => AvailabilitySlot(
        weekday: json['weekday'] as int,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
      );

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'startTime': startTime,
        'endTime': endTime,
      };
}

/// Full sitter card (AppUser + BabysitterProfile merged for display).
class SitterCard {
  final AppUser user;
  final BabysitterProfile profile;
  final double? distanceKm;
  final bool isInTrustCircle;

  const SitterCard({
    required this.user,
    required this.profile,
    this.distanceKm,
    this.isInTrustCircle = false,
  });
}

