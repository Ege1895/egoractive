// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expensesForGymHash() => r'02108df89e12f795e86d87b5bd8cd2128cb8f573';

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

/// See also [_expensesForGym].
@ProviderFor(_expensesForGym)
const _expensesForGymProvider = _ExpensesForGymFamily();

/// See also [_expensesForGym].
class _ExpensesForGymFamily extends Family<AsyncValue<ExpensesState>> {
  /// See also [_expensesForGym].
  const _ExpensesForGymFamily();

  /// See also [_expensesForGym].
  _ExpensesForGymProvider call(String gymId) {
    return _ExpensesForGymProvider(gymId);
  }

  @override
  _ExpensesForGymProvider getProviderOverride(
    covariant _ExpensesForGymProvider provider,
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
  String? get name => r'_expensesForGymProvider';
}

/// See also [_expensesForGym].
class _ExpensesForGymProvider extends AutoDisposeStreamProvider<ExpensesState> {
  /// See also [_expensesForGym].
  _ExpensesForGymProvider(String gymId)
    : this._internal(
        (ref) => _expensesForGym(ref as _ExpensesForGymRef, gymId),
        from: _expensesForGymProvider,
        name: r'_expensesForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$expensesForGymHash,
        dependencies: _ExpensesForGymFamily._dependencies,
        allTransitiveDependencies:
            _ExpensesForGymFamily._allTransitiveDependencies,
        gymId: gymId,
      );

  _ExpensesForGymProvider._internal(
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
    Stream<ExpensesState> Function(_ExpensesForGymRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: _ExpensesForGymProvider._internal(
        (ref) => create(ref as _ExpensesForGymRef),
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
  AutoDisposeStreamProviderElement<ExpensesState> createElement() {
    return _ExpensesForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ExpensesForGymProvider && other.gymId == gymId;
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
mixin _ExpensesForGymRef on AutoDisposeStreamProviderRef<ExpensesState> {
  /// The parameter `gymId` of this provider.
  String get gymId;
}

class _ExpensesForGymProviderElement
    extends AutoDisposeStreamProviderElement<ExpensesState>
    with _ExpensesForGymRef {
  _ExpensesForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _ExpensesForGymProvider).gymId;
}

String _$expenseCategoriesHash() => r'f5e0bab4ea58b5fc632430e5d0c2f534d5952192';

/// F5-3 — `cfg_expense_categories` okuması burada async-wrapped: Remote
/// Config henüz hazır olmadığı (ör. Firebase başlatılmamış test ortamı)
/// durumlarda panel çökmesin diye. Cihaz diline göre `label_tr`/`label_en`
/// çözümlenir — Firestore'a yazılan `id` dilden bağımsız kalır.
///
/// Copied from [expenseCategories].
@ProviderFor(expenseCategories)
final expenseCategoriesProvider =
    AutoDisposeStreamProvider<List<ExpenseCategoryOption>>.internal(
      expenseCategories,
      name: r'expenseCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expenseCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpenseCategoriesRef =
    AutoDisposeStreamProviderRef<List<ExpenseCategoryOption>>;
String _$expensesControllerHash() =>
    r'66b75ff0c9ba0b1638bb145125e9f9fc343df84d';

/// See also [ExpensesController].
@ProviderFor(ExpensesController)
final expensesControllerProvider =
    AutoDisposeNotifierProvider<ExpensesController, ExpensesState>.internal(
      ExpensesController.new,
      name: r'expensesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpensesController = AutoDisposeNotifier<ExpensesState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
