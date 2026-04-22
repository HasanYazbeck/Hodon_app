import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';

class IdVerificationScreen extends ConsumerStatefulWidget {
  const IdVerificationScreen({super.key});

  @override
  ConsumerState<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends ConsumerState<IdVerificationScreen> {
  Uint8List? _idPhotoBytes;
  VerificationStatus _status = VerificationStatus.notSubmitted;
  bool _isSubmitting = false;

  Future<void> _pickIdPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _idPhotoBytes = bytes);
  }

  Future<void> _submitVerification() async {
    if (_idPhotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an ID photo first.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _status = VerificationStatus.underReview;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID submitted for verification. We\'ll review it shortly.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _status == VerificationStatus.approved;
    final isUnderReview = _status == VerificationStatus.underReview;
    final secondaryTextColor = context.appTextSecondary;

    return Scaffold(
      appBar: AppBar(title: const Text('ID Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text(
              'Verify Your Identity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Upload a clear photo of your government-issued ID (passport, driver\'s license, or national ID).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: secondaryTextColor,
                  ),
            ),
            const SizedBox(height: AppSizes.xl),
            // Status banner
            if (isApproved) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID Verified',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your identity has been verified.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ] else if (isUnderReview) ...[
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded, color: AppColors.warning),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Under Review',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your ID is being reviewed. This usually takes 24-48 hours.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.warning,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
            // ID Photo upload area
            GestureDetector(
              onTap: _isSubmitting ? null : _pickIdPhoto,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: _idPhotoBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg - 2),
                        child: Image.memory(
                          _idPhotoBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              Icons.badge_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Upload ID Photo',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select a photo',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: secondaryTextColor,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            // Requirements section
            Text(
              'Requirements',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            _RequirementItem(
              icon: Icons.check_rounded,
              text: 'Document must be valid and not expired',
            ),
            const SizedBox(height: AppSizes.sm),
            _RequirementItem(
              icon: Icons.check_rounded,
              text: 'All text must be clearly readable',
            ),
            const SizedBox(height: AppSizes.sm),
            _RequirementItem(
              icon: Icons.check_rounded,
              text: 'Photo must show the full document',
            ),
            const SizedBox(height: AppSizes.sm),
            _RequirementItem(
              icon: Icons.check_rounded,
              text: 'No glare or reflection on the document',
            ),
            const SizedBox(height: AppSizes.xxl),
            // Submit button
            if (!isApproved && !isUnderReview)
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerification,
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
                    : const Text('Submit for Verification'),
              ),
            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RequirementItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.success),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

