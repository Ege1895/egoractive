// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsForTrainerMonthHash() =>
    r'7aea7c130a63243da9f4c699dafa8bb2f25ca4d3';

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

/// See also [_sessionsForTrainerMonth].
@ProviderFor(_sessionsForTrainerMonth)
const _sessionsForTrainerMonthProvider = _SessionsForTrainerMonthFamily();

/// See also [_sessionsForTrainerMonth].
class _SessionsForTrainerMonthFamily
    extends Family<AsyncValue<Map<int, List<ScheduleSlot>>>> {
  /// See also [_sessionsForTrainerMonth].
  const _SessionsForTrainerMonthFamily();

  /// See also [_sessionsForTrainerMonth].
  _SessionsForTrainerMonthProvider call(String trainerId, int year, int month) {
    return _SessionsForTrainerMonthProvider(trainerId, year, month);
  }

  @override
  _SessionsForTrainerMonthProvider getProviderOverride(
    covariant _SessionsForTrainerMonthProvider provider,
  ) {
    return call(provider.trainerId, provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_sessionsForTrainerMonthProvider';
}

/// See also [_sessionsForTrainerMonth].
class _SessionsForTrainerMonthProvider
    extends AutoDisposeStreamProvider<Map<int, List<ScheduleSlot>>> {
  /// See also [_sessionsForTrainerMonth].
  _SessionsForTrainerMonthProvider(String trainerId, int year, int month)
    : this._internal(
        (ref) => _sessionsForTrainerMonth(
          ref as _SessionsForTrainerMonthRef,
          trainerId,
          year,
          month,
        ),
        from: _sessionsForTrainerMonthProvider,
        name: r'_sessionsForTrainerMonthProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionsForTrainerMonthHash,
        dependencies: _SessionsForTrainerMonthFamily._dependencies,
        allTransitiveDependencies:
            _SessionsForTrainerMonthFamily._allTransitiveDependencies,
        trainerId: trainerId,
        year: year,
        month: month,
      );

  _SessionsForTrainerMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trainerId,
    required this.year,
    required this.month,
  }) : super.internal();

  final String trainerId;
  final int year;
  final int month;

  @override
  Override overrideWith(
    Stream<Map<int, List<ScheduleSlot>>> Function(
      _SessionsForTrainerMonthRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionsForTrainerMonthProvider._internal(
        (ref) => create(ref as _SessionsForTrainerMonthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trainerId: trainerId,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<int, List<ScheduleSlot>>>
  createElement() {
    return _SessionsForTrainerMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionsForTrainerMonthProvider &&
        other.trainerId == trainerId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trainerId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionsForTrainerMonthRef
    on AutoDisposeStreamProviderRef<Map<int, List<ScheduleSlot>>> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _SessionsForTrainerMonthProviderElement
    extends AutoDisposeStreamProviderElement<Map<int, List<ScheduleSlot>>>
    with _SessionsForTrainerMonthRef {
  _SessionsForTrainerMonthProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as _SessionsForTrainerMonthProvider).trainerId;
  @override
  int get year => (origin as _SessionsForTrainerMonthProvider).year;
  @override
  int get month => (origin as _SessionsForTrainerMonthProvider).month;
}

String _$selectedTrainerCalendarDateHash() =>
    r'8da2c26dd6392f2a5498b13a54de254a1057e09b';

/// Seçili ay/gün — `AdminCalendarController`'daki aynı desen: `build()`
/// kendi `state`'ini henüz oluşturulmadan okuyamadığı için ayrı bir
/// provider'da tutuluyor.
///
/// Copied from [_SelectedTrainerCalendarDate].
@ProviderFor(_SelectedTrainerCalendarDate)
final _selectedTrainerCalendarDateProvider =
    AutoDisposeNotifierProvider<
      _SelectedTrainerCalendarDate,
      DateTime
    >.internal(
      _SelectedTrainerCalendarDate.new,
      name: r'_selectedTrainerCalendarDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedTrainerCalendarDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedTrainerCalendarDate = AutoDisposeNotifier<DateTime>;
String _$trainerCalendarControllerHash() =>
    r'd1b887bd25324fcf95d1591a76d92d99b99db834';

/// Antrenörün kendi (`trainerId == uid`) seansları gerçek zamanlı dinlenir.
/// Oturum yoksa (test ortamı vb.) mock repository'e düşer.
///
/// Copied from [TrainerCalendarController].
@ProviderFor(TrainerCalendarController)
final trainerCalendarControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerCalendarController,
      TrainerCalendarState
    >.internal(
      TrainerCalendarController.new,
      name: r'trainerCalendarControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerCalendarControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerCalendarController = AutoDisposeNotifier<TrainerCalendarState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
