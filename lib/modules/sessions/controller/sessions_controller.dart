import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/utils/date_labels.dart';
import '../domain/session.dart';
import '../domain/sessions_state.dart';
import '../repository/sessions_repository.dart';

part 'sessions_controller.g.dart';

Session _emptyNextSession(String title, String meta) => Session(
  id: 'none',
  day: '—',
  month: '',
  title: title,
  meta: meta,
  status: SessionStatus.planned,
);

/// Bu haftanın (Pazartesi-Pazar) her günü için üyenin o gün iptal edilmemiş
/// bir seansı var mı — "BU HAFTA" bar grafiğinin gerçek verisi. Önceden bu
/// alan hep sabit mock değerlerle (`SessionsService.loadInitial`) doluyordu,
/// üyenin gerçekte hiç seansı olmasa bile dolu görünüyordu.
@riverpod
Stream<List<WeekActivityDay>> _weekActivityForMember(
  _WeekActivityForMemberRef ref,
  String memberId,
) {
  final labels = ref.watch(dateLabelsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final nextMonday = monday.add(const Duration(days: 7));
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('memberId', isEqualTo: memberId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(monday))
      .where('startTime', isLessThan: Timestamp.fromDate(nextMonday))
      .snapshots()
      .map((snapshot) {
        final activeWeekdays = <int>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if ((data['status'] as String?) == 'cancelled') continue;
          final startTime = (data['startTime'] as Timestamp).toDate();
          activeWeekdays.add(startTime.weekday);
        }
        return [
          for (var weekday = 1; weekday <= 7; weekday++)
            WeekActivityDay(
              label: labels.weekdayShort(weekday),
              intensity: activeWeekdays.contains(weekday) ? 0.85 : 0.12,
              isRestDay: !activeWeekdays.contains(weekday),
            ),
        ];
      });
}

List<WeekActivityDay> _emptyWeek(DateLabels labels) => [
  for (var weekday = 1; weekday <= 7; weekday++)
    WeekActivityDay(
      label: labels.weekdayShort(weekday),
      intensity: 0.12,
      isRestDay: true,
    ),
];

@riverpod
Stream<bool> _canConfirmAttendanceForMember(
  _CanConfirmAttendanceForMemberRef ref,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(memberId)
      .snapshots()
      .map((doc) => doc.data()?['canConfirmAttendance'] as bool? ?? false);
}

@riverpod
Stream<(List<Session>, List<Session>)> _sessionsForMember(
  _SessionsForMemberRef ref,
  String memberId,
) {
  final labels = ref.watch(dateLabelsProvider);
  final soloTemplate = ref.watch(
    rcTextProvider(RemoteConfigKeys.commonSoloSessionWithTimeTemplate),
  );
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('memberId', isEqualTo: memberId)
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) {
        final now = DateTime.now();
        final upcoming = <Session>[];
        final past = <Session>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final startTime = (data['startTime'] as Timestamp).toDate();
          final session = _toSession(
            doc.id,
            data,
            startTime,
            labels,
            soloTemplate,
          );
          if (session.status == SessionStatus.planned &&
              startTime.isAfter(now)) {
            upcoming.add(session);
          } else {
            past.add(session);
          }
        }
        return (upcoming, past.reversed.toList());
      });
}

Session _toSession(
  String id,
  Map<String, dynamic> data,
  DateTime startTime,
  DateLabels labels,
  String soloTemplate,
) {
  final statusStr = data['status'] as String? ?? 'planned';
  final attended = data['attended'] as bool?;
  final status = switch (statusStr) {
    'cancelled' => SessionStatus.cancelled,
    'completed' =>
      attended == false ? SessionStatus.absent : SessionStatus.completed,
    _ => SessionStatus.planned,
  };
  final confirmationStr = data['memberConfirmation'] as String?;
  final confirmation = switch (confirmationStr) {
    'coming' => AttendanceAnswer.coming,
    'notComing' => AttendanceAnswer.notComing,
    _ => AttendanceAnswer.pending,
  };
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  return Session(
    id: id,
    day: startTime.day.toString().padLeft(2, '0'),
    month: labels.monthShort(startTime.month),
    title: soloTemplate.replaceAll('{time}', time),
    meta: (data['trainerName'] as String?) ?? '',
    status: status,
    confirmation: confirmation,
  );
}

