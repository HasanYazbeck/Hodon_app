import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';

class FirstAidCertificateScreen extends ConsumerStatefulWidget {
  const FirstAidCertificateScreen({super.key});

  @override
  ConsumerState<FirstAidCertificateScreen> createState() => _FirstAidCertificateScreenState();
}

class _FirstAidCertificateScreenState extends ConsumerState<FirstAidCertificateScreen> {
  VerificationStatus _status = VerificationStatus.notSubmitted;
  bool _isSubmitting = false;
  PlatformFile? _certificate;

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    setState(() => _certificate = result.files.first);
  }

  bool _isImage(PlatformFile file) {
    final ext = (file.extension ?? '').toLowerCase();
    return ext == 'png' || ext == 'jpg' || ext == 'jpeg';
  }

  Future<void> _submitCertification() async {
    if (_certificate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your First Aid certificate first.')),
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
        content: Text('First Aid certificate submitted successfully.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnderReview = _status == VerificationStatus.underReview;
    final isApproved = _status == VerificationStatus.approved;
    final secondaryTextColor = context.appTextSecondary;
    final surfaceColor = context.appSurface;
    final surfaceVariantColor = context.appSurfaceVariant;
    final borderColor = context.appBorder;

    return Scaffold(
      appBar: AppBar(title: const Text('First Aid Certificate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text('Upload First Aid Certificate', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Submit a valid first aid certificate to strengthen your trust profile.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
            ),
            const SizedBox(height: AppSizes.xl),
            if (isApproved || isUnderReview)
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: (isApproved ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: (isApproved ? AppColors.success : AppColors.warning).withValues(alpha: 0.3),
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
                            ? 'First Aid certificate approved.'
                            : 'First Aid certificate is under review.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Certificate Attachment', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Accepted formats: PDF, JPG, PNG',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: secondaryTextColor,
                        ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (_certificate == null)
                    OutlinedButton.icon(
                      onPressed: isUnderReview || isApproved || _isSubmitting ? null : _pickCertificate,
                      icon: const Icon(Icons.upload_file_rounded),
                      label: const Text('Upload Certificate'),
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
                        color: surfaceVariantColor,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isImage(_certificate!) ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              _certificate!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: isUnderReview || isApproved || _isSubmitting ? null : _pickCertificate,
                            child: const Text('Change'),
                          ),
                          IconButton(
                            onPressed: isUnderReview || isApproved || _isSubmitting
                                ? null
                                : () => setState(() => _certificate = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),
            if (!isUnderReview && !isApproved)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitCertification,
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
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit First Aid Certificate'),
              ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

