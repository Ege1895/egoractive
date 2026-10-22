import 'package:egoractive/modules/gyms/domain/gym_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GymTheme _theme(String id) => GymTheme(
  id: id,
  name: id,
  primary: const Color(0xFF000000),
  soft: const Color(0xFF111111),
  note: '',
);

void main() {
  group('isGymThemeDeletable', () {
    // Admin, uygulamayla gelen hazır temaları silemez; "liste şişiyor"
    // şikâyetinin kaynağı olan kendi eklediklerini silebilir.
    test('hazır temalar silinemez', () {
      expect(isGymThemeDeletable('egora-mavisi'), isFalse);
      expect(isGymThemeDeletable('turuncu-enerji'), isFalse);
      expect(isGymThemeDeletable('yesil-doga'), isFalse);
    });

    test('admin eklentileri ve logodan türetilenler silinebilir', () {
      expect(isGymThemeDeletable('custom-1788378832'), isTrue);
      expect(isGymThemeDeletable('logo-ff8a3d'), isTrue);
    });
  });

  group('sortedGymThemes', () {
    test('varsayılan tema en üste taşınır', () {
      final sorted = sortedGymThemes([
        _theme('custom-a'),
        _theme('egora-mavisi'),
        _theme('custom-b'),
      ]);
      expect(sorted.map((t) => t.id), [
        'egora-mavisi',
        'custom-a',
        'custom-b',
      ]);
    });

    test('kalanların göreli sırası korunur', () {
      final sorted = sortedGymThemes([
        _theme('custom-a'),
        _theme('custom-b'),
        _theme('egora-mavisi'),
        _theme('custom-c'),
      ]);
      expect(sorted.map((t) => t.id).skip(1), [
        'custom-a',
        'custom-b',
        'custom-c',
      ]);
    });

    test('zaten en üstteyse liste aynen döner', () {
      final input = [_theme('egora-mavisi'), _theme('custom-a')];
      expect(sortedGymThemes(input).map((t) => t.id), [
        'egora-mavisi',
        'custom-a',
      ]);
    });

    // Varsayılan tema silinemediği için normalde olmaz, ama eski/elle
    // düzenlenmiş bir `themePresets` dizisinde eksik olabilir.
    test('varsayılan tema listede yoksa sıra bozulmaz', () {
      final input = [_theme('custom-a'), _theme('custom-b')];
      expect(sortedGymThemes(input).map((t) => t.id), ['custom-a', 'custom-b']);
    });

    test('boş listede çökmez', () {
      expect(sortedGymThemes(const []), isEmpty);
    });
  });
}
