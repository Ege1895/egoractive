// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weekActivityForMemberHash() =>
    r'3b76a6d6f252e82541d8d490e711578d5f145443';

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

/// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
/// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
/// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
/// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
///
/// Copied from [_weekActivityForMember].
@ProviderFor(_weekActivityForMember)
const _weekActivityForMemberProvider = _WeekActivityForMemberFamily();

/// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
/// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
/// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
/// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
///
/// Copied from [_weekActivityForMember].
class _WeekActivityForMemberFamily
    extends Family<AsyncValue<List<WeekActivityDay>>> {
  /// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
  /// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
  /// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
  /// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
  ///
  /// Copied from [_weekActivityForMember].
  const _WeekActivityForMemberFamily();

  /// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
  /// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
  /// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
  /// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
  ///
  /// Copied from [_weekActivityForMember].
  _WeekActivityForMemberProvider call(String memberId) {
    return _WeekActivityForMemberProvider(memberId);
  }

  @override
  _WeekActivityForMemberProvider getProviderOverride(
    covariant _WeekActivityForMemberProvider provider,
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
  String? get name => r'_weekActivityForMemberProvider';
}

/// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
/// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
/// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
/// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
///
/// Copied from [_weekActivityForMember].
class _WeekActivityForMemberProvider
    extends AutoDisposeStreamProvider<List<WeekActivityDay>> {
  /// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
  /// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
  /// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
  /// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
  ///
  /// Copied from [_weekActivityForMember].
  _WeekActivityForMemberProvider(String memberId)
    : this._internal(
        (ref) =>
            _weekActivityForMember(ref as _WeekActivityForMemberRef, memberId),
        from: _weekActivityForMemberProvider,
        name: r'_weekActivityForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekActivityForMemberHash,
        dependencies: _WeekActivityForMemberFamily._dependencies,
        allTransitiveDependencies:
            _WeekActivityForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _WeekActivityForMemberProvider._internal(
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
    Stream<List<WeekActivityDay>> Function(_WeekActivityForMemberRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _WeekActivityForMemberProvider._internal(
        (ref) => create(ref as _WeekActivityForMemberRef),
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
  AutoDisposeStreamProviderElement<List<WeekActivityDay>> createElement() {
    return _WeekActivityForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _WeekActivityForMemberProvider &&
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
mixin _WeekActivityForMemberRef
    on AutoDisposeStreamProviderRef<List<WeekActivityDay>> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _WeekActivityForMemberProviderElement
    extends AutoDisposeStreamProviderElement<List<WeekActivityDay>>
    with _WeekActivityForMemberRef {
  _WeekActivityForMemberProviderElement(super.provider);

  @override
  String get memberId => (origin as _WeekActivityForMemberProvider).memberId;
}

String _$canConfirmAttendanceForMemberHash() =>
    r'e9959395707f1273571daaeff9dfc4222e0fad6d';

/// See also [_canConfirmAttendanceForMember].
@ProviderFor(_canConfirmAttendanceForMember)
const _canConfirmAttendanceForMemberProvider =
    _CanConfirmAttendanceForMemberFamily();

/// See also [_canConfirmAttendanceForMember].
class _CanConfirmAttendanceForMemberFamily extends Family<AsyncValue<bool>> {
  /// See also [_canConfirmAttendanceForMember].
  const _CanConfirmAttendanceForMemberFamily();

  /// See also [_canConfirmAttendanceForMember].
  _CanConfirmAttendanceForMemberProvider call(String memberId) {
    return _CanConfirmAttendanceForMemberProvider(memberId);
  }

  @override
  _CanConfirmAttendanceForMemberProvider getProviderOverride(
    covariant _CanConfirmAttendanceForMemberProvider provider,
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
  String? get name => r'_canConfirmAttendanceForMemberProvider';
}

/// See also [_canConfirmAttendanceForMember].
class _CanConfirmAttendanceForMemberProvider
    extends AutoDisposeStreamProvider<bool> {
  /// See also [_canConfirmAttendanceForMember].
  _CanConfirmAttendanceForMemberProvider(String memberId)
    : this._internal(
        (ref) => _canConfirmAttendanceForMember(
          ref as _CanConfirmAttendanceForMemberRef,
          memberId,
        ),
        from: _canConfirmAttendanceForMemberProvider,
        name: r'_canConfirmAttendanceForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$canConfirmAttendanceForMemberHash,
        dependencies: _CanConfirmAttendanceForMemberFamily._dependencies,
        allTransitiveDependencies:
            _CanConfirmAttendanceForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _CanConfirmAttendanceForMemberProvider._internal(
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
    Stream<bool> Function(_CanConfirmAttendanceForMemberRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _CanConfirmAttendanceForMemberProvider._internal(
        (ref) => create(ref as _CanConfirmAttendanceForMemberRef),
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
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _CanConfirmAttendanceForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _CanConfirmAttendanceForMemberProvider &&
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
mixin _CanConfirmAttendanceForMemberRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _CanConfirmAttendanceForMemberProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with _CanConfirmAttendanceForMemberRef {
  _CanConfirmAttendanceForMemberProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as _CanConfirmAttendanceForMemberProvider).memberId;
}

String _$sessionsForMemberHash() => r'b6a6874c2ffc1ae24384c390e14747c2ddba81cc';

/// See also [_sessionsForMember].
@ProviderFor(_sessionsForMember)
const _sessionsForMemberProvider = _SessionsForMemberFamily();

/// See also [_sessionsForMember].
class _SessionsForMemberFamily
    extends Family<AsyncValue<(List<Session>, List<Session>)>> {
  /// See also [_sessionsForMember].
  const _SessionsForMemberFamily();

  /// See also [_sessionsForMember].
  _SessionsForMemberProvider call(String memberId) {
    return _SessionsForMemberProvider(memberId);
  }

  @override
  _SessionsForMemberProvider getProviderOverride(
    covariant _SessionsForMemberProvider provider,
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
  String? get name => r'_sessionsForMemberProvider';
}

/// See also [_sessionsForMember].
class _SessionsForMemberProvider
    extends AutoDisposeStreamProvider<(List<Session>, List<Session>)> {
  /// See also [_sessionsForMember].
  _SessionsForMemberProvider(String memberId)
    : this._internal(
        (ref) => _sessionsForMember(ref as _SessionsForMemberRef, memberId),
        from: _sessionsForMemberProvider,
        name: r'_sessionsForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionsForMemberHash,
        dependencies: _SessionsForMemberFamily._dependencies,
        allTransitiveDependencies:
            _SessionsForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _SessionsForMemberProvider._internal(
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
    Stream<(List<Session>, List<Session>)> Function(
      _SessionsForMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionsForMemberProvider._internal(
        (ref) => create(ref as _SessionsForMemberRef),
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
  AutoDisposeStreamProviderElement<(List<Session>, List<Session>)>
  createElement() {
    return _SessionsForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionsForMemberProvider && other.memberId == memberId;
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
mixin _SessionsForMemberRef
    on AutoDisposeStreamProviderRef<(List<Session>, List<Session>)> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _SessionsForMemberProviderElement
    extends AutoDisposeStreamProviderElement<(List<Session>, List<Session>)>
    with _SessionsForMemberRef {
  _SessionsForMemberProviderElement(super.provider);

  @override
  String get memberId => (origin as _SessionsForMemberProvider).memberId;
}

String _$sessionsControllerHash() =>
    r'08d3301ee1b306a3ae97d8e835334c44c1a86927';

/// F3-3 — üyenin kendi seansları gerçek zamanlı `sessions` koleksiyonundan
/// (memberId == kendi uid'si) okunur. `paymentWarning` hâlâ ayrı, devam eden
/// bir mock alan (bu task'ın kapsamı dışında).
///
/// F3-4 — `attendanceAnswer` artık ayrı bir yerel state değil, sıradaki
/// seansın Firestore'daki `memberConfirmation` alanından türetiliyor.
///
/// Copied from [SessionsController].
@ProviderFor(SessionsController)
final sessionsControllerProvider =
    AutoDisposeNotifierProvider<SessionsController, SessionsState>.internal(
      SessionsController.new,
      name: r'sessionsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionsController = AutoDisposeNotifier<SessionsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
