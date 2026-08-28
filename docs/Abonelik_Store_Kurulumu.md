# Abonelik (Salon Aboneliği) — Store Kurulum Notları

Bu dosya, admin onboarding'ine eklenen zorunlu "Aboneliğini başlat" ekranının
(`SubscriptionOnboardingPanel`) gerçek para çekimiyle çalışması için App
Store Connect / Play Console tarafında yapman gereken her şeyi topluyor.
Kod tarafı hazır, aşağıdakiler tamamlanmadan bu ekran boş/işlevsiz kalır.
İstediğin an "abonelik store kurulumu" deyip bu dosyayı tekrar isteyebilirsin.

## Kod tarafında zaten sabit olanlar (değiştirmeden kullan)

- **Ürün ID'leri** (`lib/core/constants/subscription_constants.dart` /
  `functions/src/shared/subscription-constants.ts`) — her iki mağazada da
  **birebir bu ID'lerle** oluşturulmalı:
  - `egoractive_business_monthly`
  - `egoractive_business_yearly`
- **Bundle ID / paket adı:** `com.egoragames.egoractive`
- **Deneme süresi:** şu an 14 gün (`cfg_trial_duration_days`, Remote Config).
  Mağazadaki "Free Trial" introductory offer süresini de bununla aynı tut.

## 1) App Store Connect (iOS)

