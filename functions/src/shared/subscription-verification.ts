import { Environment, OfferType, SignedDataVerifier, VerificationException, VerificationStatus } from "@apple/app-store-server-library";
import { GoogleAuth } from "google-auth-library";

import { ANDROID_PACKAGE_NAME, APPLE_APP_ID, IOS_BUNDLE_ID } from "./subscription-constants";

export interface VerifiedSubscription {
  expiresAtMs: number;
  isActive: boolean;
  /** Aboneliğin mağazadaki orijinal başlangıç tarihi — yenilemelerde değişmez. */
  startAtMs: number;
  /**
   * Salon Abonelik ve Erişim Akışı — bu işlem mağazanın "Free Trial"
   * introductory offer'ı kapsamında mı gerçekleşti (Apple `is_trial_period`,
   * Google `paymentState === 2`). `gyms/{gymId}.trialUsed` bunu true'ya
   * çevirmek için okunur.
   */
  isTrialPeriod: boolean;
  /**
   * Store'un abonelik/işlem için verdiği KALICI kimlik (Apple
   * `original_transaction_id`, Google'da doğrulamada kullanılan purchase
   * token'ın kendisi) — `subscriptionTransactions/{transactionKey}` lookup
   * index'inde webhook'ların gymId'yi bulabilmesi için saklanır.
   */
  transactionKey: string;
}

/**
 * F6-1d (2026-08-28 revizyonu) — `verificationData` artık StoreKit2'nin
 * verdiği JWS imzalı transaction verisi (`Transaction.jsonRepresentation`'ın
 * DEĞİL, `signedTransactionInfo`/`serverVerificationData`'sı) — Apple'ın
 * klasik `verifyReceipt` REST uç noktası (eski `verifyAppleReceipt`) bu
 * formatı anlamıyordu, "receipt-data malformed" (status 21002) hatası
 * veriyordu. `in_app_purchase_storekit` paketi varsayılan olarak StoreKit2
 * kullandığından (bkz. `SubscriptionPurchaseService`) client hep bu formatı
 * gönderiyor — App-Specific Shared Secret artık iOS doğrulaması için
 * kullanılmıyor (sadece Apple Root CA sertifikaları gerekiyor, aynı
 * `appleServerNotifications` webhook'unun kullandığı `SignedDataVerifier`).
 *
 * Bir işlem hangi ortamdan (Production/Sandbox) geldiğini önceden
 * bilemediğimiz için önce Production, `INVALID_ENVIRONMENT` hatası alırsak
 * Sandbox ile tekrar deneriz (klasik `verifyReceipt`'teki 21007 sandbox
 * retry mantığının JWS karşılığı).
 */
export async function verifyAppleTransaction(params: {
  signedTransactionInfo: string;
  productId: string;
  rootCertificatesBase64: string;
}): Promise<VerifiedSubscription> {
  const rootCertificates = params.rootCertificatesBase64.split(",").map((b64) => Buffer.from(b64.trim(), "base64"));

  let transaction;
  try {
    const productionVerifier = new SignedDataVerifier(rootCertificates, true, Environment.PRODUCTION, IOS_BUNDLE_ID, APPLE_APP_ID);
    transaction = await productionVerifier.verifyAndDecodeTransaction(params.signedTransactionInfo);
  } catch (error) {
    if (!(error instanceof VerificationException) || error.status !== VerificationStatus.INVALID_ENVIRONMENT) {
      throw error;
    }
    const sandboxVerifier = new SignedDataVerifier(rootCertificates, true, Environment.SANDBOX, IOS_BUNDLE_ID);
    transaction = await sandboxVerifier.verifyAndDecodeTransaction(params.signedTransactionInfo);
  }

  if (transaction.productId !== params.productId) {
    throw new Error(`Transaction'da ${params.productId} yerine ${transaction.productId} bulundu.`);
  }
  if (transaction.expiresDate === undefined || transaction.originalPurchaseDate === undefined || !transaction.originalTransactionId) {
    throw new Error("Transaction eksik alanlar içeriyor (expiresDate/originalPurchaseDate/originalTransactionId).");
  }

  return {
    expiresAtMs: transaction.expiresDate,
    isActive: transaction.expiresDate > Date.now(),
    startAtMs: transaction.originalPurchaseDate,
    isTrialPeriod: transaction.offerType === OfferType.INTRODUCTORY_OFFER,
    transactionKey: transaction.originalTransactionId,
  };
}

/**
 * F6-1d — `verificationData` Google Play'in verdiği satın alma token'ı.
 * Play Developer API'ye (`purchases.subscriptions.get`) bir servis hesabı
 * ile OAuth2 erişim token'ı alınarak sorgulanır.
 */
export async function verifyGooglePurchase(params: {
  purchaseToken: string;
  productId: string;
  serviceAccountJson: string;
}): Promise<VerifiedSubscription> {
  const credentials = JSON.parse(params.serviceAccountJson);
  const auth = new GoogleAuth({ credentials, scopes: ["https://www.googleapis.com/auth/androidpublisher"] });
  const client = await auth.getClient();
  const accessToken = (await client.getAccessToken()).token;
  if (!accessToken) {
    throw new Error("Google Play servis hesabından erişim token'ı alınamadı.");
  }

  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${ANDROID_PACKAGE_NAME}` +
    `/purchases/subscriptions/${params.productId}/tokens/${params.purchaseToken}`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${accessToken}` } });
  if (!res.ok) {
    throw new Error(`Google Play doğrulaması başarısız (HTTP ${res.status}).`);
  }

  const data = (await res.json()) as {
    expiryTimeMillis: string;
    startTimeMillis: string;
    paymentState?: number;
  };
  const expiresAtMs = Number(data.expiryTimeMillis);
  const startAtMs = Number(data.startTimeMillis);
  return {
    expiresAtMs,
    isActive: expiresAtMs > Date.now(),
    startAtMs,
    // paymentState: 2 = free trial (Play Developer API SubscriptionPurchase).
    isTrialPeriod: data.paymentState === 2,
    transactionKey: params.purchaseToken,
  };
}
