// Tek seferlik asset üretici — assets/icon/app_icon.png'den PDF filigranı için
// küçük, saydam arka planlı bir PNG çıkarır. Çıktı: assets/images/pdf_watermark.png
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as im;

const _targetSize = 72; // px — PDF'te ~20pt basılacak (~260 dpi)
const _alphaLow = 0.10; // bu parlaklığın altı tamamen saydam (arka plan)
const _alphaHigh = 0.62; // bu parlaklığın üstü tamamen opak (asıl işaret)

void main() {
  final src = im.decodePng(File('assets/icon/app_icon.png').readAsBytesSync())!;
  final rgba = im.Image(width: src.width, height: src.height, numChannels: 4);

  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
      final l = math.max(r, math.max(g, b)) / 255.0;
      final a = ((l - _alphaLow) / (_alphaHigh - _alphaLow)).clamp(0.0, 1.0);
      if (a <= 0) {
        rgba.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      // İkon siyah zemin üzerine composite edilmiş; alfayı geri çıkarırken
      // rengi un-premultiply ediyoruz ki kenarlar grileşmesin.
      int un(double c) => (c / math.max(a, 0.15)).clamp(0, 255).round();
      rgba.setPixelRgba(x, y, un(r), un(g), un(b), (a * 255).round());
    }
  }

  final trimmed = im.trim(rgba, mode: im.TrimMode.transparent);
  // En-boy oranı korunur: yükseklik sabitlenir, genişlik ondan türetilir.
  final resized = im.copyResize(
    trimmed,
    height: _targetSize,
    interpolation: im.Interpolation.average,
  );

  final bytes = im.encodePng(resized, level: 9);
  File('assets/images/pdf_watermark.png').writeAsBytesSync(bytes);
  stdout.writeln(
    'kaynak ${src.width}x${src.height} -> trim ${trimmed.width}x${trimmed.height} '
    '-> çıktı ${resized.width}x${resized.height}, ${bytes.length} bayt',
  );
}
