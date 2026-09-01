/**
 * Egoractive — `phoneIndex/{phoneNumber}` için bir kerelik backfill.
 * `checkPhoneAvailable` callable'ının (cold start'ta 20-30+ saniyeye
 * çıkabiliyordu — üye ekleme akışında "Kaydet"e basınca ~1 dakikaya varan
 * donma) yerini alan bu index, client'ın telefon benzersizlik kontrolünü
 * doğrudan ucuz bir Firestore point-read'le yapmasını sağlıyor (bkz.
 * `functions/src/triggers/on-user-write-sync-phone-index.ts`,
 * `member_registration_service.dart`/`trainer_registration_service.dart`).
 *
 * Bu script'ten SONRA yazılan/değişen `users/{uid}.phoneNumber` alanları
 * zaten o trigger tarafından canlı senkronlanıyor — bu script SADECE
 * trigger devreye girmeden ÖNCE var olan kullanıcıları bir kerelik
 * indekslemek için gerekli. `users` koleksiyonunu tarayıp her dokümanın
 * MEVCUT `phoneNumber` değerini (E.164 ya da migrasyon öncesi çıplak TR
 * hali, hangisiyse) `phoneIndex`'e yazar — idempotent, güvenle tekrar
 * çalıştırılabilir (her çalıştırmada üzerine yazar).
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek (production)
 * projeye yazmak için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 *
 * Kullanım (emulator):
 *   firebase emulators:start --only firestore
 *   FIRESTORE_EMULATOR_HOST=localhost:8080 npm run backfill-phone-index
 *
 * Kullanım (production):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run backfill-phone-index -- --allow-production --project=egoractive-e92bd
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

  console.log(`Proje: ${projectId} — users koleksiyonunu tarayıp phoneIndex'i dolduruyorum...`);

  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  let scanned = 0;
  let indexed = 0;
  let skippedNoPhone = 0;

  for (;;) {
    let query = db.collection("users").orderBy("__name__").limit(500);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    const batch = db.batch();
    for (const doc of snapshot.docs) {
      scanned++;
      const phoneNumber = doc.data().phoneNumber as string | undefined;
      if (!phoneNumber) {
        skippedNoPhone++;
        continue;
      }
      batch.set(db.doc(`phoneIndex/${phoneNumber}`), { uid: doc.id, updatedAt: new Date() });
      indexed++;
    }
    await batch.commit();

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 500) break;
  }

  console.log(
    `Tamamlandı — ${scanned} kullanıcı tarandı, ${indexed} tanesi indekslendi, ` +
      `${skippedNoPhone} tanesinin telefon numarası yoktu (atlandı).`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
