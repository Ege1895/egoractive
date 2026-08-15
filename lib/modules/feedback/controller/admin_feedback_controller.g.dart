// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedbackForGymHash() => r'e442bb8ccd1d845b453ef5a6a5fe68997c2f8f0b';

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

/// See also [_feedbackForGym].
@ProviderFor(_feedbackForGym)
const _feedbackForGymProvider = _FeedbackForGymFamily();

/// See also [_feedbackForGym].
class _FeedbackForGymFamily extends Family<AsyncValue<AdminFeedbackSummary>> {
  /// See also [_feedbackForGym].
  const _FeedbackForGymFamily();

  /// See also [_feedbackForGym].
  _FeedbackForGymProvider call(String gymId) {
    return _FeedbackForGymProvider(gymId);
  }

  @override
  _FeedbackForGymProvider getProviderOverride(
    covariant _FeedbackForGymProvider provider,
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
  String? get name => r'_feedbackForGymProvider';
}

/// See also [_feedbackForGym].
class _FeedbackForGymProvider
    extends AutoDisposeStreamProvider<AdminFeedbackSummary> {
  /// See also [_feedbackForGym].
  _FeedbackForGymProvider(String gymId)
    : this._internal(
        (ref) => _feedbackForGym(ref as _FeedbackForGymRef, gymId),
        from: _feedbackForGymProvider,
        name: r'_feedbackForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedbackForGymHash,
        dependencies: _FeedbackForGymFamily._dependencies,
        allTransitiveDependencies:
            _FeedbackForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _FeedbackForGymProvider._internal(
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
    Stream<AdminFeedbackSummary> Function(_FeedbackForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _FeedbackForGymProvider._internal(
        (ref) => create(ref as _FeedbackForGymRef),
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
  AutoDisposeStreamProviderElement<AdminFeedbackSummary> createElement() {
    return _FeedbackForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _FeedbackForGymProvider && other.gymId == gymId;
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
mixin _FeedbackForGymRef on AutoDisposeStreamProviderRef<AdminFeedbackSummary> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _FeedbackForGymProviderElement
    extends AutoDisposeStreamProviderElement<AdminFeedbackSummary>
    with _FeedbackForGymRef {
  _FeedbackForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _FeedbackForGymProvider).gymId;
}

String _$adminFeedbackControllerHash() =>
    r'ae6b0032221805560ad54a78be045958c7cf2338';

/// See also [AdminFeedbackController].
@ProviderFor(AdminFeedbackController)
final adminFeedbackControllerProvider =
    AutoDisposeNotifierProvider<
      AdminFeedbackController,
      AdminFeedbackSummary
    >.internal(
      AdminFeedbackController.new,
      name: r'adminFeedbackControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminFeedbackControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminFeedbackController = AutoDisposeNotifier<AdminFeedbackSummary>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
