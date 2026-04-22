import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/communication_service.dart';
import '../widgets/shared_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
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
                        Text('Need help?', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 2),
                        Text(
                          'Find quick answers or contact our support team.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            _ActionTile(
              icon: Icons.chat_bubble_rounded,
              title: 'Live Chat',
              subtitle: 'Start a conversation with support',
              onTap: () => context.go('/chat'),
            ),
            const SizedBox(height: AppSizes.sm),
            _ActionTile(
              icon: Icons.email_rounded,
              title: 'Email Support',
              subtitle: CommunicationService.supportEmail,
              onTap: () => _handleEmailTap(context),
            ),
            const SizedBox(height: AppSizes.sm),
            _ActionTile(
              icon: Icons.phone_rounded,
              title: 'Call Us',
              subtitle: CommunicationService.supportPhoneDisplay,
              onTap: () => _handleCallTap(context),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Frequently Asked Questions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            ..._faqItems.map(
              (faq) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: HodonCard(
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: AppSizes.sm),
                    title: Text(faq.question, style: Theme.of(context).textTheme.titleSmall),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                        child: Text(
                          faq.answer,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }


  void _handleEmailTap(BuildContext context) async {
    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Hodon Support Request',
        body: 'Hi Hodon Support,\n\nI need help with...\n\nThank you!',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email client: $e')),
        );
      }
    }
  }

  void _handleCallTap(BuildContext context) async {
    try {
      await CommunicationService.makePhoneCall(CommunicationService.supportPhone);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open phone dialer: $e')),
        );
      }
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HodonCard(
      onTap: onTap,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

const List<_FaqItem> _faqItems = [
  _FaqItem(
    question: 'How do I cancel a booking?',
    answer:
        'Open Bookings, select the booking, and tap Cancel. Cancellation availability depends on booking status and policy.',
  ),
  _FaqItem(
    question: 'How are payments calculated?',
    answer:
        'Total cost includes hourly rate, platform fee, and any emergency fee when applicable.',
  ),
  _FaqItem(
    question: 'How do I update my verification documents?',
    answer:
        'Go to Verification Center in your profile and re-upload the required document type.',
  ),
];

