/// 8pt ızgara ve panel iskeleti sabitleri (CLAUDE.md §2.4 tasarım dili planı,
/// "8pt ızgara, 20pt kenar, 3 katlı panel"). Build-time sabit, iş kuralı
/// değil — bu yüzden Remote Config'e değil buraya ait (§2.5).
abstract final class AppSpacing {
  static const double unit = 8;

  static const double xs = unit * 0.5; // 4
  static const double sm = unit; // 8
  static const double md = unit * 1.5; // 12
  static const double lg = unit * 2; // 16
  static const double xl = unit * 2.5; // 20
  static const double xxl = unit * 4; // 32

  /// Panel kenar boşluğu.
  static const double screenEdge = xl;

  /// Kart arası boşluk.
  static const double cardGap = lg;

  /// Kart yarıçapı.
  static const double radiusCard = 20;

  /// Kart içi blok yarıçapı.
  static const double radiusInner = 14;

  /// Rozet/çip yarıçapı (tam yuvarlak).
  static const double radiusPill = 999;

  /// Panel header yüksekliği.
  static const double headerHeight = 56;

  /// Alt aksiyon (birincil buton) yüksekliği.
  static const double primaryActionHeight = 52;

  /// En küçük dokunma hedefi (WCAG/iOS/Android ortak taban).
  static const double minTouchTarget = 44;
}
