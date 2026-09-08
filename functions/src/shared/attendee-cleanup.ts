import { FieldValue, Firestore } from "firebase-admin/firestore";

/**
 * Kontenjanlı katılım listesi tutan KÖK koleksiyonlar. `firestore-paths.ts`
 * bunlar için `gyms/{gymId}/...` altında yardımcılar tanımlıyor ama gerçek
 * şema kök seviyede (bkz. oradaki `expenses` notu, aynı durum) —
 * `badge-check.ts:121` ve `report-extras-stats.ts:50` de kökten okuyor.
 */
const ATTENDEE_COLLECTIONS = ["groupSessions", "events"] as const;

/** Tek bir `WriteBatch`'e konulacak azami işlem (Firestore sınırı 500). */
const BATCH_LIMIT = 400;

/**
 * F12-1 — verilen kullanıcıyı grup dersi ve etkinliklerin `attendeeIds`
 * listelerinden çıkarır; güncellenen doküman sayısını döner.
 *
 * Neden gerekli: `deleteAccount` yalnızca `users/{uid}` dokümanını
 * siliyordu, uid katılım listelerinde kalıyordu. Kontenjan
 * `attendeeIds.size()` üzerinden hesaplandığı için (`firestore.rules` →
 * `withinCapacity()`, ayrıca client'taki `CapacityService`) silinmiş bir
 * üye kalıcı olarak bir yer işgal ediyor, ders dolu görünüyor ve başka
 * kimse katılamıyordu.
 *
 * GEÇMİŞ dersler de bilerek temizleniyor: geçmiş bir dersin katılımcı
 * listesinde silinmiş uid kalması rapor sayımlarını da bozar (bkz.
 * `report-extras-stats.ts`).
 */
export async function removeFromAttendeeLists(uid: string, db: Firestore): Promise<number> {
  let updated = 0;
  for (const collectionName of ATTENDEE_COLLECTIONS) {
    const snapshot = await db.collection(collectionName).where("attendeeIds", "array-contains", uid).get();
    if (snapshot.empty) continue;

    for (let i = 0; i < snapshot.docs.length; i += BATCH_LIMIT) {
      const batch = db.batch();
      for (const doc of snapshot.docs.slice(i, i + BATCH_LIMIT)) {
        batch.update(doc.ref, { attendeeIds: FieldValue.arrayRemove(uid) });
        updated++;
      }
      await batch.commit();
    }
  }
  return updated;
}
