/**
 * Tüm Firestore koleksiyon/döküman yolları burada tanımlanır — fonksiyonlarda
 * hiçbir yerde ham string path yazılmaz (CLAUDE.md §5, F1-9 kabul kriteri).
 *
 * Şema henüz F2'de netleşecek (mock verilerin gerçek Firestore'a bağlanması);
 * burada CLAUDE.md'deki modül listesine ve mevcut client tarafı yorumlarına
 * (ör. `gyms/{gymId}.themeColors`) dayanan başlangıç seti var — yeni bir
 * koleksiyon gerektiğinde buraya eklenir.
 */

export function usersCollection() {
  return "users";
}

export function userDoc(uid: string) {
  return `${usersCollection()}/${uid}`;
}

/**
 * F2-2 perf — üye/antrenör ekleme akışındaki "bu telefon zaten kayıtlı mı"
 * kontrolü eskiden `checkPhoneAvailable` callable'ına gidiyordu; bu callable
 * soğuk başlarsa (Cloud Run scale-to-zero) tek başına 20-30+ saniye
 * ekleyebiliyordu ("Kaydet"e basınca ~1 dakikaya varan donma, kullanıcı
 * raporu). `users/{uid}.phoneNumber` küresel benzersiz olmalı ama client
 * bunu doğrudan sorgulayamaz (rules `gymId` filtresi ister, F1-10 notu) —
 * bunun yerine `on-user-write-sync-phone-index.ts` trigger'ının canlı
 * tuttuğu bu index client'tan DOĞRUDAN, ucuz bir point-read'le okunur
 * (Cloud Function invocation'ı hiç yok, dolayısıyla cold start riski de
 * yok). Doküman id'si telefon numarasının kendisi (E.164 ya da migrasyon
 * öncesi çıplak TR hali — bkz. `phone-lookup.ts`), içeriği sadece sahibinin
 * `uid`'i; client sadece VARLIĞINI okuyabilir, hiçbir zaman yazamaz.
 */
export function phoneIndexCollection() {
  return "phoneIndex";
}

export function phoneIndexDoc(phoneNumber: string) {
  return `${phoneIndexCollection()}/${phoneNumber}`;
}

/** Email OTP sistemi — bkz. `shared/otp.ts`. Doküman id'si `{purpose}_{uid}` şeklinde. */
export function otpRequestsCollection() {
  return "otpRequests";
}

export function otpRequestDoc(id: string) {
  return `${otpRequestsCollection()}/${id}`;
}

export function gymsCollection() {
  return "gyms";
}

export function gymDoc(gymId: string) {
  return `${gymsCollection()}/${gymId}`;
}

export function gymThemesCollection(gymId: string) {
  return `${gymDoc(gymId)}/themes`;
}

export function gymThemeDoc(gymId: string, themeId: string) {
  return `${gymThemesCollection(gymId)}/${themeId}`;
}

export function membersCollection(gymId: string) {
  return `${gymDoc(gymId)}/members`;
}

export function memberDoc(gymId: string, memberId: string) {
  return `${membersCollection(gymId)}/${memberId}`;
}

export function trainersCollection(gymId: string) {
  return `${gymDoc(gymId)}/trainers`;
}

export function trainerDoc(gymId: string, trainerId: string) {
  return `${trainersCollection(gymId)}/${trainerId}`;
}

export function sessionsCollection(gymId: string) {
  return `${gymDoc(gymId)}/sessions`;
}

export function sessionDoc(gymId: string, sessionId: string) {
  return `${sessionsCollection(gymId)}/${sessionId}`;
}

export function groupSessionsCollection(gymId: string) {
  return `${gymDoc(gymId)}/groupSessions`;
}

export function groupSessionDoc(gymId: string, groupSessionId: string) {
  return `${groupSessionsCollection(gymId)}/${groupSessionId}`;
}

export function packagesCollection(gymId: string) {
  return `${gymDoc(gymId)}/packages`;
}

export function packageDoc(gymId: string, packageId: string) {
  return `${packagesCollection(gymId)}/${packageId}`;
}

export function eventsCollection(gymId: string) {
  return `${gymDoc(gymId)}/events`;
}

export function eventDoc(gymId: string, eventId: string) {
  return `${eventsCollection(gymId)}/${eventId}`;
}

export function expensesCollection(gymId: string) {
  return `${gymDoc(gymId)}/expenses`;
}

export function expenseDoc(gymId: string, expenseId: string) {
  return `${expensesCollection(gymId)}/${expenseId}`;
}

export function feedbackCollection(gymId: string) {
  return `${gymDoc(gymId)}/feedback`;
}

export function feedbackDoc(gymId: string, feedbackId: string) {
  return `${feedbackCollection(gymId)}/${feedbackId}`;
}

/** Salon Abonelik ve Erişim Akışı — abonelik geçmişi ledger'ı (Admin SDK-only). */
export function subscriptionHistoryCollection(gymId: string) {
  return `${gymDoc(gymId)}/subscriptionHistory`;
}

export function subscriptionHistoryDoc(gymId: string, entryId: string) {
  return `${subscriptionHistoryCollection(gymId)}/${entryId}`;
}

/**
 * Store transaction/purchase token'ından gymId'ye dönüş için lookup index'i
 * (webhook'lar bildirimde sadece transaction/purchase token'ı alır, gymId'yi
 * değil). Top-level, Admin SDK-only.
 */
export function subscriptionTransactionsCollection() {
  return "subscriptionTransactions";
}

export function subscriptionTransactionDoc(transactionKey: string) {
  return `${subscriptionTransactionsCollection()}/${transactionKey}`;
}

/**
 * F5-1/F7-2 — dashboard'daki antrenör performans dökümü artık antrenör
 * başına 2 `count()` sorgusu (N antrenörde 2N round-trip) yerine, her seans
 * yazımında `on-session-write-update-trainer-stats.ts` trigger'ının canlı
 * tuttuğu TEK bir özet dokümanı okuyor. `{yearMonth}` UTC takvim ayı,
 * "2026-08" formatında — trigger'ın yazdığı anahtarla `dashboard_report_service.dart`'ın
 * okuduğu anahtar BİLEREK aynı (UTC) kuralla üretiliyor, salon saat dilimine
 * göre hesaplamak ikisi arasında gece yarısı civarı uyuşmazlık riski
 * doğururdu. Sadece Admin SDK (trigger) yazar, salon admin'i okur.
 */
export function monthlyTrainerStatsCollection(gymId: string) {
  return `${gymDoc(gymId)}/monthlyTrainerStats`;
}

export function monthlyTrainerStatsDoc(gymId: string, yearMonth: string) {
  return `${monthlyTrainerStatsCollection(gymId)}/${yearMonth}`;
}
