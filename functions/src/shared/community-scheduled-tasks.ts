import { enqueueScheduledTask } from "./scheduled-task-engine";
import { oneDayBeforeAt21Local } from "./timezone-math";

const EVENT_REMINDER_QUEUE = "sendEventReminderTask";
const GROUP_SESSION_REMINDER_QUEUE = "sendGroupSessionReminderTask";

/**
 * Bir etkinlik/grup dersi oluşturulduğunda, başlangıcının salon saatiyle
 * YEREL takvim gününden bir gün öncesinin 21:00'ine bir hatırlatma görevi
 * kurar — sadece o an katılmış olanlara gider (görev ateşlendiğinde
 * dokümanın GÜNCEL attendeeIds'i okunur, kuruluş anındaki değil). Bu doğal
 * zamanlama zaten geçmişteyse (ör. etkinlik yarına, saat 22'den sonra
 * oluşturulduysa) hiç kurulmaz — bu bir kritik hatırlatma değil, nazik bir
 * "unutma" notu, seans hatırlatmasındaki gibi "geç kalınmışsa hemen
 * gönder" zorunluluğu yok.
 */
export async function scheduleEventReminderTask(eventId: string, startTimeMs: number, gymTimeZone: string): Promise<void> {
  if (startTimeMs <= Date.now()) return;
  const fireAt = oneDayBeforeAt21Local(new Date(startTimeMs), gymTimeZone);
  if (fireAt.getTime() <= Date.now()) return;
  await enqueueScheduledTask(EVENT_REMINDER_QUEUE, eventId, startTimeMs, fireAt.getTime(), {
    eventId,
    expectedDateTimeMs: startTimeMs,
  });
}

export async function scheduleGroupSessionReminderTask(groupSessionId: string, startTimeMs: number, gymTimeZone: string): Promise<void> {
  if (startTimeMs <= Date.now()) return;
  const fireAt = oneDayBeforeAt21Local(new Date(startTimeMs), gymTimeZone);
  if (fireAt.getTime() <= Date.now()) return;
  await enqueueScheduledTask(GROUP_SESSION_REMINDER_QUEUE, groupSessionId, startTimeMs, fireAt.getTime(), {
    groupSessionId,
    expectedStartTimeMs: startTimeMs,
  });
}
