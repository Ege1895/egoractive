import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc } from "../shared/firestore-paths";
import { mintLoginToken } from "../shared/login-token";
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
 * §5/§6 — `sendEmailSetupOtp`'un ikinci adımı. Doğrulanan email
 * `users/{uid}`'e yazılır ve aynı çağrıda giriş token'ı da üretilir — hem
 * henüz hiç oturumu olmayan ilk aktivasyonu (§5) hem zaten oturum açık
 * mevcut hesabın email tamamlamasını (§6) TEK callable karşılar; ikinci
 * durumda aynı uid'e tekrar `signInWithCustomToken` yapmak zararsızdır.
 */
export const verifyEmailSetupOtp = onCall(async (request) => {
  const uid = typeof request.data?.uid === "string" ? request.data.uid : "";
  const code = typeof request.data?.code === "string" ? request.data.code : "";
  if (!uid || !code) {
    throw new HttpsError("invalid-argument", "uid ve kod gerekli.");
  }

  const result = await verifyOtp({ purpose: "activation", uid, code });
  if (!result.ok) {
    throw new HttpsError(reasonToCode(result.reason), "Kod doğrulanamadı.");
  }

  await getFirestore()
    .doc(userDoc(uid))
    .update({ email: result.email, emailLower: result.email.toLowerCase() });

  const token = await mintLoginToken(uid);
  return { token };
});
