import 'dart:convert';
import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/utils/gym_logo_image.dart';
import '../domain/gym_profile.dart';

part 'create_gym_service.g.dart';

/// F2-9 — salon oluşturma: bu ekrana henüz hiçbir Firebase Auth oturumu
/// olmayan yeni bir antrenör "kendi salonumu açıyorum" akışından ulaşır, bu
/// yüzden yazma işlemi client'ta doğrudan Firestore/Storage'a değil,
/// `signupGymAdmin` callable'ına (Admin SDK, kurallara tabi değil) yapılır.
/// O fonksiyon `gyms` dokümanını, logoyu ve `users/{uid}` (`role: admin`)
/// dokümanını oluşturur — F2-5'teki trigger bunu custom claim'e çevirir,
/// kullanıcı da girdiği telefon numarasıyla `requestCustomToken` üzerinden
/// (F1-10) ilk girişini yapınca gerçek Auth hesabı lazy olarak oluşur.
class CreateGymService {
  const CreateGymService();

  Future<String> createGym({
    required GymProfile profile,
    required Color themeColor,
    XFile? logoFile,
  }) async {
    // Seans hatırlatma push'larının salonun bulunduğu yerin saatine göre
    // gösterilebilmesi için (bkz. sendSessionReminderTask) — cihazın o anki
    // IANA saat dilimi, salon kaydı burada bir kere yapılırken kaydediliyor.
    String? timeZone;
    try {
      timeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
    } on Exception {
      // Alınamazsa Cloud Functions tarafı Europe/Istanbul'a düşer.
    }

    final result = await FirebaseFunctions.instance
        .httpsCallable('signupGymAdmin')
        .call<Map<String, dynamic>>({
          'name': profile.name,
          'city': profile.city,
          // profile.phone sadece 10 haneli rakam (GymProfileController) — F1-10
          // login akışıyla (AuthService) aynı '+90' + rakam formatına burada
          // çevriliyor, yoksa requestCustomToken bu numarayı bulamaz.
          'phoneNumber': '+90${profile.phone}',
          'address': profile.address,
          'themeColorHex': _toHex(themeColor),
          if (timeZone != null) 'timeZone': timeZone,
          if (logoFile != null)
            'logoBase64': base64Encode(
              encodeGymLogoPng(await logoFile.readAsBytes()),
            ),
        });
    return result.data['gymId'] as String;
  }

  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

@riverpod
CreateGymService createGymService(CreateGymServiceRef ref) =>
    const CreateGymService();
