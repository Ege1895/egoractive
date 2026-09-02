import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { phoneIndexDoc, usersCollection } from "../shared/firestore-paths";
import { withFailureAlerting } from "../shared/function-health";

export interface PhoneIndexSync {
  /** Eski numaranın index kaydı — değiştiyse ya da hesap silindiyse temizlenir. */
  removePhone: string | null;
  /** Yeni/güncel numaranın index kaydı — yoksa (hesap silindiyse) yazılmaz. */
  writePhone: { phoneNumber: string; uid: string } | null;
}

/**
 * Saf karar mantığı — `users/{uid}` dokümanının önceki/sonraki hâlini
 * karşılaştırıp `phoneIndex`'te ne değişmesi gerektiğine karar verir.
 * `phoneNumber` değişmediyse (isim/telefon dışı bir alan güncellemesi, ör.
 * `fcmTokens`) hiçbir şey yapmaz — bkz. `resolveClaimsUpdate` (aynı desen,
 * `on-user-role-assigned.ts`).
 */
export function resolvePhoneIndexSync(
  uid: string,
  beforeData: Record<string, unknown> | undefined,
  afterData: Record<string, unknown> | undefined,
): PhoneIndexSync | null {
  const beforePhone = typeof beforeData?.phoneNumber === "string" ? beforeData.phoneNumber : null;
  const afterPhone = typeof afterData?.phoneNumber === "string" ? afterData.phoneNumber : null;

  if (beforePhone === afterPhone) return null;

  return {
    removePhone: beforePhone,
    writePhone: afterPhone ? { phoneNumber: afterPhone, uid } : null,
  };
}

/**
 * F2-2 perf — `checkPhoneAvailable` callable'ının (Cloud Run cold start'ında
 * tek başına 20-30+ saniyeye çıkabiliyordu) yerini alan `phoneIndex`
 * koleksiyonunu canlı tutar. `users/{uid}.phoneNumber` her yazıldığında/
 * değiştiğinde/hesap silindiğinde tetiklenir; client artık bu koleksiyonu
 * (sadece varlık kontrolü) doğrudan, ucuz bir point-read'le okuyor —
 * `member_registration_service.dart`/`trainer_registration_service.dart`.
 */
export const onUserWriteSyncPhoneIndex = onDocumentWritten(
  { document: `${usersCollection()}/{uid}`, retry: true },
  withFailureAlerting("onUserWriteSyncPhoneIndex", async (event) => {
    const before = event.data?.before;
    const after = event.data?.after;
    const sync = resolvePhoneIndexSync(
      event.params.uid,
      before?.exists ? before.data() : undefined,
      after?.exists ? after.data() : undefined,
    );
    if (!sync) return;

    const db = getFirestore();
    if (sync.removePhone) {
      await db.doc(phoneIndexDoc(sync.removePhone)).delete();
    }
    if (sync.writePhone) {
      await db.doc(phoneIndexDoc(sync.writePhone.phoneNumber)).set({
        uid: sync.writePhone.uid,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }),
);
