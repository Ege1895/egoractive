# Egoractive — Panel Bazlı UI Görev Listesi

Bu doküman, `ios-fitness-app-design-plan` handoff paketindeki (`Egoractive v2.dc.html`, "ikinci yön") **onaylanmış tasarımın** ekran ekran, tek tek Claude Code görevlerine bölünmüş halidir. `Egoractive_Gorev_Listesi.md` (Faz 0-7) ile **çakışmaz, onu tamamlar**: o doküman özellik/backend sırasını verir, bu doküman **UI panellerinin hangi sırayla, tek tek inşa edileceğini** verir.

**Çalışma prensibi:** Bir panel bitmeden bir sonrakine geçilmez. Her panel task'ı bitince: `flutter analyze` temiz, panel simülatörde açılıyor, sonraki panele geçmeden önce bana gösterilip onay alınıyor.

**Kapsam notu:** Tasarımda başlangıçta planlanan "Admin · Abonelik/Ödeme Yönetimi" ekranı son üründen **çıkarılmıştır** ("ödemeler bu sistem üzerinden yürümüyor" notu, Adım 5 başlığında). Bu listede o ekran yok — Faz 6'daki RevenueCat işi (F6-1) ayrı ve ödeme değil, salon aboneliği ile ilgili, mevcut haliyle kalıyor.

**Her panelin ortak kabul kriterleri (tekrar yazılmadı, hepsi geçerli):**
- `CLAUDE.md` §2.3'teki `BasePanel`/`BasePanelState` extend ediliyor, panel `PanelStackController` üzerinden push ediliyor
- Literal `Color(0xFF...)` yok, F1-5'teki tema token'ları (`Theme.of(context).colorScheme.X`) kullanılıyor
- Bu fazda gerçek Firestore bağlantısı yok — mock repository/controller ile gerçekçi Türkçe veri (isim, tarih, tutar) gösteriliyor; "Lorem Ipsum" / "Test User" yasak
- Normal, boş (empty state), yükleniyor, hata durumlarının hepsi ayrı ayrı ele alınıyor
- Küçük ekran (iPhone SE boyutu) ve büyük ekranda taşma yok
- Buton/mesaj metinleri aktif ses ve spesifik (örn. "Kaydedildi", "İşlem başarılı" değil)
- iOS simülatörde (ve mümkünse Android emülatörde) açılıp gezilerek doğrulanmış

---

## FAZ P0 — Panel inşasından önce (önkoşul, bir kez yapılır)

Bunlar `Egoractive_Gorev_Listesi.md`'deki F1-1, F1-2, F1-3, F1-4, F1-5'in **minimum alt kümesi** — panellerin üzerine oturacağı iskelet. Sırayla:

