import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/gyms/controller/partner_gyms_controller.dart';
import 'package:egoractive/modules/gyms/domain/partner_gym.dart';
import 'package:egoractive/modules/gyms/service/partner_gym_service.dart';

class _FakePartnerGymService implements PartnerGymService {
  const _FakePartnerGymService(this._gyms);

  final List<PartnerGym> _gyms;

  @override
  Future<List<PartnerGym>> fetchAll() async => _gyms;
}

const _turkishGym = PartnerGym(
  id: 'tr-1',
  name: 'İstanbul Fit',
  phone: '+905324187605',
  city: 'İstanbul',
  address: '',
  logoUrl: '',
);
const _usGym = PartnerGym(
  id: 'us-1',
  name: 'Texas Gym',
  phone: '+15551234567',
  city: 'Austin',
  address: '',
  logoUrl: '',
);
const _noPhoneGym = PartnerGym(
  id: 'no-phone',
  name: 'Numarasız Salon',
  phone: '',
  city: '',
  address: '',
  logoUrl: '',
);

ProviderContainer _buildContainer({
  required String? deviceCountry,
  required List<PartnerGym> gyms,
}) {
  final container = ProviderContainer(
    overrides: [
      deviceCountryCodeProvider.overrideWithValue(deviceCountry),
      partnerGymServiceProvider.overrideWithValue(
        _FakePartnerGymService(gyms),
      ),
    ],
  );
  return container;
}

void main() {
  test(
    'only shows gyms whose phone country matches the device region',
    () async {
      final container = _buildContainer(
        deviceCountry: 'TR',
        gyms: const [_turkishGym, _usGym, _noPhoneGym],
      );
      addTearDown(container.dispose);

      final result = await container.read(partnerGymsProvider.future);

      expect(result, [_turkishGym]);
    },
  );

  test('filters to the US for a US device region', () async {
    final container = _buildContainer(
      deviceCountry: 'US',
      gyms: const [_turkishGym, _usGym],
    );
    addTearDown(container.dispose);

    final result = await container.read(partnerGymsProvider.future);

    expect(result, [_usGym]);
  });

  test('shows everything when the device region is unknown', () async {
    final container = _buildContainer(
      deviceCountry: null,
      gyms: const [_turkishGym, _usGym],
    );
    addTearDown(container.dispose);

    final result = await container.read(partnerGymsProvider.future);

    expect(result, [_turkishGym, _usGym]);
  });
}
