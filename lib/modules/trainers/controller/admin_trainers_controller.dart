import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../members/controller/admin_members_controller.dart';
import '../domain/admin_trainer_summary.dart';
import '../domain/admin_trainer_summary_mapper.dart';
import '../repository/admin_trainers_repository.dart';

part 'admin_trainers_controller.g.dart';

@riverpod
Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _trainerDocsForGym(
  _TrainerDocsForGymRef ref,
  String gymId,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'trainer')
      .snapshots()
      // Admin'in pasife aldığı antrenörler (bkz. `deactivateTrainer`)
      // listelerde görünmez — ama `users` dokümanı ve ürettiği tüm veri
      // (seanslar, grup dersleri, üye atamaları, aylık istatistikler)
      // yerinde durur, raporlar bozulmaz.
      //
      // Filtre BİLEREK client tarafında: Firestore'da `isActive != false`
      // sorgusu, alanı HİÇ OLMAYAN dokümanları da dışarıda bırakırdı —
      // mevcut antrenörlerin hiçbirinde bu alan yok, hepsi kaybolurdu.
      // Alanın yokluğu "aktif" demek olduğu için karşılaştırma burada.
      .map(
        (snapshot) => snapshot.docs
            .where((doc) => doc.data()['isActive'] != false)
            .toList(),
      );
}

@riverpod
Stream<Map<String, dynamic>?> _userDoc(_UserDocRef ref, String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
}

/// F11-1/F11-5 — admin kendini antrenör olarak eklediyse, oluşan "gölge
/// antrenör" dokümanının id'si ve aktiflik durumu; hiç eklemediyse `null`.
///
/// Bağlantının kaynağı BİLEREK adminin KENDİ dokümanındaki
/// `trainerProfileUid` alanı, antrenör listesi değil: antrenörlükten
/// çıkıldığında gölge doküman `isActive: false` ile listeden düşer
/// ([_trainerDocsForGym] filtresi) ama bağ korunmalı — aksi halde ekleme
/// akışı İKİNCİ bir gölge doküman açar ve aylık istatistikler iki kayda
/// bölünürdü. Bu yüzden `trainerProfileUid` bir daha hiç silinmiyor;
/// "antrenör mü" sorusunun cevabı gölge dokümanın `isActive` alanı.
@riverpod
({String uid, bool isActive, String name, List<String> specialties})?
selfTrainerProfile(SelfTrainerProfileRef ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return null;
  final adminData = ref.watch(_userDocProvider(uid)).valueOrNull;
  final shadowUid = adminData?['trainerProfileUid'] as String?;
  if (shadowUid == null) return null;

  final shadowData = ref.watch(_userDocProvider(shadowUid)).valueOrNull;
  // Doküman henüz yüklenmediyse AKTİF varsayılıyor: `isActive` alanı hiç
  // yazılmamış eski kayıtlar da aktif sayıldığı için ([_trainerDocsForGym]
  // ile aynı kural) varsayılanın `true` olması tutarlı, ayrıca yükleme
  // anında ekleme akışının bir an "yeniden aktive et" durumuna düşmesini
  // önlüyor.
  return (
    uid: shadowUid,
    isActive: (shadowData?['isActive'] as bool?) ?? true,
    // F12-8 — antrenörlüğe geri dönerken form bunlarla ön-doldurulur;
    // gölge doküman listede olmadığı için (pasifken filtreleniyor) tek
    // kaynak burası.
    name: (shadowData?['name'] as String?) ?? '',
    specialties:
        (shadowData?['specialties'] as List?)?.whereType<String>().toList() ??
        const <String>[],
  );
}

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz — bu
/// durumda [AdminTrainersController] mock listeye düşer (bkz.
/// [AdminMembersController]'daki aynı desen).
@riverpod
class AdminTrainersController extends _$AdminTrainersController {
  @override
  List<AdminTrainerSummary> build() {
    final gymIdAsync = ref.watch(activeGymIdProvider);
    // F13-6 — provider ilk izlendiğinde henüz sonuçlanmamış olabilir; bu
    // durum "gerçekten salon yok" ile AYNI DEĞİL. O ana kadar mock'a
    // düşülürse kullanıcı bir an sahte veriyi gerçekmiş gibi görür ve
    // dokunduğunda var olmayan bir ID ile Firestore'a yazma denenir (bkz.
    // `discover_controller.dart`/`trainer_home_controller.dart` — aynı hata
    // orada yaşandı ve düzeltildi).
    if (gymIdAsync.isLoading) return const [];
    final gymId = gymIdAsync.valueOrNull;
    if (gymId == null) {
      return ref.watch(adminTrainersRepositoryProvider).loadTrainers();
    }
    final docs = ref.watch(_trainerDocsForGymProvider(gymId)).valueOrNull;
    if (docs == null) return const [];

    // `memberCount`, trainer dokümanında tutulmuyor — üye dokümanlarındaki
    // `trainerId` alanıyla sayılıyor (aynı üye listesi zaten
    // AdminMembersController üzerinden canlı izleniyor).
    //
    // F12-2 — sayım önceden denormalize `trainerName` alanıyla, yani İSİMLE
    // eşleştiriliyordu. `updateTrainer` üye dokümanlarındaki bu alana
    // dokunmadığı için antrenörün adı düzeltilir düzeltilmez eşleşme
    // kopuyor ve üye sayısı sıfıra düşüyordu. Kimlik alanı hiç değişmiyor,
    // bu yüzden sayım artık `trainerId` üzerinden.
    final members = ref.watch(adminMembersControllerProvider);
    final countByTrainerId = <String, int>{};
    for (final member in members) {
      if (member.trainerId.isEmpty) continue;
      countByTrainerId[member.trainerId] =
          (countByTrainerId[member.trainerId] ?? 0) + 1;
    }

    return docs
        .map(
          (doc) => adminTrainerSummaryFromDoc(
            doc,
            memberCount: countByTrainerId[doc.id] ?? 0,
          ),
        )
        .toList();
  }

