/**
 * F7-2 — `seed_load_test_data.ts` ile seed edilen "load-test-gym" salonu
 * üzerinde, Flutter uygulamasının F2-2 (üye listesi) ve F5-1 (dashboard)
 * ekranlarında attığı GERÇEK sorguları birebir tekrarlayıp süresini ölçer.
 * Tam bir Flutter UI first-render ölçümü değil (widget build/layout süresi
 * dahil değil) ama bu iki ekranda asıl maliyet Firestore round-trip'i
 * olduğu için güçlü bir sinyal verir.
 *
 * Kullanım: seed_load_test_data.ts ile aynı ortamda (emulator veya aynı
 * güvenlik onayıyla production) çalıştırılır:
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 npm run measure
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp, AggregateField } from "firebase-admin/firestore";

const GYM_ID = "load-test-gym";

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

async function timed<T>(label: string, run: () => Promise<T>): Promise<T> {
  const start = performance.now();
  const result = await run();
  const elapsedMs = performance.now() - start;
  const flag = elapsedMs > 3000 ? "  <-- 3sn'yi AŞTI" : "";
  console.log(`  ${label}: ${elapsedMs.toFixed(0)}ms${flag}`);
  return result;
}

async function measureMemberListFirstPage(db: FirebaseFirestore.Firestore) {
  console.log("\nF2-2 — üye listesi ilk sayfa (orderBy name, limit 50):");
  await timed("İlk sayfa (50 üye)", () =>
    db.collection("users").where("gymId", "==", GYM_ID).where("role", "==", "member").orderBy("name").limit(50).get(),
  );
  await timed("İsim öneki araması ('Üye 0012')", () =>
    db
      .collection("users")
      .where("gymId", "==", GYM_ID)
      .where("role", "==", "member")
      .orderBy("name")
      .startAt(["Üye 0012"])
      .endAt(["Üye 0012"])
      .limit(30)
      .get(),
  );
}

async function measureDashboard(db: FirebaseFirestore.Firestore) {
  console.log("\nF5-1 — dashboard (dashboard_report_service.dart ile birebir aynı sorgular, F7-2'den sonra ikiye ayrıldı):");
  const now = new Date();
  const monthStart = Timestamp.fromDate(new Date(now.getFullYear(), now.getMonth(), 1));
  const monthSessions = db.collection("sessions").where("gymId", "==", GYM_ID).where("startTime", ">=", monthStart);

  await timed("loadSummary() — ilk render'ı belirleyen kısım", () =>
    Promise.all([
      monthSessions.count().get(),
      monthSessions.where("status", "==", "completed").count().get(),
      monthSessions.where("status", "==", "cancelled").count().get(),
      db
        .collection("memberPackages")
        .where("gymId", "==", GYM_ID)
        .where("purchasedAt", ">=", monthStart)
        .aggregate({ total: AggregateField.sum("paidAmount") })
        .get(),
      db
        .collection("expenses")
        .where("gymId", "==", GYM_ID)
        .where("date", ">=", monthStart)
        .aggregate({ total: AggregateField.sum("amountTl") })
        .get(),
    ]),
  );

  await timed("loadTrainerPerformance() — ayrı, arka planda devam eden kısım", async () => {
    const trainersSnapshot = await db.collection("users").where("gymId", "==", GYM_ID).where("role", "==", "trainer").get();
    await Promise.all(
      trainersSnapshot.docs.flatMap((trainer) => [
        monthSessions.where("trainerId", "==", trainer.id).count().get(),
        monthSessions.where("trainerId", "==", trainer.id).where("status", "==", "completed").count().get(),
      ]),
    );
  });
}

async function main() {
  initializeApp({ projectId: projectIdFromArgs() });
  const db = getFirestore();

  console.log(`Ölçüm çalıştırılıyor: gymId=${GYM_ID}`);
  await measureMemberListFirstPage(db);
  await measureDashboard(db);
  console.log("\nKabul kriteri: her iki ekran da 3000ms'nin altında olmalı.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
