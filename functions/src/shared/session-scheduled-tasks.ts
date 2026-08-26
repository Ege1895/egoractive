import { cancelScheduledTask, enqueueScheduledTask } from "./scheduled-task-engine";

const REMINDER_QUEUE = "sendSessionReminderTask";
const COMPLETION_QUEUE = "sendSessionCompletionTask";

/**
 * Bir seans oluşturulduğunda/ertelendiğinde, başlangıcından `leadMinutes`
 * (Remote Config'teki `cfg_session_reminder_minutes_before`) önceye üyeye
 * bir hatırlatma görevi kurar. Seans zaten başlamışsa (ör. bu, geçmişte
 * kalmış bir seansın alakasız bir alan güncellemesiyse) hiç kurulmaz.
 */
export async function scheduleSessionReminderTask(
  sessionId: string,
  startTimeMs: number,
  leadMinutes: number,
): Promise<void> {
  if (startTimeMs <= Date.now()) return;
  await enqueueScheduledTask(REMINDER_QUEUE, sessionId, startTimeMs, startTimeMs - leadMinutes * 60_000, {
    sessionId,
    expectedStartTimeMs: startTimeMs,
  });
}

export async function cancelSessionReminderTask(sessionId: string, startTimeMs: number): Promise<void> {
  await cancelScheduledTask(REMINDER_QUEUE, sessionId, startTimeMs);
}

/**
 * Bir seans oluşturulduğunda/ertelendiğinde, bitişinden `delayMinutes`
 * (admin'in Yetki Ayarları'ndan o antrenöre özel setlediği süre, bkz.
 * `trainer-completion-delay.ts`) sonra antrenöre "tamamlandı mı?" görevi
 * kurar. Reminder'ın aksine geçmişte kalmış bir zaman için de kurulur (o
 * an itibarıyla hemen ateşlenir) — zaten bu görevin var oluş amacı,
 * session bitince antrenöre sorulması. Görev ID'si (idTimeMs) hâlâ ham
 * `endTimeMs`'e dayanıyor — gecikme değişse bile aynı seansın aynı
 * bitişi için tek görev kalması, gecikme aynı kalsa bile erteleme/iptal
 * karşılaştırmasının doğru çalışması için.
 */
export async function scheduleSessionCompletionTask(
  sessionId: string,
  endTimeMs: number,
  delayMinutes: number,
): Promise<void> {
  await enqueueScheduledTask(COMPLETION_QUEUE, sessionId, endTimeMs, endTimeMs + delayMinutes * 60_000, {
    sessionId,
    expectedEndTimeMs: endTimeMs,
  });
}

export async function cancelSessionCompletionTask(sessionId: string, endTimeMs: number): Promise<void> {
  await cancelScheduledTask(COMPLETION_QUEUE, sessionId, endTimeMs);
}

/**
 * Bir seans dokümanının 'planned' durumundayken taşıdığı bir zaman
 * alanının (startTime ya da endTime) yazım öncesi/sonrası durumunu
 * karşılaştırıp buna göre eski görevi iptal edip/yenisini kurar —
 * [onSessionWriteScheduleNotifications] hem hatırlatma hem tamamlama
 * görevi için bunu kullanır, iki yerde aynı karşılaştırma mantığını elle
 * tekrarlamamak için.
 */
export async function reconcileSessionTask(
  params: {
    wasPlanned: boolean;
    beforeTimeMs: number | undefined;
    isPlanned: boolean;
    afterTimeMs: number | undefined;
  },
  cancel: (timeMs: number) => Promise<void>,
  schedule: (timeMs: number) => Promise<void>,
): Promise<void> {
  const sameTimeStillPlanned =
    params.wasPlanned && params.isPlanned && params.beforeTimeMs === params.afterTimeMs;

  if (params.wasPlanned && params.beforeTimeMs !== undefined && !sameTimeStillPlanned) {
    await cancel(params.beforeTimeMs);
  }

  if (sameTimeStillPlanned) return;
  if (!params.isPlanned || params.afterTimeMs === undefined) return;

  await schedule(params.afterTimeMs);
}
