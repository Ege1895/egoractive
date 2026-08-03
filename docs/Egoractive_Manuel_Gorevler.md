# Egoractive — Senin (İnsan) Yapacakların

Bu liste, Claude Code'un yapamayacağı/yapmaması gereken (hesap açma, ödeme, onay bekleme, karar verme) işleri topluyor. `Egoractive_Gorev_Listesi.md` Faz 0 ve Faz 7'deki insan görevleriyle aynı — burada tek yerde, sıraya göre toplandı.

## Şimdi (P0-P5 panel inşasıyla paralel yapılabilir, hiçbiri kod akışını bloklamıyor)

- [ ] **Apple Developer Program** kaydı — "Egora Games" tüzel kişilik olarak (D-U-N-S numarası gerekiyor, başvurmadan önce D-U-N-S'nin hazır/kayıtlı olduğundan emin ol, yoksa başvuru haftalar sürebilir)
- [ ] **Google Play Console** geliştirici hesabı — tek seferlik $25, "Egora Games" profili
- [ ] Her iki store'da **boş app kaydı** — uygulama adı ve bundle ID kararı (öneri: `com.egoragames.egoractive` — onaylıyor musun, yoksa değiştirelim mi?)
- [ ] **Gizlilik Politikası ve Kullanım Şartları** metni — toplanan veri tipleri (telefon no, ölçüm/sağlık verisi, push token; konum yok) baz alınarak yazılır, statik bir sayfada yayınlanır (GitHub Pages / Firebase Hosting). Metni ben de taslak olarak hazırlayabilirim, sen barındırma ve onay kısmını yaparsın — istersen söyle, taslağı yazayım.
- [ ] **Marka kimliği kararı:** Tasarım paketindeki koyu tema (`#06090D` arka plan, `#05A6FA` mavi vurgu, Outfit + IBM Plex Sans) nihai marka rengi mi, yoksa F0-5'te ayrı bir "varsayılan/marka teması" mı belirlenecek? App icon ve tüm çözünürlükte export bekliyor.
- [ ] **Firebase projeleri:** `egoractive-dev` ve `egoractive-prod` adıyla iki proje aç (Google Cloud/Firebase Console üzerinden — hesap sahipliği ve faturalandırma senin kararın, ben `flutterfire configure` ile bağlarım ama projeleri oluşturmak senin onayınla/hesabınla olmalı)

## Panel inşası bitince (Faz 2 sonrası, backend'e geçerken)

- [ ] Firebase Console'da **Remote Config** parametrelerini gir (F1-7'deki liste, ilk değerlerle)
- [ ] Test cihazlarına/hesaplarına **manuel custom claim** atama (F1-11 testi için — 3 rolü test etmek için)
- [ ] **RevenueCat** hesabı ve ürün tanımları (Faz 6, salon aboneliği — ödeme değil, salon SaaS aboneliği)
- [ ] **AdMob** hesabı (Faz 6)

## Yayın öncesi (Faz 2 sonu + Faz 7)

- [ ] `flutter build ipa` / `flutter build appbundle` ile **TestFlight / Internal Testing** yüklemesi ve Apple review'a gönderim (F2-10) — build'i ben hazırlarım, mağaza yüklemesi/gönderimi kendi hesabından yapman gerekiyor
- [ ] **Store listing:** Görseller, tanıtım videosu, açıklama metinleri, anahtar kelime optimizasyonu (F7-4)
- [ ] **Google Cloud bütçe alarmı** kurulumu ($10/$25/$100 eşikleri, F7-3)
- [ ] **Final review ve genel lansman** onayı (F7-5)

## Netleştirilmesi gereken sorular (kod yazmaya başlamadan önce cevaplarsan hızlanır)

1. Tasarımda **"Abonelik/Ödeme Yönetimi"** ekranı son halde kaldırılmış ("ödemeler bu sistem üzerinden yürümüyor" notu var) — bunu onaylıyor musun, yoksa geri mi eklensin?
2. Bundle ID / paket adı önerisi: `com.egoragames.egoractive` — onay?
3. F0-5'teki marka rengi ile tasarım paketindeki koyu/mavi tema aynı mı, yoksa ayrı bir karar mı bekliyorsun?
4. Panel inşası sırasında (Faz P) gerçek Firebase bağlantısı yok, tamamen mock veri — bu sırayla (önce tüm UI, sonra tüm backend) ilerlemek istediğini teyit ediyorum, doğru mu?
