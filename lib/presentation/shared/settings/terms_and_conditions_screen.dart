import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/legal/terms_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../widgets/app_button.dart';
import '../widgets/shared_widgets.dart';

class TermsAndConditionsScreen extends ConsumerStatefulWidget {
  final bool requireAcceptance;
  const TermsAndConditionsScreen({
    super.key,
    this.requireAcceptance = false,
  });

  @override
  ConsumerState<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState
    extends ConsumerState<TermsAndConditionsScreen> {
  bool _accepted = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final acceptanceState = ref.watch(parentTermsAcceptanceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hodon Parent Booking Terms',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Please review these terms before placing your first booking.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const _TermCard(
                    title: '1. Booking Commitment',
                    body:
                        'When a babysitter accepts your booking, that time slot is reserved and unavailable to other families.',
                  ),
                  const _TermCard(
                    title: '2. Cancellation After Acceptance',
                    body:
                        'If you cancel after the sitter accepts, the platform fee listed in your payment summary is deducted from the initial payment.',
                  ),
                  const _TermCard(
                    title: '3. Safety and Communication',
                    body:
                        'Use in-app messaging for coordination and emergency updates. Keep your child profile and contact details accurate.',
                  ),
                  const _TermCard(
                    title: '4. Service Expectations',
                    body:
                        'Provide clear instructions and a safe environment. Repeated misuse may limit booking access.',
                  ),
                  const SizedBox(height: AppSizes.md),
                  acceptanceState.when(
                    data: (accepted) => accepted
                        ? const StatusChip(
                            label: 'You have already accepted these terms',
                            color: AppColors.success,
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          if (widget.requireAcceptance)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.pageHorizontal,
                  AppSizes.sm,
                  AppSizes.pageHorizontal,
                  AppSizes.pageHorizontal,
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _accepted,
                      onChanged: (value) =>
                          setState(() => _accepted = value ?? false),
                      title: const Text('I agree to the Terms & Conditions'),
                    ),
                    AppButton(
                      label: 'Accept & Continue',
                      isLoading: _saving,
                      onPressed: _accepted ? _acceptAndContinue : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _acceptAndContinue() async {
    setState(() => _saving = true);
    try {
      await ref.read(parentTermsAcceptanceProvider.notifier).accept();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _TermCard extends StatelessWidget {
  final String title;
  final String body;

  const _TermCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: HodonCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(body, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
