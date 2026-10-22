import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { pruneDeadTokens } from "../shared/dead-token-cleanup";
import { userDoc } from "../shared/firestore-paths";
import { resolveGymTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { readLocalizedNotificationText } from "../shared/notification-text";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

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

/**
 * `onMemberPackageQuotaChanged` Firestore trigger'ının yerini alıyor — o
 * yaklaşım `users/{uid}` üzerindeki HER yazımda (isim/telefon değişikliği,
 * fcmToken yenilenmesi vb. dahil) tetikleniyordu, gerçek sinyal (kalan ders
 * eşiği aşıldı) sadece nadiren oluşsa bile. Client zaten bu hesaplamayı
 * kendi yapıyor (bkz. `resolveMemberPackageAlert` — Dart tarafı,
 * `session_completion_service.dart`'ta seans tamamlanma transaction'ının
 * hemen ardından çağrılıyor) — bu yüzden fonksiyon SADECE gerçekten bir
 * eşik geçişi olduğunda, doğrudan client tarafından çağrılıyor. Gereksiz
 * invocation/Firestore okuma maliyeti kalmıyor.
 *
 * Güvenlik: eşik hesaplaması client'a güvenilir (en kötü ihtimalle bir
 * salonun kendi admin/antrenörü kendi üyesine fazladan/erken bir push
 * attırır — `sendManualNotification`'ın zaten güvendiği aynı güven
 * seviyesi), ama HEDEF üyenin gerçekten çağıranın kendi salonunda bir üye
 * olduğu server-side doğrulanıyor — başka bir salona push attırılamaz.
 */
export const notifyMemberPackageQuota = onCall(async (request) => {
  const role = request.auth?.token?.role as string | undefined;
  const gymId = request.auth?.token?.gymId as string | undefined;
  if (!request.auth?.uid || (role !== "admin" && role !== "trainer") || !gymId) {
    throw new HttpsError("permission-denied", "Bu işlem için salon admin'i veya antrenörü olarak oturum açmış olman gerekiyor.");
  }

  const memberId = typeof request.data?.memberId === "string" ? request.data.memberId : "";
  const alert = request.data?.alert;
  const totalRemainingRaw = request.data?.totalRemaining;
  if (!memberId || (alert !== "endingSoon" && alert !== "none")) {
    throw new HttpsError("invalid-argument", "memberId ve alert ('endingSoon' | 'none') gerekli.");
  }
  const totalRemaining = Number.isInteger(totalRemainingRaw) && totalRemainingRaw >= 0 ? totalRemainingRaw : 0;

  const db = getFirestore();
  const memberSnapshot = await db.doc(userDoc(memberId)).get();
  const memberData = memberSnapshot.data();
  if (!memberSnapshot.exists || memberData?.role !== "member" || memberData?.gymId !== gymId) {
    throw new HttpsError("not-found", "Üye bulunamadı.");
  }

  const fcmTokens = (memberData?.fcmTokens as string[] | undefined) ?? [];
  if (fcmTokens.length === 0) {
    return { sent: false };
  }

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch {
    template = { parameters: {} } as RemoteConfigTemplate;
  }

  const locale = resolveNotificationLocale(await resolveGymTimeZone(gymId));
  const vars = { remaining: String(totalRemaining) };
  const baseKey = alert === "none" ? "lbl_notif_package_none" : "lbl_notif_package_ending_soon";

  const response = await getMessaging().sendEachForMulticast({
    tokens: fcmTokens,
    notification: {
      title: readLocalizedNotificationText(template, `${baseKey}_title`, locale, vars, DEFAULT_TEXT),
      body: readLocalizedNotificationText(template, `${baseKey}_body`, locale, vars, DEFAULT_TEXT),
    },
    data: { type: "member_package_quota", alert },
  });
  await pruneDeadTokens(fcmTokens, response);

  return { sent: true };
});
