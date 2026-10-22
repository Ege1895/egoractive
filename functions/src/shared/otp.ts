import { randomBytes, randomInt, createHash } from "node:crypto";

import { getFirestore, Timestamp } from "firebase-admin/firestore";

import { otpRequestDoc } from "./firestore-paths";
import { resolveUserLocale } from "./notification-locale";
import { otpEmailHtml, otpEmailSubject } from "./otp-email-template";
import { queueEmail } from "./mail";

export type OtpPurpose = "login" | "activation" | "emailChange";

const OTP_TTL_MS = 5 * 60_000;
const MAX_ATTEMPTS = 5;
const RESEND_COOLDOWN_MS = 60_000;

/** `otpRequests/{docId}` — purpose+uid zaten deterministik/tekil, email doc id olarak kullanılmaz. */
export function otpDocId(purpose: OtpPurpose, uid: string): string {
  return `${purpose}_${uid}`;
}

export function hashOtp(code: string, salt: string): string {
  return createHash("sha256").update(`${salt}:${code}`).digest("hex");
}

export type SendOtpResult = { ok: true } | { ok: false; reason: "cooldown" };

/**
 * Yeni bir 6 haneli kod üretip mevcut kaydın (varsa) üzerine yazar — önceki
 * kod otomatik geçersiz kalır (aynı dokümanı okuyan `verifyOtp` artık yeni
 * hash'i görür). Plaintext kod hiçbir yerde saklanmaz, sadece tuzlanmış
 * SHA-256 hash'i.
 */
export async function sendOtpToEmail(params: {
  purpose: OtpPurpose;
  uid: string;
  email: string;
}): Promise<SendOtpResult> {
  const firestore = getFirestore();
  const ref = firestore.doc(otpRequestDoc(otpDocId(params.purpose, params.uid)));
  const existing = await ref.get();
  const lastSentAt = existing.data()?.lastSentAt as Timestamp | undefined;
  if (lastSentAt && Date.now() - lastSentAt.toMillis() < RESEND_COOLDOWN_MS) {
    return { ok: false, reason: "cooldown" };
  }

  const code = randomInt(0, 1_000_000).toString().padStart(6, "0");
  const salt = randomBytes(16).toString("hex");

  await ref.set({
    purpose: params.purpose,
    uid: params.uid,
    email: params.email,
    codeHash: hashOtp(code, salt),
    salt,
    attempts: 0,
    maxAttempts: MAX_ATTEMPTS,
    consumed: false,
    expiresAt: Timestamp.fromMillis(Date.now() + OTP_TTL_MS),
    lastSentAt: Timestamp.now(),
  });

  const locale = await resolveUserLocale(params.uid);
  await queueEmail({
    to: params.email,
    subject: otpEmailSubject(params.purpose, code, locale),
    html: otpEmailHtml(params.purpose, code, OTP_TTL_MS / 60_000, locale),
  });

  return { ok: true };
}

/**
 * Google Play kapalı testi için ayrılmış demo hesaplarının sabit kodu.
 * GİZLİ DEĞİLDİR — Play Console'daki "Test credentials" alanında testerlara
 * açıkça veriliyor, gizli tutmanın bir anlamı yok.
 */
export const testAccountOtpCode = "000000";

/** Sabit kodun geçerlilik süresi: tester akışın ortasında takılmasın diye uzun. */
const TEST_ACCOUNT_OTP_TTL_MS = 30 * 24 * 60 * 60_000;

/**
 * OTP dokümanını SABİT bir kodla yazar ve e-posta GÖNDERMEZ — yalnızca
 * `users/{uid}.otpBypassEnabled === true` olan demo hesapları için.
 *
 * Neden e-posta atlanıp kod tamamen kaldırılmıyor: `verifyLoginOtp` ve
 * client'ın kod ekranı olduğu gibi çalışmaya devam etsin diye. Kodu tümden
 * atlamak client'ta da değişiklik (ve yeni bir store build'i) gerektirirdi;
 * bu yol, halihazırda yayında olan build ile çalışıyor.
 *
 * Gerçek kullanıcı akışından farkları bilinçli: 60 saniyelik yeniden gönderim
 * bekleme süresi uygulanmaz (tester arka arkaya deneyebilsin) ve kod uzun
 * süre geçerlidir.
 *
 * ⚠️ Bu bayrak açık olan bir hesaba, telefon numarasını/e-postasını bilen
 * HERKES girebilir. Sadece kapalı testteki demo hesaplarında açık kalmalı;
 * test bitince `otpBypassEnabled` alanı Console'dan kaldırılmalı.
 */
export async function storeTestAccountOtp(params: {
  purpose: OtpPurpose;
  uid: string;
  email: string;
}): Promise<void> {
  const firestore = getFirestore();
  const ref = firestore.doc(otpRequestDoc(otpDocId(params.purpose, params.uid)));
  const salt = randomBytes(16).toString("hex");
  await ref.set({
    purpose: params.purpose,
    uid: params.uid,
    email: params.email,
    codeHash: hashOtp(testAccountOtpCode, salt),
    salt,
    attempts: 0,
    maxAttempts: MAX_ATTEMPTS,
    consumed: false,
    testAccount: true,
    expiresAt: Timestamp.fromMillis(Date.now() + TEST_ACCOUNT_OTP_TTL_MS),
    lastSentAt: Timestamp.now(),
  });
}

export type VerifyOtpResult =
  | { ok: true; email: string }
  | { ok: false; reason: "expired" | "locked" | "invalid" };

export async function verifyOtp(params: {
  purpose: OtpPurpose;
  uid: string;
  code: string;
}): Promise<VerifyOtpResult> {
  const firestore = getFirestore();
  const ref = firestore.doc(otpRequestDoc(otpDocId(params.purpose, params.uid)));
  const snapshot = await ref.get();
  const data = snapshot.data();

  if (!data || data.consumed === true) {
    return { ok: false, reason: "expired" };
  }
  const expiresAt = data.expiresAt as Timestamp;
  if (Date.now() > expiresAt.toMillis()) {
    return { ok: false, reason: "expired" };
  }
  const attempts = (data.attempts as number) ?? 0;
  const maxAttempts = (data.maxAttempts as number) ?? MAX_ATTEMPTS;
  if (attempts >= maxAttempts) {
    return { ok: false, reason: "locked" };
  }

  const candidateHash = hashOtp(params.code, data.salt as string);
  if (candidateHash !== data.codeHash) {
    await ref.update({ attempts: attempts + 1 });
    return { ok: false, reason: "invalid" };
  }

  await ref.update({ consumed: true });
  return { ok: true, email: data.email as string };
}
