import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/gym_logo_constants.dart';
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
    final result = await FirebaseFunctions.instance.httpsCallable('signupGymAdmin').call<Map<String, dynamic>>({
      'name': profile.name,
      'city': profile.city,
      // profile.phone sadece 10 haneli rakam (GymProfileController) — F1-10
      // login akışıyla (AuthService) aynı '+90' + rakam formatına burada
      // çevriliyor, yoksa requestCustomToken bu numarayı bulamaz.
      'phoneNumber': '+90${profile.phone}',
      'address': profile.address,
      'themeColorHex': _toHex(themeColor),
      if (logoFile != null) 'logoBase64': base64Encode(_toLogoPng(await logoFile.readAsBytes())),
    });
    return result.data['gymId'] as String;
  }

  String _toHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  /// Storage'ı ücretsiz kotada tutmak için logo her zaman en fazla
  /// [gymLogoMaxDimension]x[gymLogoMaxDimension] boyutuna küçültülüp PNG
  /// olarak encode edilir — `signupGymAdmin` fonksiyonundaki boyut sınırı
  /// bunun yalnızca güvenlik tabanıdır, gerçek garanti burada verilir.
  Uint8List _toLogoPng(Uint8List original) {
    final decoded = img.decodeImage(original);
    if (decoded == null) {
      throw const FormatException('Seçilen dosya geçerli bir görsel değil.');
    }
    final resized = decoded.width > gymLogoMaxDimension || decoded.height > gymLogoMaxDimension
        ? img.copyResize(
            decoded,
            width: decoded.width >= decoded.height ? gymLogoMaxDimension : null,
            height: decoded.height > decoded.width ? gymLogoMaxDimension : null,
          )
        : decoded;
    final encoded = Uint8List.fromList(img.encodePng(resized));
    if (encoded.length > gymLogoMaxBytes) {
      throw const FormatException('Logo dosyası çok büyük, daha küçük bir görsel seç.');
    }
    return encoded;
  }
}

@riverpod
CreateGymService createGymService(CreateGymServiceRef ref) => const CreateGymService();
