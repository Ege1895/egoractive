// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expensesCanGoNextMonthHash() =>
    r'b45b204019dceec77e30032c9175563e194f7602';

/// Panelde "sonraki ay" okunu pasifleştirmek için — `notifier`'ı `watch`
/// etmek yeniden çizim TETİKLEMEZ (state değişimini dinlemez), bu yüzden
/// türetilmiş bir provider olarak duruyor.
///
/// Copied from [expensesCanGoNextMonth].
@ProviderFor(expensesCanGoNextMonth)
final expensesCanGoNextMonthProvider = AutoDisposeProvider<bool>.internal(
  expensesCanGoNextMonth,
  name: r'expensesCanGoNextMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expensesCanGoNextMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExpensesCanGoNextMonthRef = AutoDisposeProviderRef<bool>;
String _$expensesForGymHash() => r'0925aedc35954fa7f279106e9ba1e25db3a2b008';

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
  _ExpensesForGymProvider call(String gymId, DateTime month) {
    return _ExpensesForGymProvider(gymId, month);
  }

  @override
  _ExpensesForGymProvider getProviderOverride(
    covariant _ExpensesForGymProvider provider,
  ) {
    return call(provider.gymId, provider.month);
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
  _ExpensesForGymProvider(String gymId, DateTime month)
    : this._internal(
        (ref) => _expensesForGym(ref as _ExpensesForGymRef, gymId, month),
        from: _expensesForGymProvider,
        name: r'_expensesForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$expensesForGymHash,
        dependencies: _ExpensesForGymFamily._dependencies,
        allTransitiveDependencies:
            _ExpensesForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        month: month,
      );

  _ExpensesForGymProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gymId,
    required this.month,
  }) : super.internal();

  final String gymId;
  final DateTime month;

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
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ExpensesState> createElement() {
    return _ExpensesForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _ExpensesForGymProvider &&
        other.gymId == gymId &&
        other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gymId.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin _ExpensesForGymRef on AutoDisposeStreamProviderRef<ExpensesState> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _ExpensesForGymProviderElement
    extends AutoDisposeStreamProviderElement<ExpensesState>
    with _ExpensesForGymRef {
  _ExpensesForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _ExpensesForGymProvider).gymId;
  @override
  DateTime get month => (origin as _ExpensesForGymProvider).month;
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
String _$expensesSelectedMonthHash() =>
    r'3d105713c6b7a17ff8d125650ed9487031f00918';

/// Finans panelinde görüntülenen ay (ayın ilk günü). Varsayılan: içinde
/// bulunulan ay. Önceden gider listesi `DateTime.now()`'a sabitliydi, yani
/// ay değişince bir önceki ayın girdileri hiç görülemiyordu (kullanıcı
/// raporu, 2026-09-02).
///
/// İleri gitmek içinde bulunulan ayla SINIRLI — gider tarihleri geleceğe
/// girilebilse de, kullanıcıyı boş aylarda sonsuza kadar ilerletmenin bir
/// faydası yok; [canGoNext] bunu panelde butonu pasifleştirmek için açar.
///
/// Copied from [ExpensesSelectedMonth].
@ProviderFor(ExpensesSelectedMonth)
final expensesSelectedMonthProvider =
    AutoDisposeNotifierProvider<ExpensesSelectedMonth, DateTime>.internal(
      ExpensesSelectedMonth.new,
      name: r'expensesSelectedMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$expensesSelectedMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExpensesSelectedMonth = AutoDisposeNotifier<DateTime>;
String _$expensesControllerHash() =>
    r'17ad25f30d731d5090f65b28134302cb8db6d54d';

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
