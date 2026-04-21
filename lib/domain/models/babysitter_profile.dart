import '../enums/app_enums.dart';
import 'user.dart';

class BabysitterProfile {
  final String userId;
  final int yearsOfExperience;
  final double hourlyRate;
  final List<SitterSkill> skills;
  final List<ServiceType> services;
  final List<ChildAgeGroup> ageGroups;
  final List<String> languages;
  final List<TrustBadge> badges;
  final VerificationStatus verificationStatus;
  final double rating;
  final int reviewsCount;
  final int completedJobs;
  final String? averageResponseTime; // e.g. "~15 min"
  final double? coverageRadiusKm;
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
    required this.skills,
    required this.services,
    required this.ageGroups,
    required this.languages,
    required this.badges,
    required this.verificationStatus,
    required this.rating,
    required this.reviewsCount,
    required this.completedJobs,
    this.averageResponseTime,
    this.coverageRadiusKm,
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

  factory BabysitterProfile.fromJson(Map<String, dynamic> json) => BabysitterProfile(
        userId: json['userId'] as String,
        yearsOfExperience: json['yearsOfExperience'] as int,
        hourlyRate: (json['hourlyRate'] as num).toDouble(),
        skills: (json['skills'] as List<dynamic>)
            .map((e) => SitterSkill.values.byName(e as String))
            .toList(),
        services: (json['services'] as List<dynamic>)
            .map((e) => ServiceType.values.byName(e as String))
            .toList(),
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
        'skills': skills.map((e) => e.name).toList(),
        'services': services.map((e) => e.name).toList(),
        'ageGroups': ageGroups.map((e) => e.name).toList(),
        'languages': languages,
        'badges': badges.map((e) => e.name).toList(),
        'verificationStatus': verificationStatus.name,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'completedJobs': completedJobs,
        'averageResponseTime': averageResponseTime,
        'coverageRadiusKm': coverageRadiusKm,
        'availability': availability.map((e) => e.toJson()).toList(),
        'idDocumentUrl': idDocumentUrl,
        'selfieUrl': selfieUrl,
        'certificateUrl': certificateUrl,
        'referenceDetails': referenceDetails,
        'approvedAt': approvedAt?.toIso8601String(),
      };
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

