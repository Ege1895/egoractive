import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

import { pruneDeadTokens } from "./dead-token-cleanup";

/** Firebase Cloud Messaging'in `sendEachForMulticast` başına izin verdiği azami token sayısı. */
const FCM_MULTICAST_CHUNK_SIZE = 500;

function chunk<T>(items: T[], size: number): T[][] {
  const chunks: T[][] = [];
  for (let i = 0; i < items.length; i += size) chunks.push(items.slice(i, i + size));
  return chunks;
}

/**
 * Bir salonun TÜM üyelerine tek seferlik bir duyuru push'u atar (ör. yeni
 * etkinlik/grup dersi oluşturulduğunda) — `sendManualNotification`'daki
 * "tüm salon" hedeflemesiyle aynı sorgu deseni.
 */
export async function broadcastToGymMembers(
  gymId: string,
  notification: { title: string; body: string },
  data: Record<string, string>,
  options: {
    /**
     * Bildirim gönderilmeyecek üye uid'leri. "Yarın grup dersi var,
     * katılmak ister misin?" davetinde KATILMIŞ üyeleri hariç tutmak için
     * — onlara zaten ayrı bir "katılacağını unutma" hatırlatması gidiyor,
     * iki bildirim birden almasınlar.
     */
    excludeUids?: readonly string[];
  } = {},
): Promise<void> {
  const db = getFirestore();
  const membersSnapshot = await db.collection("users").where("gymId", "==", gymId).where("role", "==", "member").get();
  const excluded = new Set(options.excludeUids ?? []);
  const fcmTokens = membersSnapshot.docs
    .filter((doc) => !excluded.has(doc.id))
    .flatMap((doc) => (doc.data().fcmTokens as string[] | undefined) ?? []);
  if (fcmTokens.length === 0) return;

  for (const tokenChunk of chunk(fcmTokens, FCM_MULTICAST_CHUNK_SIZE)) {
    const response = await getMessaging().sendEachForMulticast({ tokens: tokenChunk, notification, data });
    await pruneDeadTokens(tokenChunk, response);
  }
}
