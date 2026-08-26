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