- [ ] Uygulama altında bir **Subscription Group** oluştur (öneri: "Egoractive Gym Plans") — aylık/yıllık aynı grupta olmalı ki kullanıcı ikisi arasında geçiş yapabilsin.
- [ ] Grup içine iki auto-renewable subscription ekle: `egoractive_business_monthly`, `egoractive_business_yearly` (Product ID alanına birebir bunlar).
- [ ] Her ikisine de fiyat, süre (1 ay / 1 yıl), yerelleştirilmiş başlık/açıklama gir.
- [ ] Her ikisine **Introductory Offer → Free Trial** ekle, süre: **2 Weeks** (14 gün ile eşleşen en yakın hazır seçenek) — bölge/fiyat listesi seçimini kontrol et.
- [ ] **App-Specific Shared Secret** üret (App Store Connect → uygulama → App Information, ya da Subscriptions sayfasından) — bu değeri bana ver, `APPLE_SUBSCRIPTION_SHARED_SECRET` secret'ına işleyeceğim.
- [ ] **Apple Root CA sertifikaları** indir ([Apple PKI sayfası](https://www.apple.com/certificateauthority/), "Apple Root Certificates" bölümü, DER formatındaki `.cer` dosyaları) — webhook'un imza doğrulaması için gerekiyor. Her birini base64'e çevirip (`base64 -i AppleRootCA-G3.cer`) virgülle birleştir, bana ver — `APPLE_ROOT_CA_CERTIFICATES_BASE64` secret'ına işleyeceğim.
- [ ] **Server Notifications V2 URL'i** (App Store Connect → uygulama → App Information → App Store Server Notifications → Production/Sandbox URL) — fonksiyon deploy edildikten sonra vereceğim `https://us-central1-egoractive-e92bd.cloudfunctions.net/appleServerNotifications` adresini buraya gir.
- [ ] **Sandbox Tester** hesabı oluştur (Users and Access → Sandbox → Testers) — gerçek ücret çekmeden trial+satın alma akışını uçtan uca test etmek için bu hesapla cihazda oturum açacağız.
- [ ] Review notlarına aboneliğin ne sağladığını kısaca yaz (App Store Guideline 3.1.2 — fiyat/süre/otomatik yenileme ekranda net görünmeli; mevcut `SubscriptionOnboardingPanel` metni bunu zaten karşılıyor).

## 2) Google Play Console (Android)

- [ ] İki ayrı **klasik subscription** oluştur (Base plan'lı tek ürün DEĞİL — mevcut backend kodu `purchases.subscriptions.get` legacy API'yi kullanıyor, bu yalnızca klasik/çoklu-SKU modeliyle uyumlu): `egoractive_business_monthly`, `egoractive_business_yearly`.
  - Eğer Play Console sende yeni "tek subscription + birden çok base plan" akışını zorunlu kılıyorsa (yeni projelerde bazen öyle), bana haber ver — o zaman backend'i `purchases.subscriptionsv2.get`'e taşımam gerekecek, kod değişikliği bende.
- [ ] Her ikisine fiyat, süre gir; **Free trial** offer'ı ekle, süre 14 gün.
- [ ] **API access** (Play Console → Setup → API access) altında bir servis hesabı oluştur, "Play Android Developer API" için erişim ver (finansal veri görüntüleme yeterli), JSON anahtarını indir — bu dosyayı bana ver, `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` secret'ına (tek satır string olarak) işleyeceğim.
- [ ] **License testing** (Setup → License testing) altına test Google hesabını ekle, uygulamayı Internal/Closed testing track'e yükle — gerçek ücret çekmeden trial+satın alma testi için gerekiyor.
- [ ] **Real-time developer notifications** (Monetization setup → Real-time developer notifications) altında bir **Pub/Sub topic** oluştur, adı tam olarak **`play-subscriptions`** olmalı (kod bu isme abone oluyor) ve bu topic'i abonelik bildirimlerine bağla.

## 3) Bana vermen gerekenler (hepsi gizli — Firebase Secret Manager'a yazılacak, koda gömülmeyecek)

- [ ] Apple App-Specific Shared Secret (tek satır string)
- [ ] Apple Root CA sertifikaları (base64, virgülle ayrılmış)
- [ ] Google Play servis hesabı JSON anahtarı (tüm dosya içeriği)

Bunları aldığımda şu komutlarla secret'lara işleyip ilgili fonksiyonları deploy edeceğim:
```
firebase functions:secrets:set APPLE_SUBSCRIPTION_SHARED_SECRET
firebase functions:secrets:set APPLE_ROOT_CA_CERTIFICATES_BASE64
firebase functions:secrets:set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
firebase deploy --only functions:verifySubscriptionPurchase,functions:appleServerNotifications,functions:googlePlayRtdn,functions:subscriptionRenewalCheck
```

## 3a) Anlık durum güncellemesi — webhook + günlük yedek kontrol

Kod tarafında iki katmanlı bir sistem var:
- **Webhook'lar** (`appleServerNotifications`, `googlePlayRtdn`) — store bir yenileme/iptal/ödeme başarısızlığı bildirdiği ANDA Firestore'u günceller (yukarıdaki URL/Pub/Sub topic kurulumu tamamlanınca aktif olur).
- **`subscriptionRenewalCheck`** (günde bir kez çalışan zamanlı fonksiyon) — webhook hiç kurulmasa/bir bildirim kaçsa bile, süresi dolmak üzere/dolmuş her `trial`/`active` salonun son bilinen makbuzunu tekrar sorgulayıp durumu düzeltir. Bu, webhook kurulumunu beklemeden BUGÜN de çalışıyor — yani webhook'ları hemen kurmasan bile salon en geç 24 saat içinde doğru duruma geçer.

## 3b) Test/demo salonlarını abonelik olmadan aktif tutma — `subscriptionExempt`

Store kurulumu tamamlanmadan bir salonu (kendi test salonların ya da bir demo salonu) tamamen serbest bırakmak istersen:

1. Firebase Console → Firestore Database → `gyms` koleksiyonu → ilgili salon dokümanı.
2. Yeni alan ekle: `subscriptionExempt`, tip **boolean**, değer **true**.
3. Kaydet — anında etkili olur (client canlı dinliyor, uygulamayı kapatıp açmaya gerek yok).

Bu `true` olduğu sürece o salonun admin'i, antrenörleri ve üyeleri **abonelik durumu ne olursa olsun** (hatta `subscriptionStatus` alanı hiç yoksa bile) tam erişimli sayılır — hiçbir ücret çekilmez. Varsayılan `false`'tur (alan hiç yoksa da `false` sayılır) — yani dokunmadığın her salon normal şekilde abonelik ister. Bu alanı sadece Console/Admin SDK'dan değiştirebilirsin, uygulama içinden (admin dahil) hiç kimse kendi salonuna bunu yazamaz.

## 4) Test sırası (her iki mağaza da hazır olunca)

1. Sandbox/test hesabıyla cihazda oturum aç (gerçek Apple ID/Google hesabıyla DEĞİL, yukarıdaki test hesaplarıyla).
2. Yeni bir salon oluştur (Antrenörüm → Yeni salon aç akışı) → telefonla giriş yap.
3. Zorunlu abonelik ekranında bir paket seç, "14 gün ücretsiz başlat"a bas.
4. Mağaza sheet'inde ücretsiz deneme + sonraki tarih/fiyat net görünmeli, onaylayınca ekran otomatik olarak admin ana ekranına geçmeli.
5. `gyms/{gymId}.subscriptionStatus` alanının Firestore'da `active` olduğunu doğrula.

## 5) Bu tamamlanana kadar dikkat

- **Remote Config → `cfg_require_subscription_onboarding`** şu an `true` — admin girişten hemen sonra zorunlu abonelik ekranına düşüyor. Mağaza ürünleri henüz canlı olmadığı için ekran mock veriyle açılıyor (bkz. Bölüm 5a) — kimse takılı kalmıyor.
- **ÖNEMLİ — bu bayrak antrenör/üye girişini etkilemiyor.** Salon Abonelik ve Erişim Akışı kapsamında artık: bir salonun `subscriptionStatus`'u `trial`/`active` değilse o salonun antrenör/üyeleri HİÇBİR ZAMAN giriş yapamaz (bu bayraktan bağımsız, her zaman geçerli) ve admin de normal ekranlara erişemez (sadece okuma/yazma değil). Yeni oluşturduğun test salonlarında antrenör/üye girişini test edeceksen, o salonun admin'inin (gerçek ya da sandbox) bir abonelik başlatmış olması gerekir.
- Mevcut/eski salonlar (bu değişiklikten önce oluşturulanlar) etkilenmiyor — onların `subscriptionStatus` alanı zaten `trial`/`active` olarak yazılmıştı, yeniden abone olmaları istenmiyor.
- `trialExpiryCheck` (eski, saf Firestore tabanlı 14 gün sayacı) hâlâ çalışıyor ama artık sadece bu eski salonlar için anlamlı — yeni salonlarda gerçek mağaza aboneliği zaten `subscriptionExpiresAt`'i kendi belirliyor (`subscriptionRenewalCheck` + webhook'lar üzerinden).

## 5a) ŞU AN mock modda çalışan kısım — store bağlanmadan test edilebiliyor

Mağaza ürünleri henüz canlı olmadığı için (2026-08-26 itibarıyla) abonelik ekranındaki "X gün ücretsiz başlat" butonu gerçek satın alma yerine geçici bir **mock başlatma** yoluna gidiyor:

- `SubscriptionPurchaseService.fetchProducts()` mağazadan hiç ürün alamayınca (`lastFetchWasMock = true`) mock plan verisi gösteriyor — fiyatlar gerçek (planlanan) fiyatlarımız: **TR: Aylık ₺999,00 / Yıllık ₺9.990,00**, **Global: Aylık $19.99 / Yıllık $199.99** (cihazın dil ayarına göre TR/EN seçiliyor).
- Butona basınca client bunu görüp gerçek `verifySubscriptionPurchase` yerine yeni **`startMockSubscription`** callable'ını çağırıyor — bu, hiçbir mağaza doğrulaması yapmadan salonu doğrudan `subscriptionStatus: trial` yapıyor (ücret çekilmez, gerçek bir işlem yok).
- **Store ürünleri canlıya alınıp `queryProductDetails` gerçek ürün döndürmeye başlar başlamaz `lastFetchWasMock` otomatik olarak `false` olur ve client kendiliğinden gerçek satın alma akışına geçer — bunun için BENİM ayrıca bir kod değişikliği yapmama gerek YOK.** Sadece ek bir güvenlik kapağı olarak `cfg_require_subscription_onboarding` gibi Remote Config'te `cfg_subscription_mock_start_enabled` var (varsayılan `true`) — istersen store canlıya alınmadan önce bile bunu `false` yapıp mock yolunu tamamen kapatabilirsin.

**Sana düşen:** Store süreçlerini (Bölüm 1/2) tamamladığında bana "storeları tamamladım" de — birlikte gerçek ürünlerin (`queryProductDetails`) doğru döndüğünü doğrularız, `verifySubscriptionPurchase` secret'larını (Bölüm 3) bağlarız ve test sırasını (Bölüm 4) birlikte çalıştırırız. Kod tarafında bekleyen bir iş yok, sadece store console kurulumu + secret'lar.

## 6) Trial bir kez kullanılır (`trialUsed`)

Bir salon gerçek mağaza trial'ıyla (Apple/Google'ın "Free Trial" introductory offer'ı) bir kez abone olduğunda `gyms/{gymId}.trialUsed = true` kalıcı olarak yazılır — admin hesabı silinse, aboneliği iptal edip yeniden alsa bile bu bayrak asla `false`'a dönmez; abonelik ekranında bir daha "X gün ücretsiz" seçeneği gösterilmez, doğrudan ücretli plan sunulur.

**Bilinen sınır:** Bu bizim uygulama/backend kararımız — ama Apple/Google'ın kendi "Free Trial" introductory offer'ı hesap (Apple ID/Google hesabı) bazlı çalışıyor. Yani salon `trialUsed=true` olsa bile, admin FARKLI bir Apple ID/Google hesabıyla satın alırsa mağaza yine de kendi ücretsiz deneme UI'ını gösterebilir — bunu App/Play Store seviyesinde tam engellemek Apple'da "Promotional Offers" (imzalı, sunucu taraflı) sistemine geçmeyi gerektirir, bu kapsamda yapılmadı. `trialUsed` bizim UI/erişim kararlarımızı doğru yönetiyor, bu tek istisna dışında.
