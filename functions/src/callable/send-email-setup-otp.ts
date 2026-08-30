import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc, usersCollection } from "../shared/firestore-paths";
import { sendOtpToEmail } from "../shared/otp";

/**
 * Egoractive Authentication Sistemi §5/§6 — admin tarafından oluşturulmuş
 * (email boş) bir member/trainer'ın ilk aktivasyonu VEYA email'i boş
 * mevcut bir hesabın app açılışında yakalanıp email eklettirilmesi. İkisi de
 * unauthenticated çağrılır (aktivasyonda henüz Firebase Auth oturumu yok —
 * F2-9'daki lazy account creation ile aynı güven modeli); `uid` zaten
 * `startLogin`'den ya da mevcut oturumdan client'a geçmiş oluyor.
 */
export const sendEmailSetupOtp = onCall(async (request) => {
  const uid = typeof request.data?.uid === "string" ? request.data.uid : "";
  const rawEmail = typeof request.data?.email === "string" ? request.data.email.trim() : "";
  if (!uid || !rawEmail) {
    throw new HttpsError("invalid-argument", "uid ve email gerekli.");
  }
  const email = rawEmail;
  const emailLower = email.toLowerCase();

  const firestore = getFirestore();
  const userSnap = await firestore.doc(userDoc(uid)).get();
  if (!userSnap.exists) {
    throw new HttpsError("not-found", "Kullanıcı bulunamadı.");
  }
  if (typeof userSnap.data()?.email === "string" && userSnap.data()?.email) {
    throw new HttpsError("failed-precondition", "Bu hesapta zaten kayıtlı bir email var.");
  }

  const taken = await firestore
    .collection(usersCollection())
    .where("emailLower", "==", emailLower)
    .limit(1)
    .get();
  if (!taken.empty && taken.docs[0].id !== uid) {
    throw new HttpsError("already-exists", "Bu email adresi başka bir hesapta kayıtlı.");
  }

  const result = await sendOtpToEmail({ purpose: "activation", uid, email });
  if (!result.ok) {
    throw new HttpsError("resource-exhausted", "Çok fazla deneme yapıldı, biraz sonra tekrar dene.");
  }

  return { ok: true };
});
