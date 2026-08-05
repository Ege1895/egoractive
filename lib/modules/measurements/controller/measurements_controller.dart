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
  1: 'Oca', 2: 'Şub', 3: 'Mar', 4: 'Nis', 5: 'May', 6: 'Haz',
  7: 'Tem', 8: 'Ağu', 9: 'Eyl', 10: 'Eki', 11: 'Kas', 12: 'Ara',
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
Stream<List<_Entry>> _measurementEntries(_MeasurementEntriesRef ref, String uid) {
  return FirebaseFirestore.instance
      .collection('measurements')
      .doc(uid)
      .collection('entries')
      .orderBy('date')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            final date = (data['date'] as Timestamp).toDate();
            final values = <MeasurementMetric, double>{};
            for (final metric in MeasurementMetric.values) {
              final raw = data[metric.name];
              if (raw is num) values[metric] = raw.toDouble();
            }
            return (date, values);
          }).toList());
}

MeasurementsState _toState(List<_Entry> entries) {
  final series = <MeasurementMetric, MeasurementSeries>{};
  final points = <MeasurementMetric, MeasurementPoint>{};

  for (final metric in MeasurementMetric.values) {
    final withMetric = entries.where((e) => e.$2.containsKey(metric)).toList();
    if (withMetric.isEmpty) continue;

    final months = withMetric.map((e) => _monthAbbrev[e.$1.month] ?? '').toList();
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
    final latest = values.last;
    final previous = values.length > 1 ? values[values.length - 2] : latest;
    final diff = latest - previous;
    points[metric] = MeasurementPoint(
      metric: metric,
      value: latest.toStringAsFixed(1).replaceAll('.', ','),
      delta: _formatDelta(diff, zeroLabel: 'değişim yok'),
      isImprovement: diff <= 0,
      since: 'Son ölçüm ${withMetric.last.$1.day} ${_monthAbbrev[withMetric.last.$1.month]}',
      fx: layout.fx,
      fy: layout.fy,
      side: layout.side,
    );
  }

  return MeasurementsState(points: points, series: series);
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
class MeasurementsController extends _$MeasurementsController {
  @override
  MeasurementsState build() {
    final uid = ref.watch(measurementsViewedUidProvider) ?? ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(measurementsRepositoryProvider).loadInitial();
    if (uid == null) return mock;

    final entries = ref.watch(_measurementEntriesProvider(uid)).valueOrNull;
    if (entries == null || entries.isEmpty) return mock;

    final real = _toState(entries);
    return mock.copyWith(points: real.points, series: real.series);
  }

  void selectPoint(MeasurementMetric metric) {
    state = state.copyWith(selectedMetric: metric);
  }

  void setViewMode(MeasurementsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Yeni ölçüm ekle formundan gelen değerleri gerçek Firestore'a yazar —
  /// boş bırakılan alanlar atlanır. Admin/antrenör bir üyeyi görüntülüyorsa
  /// (`measurementsViewedUidProvider` set edilmiş) o üyenin verisine yazar.
  Future<void> addMeasurement(Map<MeasurementMetric, double> newValues) async {
    final uid = ref.read(measurementsViewedUidProvider) ?? ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null || newValues.isEmpty) return;
    await ref.read(measurementsWriteServiceProvider).addEntry(uid: uid, date: DateTime.now(), values: newValues);
  }
}
