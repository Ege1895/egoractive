import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { gymDoc, usersCollection } from "../shared/firestore-paths";
import { findUserByPhone } from "../shared/phone-lookup";
import { isDeactivated } from "../shared/user-active";
import { sendOtpToEmail } from "../shared/otp";

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 5;

/**
 * Basit, örnek başına bellek içi rate-limit — aynı desende F1-10'daki eski
 * `requestCustomToken`'da kullanılıyordu, buraya olduğu gibi taşındı.
 */
const requestTimestampsByIdentifier = new Map<string, number[]>();

function isRateLimited(identifier: string): boolean {
  const now = Date.now();
  const recent = (requestTimestampsByIdentifier.get(identifier) ?? []).filter(
    (timestamp) => now - timestamp < RATE_LIMIT_WINDOW_MS,
  );
  recent.push(now);
  requestTimestampsByIdentifier.set(identifier, recent);
  return recent.length > RATE_LIMIT_MAX_REQUESTS;
}

/**
 * Egoractive Authentication Sistemi — nihai giriş akışının ilk adımı.
 * Telefon numarası ya da email ile kullanıcı bulunur, salon abonelik
 * kontrolü yapılır (F1-10'daki `requestCustomToken`'dan taşındı), ve
 * kayıtlı email'e bir OTP gönderilir. Telefonla giriş denenip kullanıcının
 * email'i henüz boşsa (admin tarafından oluşturulmuş, hiç aktive olmamış
 * member/trainer) OTP göndermeden `needsEmailSetup:true` döner — client bu
 * durumda `sendEmailSetupOtp`'a geçer.
 */
export const startLogin = onCall(async (request) => {
  const identifierType = request.data?.identifierType;
  const rawValue = typeof request.data?.value === "string" ? request.data.value.trim() : "";
  if ((identifierType !== "phone" && identifierType !== "email") || !rawValue) {
    throw new HttpsError("invalid-argument", "Telefon numarası veya email gerekli.");
  }

  const value = identifierType === "email" ? rawValue.toLowerCase() : rawValue;
  if (isRateLimited(value)) {
    throw new HttpsError("resource-exhausted", "Çok fazla deneme yapıldı.");
  }

  const db = getFirestore();
  const matchedDoc =
    identifierType === "phone"
      ? await findUserByPhone(db, value)
      : (
          await db.collection(usersCollection()).where("emailLower", "==", value).limit(1).get()
        ).docs[0] ?? null;

  if (!matchedDoc) {
    throw new HttpsError("not-found", "Bu bilgiyle kayıtlı bir kullanıcı bulunamadı.");
  }

  const uid = matchedDoc.id;
  const userData = matchedDoc.data();

  // Admin bu hesabı pasife aldıysa giriş yok (bkz. `deactivateTrainer`).
  // BİLEREK "not-found" ile aynı mesaj: hesabın var olduğunu ve pasife
  // alındığını dışarıya sızdırmamak için — kullanıcı deneyimi açısından da
  // "bu bilgiyle kayıtlı kullanıcı yok" doğru bir ifade.
  if (isDeactivated(userData)) {
    throw new HttpsError("not-found", "Bu bilgiyle kayıtlı bir kullanıcı bulunamadı.");
  }

  const role = typeof userData.role === "string" ? userData.role : undefined;
  const gymId = typeof userData.gymId === "string" ? userData.gymId : null;

  // Salon Abonelik ve Erişim Akışı — antrenör/üye salonu aboneliği aktif
  // değilken hiç giriş yapamamalı; admin'e bu kısıtlama uygulanmaz.
  if (role && role !== "admin" && gymId) {
    const gymSnap = await db.doc(gymDoc(gymId)).get();
    const gymData = gymSnap.data();
    const status = gymData?.subscriptionStatus;
    const exempt = gymData?.subscriptionExempt === true;
    if (!exempt && status !== "trial" && status !== "active") {
      throw new HttpsError("failed-precondition", "SALON_SUBSCRIPTION_INACTIVE");
    }
  }

  const email = typeof userData.email === "string" ? userData.email : "";
  if (identifierType === "phone" && !email) {
    return { needsEmailSetup: true, uid };
  }

  const targetEmail = identifierType === "email" ? value : email;
  const result = await sendOtpToEmail({ purpose: "login", uid, email: targetEmail });
  if (!result.ok) {
    throw new HttpsError("resource-exhausted", "Çok fazla deneme yapıldı, biraz sonra tekrar dene.");
  }

  return { needsEmailSetup: false, uid, email: targetEmail };
});
