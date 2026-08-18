import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/measurement_metric.dart';
import '../domain/measurement_point.dart';
import '../domain/measurement_series.dart';
import '../domain/measurements_state.dart';
import '../repository/measurements_repository.dart';
import '../service/measurements_write_service.dart';

part 'measurements_controller.g.dart';

const _monthAbbrev = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

/// Silüet üzerindeki tıklanabilir nokta konumları — gerçek ölçüm verisiyle
/// hiçbir ilgisi yok, sadece görsel bir yerleşim sabiti (mock'takiyle aynı).
const _avatarLayout = {
  MeasurementMetric.gogus: (fx: 0.50, fy: 0.255, side: AvatarSide.right),
  MeasurementMetric.kol: (fx: 0.335, fy: 0.345, side: AvatarSide.left),
  MeasurementMetric.bel: (fx: 0.50, fy: 0.395, side: AvatarSide.right),
  MeasurementMetric.kalca: (fx: 0.50, fy: 0.475, side: AvatarSide.left),
  MeasurementMetric.bacak: (fx: 0.435, fy: 0.615, side: AvatarSide.right),
};

typedef _Entry = (DateTime date, Map<MeasurementMetric, double> values);

@riverpod
Stream<List<_Entry>> _measurementEntries(
  _MeasurementEntriesRef ref,
  String uid,
) {
  return FirebaseFirestore.instance
      .collection('measurements')
      .doc(uid)
      .collection('entries')
      .orderBy('date')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          final date = (data['date'] as Timestamp).toDate();
          final values = <MeasurementMetric, double>{};
          for (final metric in MeasurementMetric.values) {
            final raw = data[metric.name];
            if (raw is num) values[metric] = raw.toDouble();
          }
          return (date, values);
        }).toList(),
      );
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// `entries` tarihe göre artan sırada — `target` gün veya ondan önceki en
/// yakın kaydı döner (o metrik için o günde/o günden önce bir kayıt yoksa
/// null).
_Entry? _entryAtOrBefore(List<_Entry> entries, DateTime target) {
  _Entry? result;
  for (final entry in entries) {
    if (entry.$1.isAfter(target) && !_isSameDay(entry.$1, target)) break;
    result = entry;
  }
  return result;
}

/// F4-1 — `selectedDate` verilirse avatar ekranı o güne (veya o günden
/// önceki en yakın kayda) ait değerleri gösterir; verilmezse her metriğin
/// en son kaydı kullanılır. Grafik/trend her zaman tüm geçmişi gösterir,
/// tarih seçiminden etkilenmez.
MeasurementsState _toState(List<_Entry> entries, {DateTime? selectedDate}) {
  final series = <MeasurementMetric, MeasurementSeries>{};
  final points = <MeasurementMetric, MeasurementPoint>{};
  final recordedDates = entries.map((e) => e.$1).toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  for (final metric in MeasurementMetric.values) {
    final withMetric = entries.where((e) => e.$2.containsKey(metric)).toList();
    if (withMetric.isEmpty) continue;

    final months = withMetric
        .map((e) => _monthAbbrev[e.$1.month] ?? '')
        .toList();
    final values = withMetric.map((e) => e.$2[metric]!).toList();
    final totalDelta = values.last - values.first;
    series[metric] = MeasurementSeries(
      metric: metric,
      months: months,
      values: values,
      totalDeltaLabel: _formatDelta(totalDelta, zeroLabel: '0 cm'),
    );

    final layout = _avatarLayout[metric];
    if (layout == null) continue;

    final target = selectedDate == null
        ? withMetric.last
        : (_entryAtOrBefore(withMetric, selectedDate) ?? withMetric.last);
    final targetIndex = withMetric.indexOf(target);
    final targetValue = target.$2[metric]!;
    final previousValue = targetIndex > 0
        ? withMetric[targetIndex - 1].$2[metric]!
        : targetValue;
    final diff = targetValue - previousValue;
    points[metric] = MeasurementPoint(
      metric: metric,
      value: targetValue.toStringAsFixed(1).replaceAll('.', ','),
      delta: _formatDelta(diff, zeroLabel: 'değişim yok'),
      isImprovement: diff <= 0,
      since:
          '${target.$1.day} ${_monthAbbrev[target.$1.month]} ${target.$1.year}',
      fx: layout.fx,
      fy: layout.fy,
      side: layout.side,
    );
  }

  return MeasurementsState(
    points: points,
    series: series,
    recordedDates: recordedDates,
  );
}

