import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onTaskDispatched, Request } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";

import { withFailureAlerting } from "../shared/function-health";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { readLocalizedNotificationText } from "../shared/notification-text";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { formatTimeInZone } from "../shared/timezone-math";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_group_session_reminder_title: {
    tr: "⏰ Yarın {className} var!",
    en: "⏰ {className} is tomorrow!",
  },
  lbl_notif_group_session_reminder_body: {
    tr: "Katılacağını unutma, saat {time}'te başlıyor 💪",
    en: "Don't forget — it starts at {time} 💪",
  },
};

interface GroupSessionReminderTaskData {
  groupSessionId: string;
  expectedStartTimeMs: number;
}

/**
 * [onGroupSessionCreated] tarafından, bir grup dersinin başlangıcından 1
 * gün önce (salon saatiyle 21:00) ateşlenmek üzere kurulan görevin
 * işleyicisi — SADECE katılmış (attendeeIds) üyelere gider. Bkz.
 * `send-event-reminder-task.ts`'teki aynı desen.
 */
export const sendGroupSessionReminderTask = onTaskDispatched(
  { retryConfig: { maxAttempts: 3 }, rateLimits: { maxConcurrentDispatches: 10 } },
  withFailureAlerting("sendGroupSessionReminderTask", async (request: Request<GroupSessionReminderTaskData>) => {
    const { groupSessionId, expectedStartTimeMs } = request.data;
    const db = getFirestore();
    const groupSessionRef = db.collection("groupSessions").doc(groupSessionId);
    const groupSessionSnap = await groupSessionRef.get();
    if (!groupSessionSnap.exists) return;

    const data = groupSessionSnap.data() as {
      gymId?: string;
      title?: string;
      startTime?: Timestamp;
      attendeeIds?: string[];
    };

    if (data.startTime?.toMillis() !== expectedStartTimeMs) return;

    const attendeeIds = data.attendeeIds ?? [];
    if (attendeeIds.length === 0) return;

    const attendeeDocs = await Promise.all(attendeeIds.map((uid) => db.collection("users").doc(uid).get()));
    const fcmTokens = attendeeDocs.flatMap((doc) => (doc.data()?.fcmTokens as string[] | undefined) ?? []);
    if (fcmTokens.length === 0) {
      logger.info(`Grup dersi ${groupSessionId} katılımcılarının hiçbirinde kayıtlı FCM token yok, atlandı.`);
      return;
    }

    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(data.gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const vars = {
      className: data.title?.trim() || (locale === "tr" ? "grup dersi" : "the class"),
      time: data.startTime ? formatTimeInZone(data.startTime.toDate(), gymTimeZone) : "--:--",
    };

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readLocalizedNotificationText(template, "lbl_notif_group_session_reminder_title", locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, "lbl_notif_group_session_reminder_body", locale, vars, DEFAULT_TEXT),
      },
      data: { type: "group_session_reminder", groupSessionId },
    });
  }),
);
