import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";

import { gymDoc, subscriptionHistoryCollection, subscriptionTransactionDoc } from "./firestore-paths";
import { VerifiedSubscription } from "./subscription-verification";

export type SubscriptionUpdateSource = "purchase" | "reverify" | "webhook";

/**
 * Salon Abonelik ve Erişim Akışı — bir mağaza doğrulamasının (yeni satın
 * alma, günlük yenileme kontrolü, ya da webhook) SONUCUNU `gyms/{gymId}`'ye
 * ve `subscriptionHistory`'ye yazan TEK ortak yer. `verifySubscriptionPurchase`,
 * `subscriptionRenewalCheck` ve store webhook handler'ları (Apple/Google)
 * hepsi bunu çağırır — durum yazma/trialUsed/history mantığı üç yerde ayrı
 * ayrı tekrarlanmasın diye.
 *
 * `trialUsed` SADECE true'ya çevrilir, asla false'a döndürülmez — bir salon
 * bir kez trial kullandıktan sonra (admin hesabı silinse/değişse, abonelik
 * iptal edilip yeniden alınsa bile) bir daha trial hakkı kazanamaz.
 */
export async function applySubscriptionUpdate(params: {
  gymId: string;
  verified: VerifiedSubscription;
  productId: string;
  platform: "ios" | "android";
  source: SubscriptionUpdateSource;
  /** Ham makbuz/token — günlük yenileme kontrolünün yeniden doğrulayabilmesi için persist edilir. */
  rawVerificationData: string;
}): Promise<"active" | "trial" | "expired"> {
  const { gymId, verified, productId, platform, source, rawVerificationData } = params;
  const status = !verified.isActive ? "expired" : verified.isTrialPeriod ? "trial" : "active";

  const gymUpdate: Record<string, unknown> = {
    subscriptionStatus: status,
    subscriptionExpiresAt: Timestamp.fromMillis(verified.expiresAtMs),
    subscriptionStartedAt: Timestamp.fromMillis(verified.startAtMs),
    subscriptionProductId: productId,
    subscriptionPlatform: platform,
    subscriptionCancelAtPeriodEnd: false,
    subscriptionLastVerificationData: rawVerificationData,
    subscriptionLastVerificationPlatform: platform,
  };
  if (verified.isTrialPeriod) {
    gymUpdate.trialUsed = true;
  }

  const db = getFirestore();
  const batch = db.batch();
  batch.set(db.doc(gymDoc(gymId)), gymUpdate, { merge: true });
  batch.set(db.collection(subscriptionHistoryCollection(gymId)).doc(), {
    status,
    productId,
    platform,
    isTrialPeriod: verified.isTrialPeriod,
    startedAt: Timestamp.fromMillis(verified.startAtMs),
    expiresAt: Timestamp.fromMillis(verified.expiresAtMs),
    source,
    createdAt: FieldValue.serverTimestamp(),
  });
  batch.set(db.doc(subscriptionTransactionDoc(verified.transactionKey)), { gymId }, { merge: true });
  await batch.commit();

  return status;
}

/**
 * Store bir aboneliğin dönem sonunda yenilenmeyeceğini bildirdiğinde (ör.
 * kullanıcı store'dan iptal etti) ama entitlement expiry tarihine kadar hâlâ
 * geçerliyse çağrılır (Bölüm 12) — `subscriptionStatus` `active` kalır,
 * sadece bu bayrak `true` olur. Gerçek erişim kaybı, expiry geçtiğinde
 * `subscriptionRenewalCheck`/webhook'un `applySubscriptionUpdate` ile
 * `expired` yazmasıyla olur.
 */
export async function markSubscriptionCancelAtPeriodEnd(gymId: string): Promise<void> {
  await getFirestore().doc(gymDoc(gymId)).set({ subscriptionCancelAtPeriodEnd: true }, { merge: true });
}

/**
 * Store bir aboneliğin ANINDA iptal/iade edildiğini bildirdiğinde (Apple
 * REFUND/REVOKE, Google SUBSCRIPTION_REVOKED) çağrılır — expiry tarihini
 * beklemeden erişim hemen kesilir.
 */
export async function markSubscriptionCanceled(gymId: string): Promise<void> {
  await getFirestore().doc(gymDoc(gymId)).set({ subscriptionStatus: "canceled" }, { merge: true });
}

/** Store yenileme denemesi başarısız olduğunda (grace/retry döneminde) çağrılır. */
export async function markSubscriptionPastDue(gymId: string): Promise<void> {
  await getFirestore().doc(gymDoc(gymId)).set({ subscriptionStatus: "pastDue" }, { merge: true });
}
