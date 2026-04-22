# Quick Actions - Code Examples

This document provides copy-paste examples for using the quick actions in your code.

## Using CommunicationService

### Basic Email
```dart
await CommunicationService.sendEmail(
  toEmail: CommunicationService.supportEmail,
  subject: 'Hodon Support Request',
  body: 'Hi, I need help with...',
);
```

### Basic Phone Call
```dart
await CommunicationService.makePhoneCall(CommunicationService.supportPhone);
```

### SMS
```dart
await CommunicationService.sendSMS(
  CommunicationService.supportPhone,
  message: 'Hi Hodon, I need help with...',
);
```

### WhatsApp
```dart
await CommunicationService.openWhatsApp(
  CommunicationService.supportPhone,
  message: 'Hi Hodon Support Team',
);
```

### Open URL
```dart
await CommunicationService.openUrl('https://hodon.app/help');
```

## UI Implementation Examples

### Adding Help FAB to a Screen
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'support_fab',
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuickSupportOptions(context),
        tooltip: 'Quick Support',
        child: const Icon(Icons.help_rounded),
      ),
    );
  }

  void _showQuickSupportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Get Quick Help',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSizes.md),
            ListTile(
              leading: const Icon(Icons.chat_rounded),
              title: const Text('Chat with Support'),
              subtitle: const Text('Live messaging'),
              onTap: () {
                Navigator.pop(context);
                context.go('/parent/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Send Email'),
              subtitle: const Text(CommunicationService.supportEmail),
              onTap: () {
                Navigator.pop(context);
                _sendEmail(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded),
              title: const Text('Call Us'),
              subtitle: const Text(CommunicationService.supportPhoneDisplay),
              onTap: () {
                Navigator.pop(context);
                _callSupport(context);
              },
            ),
            const SizedBox(height: AppSizes.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmail(BuildContext context) async {
    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Hodon Support',
        body: 'Hi Hodon Support,\n\nI need help with...',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _callSupport(BuildContext context) async {
    try {
      await CommunicationService.makePhoneCall(
        CommunicationService.supportPhone,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
```

### Simple Button to Email Support
```dart
ElevatedButton(
  onPressed: () async {
    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Booking Issue',
        body: 'I have a problem with my booking...',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email: $e')),
      );
    }
  },
  child: const Text('Email Support'),
)
```

### Simple Button to Call Support
```dart
ElevatedButton.icon(
  onPressed: () async {
    try {
      await CommunicationService.makePhoneCall(
        CommunicationService.supportPhone,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open phone: $e')),
      );
    }
  },
  icon: const Icon(Icons.phone_rounded),
  label: const Text('Call Support'),
)
```

### Support Tile Widget
```dart
class SupportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SupportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_rounded),
      onTap: onTap,
    );
  }
}

// Usage:
SupportTile(
  title: 'Email Support',
  subtitle: 'support@hodon.app',
  icon: Icons.email_rounded,
  onTap: () async {
    await CommunicationService.sendEmail(
      toEmail: CommunicationService.supportEmail,
    );
  },
)
```

### Context Extension (Optional)
You could add an extension for even simpler usage:

```dart
extension CommunicationExtension on BuildContext {
  Future<void> openEmail() async {
    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> openCall() async {
    try {
      await CommunicationService.makePhoneCall(
        CommunicationService.supportPhone,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> openWhatsApp() async {
    try {
      await CommunicationService.openWhatsApp(
        CommunicationService.supportPhone,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Usage:
ElevatedButton(
  onPressed: () => context.openEmail(),
  child: const Text('Email'),
)
```

## Dialog Example with Loading
```dart
Future<void> _callWithLoading(BuildContext context) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Contacting Support'),
      content: const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );

  try {
    await CommunicationService.makePhoneCall(
      CommunicationService.supportPhone,
    );
    if (context.mounted) Navigator.pop(context);
  } catch (e) {
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

## Constants Available

```dart
class CommunicationService {
  static const String supportEmail = 'support@hodon.app';
  static const String supportPhone = '+961123456789';
  static const String supportPhoneDisplay = '+961 1 234 567';
  
  // ... methods ...
}
```

## Handling Specific Errors

```dart
Future<void> _handleCommunication(BuildContext context, String channel) async {
  try {
    switch (channel) {
      case 'email':
        await CommunicationService.sendEmail(
          toEmail: CommunicationService.supportEmail,
        );
        break;
      case 'phone':
        await CommunicationService.makePhoneCall(
          CommunicationService.supportPhone,
        );
        break;
      case 'whatsapp':
        await CommunicationService.openWhatsApp(
          CommunicationService.supportPhone,
        );
        break;
    }
  } on PlatformException catch (e) {
    _showErrorDialog(context, 'Platform Error: ${e.message}');
  } catch (e) {
    _showErrorDialog(context, 'Error: $e');
  }
}

void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

## Testing Communication

```dart
// In your test file
testWidgets('Support email opens', (WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  
  // Mock url_launcher
  setUrlLauncherMock();
  
  // Find and tap support button
  await tester.tap(find.byIcon(Icons.help_rounded));
  await tester.pumpAndSettle();
  
  // Verify communication service was called
  expect(find.text('Send Email'), findsOneWidget);
});
```

## Import Statements

Always include these imports:
```dart
import 'package:go_router/go_router.dart';
import '../../../core/utils/communication_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
```

## Best Practices

1. **Always use try-catch** when calling communication methods
2. **Check context.mounted** before showing dialogs/snackbars
3. **Use consistent error messaging** across the app
4. **Test on real devices** - simulators may not have all apps
5. **Provide fallbacks** if preferred app isn't available
6. **Keep support details centralized** in CommunicationService
7. **Use appropriate icons** for each communication method
8. **Provide loading feedback** for async operations

