import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { gymDoc, userDoc } from "../shared/firestore-paths";
import { verifyOtp } from "../shared/otp";

function reasonToCode(reason: "expired" | "locked" | "invalid"): "deadline-exceeded" | "resource-exhausted" | "invalid-argument" {
  switch (reason) {
    case "expired":
      return "deadline-exceeded";
    case "locked":
      return "resource-exhausted";
    case "invalid":
      return "invalid-argument";
  }
}

/**
 * §10/§11/§12 — `sendEmailChangeOtp`'un ikinci adımı. Admin ise (§9/§10)
 * aynı email `gyms/{gymId}.reportEmails.gym`'e de yazılır — "Login ve rapor
 * e-postası" tek alan, iki kullanım yeri: giriş + salon raporları.
 */
export const verifyEmailChangeOtp = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Bu işlem için oturum açmış olman gerekiyor.");
  }

  const code = typeof request.data?.code === "string" ? request.data.code : "";
  if (!code) {
    throw new HttpsError("invalid-argument", "Kod gerekli.");
  }

  const result = await verifyOtp({ purpose: "emailChange", uid, code });
  if (!result.ok) {
    throw new HttpsError(reasonToCode(result.reason), "Kod doğrulanamadı.");
  }

  const firestore = getFirestore();
  const userRef = firestore.doc(userDoc(uid));
  await userRef.update({ email: result.email, emailLower: result.email.toLowerCase() });

  const userData = (await userRef.get()).data();
  const role = userData?.role;
  const gymId = typeof userData?.gymId === "string" ? userData.gymId : undefined;
  if (role === "admin" && gymId) {
    await firestore.doc(gymDoc(gymId)).update({ "reportEmails.gym": result.email });
  }

  return { ok: true };
});
