# Quick Actions & Communication Guide

This guide documents the quick actions and communication features implemented in the Hodon app.

## Overview

The app provides multiple channels for users to get help and support through quick actions that directly open external applications or services.

## Communication Channels

### Email Support
- **Email**: support@hodon.app
- **Method**: Opens device email client with pre-filled subject and body
- **Implementation**: `CommunicationService.sendEmail()`

### Phone Support
- **Phone**: +961123456789 (Lebanon)
- **Display Format**: +961 1 234 567
- **Method**: Opens native phone dialer
- **Implementation**: `CommunicationService.makePhoneCall()`

### WhatsApp Support
- **Method**: Opens WhatsApp with pre-filled message
- **Implementation**: `CommunicationService.openWhatsApp()`

### Live Chat
- **Method**: In-app navigation to chat screens
- **Implementation**: `context.go('/parent/chat')` or `context.go('/babysitter/chat')`

## CommunicationService API

Located at: `lib/core/utils/communication_service.dart`

### Methods

#### `sendEmail()`
```dart
static Future<void> sendEmail({
  required String toEmail,
  String subject = '',
  String body = '',
})
```
Opens the device's email client with optional pre-filled subject and body.

#### `makePhoneCall()`
```dart
static Future<void> makePhoneCall(String phoneNumber)
```
Opens the phone dialer with a specific phone number.

#### `sendSMS()`
```dart
static Future<void> sendSMS(String phoneNumber, {String message = ''})
```
Opens the SMS app with optional pre-filled message.

#### `openWhatsApp()`
```dart
static Future<void> openWhatsApp(String phoneNumber, {String message = ''})
```
Opens WhatsApp with the specified phone number and optional message.

#### `openUrl()`
```dart
static Future<void> openUrl(String url)
```
Opens a URL in the default browser.

#### `showCommunicationDialog()`
```dart
static void showCommunicationDialog(BuildContext context)
```
Shows a bottom sheet with all communication options for quick access.

## UI Integration Points

### Parent Home Screen
- **Location**: `lib/presentation/parent/home/parent_home_screen.dart`
- **FAB**: Help icon floating action button
- **Behavior**: Shows bottom sheet with communication options (chat, email, call, WhatsApp)

### Babysitter Home Screen
- **Location**: `lib/presentation/babysitter/home/babysitter_home_screen.dart`
- **FAB**: Help icon floating action button
- **Behavior**: Shows bottom sheet with communication options (chat, email, call, WhatsApp)

### Help & Support Screen
- **Location**: `lib/presentation/shared/support/help_support_screen.dart`
- **Features**:
  - Live Chat: Navigates to chat list
  - Email Support: Opens email client
  - Call Us: Opens phone dialer
  - FAQ section with expandable items

## User Flows

### Parent User Getting Help
1. User clicks help (?) FAB on home screen
2. Bottom sheet appears with options
3. User selects desired communication channel:
   - **Chat**: Routes to in-app chat list
   - **Email**: Opens email client with pre-filled support email
   - **Call**: Opens phone dialer
   - **WhatsApp**: Opens WhatsApp with pre-filled message

### Babysitter User Getting Help
Same flow as parent user but with `/babysitter/chat` route for chat option.

### Help & Support Screen Access
1. User navigates to Help & Support from settings
2. Screen displays:
   - Quick action tiles (Live Chat, Email, Call)
   - FAQ section with common questions
3. User can tap any action tile to access that channel

## Error Handling

All communication methods include try-catch blocks with user-friendly error messages via SnackBar:
```dart
try {
  await CommunicationService.sendEmail(...);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Could not open email client: $e')),
  );
}
```

## Dependencies

- **url_launcher: ^6.2.4** - Handles opening external apps and URLs
  - Supported: email, phone, SMS, WhatsApp, browser
  - Platform-specific implementations for Android, iOS, Web, Windows, Linux, macOS

## Adding New Support Channels

To add a new communication channel:

1. Add method to `CommunicationService`:
```dart
static Future<void> newChannel(String param) async {
  try {
    final Uri uri = Uri(scheme: 'scheme', host: 'host', path: 'path');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch');
    }
  } catch (e) {
    rethrow;
  }
}
```

2. Update UI to include new option:
```dart
ListTile(
  leading: const Icon(Icons.icon_rounded),
  title: const Text('Channel Name'),
  subtitle: const Text('Description'),
  onTap: () => _handleNewChannel(context),
),
```

3. Add handler method:
```dart
void _handleNewChannel(BuildContext context) async {
  try {
    await CommunicationService.newChannel(param);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

## Testing

### Manual Testing Checklist
- [ ] Email client opens with correct email and subject
- [ ] Phone dialer opens with correct number
- [ ] WhatsApp opens with message (if installed)
- [ ] Chat navigation works correctly
- [ ] Error messages display when app not available
- [ ] Bottom sheet opens/closes properly
- [ ] All platforms tested (Android, iOS)

### Simulating Missing Apps
To test error handling:
1. Comment out the `if (await canLaunchUrl(uri))` check
2. The exception will be caught and displayed

## Future Enhancements

- [ ] Telegram support
- [ ] Messenger support
- [ ] In-app notification for support responses
- [ ] Support ticket tracking
- [ ] Live chat queue management
- [ ] Callback request feature

## Support Contact Details

These are defined as constants in `CommunicationService`:
- `supportEmail`: support@hodon.app
- `supportPhone`: +961123456789
- `supportPhoneDisplay`: +961 1 234 567

Update these constants if support contact information changes.

