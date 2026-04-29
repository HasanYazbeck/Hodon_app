import '../../../domain/models/babysitter_profile.dart';
import '../../../domain/models/models.dart';
import '../../../domain/models/user.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/user_role.dart';
import '../interfaces/i_sitter_repository.dart';

class MockSitterRepository implements ISitterRepository {
  final List<SitterCard> _sitters = _buildMockSitters();

  @override
  Future<List<SitterCard>> searchSitters({
    required double latitude,
    required double longitude,
    required SitterFilter filter,
    required int page,
    required int pageSize,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    var results = List<SitterCard>.from(_sitters);

    if (filter.verifiedOnly) {
      results = results.where((s) => s.profile.isVerified).toList();
    }
    if (filter.cprOnly) {
      results = results.where((s) => s.profile.hasCPR).toList();
    }
    if (filter.maxHourlyRate != null) {
      results = results
          .where((s) => s.profile.startingHourlyRate <= filter.maxHourlyRate!)
          .toList();
    }
    if (filter.minRating != null) {
      results = results.where((s) => s.profile.rating >= filter.minRating!).toList();
    }

    results.sort((a, b) => switch (filter.sortBy) {
          SitterSortBy.topRated => b.profile.rating.compareTo(a.profile.rating),
          SitterSortBy.lowestPrice =>
            a.profile.startingHourlyRate.compareTo(b.profile.startingHourlyRate),
          SitterSortBy.nearest => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999),
          SitterSortBy.fastestAvailable => a.profile.completedJobs.compareTo(b.profile.completedJobs),
        });

    final start = page * pageSize;
    if (start >= results.length) return [];
    return results.skip(start).take(pageSize).toList();
  }

  @override
  Future<SitterCard> getSitterDetail(String sitterId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _sitters.firstWhere((s) => s.user.id == sitterId);
  }

