/**
 * Egoractive — `mail` koleksiyonunda birikmiş ESKİ e-posta dokümanlarının
 * bir kerelik temizliği.
 *
 * Neden gerekli: `functions/src/shared/mail.ts` her e-posta için bir
 * doküman ekliyor (`collection("mail").add(...)`) ve hiçbir yerde silme
 * yoktu. Her giriş OTP'si, her haftalık/aylık salon raporu ve her abone
 * özeti kalıcı bir kayıt bırakıyordu. Dokümanın `message.html` alanı
 * e-postanın tam gövdesi — OTP e-postalarında bu, giriş kodunun DÜZ METİN
 * hâli (`otp.ts` kodu tuzlanmış hash olarak saklarken).
 *
 * Bundan SONRASI için çözüm Trigger Email eklentisinin TTL ayarı
 * (`TTL_EXPIRE_TYPE=day`, `TTL_EXPIRE_VALUE=7` — bkz. görev listesi F12-3);
 * eklenti dokümanlara `delivery.expireAt` yazıyor ve Firestore TTL
 * politikası onları siliyor. Ama TTL yalnızca AYARDAN SONRA yazılan
 * dokümanları etkiliyor: eskilerde `delivery.expireAt` alanı hiç yok, yani
 * politika onlara asla dokunmaz. Bu script tam olarak o birikmiş kısmı
 * temizliyor.
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek projeye yazmak
 * için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 * `--dry-run` ile hiçbir şey silmeden rapor alınır.
 *
 * Kullanım (önce mutlaka rapor):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run prune-old-mail -- --allow-production --dry-run
 *
 * Kullanım (gerçek silme, 7 günden eskiler):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run prune-old-mail -- --allow-production --older-than-days=7
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

/** Tek bir `WriteBatch`'e konulacak azami işlem (Firestore sınırı 500). */
const BATCH_LIMIT = 400;

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

function olderThanDaysFromArgs(): number {
  const arg = process.argv.find((a) => a.startsWith("--older-than-days="));
  const parsed = arg ? Number.parseInt(arg.split("=")[1], 10) : 7;
  if (!Number.isFinite(parsed) || parsed < 0) {
    console.error("REDDEDİLDİ: --older-than-days sayı olmalı.");
    process.exit(1);
  }
  return parsed;
}

const isDryRun = process.argv.includes("--dry-run");
/**
 * Zaman damgası HİÇ olmayan dokümanlar varsayılan olarak ATLANIR. Bunlar
 * ya eklenti tarafından henüz işlenmemiş (yani gönderilmeyi bekleyen) ya da
 * beklenmedik biçimde yazılmış kayıtlar; körlemesine silmek gönderilmemiş
 * bir e-postayı yok etmek olurdu.
 */
const includeUndated = process.argv.includes("--include-undated");

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

/**
 * Dokümanın "ne zaman işlendiği". Eklenti `delivery.endTime`'ı gönderim
 * bitince, `delivery.startTime`'ı işleme başlarken yazıyor; ikisi de yoksa
 * yaş bilinmiyor demektir.
 */
function processedAt(data: FirebaseFirestore.DocumentData): Timestamp | null {
  const delivery = data.delivery as { startTime?: unknown; endTime?: unknown } | undefined;
  for (const candidate of [delivery?.endTime, delivery?.startTime]) {
    if (candidate instanceof Timestamp) return candidate;
  }
  return null;
}

async function main() {
  assertSafeToRun();
  const projectId = projectIdFromArgs();
  const olderThanDays = olderThanDaysFromArgs();
  initializeApp({ projectId });
  const db = getFirestore();

  const cutoffMs = Date.now() - olderThanDays * 24 * 60 * 60_000;
  console.log(
    `Proje: ${projectId} — ${olderThanDays} günden eski mail dokümanları taranıyor` +
      (isDryRun ? " (DRY RUN: hiçbir şey silinmeyecek)" : ""),
  );

  let scanned = 0;
  let undated = 0;
  const deletable: FirebaseFirestore.DocumentReference[] = [];

  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  for (;;) {
    let query = db.collection("mail").orderBy("__name__").limit(500);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    for (const doc of snapshot.docs) {
      scanned++;
      const timestamp = processedAt(doc.data());
      if (timestamp === null) {
        undated++;
        if (includeUndated) deletable.push(doc.ref);
        continue;
      }
      if (timestamp.toMillis() < cutoffMs) deletable.push(doc.ref);
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 500) break;
  }

  console.log(
    `${scanned} doküman tarandı, ${deletable.length} tanesi silinebilir. ` +
      `${undated} tanesinin zaman damgası yok (${includeUndated ? "DAHİL edildi" : "atlandı"}).`,
  );

  if (isDryRun || deletable.length === 0) {
    if (isDryRun) console.log("DRY RUN — hiçbir şey silinmedi.");
    return;
  }

  for (let i = 0; i < deletable.length; i += BATCH_LIMIT) {
    const batch = db.batch();
    for (const ref of deletable.slice(i, i + BATCH_LIMIT)) batch.delete(ref);
    await batch.commit();
  }

  console.log(`Tamamlandı — ${deletable.length} mail dokümanı silindi.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