1. **P0-1 — Flutter proje + klasör iskeleti** (= F1-1 + F1-2): Proje kurulumu, paketler, `CLAUDE.md` §5 klasör yapısı, `CLAUDE.md` repo köküne kopyalanır.
2. **P0-2 — `BasePanel` + `PanelStackController`** (= F1-4): Panel push/pop, show/hide yaşam döngüsü, geri tuşu davranışı çalışır durumda olmalı — her panel task'ı bunun üzerine kurulacak.
3. **P0-3 — Tasarım sistemi / UI Kit** (= F1-5, tasarımdaki "Adım 1 — Tasarım Dili Planı" burada koda dökülür): `Egoractive v2.dc.html`'in en üstündeki (dosyanın başı, "Adım 1, ikinci yön" öncesi bölüm — Claude Design'ın kendi tasarım dili planı) renk paleti, tipografi (Outfit başlık + IBM Plex Sans gövde), 8pt grid ve imza görsel öğesini `AppColorScheme` / `AppTypography` / `AppButton` / `AppCard` / `AppLoadingIndicator` bileşenlerine çevir. Koyu tema esas (`#06090D` arka plan, `#05A6FA` primary vurgu) — bunlar `AppColorScheme.defaultScheme()` değerleri olacak, F0-5'teki marka kararlarıyla çelişirse F0-5 önce netleşmeli.
4. **P0-4 — Rol bazlı boş shell + tab bar iskeleti** (F1-11'in UI kısmı, backend/claim kısmı olmadan): 3 rol için alt tab bar'lar (tasarımdaki `adTabsCal` gibi 5 sekmeli yapılar baz alınarak) — her panel bu shell'lerin içine push edilecek.

**Kabul:** Boş bir panel, tab bar içinde, simülatörde açılıp kapanabiliyor; tema token'ları çalışıyor.

---

## FAZ P1 — Ortak Ekranlar (4 panel)

`modules/auth/ui/panels/`

| # | Panel | Prompt özeti | Kabul (ortaklara ek) |
|---|---|---|---|
| P1-1 | **Splash** | Logo animasyonu + arka planda oturum kontrolü simülasyonu (mock: `Future.delayed` ile "kontrol ediliyor" hissi). 1.5-2sn sonra otomatik yönlendirme. | Gerçek cihazda/simülatörde ilk açılış akışı görülüyor |
| P1-2 | **Telefon Numarası Girişi** (`PhoneLoginPanel`) | Numara maskeleme input'u, "Giriş Yap" butonu (numara tamamlanmadan disabled), "Kayıtlı değilim" durumunda gösterilecek yönlendirme metni. | Eksik numarayla buton disabled, tam numarayla enabled |
| P1-3 | **Giriş Bekleniyor / Yükleniyor** | Kod/token bekleme ekranı — `AppLoadingIndicator` + iptal seçeneği. | Loading state F1-5'teki ortak bileşenle |
| P1-4 | **Hesap Silme Onayı** | Geri dönüşü olmadığını net vurgulayan onay diyaloğu (bu adımda sadece UI — gerçek silme F2-8'de). | Onay metni "geri alınamaz" uyarısını taşıyor, yanlışlıkla dokunmaya karşı çift onay (buton + "SİL" yazdırma ya da benzeri) var |

---

## FAZ P2 — Üye Modülü (11 panel)

`modules/sessions/`, `modules/measurements/`, `modules/packages/`, `modules/group_sessions/`, `modules/badges/`, `modules/feedback/` altında ilgili `ui/panels/` — tasarım burada design dilini oturttuğu için önce bu modül bitirilir.

| # | Panel (tasarımdaki adı) | Prompt özeti |
|---|---|---|
| P2-1 | **Üye · Ana Sayfa** | Kalan ders sayısı kartı, sıradaki ders özeti, "son ders hakkı — ödeme zamanı yaklaşıyor" uyarı kartı (koşullu görünür, mock flag ile aç/kapa test edilebilir) |
| P2-2 | **Üye · Derslerim** (Takvim + Liste toggle) | Aynı panelde üstte toggle: takvim görünümü / liste görünümü. Mock ders verisiyle her iki görünüm de dolduruluyor |
| P2-3 | **"Gelecek misin?" Onay Ekranı** | Yaklaşan dersin bilgisi + "Gelicem" / "Gelmeyeceğim" iki büyük buton. Seçim sonrası anında görsel geri bildirim (state değişimi, mock) |
| P2-4 | **Ölçümlerim — Avatar** | Kadın/erkek silüet seçici (`assets/silhouette-erkek-clean.png`, `silhouette-kadin-clean.png` referans), üzerinde tıklanabilir ölçü noktaları (kol, bel, kalça, göğüs) |
| P2-5 | **Ölçümlerim — Grafik** | `fl_chart` ile zaman içindeki değişim grafiği, en az 3 mock veri noktasıyla |
| P2-6 | **Yeni Ölçüm Ekle** | Ölçü noktası bazlı input formu, kaydet butonu (mock: grafiğe/avatara anlık yansır) |
| P2-7 | **Paketim** | Kalan seans sayısı, paketin bitiş tarihi — **fiyat hiçbir yerde gösterilmiyor** (CLAUDE.md kuralı, üyeye fiyat gösterilmez) |
| P2-8 | **Grup Dersleri / Etkinlikler — Keşfet** | Açık ders/etkinlik listesi, her kart üzerinde kontenjan durumu + "Katılıyorum" butonu (dolu olan kontenjanlarda buton disabled/kilitli görünüyor) |
| P2-9 | **Rozetlerim** | Kazanılan rozetlerin vitrin görünümü (grid), henüz kazanılmamış rozetler için soluk/kilitli hal |
| P2-10 | **Geri Bildirim** | Yıldız değerlendirme (1-5) + yorum text alanı formu |
| P2-11 | **Profilim** | Hazır avatar seçici (galeri/kamera ile fotoğraf yükleme **yok** — sadece hazır setten seçim), ad/telefon görüntüleme (salt okunur), çıkış yap |

**Modül sonu kontrolü:** Tüm 11 panel arası `PanelStackController` ile geçiş + tab bar navigasyonu simülatörde uçtan uca gezilip onaya sunulur.

---

## FAZ P3 — Antrenör Modülü (8 panel)

`modules/trainers/`, `modules/sessions/`, `modules/group_sessions/` altında.

| # | Panel | Prompt özeti |
|---|---|---|
| P3-1 | **Ana Sayfa** | Bugünkü dersler saat saat program şeklinde, bekleyen "tamamlandı mı?" onayları rozet/liste olarak |
| P3-2 | **Seans Raporum** | Başlangıç/Bitiş tarih seçiciler, "Kazanılan Prim" kartı (tutar + "Detay" + "Prim Sistemine Git" — bu ikisi bu fazda sadece görsel, hedefsiz), Toplam/Tamamlanan/İptal Edilen Seanslar kartları (Birebir/Grup kırılımlı) |
| P3-3 | **Üyelerim (Liste)** | Sadece bu antrenöre bağlı mock üyeler — çoklu antrenör mock verisiyle "başka antrenörün üyesi görünmüyor" görsel olarak doğrulanabilir hale getirilsin (gerçek izolasyon F2-3/F2-6'da) |
| P3-4 | **Üye Detayı** | Kalan ders, paket bilgisi, ders geçmişi, ölçüm grafiği (P2-5'teki grafik bileşeni tekrar kullanılır — `shared/widgets/` altına taşınmalı) |
| P3-5 | **Takvimim** | Haftalık/aylık takvim görünümü (`table_calendar` paketi) |
| P3-6 | **Ders Tamamlama Onayı** | "Dersi tamamladın mı?" tek dokunuşla işaretleme akışı |
| P3-7 | **Grup Dersi Oluştur** | Kontenjan dahil oluşturma formu (P2-8'deki kontenjan gösterim mantığıyla tutarlı görsel dil) |
| P3-8 | **Ders Onayı Bildirimi Detayı** | Üyenin P2-3'teki "gelicem/gelmeyeceğim" cevabını gösteren mini panel |

---

## FAZ P4 — Admin Modülü, Batch 1: Kurulum + Operasyon Temeli (10 panel)

`modules/gyms/`, `modules/members/`, `modules/trainers/`, `modules/packages/` altında.

| # | Panel | Prompt özeti |
|---|---|---|
| P4-1 | **Salon Oluştur (ilk kurulum)** | Salon adı, adres, telefon + "Salon logosu" ve "Tema rengi" alt adımları (bu ikisi ayrı panel değil, aynı akışın alt ekranları — wizard/step olarak). Tema rengi seçimi F1-6'daki `ThemeController` mock'una yazılır |
| P4-2 | **Admin 1 · Ana Sayfa (Özet Dashboard)** | Bu ayki toplam/tamamlanan/iptal seans oranı, antrenör bazlı performans grafiği, tahmini ciro/gider özeti, "ödeme vakti yaklaşan" üyeler kısa listesi, bekleyen geri bildirim rozeti |
| P4-3 | **Admin 2 · Salon Bilgileri** | Salon bilgilerini düzenleme + "Admin · Temalar" (kayıtlı tema listesi) ve "Admin · Tema Ekle" (yeni tema + "salon logosu kullanılsın mı?" seçeneği) alt ekranları |
| P4-4 | **Admin 3 · Antrenör Yönetimi** | Liste + "Antrenör Ekle" formu (isim, telefon, uzmanlık) |
| P4-5 | **Admin 4 · Üye Listesi** | İsim, bağlı antrenör, kalan ders, paket durumu sütunlu liste + arama/filtre |
| P4-6 | **Admin 5 · Üye Bilgileri** | Tek üyenin detay/düzenleme ekranı |
| P4-7 | **Admin 6 · Yeni Üyelik — Paket** | "Paket Seç" → seçilince otomatik dolan Başlangıç/Bitiş Tarihi, Seans Sayısı, Telafi Seans Sayısı alanları |
| P4-8 | **Admin 7 · Yeni Üyelik — Ödeme** | Üye adı/avatar başlığı, Toplam Tutar / Ödendi / Kalan Ödeme (otomatik hesap) / Son Ödeme Tarihi, "Kaydet". Geri tuşuyla P4-7'ye dönünce veri kaybolmuyor (aynı flow state'i) |
| P4-9 | **Admin 8 · Stüdyo Paketleri** | Paket kartları (ad, ders tipi rozeti Birebir/Grup, süre, seans sayısı, fiyat), sağ üstte "+ Paket Ekle" |
| P4-10 | **Admin 9 · Paket Ekle/Düzenle** | Form — P4-9'daki kart alanlarının tümü düzenlenebilir |

---

## FAZ P5 — Admin Modülü, Batch 2: Takvim, Finans, Kurallar (13 panel)

`modules/sessions/`, `modules/group_sessions/`, `modules/events/`, `modules/expenses/`, `modules/gyms/`, `modules/feedback/`, `modules/notifications/`, `modules/members/` altında.

| # | Panel | Prompt özeti |
|---|---|---|
| P5-1 | **Admin · Aylık Takvim** | Aylık takvim, güne tıklayınca o günün saat çizelgesi, seansa tıklayınca detay bottom-sheet (tasarımdaki `adPopupOpen` popup yapısı — "Seansı ertele" / "Kapat") |
| P5-2 | **Admin 10 · Ders/Seans Yönetimi** | Herhangi bir üyenin/antrenörün dersini görüntüleme, iptal, erteleme — admin için tarih kısıtı yok (24 saat kuralı sadece antrenör/üye'de, F3-3) |
| P5-3 | **Admin 11 · Grup Dersleri** | Oluşturma formu (kontenjan dahil) + kontenjan doluluk göstergeli liste |
| P5-4 | **Admin 12 · Etkinlikler** | Liste + "Admin 13 · Etkinlik Oluştur" formu (lokasyon, tarih/saat, kontenjan) |
| P5-5 | **Admin 14 · Giderler** | Kategori bazlı gider listesi + "Admin 15 · Gider Ekle" formu |
| P5-6 | **Admin 16 · Stüdyo Kuralları (görüntüleme)** | 📌 emoji destekli madde madde kurallar, salt okunur render |
| P5-7 | **Admin 17 · Kuralları Düzenle** | Zengin metin editörü (`flutter_quill`, emoji picker dahil) |
| P5-8 | **Admin 18 · Yetki Ayarları** | "Seans bitimi eğitmene ne zaman hatırlatılsın?" dropdown, "Online Rezervasyon" toggle, "Paket süresi bitince seans oluşturulabilsin mi?" toggle, "Üye seans iptal edebilir" toggle, "Kaydet" |
| P5-9 | **Admin 19 · Geri Bildirimler** | Üye feedback'lerinin listesi (yıldız + yorum) |
| P5-10 | **Admin 20 · Bildirim Gönder** | Hedef seçici (tek üye/tüm salon), başlık, metin, "Gönder" |
| P5-11 | **Admin 21 · Üye Detayı** | Kalan ders, paket bilgisi, ders geçmişi, ölçüm grafiği (P3-4/P2-5 ile aynı bileşen, `shared/` üzerinden tekrar kullanılır) |

---

## Panel inşası bittikten sonra

Faz P0-P5 tamamlanınca uygulama **uçtan uca gezilebilir, tamamen mock veriyle çalışan bir prototip** halinde olur (design tool'daki tıklanabilir prototipin Flutter karşılığı). Bundan sonraki adım `Egoractive_Gorev_Listesi.md`'ye dönüp:

- **Faz 1'in geri kalanı** (F1-6 ThemeController'ın gerçek Firestore'a bağlanması, F1-7 Remote Config, F1-8 Firebase bağlama, F1-9 Cloud Functions, F1-10 telefon girişi gerçek backend, F1-11 rol bazlı yönlendirmenin gerçek custom claim'e bağlanması)
- **Faz 2** (mock verilerin gerçek Firestore okuma/yazmaya çevrilmesi, panel panel — her F2-X görevi artık "sıfırdan ekran yapma" değil "az önce yapılan paneli gerçek veriye bağlama" görevi olur)

şeklinde devam edilir. Yani P-serisi = "nasıl görünüyor", F2+ serisi = "nasıl çalışıyor".
