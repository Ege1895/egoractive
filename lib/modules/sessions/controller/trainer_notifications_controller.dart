import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_notification.dart';
import '../repository/trainer_notifications_repository.dart';

part 'trainer_notifications_controller.g.dart';

const _monthNamesShort = {
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

@riverpod
Stream<List<TrainerNotification>> _confirmationsForTrainer(
  _ConfirmationsForTrainerRef ref,
  String trainerId,
) {
  // `trainerId+startTime` için zaten bir composite index var (bkz.
  // firestore.indexes.json) — `memberConfirmation`'a göre ayrı bir
  // eşitlik/aralık sorgusu yeni bir index gerektirirdi, bu yüzden son 30
  // günün seansları çekilip yanıtlanmış olanlar client tarafında
  // filtreleniyor.
  final since = Timestamp.fromDate(
    DateTime.now().subtract(const Duration(days: 30)),
  );
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: since)
      .snapshots()
      .map((snapshot) {
        final answered =
            snapshot.docs.where((doc) {
              final confirmation = doc.data()['memberConfirmation'] as String?;
              return confirmation == 'coming' || confirmation == 'notComing';
            }).toList()..sort((a, b) {
              final aTime = a.data()['confirmationRespondedAt'] as Timestamp?;
              final bTime = b.data()['confirmationRespondedAt'] as Timestamp?;
              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime);
            });
        return answered.map(_toNotification).toList();
      });
}

TrainerNotification _toNotification(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final memberName = (data['memberName'] as String?) ?? '';
  final coming = data['memberConfirmation'] == 'coming';
  final startTime = (data['startTime'] as Timestamp).toDate();
  final sessionMeta =
      '${startTime.day} ${_monthNamesShort[startTime.month]} '
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} · Birebir';
  final respondedAt = (data['confirmationRespondedAt'] as Timestamp?)?.toDate();
  final answeredAt = respondedAt == null
      ? ''
      : '${respondedAt.day} ${_monthNamesShort[respondedAt.month]} '
            '${respondedAt.hour.toString().padLeft(2, '0')}:${respondedAt.minute.toString().padLeft(2, '0')}';

  return TrainerNotification(
    id: doc.id,
    title: '$memberName ${coming ? 'geleceğini' : 'gelmeyeceğini'} bildirdi',
    body: sessionMeta,
    memberInitials: _initialsFor(memberName),
    memberName: memberName,
    sessionMeta: sessionMeta,
    answerLabel: coming ? 'Gelicem' : 'Gelmeyeceğim',
    answerIsPositive: coming,
    answeredAt: answeredAt,
    // Üye onayı sırasında serbest metin bir not almıyor — gerçek veride
    // bu alan hiçbir zaman dolu değil.
    note: null,
  );
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}

/// Antrenörün kendi (`trainerId == uid`) seanslarına üyelerin verdiği
/// gelecek/gelmeyecek yanıtları gerçek zamanlı dinlenir. Oturum yoksa (test
/// ortamı vb.) mock repository'e düşer.
@riverpod
class TrainerNotificationsController extends _$TrainerNotificationsController {
  @override
  List<TrainerNotification> build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return ref
          .watch(trainerNotificationsRepositoryProvider)
          .loadNotifications();
    }
    return ref.watch(_confirmationsForTrainerProvider(uid)).valueOrNull ??
        const [];
  }
}
