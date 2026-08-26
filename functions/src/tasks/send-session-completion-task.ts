import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onTaskDispatched, Request } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";

import { withFailureAlerting } from "../shared/function-health";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_session_completion_title: {
    tr: "✅ Dersini onaylar mısın?",
    en: "✅ Can you confirm your session?",
  },
  lbl_notif_session_completion_body: {
    tr: "{memberName} ile dersin bitti. Tamamlandı mı, yoksa üye gelmedi mi?",
    en: "Your session with {memberName} has ended. Was it completed, or did they not show up?",
  },
};

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

interface SessionCompletionTaskData {
  sessionId: string;
  expectedEndTimeMs: number;
}

/**
 * [onSessionWriteScheduleNotifications] tarafından, bir seansın bitişinde
 * ateşlenmek üzere kurulan görevin işleyicisi — antrenöre "tamamlandı mı,
 * üye gelmedi mi?" sorusunu sorar. `expectedEndTimeMs` o an Firestore'daki
 * GERÇEK `endTime` ile karşılaştırılıyor — eşleşmezse seans daha sonra
 * ertelenmiştir (yeni zamanlama için ayrı bir görev zaten kurulmuş olur),
 * sessizce çıkılır. Gerçek "tamamlandı" işaretlemesi ve `remainingSessions`
 * düşürme/iade işlemi client'ta (`SessionCompletionPanel`) yapılır, bu
 * görev sadece antrenöre hatırlatma push'u atar.
 */
export const sendSessionCompletionTask = onTaskDispatched(
  { retryConfig: { maxAttempts: 3 }, rateLimits: { maxConcurrentDispatches: 10 } },
  withFailureAlerting("sendSessionCompletionTask", async (request: Request<SessionCompletionTaskData>) => {
    const { sessionId, expectedEndTimeMs } = request.data;
    const db = getFirestore();
    const sessionRef = db.collection("sessions").doc(sessionId);
    const sessionSnapshot = await sessionRef.get();
    if (!sessionSnapshot.exists) return;

    const sessionData = sessionSnapshot.data() as {
      status?: string;
      completionPushSent?: boolean;
      endTime?: Timestamp;
      trainerId?: string;
      memberName?: string;
      gymId?: string;
    };

    if (sessionData.status !== "planned") return;
    if (sessionData.completionPushSent === true) return;
    if (sessionData.endTime?.toMillis() !== expectedEndTimeMs) return;

    const trainerId = sessionData.trainerId;
    if (!trainerId) return;

    const trainerDoc = await db.collection("users").doc(trainerId).get();
    const fcmTokens = (trainerDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Antrenör ${trainerId} için kayıtlı FCM token yok, atlandı.`);
      await sessionRef.update({ completionPushSent: true });
      return;
    }

    let template: RemoteConfigTemplate;
    try {
      template = await getCachedRemoteConfigTemplate();
    } catch (error) {
      logger.warn("Remote Config cache okunamadı, varsayılanlar kullanılıyor.", error);
      template = { parameters: {} } as RemoteConfigTemplate;
    }

    const locale = resolveNotificationLocale(await resolveGymTimeZone(sessionData.gymId));
    const vars = { memberName: sessionData.memberName?.trim() || (locale === "tr" ? "Üyen" : "Your member") };

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readNotificationText(template, "lbl_notif_session_completion_title", locale, vars),
        body: readNotificationText(template, "lbl_notif_session_completion_body", locale, vars),
      },
      data: { type: "session_completion", sessionId },
    });

    await sessionRef.update({ completionPushSent: true });
  }),
);
