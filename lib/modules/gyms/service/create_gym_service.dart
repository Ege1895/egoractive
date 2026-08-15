import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/gym_logo_constants.dart';
import '../domain/gym_profile.dart';

part 'create_gym_service.g.dart';

/// F2-1 — salon oluşturma: logoyu Cloud Storage'a yükler, `gyms/{gymId}`
/// dokümanını yazar, oluşturan kullanıcının `users/{uid}` dokümanına
/// `role: admin` + `gymId` yazar (F2-5'teki trigger bunu custom claim'e
/// çevirir).
class CreateGymService {
  const CreateGymService();

  Future<String> createGym({
    required GymProfile profile,
    required Color themeColor,
    required XFile logoFile,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Salon oluşturmak için oturum açmış bir kullanıcı gerekiyor.');
    }

    final gymRef = FirebaseFirestore.instance.collection('gyms').doc();
    final logoRef = FirebaseStorage.instance.ref('gym_logos/${gymRef.id}.png');
    await logoRef.putData(
      _toLogoPng(await logoFile.readAsBytes()),
      SettableMetadata(contentType: 'image/png'),
    );
    final logoUrl = await logoRef.getDownloadURL();

    await gymRef.set({
      'name': profile.name,
      'city': profile.city,
      'phone': profile.phone,
      'address': profile.address,
      'logoUrl': logoUrl,
      'themeColors': {'primary': _toHex(themeColor)},
      // F6-1/F6-3 — her salon 'trial' olarak başlar; 'active'e geçiş sadece
      // verifySubscriptionPurchase Cloud Function'ı üzerinden (Admin SDK,
      // kurallara tabi değil) olur — firestore.rules bu alanları admin'in
      // doğrudan değiştirmesini engelliyor.
      'subscriptionStatus': 'trial',
      'trialStartedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': 'admin',
      'gymId': gymRef.id,
    }, SetOptions(merge: true));

    return gymRef.id;
  }

  String _toHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  /// Storage'ı ücretsiz kotada tutmak için logo her zaman en fazla
  /// [gymLogoMaxDimension]x[gymLogoMaxDimension] boyutuna küçültülüp PNG
  /// olarak encode edilir — `storage.rules`'daki boyut sınırı bunun
  /// yalnızca güvenlik tabanıdır, gerçek garanti burada verilir.
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
