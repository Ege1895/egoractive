import 'package:flutter/material.dart';

/// Hazır avatar renk paleti (Profilim — fotoğraf yükleme yok, sadece hazır
/// setten seçim). Salon temasından bağımsız, sabit bir seçenek listesi
/// olduğu için build-time const (CLAUDE.md §2.5).
abstract final class AppAvatarPalette {
  static const colors = [
    Color(0xFF05A6FA),
    Color(0xFF2ED393),
    Color(0xFFFFB020),
    Color(0xFFFF5F52),
    Color(0xFF8B7BFF),
    Color(0xFF28C2C9),
    Color(0xFFF06AA8),
    Color(0xFF93A3B4),
  ];
}
