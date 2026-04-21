import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../domain/enums/app_enums.dart';
import '../../shared/widgets/shared_widgets.dart';

const Map<ServiceType, String> _serviceAgeRanges = {
  ServiceType.babysitting: 'Ages 1-12',
  ServiceType.fullTimeNanny: 'Ages 0-12',
  ServiceType.newbornInfantCare: 'Ages 0-2',
  ServiceType.childhoodEducation: 'Ages 3-10',
};

class RatesServicesScreen extends ConsumerStatefulWidget {
  const RatesServicesScreen({super.key});

  @override
  ConsumerState<RatesServicesScreen> createState() => _RatesServicesScreenState();
}

class _RatesServicesScreenState extends ConsumerState<RatesServicesScreen> {
  late final Map<ServiceType, _ServiceConfig> _serviceConfigs;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _serviceConfigs = {
      ServiceType.babysitting: _ServiceConfig(enabled: true, rateController: TextEditingController(text: '15')),
      ServiceType.fullTimeNanny: _ServiceConfig(enabled: true, rateController: TextEditingController(text: '18')),
      ServiceType.newbornInfantCare: _ServiceConfig(enabled: false, rateController: TextEditingController(text: '20')),
      ServiceType.childhoodEducation: _ServiceConfig(enabled: false, rateController: TextEditingController(text: '22')),
    };
  }

  @override
  void dispose() {
    for (final cfg in _serviceConfigs.values) {
      cfg.rateController.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    for (final entry in _serviceConfigs.entries) {
      if (!entry.value.enabled) continue;
      final rate = double.tryParse(entry.value.rateController.text.trim());
      if (rate == null || rate <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enter a valid hourly rate for ${entry.key.label}.')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rates & services saved successfully.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _serviceConfigs.values.where((cfg) => cfg.enabled).length;

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
                    'Enable services you provide, then set hourly rate for each enabled service.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
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
                          color: enabledCount == 0 ? AppColors.textHint : AppColors.success,
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

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      serviceType.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _serviceAgeRanges[serviceType] ?? 'All ages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
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
                  color: enabled ? AppColors.success : AppColors.textSecondary,
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
              fillColor: enabled ? AppColors.surface : AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                borderSide: const BorderSide(color: AppColors.border),
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

