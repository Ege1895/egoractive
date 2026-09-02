/**
 * Bir hesabın admin tarafından pasife alınıp alınmadığı.
 *
 * Antrenör "silme" akışı BİLEREK soft-delete: `users/{uid}` dokümanı ve
 * geçmiş verinin tamamı (seanslar, grup dersleri, üye atamaları, aylık
 * antrenör istatistikleri) olduğu gibi durur — raporlar ve geçmiş
 * görünümler bozulmasın diye. Değişen tek şey, hesabın artık giriş
 * yapamaması ve antrenör listelerinde görünmemesi.
 *
 * Alan YOKSA hesap aktif sayılır — bu sayede mevcut tüm kullanıcı
 * dokümanları için geriye dönük bir migration gerekmiyor.
 */
export function isDeactivated(userData: Record<string, unknown> | undefined): boolean {
  return userData?.isActive === false;
}
