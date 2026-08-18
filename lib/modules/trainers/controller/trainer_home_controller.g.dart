// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayScheduleForTrainerHash() =>
    r'10c7732981a9afdaf2885ce65bff5d53da733a4c';

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

/// See also [_todayScheduleForTrainer].
@ProviderFor(_todayScheduleForTrainer)
const _todayScheduleForTrainerProvider = _TodayScheduleForTrainerFamily();

/// See also [_todayScheduleForTrainer].
class _TodayScheduleForTrainerFamily
    extends Family<AsyncValue<List<ScheduleSlot>>> {
  /// See also [_todayScheduleForTrainer].
  const _TodayScheduleForTrainerFamily();

  /// See also [_todayScheduleForTrainer].
  _TodayScheduleForTrainerProvider call(String trainerId) {
    return _TodayScheduleForTrainerProvider(trainerId);
  }

  @override
  _TodayScheduleForTrainerProvider getProviderOverride(
    covariant _TodayScheduleForTrainerProvider provider,
  ) {
    return call(provider.trainerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_todayScheduleForTrainerProvider';
}

/// See also [_todayScheduleForTrainer].
class _TodayScheduleForTrainerProvider
    extends AutoDisposeStreamProvider<List<ScheduleSlot>> {
  /// See also [_todayScheduleForTrainer].
  _TodayScheduleForTrainerProvider(String trainerId)
    : this._internal(
        (ref) => _todayScheduleForTrainer(
          ref as _TodayScheduleForTrainerRef,
          trainerId,
        ),
        from: _todayScheduleForTrainerProvider,
        name: r'_todayScheduleForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$todayScheduleForTrainerHash,
        dependencies: _TodayScheduleForTrainerFamily._dependencies,
        allTransitiveDependencies:
            _TodayScheduleForTrainerFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  _TodayScheduleForTrainerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
  }) : super.internal();

  final String trainerId;

  @override
  Override overrideWith(
    Stream<List<ScheduleSlot>> Function(_TodayScheduleForTrainerRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _TodayScheduleForTrainerProvider._internal(
        (ref) => create(ref as _TodayScheduleForTrainerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ScheduleSlot>> createElement() {
    return _TodayScheduleForTrainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _TodayScheduleForTrainerProvider &&
        other.trainerId == trainerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _TodayScheduleForTrainerRef
    on AutoDisposeStreamProviderRef<List<ScheduleSlot>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _TodayScheduleForTrainerProviderElement
    extends AutoDisposeStreamProviderElement<List<ScheduleSlot>>
    with _TodayScheduleForTrainerRef {
  _TodayScheduleForTrainerProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as _TodayScheduleForTrainerProvider).trainerId;
}

String _$pendingConfirmationsForTrainerHash() =>
    r'8425335c7bd4b595ca0e1737a6056ae29cfb5792';

/// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
/// `planned` kalan seanslar. Her biri için üyenin güncel
/// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
/// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
/// ek okuma kabul edilebilir.
///
/// Copied from [_pendingConfirmationsForTrainer].
@ProviderFor(_pendingConfirmationsForTrainer)
const _pendingConfirmationsForTrainerProvider =
    _PendingConfirmationsForTrainerFamily();

/// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
/// `planned` kalan seanslar. Her biri için üyenin güncel
/// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
/// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
/// ek okuma kabul edilebilir.
///
/// Copied from [_pendingConfirmationsForTrainer].
class _PendingConfirmationsForTrainerFamily
    extends Family<AsyncValue<List<PendingConfirmation>>> {
  /// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
  /// `planned` kalan seanslar. Her biri için üyenin güncel
  /// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
  /// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
  /// ek okuma kabul edilebilir.
  ///
  /// Copied from [_pendingConfirmationsForTrainer].
  const _PendingConfirmationsForTrainerFamily();

  /// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
  /// `planned` kalan seanslar. Her biri için üyenin güncel
  /// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
  /// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
  /// ek okuma kabul edilebilir.
  ///
  /// Copied from [_pendingConfirmationsForTrainer].
  _PendingConfirmationsForTrainerProvider call(String trainerId) {
    return _PendingConfirmationsForTrainerProvider(trainerId);
  }

  @override
  _PendingConfirmationsForTrainerProvider getProviderOverride(
    covariant _PendingConfirmationsForTrainerProvider provider,
  ) {
    return call(provider.trainerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_pendingConfirmationsForTrainerProvider';
}

/// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
/// `planned` kalan seanslar. Her biri için üyenin güncel
/// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
/// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
/// ek okuma kabul edilebilir.
///
/// Copied from [_pendingConfirmationsForTrainer].
class _PendingConfirmationsForTrainerProvider
    extends AutoDisposeStreamProvider<List<PendingConfirmation>> {
  /// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
  /// `planned` kalan seanslar. Her biri için üyenin güncel
  /// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
  /// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
  /// ek okuma kabul edilebilir.
  ///
  /// Copied from [_pendingConfirmationsForTrainer].
  _PendingConfirmationsForTrainerProvider(String trainerId)
    : this._internal(
        (ref) => _pendingConfirmationsForTrainer(
          ref as _PendingConfirmationsForTrainerRef,
          trainerId,
        ),
        from: _pendingConfirmationsForTrainerProvider,
        name: r'_pendingConfirmationsForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pendingConfirmationsForTrainerHash,
        dependencies: _PendingConfirmationsForTrainerFamily._dependencies,
        allTransitiveDependencies:
            _PendingConfirmationsForTrainerFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  _PendingConfirmationsForTrainerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
  }) : super.internal();

  final String trainerId;

  @override
  Override overrideWith(
    Stream<List<PendingConfirmation>> Function(
      _PendingConfirmationsForTrainerRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _PendingConfirmationsForTrainerProvider._internal(
        (ref) => create(ref as _PendingConfirmationsForTrainerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PendingConfirmation>> createElement() {
    return _PendingConfirmationsForTrainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _PendingConfirmationsForTrainerProvider &&
        other.trainerId == trainerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _PendingConfirmationsForTrainerRef
    on AutoDisposeStreamProviderRef<List<PendingConfirmation>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _PendingConfirmationsForTrainerProviderElement
    extends AutoDisposeStreamProviderElement<List<PendingConfirmation>>
    with _PendingConfirmationsForTrainerRef {
  _PendingConfirmationsForTrainerProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as _PendingConfirmationsForTrainerProvider).trainerId;
}

String _$trainerHomeControllerHash() =>
    r'70e9d4a59f95911e2d82d407f11b508becdd2bbb';

/// F3-3/F3-5 — antrenörün "Bugünkü program"ı ve onay bekleyen seansları
/// gerçek zamanlı `sessions` koleksiyonundan (trainerId == kendi uid'si)
/// okunur. `freeSlotCount` boş bırakılıyor — stüdyo çalışma saatleri/
/// kapasite kavramı henüz tanımlı değil, bu yüzden 0 dönüyor (mock'taki
/// keyfi sayı yerine).
///
/// Copied from [TrainerHomeController].
@ProviderFor(TrainerHomeController)
final trainerHomeControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerHomeController,
      TrainerHomeState
    >.internal(
      TrainerHomeController.new,
      name: r'trainerHomeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerHomeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerHomeController = AutoDisposeNotifier<TrainerHomeState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
