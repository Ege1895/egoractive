import { Timestamp } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import {
  cancelSessionCompletionTask,
  cancelSessionReminderTask,
  reconcileSessionTask,
  scheduleSessionCompletionTask,
  scheduleSessionReminderTask,
} from "../shared/session-scheduled-tasks";
import { withFailureAlerting } from "../shared/function-health";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

const DEFAULT_REMINDER_MINUTES = 60;

function readReminderMinutesBefore(template: RemoteConfigTemplate): number {
  const param = template.parameters["cfg_session_reminder_minutes_before"];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = Number.parseInt(raw ?? "", 10);
  return Number.isFinite(parsed) ? parsed : DEFAULT_REMINDER_MINUTES;
}

/**
 * F3-4/F3-5'in yerini alır — önceden `sessionReminderCheck`/
 * `sessionCompletionCheck` 15 dakikada bir TÜM `planned` seansları tarayıp
 * sırasıyla başlangıcı/bitişi gelenleri buluyordu. Bu, bir seans o
 * pencerenin ZATEN GEÇTİĞİ bir anda oluşturulursa (ör. seansa 1 saatten az
 * kala oluşturulduysa) bildirimin hiç gönderilmemesine yol açıyordu —
 * polling yalnızca "şu an itibarıyla pencerede olanları" görüyordu.
 *
 * Bunun yerine, her seans yazımında (oluşturma/erteleme/iptal) doğrudan bu
 * SEANSA ÖZEL iki Cloud Tasks görevi (hatırlatma + tamamlama sorusu)
 * kurulur/iptal edilir — event tabanlı, pencere kaçırma riski yok. Görev
 * ID'leri sessionId+zaman alanından türediği için ayrı bir "hangi görevi
 * sileceğim" Firestore alanına gerek kalmıyor (bkz. `session-scheduled-tasks.ts`).
 */
export const onSessionWriteScheduleNotifications = onDocumentWritten(
  "sessions/{sessionId}",
  withFailureAlerting("onSessionWriteScheduleNotifications", async (event) => {
    const sessionId = event.params.sessionId;
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    const beforeData = beforeSnap?.exists ? beforeSnap.data() : undefined;
    const afterData = afterSnap?.exists ? afterSnap.data() : undefined;

    const wasPlanned = beforeData?.status === "planned";
    const isPlanned = afterData?.status === "planned";
    const beforeStartMs = (beforeData?.startTime as Timestamp | undefined)?.toMillis();
    const afterStartMs = (afterData?.startTime as Timestamp | undefined)?.toMillis();
    const beforeEndMs = (beforeData?.endTime as Timestamp | undefined)?.toMillis();
    const afterEndMs = (afterData?.endTime as Timestamp | undefined)?.toMillis();

    let template: RemoteConfigTemplate | undefined;
    async function getTemplate(): Promise<RemoteConfigTemplate> {
      if (template) return template;
      try {
        template = await getCachedRemoteConfigTemplate();
      } catch (error) {
        logger.warn("Remote Config cache okunamadı, varsayılan hatırlatma süresi (60dk) kullanılıyor.", error);
        template = { parameters: {} } as RemoteConfigTemplate;
      }
      return template;
    }

    await reconcileSessionTask(
      { wasPlanned, beforeTimeMs: beforeStartMs, isPlanned, afterTimeMs: afterStartMs },
      (timeMs) => cancelSessionReminderTask(sessionId, timeMs),
      async (timeMs) => scheduleSessionReminderTask(sessionId, timeMs, readReminderMinutesBefore(await getTemplate())),
    );

    await reconcileSessionTask(
      { wasPlanned, beforeTimeMs: beforeEndMs, isPlanned, afterTimeMs: afterEndMs },
      (timeMs) => cancelSessionCompletionTask(sessionId, timeMs),
      (timeMs) => scheduleSessionCompletionTask(sessionId, timeMs),
    );
  }),
);
