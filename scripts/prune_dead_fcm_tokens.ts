/**
 * Egoractive — `users/{uid}.fcmTokens` içindeki ÖLÜ token'ların bir kerelik
 * temizliği.
 *
 * Neden gerekli: token uzun süre yalnızca ekleniyordu (`arrayUnion`), hiç
 * silinmiyordu. Bugün üç temizlik yolu var — çıkışta
 * (`removeTokenForCurrentUser`), token yenilenince (`_saveToken`) ve
 * gönderim yanıtındaki "kayıtlı değil" hatasında
 * (`functions/src/shared/dead-token-cleanup.ts`) — ama üçü de BUNDAN SONRA
 * oluşacak durumları kapatıyor. Halihazırda dokümanlarda birikmiş ölü
 * token'lar ancak o kullanıcıya bir bildirim gönderildiğinde temizlenir;
 * bu script onları beklemeden siler.
 *
 * NASIL ÇALIŞIR: Her token'ı FCM'e `dryRun: true` ile gönderir. Dry-run
 * gerçek teslimat YAPMAZ — hiçbir kullanıcıya bildirim düşmez — ama token
 * geçerliliği doğrulanır. `registration-token-not-registered` /
 * `invalid-registration-token` dönen token'lar dokümandan çıkarılır.
 *
 * `invalid-argument` BİLEREK ölü sayılmaz (aynı gerekçe
 * `dead-token-cleanup.ts`'te yazılı: o kod bozuk payload için de dönebiliyor).
 *
 * GÜVENLİK: varsayılan hedef Firestore EMULATOR'ı. Gerçek projeye yazmak
 * için hem `--allow-production` bayrağı hem de
 * `CONFIRM_PRODUCTION_BACKFILL=yes` ortam değişkeni birlikte verilmeli.
 * `--dry-run` ile hiçbir şey yazmadan sadece raporlar.
 *
 * Kullanım (önce mutlaka rapor al):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run prune-dead-tokens -- --allow-production --dry-run
 *
 * Kullanım (gerçek temizlik):
 *   GOOGLE_APPLICATION_CREDENTIALS=... CONFIRM_PRODUCTION_BACKFILL=yes \
 *     npm run prune-dead-tokens -- --allow-production
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

/** `sendEachForMulticast` başına izin verilen azami token sayısı. */
const FCM_MULTICAST_CHUNK_SIZE = 500;

const DEAD_TOKEN_ERROR_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

function projectIdFromArgs(): string {
  const arg = process.argv.find((a) => a.startsWith("--project="));
  return arg ? arg.split("=")[1] : "egoractive-e92bd";
}

const isDryRun = process.argv.includes("--dry-run");

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

  console.log(
    `Proje: ${projectId} — users koleksiyonu taranıyor` + (isDryRun ? " (DRY RUN: hiçbir şey yazılmayacak)" : ""),
  );

  // Token -> onu taşıyan doküman id'leri. Aynı token birden fazla dokümanda
  // olabilir (aynı cihazdan iki hesaba girilip çıkış yapılmamışsa).
  const docIdsByToken = new Map<string, string[]>();
  let scanned = 0;

  let lastDoc: FirebaseFirestore.QueryDocumentSnapshot | undefined;
  for (;;) {
    let query = db.collection("users").orderBy("__name__").limit(500);
    if (lastDoc) query = query.startAfter(lastDoc);
    const snapshot = await query.get();
    if (snapshot.empty) break;

    for (const doc of snapshot.docs) {
      scanned++;
      const tokens = doc.data().fcmTokens;
      if (!Array.isArray(tokens)) continue;
      for (const token of tokens) {
        if (typeof token !== "string" || token.length === 0) continue;
        docIdsByToken.set(token, [...(docIdsByToken.get(token) ?? []), doc.id]);
      }
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    if (snapshot.docs.length < 500) break;
  }

  const allTokens = [...docIdsByToken.keys()];
  console.log(`${scanned} kullanıcı tarandı, ${allTokens.length} benzersiz token bulundu. FCM'e dry-run ile soruluyor...`);

  const dead: string[] = [];
  for (let i = 0; i < allTokens.length; i += FCM_MULTICAST_CHUNK_SIZE) {
    const chunk = allTokens.slice(i, i + FCM_MULTICAST_CHUNK_SIZE);
    // `dryRun: true` — FCM token'ı doğrular ama TESLİMAT YAPMAZ, yani
    // hiçbir kullanıcının telefonunda bildirim görünmez.
    const response = await getMessaging().sendEachForMulticast(
      { tokens: chunk, notification: { title: "", body: "" } },
      true,
    );
    response.responses.forEach((result, index) => {
      if (!result.success && result.error && DEAD_TOKEN_ERROR_CODES.has(result.error.code)) {
        dead.push(chunk[index]);
      }
    });
  }

  const affectedDocs = new Set(dead.flatMap((token) => docIdsByToken.get(token) ?? []));
  console.log(`${dead.length} ölü token, ${affectedDocs.size} dokümanda tespit edildi.`);

  if (isDryRun) {
    console.log("DRY RUN — hiçbir şey silinmedi. Gerçek temizlik için --dry-run bayrağını kaldır.");
    return;
  }
  if (dead.length === 0) return;

  // Doküman başına TEK yazma: aynı dokümandaki tüm ölü token'lar birlikte
  // çıkarılıyor, aksi halde çok token'lı bir kullanıcı için gereksiz yere
  // birden fazla yazma yapılırdı.
  const deadTokensByDoc = new Map<string, string[]>();
  for (const token of dead) {
    for (const docId of docIdsByToken.get(token) ?? []) {
      deadTokensByDoc.set(docId, [...(deadTokensByDoc.get(docId) ?? []), token]);
    }
  }

  let written = 0;
  const entries = [...deadTokensByDoc.entries()];
  for (let i = 0; i < entries.length; i += 400) {
    const batch = db.batch();
    for (const [docId, tokens] of entries.slice(i, i + 400)) {
      batch.update(db.collection("users").doc(docId), { fcmTokens: FieldValue.arrayRemove(...tokens) });
      written++;
    }
    await batch.commit();
  }

  console.log(`Tamamlandı — ${dead.length} ölü token, ${written} dokümandan silindi.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
