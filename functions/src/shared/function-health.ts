import { FieldValue, getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

import { queueEmail } from "./mail";

/** Egora Games'in kendi hata alarmı adresi — F5-2/F6-1'deki sabit sahip adresleriyle aynı. */
const ALERT_EMAIL = "egoragames@gmail.com";
const FAILURE_THRESHOLD = 3;

/**
 * Art arda kaçıncı hatada alarm e-postası atılacağını belirler. Sadece
 * eşiği TAM o hatada geçtiğinde `true` döner (3, 4, 5... değil sadece 3) —
 * aksi halde fonksiyon sürekli hata verirse her çalıştığında ayrı bir mail
 * gider (spam). Saf fonksiyon olarak ayrıldı, test edilebilir olsun diye.
 */
export function shouldAlert(consecutiveFailuresAfterThisOne: number): boolean {
  return consecutiveFailuresAfterThisOne === FAILURE_THRESHOLD;
}

async function recordFailure(functionName: string, error: unknown): Promise<void> {
  const db = getFirestore();
  const ref = db.collection("functionHealth").doc(functionName);
  const message = error instanceof Error ? error.message : String(error);

  const consecutiveFailures = await db.runTransaction(async (tx) => {
    const snapshot = await tx.get(ref);
    const current = (snapshot.data()?.consecutiveFailures as number | undefined) ?? 0;
    const next = current + 1;
    tx.set(ref, { consecutiveFailures: next, lastError: message, lastFailureAt: FieldValue.serverTimestamp() }, { merge: true });
    return next;
  });

  if (shouldAlert(consecutiveFailures)) {
    await queueEmail({
      to: ALERT_EMAIL,
      subject: `Egoractive · ${functionName} art arda ${FAILURE_THRESHOLD} kez hata verdi`,
      html: `<p><b>${functionName}</b> fonksiyonu art arda ${FAILURE_THRESHOLD} kez hata verdi.</p><p>Son hata: ${message}</p>`,
    });
  }
}

async function recordSuccess(functionName: string): Promise<void> {
  await getFirestore().collection("functionHealth").doc(functionName).set({ consecutiveFailures: 0 }, { merge: true });
}

/**
 * F7-3 — bir scheduled/trigger function'ı sarmalar: `functionHealth/{functionName}`
 * Firestore dokümanında art arda hata sayısını tutar, [FAILURE_THRESHOLD]'a
 * ulaşınca mevcut `mail`/`queueEmail` altyapısı üzerinden (F5-2'den beri
 * kurulu Brevo hattı) [ALERT_EMAIL]'e alarm maili gönderir. Başarılı
 * çalışma sayacı sıfırlar. Hatayı yeniden fırlatır — Cloud Functions'ın
 * kendi hata loglaması/yeniden deneme davranışı bu sarmalayıcı yüzünden
 * bozulmasın diye.
 *
 * `isIgnorable` verilirse: bu tahmine uyan hatalar hâlâ fırlatılır (Cloud
 * Functions'ın `retry: true` mekanizması hâlâ çalışsın diye) ama art arda
 * hata sayacını artırmaz/alarm tetiklemez — kendi kendine düzelmesi
 * beklenen, bilinen bir yarış durumu için (bkz. onUserRoleAssigned'daki
 * `auth/user-not-found`) her denemede ayrı bir "gerçek" hata gibi
 * sayılmasın diye.
 */
export function withFailureAlerting<Args extends unknown[]>(
  functionName: string,
  handler: (...args: Args) => Promise<void>,
  options?: { isIgnorable?: (error: unknown) => boolean },
): (...args: Args) => Promise<void> {
  return async (...args: Args) => {
    try {
      await handler(...args);
      await recordSuccess(functionName);
    } catch (error) {
      if (options?.isIgnorable?.(error)) {
        logger.info(`${functionName} beklenen bir hatayla karşılaştı, alarm sayılmadı`, error);
        throw error;
      }
      logger.error(`${functionName} hata verdi`, error);
      await recordFailure(functionName, error);
      throw error;
    }
  };
}
