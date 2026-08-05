// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionsForMemberHash() => r'f7746ef4946a84f663fa75c87cb5f1eb4505e1b5';

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

/// See also [_sessionsForMember].
@ProviderFor(_sessionsForMember)
const _sessionsForMemberProvider = _SessionsForMemberFamily();

/// See also [_sessionsForMember].
class _SessionsForMemberFamily
    extends Family<AsyncValue<(List<Session>, List<Session>)>> {
  /// See also [_sessionsForMember].
  const _SessionsForMemberFamily();

  /// See also [_sessionsForMember].
  _SessionsForMemberProvider call(String memberId) {
    return _SessionsForMemberProvider(memberId);
  }

  @override
  _SessionsForMemberProvider getProviderOverride(
    covariant _SessionsForMemberProvider provider,
  ) {
    return call(provider.memberId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'_sessionsForMemberProvider';
}

/// See also [_sessionsForMember].
class _SessionsForMemberProvider
    extends AutoDisposeStreamProvider<(List<Session>, List<Session>)> {
  /// See also [_sessionsForMember].
  _SessionsForMemberProvider(String memberId)
    : this._internal(
        (ref) => _sessionsForMember(ref as _SessionsForMemberRef, memberId),
        from: _sessionsForMemberProvider,
        name: r'_sessionsForMemberProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sessionsForMemberHash,
        dependencies: _SessionsForMemberFamily._dependencies,
        allTransitiveDependencies:
            _SessionsForMemberFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _SessionsForMemberProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.memberId,
  }) : super.internal();

  final String memberId;

  @override
  Override overrideWith(
    Stream<(List<Session>, List<Session>)> Function(
      _SessionsForMemberRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _SessionsForMemberProvider._internal(
        (ref) => create(ref as _SessionsForMemberRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        memberId: memberId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<(List<Session>, List<Session>)>
  createElement() {
    return _SessionsForMemberProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionsForMemberProvider && other.memberId == memberId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, memberId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _SessionsForMemberRef
    on AutoDisposeStreamProviderRef<(List<Session>, List<Session>)> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _SessionsForMemberProviderElement
    extends AutoDisposeStreamProviderElement<(List<Session>, List<Session>)>
    with _SessionsForMemberRef {
  _SessionsForMemberProviderElement(super.provider);

  @override
  String get memberId => (origin as _SessionsForMemberProvider).memberId;
}

String _$sessionsControllerHash() =>
    r'a1d1857217a6884908cbd9e0368a5e59c6460af3';

/// F3-3 — üyenin kendi seansları gerçek zamanlı `sessions` koleksiyonundan
/// (memberId == kendi uid'si) okunur. `week`/`paymentWarning` bu task'ın
/// kapsamı dışında (ayrı devam eden mock alanlar).
///
/// Copied from [SessionsController].
@ProviderFor(SessionsController)
final sessionsControllerProvider =
    AutoDisposeNotifierProvider<SessionsController, SessionsState>.internal(
      SessionsController.new,
      name: r'sessionsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sessionsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionsController = AutoDisposeNotifier<SessionsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
