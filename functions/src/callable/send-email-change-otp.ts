import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc, usersCollection } from "../shared/firestore-paths";
import { sendOtpToEmail } from "../shared/otp";

/**
 * §10/§11/§12 — admin/member/trainer kendi profilinde email değiştirirken
 * çağırır. Yeni email doğrulanmadan hiçbir yere yazılmaz — bkz.
 * `verifyEmailChangeOtp`.
 */
export const sendEmailChangeOtp = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Bu işlem için oturum açmış olman gerekiyor.");
  }

  const rawEmail = typeof request.data?.newEmail === "string" ? request.data.newEmail.trim() : "";
  if (!rawEmail) {
    throw new HttpsError("invalid-argument", "Email gerekli.");
  }
  const newEmail = rawEmail;
  const emailLower = newEmail.toLowerCase();

  const firestore = getFirestore();
  const taken = await firestore
    .collection(usersCollection())
    .where("emailLower", "==", emailLower)
    .limit(1)
    .get();
  if (!taken.empty && taken.docs[0].id !== uid) {
    throw new HttpsError("already-exists", "Bu email adresi başka bir hesapta kayıtlı.");
  }

  const userSnap = await firestore.doc(userDoc(uid)).get();
  if (userSnap.data()?.email === newEmail) {
    throw new HttpsError("invalid-argument", "Bu zaten kayıtlı email adresin.");
  }

  const result = await sendOtpToEmail({ purpose: "emailChange", uid, email: newEmail });
  if (!result.ok) {
    throw new HttpsError("resource-exhausted", "Çok fazla deneme yapıldı, biraz sonra tekrar dene.");
  }

  return { ok: true };
});
