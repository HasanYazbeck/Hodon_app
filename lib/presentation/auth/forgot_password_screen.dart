import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authProvider.notifier).forgotPassword(_emailCtrl.text.trim());
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = state is AuthLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.pageHorizontal),
          child: _sent ? _buildSuccess(context) : _buildForm(context, isLoading),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading) => Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.xl),
            Text('Forgot\nPassword?', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Enter your email and we\'ll send you a reset link.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSizes.xl),
            AppTextField(
              label: AppStrings.emailLabel,
              hint: AppStrings.emailHint,
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.email,
            ),
            const SizedBox(height: AppSizes.lg),
            AppButton(label: 'Send Reset Link', onPressed: _submit, isLoading: isLoading),
          ],
        ),
      );

  Widget _buildSuccess(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📧', style: TextStyle(fontSize: 72)),
          const SizedBox(height: AppSizes.lg),
          Text('Check Your Email', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: AppSizes.sm),
          Text(
            'We\'ve sent a password reset link to\n${_emailCtrl.text}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          AppButton(label: 'Back to Login', onPressed: () => context.go('/login')),
        ],
      );
}

