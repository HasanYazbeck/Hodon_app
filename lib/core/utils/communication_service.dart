import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for handling various communication channels
class CommunicationService {
  // Support contact details
  static const String supportEmail = 'support@hodon.app';
  static const String supportPhone = '+961123456789'; // Lebanon number format
  static const String supportPhoneDisplay = '+961 1 234 567';

  /// Open email client to send email
  static Future<void> sendEmail({
    required String toEmail,
    String subject = '',
    String body = '',
  }) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: toEmail,
        queryParameters: {
          if (subject.isNotEmpty) 'subject': subject,
          if (body.isNotEmpty) 'body': body,
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Open phone dialer
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Could not launch phone call');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send SMS
  static Future<void> sendSMS(String phoneNumber, {String message = ''}) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Could not launch SMS');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Open WhatsApp chat
  static Future<void> openWhatsApp(String phoneNumber, {String message = ''}) async {
    try {
      // Format: https://wa.me/[country-code][number]?text=[message]
      final String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri whatsappUri = Uri(
        scheme: 'https',
        host: 'wa.me',
        path: cleanPhone,
        queryParameters: {'text': message},
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Open URL in browser
  static Future<void> openUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch URL');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Show communication options dialog
  static void showCommunicationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email_rounded),
                title: const Text('Email'),
                subtitle: const Text('support@hodon.app'),
                onTap: () {
                  Navigator.pop(context);
                  sendEmail(toEmail: supportEmail);
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone_rounded),
                title: const Text('Call'),
                subtitle: const Text(supportPhoneDisplay),
                onTap: () {
                  Navigator.pop(context);
                  makePhoneCall(supportPhone);
                },
              ),
              ListTile(
                leading: const Icon(Icons.message_rounded),
                title: const Text('WhatsApp'),
                subtitle: const Text('Chat with us'),
                onTap: () {
                  Navigator.pop(context);
                  openWhatsApp(supportPhone);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

