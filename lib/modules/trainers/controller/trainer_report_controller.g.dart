// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportForTrainerHash() => r'e34f0d8c5560136434340993a8001f5336a5bcc4';

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

/// See also [_reportForTrainer].
@ProviderFor(_reportForTrainer)
const _reportForTrainerProvider = _ReportForTrainerFamily();

/// See also [_reportForTrainer].
class _ReportForTrainerFamily extends Family<AsyncValue<TrainerReportState>> {
  /// See also [_reportForTrainer].
  const _ReportForTrainerFamily();

  /// See also [_reportForTrainer].
  _ReportForTrainerProvider call(String trainerId) {
    return _ReportForTrainerProvider(trainerId);
  }

  @override
  _ReportForTrainerProvider getProviderOverride(
    covariant _ReportForTrainerProvider provider,
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
  String? get name => r'_reportForTrainerProvider';
}

/// See also [_reportForTrainer].
class _ReportForTrainerProvider
    extends AutoDisposeFutureProvider<TrainerReportState> {
  /// See also [_reportForTrainer].
  _ReportForTrainerProvider(String trainerId)
    : this._internal(
        (ref) => _reportForTrainer(ref as _ReportForTrainerRef, trainerId),
        from: _reportForTrainerProvider,
        name: r'_reportForTrainerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reportForTrainerHash,
        dependencies: _ReportForTrainerFamily._dependencies,
        allTransitiveDependencies:
            _ReportForTrainerFamily._allTransitiveDependencies,
        trainerId: trainerId,
      );

  _ReportForTrainerProvider._internal(
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
    FutureOr<TrainerReportState> Function(_ReportForTrainerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ReportForTrainerProvider._internal(
        (ref) => create(ref as _ReportForTrainerRef),
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
    return other is _ReportForTrainerProvider && other.trainerId == trainerId;
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
mixin _ReportForTrainerRef on AutoDisposeFutureProviderRef<TrainerReportState> {
  /// The parameter `trainerId` of this provider.
  String get trainerId;
}

class _ReportForTrainerProviderElement
    extends AutoDisposeFutureProviderElement<TrainerReportState>
    with _ReportForTrainerRef {
  _ReportForTrainerProviderElement(super.provider);

  @override
  String get trainerId => (origin as _ReportForTrainerProvider).trainerId;
}

String _$trainerReportControllerHash() =>
    r'd2f84d27082263aae199c3411415836df393cae5';

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
