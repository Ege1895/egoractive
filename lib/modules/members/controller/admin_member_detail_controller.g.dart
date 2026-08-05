// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_member_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminMemberDetailControllerHash() =>
    r'dbea92d2f0b87da6b0fb8caf4baab937a7d846fa';

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
