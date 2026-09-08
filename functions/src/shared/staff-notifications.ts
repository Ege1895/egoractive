import { Firestore, getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

import { pruneDeadTokens } from "./dead-token-cleanup";

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

/** Bir `users` dokümanının kendi cihaz token'ları (alan yoksa boş liste). */
export function readTokens(data: Record<string, unknown> | undefined): string[] {
  const tokens = data?.fcmTokens;
  return Array.isArray(tokens) ? tokens.filter((token): token is string => typeof token === "string") : [];
}

export type TokenSource = { kind: "tokens"; tokens: string[] } | { kind: "proxy"; uid: string };

/**
 * F11-2 — bir `users` dokümanının bildirimlerinin HANGİ cihazlara gideceğini
 * çözer.
 *
 * `notificationProxyUid` doluysa doküman kendi token'larını değil, işaret
 * ettiği kullanıcının token'larını kullanır. Bu, admin'in kendisini antrenör
 * olarak eklediği "gölge antrenör" dokümanı içindir (bkz. görev listesi
 * F11-1): o dokümanın hiç `fcmTokens` alanı yoktur ve hiçbir zaman giriş
 * yapmaz, bildirimleri admin'in cihazına düşmelidir.
 *
 * Token'ları KOPYALAMAK yerine işaret etmenin sebebi: kopya çürür. Client
 * `_saveToken` yalnızca giriş yapmış kullanıcının kendi dokümanına yazıyor
 * (`push_notification_service.dart`), yani token yenilendiğinde, cihaz
 * değiştiğinde ya da çıkış yapıldığında kopya sessizce ölü kalırdı.
 */
export function resolveTokenSource(data: Record<string, unknown> | undefined): TokenSource {
  const proxyUid = typeof data?.notificationProxyUid === "string" ? data.notificationProxyUid.trim() : "";
  if (proxyUid.length > 0) return { kind: "proxy", uid: proxyUid };
  return { kind: "tokens", tokens: readTokens(data) };
}

/**
 * Doküman verilerinden token toplar; `notificationProxyUid` taşıyanlar için
 * işaret edilen dokümanı okur.
 *
 * Yönlendirme TEK ADIM: hedefin kendi `notificationProxyUid`'i varsa
 * İZLENMEZ, sadece `fcmTokens`'ı okunur. Böylece iki dokümanın birbirini
 * göstermesi (ya da uzun bir zincir) sonsuz döngüye/okuma patlamasına yol
 * açamaz. Hedef doküman silinmişse o kullanıcı için boş liste döner —
 * fonksiyon hata fırlatmaz, sadece o kişiye bildirim gitmez.
 */
async function collectTokens(
  datas: readonly (Record<string, unknown> | undefined)[],
  db: Firestore,
): Promise<string[]> {
  const direct: string[] = [];
  const proxyUids = new Set<string>();
  for (const data of datas) {
    const source = resolveTokenSource(data);
    if (source.kind === "proxy") {
      proxyUids.add(source.uid);
    } else {
      direct.push(...source.tokens);
    }
  }
  if (proxyUids.size === 0) return direct;

  const proxyDocs = await Promise.all([...proxyUids].map((uid) => db.collection("users").doc(uid).get()));
  return [...direct, ...proxyDocs.flatMap((doc) => readTokens(doc.data()))];
}

/** Verilen kullanıcıların TÜM cihaz token'ları (bir kullanıcının birden çok cihazı olabilir). */
export async function fetchTokensForUids(uids: readonly string[], db: Firestore = getFirestore()): Promise<string[]> {
  const unique = [...new Set(uids.filter((uid) => uid.trim().length > 0))];
  if (unique.length === 0) return [];
  const docs = await Promise.all(unique.map((uid) => db.collection("users").doc(uid).get()));
  return collectTokens(
    docs.map((doc) => doc.data()),
    db,
  );
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
  return collectTokens(
    snapshot.docs.map((doc) => doc.data()).filter((data) => data.isActive !== false),
    db,
  );
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
    const chunk = unique.slice(i, i + FCM_MULTICAST_CHUNK_SIZE);
    const response = await getMessaging().sendEachForMulticast({ tokens: chunk, notification, data });
    await pruneDeadTokens(chunk, response);
  }
}
