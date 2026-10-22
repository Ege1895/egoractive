// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_recipients_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recipientsForGymHash() => r'd00725f2b122383a38bdaa538bf6dee68c12871a';

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

/// See also [_recipientsForGym].
@ProviderFor(_recipientsForGym)
const _recipientsForGymProvider = _RecipientsForGymFamily();

/// See also [_recipientsForGym].
class _RecipientsForGymFamily extends Family<AsyncValue<ReportRecipients>> {
  /// See also [_recipientsForGym].
  const _RecipientsForGymFamily();

  /// See also [_recipientsForGym].
  _RecipientsForGymProvider call(String gymId) {
    return _RecipientsForGymProvider(gymId);
  }

  @override
  _RecipientsForGymProvider getProviderOverride(
    covariant _RecipientsForGymProvider provider,
  ) {
    return call(provider.gymId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_recipientsForGymProvider';
}

/// See also [_recipientsForGym].
class _RecipientsForGymProvider
    extends AutoDisposeStreamProvider<ReportRecipients> {
  /// See also [_recipientsForGym].
  _RecipientsForGymProvider(String gymId)
    : this._internal(
        (ref) => _recipientsForGym(ref as _RecipientsForGymRef, gymId),
        from: _recipientsForGymProvider,
        name: r'_recipientsForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recipientsForGymHash,
        dependencies: _RecipientsForGymFamily._dependencies,
        allTransitiveDependencies:
            _RecipientsForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _RecipientsForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
  }) : super.internal();

  final String gymId;

  @override
  Override overrideWith(
    Stream<ReportRecipients> Function(_RecipientsForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _RecipientsForGymProvider._internal(
        (ref) => create(ref as _RecipientsForGymRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gymId: gymId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ReportRecipients> createElement() {
    return _RecipientsForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _RecipientsForGymProvider && other.gymId == gymId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _RecipientsForGymRef on AutoDisposeStreamProviderRef<ReportRecipients> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _RecipientsForGymProviderElement
    extends AutoDisposeStreamProviderElement<ReportRecipients>
    with _RecipientsForGymRef {
  _RecipientsForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _RecipientsForGymProvider).gymId;
}

String _$reportRecipientsControllerHash() =>
    r'1388458404bc068d07260ca158c27576add1da7c';

/// F5-2/F5-15 — haftalık/aylık salon raporunun gönderileceği e-posta.
///
/// Copied from [ReportRecipientsController].
@ProviderFor(ReportRecipientsController)
final reportRecipientsControllerProvider =
    AutoDisposeNotifierProvider<
      ReportRecipientsController,
      ReportRecipients
    >.internal(
      ReportRecipientsController.new,
      name: r'reportRecipientsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reportRecipientsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReportRecipientsController = AutoDisposeNotifier<ReportRecipients>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
