import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_member_summary.freezed.dart';

enum MemberPackageStatus { active, endingSoon, none }

@freezed
class AdminMemberSummary with _$AdminMemberSummary {
  const factory AdminMemberSummary({
    required String id,
    required String initials,
    required String name,
    required String phone,
    required String trainerName,

    /// F12-2 — üye sayımı ve antrenör eşlemesi bunun üzerinden yapılır;
    /// [trainerName] yalnızca GÖSTERİM içindir. Sayım isimle yapıldığında
    /// antrenörün adı değiştirilir değiştirilmez üye sayısı sıfıra
    /// düşüyordu. Varsayılan boş: mock/salon-yok akışları bu alanı
    /// doldurmuyor, oralarda sayım da yapılmıyor.
    @Default('') String trainerId,
    required int remainingSessions,

    /// Henüz takvime hiç girilmemiş, gerçekten yeni bir seans için
    /// kullanılabilir hak — `remainingSessions` (planlanmış + planlanmamış
    /// toplamı, "Üyeler" listesinde gösterilen) ile KARIŞTIRILMAMALI. Seans
    /// oluşturma ekranı (`create_session_sheet.dart`) bu alanı kullanır;
    /// aksi halde zaten tamamı takvime girilmiş bir üyeye "hakkı var" diye
    /// yeni seans atanmaya çalışılıp `InsufficientSessionsException` alınır.
    required int unplannedSessions,
    required String packageEndDate,
    required MemberPackageStatus status,
  }) = _AdminMemberSummary;
}
