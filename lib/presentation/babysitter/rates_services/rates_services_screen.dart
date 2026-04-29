import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/providers.dart';
import '../../../application/sitter/sitter_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/context_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../../domain/models/babysitter_profile.dart';
import '../../shared/widgets/shared_widgets.dart';

const Map<ServiceType, String> _serviceAgeRanges = {
  ServiceType.babysitting: 'Ages 1-12',
  ServiceType.fullTimeNanny: 'Ages 0-12',
  ServiceType.newbornInfantCare: 'Ages 0-2',
  ServiceType.childhoodEducation: 'Ages 3-10',
};

const Map<ServiceType, String> _serviceDescriptions = {
  ServiceType.babysitting:
      'Short-term childcare for a few hours, usually evenings or specific occasions. Best for flexible, ad-hoc support.',
  ServiceType.fullTimeNanny:
      'Consistent daily childcare with routine support (meals, school prep, naps, activities). Best for families needing ongoing coverage.',
  ServiceType.newbornInfantCare:
      'Specialized care for newborns and infants, including feeding schedules, soothing, sleep routines, and hygiene support.',
  ServiceType.childhoodEducation:
      'Learning-focused support through structured play, early literacy/numeracy, and age-appropriate educational activities.',
};

class RatesServicesScreen extends ConsumerWidget {
  const RatesServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in as a babysitter.')),
      );
    }

    final sitterAsync = ref.watch(sitterDetailProvider(user.id));
    return sitterAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (sitter) => _RatesServicesForm(sitter: sitter),
    );
  }
}

class _RatesServicesForm extends ConsumerStatefulWidget {
  final SitterCard sitter;

  const _RatesServicesForm({required this.sitter});

  @override
  ConsumerState<_RatesServicesForm> createState() => _RatesServicesFormState();
}

class _RatesServicesFormState extends ConsumerState<_RatesServicesForm> {
  late final Map<ServiceType, _ServiceConfig> _serviceConfigs;
  late final Set<CareLocationType> _supportedCareLocations;
  late final TextEditingController _transportFeeCtrl;
  late final TextEditingController _coverageRadiusCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.sitter.profile;
    _serviceConfigs = {
      for (final service in ServiceType.values)
        service: _ServiceConfig(
          enabled: profile.services.contains(service),
          rateController: TextEditingController(
            text: profile.rateForService(service).toStringAsFixed(0),
          ),
        ),
    };
    _supportedCareLocations = profile.supportedCareLocations.toSet();
    _transportFeeCtrl = TextEditingController(
      text: profile.transportFeePerKm.toStringAsFixed(
        profile.transportFeePerKm.truncateToDouble() == profile.transportFeePerKm
            ? 0
            : 2,
      ),
    );
    _coverageRadiusCtrl = TextEditingController(
      text: profile.coverageRadiusKm?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    for (final cfg in _serviceConfigs.values) {
      cfg.rateController.dispose();
    }
    _transportFeeCtrl.dispose();
    _coverageRadiusCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final enabledServices = <ServiceType>[];
    final serviceRates = <ServiceType, double>{};

    for (final entry in _serviceConfigs.entries) {
      if (!entry.value.enabled) continue;
      final rate = double.tryParse(entry.value.rateController.text.trim());
      if (rate == null || rate <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter a valid hourly rate for ${entry.key.label}.')),
        );
        return;
      }
      enabledServices.add(entry.key);
      serviceRates[entry.key] = rate;
    }

