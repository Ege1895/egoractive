import 'member_mock_profile.dart';

/// P3 (Antrenör modülü) UI-only aşamasında tüm panellerde tutarlı kalması
/// gereken mock antrenör + üye verisi — Faz 2'de gerçek Firestore verisiyle
/// değişecek. Tasarım kuralı: "Berk Aydın'ın üyesi Ayşe Yılmaz'ın kalan
/// dersi her yerde 6" — [MemberMockProfile] ile aynı değerleri paylaşır.
class TrainerMockMember {
  const TrainerMockMember({
    required this.id,
    required this.initials,
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.packageName,
    required this.remainingSessions,
    required this.packageEndDate,
  });

  final String id;
  final String initials;
  final String name;
  final String phone;
  final String memberSince;
  final String packageName;
  final int remainingSessions;
  final String packageEndDate;
}

abstract final class TrainerMockData {
  static const trainerName = MemberMockProfile.trainerName;
  static const trainerInitials = MemberMockProfile.trainerInitials;
  static const gymName = MemberMockProfile.gymName;
  static const specialty = MemberMockProfile.trainerSpecialty;

  /// Bu antrenöre bağlı üyeler — "başka antrenörün üyesi görünmüyor" kuralı
  /// bu listenin sadece Berk Aydın'a ait üyeleri içermesiyle sağlanır.
  static const members = [
    TrainerMockMember(
      id: 'ayse-yilmaz',
      initials: 'AY',
      name: MemberMockProfile.memberFullName,
      phone: '0532 418 76 05',
      memberSince: "14 Haziran'dan beri",
      packageName: MemberMockProfile.packageName,
      remainingSessions: MemberMockProfile.remainingSessions,
      packageEndDate: MemberMockProfile.packageEnd,
    ),
    TrainerMockMember(
      id: 'cem-demir',
      initials: 'CD',
      name: 'Cem Demir',
      phone: '0533 219 84 40',
      memberSince: "2 Mart'tan beri",
      packageName: 'Birebir 8 Seans',
      remainingSessions: 2,
      packageEndDate: '19 Ağu 2026',
    ),
    TrainerMockMember(
      id: 'zeynep-kaya',
      initials: 'ZK',
      name: 'Zeynep Kaya',
      phone: '0505 762 30 18',
      memberSince: "21 Nisan'dan beri",
      packageName: 'Birebir 12 Seans',
      remainingSessions: 9,
      packageEndDate: '3 Eki 2026',
    ),
    TrainerMockMember(
      id: 'mert-arslan',
      initials: 'MA',
      name: 'Mert Arslan',
      phone: '0542 887 15 62',
      memberSince: "9 Ocak'tan beri",
      packageName: 'Birebir 20 Seans',
      remainingSessions: 0,
      packageEndDate: '15 Ağu 2026',
    ),
  ];

  static TrainerMockMember memberById(String id) => members.firstWhere((m) => m.id == id);
}
