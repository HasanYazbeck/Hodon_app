# AGENTS.md — hodon_app

## Big Picture
- `hodon_app` is no longer a Flutter counter scaffold; it is a feature-first Hodon marketplace foundation for parents and babysitters with Riverpod state, GoRouter navigation, mock repositories, secure auth persistence, and premium lavender-themed UI.
- App bootstrap is `lib/main.dart` → `ProviderScope` → `HodonApp` in `lib/app.dart`; routing is centralized in `lib/core/router/app_router.dart`.
- The codebase is layered as `presentation/`, `application/`, `domain/`, `data/`, and `core/`. Keep new code inside the same layer boundaries.

## Architecture That Matters
- Auth state lives in `lib/application/auth/auth_provider.dart` and drives router redirects. Do not bypass it with ad-hoc navigation guards.
- `GoRouter` uses two shell navigators in `lib/core/router/app_router.dart`: `ParentShell` and `SitterShell`, each with bottom navigation and role-specific routes.
- Repository injection is centralized in `lib/application/providers.dart`. Current implementations are mock-first (`MockAuthRepository`, `MockSitterRepository`, `MockBookingRepository`), with interfaces ready for remote replacements.
- Network and token handling are already scaffolded in `lib/core/network/api_client.dart` using Dio + auth refresh interceptor. Reuse this instead of creating new HTTP clients.
- Secure tokens/user identity are stored via `lib/core/storage/secure_storage_service.dart`; auth persistence depends on it.

## Implemented Product Flows
- Shared auth screens exist in `lib/presentation/auth/`: onboarding intro, register, login, OTP, forgot password, and role selection.
- Shared profile setup exists in `lib/presentation/onboarding/profile_setup_screen.dart` as a 3-step flow: photo, personal info, and location.
- Parent flows implemented in `lib/presentation/parent/`: home dashboard, sitter search/filtering, sitter details, booking creation/detail/list, children list/add, trust circle, and profile.
- Babysitter flows implemented in `lib/presentation/babysitter/`: home dashboard, booking requests/list, earnings, profile, and a lightweight onboarding flow embedded in `sitter_profile_screen.dart` and re-exported by `sitter_onboarding_screen.dart`.
- Shared communication/support surfaces exist in `lib/presentation/shared/`: chat list/detail, notifications, settings, and reusable widgets.

## Domain + Business Rules
- Core models live in `lib/domain/models/` and enums in `lib/domain/enums/`; use them instead of ad-hoc maps.
- Booking lifecycle is modeled in `booking_status.dart` and includes trust-circle notification states, active/past helpers, and cancelability helpers.
- Pricing logic is centralized in `BookingPricing.calculate()` in `lib/domain/models/booking.dart` (15% platform commission, emergency fee for emergency bookings).
- Sitter search uses `SitterFilter` from `lib/data/repositories/interfaces/i_sitter_repository.dart`; extend this object rather than adding loose filter params.
- User-facing text is largely centralized in `lib/core/constants/app_strings.dart`; continue externalizing strings there to stay localization-ready.

## Mock Data / QA Shortcuts
- Default sign-in credentials are in `lib/data/repositories/mock/mock_auth_repository.dart`:
  - Parent: `parent@test.com` / `Password1`
  - Babysitter: `sitter@test.com` / `Password1`
- Mock OTP accepts any 6-digit code.
- Several feature-local states are still screen-scoped providers or in-memory lists, notably children in `children_screen.dart` and trust circle members in `trust_circle_screen.dart`.

## UI / Styling Conventions
- Use the shared design system in `lib/core/constants/` (`app_colors.dart`, `app_sizes.dart`, `app_theme.dart`) and widgets in `lib/presentation/shared/widgets/` before adding bespoke UI.
- Visual direction is soft premium childcare: lavender primary, blush secondary, rounded cards, large spacing, and friendly iconography.
- Prefer `HodonCard`, `UserAvatar`, `StatusChip`, `TrustBadgeChip`, `EmptyState`, `SectionHeader`, `AppButton`, and `AppTextField` over raw Material widgets when possible.

## Developer Workflows
```powershell
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --debug
```
- Android builds currently rely on `android/gradle.properties` pinning Gradle to Android Studio JBR. If Android IDE imports show Flutter embedding errors, open the project root (`hodon_app`), not `android/` alone.
- `flutter build apk --debug` has been verified to succeed after the Android JDK and Material theme fixes.

## Project-Specific Conventions
- Use Riverpod providers/notifiers for app state; avoid introducing `setState` for cross-screen flows already represented in `application/`.
- Keep mock and future remote implementations behind repository interfaces in `lib/data/repositories/interfaces/`.
- Preserve route naming patterns like `/parent/...`, `/babysitter/...`, and shared `/chat/:conversationId`.
- When changing logout or auth behavior, verify router redirect behavior in `app_router.dart` rather than patching single screens only.
- Existing tests are minimal; `test/widget_test.dart` currently verifies app bootstrap and splash text, so add focused provider/widget tests near critical new logic.

