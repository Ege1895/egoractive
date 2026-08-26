import { getMessaging } from "firebase-admin/messaging";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import { usersCollection } from "../shared/firestore-paths";
import { withFailureAlerting } from "../shared/function-health";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { readLocalizedNotificationText, readRemoteConfigParam } from "../shared/notification-text";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

const DEFAULT_ENDING_SOON_THRESHOLD = 3;

const DEFAULT_TEXT: Record<string, { tr: string; en: string }> = {
  lbl_notif_package_ending_soon_title: {
    tr: "⏳ Paketin bitmek üzere",
    en: "⏳ Your package is running low",
  },
  lbl_notif_package_ending_soon_body: {
    tr: "{remaining} ders hakkın kaldı. Yeni paket için salonunla iletişime geç.",
    en: "You have {remaining} sessions left. Contact your gym to get a new package.",
  },
  lbl_notif_package_none_title: {
    tr: "📦 Paketin bitti",
    en: "📦 Your package has ended",
  },
  lbl_notif_package_none_body: {
    tr: "Ders hakkın kalmadı. Devam edebilmek için yeni bir paket almalısın.",
    en: "You have no sessions left. Get a new package to keep training.",
  },
};

export type MemberPackageAlert = "endingSoon" | "none";

interface MemberQuotaFields {
  role?: string;
  remainingSessions?: number;
  plannedSessionsCount?: number;
}

/**
 * Saf karar mantığı (Firebase'siz test edilebilir) — bir üyenin
 * `remainingSessions + plannedSessionsCount` toplamı (admin Üyeler
 * listesindeki "Kalan ders" ile birebir aynı hesap, bkz.
 * admin_member_summary_mapper.dart) bu yazımda "Bitiyor"/"Paketi yok"
 * eşiğini AŞAĞI doğru mu geçti diye karar verir.
 *
 * Sadece AZALIŞ ilgilendiriyor — admin bir üyeye yeni paket/ek seans
 * tanımlayıp toplamı yükselttiğinde (ör. none'dan endingSoon'a çıksa bile)
 * asla bildirim gönderilmez. Ayrıca zaten "endingSoon" durumundayken tek
 * tek azalan her seansta tekrar tekrar bildirim gitmesin diye sadece
 * eşiği O AN yeni geçen durumlar sinyal üretir — halihazırda eşiğin
 * altındaysa (ör. 2 kalan → 1 kalan) sessiz kalır.
 */
export function resolveMemberPackageAlert(
  before: MemberQuotaFields | undefined,
  after: MemberQuotaFields | undefined,
  endingSoonThreshold: number,
): { alert: MemberPackageAlert; totalRemaining: number } | null {
  if (!before || !after) return null;
  if (after.role !== "member") return null;

  const beforeTotal = (before.remainingSessions ?? 0) + (before.plannedSessionsCount ?? 0);
  const afterTotal = (after.remainingSessions ?? 0) + (after.plannedSessionsCount ?? 0);
  if (afterTotal >= beforeTotal) return null;

  if (beforeTotal > 0 && afterTotal <= 0) {
    return { alert: "none", totalRemaining: 0 };
  }

  const wasAboveThreshold = beforeTotal > endingSoonThreshold;
  if (wasAboveThreshold && afterTotal > 0 && afterTotal <= endingSoonThreshold) {
    return { alert: "endingSoon", totalRemaining: afterTotal };
  }

  return null;
}

/**
 * Üyenin kalan ders toplamı, admin Üyeler listesindeki "Bitiyor"/"Paketi
 * yok" eşiğini aşağı doğru geçtiğinde üyeye push atar. Bu iki alan
 * (`remainingSessions`/`plannedSessionsCount`) sadece seans oluşturma/
 * iptal/tamamlama transaction'larında değiştiği için (bkz.
 * SessionsWriteService, SessionCompletionService) bu trigger pratikte
 * sadece o üç olayda anlamlı bir kontrol yapar — diğer `users/{uid}`
 * yazımlarında (isim değişikliği vb.) `resolveMemberPackageAlert` hemen
 * `null` döner ve fonksiyon erken çıkar.
 */
export const onMemberPackageQuotaChanged = onDocumentUpdated(
  `${usersCollection()}/{uid}`,
  withFailureAlerting("onMemberPackageQuotaChanged", async (event) => {
    const before = event.data?.before?.data() as MemberQuotaFields | undefined;
    const after = event.data?.after?.data() as
      | (MemberQuotaFields & { gymId?: string; fcmTokens?: string[] })
      | undefined;
    if (!after) return;

    let template: RemoteConfigTemplate;
    try {
      template = await getCachedRemoteConfigTemplate();
    } catch (error) {
      logger.warn("Remote Config cache okunamadı, varsayılanlar kullanılıyor.", error);
      template = { parameters: {} } as RemoteConfigTemplate;
    }
    const thresholdRaw = readRemoteConfigParam(template, "cfg_member_ending_soon_sessions_threshold");
    const parsedThreshold = thresholdRaw ? Number(thresholdRaw) : NaN;
    const threshold = Number.isFinite(parsedThreshold) ? parsedThreshold : DEFAULT_ENDING_SOON_THRESHOLD;

    const result = resolveMemberPackageAlert(before, after, threshold);
    if (!result) return;

    const fcmTokens = after.fcmTokens ?? [];
    if (fcmTokens.length === 0) {
      logger.info(`Üye ${event.params.uid} için kayıtlı FCM token yok, atlandı.`);
      return;
    }

    const locale = resolveNotificationLocale(await resolveGymTimeZone(after.gymId));
    const vars = { remaining: String(result.totalRemaining) };
    const baseKey = result.alert === "none" ? "lbl_notif_package_none" : "lbl_notif_package_ending_soon";

    await getMessaging().sendEachForMulticast({
      tokens: fcmTokens,
      notification: {
        title: readLocalizedNotificationText(template, `${baseKey}_title`, locale, vars, DEFAULT_TEXT),
        body: readLocalizedNotificationText(template, `${baseKey}_body`, locale, vars, DEFAULT_TEXT),
      },
      data: { type: "member_package_quota", alert: result.alert },
    });
  }),
);
