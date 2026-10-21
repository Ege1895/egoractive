# Sonraki Oturum Promptu — FAZ 14: Apple İncelemesini Tek Seferde Geçmek

> Bu dosyanın tamamını yeni oturuma yapıştır. Hazırlanma tarihi: 2026-10-21.

---

Egoractive (Flutter + Firebase, iOS + Android) için App Store incelemesini **tek gönderimde** geçecek hâle getiriyoruz. Önceki oturum context limiti yüzünden kapandı; kaldığımız yer aşağıda. Önce `CLAUDE.md`'yi, sonra `docs/Egoractive_Gorev_Listesi.md` içindeki **FAZ 14** bölümünü (sonundaki "Oturum sonu durumu" dahil) oku. Kod soruları için önce `graphify query` kullan (CLAUDE.md kuralı).

**Hedef:** Bu oturumun sonunda (1) tüm değişiklikler commitli ve pushlu, (2) Cloud Functions ve Remote Config canlıda güncel, (3) uygulama prod'a hazır, (4) kullanıcı build 28'i TestFlight'tan kurup **sandbox'ta iki aboneliği de satın alarak test edebiliyor**, (5) App Store Connect'e gönderim için kullanıcının yapacağı her adım net bir listede.

Her adımdan sonra kısa bir durum ver. Canlıyı etkileyen her işlemden (deploy, Firestore yazma, mağaza ayarı) önce bana sor. Commit/push için onayım var: her tamamlanan task'ı ayrı commitle ve pushla (branch: `feature/theme-delete-and-recurring-year`).

## 1. Durum özeti

