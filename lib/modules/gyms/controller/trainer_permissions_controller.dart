import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/admin_permissions.dart';

part 'trainer_permissions_controller.g.dart';

TrainerReminderDelay _delayFromMinutes(int minutes) => switch (minutes) {
  15 => TrainerReminderDelay.fifteenMinutes,
  60 => TrainerReminderDelay.oneHour,
  _ => TrainerReminderDelay.thirtyMinutes,
};

int _minutesFromDelay(TrainerReminderDelay delay) => switch (delay) {
  TrainerReminderDelay.fifteenMinutes => 15,
  TrainerReminderDelay.thirtyMinutes => 30,
  TrainerReminderDelay.oneHour => 60,
};

/// [AdminPermissionsPanel]'in antrenör seçim adımından sonra açılan
/// [TrainerPermissionsEditPanel]'in state'i — gym-wide `AdminPermissionsController`'dan
/// farklı olarak `gyms/{gymId}.trainerPermissions.{trainerId}` altında,
/// seçilen bir ya da birden fazla antrenöre özel saklanır. Her toggle
/// seçilen antrenörlerin hepsine aynı anda yazılır (toplu düzenleme).
@riverpod
class TrainerPermissionsController extends _$TrainerPermissionsController {
  @override
  AdminPermissions build() => const AdminPermissions();

  /// Sheet açıldığında ilk seçilen antrenörün mevcut ayarlarını (varsa)
  /// yükler — birden fazla antrenör seçiliyse ve aralarında farklı ayarlar
  /// varsa, düzenleme ekranı ilkinin değerinden başlar; her değişiklik
  /// seçilen antrenörlerin hepsine aynı şekilde uygulanır.
  Future<void> loadFrom(String trainerId) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    final rc = ref.read(remoteConfigServiceProvider);
    if (gymId == null) {
      state = const AdminPermissions();
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .get();
    final data =
        (doc.data()?['trainerPermissions'] as Map<String, dynamic>?)?[trainerId]
            as Map<String, dynamic>?;
    state = AdminPermissions(
      trainerReminderDelay: _delayFromMinutes(
        (data?['trainerReminderDelayMinutes'] as num?)?.toInt() ??
            rc.defaultTrainerReminderDelayMinutes,
      ),
      canCancelMemberSessions:
          (data?['canCancelMemberSessions'] as bool?) ??
          rc.defaultCanCancelMemberSessions,
      canRescheduleMemberSessions:
          (data?['canRescheduleMemberSessions'] as bool?) ??
          rc.defaultCanRescheduleMemberSessions,
    );
  }

  Future<void> setReminderDelay(
    TrainerReminderDelay delay,
    List<String> trainerIds,
  ) => _apply(
    trainerIds,
    field: 'trainerReminderDelayMinutes',
    value: _minutesFromDelay(delay),
    optimistic: state.copyWith(trainerReminderDelay: delay),
  );

  Future<void> toggleCanCancelMemberSessions(List<String> trainerIds) =>
      _apply(
        trainerIds,
        field: 'canCancelMemberSessions',
        value: !state.canCancelMemberSessions,
        optimistic: state.copyWith(
          canCancelMemberSessions: !state.canCancelMemberSessions,
        ),
      );

  Future<void> toggleCanRescheduleMemberSessions(List<String> trainerIds) =>
      _apply(
        trainerIds,
        field: 'canRescheduleMemberSessions',
        value: !state.canRescheduleMemberSessions,
        optimistic: state.copyWith(
          canRescheduleMemberSessions: !state.canRescheduleMemberSessions,
        ),
      );

  /// Optimistik günceller (anında geri bildirim), yazma başarısız olursa
  /// önceki değere geri alır — GymThemeController.selectTheme'deki aynı
  /// desen.
  Future<void> _apply(
    List<String> trainerIds, {
    required String field,
    required Object value,
    required AdminPermissions optimistic,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null || trainerIds.isEmpty) return;
    final previous = state;
    state = optimistic;
    try {
      // Hepsi aynı gyms/{gymId} dokümanının iç içe bir alanı olduğu için
      // (ayrı dokümanlar değil), her antrenör için tek bir WriteBatch'te
      // ayrı .set() çağrısı yapılamaz (aynı dokümana ikinci kez dokunmak
      // hata verir) — tek bir merge write'ta birleştiriliyor.
      final update = <String, dynamic>{
        for (final trainerId in trainerIds) trainerId: {field: value},
      };
      await FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
        'trainerPermissions': update,
      }, SetOptions(merge: true));
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}
