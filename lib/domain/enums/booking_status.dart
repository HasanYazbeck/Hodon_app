enum BookingStatus {
  draft,
  pending,
  notifyingTrustCircle,
  notifyingSitterPool,
  accepted,
  parentConfirmed,
  sitterEnRoute,
  checkedIn,
  inProgress,
  completed,
  rated,
  cancelledByParent,
  cancelledBySitter,
  expired,
}

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
        BookingStatus.draft => 'Draft',
        BookingStatus.pending => 'Pending',
        BookingStatus.notifyingTrustCircle => 'Notifying Trust Circle',
        BookingStatus.notifyingSitterPool => 'Finding Sitter',
        BookingStatus.accepted => 'Accepted',
        BookingStatus.parentConfirmed => 'Confirmed',
        BookingStatus.sitterEnRoute => 'Sitter En Route',
        BookingStatus.checkedIn => 'Checked In',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.rated => 'Rated',
        BookingStatus.cancelledByParent => 'Cancelled',
        BookingStatus.cancelledBySitter => 'Cancelled by Sitter',
        BookingStatus.expired => 'Expired',
      };

  bool get isActive => [
        BookingStatus.accepted,
        BookingStatus.parentConfirmed,
        BookingStatus.sitterEnRoute,
        BookingStatus.checkedIn,
        BookingStatus.inProgress,
      ].contains(this);

  bool get isPast => [
        BookingStatus.completed,
        BookingStatus.rated,
        BookingStatus.cancelledByParent,
        BookingStatus.cancelledBySitter,
        BookingStatus.expired,
      ].contains(this);

  bool get canCancelWithoutFee => [
        BookingStatus.pending,
        BookingStatus.notifyingTrustCircle,
        BookingStatus.notifyingSitterPool,
      ].contains(this);

  bool get requiresPlatformFeeDeductionOnParentCancellation => [
        BookingStatus.accepted,
        BookingStatus.parentConfirmed,
      ].contains(this);

  bool get canCancelByParent =>
      canCancelWithoutFee || requiresPlatformFeeDeductionOnParentCancellation;

  // Backward-compatible alias for older usages.
  bool get requiresParentCancellationFee =>
      requiresPlatformFeeDeductionOnParentCancellation;

  // Backward-compatible alias used by existing screens.
  bool get canCancel => canCancelByParent;
}
