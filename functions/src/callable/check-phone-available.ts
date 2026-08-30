import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { usersCollection } from "../shared/firestore-paths";

/**
 * Üye ekleme akışında `phoneNumber` tüm `users` koleksiyonunda global olarak
 * benzersiz olmalı (F1-10'daki `requestCustomToken` girişte salon
 * gözetmeksizin ilk eşleşen dokümanı kullanıyor). Bu yüzden client bunu
 * doğrudan bir Firestore `list` sorgusuyla kontrol edemez: `firestore.rules`
 * `users` `allow read` kuralı `resource.data.gymId == myGymId()` gerektirir
 * ve bu, gymId filtresi olmayan bir `list` sorgusunda Firestore tarafından
 * provably-safe kabul edilmez — istek her zaman permission-denied ile
 * reddedilir (admin başka salonların üye verisini göremez). Bu callable
 * Admin SDK ile kuralları atlayıp sadece bir boolean döner, başka salonun
 * üye verisini client'a hiç sızdırmaz.
 *
 * Admin üye/antrenör eklerken KULLANICININ girdiği bir numarayı kontrol
 * eder; member/trainer kendi profilini düzenlerken (bkz.
 * `member_self_info_panel.dart`/`trainer_info_panel.dart`) KENDİ yeni
 * numarasını kontrol eder — ikisi de sadece oturum açmış olmayı gerektirir,
 * role'e özel bir kısıtlama yok (sonuç sadece bir boolean, hiçbir kullanıcı
 * verisi sızdırmıyor).
 */
export const checkPhoneAvailable = onCall(async (request) => {
  if (!request.auth?.uid) {
    throw new HttpsError("unauthenticated", "Bu işlem için oturum açmış olman gerekiyor.");
  }

  const phoneNumber = typeof request.data?.phoneNumber === "string" ? request.data.phoneNumber.trim() : "";
  if (!phoneNumber) {
    throw new HttpsError("invalid-argument", "Telefon numarası gerekli.");
  }

  const snapshot = await getFirestore()
    .collection(usersCollection())
    .where("phoneNumber", "==", phoneNumber)
    .limit(1)
    .get();

  return { available: snapshot.empty };
});
