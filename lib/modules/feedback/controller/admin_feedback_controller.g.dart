// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_feedback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminFeedbackCanGoNextMonthHash() =>
    r'10667ee15bcb4fbcec974f6df5833659fd1e8cf5';

/// "Sonraki ay" okunu pasifleştirmek için — `notifier`'ı `watch` etmek
/// yeniden çizim tetiklemez, bu yüzden türetilmiş provider.
///
/// Copied from [adminFeedbackCanGoNextMonth].
@ProviderFor(adminFeedbackCanGoNextMonth)
final adminFeedbackCanGoNextMonthProvider = AutoDisposeProvider<bool>.internal(
  adminFeedbackCanGoNextMonth,
  name: r'adminFeedbackCanGoNextMonthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminFeedbackCanGoNextMonthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminFeedbackCanGoNextMonthRef = AutoDisposeProviderRef<bool>;
String _$feedbackForGymHash() => r'99bb39e8ff6e836134fc63fdcdadddb3f15e852d';

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
  _FeedbackForGymProvider call(String gymId, DateTime month) {
    return _FeedbackForGymProvider(gymId, month);
  }

  @override
  _FeedbackForGymProvider getProviderOverride(
    covariant _FeedbackForGymProvider provider,
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
  String? get name => r'_feedbackForGymProvider';
}

/// See also [_feedbackForGym].
class _FeedbackForGymProvider
    extends AutoDisposeStreamProvider<AdminFeedbackSummary> {
  /// See also [_feedbackForGym].
  _FeedbackForGymProvider(String gymId, DateTime month)
    : this._internal(
        (ref) => _feedbackForGym(ref as _FeedbackForGymRef, gymId, month),
        from: _feedbackForGymProvider,
        name: r'_feedbackForGymProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedbackForGymHash,
        dependencies: _FeedbackForGymFamily._dependencies,
        allTransitiveDependencies:
            _FeedbackForGymFamily._allTransitiveDependencies,
        gymId: gymId,
        month: month,
      );

  _FeedbackForGymProvider._internal(
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
        month: month,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<AdminFeedbackSummary> createElement() {
    return _FeedbackForGymProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is _FeedbackForGymProvider &&
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
mixin _FeedbackForGymRef on AutoDisposeStreamProviderRef<AdminFeedbackSummary> {
  /// The parameter `gymId` of this provider.
  String get gymId;

  /// The parameter `month` of this provider.
  DateTime get month;
}

class _FeedbackForGymProviderElement
    extends AutoDisposeStreamProviderElement<AdminFeedbackSummary>
    with _FeedbackForGymRef {
  _FeedbackForGymProviderElement(super.provider);

  @override
  String get gymId => (origin as _FeedbackForGymProvider).gymId;
  @override
  DateTime get month => (origin as _FeedbackForGymProvider).month;
}

String _$adminFeedbackFilteredEntriesHash() =>
    r'064a3e558a7910810b527f6a63d16c35ae43eb53';

/// Ekranda gösterilecek liste: seçili ayın özeti + yıldız filtresi.
///
/// `average`/`starCounts`/`totalCount` BİLEREK filtrelenmemiş özetten
/// okunuyor — filtre uygulanınca üstteki ortalama/dağılım kartının da
/// değişmesi kafa karıştırıcı olurdu; o kart ayın tamamını özetler,
/// filtre yalnızca alttaki listeyi daraltır.
///
/// Copied from [adminFeedbackFilteredEntries].
@ProviderFor(adminFeedbackFilteredEntries)
final adminFeedbackFilteredEntriesProvider =
    AutoDisposeProvider<List<AdminFeedbackEntry>>.internal(
      adminFeedbackFilteredEntries,
      name: r'adminFeedbackFilteredEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminFeedbackFilteredEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminFeedbackFilteredEntriesRef =
    AutoDisposeProviderRef<List<AdminFeedbackEntry>>;
String _$adminFeedbackSelectedMonthHash() =>
    r'36986839854549c1f869f3d02c1822ddf87f841d';

/// Geri bildirim ekranında görüntülenen ay (ayın ilk günü). Varsayılan:
/// içinde bulunulan ay. Liste önceden salonun TÜM geri bildirimlerini
/// çekiyordu; yüzlerce kayıtta okunmaz hale geliyordu.
///
/// `ExpensesSelectedMonth` ile BİLEREK aynı desen — ileri gitmek içinde
/// bulunulan ayla sınırlı, geçmiş aylara serbestçe gidilebilir (yoksa
/// geçen ayın geri bildirimleri hiç görülemezdi).
///
/// Copied from [AdminFeedbackSelectedMonth].
@ProviderFor(AdminFeedbackSelectedMonth)
final adminFeedbackSelectedMonthProvider =
    AutoDisposeNotifierProvider<AdminFeedbackSelectedMonth, DateTime>.internal(
      AdminFeedbackSelectedMonth.new,
      name: r'adminFeedbackSelectedMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminFeedbackSelectedMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminFeedbackSelectedMonth = AutoDisposeNotifier<DateTime>;
String _$adminFeedbackStarFilterHash() =>
    r'accdaec61f3dcc54fdab7fa4dcfb53932cc833a5';

/// Yıldız filtresi — `null` "tümü" demek, 1-5 arası bir değer sadece o
/// puanı gösterir. Filtre CLIENT tarafında uygulanıyor: sorgu zaten tek
/// bir ayla sınırlı olduğu için veri kümesi küçük, böylece hem ek bir
/// composite index gerekmiyor hem filtre değişimi anında oluyor.
///
/// Copied from [AdminFeedbackStarFilter].
@ProviderFor(AdminFeedbackStarFilter)
final adminFeedbackStarFilterProvider =
    AutoDisposeNotifierProvider<AdminFeedbackStarFilter, int?>.internal(
      AdminFeedbackStarFilter.new,
      name: r'adminFeedbackStarFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminFeedbackStarFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminFeedbackStarFilter = AutoDisposeNotifier<int?>;
String _$adminFeedbackControllerHash() =>
    r'72085b5f9fa515a7e41ebcd2cd8b9f341dff393b';

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