/// F3-3 — üyenin kendi seansları gerçek zamanlı `sessions` koleksiyonundan
/// (memberId == kendi uid'si) okunur. `paymentWarning` hâlâ ayrı, devam eden
/// bir mock alan (bu task'ın kapsamı dışında).
///
/// F3-4 — `attendanceAnswer` artık ayrı bir yerel state değil, sıradaki
/// seansın Firestore'daki `memberConfirmation` alanından türetiliyor.
@riverpod
class SessionsController extends _$SessionsController {
  @override
  SessionsState build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(sessionsRepositoryProvider).loadInitial();
    if (uid == null) return mock;

    final (upcoming, past) =
        ref.watch(_sessionsForMemberProvider(uid)).valueOrNull ??
        (const <Session>[], const <Session>[]);
    final nextSession = upcoming.isEmpty
        ? _emptyNextSession(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsNoPlannedSessionTitle),
            ),
            ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsNoPlannedSessionMeta),
            ),
          )
        : upcoming.first;
    final canConfirmAttendance =
        ref.watch(_canConfirmAttendanceForMemberProvider(uid)).valueOrNull ??
        false;
    final week =
        ref.watch(_weekActivityForMemberProvider(uid)).valueOrNull ??
        _emptyWeek(ref.watch(dateLabelsProvider));
    return mock.copyWith(
      nextSession: nextSession,
      upcoming: upcoming,
      past: past,
      week: week,
      attendanceAnswer: nextSession.confirmation,
      canConfirmAttendance: canConfirmAttendance,
    );
  }

  void setViewMode(SessionsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Yazma başarısız olursa (network/izin) UI'da yanlış bir "onaylandı"
  /// görünümü kalmasın diye önceki cevaba geri dönülür — F3-4'ün ilk
  /// sürümünde yazma denenmeden önce optimistik güncelleniyor ve hata hiç
  /// yakalanmıyordu, bu da sessiz veri kaybına yol açabiliyordu.
  Future<void> confirmAttendance(bool coming) async {
    if (!state.canConfirmAttendance) return;
    final sessionId = state.nextSession.id;
    if (sessionId == 'none') return;
    final previousAnswer = state.attendanceAnswer;
    final answer = coming
        ? AttendanceAnswer.coming
        : AttendanceAnswer.notComing;
    state = state.copyWith(
      attendanceAnswer: answer,
      attendanceErrorMessage: null,
    );
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({
            'memberConfirmation': coming ? 'coming' : 'notComing',
            // Antrenörün bildirim listesi (bkz. TrainerNotificationsController)
            // en son yanıtları önce göstermek için bu alanı kullanıyor.
            'confirmationRespondedAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {
      state = state.copyWith(
        attendanceAnswer: previousAnswer,
        attendanceErrorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.sessionsAttendanceSaveError),
        ),
      );
    }
  }

  Future<void> resetAttendance() async {
    final sessionId = state.nextSession.id;
    final previousAnswer = state.attendanceAnswer;
    state = state.copyWith(
      attendanceAnswer: AttendanceAnswer.pending,
      attendanceErrorMessage: null,
    );
    if (sessionId == 'none') return;
    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({
            'memberConfirmation': FieldValue.delete(),
            'confirmationRespondedAt': FieldValue.delete(),
          });
    } catch (_) {
      state = state.copyWith(
        attendanceAnswer: previousAnswer,
        attendanceErrorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.sessionsAttendanceSaveError),
        ),
      );
    }
  }
}
