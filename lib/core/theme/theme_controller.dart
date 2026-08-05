import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../router/app_router.dart';
import 'app_color_scheme.dart';

part 'theme_controller.g.dart';

/// Oturum açan kullanıcının custom claim'indeki `gymId`. Gerçek claim
/// ataması F2-5'te (Custom Claims atama Cloud Function) yapılacağı için
/// şimdilik çoğunlukla `null` döner — bu durumda [ThemeController]
/// varsayılan temada kalır (F1-6 kabul kriteri: "salon yokken varsayılan
/// tema düzgün render ediliyor").
@riverpod
Future<String?> activeGymId(ActiveGymIdRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  final tokenResult = await user.getIdTokenResult();
  return tokenResult.claims?['gymId'] as String?;
}

/// Salon bazlı dinamik tema (CLAUDE.md §2.4). Aktif salon biliniyorsa
/// `gyms/{gymId}` dokümanındaki `themeColors.primary` alanını canlı dinler
/// (F1-6); salon yoksa varsayılan temada kalır.
///
/// `setAccentColor`, admin Salon Bilgileri/Temalar panelinde seçim
/// yaparken anlık önizleme için state'i optimistik olarak günceller — bir
/// sonraki Firestore emisyonu (gerçek kayıt F2'de) bunu teyit eder/geçersiz
/// kılar.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  Stream<AppColorScheme> build() async* {
    final gymId = await ref.watch(activeGymIdProvider.future);
    if (gymId == null) {
      yield AppColorScheme.defaultScheme();
      return;
    }

    yield* FirebaseFirestore.instance.collection('gyms').doc(gymId).snapshots().map((snapshot) {
      final hex = snapshot.data()?['themeColors']?['primary'] as String?;
      final color = _parseHexColor(hex);
      return color == null ? AppColorScheme.defaultScheme() : AppColorScheme.withAccent(color);
    });
  }

  void setAccentColor(Color primary) {
    state = AsyncData(AppColorScheme.withAccent(primary));
  }
}

/// `"#05A6FA"` veya `"05A6FA"` biçimindeki bir hex rengi ayrıştırır;
/// eksik/bozuksa `null` döner (çağıran taraf varsayılan temaya düşer).
Color? _parseHexColor(String? hex) {
  if (hex == null) return null;
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return null;
  final value = int.tryParse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16);
  return value == null ? null : Color(value);
}
