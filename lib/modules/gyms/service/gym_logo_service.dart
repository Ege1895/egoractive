import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/utils/gym_logo_image.dart';

part 'gym_logo_service.g.dart';

/// Mevcut bir salonun logosunu değiştirme — [CreateGymService]'ten farklı
/// olarak salon zaten var (`gymId` biliniyor) ve admin zaten oturum açmış,
/// bu yüzden `signupGymAdmin` callable'ına değil doğrudan Storage/Firestore'a
/// yazılır (`storage.rules`'taki `gym_logos/{fileName}` girişli-kullanıcı
/// kuralı ve `gyms/{gymId}` admin update kuralı buna izin veriyor).
class GymLogoService {
  const GymLogoService();

  Future<XFile?> pickLogo() {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  /// Logoyu `gym_logos/{gymId}.png`'ye yükler, `gyms/{gymId}.logoUrl`'ü
  /// günceller ve yeni URL'i döner.
  Future<String> uploadLogo({
    required String gymId,
    required XFile file,
  }) async {
    final bytes = encodeGymLogoPng(await file.readAsBytes());
    final storageRef = FirebaseStorage.instance.ref('gym_logos/$gymId.png');
    await storageRef.putData(bytes, SettableMetadata(contentType: 'image/png'));
    final url = await storageRef.getDownloadURL();
    await FirebaseFirestore.instance.collection('gyms').doc(gymId).update({
      'logoUrl': url,
    });
    return url;
  }
}

@riverpod
GymLogoService gymLogoService(GymLogoServiceRef ref) => const GymLogoService();
