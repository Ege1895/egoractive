import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

const DEFAULT_REMINDER_MINUTES = 60;

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_session_reminder_title: { tr: "Dersin yaklaşıyor", en: "Your session is coming up" },
  lbl_notif_session_reminder_body: {
    tr: "Yaklaşan dersin için gelip gelmeyeceğini bildir.",
    en: "Let us know if you can make your upcoming session.",
  },
};

function readParam(template: RemoteConfigTemplate, key: string): string | undefined {
  const param = template.parameters[key];
  return param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
}

function readReminderMinutesBefore(template: RemoteConfigTemplate): number {
  const parsed = Number.parseInt(readParam(template, "sessionReminderMinutesBefore") ?? "", 10);
  return Number.isFinite(parsed) ? parsed : DEFAULT_REMINDER_MINUTES;
}

/**
 * F3-4 — bildirim metnini kullanıcının `users/{uid}.locale` alanına göre
 * seçer (client bunu FCM token kaydederken cihaz dilinden yazıyor).
 * RC'de karşılığı yoksa kod içindeki varsayılana düşer.
 */
function readNotificationText(template: RemoteConfigTemplate, baseKey: string, locale: string): string {
  const lang = locale === "en" ? "en" : "tr";
  return readParam(template, `${baseKey}_${lang}`) ?? DEFAULT_TEXT[baseKey][lang];
}

/**
 * F3-4 — 15 dakikada bir çalışır: F1-7'deki `sessionReminderMinutesBefore`
 * RC değerine göre, başlangıcı yaklaşan ve henüz bildirim gönderilmemiş
 * (`confirmationRequested: false`) planlı seansları bulur, üyenin kayıtlı
 * FCM token'larına push gönderir ve `confirmationRequested: true` yapar —
 * bu alan aynı seans için ikinci kez bildirim gitmesini engeller.
 */
export const sessionReminderCheck = onSchedule("every 15 minutes", async () => {
  const db = getFirestore();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, varsayılanlar kullanılıyor.", error);
    template = { parameters: {} } as RemoteConfigTemplate;
  }
  const minutesBefore = readReminderMinutesBefore(template);

  const now = Timestamp.now();
  const windowEnd = Timestamp.fromMillis(now.toMillis() + minutesBefore * 60_000);

  const dueSessions = await db
    .collection("sessions")
    .where("status", "==", "planned")
    .where("confirmationRequested", "==", false)
    .where("startTime", ">=", now)
    .where("startTime", "<=", windowEnd)
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
      await sessionDoc.ref.update({ confirmationRequested: true });
      continue;
    }

    const locale = (memberDoc.data()?.locale as string | undefined) ?? "tr";
    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readNotificationText(template, "lbl_notif_session_reminder_title", locale),
        body: readNotificationText(template, "lbl_notif_session_reminder_body", locale),
      },
      data: { type: "session_reminder", sessionId: sessionDoc.id },
    });

    await sessionDoc.ref.update({ confirmationRequested: true });
  }
});
