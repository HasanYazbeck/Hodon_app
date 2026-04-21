import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/user_role.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/otp_screen.dart';
import '../../presentation/auth/forgot_password_screen.dart';
import '../../presentation/auth/role_selection_screen.dart';
import '../../presentation/parent/home/parent_home_screen.dart';
import '../../presentation/parent/search/search_screen.dart';
import '../../presentation/parent/sitter_detail/sitter_detail_screen.dart';
import '../../presentation/parent/booking/create_booking_screen.dart';
import '../../presentation/parent/booking/booking_list_screen.dart';
import '../../presentation/parent/children/children_screen.dart';
import '../../presentation/parent/trust_circle/trust_circle_screen.dart';
import '../../presentation/parent/profile/parent_profile_screen.dart';
import '../../presentation/babysitter/home/babysitter_home_screen.dart';
import '../../presentation/babysitter/bookings/sitter_bookings_screen.dart';
import '../../presentation/babysitter/bookings/booking_request_screen.dart';
import '../../presentation/babysitter/profile/sitter_profile_screen.dart';
import '../../presentation/babysitter/verification/verification_center_screen.dart';
import '../../presentation/babysitter/verification/id_verification_screen.dart';
import '../../presentation/babysitter/verification/selfie_verification_screen.dart';
import '../../presentation/babysitter/verification/background_check_screen.dart';
import '../../presentation/babysitter/verification/cpr_certification_screen.dart';
import '../../presentation/babysitter/verification/first_aid_certificate_screen.dart';
import '../../presentation/babysitter/availability/availability_screen.dart';
import '../../presentation/babysitter/rates_services/rates_services_screen.dart';
import '../../presentation/babysitter/earnings/earnings_screen.dart';
import '../../presentation/shared/chat/chat_list_screen.dart';
import '../../presentation/shared/notifications/notifications_screen.dart';
import '../../presentation/shared/settings/settings_screen.dart';
import '../../presentation/onboarding/profile_setup_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// A [ChangeNotifier] that bridges Riverpod auth state into GoRouter's
/// [refreshListenable] so the router re-runs redirect without being recreated.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      if (authState is AuthInitial || authState is AuthLoading) {
        return location == '/splash' ? null : '/splash';
      }

      final isAuthenticated = authState is AuthAuthenticated;
      final needsOtp = authState is AuthOtpRequired;
      final publicRoutes = ['/onboarding', '/login', '/register', '/forgot-password'];
      final isPublicRoute = publicRoutes.any((r) => location.startsWith(r));

      if (needsOtp && !location.startsWith('/otp')) return '/otp';

      if (!isAuthenticated && location == '/splash') {
        return '/onboarding';
      }

      if (!isAuthenticated && !isPublicRoute && !location.startsWith('/otp') && location != '/splash') {
        return '/login';
      }

      if (isAuthenticated) {
        if (isPublicRoute || location == '/splash') {
          final user = authState.user;
          if (!user.isEmailVerified) return '/otp';
          if (!user.isProfileComplete) {
            return user.role == UserRole.parent
                ? '/parent/onboarding'
                : '/babysitter/onboarding';
          }
          return user.role == UserRole.parent ? '/parent/home' : '/babysitter/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/role-selection', builder: (_, __) => const RoleSelectionScreen()),
      GoRoute(path: '/profile-setup', builder: (_, __) => const ProfileSetupScreen()),

      // Parent shell
      ShellRoute(
        builder: (context, state, child) => ParentShell(state: state, child: child),
        routes: [
          GoRoute(path: '/parent/home', builder: (_, __) => const ParentHomeScreen()),
          GoRoute(path: '/parent/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/parent/bookings', builder: (_, __) => const BookingListScreen()),
          GoRoute(
            path: '/parent/sitter/:sitterId',
            builder: (_, state) => SitterDetailScreen(
              sitterId: state.pathParameters['sitterId']!,
            ),
          ),
          GoRoute(
            path: '/parent/book/:sitterId',
            builder: (_, state) => CreateBookingScreen(
              sitterId: state.pathParameters['sitterId']!,
            ),
          ),
          GoRoute(
            path: '/parent/booking/:bookingId',
            builder: (_, state) => BookingDetailScreen(
              bookingId: state.pathParameters['bookingId']!,
            ),
          ),
          GoRoute(path: '/parent/children', builder: (_, __) => const ChildrenScreen()),
          GoRoute(path: '/parent/add-child', builder: (_, __) => const AddChildScreen()),
          GoRoute(path: '/parent/trust-circle', builder: (_, __) => const TrustCircleScreen()),
          GoRoute(path: '/parent/profile', builder: (_, __) => const ParentProfileScreen()),
          GoRoute(path: '/parent/onboarding', builder: (_, __) => const ProfileSetupScreen()),
          GoRoute(path: '/parent/chat', builder: (_, __) => const ChatListScreen()),
          GoRoute(
            path: '/chat/:conversationId',
            builder: (_, state) => ChatScreen(
              conversationId: state.pathParameters['conversationId']!,
            ),
          ),
          GoRoute(path: '/parent/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/parent/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),

      // Babysitter shell
      ShellRoute(
        builder: (context, state, child) => SitterShell(state: state, child: child),
        routes: [
          GoRoute(path: '/babysitter/home', builder: (_, __) => const BabysitterHomeScreen()),
          GoRoute(path: '/babysitter/bookings', builder: (_, __) => const SitterBookingsScreen()),
          GoRoute(
            path: '/babysitter/booking-request/:bookingId',
            builder: (_, state) => BookingRequestScreen(
              bookingId: state.pathParameters['bookingId']!,
            ),
          ),
          GoRoute(path: '/babysitter/profile', builder: (_, __) => const SitterProfileScreen()),
          GoRoute(path: '/babysitter/verification', builder: (_, __) => const VerificationCenterScreen()),
          GoRoute(path: '/babysitter/verification/id', builder: (_, __) => const IdVerificationScreen()),
          GoRoute(path: '/babysitter/verification/selfie', builder: (_, __) => const SelfieVerificationScreen()),
          GoRoute(path: '/babysitter/verification/background-check', builder: (_, __) => const BackgroundCheckScreen()),
          GoRoute(path: '/babysitter/verification/cpr', builder: (_, __) => const CprCertificationScreen()),
          GoRoute(path: '/babysitter/verification/first-aid', builder: (_, __) => const FirstAidCertificateScreen()),
          GoRoute(path: '/babysitter/availability', builder: (_, __) => const AvailabilityScreen()),
          GoRoute(path: '/babysitter/rates-services', builder: (_, __) => const RatesServicesScreen()),
          GoRoute(path: '/babysitter/edit-profile', builder: (_, __) => const ProfileSetupScreen()),
          GoRoute(path: '/babysitter/onboarding', builder: (_, __) => const SitterOnboardingScreen()),
          GoRoute(path: '/babysitter/earnings', builder: (_, __) => const EarningsScreen()),
          GoRoute(path: '/babysitter/chat', builder: (_, __) => const ChatListScreen()),
          GoRoute(path: '/babysitter/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/babysitter/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );

  ref.onDispose(notifier.dispose);
  return router;
});

// ── Shell scaffolds with bottom navigation ──────────────────────────────────

class ParentShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  const ParentShell({super.key, required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppShell(
      state: state,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
      routes: [
        '/parent/home',
        '/parent/search',
        '/parent/bookings',
        '/parent/chat',
        '/parent/profile',
      ],
      child: child,
    );
  }
}

class SitterShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  const SitterShell({super.key, required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return _AppShell(
      state: state,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.work_rounded), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money_rounded), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ],
      routes: [
        '/babysitter/home',
        '/babysitter/bookings',
        '/babysitter/chat',
        '/babysitter/earnings',
        '/babysitter/profile',
      ],
      child: child,
    );
  }
}

class _AppShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;
  final List<BottomNavigationBarItem> items;
  final List<String> routes;

  const _AppShell({
    required this.state,
    required this.child,
    required this.items,
    required this.routes,
  });

  int _currentIndex() {
    final location = state.matchedLocation;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(),
        onTap: (i) => context.go(routes[i]),
        items: items,
      ),
    );
  }
}

