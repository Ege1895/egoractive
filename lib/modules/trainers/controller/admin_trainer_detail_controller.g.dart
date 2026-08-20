// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_trainer_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminTrainerDetailStatsHash() =>
    r'0f11538abe253d7f11755e519ca3396baa8894ab';

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

/// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
/// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
/// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
/// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
/// kapsar.
///
/// Copied from [adminTrainerDetailStats].
@ProviderFor(adminTrainerDetailStats)
const adminTrainerDetailStatsProvider = AdminTrainerDetailStatsFamily();

/// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
/// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
/// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
/// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
/// kapsar.
///
/// Copied from [adminTrainerDetailStats].
class AdminTrainerDetailStatsFamily
    extends Family<AsyncValue<AdminTrainerDetailStats>> {
  /// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
  /// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
  /// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
  /// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
  /// kapsar.
  ///
  /// Copied from [adminTrainerDetailStats].
  const AdminTrainerDetailStatsFamily();

  /// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
  /// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
  /// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
  /// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
  /// kapsar.
  ///
  /// Copied from [adminTrainerDetailStats].
  AdminTrainerDetailStatsProvider call(String trainerId) {
    return AdminTrainerDetailStatsProvider(trainerId);
  }

  @override
  AdminTrainerDetailStatsProvider getProviderOverride(
    covariant AdminTrainerDetailStatsProvider provider,
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
  String? get name => r'adminTrainerDetailStatsProvider';
}

/// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
/// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
/// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
/// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
/// kapsar.
///
/// Copied from [adminTrainerDetailStats].
class AdminTrainerDetailStatsProvider
    extends AutoDisposeStreamProvider<AdminTrainerDetailStats> {
  /// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
  /// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
  /// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
  /// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
  /// kapsar.
  ///
  /// Copied from [adminTrainerDetailStats].
  AdminTrainerDetailStatsProvider(String trainerId)
    : this._internal(
        (ref) => adminTrainerDetailStats(
          ref as AdminTrainerDetailStatsRef,
          trainerId,
        ),
        from: adminTrainerDetailStatsProvider,
        name: r'adminTrainerDetailStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminTrainerDetailStatsHash,
        dependencies: AdminTrainerDetailStatsFamily._dependencies,
        allTransitiveDependencies:
            AdminTrainerDetailStatsFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  AdminTrainerDetailStatsProvider._internal(
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
    Stream<AdminTrainerDetailStats> Function(
      AdminTrainerDetailStatsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdminTrainerDetailStatsProvider._internal(
        (ref) => create(ref as AdminTrainerDetailStatsRef),
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
  AutoDisposeStreamProviderElement<AdminTrainerDetailStats> createElement() {
    return _AdminTrainerDetailStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminTrainerDetailStatsProvider &&
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
mixin AdminTrainerDetailStatsRef
    on AutoDisposeStreamProviderRef<AdminTrainerDetailStats> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _AdminTrainerDetailStatsProviderElement
    extends AutoDisposeStreamProviderElement<AdminTrainerDetailStats>
    with AdminTrainerDetailStatsRef {
  _AdminTrainerDetailStatsProviderElement(super.provider);

  @override
  String get trainerId => (origin as AdminTrainerDetailStatsProvider).trainerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
