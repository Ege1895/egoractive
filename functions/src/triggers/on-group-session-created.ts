import { Timestamp } from "firebase-admin/firestore";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

import { broadcastToGymMembers } from "../shared/community-broadcast";
import { scheduleGroupSessionReminderTask } from "../shared/community-scheduled-tasks";
import { withFailureAlerting } from "../shared/function-health";
import { readLocalizedNotificationText } from "../shared/notification-text";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { formatTimeInZone, formatWeekdayInZone } from "../shared/timezone-math";

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_group_session_created_title: {
    tr: "🧘 Yeni bir grup dersi eklendi!",
    en: "🧘 A new group class just got added!",
  },
  lbl_notif_group_session_created_body: {
    tr: "{className} · {day} {time}. Hemen katıl!",
    en: "{className} · {day} {time}. Join now!",
  },
};

/**
 * F4-2 — bir admin/antrenör yeni bir grup dersi oluşturduğunda salonun
 * TÜM üyelerine tek seferlik bir duyuru push'u atar; ayrıca dersin (salon
 * saatiyle yerel takvim günü) 1 gün öncesinin 21:00'i için bir hatırlatma
 * görevi kurar. `create_group_session_controller.dart` seçili her gün için
 * AYRI bir `groupSessions` dokümanı oluşturuyor (F3-3'teki tekrarlı seans
 * oluşturma gibi) — yani "Pazartesi+Çarşamba" seçilirse bu trigger 2 kez
 * ateşlenip 2 ayrı duyuru gider; bilinçli bir davranış, her biri gerçek,
 * bağımsız bir ders günü.
 */
export const onGroupSessionCreated = onDocumentCreated(
  "groupSessions/{groupSessionId}",
  withFailureAlerting("onGroupSessionCreated", async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;
    const data = snapshot.data() as {
      gymId?: string;
      title?: string;
      startTime?: Timestamp;
    };
    const gymId = data.gymId;
    if (!gymId) return;

    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const vars = {
      className: data.title?.trim() || (locale === "tr" ? "Yeni grup dersi" : "New group class"),
      day: data.startTime ? formatWeekdayInZone(data.startTime.toDate(), gymTimeZone, locale) : "",
      time: data.startTime ? formatTimeInZone(data.startTime.toDate(), gymTimeZone) : "--:--",
    };

    await broadcastToGymMembers(
      gymId,
      {
        title: readLocalizedNotificationText(template, "lbl_notif_group_session_created_title", locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, "lbl_notif_group_session_created_body", locale, vars, DEFAULT_TEXT),
      },
      { type: "group_session_created", groupSessionId: event.params.groupSessionId },
    );

    if (data.startTime) {
      await scheduleGroupSessionReminderTask(event.params.groupSessionId, data.startTime.toMillis(), gymTimeZone);
    }
  }),
);
