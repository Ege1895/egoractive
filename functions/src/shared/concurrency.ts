/**
 * `items`i sırayla (bir `await` bitmeden diğeri başlamadan) işlemek yerine
 * en fazla `limit` tanesini aynı anda işler — tam paralel (`Promise.all`
 * hepsini bir anda) ile tam sıralı (`for...of` içinde `await`) arasında bir
 * orta yol. Büyük koleksiyonlarda (ör. binlerce üye) sıralı işlemek
 * fonksiyonun zaman aşımına yaklaşmasına yol açabilirken, sınırsız paralel
 * işlemek Firestore/FCM kota patlamasına yol açabilir — sınırlı eşzamanlılık
 * ikisini de önler, sonucun sırası/işlevi sıralı halinden farksız kalır.
 */
export async function mapWithConcurrency<T, R>(
  items: T[],
  limit: number,
  fn: (item: T, index: number) => Promise<R>,
): Promise<R[]> {
  const results = new Array<R>(items.length);
  let nextIndex = 0;

  async function worker(): Promise<void> {
    while (true) {
      const current = nextIndex++;
      if (current >= items.length) return;
      results[current] = await fn(items[current], current);
    }
  }

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
}
