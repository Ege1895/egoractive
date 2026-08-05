import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

const DEFAULT_REMINDER_MINUTES = 60;

async function readReminderMinutesBefore(): Promise<number> {
  try {
    const template = await getRemoteConfig().getTemplate();
    const param = template.parameters["sessionReminderMinutesBefore"];
    const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
    const parsed = raw ? Number.parseInt(raw, 10) : NaN;
    return Number.isFinite(parsed) ? parsed : DEFAULT_REMINDER_MINUTES;
  } catch (error) {
    logger.warn("Remote Config okunamadı, varsayılan kullanılıyor.", error);
    return DEFAULT_REMINDER_MINUTES;
  }
}

/**
 * F2-7 — 15 dakikada bir çalışır: F1-7'deki `sessionReminderMinutesBefore`
 * RC değerine göre, başlangıcı yaklaşan (henüz hatırlatma gönderilmemiş)
 * seansları bulur ve üyenin kayıtlı FCM token'larına push gönderir.
 *
 * Gerçek seans verisi henüz yok (F3'te dolacak) — `gyms/{gymId}/sessions`
 * alt koleksiyonundaki herhangi bir (mock/dummy) dokümanla uçtan uca
 * çalışır; şema hazır olduğunda değişiklik gerekmiyor.
 */
export const sessionReminderCheck = onSchedule("every 15 minutes", async () => {
  const minutesBefore = await readReminderMinutesBefore();
  const db = getFirestore();

  const now = Timestamp.now();
  const windowEnd = Timestamp.fromMillis(now.toMillis() + minutesBefore * 60_000);

  const dueSessions = await db
    .collectionGroup("sessions")
    .where("startsAt", ">=", now)
    .where("startsAt", "<=", windowEnd)
    .where("reminderSent", "==", false)
    .get();

  if (dueSessions.empty) {
    logger.info("Hatırlatma gereken seans yok.");
    return;
  }

  for (const sessionDoc of dueSessions.docs) {
    const { memberId } = sessionDoc.data() as { memberId?: string };
    if (!memberId) continue;

    const memberDoc = await db.collection("users").doc(memberId).get();
    const fcmTokens = (memberDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Üye ${memberId} için kayıtlı FCM token yok, atlandı.`);
      continue;
    }

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: "Dersin yaklaşıyor",
        body: "Yaklaşan dersin için gelip gelmeyeceğini bildir.",
      },
      data: { type: "session_reminder" },
    });

    await sessionDoc.ref.update({ reminderSent: true });
  }
});
