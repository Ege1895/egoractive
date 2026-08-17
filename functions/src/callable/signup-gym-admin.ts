import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { gymsCollection, usersCollection } from "../shared/firestore-paths";

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
 */
export const signupGymAdmin = onCall(async (request) => {
  const data = request.data ?? {};
  const name = requireNonEmptyString(data.name, "Salon adı");
  const city = requireNonEmptyString(data.city, "Şehir");
  const phoneNumber = requireNonEmptyString(data.phoneNumber, "Telefon numarası");
  const address = requireNonEmptyString(data.address, "Adres");
  const themeColorHex = requireNonEmptyString(data.themeColorHex, "Tema rengi");
  const logoBase64 = optionalNonEmptyString(data.logoBase64);

  let logoBuffer: Buffer | undefined;
  if (logoBase64 !== undefined) {
    logoBuffer = Buffer.from(logoBase64, "base64");
    if (logoBuffer.length === 0 || logoBuffer.length > MAX_LOGO_BYTES) {
      throw new HttpsError("invalid-argument", "Logo dosyası geçersiz veya çok büyük.");
    }
  }

  const firestore = getFirestore();
  const existing = await firestore
    .collection(usersCollection())
    .where("phoneNumber", "==", phoneNumber)
    .limit(1)
    .get();
  if (!existing.empty) {
    throw new HttpsError("already-exists", "Bu telefon numarasıyla kayıtlı bir kullanıcı zaten var.");
  }

  const gymRef = firestore.collection(gymsCollection()).doc();

  let logoUrl: string | undefined;
  if (logoBuffer !== undefined) {
    const logoPath = `gym_logos/${gymRef.id}.png`;
    const file = getStorage().bucket().file(logoPath);
    await file.save(logoBuffer, { contentType: "image/png" });
    await file.makePublic();
    logoUrl = `https://storage.googleapis.com/${file.bucket.name}/${logoPath}`;
  }

  await gymRef.set({
    name,
    city,
    phone: phoneNumber,
    address,
    ...(logoUrl !== undefined ? { logoUrl } : {}),
    themeColors: { primary: themeColorHex },
    subscriptionStatus: "trial",
    trialStartedAt: FieldValue.serverTimestamp(),
  });

  const userRef = firestore.collection(usersCollection()).doc();
  await userRef.set({
    role: "admin",
    gymId: gymRef.id,
    phoneNumber,
  });

  return { gymId: gymRef.id };
});
