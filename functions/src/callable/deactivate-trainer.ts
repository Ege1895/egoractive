import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc } from "../shared/firestore-paths";

/**
 * Admin · Antrenör Detayı > "Antrenörü sil" — antrenörün salonla ilişiğini
 * keser.
 *
 * 🔴 BU BİR SOFT-DELETE: `users/{trainerId}` dokümanı ve antrenörün ÜRETTİĞİ
 * HİÇBİR VERİ SİLİNMEZ. Seanslar, grup dersleri, üye atamaları ve aylık
 * antrenör istatistikleri olduğu gibi kalır — admin'in geçmiş raporlarında
 * bu antrenörün verileri görünmeye devam etmeli (ürün kararı). Silinen tek
 * şey erişim: hesap artık giriş yapamaz ve antrenör listelerinde çıkmaz.
 *
 * İki katmanlı engel (defense-in-depth):
 * 1. `users/{uid}.isActive = false` → `startLogin`/`mintLoginToken` reddeder,
 *    client tarafındaki antrenör listeleri bu antrenörü filtreler.
 * 2. Firebase Auth hesabı `disabled: true` → bir şekilde token üretilse bile
 *    `signInWithCustomToken` başarısız olur. Hesap henüz hiç oluşmamış
 *    olabilir (lazy account creation — kullanıcı ilk girişini yapana kadar
 *    Auth kaydı yoktur), o durumda `auth/user-not-found` beklenen bir sonuç
 *    ve yutulur: Firestore bayrağı zaten girişi engelliyor.
 */
export const deactivateTrainer = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  const role = request.auth?.token?.role as string | undefined;
  const gymId = request.auth?.token?.gymId as string | undefined;
  if (!callerUid || role !== "admin" || !gymId) {
    throw new HttpsError(
      "permission-denied",
      "Bu işlem için salon admin'i olarak oturum açmış olman gerekiyor.",
    );
  }

  const trainerId = typeof request.data?.trainerId === "string" ? request.data.trainerId : "";
  if (!trainerId) {
    throw new HttpsError("invalid-argument", "trainerId gerekli.");
  }
  if (trainerId === callerUid) {
    throw new HttpsError("invalid-argument", "Kendi hesabını bu akışla pasife alamazsın.");
  }

  const db = getFirestore();
  const ref = db.doc(userDoc(trainerId));
  const snap = await ref.get();
  const data = snap.data();
  if (!snap.exists || !data) {
    throw new HttpsError("not-found", "Antrenör bulunamadı.");
  }
  // Admin sadece KENDİ salonundaki bir antrenörü pasife alabilir.
  if (data.gymId !== gymId) {
    throw new HttpsError("permission-denied", "Bu antrenör senin salonuna ait değil.");
  }
  if (data.role !== "trainer") {
    throw new HttpsError("invalid-argument", "Bu hesap bir antrenör değil.");
  }

  await ref.update({
    isActive: false,
    deactivatedAt: FieldValue.serverTimestamp(),
    deactivatedBy: callerUid,
  });

  try {
    await getAuth().updateUser(trainerId, { disabled: true });
  } catch (error) {
    // Lazy account creation: kullanıcı hiç giriş yapmadıysa Auth kaydı yok.
    // Firestore bayrağı zaten `startLogin`'i engellediği için bu güvenli.
    if ((error as { code?: string }).code !== "auth/user-not-found") throw error;
  }

  return { ok: true };
});
