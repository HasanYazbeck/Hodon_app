import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/user_role.dart';
import '../../../domain/models/user.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Form fields
  Uint8List? _avatarBytes;
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _dob;
  Gender? _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _bioCtrl.text = user?.bio ?? '';
    _locationCtrl.text = user?.address?.fullAddress ?? '';
    _dob = user?.dateOfBirth;
    _gender = user?.gender;
    _avatarBytes = _decodeAvatarDataUri(user?.avatarUrl);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() => _avatarBytes = bytes);
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    final avatarDataUri = _avatarBytes != null
        ? 'data:image/jpeg;base64,${base64Encode(_avatarBytes!)}'
        : user.avatarUrl;
    final address = _locationCtrl.text.trim().isEmpty
        ? user.address
        : UserAddress(
            id: user.address?.id ?? 'addr_${user.id}',
            label: user.address?.label ?? 'Home',
            fullAddress: _locationCtrl.text.trim(),
            latitude: user.address?.latitude ?? 0,
            longitude: user.address?.longitude ?? 0,
            isDefault: user.address?.isDefault ?? true,
          );

    final ok = await ref.read(authProvider.notifier).updateProfile(
          avatarUrl: avatarDataUri,
          bio: _bioCtrl.text.trim(),
          dateOfBirth: _dob,
          gender: _gender,
          address: address,
          markProfileComplete: true,
        );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile. Please try again.')),
      );
      return;
    }

    if (user.role.isParent) {
      context.go('/parent/home');
    } else {
      context.go('/babysitter/home');
    }
  }

  Uint8List? _decodeAvatarDataUri(String? value) {
    if (value == null || !value.startsWith('data:image')) return null;
    final comma = value.indexOf(',');
    if (comma < 0 || comma == value.length - 1) return null;
    try {
      return base64Decode(value.substring(comma + 1));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _PhotoPage(
                    avatarBytes: _avatarBytes,
                    onPickAvatar: _pickAvatar,
                    onNext: _isSaving ? null : _nextPage,
                  ),
                  _PersonalInfoPage(
                    bioCtrl: _bioCtrl,
                    selectedGender: _gender,
                    selectedDob: _dob,
                    onGenderChanged: (g) => setState(() => _gender = g),
                    onDobChanged: (d) => setState(() => _dob = d),
                    onNext: _isSaving ? null : _nextPage,
                  ),
                  _LocationPage(
                    locationCtrl: _locationCtrl,
                    isSaving: _isSaving,
                    onNext: _isSaving ? null : _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final borderColor = context.appBorder;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.md),
      child: Row(
        children: List.generate(3, (i) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= _currentPage ? AppColors.primary : borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }
}

class _PhotoPage extends StatelessWidget {
  final Uint8List? avatarBytes;
  final VoidCallback onPickAvatar;
  final VoidCallback? onNext;

  const _PhotoPage({this.avatarBytes, required this.onPickAvatar, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.xl),
          Text('Add Your Photo', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.sm),
          Text('Help families recognise you', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor), textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.xxl),
          GestureDetector(
            onTap: onPickAvatar,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: AppSizes.avatarXl,
                  height: AppSizes.avatarXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: avatarBytes != null
                      ? ClipOval(child: Image.memory(avatarBytes!, fit: BoxFit.cover, gaplessPlayback: true))
                      : const Icon(Icons.person_rounded, size: 60, color: AppColors.primary),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(label: avatarBytes != null ? AppStrings.next : 'Skip for Now', onPressed: onNext),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _PersonalInfoPage extends StatelessWidget {
  final TextEditingController bioCtrl;
  final Gender? selectedGender;
  final DateTime? selectedDob;
  final void Function(Gender) onGenderChanged;
  final void Function(DateTime) onDobChanged;
  final VoidCallback? onNext;

  const _PersonalInfoPage({
    required this.bioCtrl,
    this.selectedGender,
    this.selectedDob,
    required this.onGenderChanged,
    required this.onDobChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.xl),
          Text('About You', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.xl),
          AppTextField(
            label: AppStrings.bioLabel,
            hint: AppStrings.bioHint,
            controller: bioCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.md),
          // Date of birth
          _DatePickerField(
            label: 'Date of Birth',
            value: selectedDob,
            onChanged: onDobChanged,
          ),
          const SizedBox(height: AppSizes.md),
          // Gender selection
          Text(AppStrings.genderLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            children: Gender.values.map((g) => ChoiceChip(
              label: Text(g.label),
              selected: selectedGender == g,
              onSelected: (_) => onGenderChanged(g),
              selectedColor: AppColors.primaryContainer,
            )).toList(),
          ),
          const SizedBox(height: AppSizes.xl),
          AppButton(label: AppStrings.next, onPressed: onNext),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _LocationPage extends StatelessWidget {
  final TextEditingController locationCtrl;
  final VoidCallback? onNext;
  final bool isSaving;

  const _LocationPage({required this.locationCtrl, required this.onNext, this.isSaving = false});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.xl),
          Text('Your Location', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.sm),
          Text('Help us show you nearby sitters', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor)),
          const SizedBox(height: AppSizes.xl),
          AppTextField(
            label: AppStrings.locationLabel,
            hint: AppStrings.locationHint,
            controller: locationCtrl,
            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
          ),
          const SizedBox(height: AppSizes.md),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.my_location_rounded),
            label: const Text(AppStrings.useCurrentLocation),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
            ),
          ),
          const Spacer(),
          AppButton(
            label: isSaving ? 'Saving...' : "Let's Go! 🎉",
            onPressed: onNext,
          ),
          const SizedBox(height: AppSizes.xl),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime) onChanged;

  const _DatePickerField({required this.label, this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final surfaceVariantColor = context.appSurfaceVariant;
    final borderColor = context.appBorder;
    final secondaryTextColor = context.appTextSecondary;
    final primaryTextColor = context.appTextPrimary;
    final hintColor = context.appTextHint;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1990, 1, 1),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
        decoration: BoxDecoration(
          color: surfaceVariantColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 20, color: secondaryTextColor),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                value != null
                    ? '${value!.day}/${value!.month}/${value!.year}'
                    : label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value != null ? primaryTextColor : hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

