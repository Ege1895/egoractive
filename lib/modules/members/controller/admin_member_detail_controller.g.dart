// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detailStreamForIdHash() => r'd457717ee6c7c614acec6247ecb7a26867450217';

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

/// See also [_detailStreamForId].
@ProviderFor(_detailStreamForId)
const _detailStreamForIdProvider = _DetailStreamForIdFamily();

/// See also [_detailStreamForId].
class _DetailStreamForIdFamily extends Family<AsyncValue<AdminMemberDetail>> {
  /// See also [_detailStreamForId].
  const _DetailStreamForIdFamily();

  /// See also [_detailStreamForId].
  _DetailStreamForIdProvider call(String memberId) {
    return _DetailStreamForIdProvider(memberId);
  }

  @override
  _DetailStreamForIdProvider getProviderOverride(
    covariant _DetailStreamForIdProvider provider,
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
  String? get name => r'_detailStreamForIdProvider';
}

/// See also [_detailStreamForId].
class _DetailStreamForIdProvider
    extends AutoDisposeStreamProvider<AdminMemberDetail> {
  /// See also [_detailStreamForId].
  _DetailStreamForIdProvider(String memberId)
    : this._internal(
        (ref) => _detailStreamForId(ref as _DetailStreamForIdRef, memberId),
        from: _detailStreamForIdProvider,
        name: r'_detailStreamForIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$detailStreamForIdHash,
        dependencies: _DetailStreamForIdFamily._dependencies,
        allTransitiveDependencies:
            _DetailStreamForIdFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  _DetailStreamForIdProvider._internal(
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
    Stream<AdminMemberDetail> Function(_DetailStreamForIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _DetailStreamForIdProvider._internal(
        (ref) => create(ref as _DetailStreamForIdRef),
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
  AutoDisposeStreamProviderElement<AdminMemberDetail> createElement() {
    return _DetailStreamForIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _DetailStreamForIdProvider && other.memberId == memberId;
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
mixin _DetailStreamForIdRef on AutoDisposeStreamProviderRef<AdminMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _DetailStreamForIdProviderElement
    extends AutoDisposeStreamProviderElement<AdminMemberDetail>
    with _DetailStreamForIdRef {
  _DetailStreamForIdProviderElement(super.provider);

  @override
  String get memberId => (origin as _DetailStreamForIdProvider).memberId;
}

String _$adminMemberDetailControllerHash() =>
    r'f612d4b9c9367be83a75d5fc1970c8b23ed6bfae';

abstract class _$AdminMemberDetailController
    extends BuildlessAutoDisposeNotifier<AdminMemberDetail> {
  late final String memberId;

  AdminMemberDetail build(String memberId);
}

/// See also [AdminMemberDetailController].
@ProviderFor(AdminMemberDetailController)
const adminMemberDetailControllerProvider = AdminMemberDetailControllerFamily();

/// See also [AdminMemberDetailController].
class AdminMemberDetailControllerFamily extends Family<AdminMemberDetail> {
  /// See also [AdminMemberDetailController].
  const AdminMemberDetailControllerFamily();

  /// See also [AdminMemberDetailController].
  AdminMemberDetailControllerProvider call(String memberId) {
    return AdminMemberDetailControllerProvider(memberId);
  }

  @override
  AdminMemberDetailControllerProvider getProviderOverride(
    covariant AdminMemberDetailControllerProvider provider,
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
  String? get name => r'adminMemberDetailControllerProvider';
}

/// See also [AdminMemberDetailController].
class AdminMemberDetailControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          AdminMemberDetailController,
          AdminMemberDetail
        > {
  /// See also [AdminMemberDetailController].
  AdminMemberDetailControllerProvider(String memberId)
    : this._internal(
        () => AdminMemberDetailController()..memberId = memberId,
        from: adminMemberDetailControllerProvider,
        name: r'adminMemberDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adminMemberDetailControllerHash,
        dependencies: AdminMemberDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            AdminMemberDetailControllerFamily._allTransitiveDependencies,
        memberId: memberId,
      );

  AdminMemberDetailControllerProvider._internal(
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
  AdminMemberDetail runNotifierBuild(
    covariant AdminMemberDetailController notifier,
  ) {
    return notifier.build(memberId);
  }

  @override
  Override overrideWith(AdminMemberDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AdminMemberDetailControllerProvider._internal(
        () => create()..memberId = memberId,
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
  AutoDisposeNotifierProviderElement<
    AdminMemberDetailController,
    AdminMemberDetail
  >
  createElement() {
    return _AdminMemberDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdminMemberDetailControllerProvider &&
        other.memberId == memberId;
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
mixin AdminMemberDetailControllerRef
    on AutoDisposeNotifierProviderRef<AdminMemberDetail> {
  /// The parameter `memberId` of this provider.
  String get memberId;
}

class _AdminMemberDetailControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          AdminMemberDetailController,
          AdminMemberDetail
        >
    with AdminMemberDetailControllerRef {
  _AdminMemberDetailControllerProviderElement(super.provider);

  @override
  String get memberId =>
      (origin as AdminMemberDetailControllerProvider).memberId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
