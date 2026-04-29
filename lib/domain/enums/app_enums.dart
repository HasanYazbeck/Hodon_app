enum BookingType { scheduled, instant, emergency }

extension BookingTypeX on BookingType {
  String get label => switch (this) {
        BookingType.scheduled => 'Scheduled',
        BookingType.instant => 'Instant',
        BookingType.emergency => 'Emergency',
      };
}

enum ServiceType {
  babysitting,
  fullTimeNanny,
  newbornInfantCare,
  childhoodEducation,
}

extension ServiceTypeX on ServiceType {
  String get label => switch (this) {
        ServiceType.babysitting => 'Babysitting',
        ServiceType.fullTimeNanny => 'Full-Time Nanny',
        ServiceType.newbornInfantCare => 'Newborn & Infant Care',
        ServiceType.childhoodEducation => 'Childhood Education',
      };
}

enum CareLocationType {
  parentHomeVisit,
  parentPickupFromSitter,
  sitterHomeHosting,
}

extension CareLocationTypeX on CareLocationType {
  String get label => switch (this) {
        CareLocationType.parentHomeVisit => 'Go to parent home',
        CareLocationType.parentPickupFromSitter => 'Parent picks up from sitter',
        CareLocationType.sitterHomeHosting => 'Host at sitter home',
      };

  String get description => switch (this) {
        CareLocationType.parentHomeVisit =>
          'You travel to the parent home to provide care.',
        CareLocationType.parentPickupFromSitter =>
          'The parent arranges pickup from your location before the booking.',
        CareLocationType.sitterHomeHosting =>
          'Children stay at your home during the booking.',
      };

  bool get requiresTransportFee => switch (this) {
        CareLocationType.parentHomeVisit => true,
        CareLocationType.parentPickupFromSitter => true,
        CareLocationType.sitterHomeHosting => false,
      };
}

enum ChildAgeGroup { baby, toddler, preschool, gradeschooler }

extension ChildAgeGroupX on ChildAgeGroup {
  String get label => switch (this) {
        ChildAgeGroup.baby => 'Baby (0–1)',
        ChildAgeGroup.toddler => 'Toddler (1–3)',
        ChildAgeGroup.preschool => 'Preschool (3–5)',
        ChildAgeGroup.gradeschooler => 'Gradeschooler (5–12)',
      };
}

enum Gender { male, female, preferNotToSay }

extension GenderX on Gender {
  String get label => switch (this) {
        Gender.male => 'Male',
        Gender.female => 'Female',
        Gender.preferNotToSay => 'Prefer not to say',
      };
}

enum VerificationStatus { notSubmitted, submitted, underReview, approved, rejected }

extension VerificationStatusX on VerificationStatus {
  String get label => switch (this) {
        VerificationStatus.notSubmitted => 'Not Submitted',
        VerificationStatus.submitted => 'Submitted',
        VerificationStatus.underReview => 'Under Review',
        VerificationStatus.approved => 'Approved',
        VerificationStatus.rejected => 'Rejected',
      };

  bool get isApproved => this == VerificationStatus.approved;
}

enum TrustBadge {
  idVerified,
  backgroundChecked,
  cprCertified,
  videoInterviewed,
  topRated,
  repeatFamilyFavorite,
}

extension TrustBadgeX on TrustBadge {
  String get label => switch (this) {
        TrustBadge.idVerified => 'ID Verified',
        TrustBadge.backgroundChecked => 'Background Checked',
        TrustBadge.cprCertified => 'CPR Certified',
        TrustBadge.videoInterviewed => 'Video Interviewed',
        TrustBadge.topRated => 'Top Rated',
        TrustBadge.repeatFamilyFavorite => 'Repeat Family Favorite',
      };
}

enum SitterSkill {
  firstAidCPR,
  storytellingCreativePlay,
  patienceAndCalmness,
  conflictResolution,
  feedingAndMealPrep,
  homeworkAssistance,
  specialNeedsSupport,
  musicalActivities,
  outdoorActivities,
  artsAndCrafts,
}

extension SitterSkillX on SitterSkill {
  String get label => switch (this) {
        SitterSkill.firstAidCPR => 'First Aid & CPR',
        SitterSkill.storytellingCreativePlay => 'Storytelling & Creative Play',
        SitterSkill.patienceAndCalmness => 'Patience & Calmness',
        SitterSkill.conflictResolution => 'Conflict Resolution',
        SitterSkill.feedingAndMealPrep => 'Feeding & Meal Prep',
        SitterSkill.homeworkAssistance => 'Homework Assistance',
        SitterSkill.specialNeedsSupport => 'Special Needs Support',
        SitterSkill.musicalActivities => 'Musical Activities',
        SitterSkill.outdoorActivities => 'Outdoor Activities',
        SitterSkill.artsAndCrafts => 'Arts & Crafts',
      };
}

enum PaymentMethod { card, cash, wallet }

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.card => 'Credit / Debit Card',
        PaymentMethod.cash => 'Cash',
        PaymentMethod.wallet => 'Hodon Wallet',
      };
}

enum NotificationType {
  otp,
  bookingRequest,
  bookingAccepted,
  bookingRejected,
  bookingReminder,
  emergencyRequest,
  checkIn,
  checkOut,
  paymentStatus,
  trustCircleInvite,
  reviewRequest,
  supportUpdate,
  general,
}

enum TrustCircleMemberType { babysitter, relative, friend, other }

