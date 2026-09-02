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
  lbl_notif_group_session_reminder_title: {
    tr: "⏰ Yarın {className} var!",
    en: "⏰ {className} is tomorrow!",
  },
  lbl_notif_group_session_reminder_body: {
    tr: "Katılacağını unutma, saat {time}'te başlıyor 💪",
    en: "Don't forget — it starts at {time} 💪",
  },
  // Katılmamış üyelere giden DAVET metni. Hatırlatmadan bilerek farklı:
  // burada kişi henüz katılmadığı için ne olduğu, ne zaman olduğu, yer
  // kalıp kalmadığı ve NE YAPMASI gerektiği tek bakışta anlaşılmalı.
  lbl_notif_group_session_invite_title: {
    tr: "🧘 Yarın {className} var — katılmak ister misin?",
    en: "🧘 {className} is tomorrow — want to join?",
  },
  lbl_notif_group_session_invite_body: {
    tr: "Saat {time}'te başlıyor ve {remaining} kişilik yer kaldı. Katılmak için bu bildirime dokun 👉",
    en: "It starts at {time} and there are {remaining} spots left. Tap here to join 👉",
  },
  // Kontenjan sınırsızsa "kaç kişilik yer kaldı" cümlesi anlamsız olur.
  lbl_notif_group_session_invite_body_unlimited: {
    tr: "Saat {time}'te başlıyor, yer var. Katılmak için bu bildirime dokun 👉",
    en: "It starts at {time} and there's room. Tap here to join 👉",
  },
};

interface GroupSessionReminderTaskData {
  groupSessionId: string;
  expectedStartTimeMs: number;
}

/**
 * [onGroupSessionCreated] tarafından, bir grup dersinin başlangıcından 1
 * gün önce (salon saatiyle 21:00) ateşlenmek üzere kurulan görevin
 * işleyicisi. İKİ ayrı bildirim gönderir:
 * 1. KATILANLARA (attendeeIds) "katılacağını unutma" hatırlatması.
 * 2. KATILMAYANLARA "yarın var, katılmak ister misin?" daveti — SADECE
 *    kontenjanda yer kaldıysa. Dolu bir derse davet göndermek kullanıcıyı
 *    boşuna heveslendirir.
 * Bkz. `send-event-reminder-task.ts`'teki aynı desen.
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
      capacity?: number | null;
      status?: string;
    };

    if (data.startTime?.toMillis() !== expectedStartTimeMs) return;
    // İptal edilmiş ders için hatırlatma/davet gitmemeli. Bu kontrol
    // önceden YOKTU — iptal edilmiş bir ders için katılımcılara hâlâ
    // "Yarın {className} var!" bildirimi gidiyordu.
    if (data.status === "cancelled") {
      logger.info(`Grup dersi ${groupSessionId} iptal edilmiş, bildirim gönderilmedi.`);
      return;
    }

    const attendeeIds = data.attendeeIds ?? [];
    const template = await getCachedRemoteConfigTemplate();
    const gymTimeZone = await resolveGymTimeZone(data.gymId);
    const locale = resolveNotificationLocale(gymTimeZone);
    const className = data.title?.trim() || (locale === "tr" ? "grup dersi" : "the class");
    const time = data.startTime ? formatTimeInZone(data.startTime.toDate(), gymTimeZone) : "--:--";

    // 1) KATILANLAR — "katılacağını unutma" hatırlatması (mevcut davranış).
    if (attendeeIds.length > 0) {
      const attendeeDocs = await Promise.all(attendeeIds.map((uid) => db.collection("users").doc(uid).get()));
      const fcmTokens = attendeeDocs.flatMap((doc) => (doc.data()?.fcmTokens as string[] | undefined) ?? []);
      if (fcmTokens.length > 0) {
        const vars = { className, time };
        await getMessaging().sendEachForMulticast({
          tokens: fcmTokens,
          notification: {
            title: readLocalizedNotificationText(template, "lbl_notif_group_session_reminder_title", locale, vars, DEFAULT_TEXT),
            body: readLocalizedNotificationText(template, "lbl_notif_group_session_reminder_body", locale, vars, DEFAULT_TEXT),
          },
          data: { type: "group_session_reminder", groupSessionId },
        });
      } else {
        logger.info(`Grup dersi ${groupSessionId} katılımcılarının hiçbirinde kayıtlı FCM token yok, hatırlatma atlandı.`);
      }
    }

    // 2) KATILMAYANLAR — sadece YER VARSA davet. `capacity` null ise
    // kontenjan sınırsız demektir (bkz. `CapacityService`), o durumda da
    // yer vardır ama "kaç kişilik yer kaldı" cümlesi kullanılamaz.
    const capacity = typeof data.capacity === "number" ? data.capacity : null;
    const remaining = capacity === null ? null : capacity - attendeeIds.length;
    if (remaining !== null && remaining <= 0) {
      logger.info(`Grup dersi ${groupSessionId} kontenjanı dolu, davet gönderilmedi.`);
      return;
    }

    if (!data.gymId) return;
    await broadcastToGymMembers(
      data.gymId,
      {
        title: readLocalizedNotificationText(
          template,
          "lbl_notif_group_session_invite_title",
          locale,
          { className, time },
          DEFAULT_TEXT,
        ),
        body: readLocalizedNotificationText(
          template,
          remaining === null
            ? "lbl_notif_group_session_invite_body_unlimited"
            : "lbl_notif_group_session_invite_body",
          locale,
          { className, time, remaining: `${remaining ?? ""}` },
          DEFAULT_TEXT,
        ),
      },
      { type: "group_session_invite", groupSessionId },
      // Katılanlar hariç — onlara yukarıda zaten hatırlatma gitti.
      { excludeUids: attendeeIds },
    );
  }),
);
