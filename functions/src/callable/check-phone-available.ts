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
 */
export const checkPhoneAvailable = onCall(async (request) => {
  const role = request.auth?.token?.role as string | undefined;
  if (!request.auth?.uid || role !== "admin") {
    throw new HttpsError("permission-denied", "Bu işlem için salon admin'i olarak oturum açmış olman gerekiyor.");
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
