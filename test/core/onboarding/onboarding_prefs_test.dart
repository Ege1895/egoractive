import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egoractive/core/onboarding/onboarding_prefs.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to false before any login has ever completed', () async {
    await OnboardingPrefs.init();
    expect(OnboardingPrefs.hasCompletedFirstLogin, isFalse);
  });

  test('stays false merely because the role picker was shown', () async {
    // F8-5 sonrası bulunan gerçek hata: eskiden bu bayrak rol seçim ekranı
    // GÖSTERİLİR gösterilmez işaretleniyordu (bkz. `SplashPanel` git
    // geçmişi) — kullanıcı rol seçip telefon/salon kurulumunu
    // TAMAMLAMADAN uygulamayı kapatırsa bir daha asla rol seçim ekranını
    // göremiyordu. Artık sadece `markFirstLoginCompleted()` bunu değiştirir.
    await OnboardingPrefs.init();
    expect(OnboardingPrefs.hasCompletedFirstLogin, isFalse);
  });

  test('becomes true only after markFirstLoginCompleted is called', () async {
    await OnboardingPrefs.init();
    await OnboardingPrefs.markFirstLoginCompleted();
    expect(OnboardingPrefs.hasCompletedFirstLogin, isTrue);
  });

  test('persists across a fresh init (simulating app relaunch)', () async {
    await OnboardingPrefs.init();
    await OnboardingPrefs.markFirstLoginCompleted();

    await OnboardingPrefs.init();
    expect(OnboardingPrefs.hasCompletedFirstLogin, isTrue);
  });
}
