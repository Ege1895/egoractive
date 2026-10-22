/**
 * Egoractive — üretimde `users/{uid}.otpBypassEnabled === true` taşıyan
 * hesapların denetimi (ve istenirse temizliği).
 *
 * NEDEN: Bu bayrak açık olan hesaplara sabit `000000` koduyla giriliyor ve
 * e-posta bile gönderilmiyor (`functions/src/shared/otp.ts`). Yani telefon
 * numarasını ya da e-postasını bilen HERKES o hesaba girebilir. Kapalı test
 * için bilinçli bir mekanizma, ama yayına açılmadan önce üretimde bu
 * bayrağı taşıyan hesap KALMAMALI.
 *
 * `enable_closed_test_accounts.ts --revoke` de bayrağı kaldırıyor ama
 * yalnızca o dosyada SABİT YAZILI 3 uid'yi kapsıyor. Bu script koleksiyonun
 * TAMAMINI tarar — Console'dan elle açılmış ya da unutulmuş bir hesabı da
 * yakalar.
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek projeye yazmak
 * için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 * Varsayılan davranış SADECE RAPORLAMA — silmek için `--revoke` gerekir.
 *
 * Kullanım (denetim, hiçbir şey değiştirmez):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run audit-otp-bypass -- --allow-production
 *
 * Kullanım (bayrağı tüm hesaplardan kaldır):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run audit-otp-bypass -- --allow-production --revoke
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

/** Tek bir `WriteBatch`'e konulacak azami işlem (Firestore sınırı 500). */
const BATCH_LIMIT = 400;

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

const shouldRevoke = process.argv.includes("--revoke");

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

  console.log(`Proje: ${projectId} · mod: ${shouldRevoke ? "TEMİZLEME" : "SADECE DENETİM"}`);

  const snapshot = await db.collection("users").where("otpBypassEnabled", "==", true).get();

  if (snapshot.empty) {
    console.log("✅ Bayrağı açık hesap YOK — yayın için bu kontrol temiz.");
    return;
  }

  console.log(`⚠️  ${snapshot.size} hesapta otpBypassEnabled açık:`);
  for (const doc of snapshot.docs) {
    const data = doc.data();
    console.log(
      `   - users/${doc.id} · role=${data.role ?? "?"} · phone=${data.phoneNumber ?? "?"} · email=${data.email ?? "?"}`,
    );
  }

  if (!shouldRevoke) {
    console.log("\nHiçbir şey değiştirilmedi. Kaldırmak için --revoke ile tekrar çalıştır.");
    process.exitCode = 1; // CI/kontrol listesi bu çıkışı "temiz değil" diye okuyabilsin.
    return;
  }

  for (let i = 0; i < snapshot.docs.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    for (const doc of snapshot.docs.slice(i, i + BATCH_LIMIT)) {
      batch.update(doc.ref, { otpBypassEnabled: FieldValue.delete() });
    }
    await batch.commit();
  }

  console.log(`\n✅ ${snapshot.size} hesaptan otpBypassEnabled kaldırıldı.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