**İnceleme geçmişi (App Store, Submission ID `291c1096-fa10-4d90-bb16-e5022526e4ad`, App Apple ID `6802342121`):**
- 2.1(a) — demo hesap bilgisi eksik → çözüldü (App Review Information'a 3 demo hesap eklendi).
- 2.1(b) — iş modeli soruları → cevaplandı.
- **21 Ekim, son red (build 24, iPad Air 11 inç, iPadOS 27.0.1):**
  1. **3.1.2(c):** Satın alma akışında Kullanım Koşulları (EULA) + Gizlilik Politikası bağlantıları yok; App Store açıklamasında (her dilde) Kullanım Koşulları bağlantısı yok. Cevapta **ekran kaydı** istiyorlar; bilgiyi Notes alanına da eklememizi istiyorlar.
  2. **2.1(b):** Abonelikler incelemeye gönderilmemiş → ürünleri gönder + **yeni build yükle**.
  3. **2.1(b):** Plana dokununca hiçbir şey olmadı → sandbox'ta ürün yapılandırması + Paid Apps Agreement kontrolü.

**Kök nedenler (önceki oturumda kodda ve ASC'de doğrulandı):**
- ASC abonelik sayfası: **"You must set availability for your subscription"** → satış ülkeleri seçilmemiş; StoreKit'in boş dönmesinin en olası sebebi. Ayrıca "Review Information screenshot" eksik.
- Uygulama, ürün gelmeyince **sahte planlar** gösterip plana dokununca **ödemesiz deneme** başlatan `startMockSubscription` callable'ını çağırıyordu (3.1.1 riski; Play'deki build 25'te hâlâ aktif). → F14-2'de kaldırıldı (commitlenmedi, deploy edilmedi).
- `LegalLinks` 6 satın alma noktasından yalnızca birinde var (`_trialView`). Demo salon muaf olduğu için reviewer bağlantısız `_exemptView`'ı gördü.

**Sürümler:**
- Play üretimde canlı: **build 25** — giriş sonrası OTP ekranında donma hatası var.
- Build 26: eksik düzeltme (kullanılmayacak). Build 27: giriş düzeltmesi tam (commit `ce5fc13`), alındı ama hiçbir mağazaya yüklenmedi.
- **Hedef: build 28** = 27 + FAZ 14.
- `pubspec.yaml` şu an `1.0.0+27`.

## 1b. 2026-10-21 oturum sonu güncellemesi (bunu önce oku)

- **F14-2 commitlendi ve pushlandı** (`ed48e9f`) — aşağıdaki 2. bölüm artık yalnızca bilgi amaçlı; deploy (3. bölüm) hâlâ yapılmadı.
- **F14-1 commitlendi ve pushlandı** (`638d497`): `_PurchaseFooter` (geri yükle + bağlantılar) deneme/süresi dolmuş/yıllığa geç ekranlarında; `LegalLinks` muaf, onboarding ve "tekrar dene" ekranlarında; plan kartında yenilenme dönemi (`plan_labels.dart`, RC `lbl_subscription_period_monthly/yearly`); ürün sorgusuna 15 sn zaman aşımı (emülatörde sonsuz yükleme yeniden üretildi ve düzeltildi). Emülatörde görsel olarak doğrulandı. Yıllık planın aylık karşılığı (birim fiyat) eklenmedi — Apple "uygunsa" diyor, isteğe bağlı.
- **YENİ GÖREV F14-7 — abonelik test hesabı (canlı veri, onay al):** Demo salon muaf olduğu için abonelik ekranında satın alma butonu YOK; reviewer demo hesapla abonelik test edemiyor. Muaf OLMAYAN, aboneliği olmayan ayrı bir demo salon + admin oluştur: telefon `+905555550001`, `otpBypassEnabled: true`, `email` dolu (başka hesapta kullanılmayan), custom claim `role: admin` + `gymId`. Mevcut admin/salon oluşturma Cloud Function'larını ve `scripts/enable_closed_test_accounts.ts`'i incele, aynı yolla oluştur. App Review Notes metni bu hesabı varsayıyor. Yayın sonrası OTP bypass kapatılırken bu hesap da listeye girmeli.
- Kullanıcı yaptı: Paid Apps Agreement onaylandı, abonelik Availability ayarlandı, Privacy Policy URL dolu. Ekran görüntüsü, IAP gönderimi, build 28, ekran kaydı build'den sonra.

## 1c. İkinci oturum ilerlemesi

- **F14-3 commitlendi** (`9cc404a`): `core/diagnostics/non_fatal.dart` → `reportNonFatal`.
- **Build 29 alındı (`32d3735`), mağazalara gönderilecek olan bu; build 28 alındı, commitlendi, pushlandı** (`ed44dbc`): `28 (1.0.0).aab` (versionCode=28 doğrulandı), iOS `FLUTTER_BUILD_NUMBER=28`.
- **Canlı RC ↔ şablon farkı kontrol edildi:** canlıda olup şablonda olmayan parametre YOK; fark yalnızca 10 yeni metin anahtarı + `cfg_subscription_mock_start_enabled` true→false. Deploy güvenli, **kullanıcı onayı bekleniyor**.
- **F14-7 TAMAM:** abonelik test hesabı `+905335335353` (uid `ku8Tv1mTYsgyO8nnKTwN`, salon "GymFit" `JUGd0MGv28iqxv22EFMy`, e-posta egoragames@gmail.com, abonelik yok, muaf değil) → `otpBypassEnabled: true` yazıldı. Emülatörde `000000` ile giriş → doğrudan "Aboneliğini başlat" (`subscriptionOnboarding`). Notes metni bu hesapla güncellendi. Yayın sonrası bypass kapatılırken bu hesap da kapanır (script tüm `otpBypassEnabled` hesaplarını tarar).
- **AÇIK RİSK — 14 gün ücretsiz vaadi:** onboarding alt başlığı (`lbl_subscription_onboarding_subtitle_*`, `{days}`=RC `cfg_trial_duration_days`=14) "14 gün ücret alınmaz" diyor. Eskiden bu deneme mock fonksiyonla uygulama tarafında başlıyordu; mock silindi. App Store / Play'de aboneliklere 14 günlük ücretsiz deneme (introductory offer) tanımlı DEĞİLSE ekran yanlış vaat veriyor → Apple reddi riski. **ÇÖZÜLDÜ (2026-10-21):** kullanıcı App Store'da 14 günlük ücretsiz deneme tanımladı, Apple ödeme penceresinde görünüyor. Play tarafı teyit edilmedi. Küçük iyileştirme (isteğe bağlı): `subscription_purchase_service.dart` `_freeTrialDays` `promotionalOffers`'a bakıyor; ücretsiz deneme StoreKit2'de `introductoryOffer` olarak gelir, bu yüzden plan kartında "14 gün ücretsiz" etiketi görünmüyor (yalnızca yenilenme dönemi).
- (eski not) **F14-7 değişti:** abonelik test hesabını kullanıcı uygulamadan kendisi oluşturacak (yeni salon → zorunlu abonelik ekranı, abone olmadan kapatacak). Bize kalan: o hesaba `otpBypassEnabled: true` yazmak (onayla) ve Notes'taki numarayı güncellemek. Bu hesap girişte doğrudan abonelik ekranını açar.
- **F14-4 TAMAM:** üye demo hesabına (`XyrJtfwrt8Ol2ueZiBzI`, +905335330000) `meliskorkmz07@gmail.com` yazıldı; emülatörde temiz kurulumla `000000` → doğrudan üye ana ekranı (`email=set`, `ready`).
- **DEPLOY YAPILDI (2026-10-21):** Remote Config canlıda (10 yeni anahtar, mock bayrağı false); functions deploy başarılı, `startMockSubscription` silindi (`firebase functions:list` ile doğrulandı).
- **`egoragames@gmail.com` Texas Gym admininden (`K8UXu6FR5nPAw5o6KNOH`, +905333003030) kaldırıldı** (kullanıcı isteği); kullanıcı bu adresle abonelik test hesabı/salonu oluşturacak. Texas Gym admini sonraki girişte e-posta kurulum ekranına düşer.

## 2. Çalışma dizinindeki commitlenmemiş değişiklikler (ilk iş)

F14-2 kodu hazır ama commitlenmedi. `git status` ile doğrula; beklenen:
- Silinenler: `functions/src/callable/start-mock-subscription.ts` (`git rm` yapıldı), `functions/src/index.ts`'deki export; `mockSubscriptionProducts`; `lastFetchWasMock` / `startMockSubscription` (purchase service, verification service, repository, controller); `_purchaseOrMockStart`.
- Eklenenler: `SubscriptionProductsUnavailableException`, `lib/modules/subscription/ui/widgets/subscription_products_unavailable.dart`, RC anahtarları `lbl_subscription_products_unavailable_title/_body` + `lbl_subscription_products_retry` (kod varsayılanı + `remoteconfig.template.json`), `test/modules/subscription/subscription_products_unavailable_test.dart`.
- `remoteconfig.template.json`: `cfg_subscription_mock_start_enabled` → `false`.
- `docs/Egoractive_Gorev_Listesi.md` (FAZ 14), bu dosya.

`flutter analyze lib` (beklenen: eski 10 info), `flutter test` (182), `cd functions && rm -rf lib && npm run build && npm test` (130) çalıştır; geçerse **F14-2'yi commitle ve pushla**. `graphify-out/manifest.json` ve `assets/store-scrennshots/` commit'e girmesin.

## 3. Deploy (onayımı al)

1. **Remote Config:** Şablonu yayınlamak canlıyı tamamen ezer. Önce canlıyı indir (`firebase remoteconfig:get -o /tmp/rc_live.json`), `remoteconfig.template.json` ile parametre parametre karşılaştır, şablonda olmayan ya da değeri farklı olan canlı parametreleri bana göster. Onaylarsam deploy et (`firebase deploy --only remoteconfig`).
2. **Functions:** `firebase deploy --only functions` — `startMockSubscription` silinmesini isteyecek, onayla. Silindikten sonra Play'deki build 25 bu callable'ı çağırırsa hata alır; bu istenen davranış (ödemesiz deneme kapanır).
3. Deploy sonrası `firebase functions:list` ile `startMockSubscription`'ın gittiğini doğrula.

## 4. Kod görevleri (FAZ 14 — her biri ayrı commit)

**F14-1 — Hukuki bağlantılar her satın alma noktasında (3.1.2(c)):**
- `LegalLinks(centered: true)`'yı satın alma butonunun hemen altına ekle: `subscription_panel.dart` `_exemptView`, `_activeView` (yıllığa geç kartı), `_expiredView`, `_pendingView`; `subscription_onboarding_panel.dart`. Yerleşim için `_trialView`'ı örnek al.
- Yeni "Tekrar dene" ekranına da ekle (Apple satın alma ekranında bu bağlantıları bekliyor).
- Her plan kartında **ad, süre (aylık/yıllık), fiyat** görünür olmalı; yıllıkta mümkünse aylık karşılık. Eksikse ekle, metinler RC'den.
- URL'ler RC'den: `lbl_common_terms_url_tr/en` = `https://egoragames.com/games/egoractive/terms-of-use/{tr|en}/`, `lbl_common_privacy_url_tr/en` = `.../privacy-policy/{tr|en}/`. Canlı RC'de dolu olduklarını doğrula (boşsa `LegalLinks` satırı gizliyor).
- Widget testi: her görünümde `LegalLinks` render ediliyor.

**F14-3 — Sessiz hataları logla:** `ad_consent_service.dart` hata callback'i, `ad_banner_widget.dart` ve `ad_interstitial_gate.dart` yükleme/gösterme hataları, ürün sorgusu hatası (`SubscriptionProductsUnavailableException`), satın alma hataları → `debugPrint` + Crashlytics non-fatal. Davranış değişmesin.

**F14-4 — Üye demo hesabı e-postası (canlı Firestore yazma — onayımı al):** `users/XyrJtfwrt8Ol2ueZiBzI` (+905335330000) `email`/`emailLower` boş → reviewer "E-posta adresini ekle" ekranında kalıyor (OTP bypass orada geçmiyor). Hangi adresi yazacağını bana sor; başka hesapta kullanılmadığını (`emailLower` sorgusu) kontrol et. Sonra Android emülatörde (`galaxy_a71`, release APK) üye demo hesabıyla `000000` → doğrudan ana ekran açıldığını doğrula.

**Abonelik değişikliği kuralı (CLAUDE.md):** `resetGymSubscription` (`functions/src/http/reset-gym-subscription.ts`) ve `docs/Abonelik_Iptal_Rehberi.docx` etkileniyor mu değerlendir. Mock akışın salonlara `trialStartedAt` ve `subscriptionHistory`'ye `source: "mock"` kayıtları yazmış olabileceğini not et; hangi salonlarda olduğunu read-only bir sorguyla listele, temizlik kararını bana bırak.

## 5. Build 28 (CLAUDE.md §7 — iki platform eksiksiz)

`version: 1.0.0+28` → `flutter pub get` → `cd ios && LANG=en_US.UTF-8 pod install` → `flutter build appbundle --release` → `cp app-release.aab "28 (1.0.0).aab"` (Flutter'ın yazdığı dosya adı yanıltıcı; versionCode'u bundle içindeki proto manifestten oku) → `flutter build ios --no-codesign --debug` → `ios/Flutter/Generated.xcconfig`'te `FLUTTER_BUILD_NUMBER=28` → commit + push. Kullanıcıya Xcode'da **Product → Archive** hatırlatması yap.

## 6. Sandbox teste hazırlık (kullanıcı tarafı — adım adım yaz)

Kullanıcının build 28'i TestFlight'tan kurup sandbox'ta satın alabilmesi için:
1. **Business → Agreements:** Paid Apps Agreement "Active", banka ve vergi tamam.
2. **Abonelikler** (`egoractive_business_monthly`, `egoractive_business_yearly`, tek abonelik grubu "Egoractive Business Plans"): **Availability → ülkeleri seç**, fiyat, TR+EN yerelleştirme (görünen ad + açıklama) dolu, **Review Information screenshot** (abonelik ekranının görüntüsü; availability ayarlandıktan sonra gerçek fiyatlarla alınabilir). Durum "Ready to Submit" olmalı.
3. **Users and Access → Sandbox → Test Accounts:** sandbox test hesabı oluştur (hafızadaki nota göre henüz yok). iPhone'da Ayarlar → App Store → Sandbox Account ile giriş.
4. **App Store Server Notifications URL** (hafızada "bekliyor" olarak not edilmiş): abonelik yenileme/iptal bildirimleri için gerekli mi, backend'de hangi endpoint'e bağlı, kontrol et ve kullanıcıya yaz.
5. TestFlight'ta build 28'i iç test grubuna aç.

**Sandbox test senaryosu (kullanıcı uygulayacak, ekran kaydı alacak — Apple cevapta istiyor):** demo admin (`+90 555 555 0000` / `000000`) ile gir → Ayarlar → Abonelik → bağlantıları göster ve aç → aylık planı seç → Apple ödeme penceresi → satın al → `subscriptionStatus: active` → "Satın alımları geri yükle" → yıllığa geçiş. **Not:** Demo salon muaf (`subscriptionExempt: true`); muaf görünümde satın alma butonu çalışıyor mu kontrol et, çalışmıyorsa test için muaf olmayan bir test salonu öner.

## 7. App Store Connect gönderim listesi (kullanıcı tarafı)

- Sürüm 1.0 → build **28**; **In-App Purchases and Subscriptions** bölümünde iki ürün seçili.
- **Açıklama (TR ve EN):** sonuna Kullanım Koşulları ve Gizlilik Politikası bağlantıları. Privacy Policy URL alanı dolu.
- **App Review Information:** Sign-in `+90 555 555 0000` / `000000` (önceden `egoragames`/şifre yazılıydı, düzeltildi mi kontrol ettir). Notes: önceki oturumda yazılan İngilizce metin (giriş akışı + demo hesaplar + iş modeli) + abonelik ekranına nasıl gidileceği.
- Red mesajına ekran kaydıyla cevap; sonra **Submit**.
- (İsteğe bağlı) iPad görünümü: reviewer iPad kullanıyor. iPad simülatörü için `SUPPORTED_PLATFORMS = iphoneos` derlemeyi engelliyor; geçici olarak `"iphoneos iphonesimulator"` yapıp bak, sonra geri al.

## 8. Web sitesi (2026-10-21'de curl ile doğrulandı)

Hepsi yayında (HTTP 200): `/games/egoractive/privacy-policy/{tr,en}/`, `/games/egoractive/terms-of-use/{tr,en}/` (abonelik bölümü var: otomatik yenileme, 24 saat kala iptal, fiyat), `/games/egoractive/support/{tr,en}/` (hesap silme bölümü var), `https://egoragames.com/app-ads.txt` (`google.com, pub-7842412614783450, DIRECT, f08c47fec0942fa0`). Eksik ama isteğe bağlı: ayrı hesap silme sayfası (`/delete-account/`, 404 — silme bilgisi support ve privacy §8'de zaten var), tanıtım sayfası `/games/egoractive/` (404). Yeni URL hazırlamak gerekmiyor.

## 9. Google Play

- Build 28'i (ya da hemen 27'yi) üretime yükle: canlıdaki 25'te giriş donması var.
- Kullanıcı **Yönetilen yayınlama**'yı açmak istiyor (Yayın özeti → Yönetilen yayınlama → aç).

## 10. Dokunma / unutma

- **Demo hesapların OTP bypass'ı** (`otpBypassEnabled`) iki mağazanın onayı gelene kadar AÇIK kalmalı; onaydan sonra `cd scripts && CONFIRM_PRODUCTION_BACKFILL=yes npm run audit-otp-bypass -- --allow-production --revoke`.
- Google Cloud faturalandırma ücretliye yükseltildi (2026-10-05), bütçe uyarıları kurulu, spend cap açılmayacak.
- AdMob GDPR mesajı yayında (2026-10-12); reklamlar çalışıyor (yalnızca üye ekranı, abonelik `active` değilken).
- Bilinen ama bu fazın dışında: `shouldShowAds` `subscriptionExempt`'i yok sayıyor; App Check API Google Cloud'da etkin değil (403).
