import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { gymsCollection, usersCollection } from "../shared/firestore-paths";
import { findUserByPhone } from "../shared/phone-lookup";

const MAX_LOGO_BYTES = 300 * 1024;

function requireNonEmptyString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${field} gerekli.`);
  }
  return value.trim();
}

/** Logo opsiyonel — boş/eksikse `undefined` döner, girildiyse trim'lenir. */
function optionalNonEmptyString(value: unknown): string | undefined {
  if (typeof value !== "string" || value.trim().length === 0) return undefined;
  return value.trim();
}

const DEFAULT_TIME_ZONE = "Europe/Istanbul";

const DEFAULT_CURRENCY_CODE = "TRY";

/**
 * F9-2 — para birimi sadece kuruluşta seçilir, sonradan değiştirilemez
 * (client'ta da düzenleme UI'ı yok). Tam ISO 4217 kod listesini burada
 * ikinci kez tutmak yerine (client'taki `currency_constants.dart` tek
 * kaynak), sadece kabaca "3 büyük harf" formatı doğrulanır — geçersiz/eksik
 * gelirse varsayılana düşülür.
 */
function resolveCurrency(value: unknown): string {
  if (typeof value !== "string") return DEFAULT_CURRENCY_CODE;
  const trimmed = value.trim().toUpperCase();
  return /^[A-Z]{3}$/.test(trimmed) ? trimmed : DEFAULT_CURRENCY_CODE;
}

/**
 * Push bildirimlerinde (ör. seans hatırlatması) saatin salonun bulunduğu
 * yerin saatine göre gösterilebilmesi için — uygulama artık tek ülkeye
 * (Türkiye) özel değil, salon dünyanın herhangi bir yerinde olabilir.
 * Client, cihazın IANA saat dilimini (`flutter_timezone`) gönderir;
 * geçersiz/eksikse ya da tanınmayan bir IANA adıysa `DEFAULT_TIME_ZONE`'a
 * düşülür (`Intl.DateTimeFormat` geçersiz `timeZone` ile fırlatır, bu da
 * geçerliliği ucuza doğrulamanın bir yolu).
 */
function resolveTimeZone(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) return DEFAULT_TIME_ZONE;
  try {
    Intl.DateTimeFormat(undefined, { timeZone: value });
    return value;
  } catch {
    return DEFAULT_TIME_ZONE;
  }
}

/**
 * F2-9 — yeni bir antrenör, henüz hiçbir Firebase Auth oturumu olmadan
 * "kendi salonumu oluşturuyorum" akışında bu fonksiyonu çağırır (client
 * `requestCustomToken` ile aynı şekilde unauthenticated). Admin SDK
 * kurallara tabi olmadığı için `gyms`/`users` dokümanlarını ve logo
 * dosyasını burada doğrudan yazabiliyoruz.
 *
 * `users/{uid}` dokümanının id'si burada da (F1-10/F2-2'deki gibi) auto-id
 * olarak üretilir — gerçek Firebase Auth hesabı, kullanıcı bu telefon
 * numarasıyla `requestCustomToken` üzerinden ilk girişini yaptığında lazy
 * olarak oluşur.
 *
 * Email BİLEREK burada istenmiyor (UX kararı — telefon zaten hesabın kalıcı
 * giriş kimliği; salon oluşturma anında email de zorunlu tutup ayrıca
 * doğrulatmak, telefon OTP'sinden ÖNCE ikinci bir doğrulama adımı ekleyip
 * kurulumu yavaşlatıyordu, üstelik yanlış girilirse salonu hiç
 * oluşturamama riski taşıyordu). Kullanıcı normal telefon girişini
 * (`requestCustomToken`) yapınca `email` alanı boş kaldığından
 * `emailSetupRequired` kapısı devreye girer, `sendEmailSetupOtp`/
 * `verifyEmailSetupOtp` üzerinden email ilk oturumdan hemen sonra
 * tamamlanır — `reportEmails.gym` da o an otomatik yazılır (bkz.
 * `verify-email-setup-otp.ts`).
 */
export const signupGymAdmin = onCall(async (request) => {
  const data = request.data ?? {};
  const name = requireNonEmptyString(data.name, "Salon adı");
  const city = requireNonEmptyString(data.city, "Şehir");
  const phoneNumber = requireNonEmptyString(data.phoneNumber, "Telefon numarası");
  const address = requireNonEmptyString(data.address, "Adres");
  const themeColorHex = requireNonEmptyString(data.themeColorHex, "Tema rengi");
  const logoBase64 = optionalNonEmptyString(data.logoBase64);
  const timeZone = resolveTimeZone(data.timeZone);
  const currency = resolveCurrency(data.currency);

  let logoBuffer: Buffer | undefined;
  if (logoBase64 !== undefined) {
    logoBuffer = Buffer.from(logoBase64, "base64");
    if (logoBuffer.length === 0 || logoBuffer.length > MAX_LOGO_BYTES) {
      throw new HttpsError("invalid-argument", "Logo dosyası geçersiz veya çok büyük.");
    }
  }

  const firestore = getFirestore();
  // F8-3 — geçiş penceresi: migrate edilmemiş eski çıplak TR kayıtlarıyla da
  // çakışma kontrolü yapar, bkz. `shared/phone-lookup.ts`.
  const existingPhoneDoc = await findUserByPhone(firestore, phoneNumber);
  if (existingPhoneDoc !== null) {
    throw new HttpsError("already-exists", "Bu telefon numarasıyla kayıtlı bir kullanıcı zaten var.");
  }

  const gymRef = firestore.collection(gymsCollection()).doc();

  let logoUrl: string | undefined;
  if (logoBuffer !== undefined) {
    const logoPath = `gym_logos/${gymRef.id}.png`;
    const file = getStorage().bucket().file(logoPath);
    await file.save(logoBuffer, {
      contentType: "image/png",
      // Logo değişince `gyms/{gymId}.logoUrl` de (yeni bir download token'ıyla)
      // değişiyor (bkz. gym_logo_service.dart) — bu yüzden aynı path'e uzun
      // süreli cache-control yazmak eski görseli "yapışık" bırakmıyor,
      // client zaten güncel URL'i okuyor.
      metadata: { cacheControl: "public, max-age=31536000, immutable" },
    });
    await file.makePublic();
    logoUrl = `https://storage.googleapis.com/${file.bucket.name}/${logoPath}`;
  }

  await gymRef.set({
    name,
    city,
    phone: phoneNumber,
    address,
    timeZone,
    currency,
    ...(logoUrl !== undefined ? { logoUrl } : {}),
    themeColors: { primary: themeColorHex },
    // subscriptionStatus artık burada otomatik "trial" yazılmıyor — admin,
    // girişten hemen sonra zorunlu SubscriptionOnboardingPanel'de gerçek bir
    // mağaza aboneliği (store'un kendi "free trial" introductory offer'ıyla)
    // başlatana kadar `subscriptionStatus` alanı yok = SubscriptionStatus.none
    // (bkz. subscription_status_service.dart). O ekranda seçtiği pakete
    // `verifySubscriptionPurchase` (F6-1d) ile abone olunca "active" yazılır.
    // `subscriptionExempt` bilerek false yazılıyor (varsayılan davranışla
    // aynı sonuç, ama Console'da alanı görünür/tutarlı kılmak için) — bunu
    // sonradan sadece Console/Admin SDK'dan true'ya çevirebilirsin.
    subscriptionExempt: false,
  });

  const userRef = firestore.collection(usersCollection()).doc();
  await userRef.set({
    role: "admin",
    gymId: gymRef.id,
    phoneNumber,
  });

  return { gymId: gymRef.id };
});
