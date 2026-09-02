import { Firestore } from "firebase-admin/firestore";

import { usersCollection } from "./firestore-paths";

const LEGACY_TR_PREFIX = "+90";

/**
 * F8-3 — geçiş penceresi güvenliği. `users/{uid}.phoneNumber` F8-2 öncesi
 * hep çıplak (prefiksiz) 10 haneli TR numarasıydı; migration script'i
 * (`scripts/migrate-phone-e164.ts`) bunları `+90` önekiyle E.164'e çevirir,
 * ama migration çalışana KADAR hâlâ eski çıplak kayıtlar olabilir. Bu
 * fonksiyon, bir `+90` numarası için önce tam E.164'ü, bulamazsa eski
 * çıplak halini dener — TR dışı numaralarda (hiç çıplak karşılığı
 * olamayacağından) tek aday döner.
 *
 * Migration tamamlanıp doğrulandıktan sonra bu fallback kaldırılabilir.
 */
export function phoneLookupCandidates(value: string): string[] {
  if (!value.startsWith(LEGACY_TR_PREFIX)) return [value];
  const bareDigits = value.slice(LEGACY_TR_PREFIX.length);
  if (bareDigits.length === 0) return [value];
  return [value, bareDigits];
}

/**
 * `users` koleksiyonunda `phoneNumber`'ı `value`'ya (E.164) ya da onun
 * migrate edilmemiş çıplak TR haline eşit olan ilk dokümanı arar.
 */
export async function findUserByPhone(
  db: Firestore,
  value: string,
): Promise<FirebaseFirestore.QueryDocumentSnapshot | null> {
  for (const candidate of phoneLookupCandidates(value)) {
    const snapshot = await db
      .collection(usersCollection())
      .where("phoneNumber", "==", candidate)
      .limit(1)
      .get();
    if (!snapshot.empty) return snapshot.docs[0];
  }
  return null;
}
