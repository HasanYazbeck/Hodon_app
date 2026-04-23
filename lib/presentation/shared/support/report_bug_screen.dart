import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/communication_service.dart';
import '../widgets/shared_widgets.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _expectedCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _stepsCtrl.dispose();
    _expectedCtrl.dispose();
    _actualCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await CommunicationService.sendEmail(
        toEmail: CommunicationService.supportEmail,
        subject: 'Bug Report: ${_titleCtrl.text.trim()}',
        body:
            'Bug Title:\n${_titleCtrl.text.trim()}\n\n'
            'Steps to Reproduce:\n${_stepsCtrl.text.trim()}\n\n'
            'Expected Result:\n${_expectedCtrl.text.trim()}\n\n'
            'Actual Result:\n${_actualCtrl.text.trim()}\n\n'
            '---\n'
            'Sent from Hodon mobile app',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanks! Your report is ready to send in your email app.')),
      );
      _titleCtrl.clear();
      _stepsCtrl.clear();
      _expectedCtrl.clear();
      _actualCtrl.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email app: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('Report a Bug')),
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
                      child: const Icon(Icons.bug_report_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Help us improve', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(
                            'Share what happened and we will investigate it quickly.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextFormField(
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Bug title',
                  hintText: 'Short summary',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a bug title' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _stepsCtrl,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Steps to reproduce',
                  hintText: '1) ... 2) ... 3) ...',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please add reproduction steps' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _expectedCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Expected result',
                  hintText: 'What should happen?',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please add expected result' : null,
              ),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _actualCtrl,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Actual result',
                  hintText: 'What happened instead?',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please add actual result' : null,
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                        )
                      : const Text('Submit Bug Report'),
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

