import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_trainer_summary.dart';

/// `users/{uid}` (role=trainer) dokümanını [AdminTrainerSummary]'ye çevirir.
/// `memberCount`, üye dokümanlarındaki denormalize `trainerName` alanıyla
/// eşleştirilerek [AdminTrainersController] tarafından ayrıca hesaplanır —
/// bu fonksiyon sadece trainer dokümanının kendi alanlarını çevirir.
AdminTrainerSummary adminTrainerSummaryFromDoc(
  QueryDocumentSnapshot<Map<String, dynamic>> doc, {
  required int memberCount,
}) {
  final data = doc.data();
  final name = (data['name'] as String?)?.trim() ?? '';
  final specialtiesData =
      (data['specialties'] as List?)?.whereType<String>().toList() ?? const [];
  return AdminTrainerSummary(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    phone: (data['phoneNumber'] as String?) ?? '',
    specialties: specialtiesData.isEmpty
        ? const ['Fonksiyonel']
        : specialtiesData,
    memberCount: memberCount,
  );
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}
