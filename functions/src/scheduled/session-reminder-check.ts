import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

const DEFAULT_REMINDER_MINUTES = 60;

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_session_reminder_title: {
    tr: "⏰ Bugün {time}'de dersin var!",
    en: "⏰ Your session is at {time} today!",
  },
  lbl_notif_session_reminder_body: {
    tr: "{trainerName} seni bekliyor. Gelip gelmeyeceğini onaylamak için dokun 👇",
    en: "{trainerName} is waiting for you. Tap to confirm you're coming 👇",
  },
};

const FALLBACK_TRAINER_NAME: Record<string, string> = { tr: "Antrenörün", en: "Your trainer" };

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
 * seçer (client bunu FCM token kaydederken cihaz dilinden yazıyor), RC'de
 * karşılığı yoksa kod içindeki varsayılana düşer. `{time}`/`{trainerName}`
 * yer tutucularını gerçek değerlerle değiştirip kişiselleştirilmiş bir
 * metin döner — jenerik "dersin yaklaşıyor" yerine somut, harekete
 * geçirici bir bildirim (UX kalitesi için bilerek tasarlandı).
 */
function readNotificationText(
  template: RemoteConfigTemplate,
  baseKey: string,
  locale: string,
  vars: Record<string, string>,
): string {
  const lang = locale === "tr" ? "tr" : "en";
  const raw = readParam(template, `${baseKey}_${lang}`) ?? DEFAULT_TEXT[baseKey][lang];
  return Object.entries(vars).reduce((text, [key, value]) => text.replaceAll(`{${key}}`, value), raw);
}

function formatTime(date: Date): string {
  return `${date.getHours().toString().padStart(2, "0")}:${date.getMinutes().toString().padStart(2, "0")}`;
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
    const sessionData = sessionDoc.data() as { memberId?: string; trainerName?: string; startTime?: Timestamp };
    const { memberId } = sessionData;
    if (!memberId) continue;

    const memberDoc = await db.collection("users").doc(memberId).get();
    const fcmTokens = (memberDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Üye ${memberId} için kayıtlı FCM token yok, atlandı.`);
      await sessionDoc.ref.update({ confirmationRequested: true });
      continue;
    }

    const locale = (memberDoc.data()?.locale as string | undefined) ?? "en";
    const lang = locale === "tr" ? "tr" : "en";
    const vars = {
      time: sessionData.startTime ? formatTime(sessionData.startTime.toDate()) : "--:--",
      trainerName: sessionData.trainerName?.trim() || FALLBACK_TRAINER_NAME[lang],
    };

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readNotificationText(template, "lbl_notif_session_reminder_title", locale, vars),
        body: readNotificationText(template, "lbl_notif_session_reminder_body", locale, vars),
      },
      data: { type: "session_reminder", sessionId: sessionDoc.id },
    });

    await sessionDoc.ref.update({ confirmationRequested: true });
  }
});
