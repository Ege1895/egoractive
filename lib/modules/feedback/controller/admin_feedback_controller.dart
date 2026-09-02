import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_feedback_entry.dart';
import '../repository/admin_feedback_repository.dart';
import '../../../shared/utils/date_labels.dart';

part 'admin_feedback_controller.g.dart';

const _empty = AdminFeedbackSummary(
  average: 0,
  totalCount: 0,
  starCounts: {},
  entries: [],
);

/// Geri bildirim ekranında görüntülenen ay (ayın ilk günü). Varsayılan:
/// içinde bulunulan ay. Liste önceden salonun TÜM geri bildirimlerini
/// çekiyordu; yüzlerce kayıtta okunmaz hale geliyordu.
///
/// `ExpensesSelectedMonth` ile BİLEREK aynı desen — ileri gitmek içinde
/// bulunulan ayla sınırlı, geçmiş aylara serbestçe gidilebilir (yoksa
/// geçen ayın geri bildirimleri hiç görülemezdi).
@riverpod
class AdminFeedbackSelectedMonth extends _$AdminFeedbackSelectedMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() {
    if (!feedbackMonthIsBeforeCurrent(state)) return;
    state = DateTime(state.year, state.month + 1);
  }
}

/// Saf yardımcı — [adminFeedbackCanGoNextMonth] ve
/// [AdminFeedbackSelectedMonth.next] aynı kuralı paylaşsın diye ayrıldı.
bool feedbackMonthIsBeforeCurrent(DateTime month) {
  final now = DateTime.now();
  return month.isBefore(DateTime(now.year, now.month));
}

/// "Sonraki ay" okunu pasifleştirmek için — `notifier`'ı `watch` etmek
/// yeniden çizim tetiklemez, bu yüzden türetilmiş provider.
@riverpod
bool adminFeedbackCanGoNextMonth(AdminFeedbackCanGoNextMonthRef ref) {
  return feedbackMonthIsBeforeCurrent(
    ref.watch(adminFeedbackSelectedMonthProvider),
  );
}

/// Yıldız filtresi — `null` "tümü" demek, 1-5 arası bir değer sadece o
/// puanı gösterir. Filtre CLIENT tarafında uygulanıyor: sorgu zaten tek
/// bir ayla sınırlı olduğu için veri kümesi küçük, böylece hem ek bir
/// composite index gerekmiyor hem filtre değişimi anında oluyor.
@riverpod
class AdminFeedbackStarFilter extends _$AdminFeedbackStarFilter {
  @override
  int? build() => null;

  /// Aynı yıldıza tekrar dokunmak filtreyi kaldırır (toggle).
  void toggle(int stars) => state = state == stars ? null : stars;

  void clear() => state = null;
}

@riverpod
Stream<AdminFeedbackSummary> _feedbackForGym(
  _FeedbackForGymRef ref,
  String gymId,
  DateTime month,
) {
  return ref
      .watch(adminFeedbackRepositoryProvider)
      .watchSummary(gymId, month, ref.watch(dateLabelsProvider));
}

@riverpod
class AdminFeedbackController extends _$AdminFeedbackController {
  @override
  AdminFeedbackSummary build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return _empty;
    final month = ref.watch(adminFeedbackSelectedMonthProvider);
    return ref.watch(_feedbackForGymProvider(gymId, month)).valueOrNull ??
        _empty;
  }
}

/// Ekranda gösterilecek liste: seçili ayın özeti + yıldız filtresi.
///
/// `average`/`starCounts`/`totalCount` BİLEREK filtrelenmemiş özetten
/// okunuyor — filtre uygulanınca üstteki ortalama/dağılım kartının da
/// değişmesi kafa karıştırıcı olurdu; o kart ayın tamamını özetler,
/// filtre yalnızca alttaki listeyi daraltır.
@riverpod
List<AdminFeedbackEntry> adminFeedbackFilteredEntries(
  AdminFeedbackFilteredEntriesRef ref,
) {
  final entries = ref.watch(adminFeedbackControllerProvider).entries;
  final starFilter = ref.watch(adminFeedbackStarFilterProvider);
  if (starFilter == null) return entries;
  return entries.where((e) => e.stars == starFilter).toList();
}
