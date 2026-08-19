import 'dart:typed_data';

import 'package:flutter/material.dart' show Color;
import 'package:image/image.dart' as img;
import 'package:palette_generator/palette_generator.dart';

import '../../core/constants/gym_logo_constants.dart';

/// Salon logosunu Storage'ın ücretsiz kotasında tutmak için her zaman en
/// fazla [gymLogoMaxDimension]x[gymLogoMaxDimension] boyutuna küçültüp PNG
/// olarak encode eder. Salon oluşturma (`CreateGymService`) ve mevcut
/// salonun logosunu değiştirme (`GymLogoService`) aynı sınırı kullanır.
Uint8List encodeGymLogoPng(Uint8List original) {
  final decoded = img.decodeImage(original);
  if (decoded == null) {
    throw const FormatException('Seçilen dosya geçerli bir görsel değil.');
  }
  final resized =
      decoded.width > gymLogoMaxDimension ||
          decoded.height > gymLogoMaxDimension
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? gymLogoMaxDimension : null,
          height: decoded.height > decoded.width ? gymLogoMaxDimension : null,
        )
      : decoded;
  final encoded = Uint8List.fromList(img.encodePng(resized));
  if (encoded.length > gymLogoMaxBytes) {
    throw const FormatException(
      'Logo dosyası çok büyük, daha küçük bir görsel seç.',
    );
  }
  return encoded;
}

/// `PaletteGenerator` sonucundan baskın/canlı renkleri çıkarır — salon
/// oluşturma (`CreateGymController`) ve mevcut salonun logosunu değiştirme
/// (`GymInfoPanel`) aynı öneri mantığını paylaşır.
List<Color> extractGymPaletteColors(PaletteGenerator generator) {
  final candidates = <Color?>[
    generator.dominantColor?.color,
    generator.vibrantColor?.color,
    generator.lightVibrantColor?.color,
    generator.darkVibrantColor?.color,
    generator.mutedColor?.color,
  ].whereType<Color>().toList();
  return _dedupeSimilarColors(candidates).take(5).toList();
}

/// Palette_generator'ın döndürdüğü roller (dominant/vibrant/muted vb.) çoğu
/// logoda birbirine çok yakın renkler verir — göz zar zor ayırt edebileceği
/// neredeyse aynı iki rengi ayrı seçenek olarak göstermemek için kaba bir
/// RGB mesafe eşiğiyle eleniyor.
List<Color> _dedupeSimilarColors(List<Color> colors) {
  const threshold = 24;
  final result = <Color>[];
  for (final color in colors) {
    final isSimilar = result.any((kept) {
      final dr = (kept.r - color.r).abs() * 255;
      final dg = (kept.g - color.g).abs() * 255;
      final db = (kept.b - color.b).abs() * 255;
      return dr < threshold && dg < threshold && db < threshold;
    });
    if (!isSimilar) result.add(color);
  }
  return result;
}
