/// Application string keys — all user-facing strings externalized for l10n.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Hodon';
  static const String appTagline = 'Trusted Childcare, Near You';

  // Common
  static const String continueLabel = 'Continue';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String done = 'Done';
  static const String skip = 'Skip';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String clear = 'Clear';
  static const String apply = 'Apply';
  static const String viewAll = 'View All';
  static const String seeMore = 'See More';
  static const String select = 'Select';

  // Auth
  static const String welcomeBack = 'Welcome Back!';
  static const String loginSubtitle = 'Sign in to your Hodon account';
  static const String createAccount = 'Create Account';
  static const String registerSubtitle = 'Join Hodon — trusted childcare in Lebanon';
  static const String emailLabel = 'Email Address';
  static const String emailHint = 'you@example.com';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'At least 8 characters';
  static const String confirmPasswordLabel = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginButton = 'Sign In';
  static const String registerButton = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String orContinueWith = 'or continue with';
  static const String logout = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';

  // OTP
  static const String verifyEmail = 'Verify Your Email';
  static const String otpSubtitle = 'We sent a 6-digit code to';
  static const String otpHint = 'Enter code';
  static const String verifyButton = 'Verify';
  static const String resendCode = 'Resend Code';
  static const String resendIn = 'Resend in ';
  static const String accountVerified = 'Account Verified!';
  static const String accountVerifiedSubtitle = 'Your email has been verified successfully.';

  // Role Selection
  static const String whatBringsYou = "What brings you\nto Hodon?";
  static const String roleSelectionSubtitle = 'Choose your role to get started';
  static const String iAmParent = "I'm a Parent";
  static const String iAmParentSubtitle = 'Find trusted babysitters for my children';
  static const String iAmBabysitter = "I'm a Babysitter";
  static const String iAmBabysitterSubtitle = 'Offer my childcare services to families';

  // Profile setup
  static const String completeProfile = 'Complete Your Profile';
  static const String uploadPhoto = 'Upload Photo';
  static const String fullNameLabel = 'Full Name';
  static const String fullNameHint = 'Your full name';
  static const String phoneLabel = 'Phone Number';
  static const String phoneHint = '+961 XX XXX XXX';
  static const String dobLabel = 'Date of Birth';
  static const String genderLabel = 'Gender';
  static const String bioLabel = 'About Me';
  static const String bioHint = 'Tell families a bit about yourself...';
  static const String locationLabel = 'Location';
  static const String locationHint = 'Search your area';
  static const String useCurrentLocation = 'Use Current Location';

  // Babysitter onboarding
  static const String experienceLabel = 'Years of Experience';
  static const String skillsLabel = 'Skills & Training';
  static const String servicesLabel = 'Services Offered';
  static const String ageGroupsLabel = 'Preferred Age Groups';
  static const String hourlyRateLabel = 'Hourly Rate (USD)';
  static const String hourlyRateHint = 'e.g. 15';
  static const String languagesLabel = 'Languages Spoken';
  static const String availabilityLabel = 'Set Availability';
  static const String verificationCenter = 'Verification Center';
  static const String uploadId = 'Upload ID';
  static const String uploadCertificate = 'Upload Certificate';
  static const String selfieVerification = 'Selfie Verification';
  static const String referenceDetails = 'Reference Details';
  static const String pendingApproval = 'Pending Approval';
  static const String profileUnderReview = 'Your profile is under review. We\'ll notify you once approved.';

  // Parent onboarding
  static const String addChild = 'Add Child';
  static const String childProfiles = 'Child Profiles';
  static const String childNameLabel = 'Child\'s Name';
  static const String childAgeLabel = 'Age';
  static const String allergiesLabel = 'Allergies';
  static const String allergiesHint = 'List any allergies (e.g. nuts, dairy)';
  static const String routinesLabel = 'Routines';
  static const String routinesHint = 'Nap time, feeding schedule, etc.';
  static const String notesLabel = 'Special Notes';
  static const String notesHint = 'Any other important information';
  static const String emergencyContactLabel = 'Emergency Contact';
  static const String emergencyContactHint = 'Name and phone number';
  static const String setupPayment = 'Set Up Payment';
  static const String inviteTrustCircle = 'Invite Trust Circle';
  static const String trustCircle = 'Trust Circle';
  static const String trustCircleSubtitle = 'Invite trusted people to your Hodon network';

  // Home - Parent
  static const String goodMorning = 'Good Morning,';
  static const String goodAfternoon = 'Good Afternoon,';
  static const String goodEvening = 'Good Evening,';
  static const String findBabysitter = 'Find a Babysitter';
  static const String emergencyBooking = 'Emergency Booking';
  static const String emergencyBookingSubtitle = 'Need a sitter right now?';
  static const String upcomingBookings = 'Upcoming Bookings';
  static const String recentActivity = 'Recent Activity';
  static const String noUpcomingBookings = 'No upcoming bookings';
  static const String topRatedSitters = 'Top Rated Sitters';
  static const String trustCircleAvailable = 'Trust Circle Available';

  // Search
  static const String searchSitters = 'Search Babysitters';
  static const String searchFilters = 'Filters';
  static const String noSittersFound = 'No sitters found';
  static const String noSittersSubtitle = 'Try adjusting your filters';
  static const String verified = 'Verified';
  static const String topRated = 'Top Rated';
  static const String inTrustCircle = 'In Your Circle';
  static const String perHour = '/hr';
  static const String kmAway = 'km away';
  static const String reviews = 'reviews';

  // Booking
  static const String bookNow = 'Book Now';
  static const String scheduleBooking = 'Schedule Booking';
  static const String bookingDetails = 'Booking Details';
  static const String selectDate = 'Select Date';
  static const String selectTime = 'Select Time';
  static const String selectDuration = 'Duration';
  static const String selectChildren = 'Select Children';
  static const String selectService = 'Service Type';
  static const String paymentMethod = 'Payment Method';
  static const String bookingNotes = 'Notes for Sitter';
  static const String bookingNotesHint = 'Any special instructions...';
  static const String totalAmount = 'Total Amount';
  static const String platformFee = 'Platform Fee';
  static const String emergencyFee = 'Emergency Fee';
  static const String confirmBooking = 'Confirm Booking';
  static const String bookingConfirmed = 'Booking Confirmed!';
  static const String bookingPending = 'Booking Pending';
  static const String bookingAccepted = 'Booking Accepted';
  static const String bookingInProgress = 'In Progress';
  static const String bookingCompleted = 'Completed';
  static const String bookingCancelled = 'Cancelled';
  static const String bookingExpired = 'Expired';
  static const String cancelBooking = 'Cancel Booking';
  static const String cancelReason = 'Reason for Cancellation';
  static const String rateYourExperience = 'Rate Your Experience';

  // Trust Circle
  static const String trustCircleFirst = 'Trust Circle First';
  static const String notifyTrustCircle = 'Notify Trust Circle';
  static const String expandToAll = 'Expand to All Sitters';
  static const String addToTrustCircle = 'Add to Trust Circle';
  static const String removeFromTrustCircle = 'Remove from Circle';
  static const String inviteByEmail = 'Invite by Email';
  static const String inviteByPhone = 'Invite by Phone';

  // Chat
  static const String messages = 'Messages';
  static const String typeAMessage = 'Type a message...';
  static const String safetyNote = 'Keep all communication within the app for your safety.';
  static const String noConversations = 'No conversations yet';
  static const String noConversationsSubtitle = 'Your chats with babysitters will appear here';

  // Babysitter Home
  static const String myJobs = 'My Jobs';
  static const String newRequests = 'New Requests';
  static const String earnings = 'Earnings';
  static const String availability = 'Availability';
  static const String acceptRequest = 'Accept';
  static const String rejectRequest = 'Decline';
  static const String checkIn = 'Check In';
  static const String checkOut = 'Check Out';
  static const String currentJob = 'Current Job';
  static const String noActiveJobs = 'No active jobs';

  // Verification
  static const String idVerified = 'ID Verified';
  static const String backgroundChecked = 'Background Checked';
  static const String cprCertified = 'CPR Certified';
  static const String videoInterviewed = 'Video Interviewed';
  static const String topRatedBadge = 'Top Rated';
  static const String repeatFamilyFavorite = 'Repeat Family Favorite';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String unauthorizedError = 'Session expired. Please sign in again.';
  static const String serverError = 'Server error. Please try again later.';
  static const String notFoundError = 'Not found.';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort = 'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String otpInvalid = 'Please enter a valid 6-digit code';
  static const String rateTooLow = 'Minimum rate is \$5/hr';

  // Settings
  static const String settings = 'Settings';
  static const String account = 'Account';
  static const String notifications = 'Notifications';
  static const String privacy = 'Privacy';
  static const String helpSupport = 'Help & Support';
  static const String termsAndConditions = 'Terms & Conditions';
  static const String privacyPolicy = 'Privacy Policy';
  static const String language = 'Language';
  static const String version = 'Version';
}

