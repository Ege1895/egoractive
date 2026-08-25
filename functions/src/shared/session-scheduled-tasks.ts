import { getFunctions } from "firebase-admin/functions";
import * as logger from "firebase-functions/logger";

/**
 * Cloud Tasks görev ID'si sessionId + o alanın (startTime/endTime) o anki
 * değerinden türetilir — böylece erteleme/iptal, hangi görevi sileceğini
 * bilmek için ayrıca bir Firestore alanına (ör. "reminderTaskName") ihtiyaç
 * duymaz: eski değerden ID'yi yeniden hesaplayıp silebilir.
 */
function sessionTaskId(sessionId: string, timeMs: number): string {
  return `${sessionId}_${timeMs}`;
}

function isTaskAlreadyExistsError(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && String((error as { code?: unknown }).code).includes("task-already-exists");
}

/**
 * `idTimeMs`, görev ID'sinin türediği (dokümandaki alanın değeri —
 * schedule ile cancel'ın aynı ID'yi üretebilmesi için sabit kalması
 * gereken) zaman; `fireAtMs` ise GERÇEKTEN ateşlenmesi istenen zaman
 * (reminder'da lead süresi düşülmüş hali, completion'da aynısı). Geçmişte
 * kaldıysa hemen ateşlenir, hiç kaybolmaz.
 */
async function enqueueSessionTask(
  queueName: string,
  sessionId: string,
  idTimeMs: number,
  fireAtMs: number,
  data: Record<string, unknown>,
): Promise<void> {
  const clampedFireAtMs = Math.max(fireAtMs, Date.now());
  try {
    await getFunctions()
      .taskQueue(queueName)
      .enqueue(
        { sessionId, ...data },
        { id: sessionTaskId(sessionId, idTimeMs), scheduleTime: new Date(clampedFireAtMs) },
      );
  } catch (error) {
    if (!isTaskAlreadyExistsError(error)) throw error;
    logger.info(`${queueName} görevi zaten kurulu, atlandı: ${sessionId}`, error);
  }
}

/**
 * Task zaten ateşlenmiş ya da daha önce silinmişse Cloud Tasks hata
 * fırlatır — bu, erteleme/iptal akışında beklenen ve zararsız bir durum
 * olduğu için yutuluyor.
 */
async function cancelSessionTask(queueName: string, sessionId: string, idTimeMs: number): Promise<void> {
  try {
    await getFunctions().taskQueue(queueName).delete(sessionTaskId(sessionId, idTimeMs));
  } catch (error) {
    logger.info(`${queueName} görevi silinemedi (muhtemelen zaten ateşlenmiş): ${sessionId}`, error);
  }
}

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
  await enqueueSessionTask(REMINDER_QUEUE, sessionId, startTimeMs, startTimeMs - leadMinutes * 60_000, {
    expectedStartTimeMs: startTimeMs,
  });
}

export async function cancelSessionReminderTask(sessionId: string, startTimeMs: number): Promise<void> {
  await cancelSessionTask(REMINDER_QUEUE, sessionId, startTimeMs);
}

/**
 * Bir seans oluşturulduğunda/ertelendiğinde, bitişinde antrenöre
 * "tamamlandı mı?" görevi kurar. Reminder'ın aksine geçmişte kalmış bir
 * bitiş zamanı için de kurulur (o an itibarıyla hemen ateşlenir) — zaten
 * bu görevin var oluş amacı, session bitince antrenöre sorulması.
 */
export async function scheduleSessionCompletionTask(sessionId: string, endTimeMs: number): Promise<void> {
  await enqueueSessionTask(COMPLETION_QUEUE, sessionId, endTimeMs, endTimeMs, { expectedEndTimeMs: endTimeMs });
}

export async function cancelSessionCompletionTask(sessionId: string, endTimeMs: number): Promise<void> {
  await cancelSessionTask(COMPLETION_QUEUE, sessionId, endTimeMs);
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
