import 'package:flutter_test/flutter_test.dart';
import 'package:hodon_app/data/repositories/mock/mock_sitter_repository.dart';
import 'package:hodon_app/domain/enums/app_enums.dart';

void main() {
  test('babysitter can update rates, care locations, and transport settings',
      () async {
    final repo = MockSitterRepository();
    final sitter = await repo.getSitterDetail('user_sitter_1');

    final updated = await repo.updateSitterProfile(
      sitterId: sitter.user.id,
      profile: sitter.profile.copyWith(
        hourlyRate: 17,
        services: const [
          ServiceType.babysitting,
          ServiceType.fullTimeNanny,
        ],
        serviceHourlyRates: const {
          ServiceType.babysitting: 17,
          ServiceType.fullTimeNanny: 22,
        },
        supportedCareLocations: const [
          CareLocationType.sitterHomeHosting,
          CareLocationType.parentHomeVisit,
        ],
        transportFeePerKm: 2.1,
        coverageRadiusKm: 15,
      ),
    );

    expect(updated.profile.rateForService(ServiceType.babysitting), 17);
    expect(updated.profile.rateForService(ServiceType.fullTimeNanny), 22);
    expect(
      updated.profile.supportedCareLocations,
      contains(CareLocationType.sitterHomeHosting),
    );
    expect(updated.profile.transportFeePerKm, 2.1);
    expect(updated.profile.coverageRadiusKm, 15);

    final refreshed = await repo.getSitterDetail('user_sitter_1');
    expect(refreshed.profile.rateForService(ServiceType.fullTimeNanny), 22);
    expect(
      refreshed.profile.supportedCareLocations,
      contains(CareLocationType.parentHomeVisit),
    );
  });
}

