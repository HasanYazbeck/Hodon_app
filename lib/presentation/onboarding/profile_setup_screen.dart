import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/enums/user_role.dart';
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
  String? _avatarPath;
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  DateTime? _dob;
  Gender? _gender;

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
    if (image != null) setState(() => _avatarPath = image.path);
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

  void _finish() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (user.role.isParent) {
      context.go('/parent/home');
    } else {
      context.go('/babysitter/home');
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
                    avatarPath: _avatarPath,
                    onPickAvatar: _pickAvatar,
                    onNext: _nextPage,
                  ),
                  _PersonalInfoPage(
                    bioCtrl: _bioCtrl,
                    selectedGender: _gender,
                    selectedDob: _dob,
                    onGenderChanged: (g) => setState(() => _gender = g),
                    onDobChanged: (d) => setState(() => _dob = d),
                    onNext: _nextPage,
                  ),
                  _LocationPage(
                    locationCtrl: _locationCtrl,
                    onNext: _nextPage,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal, vertical: AppSizes.md),
      child: Row(
        children: List.generate(3, (i) => Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              color: i <= _currentPage ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        )),
      ),
    );
  }
}

class _PhotoPage extends StatelessWidget {
  final String? avatarPath;
  final VoidCallback onPickAvatar;
  final VoidCallback onNext;

  const _PhotoPage({this.avatarPath, required this.onPickAvatar, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSizes.xl),
          Text('Add Your Photo', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: AppSizes.sm),
          Text('Help families recognise you', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
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
                  child: avatarPath != null
                      ? ClipOval(child: Image.network(avatarPath!, fit: BoxFit.cover))
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
          AppButton(label: avatarPath != null ? AppStrings.next : 'Skip for Now', onPressed: onNext),
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
  final VoidCallback onNext;

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
  final VoidCallback onNext;

  const _LocationPage({required this.locationCtrl, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.xl),
          Text('Your Location', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.sm),
          Text('Help us show you nearby sitters', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
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
          AppButton(label: "Let's Go! 🎉", onPressed: onNext),
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
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                value != null
                    ? '${value!.day}/${value!.month}/${value!.year}'
                    : label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value != null ? AppColors.textPrimary : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

