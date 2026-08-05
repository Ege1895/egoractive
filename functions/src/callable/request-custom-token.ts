import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { usersCollection } from "../shared/firestore-paths";

const RATE_LIMIT_WINDOW_MS = 60_000;
const RATE_LIMIT_MAX_REQUESTS = 5;

/**
 * Basit, örnek başına bellek içi rate-limit (F1-10 kabul kriteri: "aynı
 * numaradan dakikada N istek"). Fonksiyon soğuk başlatıldığında sıfırlanır —
 * kalıcı/dağıtık bir limit gerekirse Firestore/Redis'e taşınabilir, ama bu
 * fazda kapsam dışı.
 */
const requestTimestampsByPhone = new Map<string, number[]>();

function isRateLimited(phoneNumber: string): boolean {
  const now = Date.now();
  const recent = (requestTimestampsByPhone.get(phoneNumber) ?? []).filter(
    (timestamp) => now - timestamp < RATE_LIMIT_WINDOW_MS,
  );
  recent.push(now);
  requestTimestampsByPhone.set(phoneNumber, recent);
  return recent.length > RATE_LIMIT_MAX_REQUESTS;
}

/**
 * F1-10 — telefon numarasıyla `users` koleksiyonunda eşleşen kayıt aranır;
 * varsa custom token üretilir, yoksa açık bir hata kodu döner. Client bu
 * kodu (`not-found` / `resource-exhausted`) kullanıcıya anlamlı bir mesaja
 * çevirir (bkz. `lib/modules/auth/service/auth_service.dart`).
 */
export const requestCustomToken = onCall(async (request) => {
  const phoneNumber = typeof request.data?.phoneNumber === "string" ? request.data.phoneNumber.trim() : "";

  if (!phoneNumber) {
    throw new HttpsError("invalid-argument", "Telefon numarası gerekli.");
  }

  if (isRateLimited(phoneNumber)) {
    throw new HttpsError("resource-exhausted", "Çok fazla deneme yapıldı.");
  }

  const snapshot = await getFirestore()
    .collection(usersCollection())
    .where("phoneNumber", "==", phoneNumber)
    .limit(1)
    .get();

  if (snapshot.empty) {
    throw new HttpsError("not-found", "Bu numarayla kayıtlı bir kullanıcı bulunamadı.");
  }

  const uid = snapshot.docs[0].id;
  const token = await getAuth().createCustomToken(uid);
  return { token };
});
