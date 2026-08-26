// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detailStreamForIdHash() => r'd457717ee6c7c614acec6247ecb7a26867450217';

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

/// See also [_detailStreamForId].
@ProviderFor(_detailStreamForId)
const _detailStreamForIdProvider = _DetailStreamForIdFamily();

/// See also [_detailStreamForId].
class _DetailStreamForIdFamily extends Family<AsyncValue<AdminMemberDetail>> {
  /// See also [_detailStreamForId].
  const _DetailStreamForIdFamily();

  /// See also [_detailStreamForId].
  _DetailStreamForIdProvider call(String memberId) {
    return _DetailStreamForIdProvider(memberId);
  }

  @override
  _DetailStreamForIdProvider getProviderOverride(
    covariant _DetailStreamForIdProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_detailStreamForIdProvider';
}

/// See also [_detailStreamForId].
class _DetailStreamForIdProvider
    extends AutoDisposeStreamProvider<AdminMemberDetail> {
  /// See also [_detailStreamForId].
  _DetailStreamForIdProvider(String memberId)
    : this._internal(
        (ref) => _detailStreamForId(ref as _DetailStreamForIdRef, memberId),
        from: _detailStreamForIdProvider,
        name: r'_detailStreamForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$detailStreamForIdHash,
        dependencies: _DetailStreamForIdFamily._dependencies,
        allTransitiveDependencies:
            _DetailStreamForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _DetailStreamForIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<AdminMemberDetail> Function(_DetailStreamForIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _DetailStreamForIdProvider._internal(
        (ref) => create(ref as _DetailStreamForIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AdminMemberDetail> createElement() {
    return _DetailStreamForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _DetailStreamForIdProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _DetailStreamForIdRef on AutoDisposeStreamProviderRef<AdminMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _DetailStreamForIdProviderElement
    extends AutoDisposeStreamProviderElement<AdminMemberDetail>
    with _DetailStreamForIdRef {
  _DetailStreamForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _DetailStreamForIdProvider).memberId;
}

String _$latestPackageForMemberHash() =>
    r'6b642fe8bce37fe4d4256581d16f541189c3babd';

/// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
/// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
///
/// Copied from [_latestPackageForMember].
@ProviderFor(_latestPackageForMember)
const _latestPackageForMemberProvider = _LatestPackageForMemberFamily();

/// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
/// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
///
/// Copied from [_latestPackageForMember].
class _LatestPackageForMemberFamily
    extends Family<AsyncValue<QueryDocumentSnapshot<Map<String, dynamic>>?>> {
  /// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
  /// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
  ///
  /// Copied from [_latestPackageForMember].
  const _LatestPackageForMemberFamily();

  /// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
  /// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
  ///
  /// Copied from [_latestPackageForMember].
  _LatestPackageForMemberProvider call(String memberId) {
    return _LatestPackageForMemberProvider(memberId);
  }

  @override
  _LatestPackageForMemberProvider getProviderOverride(
    covariant _LatestPackageForMemberProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_latestPackageForMemberProvider';
}

/// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
/// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
///
/// Copied from [_latestPackageForMember].
class _LatestPackageForMemberProvider
    extends
        AutoDisposeStreamProvider<
          QueryDocumentSnapshot<Map<String, dynamic>>?
        > {
  /// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
  /// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
  ///
  /// Copied from [_latestPackageForMember].
  _LatestPackageForMemberProvider(String memberId)
    : this._internal(
        (ref) => _latestPackageForMember(
          ref as _LatestPackageForMemberRef,
          memberId,
        ),
        from: _latestPackageForMemberProvider,
        name: r'_latestPackageForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestPackageForMemberHash,
        dependencies: _LatestPackageForMemberFamily._dependencies,
        allTransitiveDependencies:
            _LatestPackageForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _LatestPackageForMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> Function(
      _LatestPackageForMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _LatestPackageForMemberProvider._internal(
        (ref) => create(ref as _LatestPackageForMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<QueryDocumentSnapshot<Map<String, dynamic>>?>
  createElement() {
    return _LatestPackageForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _LatestPackageForMemberProvider &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _LatestPackageForMemberRef
    on
        AutoDisposeStreamProviderRef<
          QueryDocumentSnapshot<Map<String, dynamic>>?
        > {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _LatestPackageForMemberProviderElement
    extends
        AutoDisposeStreamProviderElement<
          QueryDocumentSnapshot<Map<String, dynamic>>?
        >
    with _LatestPackageForMemberRef {
  _LatestPackageForMemberProviderElement(super.provider);

  @override
  String get memberId => (origin as _LatestPackageForMemberProvider).memberId;
}

String _$sessionHistoryForAdminMemberHash() =>
    r'07de9b81d185f67734055bce12b5dc3b16b92e20';

/// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
/// sorgulanır, durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForAdminMember].
@ProviderFor(_sessionHistoryForAdminMember)
const _sessionHistoryForAdminMemberProvider =
    _SessionHistoryForAdminMemberFamily();

/// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
/// sorgulanır, durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForAdminMember].
class _SessionHistoryForAdminMemberFamily
    extends Family<AsyncValue<List<SessionHistoryEntry>>> {
  /// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
  /// sorgulanır, durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForAdminMember].
  const _SessionHistoryForAdminMemberFamily();

  /// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
  /// sorgulanır, durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForAdminMember].
  _SessionHistoryForAdminMemberProvider call(String memberId) {
    return _SessionHistoryForAdminMemberProvider(memberId);
  }

  @override
  _SessionHistoryForAdminMemberProvider getProviderOverride(
    covariant _SessionHistoryForAdminMemberProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_sessionHistoryForAdminMemberProvider';
}

/// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
/// sorgulanır, durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForAdminMember].
class _SessionHistoryForAdminMemberProvider
    extends AutoDisposeStreamProvider<List<SessionHistoryEntry>> {
  /// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
  /// sorgulanır, durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForAdminMember].
  _SessionHistoryForAdminMemberProvider(String memberId)
    : this._internal(
        (ref) => _sessionHistoryForAdminMember(
          ref as _SessionHistoryForAdminMemberRef,
          memberId,
        ),
        from: _sessionHistoryForAdminMemberProvider,
        name: r'_sessionHistoryForAdminMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionHistoryForAdminMemberHash,
        dependencies: _SessionHistoryForAdminMemberFamily._dependencies,
        allTransitiveDependencies:
            _SessionHistoryForAdminMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _SessionHistoryForAdminMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<List<SessionHistoryEntry>> Function(
      _SessionHistoryForAdminMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionHistoryForAdminMemberProvider._internal(
        (ref) => create(ref as _SessionHistoryForAdminMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SessionHistoryEntry>> createElement() {
    return _SessionHistoryForAdminMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionHistoryForAdminMemberProvider &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionHistoryForAdminMemberRef
    on AutoDisposeStreamProviderRef<List<SessionHistoryEntry>> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _SessionHistoryForAdminMemberProviderElement
    extends AutoDisposeStreamProviderElement<List<SessionHistoryEntry>>
    with _SessionHistoryForAdminMemberRef {
  _SessionHistoryForAdminMemberProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as _SessionHistoryForAdminMemberProvider).memberId;
}

String _$metricSeriesForAdminMemberHash() =>
    r'9af9255bd8ccdc5f51875a65e2b493ff18337f1c';

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
/// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
/// yağ oranı) tamamını tek sorgudan üretir (bkz.
/// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
/// karşılığıyla aynı kaynak).
///
/// Copied from [_metricSeriesForAdminMember].
@ProviderFor(_metricSeriesForAdminMember)
const _metricSeriesForAdminMemberProvider = _MetricSeriesForAdminMemberFamily();

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
/// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
/// yağ oranı) tamamını tek sorgudan üretir (bkz.
/// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
/// karşılığıyla aynı kaynak).
///
/// Copied from [_metricSeriesForAdminMember].
class _MetricSeriesForAdminMemberFamily
    extends Family<AsyncValue<Map<TrainerMetric, TrainerMetricSeries>>> {
  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
  /// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
  /// yağ oranı) tamamını tek sorgudan üretir (bkz.
  /// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
  /// karşılığıyla aynı kaynak).
  ///
  /// Copied from [_metricSeriesForAdminMember].
  const _MetricSeriesForAdminMemberFamily();

  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
  /// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
  /// yağ oranı) tamamını tek sorgudan üretir (bkz.
  /// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
  /// karşılığıyla aynı kaynak).
  ///
  /// Copied from [_metricSeriesForAdminMember].
  _MetricSeriesForAdminMemberProvider call(String memberId) {
    return _MetricSeriesForAdminMemberProvider(memberId);
  }

  @override
  _MetricSeriesForAdminMemberProvider getProviderOverride(
    covariant _MetricSeriesForAdminMemberProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_metricSeriesForAdminMemberProvider';
}

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
/// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
/// yağ oranı) tamamını tek sorgudan üretir (bkz.
/// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
/// karşılığıyla aynı kaynak).
///
/// Copied from [_metricSeriesForAdminMember].
class _MetricSeriesForAdminMemberProvider
    extends AutoDisposeStreamProvider<Map<TrainerMetric, TrainerMetricSeries>> {
  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
  /// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
  /// yağ oranı) tamamını tek sorgudan üretir (bkz.
  /// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
  /// karşılığıyla aynı kaynak).
  ///
  /// Copied from [_metricSeriesForAdminMember].
  _MetricSeriesForAdminMemberProvider(String memberId)
    : this._internal(
        (ref) => _metricSeriesForAdminMember(
          ref as _MetricSeriesForAdminMemberRef,
          memberId,
        ),
        from: _metricSeriesForAdminMemberProvider,
        name: r'_metricSeriesForAdminMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$metricSeriesForAdminMemberHash,
        dependencies: _MetricSeriesForAdminMemberFamily._dependencies,
        allTransitiveDependencies:
            _MetricSeriesForAdminMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _MetricSeriesForAdminMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<Map<TrainerMetric, TrainerMetricSeries>> Function(
      _MetricSeriesForAdminMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _MetricSeriesForAdminMemberProvider._internal(
        (ref) => create(ref as _MetricSeriesForAdminMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<TrainerMetric, TrainerMetricSeries>>
  createElement() {
    return _MetricSeriesForAdminMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _MetricSeriesForAdminMemberProvider &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _MetricSeriesForAdminMemberRef
    on AutoDisposeStreamProviderRef<Map<TrainerMetric, TrainerMetricSeries>> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _MetricSeriesForAdminMemberProviderElement
    extends
        AutoDisposeStreamProviderElement<
          Map<TrainerMetric, TrainerMetricSeries>
        >
    with _MetricSeriesForAdminMemberRef {
  _MetricSeriesForAdminMemberProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as _MetricSeriesForAdminMemberProvider).memberId;
}

String _$adminMemberDetailControllerHash() =>
    r'93bcdc0e41ebe3419b38f55866bb206c3bbeae9a';

abstract class _$AdminMemberDetailController
    extends BuildlessAutoDisposeNotifier<AdminMemberDetail> {
  late final String memberId;

  AdminMemberDetail build(String memberId);
}

/// See also [AdminMemberDetailController].
@ProviderFor(AdminMemberDetailController)
const adminMemberDetailControllerProvider = AdminMemberDetailControllerFamily();

/// See also [AdminMemberDetailController].
class AdminMemberDetailControllerFamily extends Family<AdminMemberDetail> {
  /// See also [AdminMemberDetailController].
  const AdminMemberDetailControllerFamily();

  /// See also [AdminMemberDetailController].
  AdminMemberDetailControllerProvider call(String memberId) {
    return AdminMemberDetailControllerProvider(memberId);
  }

  @override
  AdminMemberDetailControllerProvider getProviderOverride(
    covariant AdminMemberDetailControllerProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adminMemberDetailControllerProvider';
}

/// See also [AdminMemberDetailController].
class AdminMemberDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminMemberDetailController,
          AdminMemberDetail
        > {
  /// See also [AdminMemberDetailController].
  AdminMemberDetailControllerProvider(String memberId)
    : this._internal(
        () => AdminMemberDetailController()..memberId = memberId,
        from: adminMemberDetailControllerProvider,
        name: r'adminMemberDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminMemberDetailControllerHash,
        dependencies: AdminMemberDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminMemberDetailControllerFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  AdminMemberDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  AdminMemberDetail runNotifierBuild(
    covariant AdminMemberDetailController notifier,
  ) {
    return notifier.build(memberId);
  }

  @override
  Override overrideWith(AdminMemberDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminMemberDetailControllerProvider._internal(
        () => create()..memberId = memberId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    AdminMemberDetailController,
    AdminMemberDetail
  >
  createElement() {
    return _AdminMemberDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminMemberDetailControllerProvider &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdminMemberDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _AdminMemberDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminMemberDetailController,
          AdminMemberDetail
        >
    with AdminMemberDetailControllerRef {
  _AdminMemberDetailControllerProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as AdminMemberDetailControllerProvider).memberId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
