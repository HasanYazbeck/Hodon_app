import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/payment/payment_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/saved_payment_method.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/shared_widgets.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.watch(paymentMethodsProvider);
    final backgroundColor = context.appBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Payment Methods'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded),
            onPressed: () => _openAddCardSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paymentMethodsProvider.notifier).load(),
        child: methodsAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.pageHorizontal),
            children: const [
              ShimmerCard(height: 88),
              SizedBox(height: AppSizes.sm),
              ShimmerCard(height: 88),
              SizedBox(height: AppSizes.sm),
              ShimmerCard(height: 88),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.7,
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load payment methods',
                  subtitle: error.toString().replaceAll('Exception: ', ''),
                  action: ElevatedButton(
                    onPressed: () => ref.read(paymentMethodsProvider.notifier).load(),
                    child: const Text('Try Again'),
                  ),
                ),
              ),
            ],
          ),
          data: (methods) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.pageHorizontal),
            children: [
              _SecurityInfoCard(onAddCard: () => _openAddCardSheet(context)),
              const SizedBox(height: AppSizes.lg),
              SectionHeader(
                title: 'Saved methods',
                actionLabel: 'Add card',
                onAction: () => _openAddCardSheet(context),
              ),
              const SizedBox(height: AppSizes.sm),
              if (methods.isEmpty)
                EmptyState(
                  icon: Icons.payment_rounded,
                  title: 'No payment methods yet',
                  subtitle: 'Add a card to speed up future bookings.',
                  action: ElevatedButton(
                    onPressed: () => _openAddCardSheet(context),
                    child: const Text('Add Card'),
                  ),
                )
              else
                ...methods.map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: _PaymentMethodCard(
                      method: method,
                      onSetDefault: method.isDefault
                          ? null
                          : () => _setDefault(context, ref, method),
                      onDelete: method.canDelete
                          ? () => _confirmDelete(context, ref, method)
                          : null,
                    ),
                  ),
                ),
              const SizedBox(height: AppSizes.md),
              Text(
                'Your selected default method will be preselected during booking checkout.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appTextSecondary,
                    ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pageHorizontal,
            AppSizes.sm,
            AppSizes.pageHorizontal,
            AppSizes.pageHorizontal,
          ),
          child: AppButton(
            label: 'Add New Card',
            leadingIcon: const Icon(Icons.add_card_rounded),
            onPressed: () => _openAddCardSheet(context),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddCardSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXl)),
      ),
      builder: (sheetContext) => const _AddCardSheet(),
    );
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    SavedPaymentMethod method,
  ) async {
    final success = await ref.read(paymentMethodsProvider.notifier).setDefault(method.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${method.displayTitle} is now your default payment method.'
                : 'Could not update default payment method.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SavedPaymentMethod method,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Card'),
        content: Text('Remove ${method.displayTitle} from your saved payment methods?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final success = await ref.read(paymentMethodsProvider.notifier).delete(method.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '${method.displayTitle} removed successfully.'
                : 'Could not remove payment method.',
          ),
        ),
      );
    }
  }
}

class _SecurityInfoCard extends StatelessWidget {
  final VoidCallback onAddCard;

  const _SecurityInfoCard({required this.onAddCard});

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return HodonCard(
      color: AppColors.primaryContainer,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const Icon(Icons.lock_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fast and secure checkout', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Save your preferred method so bookings can be confirmed faster. Mock payment data is stored locally for demo purposes.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAddCard,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final SavedPaymentMethod method;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const _PaymentMethodCard({
    required this.method,
    this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return HodonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _accentColor(method.type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Icon(_iconFor(method.type), color: _accentColor(method.type)),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.displayTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      method.displaySubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
              if (method.isDefault)
                const StatusChip(label: 'Default', color: AppColors.primary)
              else
                StatusChip(label: method.type.label, color: hintColor),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              if (!method.isDefault)
                TextButton.icon(
                  onPressed: onSetDefault,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                  label: const Text('Set as default'),
                )
              else
                Text(
                  'Used automatically for new bookings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondaryTextColor),
                ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.error,
                  tooltip: 'Remove card',
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconFor(PaymentMethod type) => switch (type) {
        PaymentMethod.card => Icons.credit_card_rounded,
        PaymentMethod.cash => Icons.payments_rounded,
        PaymentMethod.wallet => Icons.account_balance_wallet_rounded,
      };

  Color _accentColor(PaymentMethod type) => switch (type) {
        PaymentMethod.card => AppColors.primary,
        PaymentMethod.cash => AppColors.success,
        PaymentMethod.wallet => AppColors.secondary,
      };
}

class _AddCardSheet extends ConsumerStatefulWidget {
  const _AddCardSheet();

  @override
  ConsumerState<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<_AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _expiryMonthCtrl = TextEditingController();
  final _expiryYearCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _cardholderCtrl.dispose();
    _cardNumberCtrl.dispose();
    _expiryMonthCtrl.dispose();
    _expiryYearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.pageHorizontal,
        AppSizes.lg,
        AppSizes.pageHorizontal,
        viewInsets.bottom + AppSizes.pageHorizontal,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appBorder,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              Text('Add New Card', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSizes.xs),
              Text(
                'Store a mock card for faster parent checkout flows.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.appTextSecondary),
              ),
              const SizedBox(height: AppSizes.lg),
              AppTextField(
                label: 'Cardholder Name',
                hint: 'Sara Khalil',
                controller: _cardholderCtrl,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Cardholder name is required'
                    : null,
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                label: 'Card Number',
                hint: '4242 4242 4242 4242',
                controller: _cardNumberCtrl,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                  if (digits.length < 12) return 'Enter a valid card number';
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Expiry Month',
                      hint: '08',
                      controller: _expiryMonthCtrl,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final month = int.tryParse(value ?? '');
                        if (month == null || month < 1 || month > 12) {
                          return '1-12';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Expiry Year',
                      hint: '2028',
                      controller: _expiryYearCtrl,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final year = int.tryParse(value ?? '');
                        if (year == null || year < DateTime.now().year) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Save Card',
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final success = await ref.read(paymentMethodsProvider.notifier).addCard(
          cardholderName: _cardholderCtrl.text.trim(),
          cardNumber: _cardNumberCtrl.text.trim(),
          expiryMonth: int.parse(_expiryMonthCtrl.text.trim()),
          expiryYear: int.parse(_expiryYearCtrl.text.trim()),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card added successfully.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not save card. Please try again.')),
    );
  }
}

