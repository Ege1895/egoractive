// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurements_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$measurementEntriesHash() =>
    r'1e3d247708e62f4305a5197d56fab521be53ae36';

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

/// See also [_measurementEntries].
@ProviderFor(_measurementEntries)
const _measurementEntriesProvider = _MeasurementEntriesFamily();

/// See also [_measurementEntries].
class _MeasurementEntriesFamily extends Family<AsyncValue<List<_Entry>>> {
  /// See also [_measurementEntries].
  const _MeasurementEntriesFamily();

  /// See also [_measurementEntries].
  _MeasurementEntriesProvider call(String uid) {
    return _MeasurementEntriesProvider(uid);
  }

  @override
  _MeasurementEntriesProvider getProviderOverride(
    covariant _MeasurementEntriesProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_measurementEntriesProvider';
}

/// See also [_measurementEntries].
class _MeasurementEntriesProvider
    extends AutoDisposeStreamProvider<List<_Entry>> {
  /// See also [_measurementEntries].
  _MeasurementEntriesProvider(String uid)
    : this._internal(
        (ref) => _measurementEntries(ref as _MeasurementEntriesRef, uid),
        from: _measurementEntriesProvider,
        name: r'_measurementEntriesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$measurementEntriesHash,
        dependencies: _MeasurementEntriesFamily._dependencies,
        allTransitiveDependencies:
            _MeasurementEntriesFamily._allTransitiveDependencies,
        uid: uid,
      );

  _MeasurementEntriesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<List<_Entry>> Function(_MeasurementEntriesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _MeasurementEntriesProvider._internal(
        (ref) => create(ref as _MeasurementEntriesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<_Entry>> createElement() {
    return _MeasurementEntriesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _MeasurementEntriesProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _MeasurementEntriesRef on AutoDisposeStreamProviderRef<List<_Entry>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _MeasurementEntriesProviderElement
    extends AutoDisposeStreamProviderElement<List<_Entry>>
    with _MeasurementEntriesRef {
  _MeasurementEntriesProviderElement(super.provider);

  @override
  String get uid => (origin as _MeasurementEntriesProvider).uid;
}

String _$measurementsViewedUidHash() =>
    r'35665840f2af82804a3945ba3ef6ac4fe69e152d';

/// F4-1 — admin/antrenör bir üyenin ölçüm ekranını açtığında bu sağlanır;
/// `MeasurementsController` bunu kendi uid'sinin önüne alır. Panel
/// kapanınca (onPanelHide) tekrar null'a dönüp üyenin kendi görünümünü
/// bozmadan bırakır.
///
/// Copied from [MeasurementsViewedUid].
@ProviderFor(MeasurementsViewedUid)
final measurementsViewedUidProvider =
    AutoDisposeNotifierProvider<MeasurementsViewedUid, String?>.internal(
      MeasurementsViewedUid.new,
      name: r'measurementsViewedUidProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$measurementsViewedUidHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MeasurementsViewedUid = AutoDisposeNotifier<String?>;
String _$measurementsSelectedDateHash() =>
    r'6cad12b8168922575626494d99830d0fef577749';

/// F4-1 — görüntülenen kişinin (kendisi ya da admin/antrenörün açtığı bir
/// üye) ölçümleri gerçek zamanlı `measurements/{uid}/entries` alt
/// koleksiyonundan okunur. Hiç ölçüm yoksa (yeni üye) mock veriye düşülür
/// — boş bir avatar/grafik göstermek yerine örnek bir başlangıç durumu
/// sunar.
///
/// Copied from [_MeasurementsSelectedDate].
@ProviderFor(_MeasurementsSelectedDate)
final _measurementsSelectedDateProvider =
    AutoDisposeNotifierProvider<_MeasurementsSelectedDate, DateTime?>.internal(
      _MeasurementsSelectedDate.new,
      name: r'_measurementsSelectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$measurementsSelectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MeasurementsSelectedDate = AutoDisposeNotifier<DateTime?>;
String _$measurementsControllerHash() =>
    r'f7436b219669f48b5f1965e797a09d848d6db80d';

/// See also [MeasurementsController].
@ProviderFor(MeasurementsController)
final measurementsControllerProvider =
    AutoDisposeNotifierProvider<
      MeasurementsController,
      MeasurementsState
    >.internal(
      MeasurementsController.new,
      name: r'measurementsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$measurementsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MeasurementsController = AutoDisposeNotifier<MeasurementsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
