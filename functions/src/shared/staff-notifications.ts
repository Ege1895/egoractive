import { Firestore, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

/** Firebase Cloud Messaging'in `sendEachForMulticast` başına izin verdiği azami token sayısı. */
const FCM_MULTICAST_CHUNK_SIZE = 500;

/**
 * Salon personeline (antrenör/admin) giden bildirimlerin ortak yardımcıları.
 * Üyelere giden bildirimler `community-broadcast.ts` üzerinden gidiyor; bu
 * dosya onun personel karşılığı — aradaki fark, personel sorgusunun
 * `isActive` alanına da bakması (pasife alınmış antrenör, bkz.
 * `callable/deactivate-trainer.ts`, artık bildirim almamalı).
 */

/**
 * "Ayşe Yılmaz" -> "Ayşe". Bildirimlerde soyisim gösterilmiyor: antrenör
 * zaten kiminle ders yaptığını bilir, ilk isim tanımak için yeterli ve
 * bildirim başlığı kısa kalır.
 */
export function firstName(fullName: string | undefined): string {
  return (fullName ?? "").trim().split(/\s+/)[0] ?? "";
}

/**
 * Düet ders 2 kişiyle sınırlı değil (bkz. `sessions_write_service.dart` —
 * en az 2, üst sınır yok), o yüzden isim sayısı serbest. Ayraç her yerde
 * virgül: "Ayşe, Mehmet, Can". Son ayraç için "ve"/"and" kullanılmıyor —
 * dile bağlı bir kural olmaması bildirimi kısaltıyor ve çeviri hatası
 * riskini kaldırıyor.
 */
export function formatNameList(names: readonly string[]): string {
  return names
    .map((name) => name.trim())
    .filter((name) => name.length > 0)
    .join(", ");
}

/** Verilen kullanıcıların TÜM cihaz token'ları (bir kullanıcının birden çok cihazı olabilir). */
export async function fetchTokensForUids(uids: readonly string[], db: Firestore = getFirestore()): Promise<string[]> {
  const unique = [...new Set(uids.filter((uid) => uid.trim().length > 0))];
  if (unique.length === 0) return [];
  const docs = await Promise.all(unique.map((uid) => db.collection("users").doc(uid).get()));
  return docs.flatMap((doc) => (doc.data()?.fcmTokens as string[] | undefined) ?? []);
}

/**
 * Salonun belirtilen roldeki AKTİF kullanıcılarının token'ları. `isActive`
 * alanı hiç yazılmamış eski kayıtlar aktif sayılır — sadece açıkça `false`
 * olanlar (pasife alınmış antrenörler) dışarıda bırakılır.
 */
export async function fetchGymStaffTokens(
  gymId: string | undefined,
  role: "trainer" | "admin",
  db: Firestore = getFirestore(),
): Promise<string[]> {
  if (!gymId) return [];
  const snapshot = await db.collection("users").where("gymId", "==", gymId).where("role", "==", role).get();
  return snapshot.docs
    .filter((doc) => doc.data().isActive !== false)
    .flatMap((doc) => (doc.data().fcmTokens as string[] | undefined) ?? []);
}

/**
 * `keep` listesinden, `exclude` içinde de bulunan token'ları çıkarır.
 *
 * Aynı bildirim olayında birden fazla `sendPushToTokens` çağrısı yapılan
 * yerlerde gerekli: `sendPushToTokens` kendi içinde tekilleştirme yapıyor
 * ama bu SADECE tek bir çağrının içindeki tekrarları eler, iki ayrı çağrı
 * birbirinden habersizdir. Bir cihaz her iki listede de bulunuyorsa
 * (ör. hem dersin antrenörü hem salonun admini olan bir kullanıcı, ya da
 * aynı cihazdan iki hesaba girilmiş olması) aynı ders için arka arkaya iki
 * bildirim alırdı.
 *
 * Etkinlik hatırlatmasında (`send-event-reminder-task.ts`) bu sorun yok,
 * çünkü orada iki grup TEK listede birleştirilip tek çağrıyla gönderiliyor
 * — metinleri aynı olduğu için bu mümkün. Metinler farklı olduğunda
 * birleştirme yapılamaz, o zaman bu eleme gerekir.
 */
export function excludeTokens(keep: readonly string[], exclude: readonly string[]): string[] {
  if (exclude.length === 0) return [...keep];
  const excluded = new Set(exclude);
  return keep.filter((token) => !excluded.has(token));
}

/** Token listesini 500'lük parçalara bölerek gönderir; boş listede hiç çağrı yapmaz. */
export async function sendPushToTokens(
  tokens: readonly string[],
  notification: { title: string; body: string },
  data: Record<string, string>,
): Promise<void> {
  const unique = [...new Set(tokens)];
  for (let i = 0; i < unique.length; i += FCM_MULTICAST_CHUNK_SIZE) {
    await getMessaging().sendEachForMulticast({
      tokens: unique.slice(i, i + FCM_MULTICAST_CHUNK_SIZE),
      notification,
      data,
    });
  }
}