String _formatDelta(double diff, {required String zeroLabel}) {
  if (diff == 0) return zeroLabel;
  final formatted = diff.abs().toStringAsFixed(1).replaceAll('.', ',');
  return '${diff < 0 ? '−' : '+'}$formatted cm';
}

/// F4-1 — admin/antrenör bir üyenin ölçüm ekranını açtığında bu sağlanır;
/// `MeasurementsController` bunu kendi uid'sinin önüne alır. Panel
/// kapanınca (onPanelHide) tekrar null'a dönüp üyenin kendi görünümünü
/// bozmadan bırakır.
@riverpod
class MeasurementsViewedUid extends _$MeasurementsViewedUid {
  @override
  String? build() => null;

  void set(String? uid) => state = uid;
}

/// F4-1 — görüntülenen kişinin (kendisi ya da admin/antrenörün açtığı bir
/// üye) ölçümleri gerçek zamanlı `measurements/{uid}/entries` alt
/// koleksiyonundan okunur. Hiç ölçüm yoksa (yeni üye) mock veriye düşülür
/// — boş bir avatar/grafik göstermek yerine örnek bir başlangıç durumu
/// sunar.
@riverpod
class _MeasurementsSelectedDate extends _$MeasurementsSelectedDate {
  @override
  DateTime? build() => null;

  void select(DateTime? date) => state = date;
}

@riverpod
class MeasurementsController extends _$MeasurementsController {
  @override
  MeasurementsState build() {
    final selectedDate = ref.watch(_measurementsSelectedDateProvider);
    final uid =
        ref.watch(measurementsViewedUidProvider) ??
        ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(measurementsRepositoryProvider).loadInitial();
    if (uid == null) return mock;

    final entries = ref.watch(_measurementEntriesProvider(uid)).valueOrNull;
    if (entries == null || entries.isEmpty) return mock;

    final real = _toState(entries, selectedDate: selectedDate);
    // real.points sadece en az bir kez ölçülmüş metrikleri içerir — mock'un
    // varsayılan selectedMetric'i (bel) o üye hiç bel ölçmediyse burada
    // karşılık bulamaz, points[selectedMetric]! UI'da null'a patlar.
    final selectedMetric = real.points.containsKey(mock.selectedMetric)
        ? mock.selectedMetric
        : (real.points.keys.isEmpty
              ? mock.selectedMetric
              : real.points.keys.first);
    return mock.copyWith(
      points: real.points,
      series: real.series,
      recordedDates: real.recordedDates,
      selectedDate: selectedDate,
      selectedMetric: selectedMetric,
      hasRealData: true,
    );
  }

  void selectPoint(MeasurementMetric metric) {
    state = state.copyWith(selectedMetric: metric);
  }

  void setViewMode(MeasurementsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Geçmiş bir tarihi seçip avatar ekranında o güne ait değerleri
  /// gösterir; `null` en son kayda döner.
  void selectDate(DateTime? date) =>
      ref.read(_measurementsSelectedDateProvider.notifier).select(date);

  /// Yeni ölçüm ekle formundan gelen değerleri gerçek Firestore'a yazar —
  /// boş bırakılan alanlar atlanır. Admin/antrenör bir üyeyi görüntülüyorsa
  /// (`measurementsViewedUidProvider` set edilmiş) o üyenin verisine yazar.
  /// Aynı gün için ikinci bir kayıt, o günün verisinin tamamen üzerine
  /// yazar (bkz. `MeasurementsWriteService`).
  Future<void> addMeasurement(Map<MeasurementMetric, double> newValues) async {
    final uid =
        ref.read(measurementsViewedUidProvider) ??
        ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || newValues.isEmpty) return;
    await ref
        .read(measurementsWriteServiceProvider)
        .addEntry(uid: uid, date: DateTime.now(), values: newValues);
  }
}
