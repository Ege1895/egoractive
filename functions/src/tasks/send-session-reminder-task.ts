import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onTaskDispatched, Request } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";

import { pruneDeadTokens } from "../shared/dead-token-cleanup";
import { withFailureAlerting } from "../shared/function-health";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_session_reminder_title: {
    tr: "⏰ Bugün saat {time}'de dersin var!",
    en: "⏰ You've got a session today at {time}!",
  },
  lbl_notif_session_reminder_body: {
    tr: "💪 {trainerName} seni bekliyor, hazırlan!",
    en: "💪 {trainerName} is waiting for you — get ready!",
  },
};

const FALLBACK_TRAINER_NAME: Record<string, string> = { tr: "Antrenörün", en: "Your trainer" };

function readParam(template: RemoteConfigTemplate, key: string): string | undefined {
  const param = template.parameters[key];
  return param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
}

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

/**
 * Cloud Functions runtime'ı UTC'de çalışır — `date.getHours()` sunucunun
 * (UTC) saatini döner, üyenin gördüğü YEREL saati değil (ör. 19:05 yerel
 * saat, UTC+3 farkıyla 22:05 olarak gösterilirdi). Uygulama tek ülkeye
 * özel değil — salon dünyanın herhangi bir yerinde olabilir — bu yüzden
 * saat, seansın gerçekleştiği SALONUN saat dilimine göre formatlanıyor
 * (bkz. [resolveGymTimeZone]).
 */
function formatTime(date: Date, timeZone: string): string {
  return new Intl.DateTimeFormat("tr-TR", {
    timeZone,
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).format(date);
}

interface SessionReminderTaskData {
  sessionId: string;
  expectedStartTimeMs: number;
}

/**
 * [onSessionWriteScheduleNotifications] tarafından, bir seansın başlangıcından
 * 1 saat önce ateşlenmek üzere kurulan görevin işleyicisi. `expectedStartTimeMs`
 * ile o an Firestore'daki GERÇEK `startTime` karşılaştırılıyor — eşleşmezse
 * bu görev, o seans daha sonra ertelendiği için artık geçersiz demektir
 * (yeni zamanlama için ayrı bir görev zaten kurulmuş olur), sessizce çıkılır.
 */
export const sendSessionReminderTask = onTaskDispatched(
  { retryConfig: { maxAttempts: 3 }, rateLimits: { maxConcurrentDispatches: 10 } },
  withFailureAlerting("sendSessionReminderTask", async (request: Request<SessionReminderTaskData>) => {
    const { sessionId, expectedStartTimeMs } = request.data;
    const db = getFirestore();
    const sessionRef = db.collection("sessions").doc(sessionId);
    const sessionSnapshot = await sessionRef.get();
    if (!sessionSnapshot.exists) return;

    const sessionData = sessionSnapshot.data() as {
      status?: string;
      confirmationRequested?: boolean;
      startTime?: Timestamp;
      trainerName?: string;
      memberId?: string;
      gymId?: string;
    };

    if (sessionData.status !== "planned") return;
    if (sessionData.confirmationRequested === true) return;
    if (sessionData.startTime?.toMillis() !== expectedStartTimeMs) return;

    const memberId = sessionData.memberId;
    if (!memberId) return;

    const memberDoc = await db.collection("users").doc(memberId).get();
    const fcmTokens = (memberDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Üye ${memberId} için kayıtlı FCM token yok, atlandı.`);
      await sessionRef.update({ confirmationRequested: true });
      return;
    }

    let template: RemoteConfigTemplate;
    try {
      template = await getCachedRemoteConfigTemplate();
    } catch (error) {
      logger.warn("Remote Config cache okunamadı, varsayılanlar kullanılıyor.", error);
      template = { parameters: {} } as RemoteConfigTemplate;
    }

    const gymTimeZone = await resolveGymTimeZone(sessionData.gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const vars = {
      time: sessionData.startTime ? formatTime(sessionData.startTime.toDate(), gymTimeZone) : "--:--",
      trainerName: sessionData.trainerName?.trim() || FALLBACK_TRAINER_NAME[locale],
    };

    const response = await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readNotificationText(template, "lbl_notif_session_reminder_title", locale, vars),
        body: readNotificationText(template, "lbl_notif_session_reminder_body", locale, vars),
      },
      data: { type: "session_reminder", sessionId },
    });
    await pruneDeadTokens(fcmTokens, response);

    await sessionRef.update({ confirmationRequested: true });
  }),
);
