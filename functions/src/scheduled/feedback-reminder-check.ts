import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { isFeedbackReminderDue } from "../shared/monthly-schedule";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_feedback_reminder_title: {
    tr: "💬 Bu ay nasıl geçti?",
    en: "💬 How was your month?",
  },
  lbl_notif_feedback_reminder_body: {
    tr: "Deneyimini bizimle paylaşır mısın? 1 dakikanı alır.",
    en: "Would you share your experience with us? It only takes a minute.",
  },
};

function readParam(template: RemoteConfigTemplate, key: string): string | undefined {
  const param = template.parameters[key];
  return param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
}

function readNotificationText(template: RemoteConfigTemplate, baseKey: string, locale: string): string {
  const lang = locale === "tr" ? "tr" : "en";
  return readParam(template, `${baseKey}_${lang}`) ?? DEFAULT_TEXT[baseKey][lang];
}

/**
 * F5-4 — RC'deki `cfg_feedback_reminder_day_of_month` (-1 = ayın son günü)
 * geldiğinde her salonun tüm üyelerine geri bildirim hatırlatma push'u
 * gönderir. Her gün İstanbul saatiyle 10:00'da çalışır — bu doğal olarak
 * ayda bir kez tetiklenmesini sağlar (haftalık raporlardaki gibi saatte bir
 * RC kontrolüne gerek yok, zaten günlük bir cron).
 */
export const feedbackReminderCheck = onSchedule(
  { schedule: "every day 10:00", timeZone: "Europe/Istanbul" },
  async () => {
    const db = getFirestore();
    const now = new Date();

    let template: RemoteConfigTemplate;
    try {
      template = await getRemoteConfig().getTemplate();
    } catch (error) {
      logger.warn("Remote Config okunamadı, feedback hatırlatması atlandı.", error);
      return;
    }

    if (!isFeedbackReminderDue(template, now)) return;

    const membersSnapshot = await db.collection("users").where("role", "==", "member").get();
    if (membersSnapshot.empty) return;

    for (const memberDoc of membersSnapshot.docs) {
      const data = memberDoc.data();
      const fcmTokens = (data.fcmTokens as string[] | undefined) ?? [];
      if (fcmTokens.length === 0) continue;

      const locale = (data.locale as string | undefined) ?? "en";
      await getMessaging().sendEachForMulticast({
        tokens: fcmTokens,
        notification: {
          title: readNotificationText(template, "lbl_notif_feedback_reminder_title", locale),
          body: readNotificationText(template, "lbl_notif_feedback_reminder_body", locale),
        },
        data: { type: "feedback_reminder" },
      });
    }

    logger.info(`Geri bildirim hatırlatması ${membersSnapshot.size} üyeye gönderildi.`);
  },
);
