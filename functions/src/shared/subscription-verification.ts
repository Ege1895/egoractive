import { GoogleAuth } from "google-auth-library";

import { ANDROID_PACKAGE_NAME } from "./subscription-constants";

export interface VerifiedSubscription {
  expiresAtMs: number;
  isActive: boolean;
}

const APPLE_PRODUCTION_VERIFY_URL = "https://buy.itunes.apple.com/verifyReceipt";
const APPLE_SANDBOX_VERIFY_URL = "https://sandbox.itunes.apple.com/verifyReceipt";
/** Apple'ın sandbox makbuzu prod endpoint'ine gönderildiğinde döndürdüğü kod — bu durumda sandbox'a tekrar denenir. */
const APPLE_STATUS_SANDBOX_RECEIPT = 21007;

/**
 * F6-1d — `verificationData` App Store'dan gelen base64 App Store receipt'i.
 * Apple'ın (hâlâ desteklenen) klasik `verifyReceipt` uç noktasına, App
 * Store Connect'teki "App-Specific Shared Secret" ile gönderilir.
 */
export async function verifyAppleReceipt(params: {
  receiptData: string;
  productId: string;
  sharedSecret: string;
}): Promise<VerifiedSubscription> {
  const body = JSON.stringify({
    "receipt-data": params.receiptData,
    password: params.sharedSecret,
    "exclude-old-transactions": true,
  });

  let response = await fetchAppleVerify(APPLE_PRODUCTION_VERIFY_URL, body);
  if (response.status === APPLE_STATUS_SANDBOX_RECEIPT) {
    response = await fetchAppleVerify(APPLE_SANDBOX_VERIFY_URL, body);
  }

  if (response.status !== 0) {
    throw new Error(`Apple receipt doğrulaması başarısız (status: ${response.status}).`);
  }

  const latestReceipts = (response.latest_receipt_info ?? []) as Array<{
    product_id: string;
    expires_date_ms: string;
  }>;
  const matching = latestReceipts
    .filter((entry) => entry.product_id === params.productId)
    .sort((a, b) => Number(b.expires_date_ms) - Number(a.expires_date_ms))[0];

  if (!matching) {
    throw new Error(`Makbuzda ${params.productId} ürünü bulunamadı.`);
  }

  const expiresAtMs = Number(matching.expires_date_ms);
  return { expiresAtMs, isActive: expiresAtMs > Date.now() };
}

async function fetchAppleVerify(url: string, body: string): Promise<{ status: number; latest_receipt_info?: unknown }> {
  const res = await fetch(url, { method: "POST", headers: { "Content-Type": "application/json" }, body });
  return (await res.json()) as { status: number; latest_receipt_info?: unknown };
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

  const data = (await res.json()) as { expiryTimeMillis: string };
  const expiresAtMs = Number(data.expiryTimeMillis);
  return { expiresAtMs, isActive: expiresAtMs > Date.now() };
}
