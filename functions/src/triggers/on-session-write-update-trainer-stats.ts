import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

import { monthlyTrainerStatsDoc } from "../shared/firestore-paths";
import { withFailureAlerting } from "../shared/function-health";

/**
 * `sessions/{sessionId}`'in ilgili alanlarından çıkarılan, bir dokümanın
 * hangi (salon, antrenör, ay) "kova"sına ait olduğunu tanımlayan minimal
 * veri. `wasCompleted`/`trainerName` delta hesaplamak için taşınıyor.
 */
export interface TrainerStatsBucket {
  gymId: string;
  trainerId: string;
  yearMonth: string;
  trainerName: string;
  isCompleted: boolean;
}

export interface BucketDelta {
  total: number;
  completed: number;
  /** `true` ise `trainerName`'i de yazar — sadece kova YENİ etkilenmeye
   * başladığında (create ya da kova değişimi) anlamlı; sadece completed
   * durumu değişen bir güncellemede tekrar yazmaya gerek yok. */
  writeName: boolean;
}

/**
 * `startTime`'ın UTC takvim ayını "YYYY-MM" olarak döner. BİLEREK salon
 * saat dilimine göre değil — bkz. `firestore-paths.ts`'teki
 * `monthlyTrainerStatsDoc` dokümantasyonu: client'ın okuma anahtarıyla
 * (aynı UTC kuralı) hiçbir zaman uyuşmazlık yaşanmasın diye, ve bu trigger
 * hiçbir ek Firestore okuması (ör. salonun timeZone alanı) yapmadan, event'in
 * kendi verisinden hesaplasın diye.
 */
export function yearMonthUtc(date: Date): string {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

/**
 * Saf çıkarım — Firebase'e hiç dokunmaz, emulator'sız test edilebilir.
 * `gymId`/`trainerId`/`startTime` eksikse (silinmiş alan, bozuk doküman)
 * `null` döner — o taraf hiç etkilenmemiş sayılır.
 */
export function toBucket(data: Record<string, unknown> | undefined): TrainerStatsBucket | null {
  if (!data) return null;
  const gymId = typeof data.gymId === "string" ? data.gymId : undefined;
  const trainerId = typeof data.trainerId === "string" ? data.trainerId : undefined;
  const startTime = data.startTime as FirebaseFirestore.Timestamp | undefined;
  if (!gymId || !trainerId || !startTime?.toDate) return null;

  return {
    gymId,
    trainerId,
    yearMonth: yearMonthUtc(startTime.toDate()),
    trainerName: typeof data.trainerName === "string" ? data.trainerName : "",
    isCompleted: data.status === "completed",
  };
}

function sameBucket(a: TrainerStatsBucket, b: TrainerStatsBucket): boolean {
  return a.gymId === b.gymId && a.trainerId === b.trainerId && a.yearMonth === b.yearMonth;
}

/**
 * `before`/`after` kovalarından hangi yazmaların gerektiğini hesaplar —
 * saf, test edilebilir. Üç durum:
 * 1. İkisi de yok → hiçbir şey (gymId/trainerId/startTime hiç olmamış).
 * 2. Aynı kova (create/delete değil, sadece status/isim değişmiş) → o kovaya
 *    TEK bir delta (total değişmez, sadece completed farkı).
 * 3. Farklı kova (create, delete, ya da antrenör/ay değişti — reschedule) →
 *    eski kovadan düş (-1/-completed), yeni kovaya ekle (+1/+completed).
 */
export function computeBucketDeltas(
  before: TrainerStatsBucket | null,
  after: TrainerStatsBucket | null,
): Array<{ bucket: TrainerStatsBucket; delta: BucketDelta }> {
  if (!before && !after) return [];

  if (before && after && sameBucket(before, after)) {
    const completedDelta = (after.isCompleted ? 1 : 0) - (before.isCompleted ? 1 : 0);
    const nameChanged = after.trainerName !== "" && after.trainerName !== before.trainerName;
    if (completedDelta === 0 && !nameChanged) return [];
    return [{ bucket: after, delta: { total: 0, completed: completedDelta, writeName: nameChanged } }];
  }

  const deltas: Array<{ bucket: TrainerStatsBucket; delta: BucketDelta }> = [];
  if (before) {
    deltas.push({
      bucket: before,
      delta: { total: -1, completed: before.isCompleted ? -1 : 0, writeName: false },
    });
  }
  if (after) {
    deltas.push({
      bucket: after,
      delta: { total: 1, completed: after.isCompleted ? 1 : 0, writeName: true },
    });
  }
  return deltas;
}

/**
 * F5-1/F7-2 — dashboard'daki antrenör performans dökümü önceden antrenör
 * başına 2 `count()` aggregate sorgusu yapıyordu (N antrenörde 2N
 * round-trip; 20 antrenörlü bir salonda yük testinde ~5sn ölçüldü, bkz.
 * `dashboard_report_service.dart`'ın eski yorumu). Bu trigger onun yerine
 * her seans yazımında ilgili (salon, antrenör, ay) kovasının toplam/
 * tamamlanan sayısını `gyms/{gymId}/monthlyTrainerStats/{yearMonth}`
 * dokümanında canlı tutar — dashboard artık antrenör sayısından/toplam
 * seans hacminden tamamen bağımsız, TEK bir doküman okuyor.
 *
 * BİLEREK hiçbir ek Firestore okuması yapmıyor (ne salon dokümanı ne başka
 * bir sorgu) — event'in kendi `before`/`after` verisinden hesaplıyor, en
 * fazla 2 yazma (kova değişince: eskisinden düş, yenisine ekle) ya da 1
 * yazma (aynı kovada sadece status değişmiş) yapıyor.
 */
export const onSessionWriteUpdateTrainerStats = onDocumentWritten(
  // `sessions` üst düzey (top-level) bir koleksiyon, `gymId` alanla
  // filtreleniyor — `firestore-paths.ts`'teki `sessionsCollection(gymId)`
  // yardımcı fonksiyonu şemanın erken bir taslağından kalma, gerçek veriyle
  // eşleşmiyor (bkz. `on-session-write-schedule-notifications.ts`'in de
  // aynı ham string'i kullanması).
  { document: "sessions/{sessionId}", retry: true },
  withFailureAlerting("onSessionWriteUpdateTrainerStats", async (event) => {
    const before = toBucket(event.data?.before?.exists ? event.data.before.data() : undefined);
    const after = toBucket(event.data?.after?.exists ? event.data.after.data() : undefined);

    const writes = computeBucketDeltas(before, after);
    if (writes.length === 0) return;

    const firestore = getFirestore();
    await Promise.all(
      writes.map(({ bucket, delta }) => {
        const update: Record<string, FirebaseFirestore.FieldValue | string> = {};
        if (delta.total !== 0) {
          update[`stats.${bucket.trainerId}.total`] = FieldValue.increment(delta.total);
        }
        if (delta.completed !== 0) {
          update[`stats.${bucket.trainerId}.completed`] = FieldValue.increment(delta.completed);
        }
        if (delta.writeName && bucket.trainerName) {
          update[`stats.${bucket.trainerId}.name`] = bucket.trainerName;
        }
        if (Object.keys(update).length === 0) return Promise.resolve();
        return firestore
          .doc(monthlyTrainerStatsDoc(bucket.gymId, bucket.yearMonth))
          .set(update, { merge: true });
      }),
    );
  }),
);
