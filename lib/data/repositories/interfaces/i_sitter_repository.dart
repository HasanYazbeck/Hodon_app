import '../../../domain/models/babysitter_profile.dart';
import '../../../domain/models/models.dart';
import '../../../domain/enums/app_enums.dart';

class SitterFilter {
  final double? maxDistanceKm;
  final double? maxHourlyRate;
  final double? minRating;
  final List<ServiceType>? services;
  final List<ChildAgeGroup>? ageGroups;
  final List<String>? languages;
  final bool verifiedOnly;
  final bool cprOnly;
  final bool trustCircleOnly;
  final bool trustCircleFirst;
  final SitterSortBy sortBy;

  const SitterFilter({
    this.maxDistanceKm,
    this.maxHourlyRate,
    this.minRating,
    this.services,
    this.ageGroups,
    this.languages,
    this.verifiedOnly = false,
    this.cprOnly = false,
    this.trustCircleOnly = false,
    this.trustCircleFirst = false,
    this.sortBy = SitterSortBy.topRated,
  });

  SitterFilter copyWith({
    double? maxDistanceKm,
    double? maxHourlyRate,
    double? minRating,
    List<ServiceType>? services,
    List<ChildAgeGroup>? ageGroups,
    List<String>? languages,
    bool? verifiedOnly,
    bool? cprOnly,
    bool? trustCircleOnly,
    bool? trustCircleFirst,
    SitterSortBy? sortBy,
  }) =>
      SitterFilter(
        maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
        maxHourlyRate: maxHourlyRate ?? this.maxHourlyRate,
        minRating: minRating ?? this.minRating,
        services: services ?? this.services,
        ageGroups: ageGroups ?? this.ageGroups,
        languages: languages ?? this.languages,
        verifiedOnly: verifiedOnly ?? this.verifiedOnly,
        cprOnly: cprOnly ?? this.cprOnly,
        trustCircleOnly: trustCircleOnly ?? this.trustCircleOnly,
        trustCircleFirst: trustCircleFirst ?? this.trustCircleFirst,
        sortBy: sortBy ?? this.sortBy,
      );
}

enum SitterSortBy { nearest, topRated, lowestPrice, fastestAvailable }

abstract class ISitterRepository {
  Future<List<SitterCard>> searchSitters({
    required double latitude,
    required double longitude,
    required SitterFilter filter,
    required int page,
    required int pageSize,
  });

  Future<SitterCard> getSitterDetail(String sitterId);

  Future<List<Review>> getSitterReviews(String sitterId);
}