  /// `users` koleksiyonuna `role: trainer` dokümanı yazar — aynı `users`
  /// koleksiyonu ve aynı yazma kuralları [MemberRegistrationService]
  /// tarafından üye eklerken de kullanılıyor (bkz. firestore.rules
  /// `match /users/{uid}`, admin için role'e özel bir kısıt yok).
  Future<void> addTrainer({
    required String name,
    required String phoneNumber,
    required List<String> specialties,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      throw StateError('Aktif salon bulunamadı.');
    }
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'trainer',
      'gymId': gymId,
      'specialties': specialties,
      // Seans Raporum'daki "Tüm zamanlar"ın alt sınırı ve "Özel" tarih
      // seçicisinin firstDate'i olarak kullanılıyor (bkz.
      // trainer_report_controller.dart) — üye kaydında zaten olan
      // createdAt'ın antrenör karşılığı, önceden hiç yazılmıyordu.
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// F11-1 — admin kendisini antrenör olarak ekler ("gölge antrenör").
  /// [addTrainer]'dan üç farkı var:
  ///
  /// 1. `phoneNumber` ve `email` alanları HİÇ yazılmaz (boş string olarak da
  ///    değil). `startLogin`'in iki kimlik sorgusu da (`phoneNumber ==` ve
  ///    `emailLower ==`) alanı olmayan dokümanı asla bulamaz, dolayısıyla bu
  ///    doküman giriş yapamaz ve adminin kendi giriş kimliğiyle çakışmaz.
  ///    `onUserWriteSyncPhoneIndex` de numarasız dokümanda hiçbir şey
  ///    yazmadığı için `phoneIndex` kirlenmez.
  /// 2. `notificationProxyUid` ile antrenöre giden push bildirimleri adminin
  ///    cihazına yönlendirilir — token KOPYALANMAZ, işaret edilir (bkz.
  ///    görev F11-2, `functions/src/shared/staff-notifications.ts`).
  /// 3. Adminin kendi dokümanına `trainerProfileUid` yazılır. Bu alan
  ///    antrenörlükten çıkılsa bile silinmez; F11-5 aynı dokümanı yeniden
  ///    aktive eder, böylece aylık istatistikler ikiye bölünmez.
  ///
  /// İki yazma tek `WriteBatch`'te: ikincisi başarısız olursa sahipsiz bir
  /// gölge doküman kalır, toggle tekrar görünür ve kullanıcı ikinci bir
  /// doküman açardı.
  ///
  /// F11-5 — daha önce eklenip antrenörlükten çıkılmışsa YENİ doküman
  /// açılmaz, mevcut gölge doküman yeniden aktive edilir: seanslar, aylık
  /// istatistikler ve rapor satırları tek bir `trainerId` altında kalmalı.
  /// İsim/uzmanlıklar formdan gelen güncel değerlerle tazelenir.
  Future<void> addSelfAsTrainer({
    required String name,
    required List<String> specialties,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      throw StateError('Aktif salon bulunamadı.');
    }
    final adminUid = ref.read(authStateProvider).valueOrNull?.uid;
    if (adminUid == null) {
      throw StateError('Oturum bulunamadı.');
    }

    final firestore = FirebaseFirestore.instance;
    final existing = ref.read(selfTrainerProfileProvider);
    if (existing != null) {
      await firestore.collection('users').doc(existing.uid).update({
        'name': name,
        'nameLower': name.toLowerCase(),
        'specialties': specialties,
        'isActive': true,
        // `deactivateTrainer`'ın bıraktığı izler temizlenir, yoksa aktif bir
        // antrenörün dokümanında "ne zaman/kim tarafından pasife alındı"
        // bilgisi asılı kalırdı.
        'deactivatedAt': FieldValue.delete(),
        'deactivatedBy': FieldValue.delete(),
      });
      return;
    }

    final shadowRef = firestore.collection('users').doc();
    await (firestore.batch()
          ..set(shadowRef, {
            'name': name,
            'nameLower': name.toLowerCase(),
            'role': 'trainer',
            'gymId': gymId,
            'specialties': specialties,
            'isActive': true,
            'notificationProxyUid': adminUid,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..update(firestore.collection('users').doc(adminUid), {
            'trainerProfileUid': shadowRef.id,
          }))
        .commit();
  }

  /// [phoneNumber] `null` ise alan HİÇ yazılmaz — boş string yazmak da
  /// olmazdı: gölge antrenör dokümanında (F11-1) `phoneNumber` alanının
  /// bulunmaması bilinçli bir tasarım, düzenleme sırasında alanın boş bir
  /// değerle oluşturulması o kaydı gereksizce kimlik sorgularının konusu
  /// haline getirirdi.
  Future<void> updateTrainer({
    required String id,
    required String name,
    required String? phoneNumber,
    required List<String> specialties,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final ref = firestore.collection('users').doc(id);

    // İsim değişip değişmediği UI'dan gelen kopyaya değil, dokümanın
    // KENDİ güncel değerine bakılarak belirleniyor — panel bayat bir
    // kopya taşıyor olabilir.
    final previousName = (await ref.get()).data()?['name'] as String?;

    await ref.update({
      'name': name,
      'phoneNumber': ?phoneNumber,
      'specialties': specialties,
    });

    if (previousName != null && previousName != name) {
      await _propagateTrainerName(trainerId: id, name: name);
    }
  }

  /// Antrenörün adı değiştiğinde, adın KOPYALANMIŞ olarak tutulduğu
  /// yerleri tazeler: üye dokümanları (F12-2) ve gelecekteki grup dersleri
  /// (F12-5). Bu kopyalar gösterim içindir; üye SAYISI artık `trainerId`
  /// üzerinden hesaplandığı için ona bağlı değil.
  ///
  /// Tüm yazmalar TEK bir listede toplanıp birlikte batch'leniyor: iki ayrı
  /// tarama iki ayrı batch turu açsaydı, ikincisi hata verdiğinde isim
  /// yarı güncellenmiş bir durumda kalırdı.
  ///
  /// Sorgular `gymId` filtresini ZORUNLU olarak taşıyor: `firestore.rules`
  /// hem `users` hem `groupSessions` okumasını `gymId == myGymId()` şartına
  /// bağlıyor ve Firestore, bir liste sorgusuna ancak kuralın kullandığı
  /// alan sorgunun kendi filtresinde de varsa izin veriyor.
  Future<void> _propagateTrainerName({
    required String trainerId,
    required String name,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;

    final updates = [
      ...await _memberNameUpdates(gymId: gymId, trainerId: trainerId, name: name),
      ...await _upcomingGroupSessionNameUpdates(
        gymId: gymId,
        trainerId: trainerId,
        name: name,
      ),
    ];
    if (updates.isEmpty) return;

    // Firestore'un 500 işlem sınırı — kalabalık bir antrenörde tek batch
    // yetmezdi.
    const batchLimit = 400;
    final firestore = FirebaseFirestore.instance;
    for (var i = 0; i < updates.length; i += batchLimit) {
      final batch = firestore.batch();
      for (final update in updates.skip(i).take(batchLimit)) {
        batch.update(update.$1, update.$2);
      }
      await batch.commit();
    }
  }

  Future<List<(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>>
  _memberNameUpdates({
    required String gymId,
    required String trainerId,
    required String name,
  }) async {
    final members = await FirebaseFirestore.instance
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('trainerId', isEqualTo: trainerId)
        .get();
    return members.docs
        .map((doc) => (doc.reference, {'trainerName': name}))
        .toList();
  }

  /// F12-5 — GELECEKTEKİ grup derslerindeki antrenör adı anlık görüntüsünü
  /// tazeler. GEÇMİŞ dersler BİLEREK dokunulmadan bırakılıyor: bir dersin
  /// kaydı, dersi o gün kimin verdiğini göstermeli — sonradan değişen bir
  /// isim geçmişi yeniden yazmamalı.
  ///
  /// Sorgu `gymId` + `startTime` üzerinden (mevcut composite index, bkz.
  /// `firestore.indexes.json`); antrenör eşleşmesi CLIENT tarafında
  /// yapılıyor. `trainerIds array-contains` filtresini sorguya eklemek yeni
  /// bir composite index gerektirirdi ve bir salonun gelecekteki ders sayısı
  /// zaten küçük.
  Future<List<(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>>
  _upcomingGroupSessionNameUpdates({
    required String gymId,
    required String trainerId,
    required String name,
  }) async {
    final upcoming = await FirebaseFirestore.instance
        .collection('groupSessions')
        .where('gymId', isEqualTo: gymId)
        .where('startTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .get();

    final updates =
        <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
    for (final doc in upcoming.docs) {
      final data = doc.data();
      final ids =
          (data['trainerIds'] as List?)?.whereType<String>().toList() ??
          const <String>[];
      final index = ids.indexOf(trainerId);
      if (index == -1) continue;

      // `trainerIds` ve `trainerNames` aynı sırayla yazılıyor (bkz.
      // `create_group_session_controller.dart` — ikisi de aynı seçili
      // antrenör listesinden üretiliyor), eşleme buna dayanıyor. Uzunluklar
      // tutmuyorsa (elle düzenlenmiş/bozuk kayıt) dokunulmuyor: yanlış
      // antrenörün adını ezmek, bayat bir isimden daha kötü.
      final names =
          (data['trainerNames'] as List?)?.whereType<String>().toList() ??
          const <String>[];
      if (index >= names.length) continue;
      if (names[index] == name) continue;

      final refreshed = [...names]..[index] = name;
      updates.add((doc.reference, {
        'trainerNames': refreshed,
        // Tekil `trainerName` geriye dönük uyumluluk için tutuluyor ve
        // yazma servisinde de aynı şekilde üretiliyor (bkz.
        // `group_sessions_write_service.dart:40`).
        'trainerName': refreshed.join(', '),
      }));
    }
    return updates;
  }
}
