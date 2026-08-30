/**
 * Egoractive — `gyms/{gymId}/monthlyTrainerStats/{yearMonth}` için bir
 * kerelik backfill. Bu koleksiyon, dashboard'daki antrenör performans
 * dökümünün artık antrenör başına 2 `count()` sorgusu yerine TEK bir
 * dokümanı okuyabilmesi için eklendi (bkz.
 * `functions/src/triggers/on-session-write-update-trainer-stats.ts`,
 * `dashboard_report_service.dart`).
 *
 * Bu script'ten SONRA oluşturulan/durumu değişen seanslar için sayaç zaten
 * o trigger tarafından canlı güncelleniyor — bu script SADECE trigger
 * devreye girmeden ÖNCE (ya da ay ortasında deploy edildiyse, o ana kadar)
 * oluşturulmuş seansları bir kerelik sayıp yazmak için gerekli. Bu AYIN
 * (`sessions.startTime`, UTC takvim ayı) verisini `sessions` koleksiyonunu
 * tarayarak sıfırdan hesaplayıp yazar — idempotent, güvenle tekrar
 * çalıştırılabilir (her çalıştırmada o ayın `stats` haritasını komple
 * yeniden hesaplayıp üzerine yazar, birikmeli artırmaz).
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek (production)
 * projeye yazmak için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 *
 * Kullanım (emulator):
 *   firebase emulators:start --only firestore
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 npm run backfill-trainer-stats
 *
 * Kullanım (production):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run backfill-trainer-stats -- --allow-production --project=egoractive-e92bd
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

function assertSafeToRun(): void {
  const targetsProduction = !process.env.FIRESTORE_EMULATOR_HOST;
  if (!targetsProduction) return;

  const allowFlag = process.argv.includes("--allow-production");
  const confirmEnv = process.env.CONFIRM_PRODUCTION_BACKFILL === "yes";
  if (!allowFlag || !confirmEnv) {
    console.error(
      "REDDEDİLDİ: FIRESTORE_EMULATOR_HOST ayarlı değil (yani hedef production gibi görünüyor) " +
        "ama --allow-production ve CONFIRM_PRODUCTION_BACKFILL=yes birlikte verilmedi.",
    );
    process.exit(1);
  }
}

/** `on-session-write-update-trainer-stats.ts`'teki `yearMonthUtc` ile BİLEREK aynı kural. */
function yearMonthUtc(date: Date): string {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

interface TrainerBucket {
  name: string;
  total: number;
  completed: number;
}

async function main() {
  assertSafeToRun();
  const projectId = projectIdFromArgs();
  initializeApp({ projectId });
  const db = getFirestore();

  const now = new Date();
  const yearMonth = yearMonthUtc(now);
  const monthStart = Timestamp.fromDate(new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), 1)));
  const monthEnd = Timestamp.fromDate(new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth() + 1, 1)));

  console.log(`Proje: ${projectId} — ${yearMonth} ayı için antrenör istatistiklerini tarıyorum...`);

  // gymId -> trainerId -> { name, total, completed }
  const statsByGym = new Map<string, Map<string, TrainerBucket>>();
  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let scanned = 0;

  for (;;) {
    let query = db
      .collection("sessions")
      .where("startTime", ">=", monthStart)
      .where("startTime", "<", monthEnd)
      .orderBy("startTime")
      .orderBy("__name__")
      .limit(1000);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const gymId = data.gymId as string | undefined;
      const trainerId = data.trainerId as string | undefined;
      if (!gymId || !trainerId) continue;
      const trainerName = typeof data.trainerName === "string" ? data.trainerName : "";
      const isCompleted = data.status === "completed";

      if (!statsByGym.has(gymId)) statsByGym.set(gymId, new Map());
      const gymStats = statsByGym.get(gymId) as Map<string, TrainerBucket>;
      const bucket = gymStats.get(trainerId) ?? { name: trainerName, total: 0, completed: 0 };
      bucket.total += 1;
      if (isCompleted) bucket.completed += 1;
      if (trainerName) bucket.name = trainerName;
      gymStats.set(trainerId, bucket);
    }

    scanned += snapshot.docs.length;
    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 1000) break;
  }

  console.log(`${scanned} seans tarandı, ${statsByGym.size} salon etkileniyor.`);

  console.log("Salon özet dokümanlarını yazıyorum...");
  let written = 0;
  for (const [gymId, gymStats] of statsByGym) {
    const stats: Record<string, TrainerBucket> = {};
    for (const [trainerId, bucket] of gymStats) stats[trainerId] = bucket;
    await db.doc(`gyms/${gymId}/monthlyTrainerStats/${yearMonth}`).set({ stats }, { merge: true });
    written++;
  }

  console.log(`Tamamlandı — ${yearMonth} için ${written} salonun antrenör istatistiği yazıldı.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
