import { getFunctions } from "firebase-admin/functions";
import * as logger from "firebase-functions/logger";

/**
 * Cloud Tasks görev ID'si entityId + o alanın (startTime/endTime/dateTime)
 * o anki değerinden türetilir — böylece erteleme/iptal, hangi görevi
 * sileceğini bilmek için ayrıca bir Firestore alanına (ör.
 * "reminderTaskName") ihtiyaç duymaz: eski değerden ID'yi yeniden
 * hesaplayıp silebilir. Seans hatırlatma/tamamlama (`session-scheduled-tasks.ts`)
 * ve etkinlik/grup dersi hatırlatma+duyuru (`community-scheduled-tasks.ts`)
 * bu ortak motoru kullanır.
 */
function scheduledTaskId(entityId: string, idTimeMs: number): string {
  return `${entityId}_${idTimeMs}`;
}

function isTaskAlreadyExistsError(error: unknown): boolean {
  return typeof error === "object" && error !== null && "code" in error && String((error as { code?: unknown }).code).includes("task-already-exists");
}

/**
 * `idTimeMs`, görev ID'sinin türediği (dokümandaki alanın değeri —
 * schedule ile cancel'ın aynı ID'yi üretebilmesi için sabit kalması
 * gereken) zaman; `fireAtMs` ise GERÇEKTEN ateşlenmesi istenen zaman.
 * Geçmişte kaldıysa hemen ateşlenir, hiç kaybolmaz. `data`, görev
 * handler'ının `request.data` ile aynen alacağı YÜKÜN TAMAMI — çağıran
 * taraf kendi id alanını (ör. `sessionId`/`eventId`) kendisi `data`'ya
 * ekler, motor burada dayatmaz (her tüketicinin kendi payload şeklini
 * koruması için).
 */
export async function enqueueScheduledTask(
  queueName: string,
  entityId: string,
  idTimeMs: number,
  fireAtMs: number,
  data: Record<string, unknown>,
): Promise<void> {
  const clampedFireAtMs = Math.max(fireAtMs, Date.now());
  try {
    await getFunctions()
      .taskQueue(queueName)
      .enqueue(data, { id: scheduledTaskId(entityId, idTimeMs), scheduleTime: new Date(clampedFireAtMs) });
  } catch (error) {
    if (!isTaskAlreadyExistsError(error)) throw error;
    logger.info(`${queueName} görevi zaten kurulu, atlandı: ${entityId}`, error);
  }
}

/**
 * Task zaten ateşlenmiş ya da daha önce silinmişse Cloud Tasks hata
 * fırlatır — bu, erteleme/iptal akışında beklenen ve zararsız bir durum
 * olduğu için yutuluyor.
 */
export async function cancelScheduledTask(queueName: string, entityId: string, idTimeMs: number): Promise<void> {
  try {
    await getFunctions().taskQueue(queueName).delete(scheduledTaskId(entityId, idTimeMs));
  } catch (error) {
    logger.info(`${queueName} görevi silinemedi (muhtemelen zaten ateşlenmiş): ${entityId}`, error);
  }
}
