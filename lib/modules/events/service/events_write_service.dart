import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/capacity_service.dart';

part 'events_write_service.g.dart';

/// F4-3 — `events/{id}` üzerinde oluşturma + katılım/ayrılma. Kontenjan
/// mantığı grup dersleriyle ortak `CapacityService`'te (kod tekrarını
/// önlemek F4-3'ün kabul kriteri).
class EventsWriteService {
  const EventsWriteService(this._capacityService);

  final CapacityService _capacityService;

  Future<void> createEvent({
    required String gymId,
    required String name,
    required String location,
    required DateTime dateTime,
    required String description,
    int? capacity,
  }) async {
    await FirebaseFirestore.instance.collection('events').add({
      'gymId': gymId,
      'name': name,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'capacity': capacity,
      'attendeeIds': <String>[],
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin'in düzenleme ekranından (bkz. `create_event_panel.dart` edit
  /// modu) mevcut bir etkinliği günceller.
  Future<void> updateEvent({
    required String eventId,
    required String name,
    required String location,
    required DateTime dateTime,
    required String description,
    int? capacity,
  }) {
    return FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'name': name,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'description': description,
      'capacity': capacity,
    });
  }

  /// Etkinlik listeden kaldırılmaz — `status: cancelled` ile işaretlenir,
  /// admin ekranında iptal rozetiyle listelenmeye devam eder; üye/antrenör
  /// Keşfet akışından filtrelenir (bkz. `discover_controller.dart`).
  Future<void> cancelEvent(String eventId) {
    return FirebaseFirestore.instance.collection('events').doc(eventId).update({
      'status': 'cancelled',
    });
  }

  Future<void> join({required String eventId, required String uid}) {
    return _capacityService.join(
      ref: FirebaseFirestore.instance.collection('events').doc(eventId),
      uid: uid,
    );
  }

  Future<void> leave({required String eventId, required String uid}) {
    return _capacityService.leave(
      ref: FirebaseFirestore.instance.collection('events').doc(eventId),
      uid: uid,
    );
  }
}

@riverpod
EventsWriteService eventsWriteService(EventsWriteServiceRef ref) =>
    EventsWriteService(ref.watch(capacityServiceProvider));
