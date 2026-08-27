// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_snapshot_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportSnapshotsForGymHash() =>
    r'cbe99a8b064d0eb7a895f54f913d6141508019ef';

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

/// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
/// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
/// provider sadece `ReportSnapshotController`'ın getter'ları içinden
/// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
/// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
/// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
/// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
/// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
/// kalıyordu.
///
/// Copied from [reportSnapshotsForGym].
@ProviderFor(reportSnapshotsForGym)
const reportSnapshotsForGymProvider = ReportSnapshotsForGymFamily();

/// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
/// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
/// provider sadece `ReportSnapshotController`'ın getter'ları içinden
/// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
/// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
/// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
/// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
/// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
/// kalıyordu.
///
/// Copied from [reportSnapshotsForGym].
class ReportSnapshotsForGymFamily
    extends Family<AsyncValue<List<ReportSnapshot>>> {
  /// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
  /// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
  /// provider sadece `ReportSnapshotController`'ın getter'ları içinden
  /// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
  /// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
  /// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
  /// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
  /// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
  /// kalıyordu.
  ///
  /// Copied from [reportSnapshotsForGym].
  const ReportSnapshotsForGymFamily();

  /// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
  /// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
  /// provider sadece `ReportSnapshotController`'ın getter'ları içinden
  /// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
  /// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
  /// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
  /// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
  /// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
  /// kalıyordu.
  ///
  /// Copied from [reportSnapshotsForGym].
  ReportSnapshotsForGymProvider call(String gymId, ReportPeriod period) {
    return ReportSnapshotsForGymProvider(gymId, period);
  }

  @override
  ReportSnapshotsForGymProvider getProviderOverride(
    covariant ReportSnapshotsForGymProvider provider,
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
  String? get name => r'reportSnapshotsForGymProvider';
}

/// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
/// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
/// provider sadece `ReportSnapshotController`'ın getter'ları içinden
/// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
/// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
/// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
/// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
/// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
/// kalıyordu.
///
/// Copied from [reportSnapshotsForGym].
class ReportSnapshotsForGymProvider
    extends AutoDisposeFutureProvider<List<ReportSnapshot>> {
  /// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
  /// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
  /// provider sadece `ReportSnapshotController`'ın getter'ları içinden
  /// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
  /// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
  /// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
  /// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
  /// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
  /// kalıyordu.
  ///
  /// Copied from [reportSnapshotsForGym].
  ReportSnapshotsForGymProvider(String gymId, ReportPeriod period)
    : this._internal(
        (ref) => reportSnapshotsForGym(
          ref as ReportSnapshotsForGymRef,
          gymId,
          period,
        ),
        from: reportSnapshotsForGymProvider,
        name: r'reportSnapshotsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportSnapshotsForGymHash,
        dependencies: ReportSnapshotsForGymFamily._dependencies,
        allTransitiveDependencies:
            ReportSnapshotsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        period: period,
      );

  ReportSnapshotsForGymProvider._internal(
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
    FutureOr<List<ReportSnapshot>> Function(ReportSnapshotsForGymRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportSnapshotsForGymProvider._internal(
        (ref) => create(ref as ReportSnapshotsForGymRef),
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
    return _ReportSnapshotsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportSnapshotsForGymProvider &&
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
mixin ReportSnapshotsForGymRef
    on AutoDisposeFutureProviderRef<List<ReportSnapshot>> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `period` of this provider.
  ReportPeriod get period;
}

class _ReportSnapshotsForGymProviderElement
    extends AutoDisposeFutureProviderElement<List<ReportSnapshot>>
    with ReportSnapshotsForGymRef {
  _ReportSnapshotsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as ReportSnapshotsForGymProvider).gymId;
  @override
  ReportPeriod get period => (origin as ReportSnapshotsForGymProvider).period;
}

String _$reportSnapshotControllerHash() =>
    r'cc10ddbb80f79a066c0fe068c6f94d24febcc4e3';

/// F5-9 — Raporlar ekranındaki "Geçmiş Raporlar" bölümünün seçili
/// haftalık/aylık filtresi. Asıl veri [reportSnapshotsForGymProvider]'dan
/// gelir — UI bunu DOĞRUDAN izlemeli (bkz. yukarıdaki not), bu controller
/// sadece filtre state'ini ve `retry()`'ı sağlar.
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
