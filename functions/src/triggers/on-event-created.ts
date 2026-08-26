import { Timestamp } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { broadcastToGymMembers } from "../shared/community-broadcast";
import { scheduleEventReminderTask } from "../shared/community-scheduled-tasks";
import { withFailureAlerting } from "../shared/function-health";
import { readLocalizedNotificationText } from "../shared/notification-text";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { formatDateInZone } from "../shared/timezone-math";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_event_created_title: {
    tr: "🎉 Yeni bir etkinlik eklendi!",
    en: "🎉 A new event just got added!",
  },
  lbl_notif_event_created_body: {
    tr: "{eventName} · {date}. Hemen göz at, yerini ayırt!",
    en: "{eventName} · {date}. Take a look and grab your spot!",
  },
};

/**
 * F4-3 — bir admin yeni bir etkinlik oluşturduğunda salonun TÜM üyelerine
 * tek seferlik bir duyuru push'u atar; ayrıca etkinliğin (salon saatiyle
 * yerel takvim günü) 1 gün öncesinin 21:00'i için — sadece o an katılmış
 * olanlara gidecek — bir hatırlatma görevi kurar (bkz.
 * `community-scheduled-tasks.ts`). Etkinliklerin şu an bir "tarihi
 * düzenle" akışı olmadığı için (sadece oluşturma var) bu trigger sadece
 * `onDocumentCreated`, `onSessionWriteScheduleNotifications`'taki gibi bir
 * erteleme/iptal karşılaştırmasına gerek yok.
 */
export const onEventCreated = onDocumentCreated(
  "events/{eventId}",
  withFailureAlerting("onEventCreated", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const data = snapshot.data() as {
      gymId?: string;
      name?: string;
      dateTime?: Timestamp;
    };
    const gymId = data.gymId;
    if (!gymId) return;

    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const vars = {
      eventName: data.name?.trim() || (locale === "tr" ? "Yeni etkinlik" : "New event"),
      date: data.dateTime ? formatDateInZone(data.dateTime.toDate(), gymTimeZone, locale) : "",
    };

    await broadcastToGymMembers(
      gymId,
      {
        title: readLocalizedNotificationText(template, "lbl_notif_event_created_title", locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, "lbl_notif_event_created_body", locale, vars, DEFAULT_TEXT),
      },
      { type: "event_created", eventId: event.params.eventId },
    );

    if (data.dateTime) {
      await scheduleEventReminderTask(event.params.eventId, data.dateTime.toMillis(), gymTimeZone);
    }
  }),
);
