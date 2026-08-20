// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$duePaymentsForGymHash() => r'd6f1ad18d2565fa2028677160709065f01dc31ab';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [_duePaymentsForGym].
@ProviderFor(_duePaymentsForGym)
const _duePaymentsForGymProvider = _DuePaymentsForGymFamily();

/// See also [_duePaymentsForGym].
class _DuePaymentsForGymFamily extends Family<AsyncValue<DuePaymentsSummary>> {
  /// See also [_duePaymentsForGym].
  const _DuePaymentsForGymFamily();

  /// See also [_duePaymentsForGym].
  _DuePaymentsForGymProvider call(String gymId) {
    return _DuePaymentsForGymProvider(gymId);
  }

  @override
  _DuePaymentsForGymProvider getProviderOverride(
    covariant _DuePaymentsForGymProvider provider,
  ) {
    return call(provider.gymId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_duePaymentsForGymProvider';
}

/// See also [_duePaymentsForGym].
class _DuePaymentsForGymProvider
    extends AutoDisposeFutureProvider<DuePaymentsSummary> {
  /// See also [_duePaymentsForGym].
  _DuePaymentsForGymProvider(String gymId)
    : this._internal(
        (ref) => _duePaymentsForGym(ref as _DuePaymentsForGymRef, gymId),
        from: _duePaymentsForGymProvider,
        name: r'_duePaymentsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$duePaymentsForGymHash,
        dependencies: _DuePaymentsForGymFamily._dependencies,
        allTransitiveDependencies:
            _DuePaymentsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _DuePaymentsForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
  }) : super.internal();

  final String gymId;

  @override
  Override overrideWith(
    FutureOr<DuePaymentsSummary> Function(_DuePaymentsForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _DuePaymentsForGymProvider._internal(
        (ref) => create(ref as _DuePaymentsForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DuePaymentsSummary> createElement() {
    return _DuePaymentsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _DuePaymentsForGymProvider && other.gymId == gymId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _DuePaymentsForGymRef
    on AutoDisposeFutureProviderRef<DuePaymentsSummary> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _DuePaymentsForGymProviderElement
    extends AutoDisposeFutureProviderElement<DuePaymentsSummary>
    with _DuePaymentsForGymRef {
  _DuePaymentsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _DuePaymentsForGymProvider).gymId;
}

String _$adminHomeControllerHash() =>
    r'5caeec843a53fe76678b26d63c405c730f7791c3';

/// Admin 1 · Ana Sayfa — aylık seans/ciro/antrenör performansı zaten
/// `DashboardReportController` (reports modülü) tarafından gerçek zamanlı
/// hesaplanıyor, burada tekrar sorgulanmıyor. Sadece bu panele özel
/// "ödemesi bekleyen üye" özeti (`memberPackages.dueAmount`) ve toplam geri
/// bildirim sayısı (`AdminFeedbackController`) ek olarak izleniyor.
///
/// Copied from [AdminHomeController].
@ProviderFor(AdminHomeController)
final adminHomeControllerProvider =
    AutoDisposeNotifierProvider<AdminHomeController, AdminHomeState>.internal(
      AdminHomeController.new,
      name: r'adminHomeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminHomeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminHomeController = AutoDisposeNotifier<AdminHomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
