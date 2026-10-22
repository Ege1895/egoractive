/**
 * Egoractive — Google Play kapalı testi için demo hesaplarını hazırlar.
 *
 * İki şey yazar:
 *  1. `users/{uid}.otpBypassEnabled = true` — bu hesaplarda `startLogin`
 *     e-posta ile doğrulama kodu GÖNDERMEZ, sabit kodu (000000) kabul eder
 *     (bkz. `functions/src/callable/start-login.ts`). Testerlar bizim posta
 *     kutumuza erişemediği için normal akışla giriş yapamıyorlardı.
 *  2. `gyms/{gymId}.subscriptionExempt = true` — admin dışındaki roller
 *     salonun aboneliği aktif değilken giriş yapamıyor (aynı dosya, salon
 *     abonelik kontrolü). Muafiyet olmadan antrenör ve üye demo hesapları
 *     kod ekranını bile göremez.
 *
 * ⚠️ TEST BİTİNCE GERİ ALIN: `--revoke` ile çalıştırmak bu alanları
 * kaldırır. `otpBypassEnabled` açık bir hesaba, telefon numarasını bilen
 * HERKES girebilir — numaralar Play Console'da testerlara açık veriliyor.
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı (bkz. `backfill_phone_index.ts`
 * ile aynı desen). Gerçek projeye yazmak için hem `--allow-production`
 * bayrağı hem de `CONFIRM_PRODUCTION_BACKFILL=yes` birlikte verilmeli.
 *
 * Kullanım (production):
 *   CONFIRM_PRODUCTION_BACKFILL=yes npm run enable-closed-test -- \
 *     --allow-production --project=egoractive-e92bd
 *
 * Geri alma:
 *   CONFIRM_PRODUCTION_BACKFILL=yes npm run enable-closed-test -- \
 *     --allow-production --project=egoractive-e92bd --revoke
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

/** Kapalı testte kullanılan demo hesaplar — rol etiketleri sadece log içindir. */
const TEST_USER_IDS: ReadonlyArray<{ uid: string; role: string }> = [
  { uid: "ifKPfciCrKH0Qqvj2NgI", role: "admin" },
  { uid: "XyrJtfwrt8Ol2ueZiBzI", role: "member" },
  { uid: "r2SHvpzvai6zaP2YYnRt", role: "trainer" },
];

const TEST_GYM_ID = "VtIqRsgL7qvgcPYW1IRW";

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : (process.env.GCLOUD_PROJECT ?? "demo-egoractive");
}

function assertTargetAllowed(): void {
  const targetsProduction = !process.env.FIRESTORE_EMULATOR_HOST;
  if (!targetsProduction) return;
  const allowFlag = process.argv.includes("--allow-production");
  const confirmEnv = process.env.CONFIRM_PRODUCTION_BACKFILL === "yes";
  if (!allowFlag || !confirmEnv) {
    throw new Error(
      "REDDEDİLDİ: FIRESTORE_EMULATOR_HOST ayarlı değil (hedef production görünüyor) " +
        "ama --allow-production ve CONFIRM_PRODUCTION_BACKFILL=yes birlikte verilmedi.",
    );
  }
}

async function main(): Promise<void> {
  assertTargetAllowed();
  const revoke = process.argv.includes("--revoke");
  const projectId = projectIdFromArgs();
  initializeApp({ projectId });
  const db = getFirestore();

  console.log(`Proje: ${projectId} · mod: ${revoke ? "GERİ ALMA" : "AÇMA"}`);

  for (const { uid, role } of TEST_USER_IDS) {
    const ref = db.collection("users").doc(uid);
    const snap = await ref.get();
    if (!snap.exists) {
      console.log(`  ! users/${uid} (${role}) bulunamadı, atlandı`);
      continue;
    }
    await ref.update({
      otpBypassEnabled: revoke ? FieldValue.delete() : true,
    });
    const phone = (snap.data()?.phoneNumber as string | undefined) ?? "(telefon yok)";
    console.log(`  ✓ users/${uid} (${role}, ${phone}) otpBypassEnabled=${revoke ? "silindi" : "true"}`);
  }

  const gymRef = db.collection("gyms").doc(TEST_GYM_ID);
  const gymSnap = await gymRef.get();
  if (!gymSnap.exists) {
    console.log(`  ! gyms/${TEST_GYM_ID} bulunamadı`);
  } else {
    // Muafiyet geri alınırken alan silinmiyor, `false` yazılıyor:
    // `signup-gym-admin.ts` de bu alanı bilerek açıkça false yazıyor.
    await gymRef.update({ subscriptionExempt: !revoke });
    console.log(`  ✓ gyms/${TEST_GYM_ID} subscriptionExempt=${!revoke}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
