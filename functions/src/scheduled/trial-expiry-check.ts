import { getFirestore } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { withFailureAlerting } from "../shared/function-health";

function readIntParam(template: RemoteConfigTemplate, key: string, fallback: number): number {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = raw === undefined ? NaN : Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

/**
 * F6-3 — `cfg_trial_duration_days` (Remote Config) süresi dolan salonları
 * `trial` -> `expired` durumuna geçirir. `firestore.rules`'taki
 * `gymSubscriptionAllowsWrite()` bu alanı okuyarak admin'in yeni üye/paket/
 * seans/grup dersi/etkinlik/gider oluşturmasını engeller — client tarafında
 * `subscription_write_gate.dart` aynı durumu proaktif olarak kontrol edip
 * "aboneliğini yenile" uyarısını gösterir.
 */
export const trialExpiryCheck = onSchedule("every 60 minutes", withFailureAlerting("trialExpiryCheck", async () => {
  let trialDurationDays = 14;
  try {
    const template = await getRemoteConfig().getTemplate();
    trialDurationDays = readIntParam(template, "cfg_trial_duration_days", 14);
  } catch (error) {
    logger.warn("Remote Config okunamadı, varsayılan deneme süresi (14 gün) kullanılıyor.", error);
  }

  const db = getFirestore();
  const snapshot = await db.collection("gyms").where("subscriptionStatus", "==", "trial").get();
  if (snapshot.empty) return;

  const now = Date.now();
  const batch = db.batch();
  let expiredCount = 0;

  for (const doc of snapshot.docs) {
    const trialStartedAt = doc.data().trialStartedAt?.toDate?.() as Date | undefined;
    if (!trialStartedAt) continue;

    const trialEndsAtMs = trialStartedAt.getTime() + trialDurationDays * 24 * 60 * 60 * 1000;
    if (now >= trialEndsAtMs) {
      batch.update(doc.ref, { subscriptionStatus: "expired" });
      expiredCount++;
    }
  }

  if (expiredCount > 0) {
    await batch.commit();
    logger.info(`${expiredCount} salonun deneme süresi doldu, 'expired' durumuna geçirildi.`);
  }
}));
