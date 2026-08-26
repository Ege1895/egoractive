/**
 * Egoractive — `users/{uid}.plannedSessionsCount` alanı için bir kerelik
 * backfill. Bu alan, admin Üyeler listesindeki "Kalan ders" değerinin artık
 * `remainingSessions` (henüz planlanmamış hak) + `plannedSessionsCount`
 * (takvimde bekleyen, tamamlanmamış seans sayısı) toplamı olarak
 * gösterilmesiyle birlikte eklendi (bkz. admin_member_summary_mapper.dart).
 *
 * Bu koddan SONRA oluşturulan/iptal edilen/tamamlanan seanslar için sayaç
 * zaten client transaction'larında (SessionsWriteService, SessionCompletionService)
 * güncelleniyor — bu script SADECE bu değişiklikten ÖNCE oluşturulmuş,
 * hâlâ `status == 'planned'` olan seansları olan üyelerin sayacını bir
 * kerelik hesaplayıp yazmak için gerekli. Çalıştırılmazsa, bu tür mevcut
 * üyelerin "Kalan ders" değeri (o seanslar iptal/tamamlanana kadar) yanlış
 * (düşük) görünmeye devam eder.
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek (production)
 * projeye yazmak için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 *
 * Kullanım (emulator):
 *   firebase emulators:start --only firestore
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 npm run backfill-planned-sessions
 *
 * Kullanım (production):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run backfill-planned-sessions -- --allow-production --project=egoractive-e92bd
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

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

async function main() {
  assertSafeToRun();
  const projectId = projectIdFromArgs();
  initializeApp({ projectId });
  const db = getFirestore();

  console.log(`Proje: ${projectId} — planned seansları sayıyorum...`);
  const plannedCounts = new Map<string, number>();
  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let scannedSessions = 0;
  for (;;) {
    let query = db
      .collection("sessions")
      .where("status", "==", "planned")
      .orderBy("__name__")
      .limit(1000);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;
    for (const doc of snapshot.docs) {
      const memberId = doc.data().memberId as string | undefined;
      if (!memberId) continue;
      plannedCounts.set(memberId, (plannedCounts.get(memberId) ?? 0) + 1);
    }
    scannedSessions += snapshot.docs.length;
    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 1000) break;
  }
  console.log(`${scannedSessions} planned seans tarandı, ${plannedCounts.size} farklı üye etkileniyor.`);

  console.log("Üye dokümanlarını güncelliyorum...");
  let updated = 0;
  let skipped = 0;
  lastDoc = undefined;
  for (;;) {
    let query = db
      .collection("users")
      .where("role", "==", "member")
      .orderBy("__name__")
      .limit(500);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    const batch = db.batch();
    let batchHasWrites = false;
    for (const doc of snapshot.docs) {
      const correctCount = plannedCounts.get(doc.id) ?? 0;
      const currentCount = (doc.data().plannedSessionsCount as number | undefined) ?? 0;
      if (currentCount === correctCount && doc.data().plannedSessionsCount !== undefined) {
        skipped++;
        continue;
      }
      batch.update(doc.ref, { plannedSessionsCount: correctCount });
      batchHasWrites = true;
      updated++;
    }
    if (batchHasWrites) await batch.commit();

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 500) break;
  }

  console.log(`Tamamlandı — ${updated} üye güncellendi, ${skipped} üye zaten doğruydu.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
