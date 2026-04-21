import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/providers.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../shared/widgets/app_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _pinCtrl = TextEditingController();
  int _secondsLeft = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isVerifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { _secondsLeft = 60; _canResend = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_pinCtrl.text.length != 6) {
      setState(() => _error = AppStrings.otpInvalid);
      return;
    }
    setState(() { _isVerifying = true; _error = null; });
    final ok = await ref.read(authProvider.notifier).verifyOtp(
      email: widget.email,
      otp: _pinCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/role-selection');
    } else {
      setState(() { _isVerifying = false; _error = 'Invalid or expired code. Please try again.'; });
    }
  }

  Future<void> _resend() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.resendOtp(email: widget.email);
    _startTimer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new code has been sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: AppSizes.otpFieldSize,
      height: AppSizes.otpFieldSize,
      textStyle: Theme.of(context).textTheme.headlineMedium,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
    );

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSizes.xl),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('✉️', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(AppStrings.verifyEmail, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: AppSizes.sm),
              Text(
                '${AppStrings.otpSubtitle}\n${widget.email}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl),
              Pinput(
                controller: _pinCtrl,
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                errorPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: AppColors.error),
                ),
                onCompleted: (_) => _verify(),
                errorText: _error,
              ),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                label: AppStrings.verifyButton,
                onPressed: _verify,
                isLoading: _isVerifying,
              ),
              const SizedBox(height: AppSizes.lg),
              if (_canResend)
                TextButton(
                  onPressed: _resend,
                  child: const Text(AppStrings.resendCode),
                )
              else
                Text(
                  '${AppStrings.resendIn}${_secondsLeft}s',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

