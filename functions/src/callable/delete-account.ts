import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc } from "../shared/firestore-paths";

/**
 * F2-8 — Apple'ın zorunlu kıldığı hesap silme akışı. Çağıranın kendi
 * Firestore `users/{uid}` dokümanını (kişisel veri) ve Firebase Auth
 * kaydını siler. Salon verisi (gyms/*) admin'e ait olduğundan silinmez —
 * sadece kullanıcıya özel doküman kaldırılır.
 *
 * `users/{uid}` silindiği için F1-10'daki `requestCustomToken` bir sonraki
 * girişte bu numarayı bulamaz — "aynı numarayla tekrar giriş yapılamıyor"
 * kabul kriteri buradan geliyor.
 */
export const deleteAccount = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Bu işlem için oturum açmış olman gerekiyor.");
  }

  await getFirestore().doc(userDoc(uid)).delete();
  await getAuth().deleteUser(uid);

  return { ok: true };
});
