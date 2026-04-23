import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/communication_service.dart';
import '../widgets/shared_widgets.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);

    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Hodon Contact Us - ${_nameCtrl.text.trim()}',
        body:
            'Name: ${_nameCtrl.text.trim()}\n'
            'Email: ${_emailCtrl.text.trim()}\n\n'
            'Message:\n${_messageCtrl.text.trim()}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your message is ready to send in your email app.')),
      );
      _messageCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email app: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HodonCard(
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Icon(Icons.support_agent_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('We are here to help', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Send us a message or use one of the quick contact options below.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text('Quick Contact', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              _ContactTile(
                icon: Icons.email_rounded,
                title: 'Email Support',
                subtitle: CommunicationService.supportEmail,
                onTap: () => CommunicationService.sendEmail(toEmail: CommunicationService.supportEmail),
              ),
              const SizedBox(height: AppSizes.sm),
              _ContactTile(
                icon: Icons.phone_rounded,
                title: 'Call Us',
                subtitle: CommunicationService.supportPhoneDisplay,
                onTap: () => CommunicationService.makePhoneCall(CommunicationService.supportPhone),
              ),
              const SizedBox(height: AppSizes.sm),
              _ContactTile(
                icon: Icons.message_rounded,
                title: 'WhatsApp',
                subtitle: 'Chat with support',
                onTap: () => CommunicationService.openWhatsApp(
                  CommunicationService.supportPhone,
                  message: 'Hi Hodon, I need support with...',
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Text('Send a Message', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Your name',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  final email = v.trim();
                  final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                  return ok ? null : 'Please enter a valid email';
                },
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _messageCtrl,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'How can we help you?',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your message' : null,
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sending ? null : _sendMessage,
                  child: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Send Message'),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return HodonCard(
      onTap: () async {
        try {
          await onTap();
        } catch (e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open contact option: $e')),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: hintColor),
        ],
      ),
    );
  }
}

