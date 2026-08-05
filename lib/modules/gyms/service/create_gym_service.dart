import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    final logoRef = FirebaseStorage.instance.ref('gym_logos/${gymRef.id}.jpg');
    await logoRef.putData(
      await logoFile.readAsBytes(),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final logoUrl = await logoRef.getDownloadURL();

    await gymRef.set({
      'name': profile.name,
      'city': profile.city,
      'phone': profile.phone,
      'address': profile.address,
      'logoUrl': logoUrl,
      'themeColors': {'primary': _toHex(themeColor)},
    });

    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'role': 'admin',
      'gymId': gymRef.id,
    }, SetOptions(merge: true));

    return gymRef.id;
  }

  String _toHex(Color color) => '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
}

@riverpod
CreateGymService createGymService(CreateGymServiceRef ref) => const CreateGymService();
