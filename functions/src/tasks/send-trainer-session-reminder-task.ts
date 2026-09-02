import { getFirestore, QueryDocumentSnapshot, Timestamp } from "firebase-admin/firestore";
import { onTaskDispatched, Request } from "firebase-functions/v2/tasks";
import * as logger from "firebase-functions/logger";

import { withFailureAlerting } from "../shared/function-health";
import { readLocalizedNotificationText } from "../shared/notification-text";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { fetchTokensForUids, firstName, formatNameList, sendPushToTokens } from "../shared/staff-notifications";
import { formatTimeInZone } from "../shared/timezone-math";

/**
 * Üyeye giden hatırlatmadan (`send-session-reminder-task.ts`) bilerek farklı
 * bir metin: antrenörün günde birden çok dersi olabilir, o yüzden bildirimin
 * tek bakışta "hangi saatte, KİMİNLE" sorusunu cevaplaması gerekiyor. Saat
 * hem başlıkta hem gövdede geçiyor — kilit ekranında başlık kesilse bile
 * bilgi kaybolmasın diye.
 */
const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_trainer_session_reminder_title: {
    tr: "⏰ Bugün {time} · {memberNames} ile dersin var",
    en: "⏰ Today at {time} · session with {memberNames}",
  },
  lbl_notif_trainer_session_reminder_body: {
    tr: "{memberNames} saat {time}'te seni bekliyor. Hazırlanma vakti 💪",
    en: "{memberNames} will be there at {time}. Time to get ready 💪",
  },
};

const FALLBACK_MEMBER_NAME: Record<string, string> = { tr: "üyen", en: "your member" };

/**
 * Görev ateşlendiği anda hâlâ GEÇERLİ olan seanslar: durumu `planned` ve
 * başlangıcı görevin kurulduğu andakiyle aynı olanlar. Saf tutuldu ki düet
 * senaryoları (biri iptal, biri duruyor / ders ertelenmiş / tamamı iptal)
 * Firestore'suz test edilebilsin.
 */
export function selectLiveSessions<T extends { status?: string; startTimeMs?: number }>(
  sessions: readonly T[],
  expectedStartTimeMs: number,
): T[] {
  return sessions.filter((s) => s.status === "planned" && s.startTimeMs === expectedStartTimeMs);
}

interface TrainerSessionReminderTaskData {
  /** Düet derste grubun tamamı, tekil derste seansın kendi id'si. */
  sessionKey: string;
  /** Düet ders ise dolu — o zaman gruptaki TÜM seanslar okunur. */
  duetGroupId?: string;
  expectedStartTimeMs: number;
}

/**
 * [onSessionWriteScheduleNotifications] tarafından, üyeye giden hatırlatmayla
 * AYNI anda (seans başlangıcından `cfg_session_reminder_minutes_before` önce)
 * ateşlenmek üzere kurulan, ANTRENÖRE giden hatırlatma.
 *
 * Düet dersler Firestore'da üye başına AYRI birer seans dokümanı olarak
 * duruyor (ortak `duetGroupId`; üye sayısı 2 ile sınırlı değil). Görev id'si
 * `duetGroupId ?? sessionId`'den
 * türetildiği için iki üyelik bir düet ders iki kez kuyruğa girse bile tek
 * görev oluşuyor (motor `task-already-exists` hatasını yutuyor, bkz.
 * `scheduled-task-engine.ts`) — antrenör tek bildirim alıyor, içinde her iki
 * üyenin adı geçiyor.
 *
 * Görev İPTAL EDİLMİYOR; bunun yerine ateşlendiği anda durum yeniden
 * okunuyor. Sebep düet: paylaşılan görev id'si yüzünden, gruptaki tek bir
 * üyenin seansı iptal edildiğinde görevi silmek diğer üyenin hatırlatmasını
 * da götürürdü. Ateşlenme anında hâlâ `planned` olan ve saati eşleşen seans
 * kalmadıysa sessizce çıkılıyor; kalanlar varsa bildirim sadece onların
 * adıyla gidiyor.
 */
export const sendTrainerSessionReminderTask = onTaskDispatched(
  { retryConfig: { maxAttempts: 3 }, rateLimits: { maxConcurrentDispatches: 10 } },
  withFailureAlerting("sendTrainerSessionReminderTask", async (request: Request<TrainerSessionReminderTaskData>) => {
    const { sessionKey, duetGroupId, expectedStartTimeMs } = request.data;
    const db = getFirestore();

    const docs: QueryDocumentSnapshot[] = duetGroupId
      ? (await db.collection("sessions").where("duetGroupId", "==", duetGroupId).get()).docs
      : await db
          .collection("sessions")
          .doc(sessionKey)
          .get()
          .then((snap) => (snap.exists ? [snap as QueryDocumentSnapshot] : []));

    const live = selectLiveSessions(
      docs.map((doc) => ({
        doc,
        status: doc.data().status as string | undefined,
        startTimeMs: (doc.data().startTime as Timestamp | undefined)?.toMillis(),
      })),
      expectedStartTimeMs,
    ).map((item) => item.doc);
    if (live.length === 0) {
      logger.info(`Antrenör hatırlatması atlandı, geçerli seans kalmamış: ${sessionKey}`);
      return;
    }

    const first = live[0].data();
    const trainerId = first.trainerId as string | undefined;
    if (!trainerId) return;

    const fcmTokens = await fetchTokensForUids([trainerId], db);
    if (fcmTokens.length === 0) {
      logger.info(`Antrenör ${trainerId} için kayıtlı FCM token yok, atlandı.`);
      return;
    }

    const gymTimeZone = await resolveGymTimeZone(first.gymId as string | undefined);
    const locale = resolveNotificationLocale(gymTimeZone);
    const names = live.map((doc) => firstName(doc.data().memberName as string | undefined));
    const vars = {
      time: formatTimeInZone((first.startTime as Timestamp).toDate(), gymTimeZone),
      memberNames: formatNameList(names) || FALLBACK_MEMBER_NAME[locale],
    };

    const template = await getCachedRemoteConfigTemplate();
    await sendPushToTokens(
      fcmTokens,
      {
        title: readLocalizedNotificationText(template, "lbl_notif_trainer_session_reminder_title", locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, "lbl_notif_trainer_session_reminder_body", locale, vars, DEFAULT_TEXT),
      },
      { type: "trainer_session_reminder", sessionId: live[0].id },
    );
  }),
);
