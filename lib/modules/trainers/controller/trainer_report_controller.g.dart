// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportForTrainerHash() => r'c0b7b60cf2a8b4aad25c422a905ddd3bdd0b95a4';

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

/// See also [reportForTrainer].
@ProviderFor(reportForTrainer)
const reportForTrainerProvider = ReportForTrainerFamily();

/// See also [reportForTrainer].
class ReportForTrainerFamily extends Family<AsyncValue<TrainerReportState>> {
  /// See also [reportForTrainer].
  const ReportForTrainerFamily();

  /// See also [reportForTrainer].
  ReportForTrainerProvider call(String trainerId) {
    return ReportForTrainerProvider(trainerId);
  }

  @override
  ReportForTrainerProvider getProviderOverride(
    covariant ReportForTrainerProvider provider,
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
  String? get name => r'reportForTrainerProvider';
}

/// See also [reportForTrainer].
class ReportForTrainerProvider
    extends AutoDisposeFutureProvider<TrainerReportState> {
  /// See also [reportForTrainer].
  ReportForTrainerProvider(String trainerId)
    : this._internal(
        (ref) => reportForTrainer(ref as ReportForTrainerRef, trainerId),
        from: reportForTrainerProvider,
        name: r'reportForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportForTrainerHash,
        dependencies: ReportForTrainerFamily._dependencies,
        allTransitiveDependencies:
            ReportForTrainerFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  ReportForTrainerProvider._internal(
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
    FutureOr<TrainerReportState> Function(ReportForTrainerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportForTrainerProvider._internal(
        (ref) => create(ref as ReportForTrainerRef),
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
  AutoDisposeFutureProviderElement<TrainerReportState> createElement() {
    return _ReportForTrainerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportForTrainerProvider && other.trainerId == trainerId;
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
mixin ReportForTrainerRef on AutoDisposeFutureProviderRef<TrainerReportState> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _ReportForTrainerProviderElement
    extends AutoDisposeFutureProviderElement<TrainerReportState>
    with ReportForTrainerRef {
  _ReportForTrainerProviderElement(super.provider);

  @override
  String get trainerId => (origin as ReportForTrainerProvider).trainerId;
}

String _$trainerReportControllerHash() =>
    r'c28760fa76c9a74666dd507c4da88bb223a72d50';

/// Antrenörün kendi (`trainerId == uid`) bu ayki seans özeti gerçek zamanlı
/// hesaplanır. Oturum yoksa (test ortamı vb.) mock repository'e düşer.
///
/// Copied from [TrainerReportController].
@ProviderFor(TrainerReportController)
final trainerReportControllerProvider =
    AutoDisposeNotifierProvider<
      TrainerReportController,
      TrainerReportState
    >.internal(
      TrainerReportController.new,
      name: r'trainerReportControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$trainerReportControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TrainerReportController = AutoDisposeNotifier<TrainerReportState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
