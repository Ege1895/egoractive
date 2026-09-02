import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

import { usersCollection } from "../shared/firestore-paths";

const LEGACY_TR_PREFIX = "+90";
const FIRESTORE_BATCH_LIMIT = 400; // gerçek sınır 500, güvenlik payı bırakıldı

/**
 * F8-3 — tek seferlik, elle çalıştırılan migration. `users/{uid}.phoneNumber`
 * F8-2 öncesi hep çıplak (prefiksiz) 10 haneli TR numarasıydı; artık hem
 * login eşleştirmesi (`start-login.ts`) hem yeni kayıtlar tam E.164
 * bekliyor. Zaten "+" ile başlayan kayıtlara dokunmaz — idempotent, birden
 * fazla çalıştırılabilir. Migration bitene kadar `shared/phone-lookup.ts`
 * eski çıplak kayıtlar için bir okuma-zamanı fallback'i zaten sağlıyor,
 * bu script o ihtiyacı ortadan kaldırır.
 *
 * Çalıştırma (functions/ dizininden):
 *   npm run build && node lib/scripts/migrate-phone-e164.js --dry-run
 *   npm run build && node lib/scripts/migrate-phone-e164.js
 *
 * Production'da GOOGLE_APPLICATION_CREDENTIALS ortam değişkeni bir
 * service account anahtarına işaret etmeli (emulator'da gerekmez).
 */
async function main(): Promise<void> {
  const dryRun = process.argv.includes("--dry-run");

  initializeApp();
  const db = getFirestore();
  const snapshot = await db.collection(usersCollection()).get();

  let migrated = 0;
  let alreadyE164 = 0;
  let skippedEmpty = 0;
  let batch = db.batch();
  let pendingInBatch = 0;

  for (const doc of snapshot.docs) {
    const phoneNumber = doc.data().phoneNumber;
    if (typeof phoneNumber !== "string" || phoneNumber.trim().length === 0) {
      skippedEmpty++;
      continue;
    }
    if (phoneNumber.startsWith("+")) {
      alreadyE164++;
      continue;
    }

    migrated++;
    if (dryRun) continue;

    batch.update(doc.ref, { phoneNumber: `${LEGACY_TR_PREFIX}${phoneNumber}` });
    pendingInBatch++;
    if (pendingInBatch >= FIRESTORE_BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      pendingInBatch = 0;
    }
  }
  if (pendingInBatch > 0) await batch.commit();

  const prefix = dryRun ? "[DRY RUN] " : "";
  console.log(`${prefix}Toplam ${snapshot.size} 'users' dokümanı tarandı.`);
  console.log(`${prefix}  Migrate edilecek/edildi: ${migrated}`);
  console.log(`${prefix}  Zaten E.164: ${alreadyE164}`);
  console.log(`${prefix}  phoneNumber boş/yok: ${skippedEmpty}`);
}

main()
  .then(() => process.exit(0))
  .catch((error: unknown) => {
    console.error("Migration başarısız:", error);
    process.exit(1);
  });
