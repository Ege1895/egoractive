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
  lbl_notif_event_reminder_title: {
    tr: "⏰ Yarın {eventName} var!",
    en: "⏰ {eventName} is tomorrow!",
  },
  lbl_notif_event_reminder_body: {
    tr: "Katılacağını unutma, saat {time}'te başlıyor 🙌",
    en: "Don't forget — it starts at {time} 🙌",
  },
};

interface EventReminderTaskData {
  eventId: string;
  expectedDateTimeMs: number;
}

/**
 * [onEventCreated] tarafından, bir etkinliğin başlangıcından 1 gün önce
 * (salon saatiyle 21:00) ateşlenmek üzere kurulan görevin işleyicisi —
 * SADECE katılmış (attendeeIds) üyelere gider. `expectedDateTimeMs` o an
 * Firestore'daki GERÇEK `dateTime` ile karşılaştırılıyor; etkinliklerin
 * şu an bir "tarihi düzenle" akışı yok ama ileride eklenirse bu görev
 * sessizce geçersiz kalmak yerine kendini iptal eder.
 */
export const sendEventReminderTask = onTaskDispatched(
  { retryConfig: { maxAttempts: 3 }, rateLimits: { maxConcurrentDispatches: 10 } },
  withFailureAlerting("sendEventReminderTask", async (request: Request<EventReminderTaskData>) => {
    const { eventId, expectedDateTimeMs } = request.data;
    const db = getFirestore();
    const eventRef = db.collection("events").doc(eventId);
    const eventSnap = await eventRef.get();
    if (!eventSnap.exists) return;

    const data = eventSnap.data() as {
      gymId?: string;
      name?: string;
      dateTime?: Timestamp;
      attendeeIds?: string[];
    };

    if (data.dateTime?.toMillis() !== expectedDateTimeMs) return;

    const attendeeIds = data.attendeeIds ?? [];
    if (attendeeIds.length === 0) return;

    const attendeeDocs = await Promise.all(attendeeIds.map((uid) => db.collection("users").doc(uid).get()));
    const fcmTokens = attendeeDocs.flatMap((doc) => (doc.data()?.fcmTokens as string[] | undefined) ?? []);
    if (fcmTokens.length === 0) {
      logger.info(`Etkinlik ${eventId} katılımcılarının hiçbirinde kayıtlı FCM token yok, atlandı.`);
      return;
    }

    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(data.gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const vars = {
      eventName: data.name?.trim() || (locale === "tr" ? "etkinlik" : "the event"),
      time: data.dateTime ? formatTimeInZone(data.dateTime.toDate(), gymTimeZone) : "--:--",
    };

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readLocalizedNotificationText(template, "lbl_notif_event_reminder_title", locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, "lbl_notif_event_reminder_body", locale, vars, DEFAULT_TEXT),
      },
      data: { type: "event_reminder", eventId },
    });
  }),
);
