// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_activity_breakdown_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trainerActivityBreakdownHash() =>
    r'a2c0b3c8514187abd4d81336198d77d7a51851d4';

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

/// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
/// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
/// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
/// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
/// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
/// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
/// göstermeli.
///
/// Copied from [trainerActivityBreakdown].
@ProviderFor(trainerActivityBreakdown)
const trainerActivityBreakdownProvider = TrainerActivityBreakdownFamily();

/// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
/// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
/// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
/// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
/// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
/// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
/// göstermeli.
///
/// Copied from [trainerActivityBreakdown].
class TrainerActivityBreakdownFamily
    extends Family<AsyncValue<TrainerActivityBreakdown>> {
  /// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
  /// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
  /// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
  /// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
  /// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
  /// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
  /// göstermeli.
  ///
  /// Copied from [trainerActivityBreakdown].
  const TrainerActivityBreakdownFamily();

  /// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
  /// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
  /// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
  /// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
  /// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
  /// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
  /// göstermeli.
  ///
  /// Copied from [trainerActivityBreakdown].
  TrainerActivityBreakdownProvider call(String trainerId) {
    return TrainerActivityBreakdownProvider(trainerId);
  }

  @override
  TrainerActivityBreakdownProvider getProviderOverride(
    covariant TrainerActivityBreakdownProvider provider,
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
  String? get name => r'trainerActivityBreakdownProvider';
}

/// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
/// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
/// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
/// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
/// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
/// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
/// göstermeli.
///
/// Copied from [trainerActivityBreakdown].
class TrainerActivityBreakdownProvider
    extends AutoDisposeFutureProvider<TrainerActivityBreakdown> {
  /// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
  /// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
  /// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
  /// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
  /// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
  /// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
  /// göstermeli.
  ///
  /// Copied from [trainerActivityBreakdown].
  TrainerActivityBreakdownProvider(String trainerId)
    : this._internal(
        (ref) => trainerActivityBreakdown(
          ref as TrainerActivityBreakdownRef,
          trainerId,
        ),
        from: trainerActivityBreakdownProvider,
        name: r'trainerActivityBreakdownProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$trainerActivityBreakdownHash,
        dependencies: TrainerActivityBreakdownFamily._dependencies,
        allTransitiveDependencies:
            TrainerActivityBreakdownFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  TrainerActivityBreakdownProvider._internal(
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
    FutureOr<TrainerActivityBreakdown> Function(
      TrainerActivityBreakdownRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TrainerActivityBreakdownProvider._internal(
        (ref) => create(ref as TrainerActivityBreakdownRef),
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
  AutoDisposeFutureProviderElement<TrainerActivityBreakdown> createElement() {
    return _TrainerActivityBreakdownProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TrainerActivityBreakdownProvider &&
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
mixin TrainerActivityBreakdownRef
    on AutoDisposeFutureProviderRef<TrainerActivityBreakdown> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _TrainerActivityBreakdownProviderElement
    extends AutoDisposeFutureProviderElement<TrainerActivityBreakdown>
    with TrainerActivityBreakdownRef {
  _TrainerActivityBreakdownProviderElement(super.provider);

  @override
  String get trainerId =>
      (origin as TrainerActivityBreakdownProvider).trainerId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
