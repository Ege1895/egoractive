import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { onTaskDispatched, Request } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";

import { broadcastToGymMembers } from "../shared/community-broadcast";
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
  // Katılmamış üyelere giden DAVET metni — bkz.
  // `send-group-session-reminder-task.ts`'teki aynı gerekçe.
  lbl_notif_event_invite_title: {
    tr: "🎉 Yarın {eventName} var — katılmak ister misin?",
    en: "🎉 {eventName} is tomorrow — want to join?",
  },
  lbl_notif_event_invite_body: {
    tr: "Saat {time}'te başlıyor ve {remaining} kişilik yer kaldı. Katılmak için bu bildirime dokun 👉",
    en: "It starts at {time} and there are {remaining} spots left. Tap here to join 👉",
  },
  lbl_notif_event_invite_body_unlimited: {
    tr: "Saat {time}'te başlıyor, yer var. Katılmak için bu bildirime dokun 👉",
    en: "It starts at {time} and there's room. Tap here to join 👉",
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
      capacity?: number | null;
      status?: string;
    };

    if (data.dateTime?.toMillis() !== expectedDateTimeMs) return;
    // İptal edilmiş etkinlik için hatırlatma/davet gitmemeli. Bu kontrol
    // önceden YOKTU — iptal edilmiş bir etkinlik için katılımcılara hâlâ
    // "Yarın {eventName} var!" bildirimi gidiyordu.
    if (data.status === "cancelled") {
      logger.info(`Etkinlik ${eventId} iptal edilmiş, bildirim gönderilmedi.`);
      return;
    }

    const attendeeIds = data.attendeeIds ?? [];
    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(data.gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const eventName = data.name?.trim() || (locale === "tr" ? "etkinlik" : "the event");
    const time = data.dateTime ? formatTimeInZone(data.dateTime.toDate(), gymTimeZone) : "--:--";

    // 1) KATILANLAR — "katılacağını unutma" hatırlatması (mevcut davranış).
    if (attendeeIds.length > 0) {
      const attendeeDocs = await Promise.all(attendeeIds.map((uid) => db.collection("users").doc(uid).get()));
      const fcmTokens = attendeeDocs.flatMap((doc) => (doc.data()?.fcmTokens as string[] | undefined) ?? []);
      if (fcmTokens.length > 0) {
        const vars = { eventName, time };
        await getMessaging().sendEachForMulticast({
          tokens: fcmTokens,
          notification: {
            title: readLocalizedNotificationText(template, "lbl_notif_event_reminder_title", locale, vars, DEFAULT_TEXT),
            body: readLocalizedNotificationText(template, "lbl_notif_event_reminder_body", locale, vars, DEFAULT_TEXT),
          },
          data: { type: "event_reminder", eventId },
        });
      } else {
        logger.info(`Etkinlik ${eventId} katılımcılarının hiçbirinde kayıtlı FCM token yok, hatırlatma atlandı.`);
      }
    }

    // 2) KATILMAYANLAR — sadece YER VARSA davet.
    const capacity = typeof data.capacity === "number" ? data.capacity : null;
    const remaining = capacity === null ? null : capacity - attendeeIds.length;
    if (remaining !== null && remaining <= 0) {
      logger.info(`Etkinlik ${eventId} kontenjanı dolu, davet gönderilmedi.`);
      return;
    }

    if (!data.gymId) return;
    await broadcastToGymMembers(
      data.gymId,
      {
        title: readLocalizedNotificationText(
          template,
          "lbl_notif_event_invite_title",
          locale,
          { eventName, time },
          DEFAULT_TEXT,
        ),
        body: readLocalizedNotificationText(
          template,
          remaining === null ? "lbl_notif_event_invite_body_unlimited" : "lbl_notif_event_invite_body",
          locale,
          { eventName, time, remaining: `${remaining ?? ""}` },
          DEFAULT_TEXT,
        ),
      },
      { type: "event_invite", eventId },
      { excludeUids: attendeeIds },
    );
  }),
);
