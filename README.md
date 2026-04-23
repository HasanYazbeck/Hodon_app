# hodon_app

Hodon marketplace app foundation (parents + babysitters) with Riverpod, GoRouter, and repository-based data sources.

## Remote Auth Setup (Step by Step)

The app now includes `RemoteAuthRepository` at:
- `lib/data/repositories/remote/remote_auth_repository.dart`

Auth repository selection is controlled in:
- `lib/application/providers.dart`

By default, mock auth is still used. Enable remote auth with `--dart-define=USE_REMOTE_AUTH=true`.

### 1) Prepare backend endpoints

Make sure your backend exposes these endpoints (matching `lib/core/constants/api_endpoints.dart`):
- `POST /auth/register`
- `POST /auth/verify-otp`
- `POST /auth/resend-otp`
- `POST /auth/login`
- `POST /auth/logout`
- `POST /auth/forgot-password`
- `POST /auth/reset-password`
- `GET /users/me`
- `PUT /users/me` (profile + role updates)

Expected auth response for login should include:
- `accessToken`
- `refreshToken`
- `user` (or user retrievable from `/users/me`)

### 2) Run app against your backend base URL

Use compile-time defines:

```powershell
flutter run --dart-define=USE_REMOTE_AUTH=true --dart-define=API_BASE_URL=https://your-api-domain.com/v1
```

### 3) Test core auth flow

- Register a new account
- Verify OTP
- Login
- Confirm role/profile routing
- Logout and login again

### 4) Keep mock mode for local UI work

If backend is unavailable, run without remote flag:

```powershell
flutter run
```

### 5) Troubleshooting

- `UNVERIFIED_EMAIL` is preserved from backend errors and used by UI routing logic.
- If login returns tokens but no user object, app fetches `/users/me` automatically.
- If `/users/me` returns 401, local tokens are cleared.

## Notes

- `ApiClient` already handles auth header injection and token refresh interceptor.
- Tokens/user identity are persisted via `SecureStorageService`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
