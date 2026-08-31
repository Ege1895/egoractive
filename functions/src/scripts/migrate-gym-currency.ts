import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

import { gymsCollection } from "../shared/firestore-paths";

const DEFAULT_CURRENCY = "TRY";
const FIRESTORE_BATCH_LIMIT = 400; // gerçek sınır 500, güvenlik payı bırakıldı

/**
 * F9-5 — tek seferlik, elle çalıştırılan migration. F9-2 öncesi kurulan
 * salonların `gyms/{gymId}.currency` alanı yok — F9-1..F9-4'teki tüm
 * formatlama zaten `currency` eksikse `'TRY'` fallback'i kullanıyor
 * (bkz. `defaultCurrencyCode` / client tarafındaki okuma noktaları), bu
 * script o güvenlik ağına güvenmek yerine alanı kalıcı olarak yazar.
 * `currency` zaten olan dokümanlara dokunmaz — idempotent, birden fazla
 * çalıştırılabilir.
 *
 * Çalıştırma (functions/ dizininden):
 *   npm run build && node lib/scripts/migrate-gym-currency.js --dry-run
 *   npm run build && node lib/scripts/migrate-gym-currency.js
 *
 * Production'da GOOGLE_APPLICATION_CREDENTIALS ortam değişkeni bir
 * service account anahtarına işaret etmeli (emulator'da gerekmez).
 */
async function main(): Promise<void> {
  const dryRun = process.argv.includes("--dry-run");

  initializeApp();
  const db = getFirestore();
  const snapshot = await db.collection(gymsCollection()).get();

  let migrated = 0;
  let alreadySet = 0;
  let batch = db.batch();
  let pendingInBatch = 0;

  for (const doc of snapshot.docs) {
    const currency = doc.data().currency;
    if (typeof currency === "string" && currency.trim().length > 0) {
      alreadySet++;
      continue;
    }

    migrated++;
    if (dryRun) continue;

    batch.update(doc.ref, { currency: DEFAULT_CURRENCY });
    pendingInBatch++;
    if (pendingInBatch >= FIRESTORE_BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      pendingInBatch = 0;
    }
  }
  if (pendingInBatch > 0) await batch.commit();

  const prefix = dryRun ? "[DRY RUN] " : "";
  console.log(`${prefix}Toplam ${snapshot.size} 'gyms' dokümanı tarandı.`);
  console.log(`${prefix}  Migrate edilecek/edildi (currency: '${DEFAULT_CURRENCY}'): ${migrated}`);
  console.log(`${prefix}  Zaten currency alanı var: ${alreadySet}`);
}

main()
  .then(() => process.exit(0))
  .catch((error: unknown) => {
    console.error("Migration başarısız:", error);
    process.exit(1);
  });
