import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capacity_service.g.dart';

/// F4-2/F4-3 — kontenjanlı katılım listelerinin (grup dersleri, etkinlikler)
/// ortak "katıl/ayrıl" mantığı. Her iki modül de aynı doküman şeklini
/// kullanır: `attendeeIds` (string dizisi) ve `capacity` (nullable sayı —
/// `null` sınırsız kontenjan demektir, hiç kontrol yapılmaz).
///
/// Kontenjan kontrolü bir `runTransaction` içinde yapılır — Firestore'un
/// aynı doküman üzerindeki eşzamanlı transaction'ları otomatik retry ile
/// serileştirme mekanizması sayesinde kontenjan hiçbir zaman aşılmaz.
class CapacityService {
  const CapacityService();

  /// Zaten katılmışsa no-op; kontenjan doluysa hata fırlatır.
  Future<void> join({
    required DocumentReference<Map<String, dynamic>> ref,
    required String uid,
  }) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) throw StateError('Kayıt bulunamadı.');

      final attendeeIds = List<String>.from(data['attendeeIds'] as List? ?? const []);
      if (attendeeIds.contains(uid)) return;

      final capacity = data['capacity'] as num?;
      if (capacity != null && attendeeIds.length >= capacity.toInt()) {
        throw StateError('Kontenjan doldu.');
      }

      transaction.update(ref, {'attendeeIds': FieldValue.arrayUnion([uid])});
    });
  }

  Future<void> leave({
    required DocumentReference<Map<String, dynamic>> ref,
    required String uid,
  }) async {
    await ref.update({'attendeeIds': FieldValue.arrayRemove([uid])});
  }
}

@riverpod
CapacityService capacityService(CapacityServiceRef ref) => const CapacityService();
