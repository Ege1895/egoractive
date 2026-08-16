// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$summaryForGymHash() => r'604e9ed01214536485387e944e9285a4d4673602';

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

/// See also [_summaryForGym].
@ProviderFor(_summaryForGym)
const _summaryForGymProvider = _SummaryForGymFamily();

/// See also [_summaryForGym].
class _SummaryForGymFamily extends Family<AsyncValue<DashboardSummary>> {
  /// See also [_summaryForGym].
  const _SummaryForGymFamily();

  /// See also [_summaryForGym].
  _SummaryForGymProvider call(String gymId) {
    return _SummaryForGymProvider(gymId);
  }

  @override
  _SummaryForGymProvider getProviderOverride(
    covariant _SummaryForGymProvider provider,
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
  String? get name => r'_summaryForGymProvider';
}

/// See also [_summaryForGym].
class _SummaryForGymProvider
    extends AutoDisposeFutureProvider<DashboardSummary> {
  /// See also [_summaryForGym].
  _SummaryForGymProvider(String gymId)
    : this._internal(
        (ref) => _summaryForGym(ref as _SummaryForGymRef, gymId),
        from: _summaryForGymProvider,
        name: r'_summaryForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$summaryForGymHash,
        dependencies: _SummaryForGymFamily._dependencies,
        allTransitiveDependencies:
            _SummaryForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _SummaryForGymProvider._internal(
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
    FutureOr<DashboardSummary> Function(_SummaryForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SummaryForGymProvider._internal(
        (ref) => create(ref as _SummaryForGymRef),
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
  AutoDisposeFutureProviderElement<DashboardSummary> createElement() {
    return _SummaryForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SummaryForGymProvider && other.gymId == gymId;
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
mixin _SummaryForGymRef on AutoDisposeFutureProviderRef<DashboardSummary> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _SummaryForGymProviderElement
    extends AutoDisposeFutureProviderElement<DashboardSummary>
    with _SummaryForGymRef {
  _SummaryForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _SummaryForGymProvider).gymId;
}

String _$trainerPerformanceForGymHash() =>
    r'd1084f08fe2a1e69fee6a0abb752762913c74b71';

/// See also [_trainerPerformanceForGym].
@ProviderFor(_trainerPerformanceForGym)
const _trainerPerformanceForGymProvider = _TrainerPerformanceForGymFamily();

/// See also [_trainerPerformanceForGym].
class _TrainerPerformanceForGymFamily
    extends Family<AsyncValue<List<TrainerPerformance>>> {
  /// See also [_trainerPerformanceForGym].
  const _TrainerPerformanceForGymFamily();

  /// See also [_trainerPerformanceForGym].
  _TrainerPerformanceForGymProvider call(String gymId) {
    return _TrainerPerformanceForGymProvider(gymId);
  }

  @override
  _TrainerPerformanceForGymProvider getProviderOverride(
    covariant _TrainerPerformanceForGymProvider provider,
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
  String? get name => r'_trainerPerformanceForGymProvider';
}

/// See also [_trainerPerformanceForGym].
class _TrainerPerformanceForGymProvider
    extends AutoDisposeFutureProvider<List<TrainerPerformance>> {
  /// See also [_trainerPerformanceForGym].
  _TrainerPerformanceForGymProvider(String gymId)
    : this._internal(
        (ref) => _trainerPerformanceForGym(
          ref as _TrainerPerformanceForGymRef,
          gymId,
        ),
        from: _trainerPerformanceForGymProvider,
        name: r'_trainerPerformanceForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerPerformanceForGymHash,
        dependencies: _TrainerPerformanceForGymFamily._dependencies,
        allTransitiveDependencies:
            _TrainerPerformanceForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _TrainerPerformanceForGymProvider._internal(
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
    FutureOr<List<TrainerPerformance>> Function(
      _TrainerPerformanceForGymRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerPerformanceForGymProvider._internal(
        (ref) => create(ref as _TrainerPerformanceForGymRef),
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
  AutoDisposeFutureProviderElement<List<TrainerPerformance>> createElement() {
    return _TrainerPerformanceForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerPerformanceForGymProvider && other.gymId == gymId;
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
mixin _TrainerPerformanceForGymRef
    on AutoDisposeFutureProviderRef<List<TrainerPerformance>> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _TrainerPerformanceForGymProviderElement
    extends AutoDisposeFutureProviderElement<List<TrainerPerformance>>
    with _TrainerPerformanceForGymRef {
  _TrainerPerformanceForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _TrainerPerformanceForGymProvider).gymId;
}

String _$dashboardReportControllerHash() =>
    r'aeafb27936893fb470c22c4874c1306287fc6984';

/// F5-1 — Admin dashboard: aylık seans/ciro/gider özeti + antrenör
/// performansı. Aktif salon bilinmiyorsa (test ortamı vb.) boş rapor
/// gösterilir.
///
/// F7-2 — özet ve antrenör dökümü BİLEREK ayrı iki provider'dan geliyor:
/// antrenör dökümü (antrenör başına 2 `count()` sorgusu) büyük salonlarda
/// asıl maliyeti taşıyor (bkz. `DashboardReportService` dokümantasyonu).
/// Ayrı tutulunca özet metrikler antrenör dökümünü beklemeden render
/// edilebiliyor — `isSummaryLoading`/`isTrainerPerformanceLoading` panel'in
/// bu ikisini ayrı ayrı göstermesini sağlıyor.
///
/// Copied from [DashboardReportController].
@ProviderFor(DashboardReportController)
final dashboardReportControllerProvider =
    AutoDisposeNotifierProvider<
      DashboardReportController,
      DashboardReport
    >.internal(
      DashboardReportController.new,
      name: r'dashboardReportControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardReportControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardReportController = AutoDisposeNotifier<DashboardReport>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
