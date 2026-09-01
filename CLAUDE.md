# CLAUDE.md — Egoractive Proje Kuralları

Bu dosya, bu repoda çalışan her Claude Code oturumunun **otomatik olarak okuyup uyması gereken** kurallardır. Aşağıdaki kurallar, görev listesindeki her task'tan önce gelir — bir task'ın açıklaması bu dosyayla çelişiyorsa, bu dosya kazanır.

---

## 1. Proje Özeti

- **Uygulama adı (çalışma adı):** Egoractive
- **Yayıncı:** Egora Games
- **Ne yapıyor:** Spor salonu / PT stüdyo yönetim uygulaması — Admin, Antrenör, Üye olmak üzere 3 farklı rol
- **Platform:** Flutter (tek kod tabanı, iOS + Android)
- **Backend:** Firebase (Firestore, Cloud Functions, FCM, Remote Config, Authentication, Analytics, Crashlytics)
- **Öncelik:** Genişletilebilirlik ve LiveOps — uygulama sürekli yeni özellik alacak şekilde tasarlanmalı, store güncellemesi olmadan davranış değiştirilebilmeli (Remote Config)

---

## 2. Mimari İlkeler

### 2.1 Modüler yapı (feature-first)

Her özellik/domain kendi modülü içinde yaşar. Modüller arası doğrudan bağımlılık yasak — bir modül başka bir modülün internal sınıflarını import edemez, sadece onun `public` arayüzünü (interface/contract) kullanır.

Her modül şu alt katmanlara sahiptir:

```
modules/<module_name>/
  controller/     # Riverpod Notifier/AsyncNotifier — "manager" karşılığı, state ve iş akışı
  service/        # Firestore/Cloud Functions/harici servislerle konuşan katman
  repository/     # Service'i domain modeline çeviren, controller'ın konuştuğu arayüz
  domain/         # Entity, value object, enum tanımları (bu modüle özel)
  ui/
    panels/       # BasePanel'i extend eden ekranlar
    widgets/      # Bu modüle özel, yeniden kullanılabilir widget'lar
```

Bir modülün Controller'ı **asla** başka bir modülün Service/Repository'sine doğrudan erişmez — ihtiyacı varsa o modülün Controller'ı üzerinden, tanımlı bir arayüzle konuşur.

### 2.2 Manager/Controller sorumluluğu

