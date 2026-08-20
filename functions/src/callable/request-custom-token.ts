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
  const userData = snapshot.docs[0].data();
  const role = typeof userData.role === "string" ? userData.role : undefined;
  const gymId = typeof userData.gymId === "string" ? userData.gymId : null;
  const claims = role ? { role, gymId } : undefined;

  // İlk giriş için (Firebase Auth hesabı henüz yok — F2-9 lazy account
  // creation) `onUserRoleAssigned` trigger'ı `setCustomUserClaims`'i hesap
  // olmadan çağırmış olabilir ve kalıcı olarak başarısız olmuştur (Eventarc
  // yeniden dener ama anlık değil). Custom token'a claim'leri doğrudan
  // gömmek, ilk oturumun ID token'ında role/gymId'nin beklemeden hazır
  // olmasını garanti eder.
  const token = await getAuth().createCustomToken(uid, claims);

  // Hesap zaten varsa (dönen kullanıcı) claim'leri burada da tazeleriz ki
  // rol/salon değişikliği bir sonraki girişte yansısın. Hesap ilk kez bu
  // girişle oluşacaksa (lazy creation client'ta signInWithCustomToken ile
  // gerçekleşir) bu çağrı `auth/user-not-found` ile başarısız olur — token'a
  // zaten gömülü olan claim'ler o oturum için yeterlidir, retry'lı trigger
  // kalıcı claim'i sonradan tamamlar.
  if (claims) {
    try {
      await getAuth().setCustomUserClaims(uid, claims);
    } catch (error) {
      if ((error as { code?: string }).code !== "auth/user-not-found") throw error;
    }
  }

  return { token };
});
