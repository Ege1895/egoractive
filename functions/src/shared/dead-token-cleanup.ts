import { FieldValue, Firestore, getFirestore } from "firebase-admin/firestore";
import { BatchResponse } from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

import { usersCollection } from "./firestore-paths";

/**
 * FCM'in "bu token artık geçerli değil" dediği hata kodları — uygulama
 * silinmiş, cihaz sıfırlanmış ya da token iptal edilmiş demektir.
 *
 * `messaging/invalid-argument` BİLEREK bu listede YOK. O kod bozuk bir
 * token için de dönebiliyor ama bozuk bir GÖNDERİ (payload) için de
 * dönüyor — ve payload hatası tüm token'lar için aynı anda geldiğinden,
 * listeye eklenseydi tek bir hatalı bildirim metni salonun BÜTÜN
 * token'larını silerdi. Token'lar zaten SDK tarafından yazıldığı için
 * biçimsel olarak bozuk olma ihtimali düşük; bu takas bilinçli.
 */
const DEAD_TOKEN_ERROR_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

/**
 * Gönderim yanıtındaki ölü token'ları ayıklar. `response.responses`,
 * gönderilen `tokens` dizisiyle AYNI sırada geliyor (FCM sözleşmesi) —
 * eşleme buna dayanıyor.
 */
export function collectDeadTokens(tokens: readonly string[], response: BatchResponse): string[] {
  return response.responses.flatMap((result, index) => {
    const token = tokens[index];
    if (!token || result.success || !result.error) return [];
    return DEAD_TOKEN_ERROR_CODES.has(result.error.code) ? [token] : [];
  });
}

/**
 * Ölü token'ları `users/{uid}.fcmTokens` dizilerinden siler.
 *
 * Neden gerekli: token yalnızca çıkışta ([removeTokenForCurrentUser]) ve
 * yenilenme anında (`_saveToken`) temizleniyor — kullanıcı uygulamayı
 * silerse ikisi de çalışmaz ve token dokümanda sonsuza kadar kalırdı.
 * FCM'in "bu token öldü" yanıtı bu boşluğu kapatan tek sinyal.
 *
 * Token'dan uid'ye eşleme TUTULMUYOR; bunun yerine `array-contains` ile
 * o token'ı taşıyan doküman(lar) aranıyor. Sebebi: aynı token birden fazla
 * dokümanda kalmış olabilir (aynı cihazdan iki hesaba girilmiş, çıkış
 * yapılmamış) ve bu yol hepsini birden temizliyor. Ölü token nadir olduğu
 * için sorgu maliyeti ihmal edilebilir.
 *
 * Hiçbir koşulda fırlatmaz: temizlik başarısız olsa bile bildirim
 * gönderimi tamamlanmış durumda, bir sonraki gönderimde tekrar denenir.
 */
export async function pruneDeadTokens(
  tokens: readonly string[],
  response: BatchResponse,
  db: Firestore = getFirestore(),
): Promise<void> {
  try {
    const dead = collectDeadTokens(tokens, response);
    if (dead.length === 0) return;

    let removed = 0;
    for (const token of dead) {
      const snapshot = await db.collection(usersCollection()).where("fcmTokens", "array-contains", token).get();
      await Promise.all(
        snapshot.docs.map((doc) => doc.ref.update({ fcmTokens: FieldValue.arrayRemove(token) })),
      );
      removed += snapshot.size;
    }
    logger.info(`${dead.length} ölü FCM token'ı ${removed} kullanıcı dokümanından temizlendi.`);
  } catch (error) {
    logger.warn("Ölü FCM token temizliği başarısız oldu, bildirim gönderimi etkilenmedi.", error);
  }
}
