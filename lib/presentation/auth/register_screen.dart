import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/enums/user_role.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role (Parent or Baby Sitter)'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          role: _selectedRole!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = state is AuthLoading;
    final secondaryTextColor = context.appTextSecondary;

    ref.listen(authProvider, (_, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: AppColors.error),
        );
        ref.read(authProvider.notifier).clearError();
      } else if (next is AuthOtpRequired) {
        context.go('/otp?email=${Uri.encodeComponent(next.email)}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.createAccount, style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: AppSizes.xs),
                Text(
                  AppStrings.registerSubtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(height: AppSizes.xl),
                AppTextField(
                  label: AppStrings.fullNameLabel,
                  hint: AppStrings.fullNameHint,
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  validator: (v) => AppValidators.required(v, fieldName: 'Full name'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailHint,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppSizes.md),
                Text('Account Type', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: AppSizes.sm),
                _buildRoleSelector(),
                const SizedBox(height: AppSizes.md),
                PasswordField(
                  controller: _passwordCtrl,
                  validator: AppValidators.password,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.md),
                PasswordField(
                  label: AppStrings.confirmPasswordLabel,
                  controller: _confirmCtrl,
                  validator: (v) => AppValidators.confirmPassword(v, _passwordCtrl.text),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSizes.xl),
                AppButton(
                  label: AppStrings.registerButton,
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSizes.md),
                Center(
                  child: Text(
                    'By creating an account you agree to our\nTerms of Service and Privacy Policy.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text(AppStrings.signIn),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final secondaryTextColor = context.appTextSecondary;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = UserRole.parent),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.parent
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusMd - 1),
                    bottomLeft: Radius.circular(AppSizes.radiusMd - 1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      color: _selectedRole == UserRole.parent
                          ? AppColors.primary
                          : secondaryTextColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Parent',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _selectedRole == UserRole.parent
                                ? AppColors.primary
                                : secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, color: AppColors.border),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = UserRole.babysitter),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: _selectedRole == UserRole.babysitter
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppSizes.radiusMd - 1),
                    bottomRight: Radius.circular(AppSizes.radiusMd - 1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_rounded,
                      color: _selectedRole == UserRole.babysitter
                          ? AppColors.primary
                          : secondaryTextColor,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Baby Sitter',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _selectedRole == UserRole.babysitter
                                ? AppColors.primary
                                : secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

