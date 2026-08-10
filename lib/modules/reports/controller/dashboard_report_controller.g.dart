// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportForGymHash() => r'75fda7dd9119983631f8e962f4ff5d877e987a05';

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

/// See also [_reportForGym].
@ProviderFor(_reportForGym)
const _reportForGymProvider = _ReportForGymFamily();

/// See also [_reportForGym].
class _ReportForGymFamily extends Family<AsyncValue<DashboardReport>> {
  /// See also [_reportForGym].
  const _ReportForGymFamily();

  /// See also [_reportForGym].
  _ReportForGymProvider call(String gymId) {
    return _ReportForGymProvider(gymId);
  }

  @override
  _ReportForGymProvider getProviderOverride(
    covariant _ReportForGymProvider provider,
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
  String? get name => r'_reportForGymProvider';
}

/// See also [_reportForGym].
class _ReportForGymProvider extends AutoDisposeFutureProvider<DashboardReport> {
  /// See also [_reportForGym].
  _ReportForGymProvider(String gymId)
    : this._internal(
        (ref) => _reportForGym(ref as _ReportForGymRef, gymId),
        from: _reportForGymProvider,
        name: r'_reportForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportForGymHash,
        dependencies: _ReportForGymFamily._dependencies,
        allTransitiveDependencies:
            _ReportForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _ReportForGymProvider._internal(
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
    FutureOr<DashboardReport> Function(_ReportForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ReportForGymProvider._internal(
        (ref) => create(ref as _ReportForGymRef),
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
  AutoDisposeFutureProviderElement<DashboardReport> createElement() {
    return _ReportForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ReportForGymProvider && other.gymId == gymId;
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
mixin _ReportForGymRef on AutoDisposeFutureProviderRef<DashboardReport> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _ReportForGymProviderElement
    extends AutoDisposeFutureProviderElement<DashboardReport>
    with _ReportForGymRef {
  _ReportForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _ReportForGymProvider).gymId;
}

String _$dashboardReportControllerHash() =>
    r'22ff9fceac74641a9844fe3245e0b7fd147a1f9c';

/// F5-1 — Admin dashboard: aylık seans/ciro/gider özeti + antrenör
/// performansı. Aktif salon bilinmiyorsa (test ortamı vb.) boş rapor
/// gösterilir.
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
