// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerDetailStreamForIdHash() =>
    r'cf435e6c34cb7e4b9429430d82342626ff7ee794';

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

/// See also [_trainerDetailStreamForId].
@ProviderFor(_trainerDetailStreamForId)
const _trainerDetailStreamForIdProvider = _TrainerDetailStreamForIdFamily();

/// See also [_trainerDetailStreamForId].
class _TrainerDetailStreamForIdFamily
    extends Family<AsyncValue<TrainerMemberDetail>> {
  /// See also [_trainerDetailStreamForId].
  const _TrainerDetailStreamForIdFamily();

  /// See also [_trainerDetailStreamForId].
  _TrainerDetailStreamForIdProvider call(String memberId) {
    return _TrainerDetailStreamForIdProvider(memberId);
  }

  @override
  _TrainerDetailStreamForIdProvider getProviderOverride(
    covariant _TrainerDetailStreamForIdProvider provider,
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
  String? get name => r'_trainerDetailStreamForIdProvider';
}

/// See also [_trainerDetailStreamForId].
class _TrainerDetailStreamForIdProvider
    extends AutoDisposeStreamProvider<TrainerMemberDetail> {
  /// See also [_trainerDetailStreamForId].
  _TrainerDetailStreamForIdProvider(String memberId)
    : this._internal(
        (ref) => _trainerDetailStreamForId(
          ref as _TrainerDetailStreamForIdRef,
          memberId,
        ),
        from: _trainerDetailStreamForIdProvider,
        name: r'_trainerDetailStreamForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerDetailStreamForIdHash,
        dependencies: _TrainerDetailStreamForIdFamily._dependencies,
        allTransitiveDependencies:
            _TrainerDetailStreamForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _TrainerDetailStreamForIdProvider._internal(
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
    Stream<TrainerMemberDetail> Function(_TrainerDetailStreamForIdRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TrainerDetailStreamForIdProvider._internal(
        (ref) => create(ref as _TrainerDetailStreamForIdRef),
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
  AutoDisposeStreamProviderElement<TrainerMemberDetail> createElement() {
    return _TrainerDetailStreamForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TrainerDetailStreamForIdProvider &&
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
mixin _TrainerDetailStreamForIdRef
    on AutoDisposeStreamProviderRef<TrainerMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _TrainerDetailStreamForIdProviderElement
    extends AutoDisposeStreamProviderElement<TrainerMemberDetail>
    with _TrainerDetailStreamForIdRef {
  _TrainerDetailStreamForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _TrainerDetailStreamForIdProvider).memberId;
}

String _$sessionHistoryForMemberHash() =>
    r'cbd0e14665f538c1411a36a30de5ae339f781f12';

/// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
/// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
/// desen), `memberId`/durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForMember].
@ProviderFor(_sessionHistoryForMember)
const _sessionHistoryForMemberProvider = _SessionHistoryForMemberFamily();

/// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
/// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
/// desen), `memberId`/durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForMember].
class _SessionHistoryForMemberFamily
    extends Family<AsyncValue<List<SessionHistoryEntry>>> {
  /// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
  /// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
  /// desen), `memberId`/durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForMember].
  const _SessionHistoryForMemberFamily();

  /// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
  /// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
  /// desen), `memberId`/durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForMember].
  _SessionHistoryForMemberProvider call(String trainerId, String memberId) {
    return _SessionHistoryForMemberProvider(trainerId, memberId);
  }

  @override
  _SessionHistoryForMemberProvider getProviderOverride(
    covariant _SessionHistoryForMemberProvider provider,
  ) {
    return call(provider.trainerId, provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_sessionHistoryForMemberProvider';
}

/// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
/// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
/// desen), `memberId`/durum filtresi client-side yapılır.
///
/// Copied from [_sessionHistoryForMember].
class _SessionHistoryForMemberProvider
    extends AutoDisposeStreamProvider<List<SessionHistoryEntry>> {
  /// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
  /// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
  /// desen), `memberId`/durum filtresi client-side yapılır.
  ///
  /// Copied from [_sessionHistoryForMember].
  _SessionHistoryForMemberProvider(String trainerId, String memberId)
    : this._internal(
        (ref) => _sessionHistoryForMember(
          ref as _SessionHistoryForMemberRef,
          trainerId,
          memberId,
        ),
        from: _sessionHistoryForMemberProvider,
        name: r'_sessionHistoryForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionHistoryForMemberHash,
        dependencies: _SessionHistoryForMemberFamily._dependencies,
        allTransitiveDependencies:
            _SessionHistoryForMemberFamily._allTransitiveDependencies,
        trainerId: trainerId,
        memberId: memberId,
      );

  _SessionHistoryForMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
    required this.memberId,
  }) : super.internal();

  final String trainerId;
  final String memberId;

  @override
  Override overrideWith(
    Stream<List<SessionHistoryEntry>> Function(
      _SessionHistoryForMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionHistoryForMemberProvider._internal(
        (ref) => create(ref as _SessionHistoryForMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SessionHistoryEntry>> createElement() {
    return _SessionHistoryForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionHistoryForMemberProvider &&
        other.trainerId == trainerId &&
        other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionHistoryForMemberRef
    on AutoDisposeStreamProviderRef<List<SessionHistoryEntry>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;

  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _SessionHistoryForMemberProviderElement
    extends AutoDisposeStreamProviderElement<List<SessionHistoryEntry>>
    with _SessionHistoryForMemberRef {
  _SessionHistoryForMemberProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as _SessionHistoryForMemberProvider).trainerId;
  @override
  String get memberId => (origin as _SessionHistoryForMemberProvider).memberId;
}

String _$waistSeriesForMemberHash() =>
    r'5e4abe22b4606dc34985201d61d745db57778df4';

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
/// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
/// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
///
/// Copied from [_waistSeriesForMember].
@ProviderFor(_waistSeriesForMember)
const _waistSeriesForMemberProvider = _WaistSeriesForMemberFamily();

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
/// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
/// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
///
/// Copied from [_waistSeriesForMember].
class _WaistSeriesForMemberFamily
    extends Family<AsyncValue<TrainerMetricSeries>> {
  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
  /// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
  /// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
  ///
  /// Copied from [_waistSeriesForMember].
  const _WaistSeriesForMemberFamily();

  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
  /// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
  /// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
  ///
  /// Copied from [_waistSeriesForMember].
  _WaistSeriesForMemberProvider call(String memberId) {
    return _WaistSeriesForMemberProvider(memberId);
  }

  @override
  _WaistSeriesForMemberProvider getProviderOverride(
    covariant _WaistSeriesForMemberProvider provider,
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
  String? get name => r'_waistSeriesForMemberProvider';
}

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
/// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
/// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
///
/// Copied from [_waistSeriesForMember].
class _WaistSeriesForMemberProvider
    extends AutoDisposeStreamProvider<TrainerMetricSeries> {
  /// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
  /// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
  /// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
  ///
  /// Copied from [_waistSeriesForMember].
  _WaistSeriesForMemberProvider(String memberId)
    : this._internal(
        (ref) =>
            _waistSeriesForMember(ref as _WaistSeriesForMemberRef, memberId),
        from: _waistSeriesForMemberProvider,
        name: r'_waistSeriesForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$waistSeriesForMemberHash,
        dependencies: _WaistSeriesForMemberFamily._dependencies,
        allTransitiveDependencies:
            _WaistSeriesForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _WaistSeriesForMemberProvider._internal(
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
    Stream<TrainerMetricSeries> Function(_WaistSeriesForMemberRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _WaistSeriesForMemberProvider._internal(
        (ref) => create(ref as _WaistSeriesForMemberRef),
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
  AutoDisposeStreamProviderElement<TrainerMetricSeries> createElement() {
    return _WaistSeriesForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _WaistSeriesForMemberProvider && other.memberId == memberId;
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
mixin _WaistSeriesForMemberRef
    on AutoDisposeStreamProviderRef<TrainerMetricSeries> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _WaistSeriesForMemberProviderElement
    extends AutoDisposeStreamProviderElement<TrainerMetricSeries>
    with _WaistSeriesForMemberRef {
  _WaistSeriesForMemberProviderElement(super.provider);

  @override
  String get memberId => (origin as _WaistSeriesForMemberProvider).memberId;
}

String _$trainerMemberDetailControllerHash() =>
    r'3c9fca327a79aef3e30c1f8b63175a75420c3057';

abstract class _$TrainerMemberDetailController
    extends BuildlessAutoDisposeNotifier<TrainerMemberDetail> {
  late final String memberId;

  TrainerMemberDetail build(String memberId);
}

/// See also [TrainerMemberDetailController].
@ProviderFor(TrainerMemberDetailController)
const trainerMemberDetailControllerProvider =
    TrainerMemberDetailControllerFamily();

/// See also [TrainerMemberDetailController].
class TrainerMemberDetailControllerFamily extends Family<TrainerMemberDetail> {
  /// See also [TrainerMemberDetailController].
  const TrainerMemberDetailControllerFamily();

  /// See also [TrainerMemberDetailController].
  TrainerMemberDetailControllerProvider call(String memberId) {
    return TrainerMemberDetailControllerProvider(memberId);
  }

  @override
  TrainerMemberDetailControllerProvider getProviderOverride(
    covariant TrainerMemberDetailControllerProvider provider,
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
  String? get name => r'trainerMemberDetailControllerProvider';
}

/// See also [TrainerMemberDetailController].
class TrainerMemberDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          TrainerMemberDetailController,
          TrainerMemberDetail
        > {
  /// See also [TrainerMemberDetailController].
  TrainerMemberDetailControllerProvider(String memberId)
    : this._internal(
        () => TrainerMemberDetailController()..memberId = memberId,
        from: trainerMemberDetailControllerProvider,
        name: r'trainerMemberDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerMemberDetailControllerHash,
        dependencies: TrainerMemberDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            TrainerMemberDetailControllerFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  TrainerMemberDetailControllerProvider._internal(
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
  TrainerMemberDetail runNotifierBuild(
    covariant TrainerMemberDetailController notifier,
  ) {
    return notifier.build(memberId);
  }

  @override
  Override overrideWith(TrainerMemberDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: TrainerMemberDetailControllerProvider._internal(
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
    TrainerMemberDetailController,
    TrainerMemberDetail
  >
  createElement() {
    return _TrainerMemberDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainerMemberDetailControllerProvider &&
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
mixin TrainerMemberDetailControllerRef
    on AutoDisposeNotifierProviderRef<TrainerMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _TrainerMemberDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          TrainerMemberDetailController,
          TrainerMemberDetail
        >
    with TrainerMemberDetailControllerRef {
  _TrainerMemberDetailControllerProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as TrainerMemberDetailControllerProvider).memberId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
