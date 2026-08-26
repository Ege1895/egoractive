import { FieldValue, getFirestore, Timestamp } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { gymDoc, subscriptionHistoryCollection } from "../shared/firestore-paths";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { isKnownSubscriptionProductId } from "../shared/subscription-constants";

function readBoolParam(template: RemoteConfigTemplate, key: string, fallback: boolean): boolean {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  if (raw === undefined) return fallback;
  return raw === "true";
}

/**
 * GEÇİCİ — App Store Connect/Play Console ürünleri henüz canlıya alınmadığı
 * için `SubscriptionOnboardingPanel`'deki mock ürün listesiyle (bkz.
 * `mockSubscriptionProducts`) gerçek bir `in_app_purchase` satın alması
 * mümkün değil. Client, mağazadan hiç ürün gelmediğini tespit ettiğinde
 * (`SubscriptionPurchaseService.lastFetchWasMock`) satın alma yerine bunu
 * çağırır — gerçek bir doğrulama yapmadan salonu `trial` durumuna geçirir.
 *
 * Store kurulumu tamamlanınca (bkz. docs/Abonelik_Store_Kurulumu.md) BU
 * FONKSİYONU AYRICA KAPATMANA GEREK YOK: mağaza gerçek ürünleri döndürmeye
 * başlar başlamaz `lastFetchWasMock` otomatik olarak `false` olur ve client
 * kendiliğinden gerçek `verifySubscriptionPurchase` akışına geçer. Bu
 * fonksiyon sadece ekstra bir güvenlik kapağı olarak `cfg_subscription_mock_start_enabled`
 * (varsayılan true) ile Console'dan da kapatılabilir.
 */
export const startMockSubscription = onCall(async (request) => {
  const uid = request.auth?.uid;
  const role = request.auth?.token?.role as string | undefined;
  const tokenGymId = request.auth?.token?.gymId as string | undefined;
  if (!uid || role !== "admin") {
    throw new HttpsError("permission-denied", "Bu işlem için salon admin'i olarak oturum açmış olman gerekiyor.");
  }

  const gymId = typeof request.data?.gymId === "string" ? request.data.gymId : "";
  const productId = typeof request.data?.productId === "string" ? request.data.productId : "";
  if (!gymId || gymId !== tokenGymId) {
    throw new HttpsError("permission-denied", "Sadece kendi salonun için abonelik başlatabilirsin.");
  }
  if (!isKnownSubscriptionProductId(productId)) {
    throw new HttpsError("invalid-argument", `Bilinmeyen ürün: ${productId}`);
  }

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch (error) {
    logger.warn("startMockSubscription: Remote Config cache okunamadı, varsayılan (etkin) kullanılıyor.", error);
    template = { parameters: {} } as RemoteConfigTemplate;
  }
  if (!readBoolParam(template, "cfg_subscription_mock_start_enabled", true)) {
    throw new HttpsError("failed-precondition", "MOCK_SUBSCRIPTION_DISABLED");
  }

  const now = Date.now();
  const db = getFirestore();
  const batch = db.batch();
  batch.set(
    db.doc(gymDoc(gymId)),
    {
      subscriptionStatus: "trial",
      trialStartedAt: FieldValue.serverTimestamp(),
      subscriptionProductId: productId,
    },
    { merge: true },
  );
  batch.set(db.collection(subscriptionHistoryCollection(gymId)).doc(), {
    status: "trial",
    productId,
    platform: "mock",
    isTrialPeriod: true,
    startedAt: Timestamp.fromMillis(now),
    expiresAt: null,
    source: "mock",
    createdAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();

  return { status: "trial" };
});
