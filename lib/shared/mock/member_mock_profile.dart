/// P2 (Üye modülü) UI-only aşamasında tüm panellerde tutarlı kalması
/// gereken tek mock üye — Faz 2'de gerçek Firestore verisiyle değişecek.
/// Tasarım kuralı: "aynı Ayşe Yılmaz her ekranda aynı kalan ders sayısına
/// sahip olmalı" — bu sabitler o tutarlılığı tek yerden garanti eder.
abstract final class MemberMockProfile {
  static const memberFirstName = 'Ayşe';
  static const memberFullName = 'Ayşe Yılmaz';
  static const memberPhoneDigits = '5324187605';
  static const gymName = 'Vira Performans Stüdyo';
  static const trainerName = 'Berk Aydın';
  static const trainerSpecialty = 'Fonksiyonel antrenman';
  static const trainerInitials = 'BA';

  static const packageName = 'Birebir 12 Seans';
  static const remainingSessions = 6;
  static const totalSessions = 12;
  static const makeupSessions = 2;
  static const packageStart = '14 Haz 2026';
  static const packageEnd = '12 Eyl 2026';

  static const paymentAmount = '₺4.800';
  static const paymentDueDate = '8 Ağustos';
}
