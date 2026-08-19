import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/session.dart';
import '../domain/sessions_state.dart';
import '../repository/sessions_repository.dart';

part 'sessions_controller.g.dart';

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

const _emptyNextSession = Session(
  id: 'none',
  day: '—',
  month: '',
  title: 'Planlanmış dersin yok',
  meta: 'Antrenörünle iletişime geç',
  status: SessionStatus.planned,
);

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
          final session = _toSession(doc.id, data, startTime);
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

Session _toSession(String id, Map<String, dynamic> data, DateTime startTime) {
  final statusStr = data['status'] as String? ?? 'planned';
  final status = switch (statusStr) {
    'cancelled' => SessionStatus.cancelled,
    'completed' => SessionStatus.completed,
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
    month: _monthAbbrev[startTime.month] ?? '',
    title: 'Birebir · $time',
    meta: (data['trainerName'] as String?) ?? '',
    status: status,
    confirmation: confirmation,
  );
}

/// F3-3 — üyenin kendi seansları gerçek zamanlı `sessions` koleksiyonundan
/// (memberId == kendi uid'si) okunur. `week`/`paymentWarning` bu task'ın
/// kapsamı dışında (ayrı devam eden mock alanlar).
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
    final nextSession = upcoming.isEmpty ? _emptyNextSession : upcoming.first;
    final canConfirmAttendance =
        ref.watch(_canConfirmAttendanceForMemberProvider(uid)).valueOrNull ??
        false;
    return mock.copyWith(
      nextSession: nextSession,
      upcoming: upcoming,
      past: past,
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
        attendanceErrorMessage:
            'Cevabın kaydedilemedi, bağlantını kontrol edip tekrar dene.',
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
        attendanceErrorMessage:
            'Cevabın kaydedilemedi, bağlantını kontrol edip tekrar dene.',
      );
    }
  }
}
