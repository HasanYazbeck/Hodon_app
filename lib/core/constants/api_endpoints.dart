/// All REST API endpoint paths.
/// Base URL is injected via environment or [ApiClient].
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users / Profile
  static const String me = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';

  // Parent
  static const String parentProfile = '/parents/profile';
  static const String children = '/parents/children';
  static String child(String id) => '/parents/children/$id';

  // Trust Circle
  static const String trustCircle = '/parents/trust-circle';
  static String trustCircleMember(String id) => '/parents/trust-circle/$id';
  static const String inviteTrustCircle = '/parents/trust-circle/invite';

  // Babysitter
  static const String babysitterProfile = '/babysitters/profile';
  static const String listSitters = '/babysitters';
  static String sitterDetail(String id) => '/babysitters/$id';
  static const String sitterAvailability = '/babysitters/availability';
  static const String sitterServices = '/babysitters/services';
  static const String sitterVerification = '/babysitters/verification';
  static const String uploadDocument = '/babysitters/documents';

  // Bookings
  static const String bookings = '/bookings';
  static String booking(String id) => '/bookings/$id';
  static String acceptBooking(String id) => '/bookings/$id/accept';
  static String rejectBooking(String id) => '/bookings/$id/reject';
  static String checkIn(String id) => '/bookings/$id/check-in';
  static String checkOut(String id) => '/bookings/$id/check-out';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static const String emergencyBooking = '/bookings/emergency';

  // Reviews
  static const String reviews = '/reviews';
  static String sitterReviews(String sitterId) => '/babysitters/$sitterId/reviews';

  // Chat
  static const String conversations = '/chat/conversations';
  static String messages(String conversationId) => '/chat/conversations/$conversationId/messages';
  static String sendMessage(String conversationId) => '/chat/conversations/$conversationId/messages';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String registerFcmToken = '/notifications/fcm-token';

  // Payments
  static const String paymentMethods = '/payments/methods';
  static const String createPaymentIntent = '/payments/intents';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionPlans = '/subscriptions/plans';

  // Location
  static const String geocode = '/location/geocode';
  static const String reverseGeocode = '/location/reverse-geocode';
}

