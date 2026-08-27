// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_snapshot_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$snapshotsForGymHash() => r'e2435cb69d04900d35bc5429d1b5fa2dd0b2a5d4';

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

/// See also [_snapshotsForGym].
@ProviderFor(_snapshotsForGym)
const _snapshotsForGymProvider = _SnapshotsForGymFamily();

/// See also [_snapshotsForGym].
class _SnapshotsForGymFamily extends Family<AsyncValue<List<ReportSnapshot>>> {
  /// See also [_snapshotsForGym].
  const _SnapshotsForGymFamily();

  /// See also [_snapshotsForGym].
  _SnapshotsForGymProvider call(String gymId, ReportPeriod period) {
    return _SnapshotsForGymProvider(gymId, period);
  }

  @override
  _SnapshotsForGymProvider getProviderOverride(
    covariant _SnapshotsForGymProvider provider,
  ) {
    return call(provider.gymId, provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_snapshotsForGymProvider';
}

/// See also [_snapshotsForGym].
class _SnapshotsForGymProvider
    extends AutoDisposeFutureProvider<List<ReportSnapshot>> {
  /// See also [_snapshotsForGym].
  _SnapshotsForGymProvider(String gymId, ReportPeriod period)
    : this._internal(
        (ref) => _snapshotsForGym(ref as _SnapshotsForGymRef, gymId, period),
        from: _snapshotsForGymProvider,
        name: r'_snapshotsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$snapshotsForGymHash,
        dependencies: _SnapshotsForGymFamily._dependencies,
        allTransitiveDependencies:
            _SnapshotsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        period: period,
      );

  _SnapshotsForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
    required this.period,
  }) : super.internal();

  final String gymId;
  final ReportPeriod period;

  @override
  Override overrideWith(
    FutureOr<List<ReportSnapshot>> Function(_SnapshotsForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SnapshotsForGymProvider._internal(
        (ref) => create(ref as _SnapshotsForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReportSnapshot>> createElement() {
    return _SnapshotsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SnapshotsForGymProvider &&
        other.gymId == gymId &&
        other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SnapshotsForGymRef
    on AutoDisposeFutureProviderRef<List<ReportSnapshot>> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `period` of this provider.
  ReportPeriod get period;
}

class _SnapshotsForGymProviderElement
    extends AutoDisposeFutureProviderElement<List<ReportSnapshot>>
    with _SnapshotsForGymRef {
  _SnapshotsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _SnapshotsForGymProvider).gymId;
  @override
  ReportPeriod get period => (origin as _SnapshotsForGymProvider).period;
}

String _$reportSnapshotControllerHash() =>
    r'6f2090c65329be17f523f0d9a41d02923765a1f0';

/// F5-9 — Raporlar ekranındaki "Geçmiş Raporlar" bölümü: state, o an seçili
/// haftalık/aylık filtredir; [snapshots]/[isLoading]/[hasError] getter'ları
/// bu filtreye göre `gyms/{gymId}/reportSnapshots`'tan (F5-7/F5-8) okunan
/// listeyi sunar. `DashboardReportController`'daki aynı desen (getter'larda
/// `ref.watch`, ayrı bir `_snapshotsForGym` family provider) izlenir.
///
/// Copied from [ReportSnapshotController].
@ProviderFor(ReportSnapshotController)
final reportSnapshotControllerProvider =
    AutoDisposeNotifierProvider<
      ReportSnapshotController,
      ReportPeriod
    >.internal(
      ReportSnapshotController.new,
      name: r'reportSnapshotControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reportSnapshotControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReportSnapshotController = AutoDisposeNotifier<ReportPeriod>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
