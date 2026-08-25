import { Timestamp } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import { cancelSessionReminderTask, scheduleSessionReminderTask } from "../shared/session-reminder-tasks";
import { withFailureAlerting } from "../shared/function-health";

const DEFAULT_REMINDER_MINUTES = 60;

function readReminderMinutesBefore(template: RemoteConfigTemplate): number {
  const param = template.parameters["cfg_session_reminder_minutes_before"];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = Number.parseInt(raw ?? "", 10);
  return Number.isFinite(parsed) ? parsed : DEFAULT_REMINDER_MINUTES;
}

/**
 * F3-4'ün yerini alır — önceden `sessionReminderCheck` 15 dakikada bir TÜM
 * `planned` seansları tarayıp başlangıcına `sessionReminderMinutesBefore`
 * kalanları buluyordu. Bu, bir seans o pencerenin ZATEN GEÇTİĞİ bir anda
 * oluşturulursa (ör. seansa 1 saatten az kala oluşturulduysa) hatırlatmanın
 * hiç gönderilmemesine yol açıyordu — polling yalnızca "şu an itibarıyla
 * pencerede olanları" görüyordu, geçmişte kalan bir pencereyi asla
 * yakalamıyordu.
 *
 * Bunun yerine, her seans yazımında (oluşturma/erteleme/iptal) doğrudan bu
 * SEANSA ÖZEL bir Cloud Tasks görevi kurulur/iptal edilir — event tabanlı,
 * pencere kaçırma riski yok. Görev ID'si sessionId+startTime'dan
 * türediği için (bkz. [sessionReminderTaskId]) ayrı bir "hangi görevi
 * sileceğim" alanına gerek kalmıyor.
 */
export const onSessionWriteScheduleReminder = onDocumentWritten(
  "sessions/{sessionId}",
  withFailureAlerting("onSessionWriteScheduleReminder", async (event) => {
    const sessionId = event.params.sessionId;
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    const beforeData = beforeSnap?.exists ? beforeSnap.data() : undefined;
    const afterData = afterSnap?.exists ? afterSnap.data() : undefined;

    const beforeStart = beforeData?.startTime as Timestamp | undefined;
    const beforeWasPlanned = beforeData?.status === "planned";
    const afterStart = afterData?.startTime as Timestamp | undefined;
    const afterIsPlanned = afterData?.status === "planned";

    const sameTimeStillPlanned =
      beforeWasPlanned && afterIsPlanned && beforeStart?.toMillis() === afterStart?.toMillis();

    // Önceden kurulmuş bir görev varsa (doküman daha önce 'planned' ve bir
    // startTime'a sahipti) ve o zamanlama artık geçerli değilse (silindi,
    // iptal edildi, tamamlandı ya da ertelendi) eski görev iptal edilir.
    if (beforeWasPlanned && beforeStart && !sameTimeStillPlanned) {
      await cancelSessionReminderTask(sessionId, beforeStart.toMillis());
    }

    // startTime değişmediyse (ör. sadece completionPushSent/attended gibi
    // alakasız bir alan güncellendiyse) zaten kurulu görev geçerliliğini
    // koruyor, yeniden kurmaya gerek yok.
    if (sameTimeStillPlanned) return;
    if (!afterIsPlanned || !afterStart) return;

    let template: RemoteConfigTemplate;
    try {
      template = await getRemoteConfig().getTemplate();
    } catch (error) {
      logger.warn("Remote Config okunamadı, varsayılan hatırlatma süresi (60dk) kullanılıyor.", error);
      template = { parameters: {} } as RemoteConfigTemplate;
    }

    await scheduleSessionReminderTask(sessionId, afterStart.toMillis(), readReminderMinutesBefore(template));
  }),
);
