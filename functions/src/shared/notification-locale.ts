import { getFirestore } from "firebase-admin/firestore";

export const DEFAULT_TIME_ZONE = "Europe/Istanbul";

/**
 * `gyms/{gymId}.timeZone` — salon oluşturulurken cihazın IANA saat dilimi
 * kaydedilir (bkz. `signup-gym-admin.ts`). Bu alan hiç yoksa (bu
 * özellikten önce oluşturulmuş eski bir salon) ya da geçersizse
 * `DEFAULT_TIME_ZONE`'a düşülür.
 */
/** Geçersiz/eksik bir IANA tanımlayıcısını `DEFAULT_TIME_ZONE`'a düşürür —
 * salon dokümanı zaten elde bulunan çağrı yerlerinde (ör. rapor scheduled
 * fonksiyonları) ekstra bir Firestore okuması gerektirmeden kullanılabilir. */
export function safeTimeZone(raw: string | undefined): string {
  if (!raw) return DEFAULT_TIME_ZONE;
  try {
    Intl.DateTimeFormat(undefined, { timeZone: raw });
    return raw;
  } catch {
    return DEFAULT_TIME_ZONE;
  }
}

export async function resolveGymTimeZone(gymId: string | undefined): Promise<string> {
  if (!gymId) return DEFAULT_TIME_ZONE;
  const gymDoc = await getFirestore().collection("gyms").doc(gymId).get();
  return safeTimeZone(gymDoc.data()?.timeZone as string | undefined);
}

/**
 * Push bildirimlerinin dili artık alıcının CİHAZ diline değil, salonun
 * bulunduğu YERE göre seçiliyor — üye/antrenörün telefonu hangi dilde
 * olursa olsun, salon Türkiye'deyse Türkçe, değilse İngilizce gönderilir.
 * `Europe/Istanbul` Türkiye'nin tek IANA saat dilimi olduğu için bu
 * karşılaştırma, ülkeyi doğrudan yansıtıyor.
 */
export function resolveNotificationLocale(timeZone: string): "tr" | "en" {
  return timeZone === DEFAULT_TIME_ZONE ? "tr" : "en";
}

/**
 * Bir KULLANICIYA gidecek e-posta/bildirim için dil — kullanıcının salonunun
 * bulunduğu yere göre (push bildirimleriyle aynı kural, bkz.
 * [resolveNotificationLocale]). Kullanıcı ya da salon bulunamazsa varsayılan
 * saat diliminin dili kullanılır.
 */
export async function resolveUserLocale(uid: string | undefined): Promise<"tr" | "en"> {
  if (!uid) return resolveNotificationLocale(DEFAULT_TIME_ZONE);
  const userDoc = await getFirestore().collection("users").doc(uid).get();
  const gymId = userDoc.data()?.gymId as string | undefined;
  return resolveNotificationLocale(await resolveGymTimeZone(gymId));
}
