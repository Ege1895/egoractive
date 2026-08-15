import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { userDoc, usersCollection } from "../shared/firestore-paths";

const DEFAULT_HOURLY_LIMIT = 10;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;
/** Firebase Cloud Messaging'in `sendEachForMulticast` başına izin verdiği azami token sayısı. */
const FCM_MULTICAST_CHUNK_SIZE = 500;

function readIntParam(template: RemoteConfigTemplate, key: string, fallback: number): number {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = raw === undefined ? NaN : Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

/**
 * F6-4 kabul kriteri: "kötüye kullanımı önlemek için rate-limit var (aynı
 * admin'den saatte N bildirim)". `requestCustomToken`'daki (F1-10) bellek
 * içi pencere deseniyle aynı — fonksiyon soğuk başlatıldığında sıfırlanır,
 * bu fazda kapsam dışı (bkz. o dosyadaki not).
 */
const sendTimestampsByAdmin = new Map<string, number[]>();

function isRateLimited(adminUid: string, hourlyLimit: number): boolean {
  const now = Date.now();
  const recent = (sendTimestampsByAdmin.get(adminUid) ?? []).filter((t) => now - t < RATE_LIMIT_WINDOW_MS);
  recent.push(now);
  sendTimestampsByAdmin.set(adminUid, recent);
  return recent.length > hourlyLimit;
}

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < items.length; i += size) chunks.push(items.slice(i, i + size));
  return chunks;
}

/**
 * F6-4 — admin, tek bir üyeye ya da tüm salona başlık+metin gönderir.
 * `SendNotificationPanel` (client) bu callable'ı çağırır. Hedef üyenin/
 * salonun çağıranın kendi salonuna ait olduğu custom claim (`gymId`) ile
 * doğrulanır — başka bir salona bildirim gönderilemez.
 */
export const sendManualNotification = onCall(async (request) => {
  const uid = request.auth?.uid;
  const role = request.auth?.token?.role as string | undefined;
  const gymId = request.auth?.token?.gymId as string | undefined;
  if (!uid || role !== "admin" || !gymId) {
    throw new HttpsError("permission-denied", "Bu işlem için salon admin'i olarak oturum açmış olman gerekiyor.");
  }

  const targetType = request.data?.targetType;
  const title = typeof request.data?.title === "string" ? request.data.title.trim() : "";
  const message = typeof request.data?.message === "string" ? request.data.message.trim() : "";
  const targetMemberId = typeof request.data?.targetMemberId === "string" ? request.data.targetMemberId : undefined;

  if (targetType !== "singleMember" && targetType !== "wholeGym") {
    throw new HttpsError("invalid-argument", "targetType 'singleMember' veya 'wholeGym' olmalı.");
  }
  if (!title || !message) {
    throw new HttpsError("invalid-argument", "Başlık ve mesaj gerekli.");
  }
  if (targetType === "singleMember" && !targetMemberId) {
    throw new HttpsError("invalid-argument", "targetMemberId gerekli.");
  }

  let hourlyLimit = DEFAULT_HOURLY_LIMIT;
  try {
    const template = await getRemoteConfig().getTemplate();
    hourlyLimit = readIntParam(template, "cfg_manual_notification_hourly_limit", DEFAULT_HOURLY_LIMIT);
  } catch {
    // RC okunamazsa varsayılan limitle devam edilir — bildirim gönderimi
    // RC'nin ayakta olmasına bağımlı kalmamalı.
  }
  if (isRateLimited(uid, hourlyLimit)) {
    throw new HttpsError("resource-exhausted", "Saatlik bildirim gönderme limitine ulaştın.");
  }

  const db = getFirestore();
  let fcmTokens: string[];

  if (targetType === "singleMember") {
    const memberSnapshot = await db.doc(userDoc(targetMemberId as string)).get();
    const memberData = memberSnapshot.data();
    if (!memberData || memberData.gymId !== gymId) {
      throw new HttpsError("not-found", "Üye bulunamadı.");
    }
    fcmTokens = (memberData.fcmTokens as string[] | undefined) ?? [];
  } else {
    const membersSnapshot = await db.collection(usersCollection()).where("gymId", "==", gymId).where("role", "==", "member").get();
    fcmTokens = membersSnapshot.docs.flatMap((doc) => (doc.data().fcmTokens as string[] | undefined) ?? []);
  }

  if (fcmTokens.length === 0) {
    return { sentCount: 0 };
  }

  let sentCount = 0;
  for (const tokenChunk of chunk(fcmTokens, FCM_MULTICAST_CHUNK_SIZE)) {
    const response = await getMessaging().sendEachForMulticast({
      tokens: tokenChunk,
      notification: { title, body: message },
      data: { type: "manual_notification" },
    });
    sentCount += response.successCount;
  }

  return { sentCount };
});
