import { FieldValue } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { usersCollection } from "../shared/firestore-paths";
import { withFailureAlerting } from "../shared/function-health";

export interface ClaimsUpdate {
  role: string;
  gymId: string | null;
}

/**
 * Saf karar mantığı (Firebase'siz test edilebilir) — `users/{uid}`
 * dokümanının önceki/sonraki hâlini karşılaştırıp custom claim'in
 * güncellenmesi gerekip gerekmediğine karar verir.
 *
 * Trigger'ın kendi yazdığı `claimsSyncedAt` alanı burada hiç okunmuyor —
 * bu yüzden o alanı yazmak `role`/`gymId` değişmediği sürece bir sonraki
 * tetiklenmede `null` döner ve sonsuz döngü oluşmaz (F2-5 kabul kriteri).
 */
export function resolveClaimsUpdate(
  beforeData: Record<string, unknown> | undefined,
  afterData: Record<string, unknown> | undefined,
): ClaimsUpdate | null {
  if (!afterData) return null;

  const role = typeof afterData.role === "string" ? afterData.role : undefined;
  if (!role) return null;

  const gymId = typeof afterData.gymId === "string" ? afterData.gymId : null;
  const beforeRole = typeof beforeData?.role === "string" ? beforeData.role : undefined;
  const beforeGymId = typeof beforeData?.gymId === "string" ? beforeData.gymId : null;

  if (beforeRole === role && beforeGymId === gymId) return null;

  return { role, gymId };
}

/**
 * F2-5 — `users/{uid}` dokümanına `role`/`gymId` yazıldığında/güncellendiğinde
 * tetiklenir, `setCustomUserClaims` ile Firebase Auth'a yazar. Ayrıca
 * `claimsSyncedAt` alanını günceller (client'ın token yenilemesi gerektiğini
 * anlaması için) — bu yazım kendi role/gymId'sini değiştirmediğinden trigger'ı
 * tekrar anlamlı bir işe sürüklemez.
 */
export const onUserRoleAssigned = onDocumentWritten(
  // F2-9 — `signupGymAdmin` bu dokümanı, henüz hiçbir Firebase Auth hesabı
  // yokken (lazy account creation) yazıyor; bu yüzden `setCustomUserClaims`
  // ilk denemede `auth/user-not-found` ile başarısız olabilir. `retry: true`
  // olmadan bu hata kalıcı olur ve kullanıcı asla doğru claim'e kavuşamaz —
  // Eventarc'ın kendi backoff'uyla, kullanıcı `requestCustomToken` ile ilk
  // girişini yapıp hesabı oluştuktan sonra tekrar denenir.
  { document: `${usersCollection()}/{uid}`, retry: true },
  withFailureAlerting("onUserRoleAssigned", async (event) => {
    const before = event.data?.before;
    const after = event.data?.after;
    if (!after?.exists) return;

    const update = resolveClaimsUpdate(before?.exists ? before.data() : undefined, after.data());
    if (!update) return;

    await getAuth().setCustomUserClaims(event.params.uid, update);
    await after.ref.update({ claimsSyncedAt: FieldValue.serverTimestamp() });
  }),
);
