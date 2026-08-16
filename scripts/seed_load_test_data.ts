/**
 * F7-2 — Egoractive için yük testi seed script'i: tek bir "load-test-gym"
 * salonuna 10.000 üye + 100.000 seans yazar. Amaç F5-1 (admin dashboard) ve
 * F2-2 (üye listesi) ekranlarının bu ölçekte performansını ölçmek.
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek (production)
 * projeye yazmak için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_SEED=yes` ortam değişkeni birlikte verilmeli — yoksa
 * script reddeder. Bu, gerçek kullanıcı verisini yanlışlıkla 110.000
 * sahte dokümanla kirletmeyi engellemek için bilinçli bir çift kilit.
 *
 * Kullanım (emulator, varsayılan ve önerilen):
 *   firebase emulators:start --only firestore
 *   # başka bir terminalde:
 *   cd scripts && npm install
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 npm run seed
 *
 * Kullanım (gerçek proje — SADECE bilinçli, izole bir test projesinde):
 *   cd scripts && npm install
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_SEED=yes \
 *     npm run seed -- --allow-production --project=egoractive-e92bd
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

const GYM_ID = "load-test-gym";
const TRAINER_COUNT = 20;
const MEMBER_COUNT = 10_000;
const SESSION_COUNT = 100_000;

function assertSafeToRun(): void {
  const usingEmulator = Boolean(process.env.FIRESTORE_EMULATOR_HOST);
  const allowProduction = process.argv.includes("--allow-production");
  const confirmedProduction = process.env.CONFIRM_PRODUCTION_SEED === "yes";

  if (usingEmulator) return;
  if (allowProduction && confirmedProduction) return;

  throw new Error(
    "FIRESTORE_EMULATOR_HOST ayarlı değil — bu script gerçek bir Firebase " +
      "projesine yazmak üzere. Bunu kastediyorsan --allow-production bayrağını " +
      "VE CONFIRM_PRODUCTION_SEED=yes ortam değişkenini birlikte ver. Aksi " +
      "halde `firebase emulators:start --only firestore` ile emulator'ı " +
      "başlatıp FIRESTORE_EMULATOR_HOST=localhost:8080 ile tekrar çalıştır.",
  );
}

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

async function main() {
  assertSafeToRun();
  initializeApp({ projectId: projectIdFromArgs() });
  const db = getFirestore();
  const writer = db.bulkWriter();
  writer.onWriteError((error) => {
    console.error(`Yazma hatası (${error.documentRef.path}), deneme #${error.failedAttempts}:`, error.message);
    return error.failedAttempts < 3;
  });

  console.log(`Salon + ${TRAINER_COUNT} antrenör oluşturuluyor...`);
  writer.set(db.doc(`gyms/${GYM_ID}`), {
    name: "Load Test Gym",
    city: "İstanbul",
    subscriptionStatus: "active",
    trialStartedAt: Timestamp.now(),
  });

  const trainerIds = Array.from({ length: TRAINER_COUNT }, (_, i) => `${GYM_ID}-trainer-${i}`);
  for (const trainerId of trainerIds) {
    writer.set(db.doc(`users/${trainerId}`), {
      role: "trainer",
      gymId: GYM_ID,
      name: `Antrenör ${trainerId.split("-").pop()}`,
      phoneNumber: `+9050000${trainerId.slice(-5).padStart(5, "0")}`,
    });
  }

  console.log(`${MEMBER_COUNT} üye yazılıyor...`);
  const memberIds: string[] = [];
  for (let i = 0; i < MEMBER_COUNT; i++) {
    const memberId = `${GYM_ID}-member-${i.toString().padStart(6, "0")}`;
    memberIds.push(memberId);
    const trainerId = trainerIds[i % TRAINER_COUNT];
    const remainingSessions = i % 5;
    writer.set(db.doc(`users/${memberId}`), {
      role: "member",
      gymId: GYM_ID,
      trainerId,
      trainerName: `Antrenör ${trainerId.split("-").pop()}`,
      name: `Üye ${i.toString().padStart(6, "0")}`,
      phoneNumber: `+9051${i.toString().padStart(7, "0")}`,
      remainingSessions,
      packageEndDate: new Date(Date.now() + (i % 60) * 24 * 60 * 60 * 1000).toISOString(),
    });
    if (i % 5_000 === 0 && i > 0) {
      await writer.flush();
      console.log(`  ${i}/${MEMBER_COUNT} üye yazıldı.`);
    }
  }
  await writer.flush();

  console.log(`${SESSION_COUNT} seans yazılıyor...`);
  const now = Date.now();
  for (let i = 0; i < SESSION_COUNT; i++) {
    const sessionId = `${GYM_ID}-session-${i.toString().padStart(7, "0")}`;
    const trainerId = trainerIds[i % TRAINER_COUNT];
    const memberId = memberIds[i % MEMBER_COUNT];
    // Son 90 günden gelecek 30 güne yayılmış, F5-1'in "bu ay" filtresinin
    // de gerçekçi bir alt küme görmesi için.
    const startTime = Timestamp.fromMillis(now + ((i % 120) - 90) * 24 * 60 * 60 * 1000);
    writer.set(db.doc(`sessions/${sessionId}`), {
      gymId: GYM_ID,
      trainerId,
      memberId,
      startTime,
      endTime: Timestamp.fromMillis(startTime.toMillis() + 60 * 60 * 1000),
      status: i % 10 === 0 ? "cancelled" : "planned",
    });
    if (i % 20_000 === 0 && i > 0) {
      await writer.flush();
      console.log(`  ${i}/${SESSION_COUNT} seans yazıldı.`);
    }
  }
  await writer.flush();
  await writer.close();

  console.log(`Tamamlandı: gymId=${GYM_ID}, ${MEMBER_COUNT} üye, ${SESSION_COUNT} seans.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