  @override
  Future<SitterCard> updateSitterProfile({
    required String sitterId,
    required BabysitterProfile profile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _sitters.indexWhere((s) => s.user.id == sitterId);
    if (index == -1) throw Exception('Sitter not found');

    final existing = _sitters[index];
    final updated = SitterCard(
      user: existing.user.copyWith(updatedAt: DateTime.now()),
      profile: profile,
      distanceKm: existing.distanceKm,
      isInTrustCircle: existing.isInTrustCircle,
    );
    _sitters[index] = updated;
    return updated;
  }

  @override
  Future<List<Review>> getSitterReviews(String sitterId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockReviews.where((r) => r.revieweeId == sitterId).toList();
  }

  static List<SitterCard> _buildMockSitters() => [
        SitterCard(
          distanceKm: 1.2,
          user: AppUser(
            id: 'user_sitter_1',
            email: 'lara@test.com',
            fullName: 'Lara Haddad',
            role: UserRole.babysitter,
            avatarUrl: 'https://i.pravatar.cc/150?img=47',
            bio: 'Passionate and caring babysitter with 5 years of experience.',
            address: const UserAddress(
              id: 'sitter_addr_1',
              label: 'Home',
              fullAddress: 'Gemmayzeh, Beirut, Lebanon',
              latitude: 33.8950,
              longitude: 35.5175,
              isDefault: true,
            ),
            isEmailVerified: true,
            isProfileComplete: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime.now(),
          ),
          profile: BabysitterProfile(
            userId: 'user_sitter_1',
            yearsOfExperience: 5,
            hourlyRate: 15,
            serviceHourlyRates: const {
              ServiceType.babysitting: 15,
              ServiceType.newbornInfantCare: 20,
            },
            skills: [SitterSkill.firstAidCPR, SitterSkill.feedingAndMealPrep, SitterSkill.storytellingCreativePlay],
            services: [ServiceType.babysitting, ServiceType.newbornInfantCare],
            supportedCareLocations: const [
              CareLocationType.parentHomeVisit,
              CareLocationType.parentPickupFromSitter,
            ],
            ageGroups: [ChildAgeGroup.baby, ChildAgeGroup.toddler, ChildAgeGroup.preschool],
            languages: ['English', 'Arabic'],
            badges: [TrustBadge.idVerified, TrustBadge.cprCertified, TrustBadge.topRated],
            verificationStatus: VerificationStatus.approved,
            rating: 4.9,
            reviewsCount: 48,
            completedJobs: 112,
            averageResponseTime: '~10 min',
            coverageRadiusKm: 12,
            transportFeePerKm: 1.4,
            availability: [
              AvailabilitySlot(weekday: 1, startTime: '09:00', endTime: '20:00'),
              AvailabilitySlot(weekday: 2, startTime: '09:00', endTime: '20:00'),
              AvailabilitySlot(weekday: 6, startTime: '10:00', endTime: '18:00'),
            ],
          ),
        ),
        SitterCard(
          distanceKm: 2.8,
          user: AppUser(
            id: 'user_sitter_2',
            email: 'maya@test.com',
            fullName: 'Maya Nassar',
            role: UserRole.babysitter,
            avatarUrl: 'https://i.pravatar.cc/150?img=45',
            bio: 'Early childhood educator with a love for creative learning.',
            address: const UserAddress(
              id: 'sitter_addr_2',
              label: 'Home',
              fullAddress: 'Mar Mikhael, Beirut, Lebanon',
              latitude: 33.8988,
              longitude: 35.5242,
              isDefault: true,
            ),
            isEmailVerified: true,
            isProfileComplete: true,
            createdAt: DateTime(2024, 3, 1),
            updatedAt: DateTime.now(),
          ),
          profile: BabysitterProfile(
            userId: 'user_sitter_2',
            yearsOfExperience: 3,
            hourlyRate: 12,
            serviceHourlyRates: const {
              ServiceType.babysitting: 12,
              ServiceType.childhoodEducation: 17,
            },
            skills: [SitterSkill.homeworkAssistance, SitterSkill.artsAndCrafts, SitterSkill.patienceAndCalmness],
            services: [ServiceType.babysitting, ServiceType.childhoodEducation],
            supportedCareLocations: const [
              CareLocationType.parentHomeVisit,
              CareLocationType.sitterHomeHosting,
            ],
            ageGroups: [ChildAgeGroup.preschool, ChildAgeGroup.gradeschooler],
            languages: ['English', 'French'],
            badges: [TrustBadge.idVerified, TrustBadge.videoInterviewed],
            verificationStatus: VerificationStatus.approved,
            rating: 4.7,
            reviewsCount: 31,
            completedJobs: 67,
            averageResponseTime: '~20 min',
            coverageRadiusKm: 10,
            transportFeePerKm: 1.1,
            availability: [
              AvailabilitySlot(weekday: 3, startTime: '14:00', endTime: '20:00'),
              AvailabilitySlot(weekday: 4, startTime: '14:00', endTime: '20:00'),
              AvailabilitySlot(weekday: 5, startTime: '09:00', endTime: '18:00'),
            ],
          ),
        ),
        SitterCard(
          distanceKm: 0.9,
          isInTrustCircle: true,
          user: AppUser(
            id: 'user_sitter_3',
            email: 'rima@test.com',
            fullName: 'Rima Azar',
            role: UserRole.babysitter,
            avatarUrl: 'https://i.pravatar.cc/150?img=44',
            bio: 'Gentle and reliable nanny, experienced with newborns.',
            address: const UserAddress(
              id: 'sitter_addr_3',
              label: 'Home',
              fullAddress: 'Badaro, Beirut, Lebanon',
              latitude: 33.8783,
              longitude: 35.5193,
              isDefault: true,
            ),
            isEmailVerified: true,
            isProfileComplete: true,
            createdAt: DateTime(2023, 6, 1),
            updatedAt: DateTime.now(),
          ),
          profile: BabysitterProfile(
            userId: 'user_sitter_3',
            yearsOfExperience: 7,
            hourlyRate: 18,
            serviceHourlyRates: const {
              ServiceType.babysitting: 18,
              ServiceType.newbornInfantCare: 24,
              ServiceType.fullTimeNanny: 21,
            },
            skills: [SitterSkill.firstAidCPR, SitterSkill.feedingAndMealPrep, SitterSkill.patienceAndCalmness],
            services: [ServiceType.babysitting, ServiceType.newbornInfantCare, ServiceType.fullTimeNanny],
            supportedCareLocations: const [
              CareLocationType.parentHomeVisit,
              CareLocationType.parentPickupFromSitter,
              CareLocationType.sitterHomeHosting,
            ],
            ageGroups: [ChildAgeGroup.baby, ChildAgeGroup.toddler],
            languages: ['Arabic', 'English'],
            badges: [TrustBadge.idVerified, TrustBadge.cprCertified, TrustBadge.backgroundChecked, TrustBadge.repeatFamilyFavorite],
            verificationStatus: VerificationStatus.approved,
            rating: 5.0,
            reviewsCount: 62,
            completedJobs: 145,
            averageResponseTime: '~5 min',
            coverageRadiusKm: 18,
            transportFeePerKm: 1.8,
            availability: [
              AvailabilitySlot(weekday: 1, startTime: '08:00', endTime: '22:00'),
              AvailabilitySlot(weekday: 2, startTime: '08:00', endTime: '22:00'),
              AvailabilitySlot(weekday: 3, startTime: '08:00', endTime: '22:00'),
              AvailabilitySlot(weekday: 4, startTime: '08:00', endTime: '22:00'),
              AvailabilitySlot(weekday: 5, startTime: '08:00', endTime: '22:00'),
            ],
          ),
        ),
        SitterCard(
          distanceKm: 4.1,
          user: AppUser(
            id: 'user_sitter_4',
            email: 'nour@test.com',
            fullName: 'Nour Gemayel',
            role: UserRole.babysitter,
            avatarUrl: 'https://i.pravatar.cc/150?img=41',
            bio: 'Energetic and fun babysitter, great with school-age kids.',
            address: const UserAddress(
              id: 'sitter_addr_4',
              label: 'Home',
              fullAddress: 'Hazmieh, Beirut, Lebanon',
              latitude: 33.8677,
              longitude: 35.5531,
              isDefault: true,
            ),
            isEmailVerified: true,
            isProfileComplete: true,
            createdAt: DateTime(2024, 6, 1),
            updatedAt: DateTime.now(),
          ),
          profile: BabysitterProfile(
            userId: 'user_sitter_4',
            yearsOfExperience: 2,
            hourlyRate: 10,
            serviceHourlyRates: const {
              ServiceType.babysitting: 10,
              ServiceType.childhoodEducation: 14,
            },
            skills: [SitterSkill.homeworkAssistance, SitterSkill.outdoorActivities, SitterSkill.conflictResolution],
            services: [ServiceType.babysitting, ServiceType.childhoodEducation],
            supportedCareLocations: const [
              CareLocationType.sitterHomeHosting,
              CareLocationType.parentHomeVisit,
            ],
            ageGroups: [ChildAgeGroup.preschool, ChildAgeGroup.gradeschooler],
            languages: ['Arabic', 'English'],
            badges: [TrustBadge.idVerified],
            verificationStatus: VerificationStatus.approved,
            rating: 4.5,
            reviewsCount: 14,
            completedJobs: 28,
            averageResponseTime: '~30 min',
            coverageRadiusKm: 8,
            transportFeePerKm: 0.9,
            availability: [
              AvailabilitySlot(weekday: 6, startTime: '10:00', endTime: '20:00'),
              AvailabilitySlot(weekday: 7, startTime: '10:00', endTime: '20:00'),
            ],
          ),
        ),
      ];

  static final List<Review> _mockReviews = [
    Review(
      id: 'rev_1',
      bookingId: 'bk_1',
      reviewerId: 'user_parent_1',
      revieweeId: 'user_sitter_1',
      overallRating: 5.0,
      punctualityRating: 5.0,
      careQualityRating: 5.0,
      communicationRating: 5.0,
      professionalismRating: 5.0,
      comment: 'Lara was absolutely wonderful with our baby. Will definitely book again!',
      createdAt: DateTime(2025, 3, 10),
      reviewerName: 'Sara K.',
      reviewerAvatarUrl: 'https://i.pravatar.cc/150?img=32',
    ),
    Review(
      id: 'rev_2',
      bookingId: 'bk_2',
      reviewerId: 'user_parent_2',
      revieweeId: 'user_sitter_1',
      overallRating: 4.8,
      punctualityRating: 5.0,
      careQualityRating: 5.0,
      communicationRating: 4.5,
      professionalismRating: 4.8,
      comment: 'Very professional and our kids loved her.',
      createdAt: DateTime(2025, 2, 15),
      reviewerName: 'Nadia M.',
      reviewerAvatarUrl: 'https://i.pravatar.cc/150?img=33',
    ),
  ];
}