    if (enabledServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enable at least one service.')),
      );
      return;
    }

    if (_supportedCareLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one care arrangement.')),
      );
      return;
    }

    final transportFeePerKm =
        double.tryParse(_transportFeeCtrl.text.trim().isEmpty ? '0' : _transportFeeCtrl.text.trim());
    if (transportFeePerKm == null || transportFeePerKm < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid transport fee per km.')),
      );
      return;
    }

    final coverageRadiusText = _coverageRadiusCtrl.text.trim();
    final coverageRadiusKm = coverageRadiusText.isEmpty
        ? null
        : double.tryParse(coverageRadiusText);
    if (coverageRadiusText.isNotEmpty &&
        (coverageRadiusKm == null || coverageRadiusKm <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid travel radius in km.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final sortedRates = serviceRates.values.toList()..sort();
      final updatedProfile = widget.sitter.profile.copyWith(
        hourlyRate: sortedRates.first,
        services: enabledServices,
        serviceHourlyRates: serviceRates,
        supportedCareLocations: _supportedCareLocations.toList(),
        transportFeePerKm: transportFeePerKm,
        coverageRadiusKm: coverageRadiusKm,
      );

      await ref.read(sitterRepositoryProvider).updateSitterProfile(
            sitterId: widget.sitter.user.id,
            profile: updatedProfile,
          );
      ref.invalidate(sitterDetailProvider(widget.sitter.user.id));
      ref.invalidate(sitterSearchProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rates & services saved successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _serviceConfigs.values.where((cfg) => cfg.enabled).length;
    final secondaryTextColor = context.appTextSecondary;
    final hintColor = context.appTextHint;

    return Scaffold(
      appBar: AppBar(title: const Text('Rates & Services')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  Text('Service Availability', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Enable the services you provide, set the hourly rate for each one, then choose how families can book you.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                  ),
                  const SizedBox(height: AppSizes.md),
                  HodonCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$enabledCount of ${ServiceType.values.length} services enabled',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        StatusChip(
                          label: enabledCount == 0 ? 'Inactive' : 'Active',
                          color: enabledCount == 0 ? hintColor : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...ServiceType.values.map((service) {
                    final config = _serviceConfigs[service]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: _ServiceRateCard(
                        serviceType: service,
                        enabled: config.enabled,
                        rateController: config.rateController,
                        onToggle: (v) => setState(() => config.enabled = v),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSizes.lg),
                  Text('Care Location Preferences', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Choose the booking arrangements you accept. Transport fees only apply when travel is required.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                  ),
                  const SizedBox(height: AppSizes.md),
                  ...CareLocationType.values.map((careLocation) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: _CareLocationCard(
                          careLocationType: careLocation,
                          selected: _supportedCareLocations.contains(careLocation),
                          onToggle: (selected) => setState(() {
                            if (selected) {
                              _supportedCareLocations.add(careLocation);
                            } else {
                              _supportedCareLocations.remove(careLocation);
                            }
                          }),
                        ),
                      )),
                  const SizedBox(height: AppSizes.lg),
                  Text('Transport Pricing', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSizes.sm),
                  HodonCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set how much to charge when you travel or when the parent arranges pickup from your location.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: secondaryTextColor),
                        ),
                        const SizedBox(height: AppSizes.md),
                        TextField(
                          controller: _transportFeeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            prefixText: '\$',
                            suffixText: '/km',
                            labelText: 'Transport Fee',
                            hintText: 'e.g. 1.5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.md),
                        TextField(
                          controller: _coverageRadiusCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            suffixText: 'km',
                            labelText: 'Travel Radius',
                            hintText: 'Leave empty for no limit',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.pageHorizontal,
                AppSizes.sm,
                AppSizes.pageHorizontal,
                AppSizes.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Rates & Services'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareLocationCard extends StatelessWidget {
  final CareLocationType careLocationType;
  final bool selected;
  final ValueChanged<bool> onToggle;

  const _CareLocationCard({
    required this.careLocationType,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;

    return HodonCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  careLocationType.label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  careLocationType.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: secondaryTextColor),
                ),
                const SizedBox(height: 6),
                Text(
                  careLocationType.requiresTransportFee
                      ? 'Distance-based transport fee applies.'
                      : 'No transport fee is added for this arrangement.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: careLocationType.requiresTransportFee
                            ? AppColors.primary
                            : AppColors.success,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: selected,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _ServiceRateCard extends StatelessWidget {
  final ServiceType serviceType;
  final bool enabled;
  final TextEditingController rateController;
  final ValueChanged<bool> onToggle;

  const _ServiceRateCard({
    required this.serviceType,
    required this.enabled,
    required this.rateController,
    required this.onToggle,
  });

  void _showServiceInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(serviceType.label),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _serviceDescriptions[serviceType] ?? 'Service details are not available.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Recommended ${_serviceAgeRanges[serviceType] ?? 'All ages'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaryTextColor = context.appTextSecondary;
    final surfaceColor = context.appSurface;
    final surfaceVariantColor = context.appSurfaceVariant;
    final borderColor = context.appBorder;

    return HodonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            serviceType.label,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showServiceInfo(context),
                          icon: const Icon(Icons.info_outline_rounded, size: 18),
                          tooltip: 'Service info',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _serviceAgeRanges[serviceType] ?? 'All ages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            enabled ? 'Enabled - set your hourly rate' : 'Disabled - enable to offer this service',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabled ? AppColors.success : secondaryTextColor,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          TextField(
            controller: rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: enabled,
            decoration: InputDecoration(
              prefixText: '\$',
              suffixText: '/hr',
              labelText: 'Hourly Rate',
              hintText: 'Enter rate',
              filled: true,
              fillColor: enabled ? surfaceColor : surfaceVariantColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceConfig {
  bool enabled;
  final TextEditingController rateController;

  _ServiceConfig({required this.enabled, required this.rateController});
}

