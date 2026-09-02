// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_gym_currency_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeGymCurrencyHash() => r'78650a18b5ded9716ed08b4108fe0d65271801b0';

/// F9-3 — para gösterilen/girilen HER ekranın aktif salonun para birimini
/// okumak için kullandığı tek kaynak. `GymProfileController` salon profili
/// DÜZENLEME akışının (form state, reset() vb.) parçası olduğundan, sadece
/// bir sayıyı doğru para biriminde göstermek isteyen ekranların ona bağımlı
/// olmaması için ayrı, salt-okunur bir provider.
///
/// Copied from [activeGymCurrency].
@ProviderFor(activeGymCurrency)
final activeGymCurrencyProvider = AutoDisposeStreamProvider<String>.internal(
  activeGymCurrency,
  name: r'activeGymCurrencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGymCurrencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGymCurrencyRef = AutoDisposeStreamProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
