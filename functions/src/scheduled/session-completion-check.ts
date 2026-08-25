import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { mapWithConcurrency } from "../shared/concurrency";
import { withFailureAlerting } from "../shared/function-health";

const SESSION_CONCURRENCY = 25;

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_session_completion_title: {
    tr: "✅ Dersini onaylar mısın?",
    en: "✅ Can you confirm your session?",
  },
  lbl_notif_session_completion_body: {
    tr: "{memberName} ile dersin bitti. Tamamlandı mı, yoksa üye gelmedi mi?",
    en: "Your session with {memberName} has ended. Was it completed, or did they not show up?",
  },
};

function readParam(template: RemoteConfigTemplate, key: string): string | undefined {
  const param = template.parameters[key];
  return param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
}

function readNotificationText(
  template: RemoteConfigTemplate,
  baseKey: string,
  locale: string,
  vars: Record<string, string>,
): string {
  const lang = locale === "tr" ? "tr" : "en";
  const raw = readParam(template, `${baseKey}_${lang}`) ?? DEFAULT_TEXT[baseKey][lang];
  return Object.entries(vars).reduce((text, [key, value]) => text.replaceAll(`{${key}}`, value), raw);
}

/**
 * F3-5 — 15 dakikada bir çalışır: bitişi (`endTime`) geçmiş ama hâlâ
 * `planned` kalan (henüz antrenör onayı bekleyen) seansları bulur,
 * antrenöre push gönderir ve `completionPushSent: true` yapar — bu alan
 * aynı seans için ikinci kez bildirim gitmesini engeller. Gerçek
 * "tamamlandı" işaretlemesi ve `remainingSessions` düşürme işlemi
 * client'ta (`SessionCompletionPanel`) bir transaction ile yapılır.
 */
export const sessionCompletionCheck = onSchedule("every 15 minutes", withFailureAlerting("sessionCompletionCheck", async () => {
  const db = getFirestore();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, varsayılanlar kullanılıyor.", error);
    template = { parameters: {} } as RemoteConfigTemplate;
  }

  const now = Timestamp.now();
  const dueSessions = await db
    .collection("sessions")
    .where("status", "==", "planned")
    .where("completionPushSent", "==", false)
    .where("endTime", "<=", now)
    .get();

  if (dueSessions.empty) {
    logger.info("Onay gereken tamamlanmış seans yok.");
    return;
  }

  // Aynı antrenörün bu pencerede birden fazla bitmiş seansı olabilir —
  // dokümanı her seans için ayrı ayrı okumak yerine uid başına tek
  // Promise'da önbelleğe alınıyor (Promise cache, eşzamanlı isteklerde de
  // tekilleştirir).
  const trainerDocCache = new Map<string, Promise<FirebaseFirestore.DocumentSnapshot>>();
  function getTrainerDoc(trainerId: string): Promise<FirebaseFirestore.DocumentSnapshot> {
    let cached = trainerDocCache.get(trainerId);
    if (!cached) {
      cached = db.collection("users").doc(trainerId).get();
      trainerDocCache.set(trainerId, cached);
    }
    return cached;
  }

  await mapWithConcurrency(dueSessions.docs, SESSION_CONCURRENCY, async (sessionDoc) => {
    const sessionData = sessionDoc.data() as { trainerId?: string; memberName?: string };
    const { trainerId } = sessionData;
    if (!trainerId) return;

    const trainerDoc = await getTrainerDoc(trainerId);
    const fcmTokens = (trainerDoc.data()?.fcmTokens as string[] | undefined) ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Antrenör ${trainerId} için kayıtlı FCM token yok, atlandı.`);
      await sessionDoc.ref.update({ completionPushSent: true });
      return;
    }

    const locale = (trainerDoc.data()?.locale as string | undefined) ?? "en";
    const vars = { memberName: sessionData.memberName?.trim() || (locale === "tr" ? "Üyen" : "Your member") };

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readNotificationText(template, "lbl_notif_session_completion_title", locale, vars),
        body: readNotificationText(template, "lbl_notif_session_completion_body", locale, vars),
      },
      data: { type: "session_completion", sessionId: sessionDoc.id },
    });

    await sessionDoc.ref.update({ completionPushSent: true });
  });
}));
