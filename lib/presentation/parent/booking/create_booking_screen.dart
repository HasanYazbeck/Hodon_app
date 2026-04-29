import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/booking/booking_provider.dart';
import '../../../application/legal/terms_provider.dart';
import '../../../application/sitter/sitter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/babysitter_profile.dart';
import '../../../domain/models/booking.dart' as booking_model;
import '../../../domain/models/user.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_text_field.dart';

class CreateBookingScreen extends ConsumerWidget {
  final String sitterId;
  const CreateBookingScreen({super.key, required this.sitterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitterAsync = ref.watch(sitterDetailProvider(sitterId));
    return sitterAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (sitter) => _BookingForm(sitter: sitter),
    );
  }
}

class _BookingForm extends ConsumerStatefulWidget {
  final SitterCard sitter;

  const _BookingForm({required this.sitter});

  @override
  ConsumerState<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<_BookingForm> {
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createBookingProvider(widget.sitter.user.id));
    final secondaryTextColor = context.appTextSecondary;
    final supportedServices = widget.sitter.profile.services;
    final supportedCareLocations = widget.sitter.profile.supportedCareLocations;

    if (supportedServices.isNotEmpty &&
        !supportedServices.contains(formState.serviceType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(createBookingProvider(widget.sitter.user.id).notifier)
            .setServiceType(supportedServices.first);
      });
    }
    if (supportedCareLocations.isNotEmpty &&
        !supportedCareLocations.contains(formState.careLocationType)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(createBookingProvider(widget.sitter.user.id).notifier)
            .setCareLocationType(supportedCareLocations.first);
      });
    }

    final selectedRate =
        widget.sitter.profile.rateForService(formState.serviceType);
    final previewPricing = _calculatePricing(formState);
    final previewDistanceKm = _estimateDistanceKm(formState.location);
    final isOutsideCoverage = formState.location != null &&
        formState.careLocationType.requiresTransportFee &&
        widget.sitter.profile.coverageRadiusKm != null &&
        previewDistanceKm > widget.sitter.profile.coverageRadiusKm!;

    ref.listen(createBookingProvider(widget.sitter.user.id), (_, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.error!), backgroundColor: AppColors.error),
        );
      }
      if (next.result != null) {
        context.push('/parent/booking/${next.result!.id}');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookingDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _handleBack(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pageHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sitter summary
            HodonCard(
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: AppColors.primary),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                      child: Text(widget.sitter.user.fullName,
                          style: Theme.of(context).textTheme.titleMedium)),
                  Text('\$${selectedRate.toStringAsFixed(0)}/hr',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Booking type
            _SectionLabel('Booking Type'),
            Row(
              children: BookingType.values
                  .map((t) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TypeChip(
                            label: t.label,
                            isSelected: formState.bookingType == t,
                            isEmergency: t == BookingType.emergency,
                            onTap: () => ref
                                .read(createBookingProvider(widget.sitter.user.id)
                                    .notifier)
                                .setBookingType(t),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            // Service type
            _SectionLabel('Service Type'),
            DropdownButtonFormField<ServiceType>(
              initialValue: formState.serviceType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
              ),
              items: supportedServices
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  ref
                      .read(createBookingProvider(widget.sitter.user.id).notifier)
                      .setServiceType(v);
                }
              },
            ),
            const SizedBox(height: AppSizes.lg),

            _SectionLabel('Care Arrangement'),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: supportedCareLocations
                  .map(
                    (locationType) => ChoiceChip(
                      label: Text(locationType.label),
                      selected: formState.careLocationType == locationType,
                      onSelected: (_) => ref
                          .read(
                            createBookingProvider(widget.sitter.user.id)
                                .notifier,
                          )
                          .setCareLocationType(locationType),
                      selectedColor: AppColors.primaryContainer,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              formState.careLocationType.description,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: secondaryTextColor),
            ),
            if (formState.careLocationType.requiresTransportFee) ...[
              const SizedBox(height: AppSizes.xs),
              Text(
                'Transport is charged at '
                '\$${widget.sitter.profile.transportFeePerKm.toStringAsFixed(2)}/km'
                '${widget.sitter.profile.coverageRadiusKm != null ? ' up to ${widget.sitter.profile.coverageRadiusKm!.toStringAsFixed(0)} km.' : '.'}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
            const SizedBox(height: AppSizes.lg),

            // Date & time
            _SectionLabel('Date & Time'),
            Row(
              children: [
                Expanded(
                  child: _DateTimePickerButton(
                    label: formState.startDatetime != null
                        ? _fmt(formState.startDatetime!)
                        : 'Start Time',
                    icon: Icons.schedule_rounded,
                    onTap: () => _pickStartDateTime(context),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: _DateTimePickerButton(
                    label: formState.endDatetime != null
                        ? _fmt(formState.endDatetime!)
                        : 'End Time',
                    icon: Icons.schedule_rounded,
                    onTap: () => _pickEndDateTime(context),
                  ),
                ),
              ],
            ),

            if (previewPricing != null) ...[
              const SizedBox(height: AppSizes.sm),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Text(
                  '${previewPricing.durationHours.toStringAsFixed(1)} hours at \$${selectedRate.toStringAsFixed(0)}/hr'
                  '${previewPricing.transportFee > 0 ? ' + transport' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ),
            ],
            const SizedBox(height: AppSizes.lg),

            // Location
            _SectionLabel('Parent Location'),
            _LocationPickerButton(
              address: formState.location?.fullAddress,
              onTap: () {
                ref
                    .read(createBookingProvider(widget.sitter.user.id).notifier)
                    .setLocation(
                      const UserAddress(
                        id: 'addr_1',
                        label: 'Home',
                        fullAddress: 'Achrafieh, Beirut, Lebanon',
                        latitude: 33.8869,
                        longitude: 35.5131,
                        isDefault: true,
                      ),
                    );
              },
            ),
            const SizedBox(height: AppSizes.lg),

            // Payment
            _SectionLabel('Payment Method'),
            Wrap(
              spacing: AppSizes.sm,
              children: PaymentMethod.values
                  .map((m) => ChoiceChip(
                        label: Text(m.label),
                        selected: formState.paymentMethod == m,
                        onSelected: (_) => ref
                            .read(
                                createBookingProvider(widget.sitter.user.id)
                                    .notifier)
                            .setPaymentMethod(m),
                        selectedColor: AppColors.primaryContainer,
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSizes.lg),

            if (formState.location != null) ...[
              HodonCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transport Overview',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      formState.careLocationType.requiresTransportFee
                          ? 'Estimated distance between parent and sitter: ${previewDistanceKm.toStringAsFixed(1)} km'
                          : 'No transport fee is added when care happens at the sitter home.',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: secondaryTextColor),
                    ),
                    if (isOutsideCoverage) ...[
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        'This address is outside the sitter travel radius.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],

            // Trust Circle toggle
            HodonCard(
              child: Row(
                children: [
                  const Icon(Icons.people_rounded,
                      color: AppColors.badgeTrustCircle),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trust Circle First',
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          'Notify your trusted network before others',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: formState.useTrustCircle,
                    onChanged: (v) => ref
                        .read(createBookingProvider(widget.sitter.user.id).notifier)
                        .setUseTrustCircle(v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // Notes
            AppTextField(
              label: AppStrings.bookingNotes,
              hint: AppStrings.bookingNotesHint,
              controller: _notesCtrl,
              maxLines: 3,
              onChanged: (v) => ref
                  .read(createBookingProvider(widget.sitter.user.id).notifier)
                  .setNotes(v),
            ),
            const SizedBox(height: AppSizes.xl),

            // Price summary
            if (previewPricing != null)
              _buildPriceSummary(context, previewPricing),
            const SizedBox(height: AppSizes.lg),

            AppButton(
              label: AppStrings.confirmBooking,
              isLoading: formState.isSubmitting,
              onPressed:
                  isOutsideCoverage ? null : () => _onConfirmBookingPressed(context),
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/parent/search');
  }

  booking_model.BookingPricing? _calculatePricing(
      CreateBookingFormState formState) {
    if (formState.startDatetime == null || formState.endDatetime == null) {
      return null;
    }
    final distanceKm = _estimateDistanceKm(formState.location);
    final transportFee = widget.sitter.profile.estimateTransportFee(
      careLocationType: formState.careLocationType,
      distanceKm: distanceKm,
    );
    return booking_model.BookingPricing.calculate(
      hourlyRate: widget.sitter.profile.rateForService(formState.serviceType),
      durationHours:
          formState.endDatetime!.difference(formState.startDatetime!).inMinutes /
              60.0,
      isEmergency: formState.bookingType == BookingType.emergency,
      paymentMethod: formState.paymentMethod,
      transportFee: transportFee,
    );
  }

  double _estimateDistanceKm(UserAddress? parentAddress) {
    if (parentAddress == null) return 0;
    final sitterAddress = widget.sitter.user.address;
    if (sitterAddress != null) {
      return booking_model.BookingPricing.calculateDistanceKm(
        from: sitterAddress,
        to: parentAddress,
      );
    }
    return widget.sitter.distanceKm ?? 0;
  }

  Future<void> _onConfirmBookingPressed(BuildContext context) async {
    final termsNotifier = ref.read(parentTermsAcceptanceProvider.notifier);
    final hasAcceptedTerms = await termsNotifier.isAccepted();

    if (!hasAcceptedTerms && context.mounted) {
      final accepted = await context.push<bool>(
        '/parent/terms-and-conditions?requireAcceptance=true',
      );
      if (accepted != true) {
        return;
      }
    }

    if (!mounted) return;
    await ref
        .read(createBookingProvider(widget.sitter.user.id).notifier)
        .submit();
  }

  Widget _buildPriceSummary(
      BuildContext context, booking_model.BookingPricing p) {
    final surfaceColor = context.appSurface;
    final borderColor = context.appBorder;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          _PriceRow(
              label: 'Subtotal', value: '\$${p.subtotal.toStringAsFixed(2)}'),
          _PriceRow(
              label: 'Platform Fee (15%)',
              value: '\$${p.platformCommission.toStringAsFixed(2)}'),
          if (p.transportFee > 0)
            _PriceRow(
              label: 'Transport Fee',
              value: '\$${p.transportFee.toStringAsFixed(2)}',
            ),
          if (p.emergencyFee > 0)
            _PriceRow(
                label: 'Emergency Fee',
                value: '\$${p.emergencyFee.toStringAsFixed(2)}',
                color: AppColors.emergency),
          const Divider(),
          _PriceRow(
            label: 'Total',
            value: '\$${p.total.toStringAsFixed(2)}',
            isBold: true,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null || !context.mounted) return;
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ref.read(createBookingProvider(widget.sitter.user.id).notifier).setStart(dt);
  }

  Future<void> _pickEndDateTime(BuildContext context) async {
    final start =
        ref.read(createBookingProvider(widget.sitter.user.id)).startDatetime ??
            DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(hours: 2)),
      firstDate: start,
      lastDate: start.add(const Duration(days: 7)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(start.add(const Duration(hours: 2))));
    if (time == null) return;
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    ref.read(createBookingProvider(widget.sitter.user.id).notifier).setEnd(dt);
  }

  String _fmt(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day} · $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isEmergency;
  final VoidCallback onTap;

  const _TypeChip(
      {required this.label,
      required this.isSelected,
      required this.isEmergency,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = isEmergency ? AppColors.emergency : AppColors.primary;
    final borderColor = context.appBorder;
    final surfaceVariant = context.appSurfaceVariant;
    final secondaryTextColor = context.appTextSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
              color: isSelected ? color : borderColor,
              width: isSelected ? 1.5 : 1),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : secondaryTextColor)),
      ),
    );
  }
}

class _DateTimePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimePickerButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 14),
          decoration: BoxDecoration(
            color: context.appSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
}

class _LocationPickerButton extends StatelessWidget {
  final String? address;
  final VoidCallback onTap;

  const _LocationPickerButton({this.address, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: context.appSurfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
                color: address != null ? AppColors.primary : context.appBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.primary),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  address ?? 'Select location',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: address != null
                            ? context.appTextPrimary
                            : context.appTextHint,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.appTextHint),
            ],
          ),
        ),
      );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _PriceRow(
      {required this.label,
      required this.value,
      this.isBold = false,
      this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: isBold
                  ? Theme.of(context).textTheme.titleMedium
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: context.appTextSecondary),
            ),
            Text(
              value,
              style: (isBold
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(
                color: color,
                fontWeight: isBold ? FontWeight.w700 : null,
              ),
            ),
          ],
        ),
      );
}