Her modülün Controller'ı (Riverpod `Notifier`/`AsyncNotifier`):
- Modülün state'ini tutar
- UI'dan gelen action'ları karşılar (`onX()` metodları)
- Service katmanını çağırır, sonucu state'e yansıtır
- İş kuralı validasyonlarını burada yapar (UI'da değil)

Controller'lar **UI'dan habersiz** olmalı — hiçbir Controller içinde `BuildContext`, `Navigator`, ya da widget referansı olmaz.

### 2.3 `BasePanel` — Ortak UI Panel Yapısı

Tüm ekranlar bu abstract sınıfı extend eder. Amaç: show/hide yaşam döngüsünü ve geri (back) davranışını merkezi bir yerden yönetmek.

```dart
abstract class BasePanel extends ConsumerStatefulWidget {
  const BasePanel({super.key});
}

abstract class BasePanelState<T extends BasePanel> extends ConsumerState<T> {
  // Panel gösterildiğinde çağrılır (push edildiğinde / stack'in tepesine geldiğinde)
  void onPanelShow() {}

  // Panel gizlendiğinde çağrılır (üstüne başka panel geldiğinde / pop edildiğinde)
  void onPanelHide() {}

  // Sistem geri tuşu / gesture: true dönerse panel kendi işini yaptı demektir,
  // PanelStackController varsayılan pop davranışını uygulamaz.
  bool onBackRequested() => false;

  @override
  Widget build(BuildContext context); // her panel kendi UI'ını burada tanımlar
}
```

Merkezi navigasyonu `PanelStackController` (Riverpod, global) yönetir:
- `push(Panel)` / `pop()` / `popToRoot()`
- Aktif panel değiştiğinde eskisinin `onPanelHide()`'ını, yenisinin `onPanelShow()`'unu tetikler
- Sistem geri tuşunu / `PopScope`'u dinler, önce aktif panelin `onBackRequested()`'ına sorar, `false` dönerse kendi `pop()`'unu çalıştırır

**Kural:** `Navigator.push` / `Navigator.pop` hiçbir yerde doğrudan çağrılmaz — her zaman `PanelStackController` üzerinden gidilir. `go_router`, `PanelStackController`'ın üstünde ince bir routing katmanı olarak kullanılır (deep link ve web URL senkronizasyonu için), iş mantığı router'da yaşamaz.

### 2.4 Dinamik Tema Mimarisi

Renk paleti ve arka plan, `ThemeController` üzerinden salon bazlı çalışır:
- `AppColorScheme` modeli: primary, secondary, background, surface, onSurface vb.
- Aktif salonun `gyms/{gymId}.themeColors` alanından yüklenir, `ThemeController` state'i günceller
- Hiçbir widget'ta `Color(0xFF...)` literal kullanılmaz — her zaman `Theme.of(context).colorScheme.X` ya da proje `AppTheme` extension'ı üzerinden

### 2.5 Hardcode Yasağı — Const / Remote Config Ayrımı

Bir değer koda yazılacaksa şu iki kutudan birine girmeli:

| Değer tipi | Nerede tanımlanır |
|---|---|
| Build-time sabit, iş kuralı değişmeyen (örn. bir enum'un olası değerleri, animasyon eğrisi) | Dart `const` — `lib/core/constants/` altında, anlamlı isimle |
| Runtime'da değişebilecek iş kuralı (eşik değerler, süreler, limitler, metin şablonları, feature flag) | **Firebase Remote Config** — `RemoteConfigService` üzerinden okunur, asla direkt `FirebaseRemoteConfig.instance` çağrılmaz |

Örnekler — Remote Config'e gitmesi gerekenler: ders onay bildiriminin kaç dakika önce gideceği, grup dersi varsayılan kontenjanı, feedback hatırlatma günü, ücretsiz sürümde reklam gösterilip gösterilmeyeceği, hangi feature'ların aktif olduğu.

**Kapsam netliği:** Bu kural iş mantığı değerleri içindir. Paket adı, dosya yolu, Firestore koleksiyon adı gibi teknik altyapı sabitleri normal şekilde `const` olarak tanımlanır — bunları Remote Config'e taşımaya gerek yok.

---

## 3. Kod Okunabilirlik Kuralları

Her Dart sınıfında üye sıralaması **her zaman** şu sırada olacak:

1. Static/const alanlar
2. Instance alanları (final önce, sonra mutable)
3. Constructor(lar)
4. Lifecycle metodları — `initState()` / `build()` (subscription ve listener kurulumları burada, metodun **başında**)
5. Public metodlar (iş mantığı, en sık kullanılandan aza doğru)
6. Private metodlar (`_` ile başlayan yardımcılar)
7. `dispose()` — tüm unsubscribe/cancel işlemleri burada, sınıfın **en altında**

```dart
class SessionListPanelState extends BasePanelState<SessionListPanel> {
  // 1. const/static
  static const _pageSize = 20;

  // 2. instance alanları
  late final StreamSubscription<List<Session>> _sessionsSub;
  final _scrollController = ScrollController();

  // 3. constructor yok (State sınıfı) — initState'e geçilir

  // 4. lifecycle — subscription kurulum en üstte
  @override
  void initState() {
    super.initState();
    _sessionsSub = ref.read(sessionControllerProvider.notifier).sessionsStream.listen(_onSessionsChanged);
  }

  @override
  Widget build(BuildContext context) { ... }

  // 5. public
  void refresh() { ... }

  // 6. private
  void _onSessionsChanged(List<Session> sessions) { ... }

  // 7. dispose — unsubscribe en altta
  @override
  void dispose() {
    _sessionsSub.cancel();
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

## 4. İsimlendirme Kuralları

Dart/Flutter ekosisteminin resmi ve evrensel standardı uygulanır (dünyada en yaygın kullanılan case, C#/Unity'den farklı olduğu için özellikle not edildi):

| Ne | Case | Örnek |
|---|---|---|
| Class, enum, extension, tip adı | PascalCase | `SessionController`, `PanelStackController` |
| Değişken, fonksiyon, metod, named parametre | camelCase | `remainingSessions`, `onPanelShow()` |
| Dosya adı | snake_case | `session_controller.dart` |
| Sabitler (const) | camelCase (Dart efektif stil rehberi — SCREAMING_CASE kullanılmaz) | `const maxGroupSessionCapacity = 12;` |
| Private üye | `_camelCase` | `_sessionsSub` |
| Riverpod provider | camelCase + `Provider` soneki | `sessionControllerProvider` |

---

## 5. Klasör Yapısı (üst seviye)

```
lib/
  core/
    panels/            # BasePanel, PanelStackController
    theme/              # ThemeController, AppColorScheme
    remote_config/      # RemoteConfigService
    constants/           # build-time const'lar
    router/              # go_router tanımı (ince katman)
  modules/
    auth/
    members/
    trainers/
    sessions/
    packages/
    group_sessions/
    events/
    measurements/
    badges/
    feedback/
    notifications/
    reports/
    expenses/
    subscription/
  shared/
    widgets/
    utils/
  main.dart

functions/                # Cloud Functions (TypeScript)
  src/
    triggers/             # Firestore trigger'ları (onDocumentUpdated vb.)
    scheduled/             # Cloud Scheduler tabanlı fonksiyonlar
    callable/               # Client'tan doğrudan çağrılan fonksiyonlar
    shared/                  # Ortak tipler, Firestore path helper'ları
```

---

## 6. Kısaltmalar / Terimler

- **Panel:** Bir ekran (BasePanel'i extend eden widget)
- **Controller:** Modülün state yöneticisi (Riverpod Notifier)
- **Manager:** Controller ile eşanlamlı, bazı task açıklamalarında bu isim geçebilir
- **RC:** Remote Config

## 7. Sürüm ve Build Numaralandırma (Google Play Store + App Store)

**Tek kaynak (source of truth):** `pubspec.yaml`'daki `version:` alanı:

```
version: <versionName>+<buildNumber>
```

- `versionName` (nokta ile ayrılmış, örn. `1.0.0`) — kullanıcıya görünen sürüm, semver mantığıyla ilerler (özellik/düzeltme kapsamına göre sen karar verirsin).
- `buildNumber` (tam sayı, örn. `1`) — hem Play Console hem App Store Connect'e her yeni yükleme öncesi **kesinlikle bir artırılmalı** (aynı buildNumber ile ikinci bir yükleme ikisi tarafından da reddedilir).

Kullanıcı "build number'ı artır" dediğinde (platform belirtmeden) **her iki platform da** etkilenir — sadece `pubspec.yaml`'ı değiştirip durmak YETMEZ, aşağıdaki tüm adımlar tamamlanmalı:

1. `pubspec.yaml`'daki `version:` satırını güncelle — `buildNumber`'ı bir artır, `versionName`'i gerekirse (görev/kapsam gerektiriyorsa) değiştir. Bu kural her zaman geçerli — kullanıcı ayrıca hatırlatmasa bile uygulanır.
2. `flutter pub get` çalıştır.
3. **Android:** `flutter build appbundle --release` ile `.aab` üret.
4. **iOS:** `flutter build ios --no-codesign --debug` (ya da gerçek bir cihaz/App Store build'i) çalıştır — **SADECE `pubspec.yaml`'ı değiştirip `flutter pub get` çalıştırmak Xcode'un gördüğü build numarasını GÜNCELLEMEZ.** `ios/Flutter/Generated.xcconfig` (Xcode projesinin `CFBundleVersion`/`CFBundleShortVersionString` için okuduğu, `$(FLUTTER_BUILD_NUMBER)`/`$(FLUTTER_BUILD_NAME)` değişkenlerini tuttuğu dosya) sadece bir **iOS build/run komutu** çalıştığında `pubspec.yaml`'dan yeniden üretiliyor — `flutter pub get` tek başına bunu tetiklemiyor. Bunu bir kere atlayıp kullanıcıya "Xcode'da hâlâ eski build number görünüyor" hatası yaşattık (2026-09-01) — Android build'i alıp iOS'u atlamıştık. **İki platformdan birini yapıp diğerini atlama, ikisi de her seferinde çalıştırılmalı.**
5. Kullanıcı Xcode'da **yeni bir Archive** almadan eski build numarası görünmeye devam eder (Archives listesi geçmiş archive'ları gösterir, bunlar otomatik güncellenmez) — build number güncellemesi sonrası kullanıcıya "Xcode'da Product → Archive ile yeni bir archive al" hatırlatmasını unutma.

**Android çıktı dosyasının adı da bu formatta olmalı.** `flutter build appbundle --release` her zaman sabit `build/app/outputs/bundle/release/app-release.aab` adını üretir — bu, pubspec'teki `version:` alanına göre otomatik değişmez. Build tamamlandıktan sonra dosyayı **aynı klasörde**, `<buildNumber> (<versionName>).aab` adıyla (örn. `2 (1.0.0).aab`) kopyala:

```
cp build/app/outputs/bundle/release/app-release.aab "build/app/outputs/bundle/release/<buildNumber> (<versionName>).aab"
```

**Kısacası — build number değiştiğinde dokunulması/kontrol edilmesi gereken dosyalar:**
- `pubspec.yaml` (`version:` — asıl kaynak, elle düzenlenir)
- `ios/Flutter/Generated.xcconfig` (`FLUTTER_BUILD_NUMBER`/`FLUTTER_BUILD_NAME` — elle düzenlenmez, `flutter build ios`/`flutter pub get` + bir iOS build adımıyla otomatik yeniden üretilir; sadece `flutter pub get` yeterli DEĞİL, gerçek bir iOS build komutu şart)
- `build/app/outputs/bundle/release/<buildNumber> (<versionName>).aab` (Android çıktısı, elle kopyalanır — yukarıdaki `cp` komutu)

## Abonelik sıfırlama aracı (resetGymSubscription)

Bir salonun (ör. reklam amaçlı ücretsiz erişim verilip sonra geri alınan, ya da test/sandbox kirliliği yaşamış bir salonun) **gerçek** abonelik izlerini sıfırlamak için `functions/src/http/reset-gym-subscription.ts` adında, sadece ELLE tetiklenen bir HTTP Cloud Function var (`resetGymSubscription`).

**Önemli — bu bir tetikleyiciye (trigger) BAĞLI DEĞİL:** hiçbir client kodu, Firestore trigger'ı, scheduler ya da webhook bunu otomatik çağırmıyor ve ÇAĞIRMAMALI. Sadece Google Cloud Console'daki fonksiyonun "Testing" sekmesinden (`{"gymId": "...", "secret": "..."}`) ya da bir HTTP isteğiyle admin tarafından elle tetikleniyor. Secret, Secret Manager'da `RESET_GYM_SUBSCRIPTION_SECRET` adıyla tutuluyor.

**Ne yapıyor:** `gyms/{gymId}` üzerindeki `subscription*` alanlarını (`subscriptionStatus`, `subscriptionProductId`, `subscriptionExpiresAt`, `subscriptionStartedAt`, `subscriptionCancelAtPeriodEnd`, `subscriptionLastVerificationData`, `subscriptionLastVerificationPlatform`, `subscriptionPlatform`) siler + `subscriptionTransactions` koleksiyonunda bu salona ait (`gymId ==` sorgusuyla bulunan) kayıt(lar)ı siler. **`subscriptionExempt` alanına DOKUNMUYOR** — o ayrı, bilinçli bir admin kararı, bu aracın kapsamı dışında.

**🔴 KRİTİK — abonelik sistemiyle ilgili HERHANGİ bir değişiklik/özellik geliştirirken bunu MUTLAKA hatırlat ve kontrol et:**
- `gyms/{gymId}` dokümanına YENİ bir abonelik alanı eklenirse (ör. `subscriptionSomethingNew`), bu fonksiyonun sildiği alan listesine de eklenmesi gerekip gerekmediğini değerlendir — eklenmezse "sıfırlama" eksik kalır, salon yarı-sıfırlanmış garip bir durumda kalabilir.
- `subscriptionTransactions`'ın şeması/anahtar yapısı değişirse (ör. `gymId` yerine başka bir alan adı kullanılırsa), buradaki sorgu da güncellenmeli.
- Abonelik doğrulama akışına (`apply-subscription-update.ts`, `verify-subscription-purchase.ts` vb.) yeni bir yan-etki/yeni bir koleksiyon eklenirse, bu aracın o yan-etkiyi de temizleyip temizlemediğini kontrol et.
- Kısacası: bu dosyayı ve `docs/Abonelik_Iptal_Rehberi.docx`'ü (manuel/Console eşdeğeri) abonelik sistemine her dokunduğunda akılda tut, ikisi de güncel kalmalı.

## graphify

Bu projede `graphify-out/graph.json` mevcut ve **kurulu** (`~/.local/bin/graphify`). Kod tabanı, mimari veya dosyalar arası ilişkilerle ilgili herhangi bir soruda — yeni bir görev/oturuma başlarken "önce kodu okuyup anlamaya çalışayım" refleksi yerine:
- ÖNCE `graphify query "<soru>"` çalıştır (geniş bağlam için), gerekirse `graphify path "A" "B"` (iki kavram arası yol) veya `graphify explain "X"` (bir node'un açıklaması) kullan. Bu, ham dosyaları `grep`/`find`/`Read` ile taramaktan veya bir Explore/general-purpose agent'ı keşif için başlatmaktan ÖNCE denenmeli — token tasarrufu asıl buradan gelir.
- Sadece grafik sorgusu yetersiz kalırsa (çok spesifik bir satır, güncel olmayan bir alan, henüz grafiğe girmemiş yeni bir dosya vb.) ham dosyaya/agent'a dön.
- Kod önemli ölçüde değiştiyse `graphify update` çalıştırılan dizindeki grafiği günceller (tam yeniden taramadan çok daha ucuz).
- **Tarama kökü `lib/`'dir, proje kökü DEĞİL** — `graphify-out/.graphify_root` `lib`'e ayarlı. Proje kökünde (`.`) tam taramaya ASLA dönme: `ios/Pods`, `functions/lib`, `functions/node_modules`, `android` gibi vendored/derlenmiş klasörler `.gitignore`'da olmadığı için taramaya girip 7000+ dosyaya şişiriyor (bir kere yaşandı, `lib/`e daraltılarak düzeltildi — 429 kod dosyası, 0 LLM token). Cloud Functions kaynak kodunu (`functions/src/`) sorgulaman gerekirse ayrı bir `graphify extract functions/src` + `graphify merge-graphs` gerekir, henüz kurulmadı.
