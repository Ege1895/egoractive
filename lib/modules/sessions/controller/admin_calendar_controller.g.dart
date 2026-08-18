// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_calendar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsForGymMonthHash() =>
    r'850a49cb56eba26fdb98d90e5dd7cec4e86d2296';

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

/// See also [_sessionsForGymMonth].
@ProviderFor(_sessionsForGymMonth)
const _sessionsForGymMonthProvider = _SessionsForGymMonthFamily();

/// See also [_sessionsForGymMonth].
class _SessionsForGymMonthFamily
    extends Family<AsyncValue<Map<int, List<AdminSessionSlot>>>> {
  /// See also [_sessionsForGymMonth].
  const _SessionsForGymMonthFamily();

  /// See also [_sessionsForGymMonth].
  _SessionsForGymMonthProvider call(String gymId, int year, int month) {
    return _SessionsForGymMonthProvider(gymId, year, month);
  }

  @override
  _SessionsForGymMonthProvider getProviderOverride(
    covariant _SessionsForGymMonthProvider provider,
  ) {
    return call(provider.gymId, provider.year, provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_sessionsForGymMonthProvider';
}

/// See also [_sessionsForGymMonth].
class _SessionsForGymMonthProvider
    extends AutoDisposeStreamProvider<Map<int, List<AdminSessionSlot>>> {
  /// See also [_sessionsForGymMonth].
  _SessionsForGymMonthProvider(String gymId, int year, int month)
    : this._internal(
        (ref) => _sessionsForGymMonth(
          ref as _SessionsForGymMonthRef,
          gymId,
          year,
          month,
        ),
        from: _sessionsForGymMonthProvider,
        name: r'_sessionsForGymMonthProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionsForGymMonthHash,
        dependencies: _SessionsForGymMonthFamily._dependencies,
        allTransitiveDependencies:
            _SessionsForGymMonthFamily._allTransitiveDependencies,
        gymId: gymId,
        year: year,
        month: month,
      );

  _SessionsForGymMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
    required this.year,
    required this.month,
  }) : super.internal();

  final String gymId;
  final int year;
  final int month;

  @override
  Override overrideWith(
    Stream<Map<int, List<AdminSessionSlot>>> Function(
      _SessionsForGymMonthRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionsForGymMonthProvider._internal(
        (ref) => create(ref as _SessionsForGymMonthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
        year: year,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Map<int, List<AdminSessionSlot>>>
  createElement() {
    return _SessionsForGymMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionsForGymMonthProvider &&
        other.gymId == gymId &&
        other.year == year &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionsForGymMonthRef
    on AutoDisposeStreamProviderRef<Map<int, List<AdminSessionSlot>>> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;
}

class _SessionsForGymMonthProviderElement
    extends AutoDisposeStreamProviderElement<Map<int, List<AdminSessionSlot>>>
    with _SessionsForGymMonthRef {
  _SessionsForGymMonthProviderElement(super.provider);

  @override
  String get gymId => (origin as _SessionsForGymMonthProvider).gymId;
  @override
  int get year => (origin as _SessionsForGymMonthProvider).year;
  @override
  int get month => (origin as _SessionsForGymMonthProvider).month;
}

String _$selectedCalendarDateHash() =>
    r'4e4f571021d3293cbcfea154b4e754841e8a2eda';

/// Seçili ay/gün — [AdminCalendarController]'ın `state`'inden ayrı bir
/// provider'da tutuluyor çünkü Notifier'ın `build()` metodu kendi
/// `state`'ini henüz oluşturulmadan okuyamıyor.
///
/// Copied from [_SelectedCalendarDate].
@ProviderFor(_SelectedCalendarDate)
final _selectedCalendarDateProvider =
    AutoDisposeNotifierProvider<_SelectedCalendarDate, DateTime>.internal(
      _SelectedCalendarDate.new,
      name: r'_selectedCalendarDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedCalendarDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedCalendarDate = AutoDisposeNotifier<DateTime>;
String _$adminCalendarControllerHash() =>
    r'53f6fced34cc4546c1f41cb378e44d5044ac3734';

/// F3-3 — aktif salonun bulunduğu aya ait seansları gerçek zamanlı
/// dinler. Salon bilinmiyorsa (test ortamı vb.) mock repository'e düşer.
///
/// Copied from [AdminCalendarController].
@ProviderFor(AdminCalendarController)
final adminCalendarControllerProvider =
    AutoDisposeNotifierProvider<
      AdminCalendarController,
      AdminCalendarState
    >.internal(
      AdminCalendarController.new,
      name: r'adminCalendarControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminCalendarControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminCalendarController = AutoDisposeNotifier<AdminCalendarState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
