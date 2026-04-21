import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';

class BackgroundCheckScreen extends ConsumerStatefulWidget {
  const BackgroundCheckScreen({super.key});

  @override
  ConsumerState<BackgroundCheckScreen> createState() => _BackgroundCheckScreenState();
}

class _BackgroundCheckScreenState extends ConsumerState<BackgroundCheckScreen> {
  VerificationStatus _status = VerificationStatus.notSubmitted;
  bool _isSubmitting = false;
  bool _consentGiven = false;
  PlatformFile? _attachment;

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    final file = (result == null || result.files.isEmpty) ? null : result.files.first;
    if (file == null || !mounted) return;
    setState(() => _attachment = file);
  }

  bool _isImage(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg';
  }

  Future<void> _submitBackgroundCheck() async {
    if (_attachment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a background check document (PDF or image).')),
      );
      return;
    }

    if (!_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide consent to continue.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _status = VerificationStatus.underReview;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Background check request submitted successfully.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnderReview = _status == VerificationStatus.underReview;
    final isApproved = _status == VerificationStatus.approved;

    return Scaffold(
      appBar: AppBar(title: const Text('Background Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text('Safety First', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            Text(
              'A background check helps families feel confident and increases your profile trust level.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            if (isApproved || isUnderReview)
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: (isApproved ? AppColors.success : AppColors.warning)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: (isApproved ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isApproved ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      color: isApproved ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        isApproved
                            ? 'Background check approved.'
                            : 'Background check is under review. This may take 2-5 business days.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            Text('What We Check', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSizes.sm),
            const _Bullet(text: 'Identity match with your submitted documents'),
            const _Bullet(text: 'Public criminal record checks where available'),
            const _Bullet(text: 'Sanctions and watchlist checks'),
            const _Bullet(text: 'Duplicate account and fraud prevention signals'),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attachment', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Upload one document as PDF or image (JPG/PNG).',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (_attachment == null)
                    OutlinedButton.icon(
                      onPressed: isUnderReview || isApproved || _isSubmitting
                          ? null
                          : _pickAttachment,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload Document'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isImage(_attachment!)
                                ? Icons.image_rounded
                                : Icons.picture_as_pdf_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              _attachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: isUnderReview || isApproved || _isSubmitting
                                ? null
                                : _pickAttachment,
                            child: const Text('Change'),
                          ),
                          IconButton(
                            onPressed: isUnderReview || isApproved || _isSubmitting
                                ? null
                                : () => setState(() => _attachment = null),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Remove file',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consent', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSizes.sm),
                  CheckboxListTile(
                    value: _consentGiven,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: isUnderReview || isApproved || _isSubmitting
                        ? null
                        : (v) => setState(() => _consentGiven = v ?? false),
                    title: const Text(
                      'I authorize Hodon to run a background check for trust and safety purposes.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            if (!isUnderReview && !isApproved)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBackgroundCheck,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit Background Check'),
              ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 8, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

