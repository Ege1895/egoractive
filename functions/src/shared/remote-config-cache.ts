import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import * as logger from "firebase-functions/logger";

const CACHE_DOC_PATH = "internal/remoteConfigCache";

/**
 * Remote Config'in kendisi ücretsiz değil — belli bir fetch hacminin
 * üzerinde ücretlendirmeye başlıyor. Önceden HER görev/fonksiyon çalışması
 * kendi `getRemoteConfig().getTemplate()` çağrısını yapıyordu (ör. aynı
 * dakikada tetiklenen yüzlerce seans hatırlatma görevi, her biri TÜM
 * şablonu ayrı ayrı çekiyordu) — bu hem gereksiz gecikme hem gereksiz
 * fetch hacmi demekti.
 *
 * Bunun yerine [refreshRemoteConfigCache] 2 saatte bir TEK bir fetch yapıp
 * sonucu `internal/remoteConfigCache` Firestore dokümanına yazıyor; tüm
 * diğer fonksiyonlar [getCachedRemoteConfigTemplate] ile bu dokümanı okuyor
 * (ucuz bir Firestore point-read). Bir görev YARIN çalışacak şekilde
 * kurulmuş olsa bile, çalıştığı ANDA bu dokümanı taze taze okuyor —
 * bugün Console'da yapılan bir değişiklik, bir sonraki 2 saatlik fetch
 * döngüsünden itibaren (en kötü ihtimalle ~2 saat içinde) tüm kurulu
 * görevlere yansır, hiçbir görev "eski değerde donmuş" kalmaz.
 */
export async function refreshRemoteConfigCache(): Promise<void> {
  const template = await getRemoteConfig().getTemplate();
  const params: Record<string, string> = {};
  for (const [key, param] of Object.entries(template.parameters)) {
    const value = param.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
    if (value !== undefined) params[key] = value;
  }
  await getFirestore().doc(CACHE_DOC_PATH).set({ params, fetchedAt: Timestamp.now() });
}

/**
 * Var olan tüm `readParam`/`readIntParam`/`readBadgeCriteria` vb. yardımcı
 * fonksiyonlar `RemoteConfigTemplate.parameters[key].defaultValue.value`
 * şeklinde okuma yapıyor — cache'ten dönen düz `{key: value}` map'i aynı
 * şekle sarmalayıp döndürüyoruz ki çağıran taraflarda hiçbir değişiklik
 * gerekmesin.
 *
 * Cache dokümanı henüz hiç yazılmamışsa (ör. `refreshRemoteConfigCache`
 * daha ilk kez çalışmadan önceki dar pencere) doğrudan RC'den bir kerelik
 * fallback fetch yapılır — bu durum kalıcı değildir, bir sonraki
 * zamanlanmış yenilemeden itibaren cache normal şekilde kullanılır.
 */
export async function getCachedRemoteConfigTemplate(): Promise<RemoteConfigTemplate> {
  const snapshot = await getFirestore().doc(CACHE_DOC_PATH).get();
  const cachedParams = snapshot.data()?.params as Record<string, string> | undefined;

  if (!cachedParams) {
    logger.warn("Remote Config cache'i henüz hiç dolmamış, bir kerelik doğrudan fetch yapılıyor.");
    return getRemoteConfig().getTemplate();
  }

  const parameters: RemoteConfigTemplate["parameters"] = {};
  for (const [key, value] of Object.entries(cachedParams)) {
    parameters[key] = { defaultValue: { value } };
  }
  return { parameters } as RemoteConfigTemplate;
}
