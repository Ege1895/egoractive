import { getFunctions } from "firebase-admin/functions";
import * as logger from "firebase-functions/logger";

/**
 * Cloud Tasks görev ID'si sessionId + o anki startTime'dan türetilir —
 * böylece erteleme/iptal, hangi görevi sileceğini bilmek için ayrıca bir
 * Firestore alanına (ör. "reminderTaskName") ihtiyaç duymaz: eski
 * startTime'dan ID'yi yeniden hesaplayıp silebilir.
 */
export function sessionReminderTaskId(sessionId: string, startTimeMs: number): string {
  return `${sessionId}_${startTimeMs}`;
}

function isTaskAlreadyExistsError(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && String((error as { code?: unknown }).code).includes("task-already-exists");
}

/**
 * Bir seans oluşturulduğunda/ertelendiğinde, başlangıcından
 * `leadMinutes` (Remote Config'teki `sessionReminderMinutesBefore`, F1-7)
 * önceye bir hatırlatma task'ı kurar. O an itibarıyla bu süreden daha az
 * kaldıysa (ör. seans 1 saatten kısa süre sonrasına, ya da hatırlatma
 * penceresi zaten geçmişken oluşturulduysa) hatırlatma HEMEN kurulur —
 * eskiden 15 dakikada bir tarayan sistemde bu durum hatırlatmanın hiç
 * gönderilmemesine yol açıyordu (pencere seans oluşturulmadan ÖNCE
 * geçmişti), burada "geç kalınmış hatırlatma" yine de gönderiliyor.
 * Aynı task ID'siyle enqueue tekrar denenirse (ör. trigger'ın "en az bir
 * kez" teslimatı yüzünden) Cloud Tasks "task-already-exists" ile
 * reddeder — bu durumda görev zaten kurulu demektir, sessizce yutuluyor.
 */
export async function scheduleSessionReminderTask(
  sessionId: string,
  startTimeMs: number,
  leadMinutes: number,
): Promise<void> {
  const now = Date.now();
  if (startTimeMs <= now) return;

  const leadBeforeMs = startTimeMs - leadMinutes * 60 * 1000;
  const fireAtMs = Math.max(leadBeforeMs, now);

  try {
    await getFunctions()
      .taskQueue<{ sessionId: string; expectedStartTimeMs: number }>("sendSessionReminderTask")
      .enqueue(
        { sessionId, expectedStartTimeMs: startTimeMs },
        { id: sessionReminderTaskId(sessionId, startTimeMs), scheduleTime: new Date(fireAtMs) },
      );
  } catch (error) {
    if (!isTaskAlreadyExistsError(error)) throw error;
    logger.info(`Hatırlatma task'ı zaten kurulu, atlandı: ${sessionId}`, error);
  }
}

/**
 * Bir seans ertelendiğinde/iptal edildiğinde/tamamlandığında, o ana kadar
 * geçerli olan (eski) startTime için kurulmuş task'ı iptal eder. Task zaten
 * ateşlenmiş ya da daha önce silinmişse Cloud Tasks hata fırlatır — bu,
 * erteleme/iptal akışında beklenen ve zararsız bir durum olduğu için
 * yutuluyor.
 */
export async function cancelSessionReminderTask(sessionId: string, startTimeMs: number): Promise<void> {
  try {
    await getFunctions().taskQueue("sendSessionReminderTask").delete(sessionReminderTaskId(sessionId, startTimeMs));
  } catch (error) {
    logger.info(`Hatırlatma task'ı silinemedi (muhtemelen zaten ateşlenmiş): ${sessionId}`, error);
  }
}
