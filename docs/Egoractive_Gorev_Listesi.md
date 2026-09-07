# Egoractive — Detaylı Görev Listesi (Claude Code Sonnet için)

Bu doküman, `CLAUDE.md`'deki mimari kuralları önkoşul kabul eder — her task'a başlamadan önce Claude Code'un `CLAUDE.md`'yi okumuş olması gerekir. Her görev; **Prompt** (Claude Code'a olduğu gibi verilebilecek talimat) ve **Kabul Kriterleri** (görevin bittiğini doğrulamak için kontrol listesi) içerir.

Sıralama, store review sürecini en hızlı şekilde başlatacak şekilde tasarlanmıştır: Faz 2 sonunda **yayınlanabilir, review'a girebilecek minimum bir sürüm** hazır olur; zengin özellikler bundan sonra eklenir.

---

## FAZ 0 — Hesaplar ve Store Altyapısı
*(Kod yazımından bağımsız, paralel yürütülür — çoğu Claude Code görevi değil, sizin/benim halledeceğim iş)*

### F0-1 — Apple Developer Program hesabı
**Ne yapılacak:** Apple Developer Program'a kayıt (bireysel ya da şirket hesabı — "Egora Games" tüzel kişilik olarak kayıt önerilir, D-U-N-S numarası gerektirir).
**Kabul kriterleri:** Hesap aktif, App Store Connect'e giriş yapılabiliyor.

### F0-2 — Google Play Console hesabı
**Ne yapılacak:** Play Console geliştirici hesabı açılışı (tek seferlik $25 ücret), "Egora Games" geliştirici profili.
**Kabul kriterleri:** Play Console erişimi aktif.

### F0-3 — Boş app kaydı (her iki store'da)
**Ne yapılacak:** App Store Connect ve Play Console'da "Egoractive" adıyla (veya son karara göre) boş app kaydı — bundle ID / package name rezervasyonu (örn. `com.egoragames.egoractive`).
**Kabul kriterleri:** İki store'da da app kaydı görünüyor, bundle ID onaylı.

### F0-4 — Gizlilik Politikası ve Kullanım Şartları
**Ne yapılacak:** Uygulamanın topladığı veri tiplerine göre (telefon no, sağlık/ölçüm verisi, konum yok, push token) bir Gizlilik Politikası ve Kullanım Şartları metni hazırlanır, statik bir sayfada (ör. GitHub Pages veya basit bir Firebase Hosting sayfası) yayınlanır.
**Kabul kriterleri:** Her iki metin de canlı bir URL'de erişilebilir; App Store Connect ve Play Console'daki ilgili alanlara bu URL'ler girilmiş.

### F0-5 — Marka kimliği
**Ne yapılacak:** Logo (app icon dahil), renk paleti (varsayılan/marka teması — salon bazlı temanın "default" değeri olacak), tipografi kararı.
**Kabul kriterleri:** App icon tüm gerekli çözünürlüklerde (iOS/Android) export edilmiş; `CLAUDE.md` §2.4'teki `AppColorScheme` varsayılan değerleri belirlenmiş.

---

## FAZ 1 — Mimari Temel

### F1-1 — Flutter proje kurulumu
**Prompt:** "Yeni bir Flutter projesi oluştur. Riverpod (flutter_riverpod + riverpod_generator), get_it, go_router, freezed + json_serializable paketlerini ekle. `CLAUDE.md` §5'teki klasör yapısını oluştur (boş klasörler + `.gitkeep`). `analysis_options.yaml`'a `flutter_lints` ekle ve strict mode aç (`implicit-casts: false`, `implicit-dynamic: false`)."
**Kabul kriterleri:**
- [ ] `flutter analyze` sıfır hata/uyarı ile geçiyor
- [ ] Klasör yapısı `CLAUDE.md` §5 ile birebir örtüşüyor
- [ ] Boş bir "Hello Egoractive" ekranı iOS simülatör ve Android emülatörde açılıyor

### F1-2 — `CLAUDE.md` dosyasının repoya eklenmesi
**Prompt:** "Ekteki `CLAUDE.md` dosyasını repo kök dizinine koy. İçeriğini oku ve bundan sonraki her görevde bu kurallara uyacağını teyit et."
**Kabul kriterleri:** Dosya repo kökünde, `.gitignore`'da hariç tutulmuyor.

### F1-3 — Modüler klasör iskeleti + örnek modül
**Prompt:** "`CLAUDE.md` §2.1'deki modül şablonunu kullanarak `modules/auth/` modülünü iskelet olarak oluştur: `controller/auth_controller.dart` (boş bir Riverpod Notifier), `service/auth_service.dart` (boş sınıf), `repository/auth_repository.dart` (boş interface + impl), `domain/auth_user.dart` (freezed model), `ui/panels/` (boş). Bu yapıyı diğer tüm modüller için şablon olarak dokümante et (`docs/module_template.md`)."
**Kabul kriterleri:**
- [ ] `modules/auth/` tüm alt klasörleriyle mevcut
- [ ] `docs/module_template.md` yeni bir modül eklerken izlenecek adımları listeliyor
- [ ] Controller'da hiçbir yerde `BuildContext` import edilmiyor (CLAUDE.md §2.2 kontrolü)

### F1-4 — `BasePanel` ve `PanelStackController`
**Prompt:** "`CLAUDE.md` §2.3'teki spesifikasyona göre `core/panels/base_panel.dart` (abstract `BasePanel` + `BasePanelState`) ve `core/panels/panel_stack_controller.dart` (Riverpod `Notifier<List<BasePanel>>`) sınıflarını yaz. `PanelStackController`: `push`, `pop`, `popToRoot` metodları; panel değişiminde eski panelin `onPanelHide()`, yenisinin `onPanelShow()` metodunu tetiklemeli. Sistem geri tuşunu yakalamak için kök widget'ı `PopScope` ile sarmalayan bir `PanelStackView` widget'ı yaz — `onBackRequested()` `false` dönerse `pop()` çağrılsın. 3 dummy panel ile (A→B→C push, geri tuşuyla C→B→A) manuel test edilebilir bir demo ekle."
**Kabul kriterleri:**
- [ ] `BasePanel`/`BasePanelState` `CLAUDE.md`'deki imzayla birebir uyumlu
- [ ] Push/pop sırasında show/hide callback'leri doğru sırada tetikleniyor (unit test ile kanıtlanmış)
- [ ] Sistem geri tuşu `Navigator.pop` değil `PanelStackController.pop()` çağırıyor
- [ ] Demo: 3 panel arası geçiş + geri tuşu simülatörde çalışıyor

### F1-5 — Tasarım sistemi / UI Kit
**Prompt:** "`shared/theme/` altında `AppColorScheme` (freezed, primary/secondary/background/surface/onSurface/error alanlarıyla), `AppTypography` (başlık/gövde/caption text style'ları) tanımla. F0-5'te belirlenen varsayılan renkleri `AppColorScheme.defaultScheme()` olarak sabitle. Temel bileşen kütüphanesini oluştur: `AppButton` (primary/secondary/text variant), `AppTextField`, `AppCard`, `AppLoadingIndicator` — hepsi `Theme.of(context)` üzerinden renk okusun, literal `Color()` kullanmasın."
**Kabul kriterleri:**
- [ ] Kod tabanında (bileşen dosyaları hariç) hiçbir yerde `Color(0xFF...)` literal yok
- [ ] Bir Storybook/widgetbook benzeri demo ekranında tüm bileşenler görüntülenebiliyor

### F1-6 — Dinamik tema mimarisi (`ThemeController`)
**Prompt:** "`core/theme/theme_controller.dart`: Riverpod `AsyncNotifier<AppColorScheme>`. Aktif salonun `gyms/{gymId}` dokümanındaki `themeColors` alanını dinler (henüz gerçek Firestore bağlı değilse mock repository ile), değiştiğinde `AppColorScheme`'i günceller ve `MaterialApp`'e yayar. Salon değişmeden önce `AppColorScheme.defaultScheme()` kullanılsın."
**Kabul kriterleri:**
- [ ] Mock veri değiştiğinde uygulama teması canlı olarak (hot reload gerektirmeden) değişiyor
- [ ] Salon yokken varsayılan tema düzgün render ediliyor

### F1-7 — Remote Config kurulumu
**Prompt:** "Firebase projesine `firebase_remote_config` paketini ekle. `core/remote_config/remote_config_service.dart` yaz: init'te fetch+activate, tip-güvenli getter'lar (`getInt`, `getBool`, `getString`, `getDouble`) — her getter, RC'de tanım yoksa aşağıdaki varsayılanlardan okusun. İlk parametre setini tanımla: `sessionReminderMinutesBefore` (varsayılan 60), `defaultGroupSessionCapacity` (varsayılan 6), `feedbackReminderDayOfMonth` (varsayılan -1 = ayın son günü), `freeVersionAdsEnabled` (varsayılan true), `featureFlags` (JSON, başlangıçta boş obje)."
**Kabul kriterleri:**
- [ ] Firebase Console'da Remote Config'te bu parametreler tanımlı
- [ ] Uygulama internetsiz açıldığında bile varsayılan değerlerle çökmeden çalışıyor
- [ ] `RemoteConfigService` dışında hiçbir yerde `FirebaseRemoteConfig.instance` çağrılmıyor

### F1-8 — Firebase proje bağlama + temel Security Rules
**Prompt:** "`flutterfire configure` ile projeyi Firebase'e bağla (dev ve prod olmak üzere 2 ayrı Firebase projesi — `egoractive-dev`, `egoractive-prod`). `firestore.rules` dosyasında: kimliği doğrulanmamış hiçbir isteğe izin verme, her koleksiyon için `role` ve `gymId` bazlı temel iskelet kurallar (şimdilik kısıtlayıcı — sonraki fazlarda genişletilecek)."
**Kabul kriterleri:**
- [ ] `firebase emulators:start` ile local emülatörde Firestore + Auth çalışıyor
- [ ] Kimliksiz bir istek reddediliyor (emulator testinde doğrulanmış)
- [ ] dev/prod ortam ayrımı `--dart-define=ENV=dev|prod` ile yapılabiliyor

### F1-9 — Cloud Functions projesi kurulumu
**Prompt:** "`functions/` altında TypeScript Cloud Functions projesi başlat (`firebase init functions`, TypeScript seçili). `CLAUDE.md` §5'teki `src/triggers`, `src/scheduled`, `src/callable`, `src/shared` klasörlerini oluştur. `src/shared/firestore-paths.ts` içinde tüm koleksiyon yollarını fonksiyon olarak tanımla (örn. `sessionsCollection()`, `userDoc(uid)`) — hiçbir yerde ham string path yazılmasın. ESLint + Prettier kur."
**Kabul kriterleri:**
- [ ] `npm run build` hatasız derleniyor
- [ ] `firebase deploy --only functions --dry-run` (veya emulator) başarılı
- [ ] Örnek bir "hello world" callable function emulator'da çağrılabiliyor

### F1-10 — Telefon girişi: client akışı + Custom Token callable function
**Prompt:** "Backend: `functions/src/callable/request-custom-token.ts` — telefon numarası parametre olarak gelir, `users` koleksiyonunda bu numarayla eşleşen kayıt aranır, varsa `admin.auth().createCustomToken(uid)` ile token üretilip dönülür, yoksa açık bir hata kodu dönülür. Client: `modules/auth/` içinde telefon numarası giriş ekranı (`PhoneLoginPanel`, `BasePanel`'den türetilmiş) + `AuthController` bu callable'ı çağırıp `signInWithCustomToken` yapar."
**Kabul kriterleri:**
- [ ] Kayıtlı bir numarayla giriş başarılı, Firebase Auth oturumu açılıyor
- [ ] Kayıtsız numarada anlamlı hata mesajı gösteriliyor
- [ ] Fonksiyon, rastgele numara denemelerine karşı basit bir rate-limit içeriyor (aynı numaradan dakikada N istek)

### F1-11 — Rol bazlı yönlendirme iskeleti
**Prompt:** "`core/router/app_router.dart` (go_router): oturum açan kullanıcının Firebase Auth custom claim'indeki `role` alanına göre (`admin`/`trainer`/`member`) 3 ayrı boş shell ekrana yönlendir. `PanelStackController` her shell için ayrı bir stack tutsun (rol değişince stack sıfırlanmalı)."
**Kabul kriterleri:**
- [ ] 3 farklı test kullanıcısıyla (manuel custom claim atanmış) giriş yapıldığında doğru boş ekrana düşülüyor
- [ ] Custom claim yoksa/geçersizse kullanıcı login ekranına geri atılıyor

---

## FAZ 2 — Yayınlanabilir İlk Sürüm
*(Hedef: mümkün olan en kısa sürede TestFlight/Internal Testing'e ve review'a girmek)*

### F2-1 — Admin: Salon oluşturma ekranı
**Prompt:** "`modules/gyms/` modülünü oluştur (CLAUDE.md şablonuna göre). `CreateGymPanel`: salon adı, adres, telefon input'ları + logo yükleme (Cloud Storage) + F1-5'teki `AppColorScheme` seçici (basit bir renk paleti picker'ı). Kaydet'e basınca `gyms/{gymId}` dokümanı oluşturulur, oluşturan kullanıcıya `admin` custom claim + `gymId` claim'i bir Cloud Function (F2-5) ile atanır."
**Kabul kriterleri:**
- [ ] Salon oluşturma formu validasyonlu (boş alan bırakılamaz)
- [ ] Logo Cloud Storage'a yükleniyor, Firestore'da `logoUrl` olarak saklanıyor
- [ ] Oluşturma sonrası kullanıcı otomatik admin olarak yönlendiriliyor

### F2-2 — Admin: Üye ekleme + üye listesi
**Prompt:** "`modules/members/` modülü. `AddMemberPanel`: isim + telefon numarası formu — kaydedince `users` koleksiyonunda `role: member`, `gymId`, `trainerId` (henüz boş/atanmamış) alanlarıyla doküman oluşur. `MemberListPanel`: aktif salonun üyelerini isim + kalan ders (şimdilik 0/placeholder) ile listeler."
**Kabul kriterleri:**
- [ ] Yeni üye eklendiğinde listede anında görünüyor (Firestore stream ile)
- [ ] Aynı telefon numarası iki kez eklenemiyor (validasyon)

### F2-3 — Antrenör: Üyelerim listesi + basit takvim görünümü
**Prompt:** "`modules/trainers/` modülü. `MyMembersPanel`: sadece `trainerId == currentUid` olan üyeleri listeler (Security Rules ile de garanti altına al — F2-6). `MyScheduleePanel`: `table_calendar` paketiyle boş bir haftalık takvim iskeleti (henüz gerçek seans verisi yok, F3'te dolacak)."
**Kabul kriterleri:**
- [ ] Antrenör A, antrenör B'nin üyelerini hiçbir koşulda göremiyor (hem UI hem Security Rules testiyle doğrulanmış)

### F2-4 — Üye: Ana sayfa + Derslerim listesi (iskelet)
**Prompt:** "`modules/sessions/` modülünün iskeleti + `MemberHomePanel` (kalan ders sayısı placeholder, sıradaki ders placeholder) + `MySessionsPanel` (boş liste, "henüz dersin yok" empty state)."
**Kabul kriterleri:** Üye rolüyle girişte bu iki panel arası `PanelStackController` ile geçiş çalışıyor.

### F2-5 — Custom Claims atama Cloud Function
**Prompt:** "`functions/src/triggers/on-user-role-assigned.ts`: `users/{uid}` dokümanına `role`/`gymId` yazıldığında/güncellendiğinde tetiklenen bir Firestore trigger — `admin.auth().setCustomUserClaims(uid, {role, gymId})` çağırır. Ayrıca F2-1'deki salon oluşturma akışında admin ataması için de bu trigger'ın tetiklendiğini doğrula."
**Kabul kriterleri:**
- [ ] `users` dokümanındaki `role` değişince, kullanıcının bir sonraki token yenilemesinde custom claim güncel
- [ ] Trigger, sonsuz döngüye girmiyor (kendi yazdığı alanı tekrar tetiklemiyor)

### F2-6 — Security Rules genişletmesi (Faz 2 kapsamı)
**Prompt:** "`firestore.rules`'ı genişlet: `gyms/{gymId}` — sadece o gymId'nin admin'i yazabilir, kimliği doğrulanmış herkes okuyabilir (kendi gymId'si için). `users/{uid}` — admin kendi salonundaki herkesi okuyabilir/yazabilir, antrenör sadece `trainerId == request.auth.uid` olanları okuyabilir, üye sadece kendi dokümanını okuyabilir."
**Kabul kriterleri:**
- [ ] Firebase emulator ile yazılmış en az 8 test case'i geçiyor (her rol için pozitif + negatif senaryo)

### F2-7 — Push bildirim altyapısı uçtan uca örnek
**Prompt:** "`firebase_messaging` + `flutter_local_notifications` client'a eklensin. `modules/notifications/` — cihaz açıldığında/token yenilendiğinde `users/{uid}.fcmTokens` alanına token eklenir (array union). Backend: `functions/src/scheduled/session-reminder-check.ts` — F1-7'deki `sessionReminderMinutesBefore` RC değerine göre 15 dakikada bir çalışan bir scheduled function; şimdilik gerçek seans verisi olmadığı için mock/dummy bir seans dokümanı ile uçtan uca test edilsin: bildirim member'ın cihazına gerçekten düşüyor mu?"
**Kabul kriterleri:**
- [ ] Fiziksel/emulator cihazda push bildirimi görülüyor
- [ ] Bildirime tıklanınca doğru panel'e (mock) yönleniyor

### F2-8 — Hesap silme akışı
**Prompt:** "Apple'ın zorunlu kıldığı hesap silme akışı: Üye/Antrenör/Admin profil ekranında 'Hesabımı Sil' butonu → onay diyaloğu → callable function (`functions/src/callable/delete-account.ts`) kullanıcının Auth kaydını ve Firestore'daki kişisel verilerini siler (salon verisi admin'e ait olduğu için silinmez, sadece kullanıcı-özel veri)."
**Kabul kriterleri:**
- [ ] Silme sonrası kullanıcı tekrar aynı numarayla giriş yapamıyor (yeniden eklenmesi gerekiyor)
- [ ] App Store inceleme rehberindeki "account deletion" gereksinimini karşılıyor

### F2-9 — Uygulama ikonu, splash screen, ilk store görselleri
**Prompt:** "F0-5'teki logo ile `flutter_launcher_icons` ve `flutter_native_splash` paketlerini yapılandır, iOS/Android için ikon setlerini üret."
**Kabul kriterleri:** Her iki platformda da doğru ikon ve splash görünüyor.

### F2-10 — TestFlight / Internal Testing + review'a gönderim
**Prompt (insan görevi, Claude Code'a kod görevi değil):** İlk build'i `flutter build ipa` / `flutter build appbundle` ile üretip TestFlight ve Play Console Internal Testing'e yükleyin, Apple review'a gönderin.
**Kabul kriterleri:** Build her iki platformda da işleniyor (processing tamamlandı), review'a gönderilmiş durumda.

---

## FAZ 3 — Temel Operasyonel Akışlar
*(Review beklenirken paralel geliştirilir)*

### F3-1 — Paket tanımlama ekranı
**Prompt:** "`modules/packages/` modülü. `PackageListPanel` + `CreatePackagePanel`: paket adı, ders tipi (birebir/grup), süre (gün), seans sayısı, fiyat. `packages/{packageId}` koleksiyonu."
**Kabul kriterleri:** Admin paket oluşturup listede görebiliyor; fiyat alanı üye rolündeki hiçbir sorguya dahil edilmiyor (CLAUDE.md — üyeye fiyat gösterilmeyecek kuralına referans).

### F3-2 — Yeni üyelik oluşturma (2 adımlı satış akışı)
**Prompt:** "`CreateMembershipFlowPanel` — 2 adımlı: Adım 1 paket seçimi (seçilince başlangıç/bitiş tarihi + seans sayısı otomatik dolar), Adım 2 ödeme bilgisi (toplam tutar, ödenen, kalan ödeme otomatik hesaplanır, son ödeme tarihi). `memberPackages/{id}` dokümanı oluşturulur."
**Kabul kriterleri:** Akış PanelStackController üzerinde iki panel arası geçiş yapıyor (geri tuşu Adım 2'den Adım 1'e dönüyor, veri kaybolmuyor).

### F3-3 — Ders/seans CRUD
**Prompt:** "`sessions/{sessionId}` — oluşturma, iptal, erteleme. Admin için deadline yok (herhangi bir tarihte düzenleyebilir), antrenör/üye için Security Rules'ta 24 saat kuralı (RC'den `cancellationDeadlineHours` okunarak, varsayılan 24) uygulanır."
**Kabul kriterleri:** 24 saatten yakın iptal denemesi üye/antrenör için reddediliyor, admin için her zaman izinli.

### F3-4 — "Gelecek misin?" scheduled Cloud Function
**Prompt:** "F2-7'deki scheduled function'ı gerçek `sessions` koleksiyonuna bağla: `startTime`'ı `now + sessionReminderMinutesBefore` penceresinde olan, `confirmationRequested: false` seansları bulup push gönderir, `confirmationRequested: true` yapar. Client: bildirime tıklayınca `SessionConfirmationPanel` açılır, 'Gelicem'/'Gelmeyeceğim' butonları `sessions/{id}.memberConfirmation` alanını günceller."
**Kabul kriterleri:** Gerçek bir test seansıyla uçtan uca çalışıyor; aynı seans için bildirim iki kez gitmiyor.

### F3-5 — Ders tamamlama onayı (antrenör) + tetikleyici Cloud Function
**Prompt:** "Scheduled function: `endTime`'ı geçmiş, `status: scheduled` kalan seanslar için antrenöre push. Client: `SessionCompletionPanel` — tek dokunuşla `status: completed` yapar, ilgili üyenin `remainingSessions` alanını bir transaction ile 1 azaltır."
**Kabul kriterleri:** `remainingSessions` azaltma işlemi transaction içinde (race condition'a karşı korumalı).

### F3-6 — Yetki Ayarları ekranı
**Prompt:** "`modules/gyms/` içine `GymSettingsPanel` ekle: hatırlatma süreleri, online rezervasyon aç/kapa, paket süresi bitince seans oluşturulabilsin mi, üye seans iptal edebilir mi — bu değerler `gyms/{gymId}` dokümanında saklanır (salon bazlı override), okunurken önce bu doküman kontrol edilir, yoksa F1-7'deki global RC varsayılanına düşülür."
**Kabul kriterleri:** Bir salonda ayar değiştirildiğinde diğer salonları etkilemiyor.

---

## FAZ 4 — Zengin Özellikler ve UX Cilası

### F4-1 — Ölçüm takibi (avatar + grafik)
**Prompt:** "`modules/measurements/`. Kadın/erkek silüet SVG'leri üzerinde tıklanabilir ölçü noktaları (kol, bel, kalça, göğüs). `fl_chart` ile zaman içindeki değişim grafiği. `measurements/{uid}/entries/{entryId}` alt koleksiyonu."
**Kabul kriterleri:** En az 3 farklı tarihli veri girildiğinde grafik doğru trend çiziyor.

### F4-2 — Grup dersleri
**Prompt:** "`modules/group_sessions/`. Kontenjan dolum mantığı `runTransaction` ile (CLAUDE.md §... örneğindeki gibi) — `attendeeIds` array'ine ekleme kontenjanı aşarsa hata fırlatır. Katılım/ayrılma 1 gün öncesine kadar açık, sonra UI'da kilitli görünür (RC: `groupSessionLockHoursBefore`)."
**Kabul kriterleri:** Eşzamanlı 10 istekle yapılan yük testinde kontenjan asla aşılmıyor.

### F4-3 — Etkinlikler
**Prompt:** "`modules/events/` — F4-2'deki grup dersi kontenjan mantığının aynısı, farklı domain modeliyle (lokasyon + tarih/saat alanları ek)."
**Kabul kriterleri:** Kod tekrarını önlemek için kontenjan mantığı `shared/` altında ortak bir `CapacityService` olarak çıkarılmış olmalı.

### F4-4 — Rozet / gamification sistemi
**Prompt:** "`modules/badges/`. Scheduled function: her gün çalışıp düzenli katılım / paket bazlı rozet kriterlerini (RC'den okunan eşiklerle) kontrol eder, hak edilen rozetleri `users/{uid}.badges` array'ine ekler. Client: `MyBadgesPanel`."
**Kabul kriterleri:** Rozet kriterleri kodda değil RC'de tanımlı (yeni rozet eklemek için store güncellemesi gerekmiyor).

### F4-5 — Stüdyo Kuralları (zengin metin + emoji editörü)
**Prompt:** "`flutter_quill` ile `GymRulesEditorPanel` (sadece admin) ve `GymRulesViewPanel` (herkes). `gyms/{gymId}.rulesContent` (Quill Delta JSON)."
**Kabul kriterleri:** Emoji ekleme, kalın/italik biçimlendirme çalışıyor; üye/antrenör tarafında salt-okunur render doğru.

### F4-6 — Admin tema özelleştirme ekranı
**Prompt:** "F1-6'daki `ThemeController`'ı kullanan bir `GymThemeEditorPanel`: renk paleti seçici + logo silüeti seçimi, kaydedince `gyms/{gymId}.themeColors` güncellenir ve tüm aktif client'larda anlık yansır (stream tabanlı)."
**Kabul kriterleri:** Değişiklik, uygulamayı yeniden başlatmadan diğer cihazlarda görünüyor.

---

## FAZ 5 — Raporlama, LiveOps ve İş Zekası

### F5-1 — Admin dashboard grafikleri
**Prompt:** "`modules/reports/` — `AdminDashboardPanel`: toplam/tamamlanan/iptal seans oranı, antrenör bazlı performans (`fl_chart` bar chart), tahmini ciro/gider özeti. Firestore aggregation query'leri (mümkünse `count()` aggregation, büyük veri setlerinde tüm dokümanları client'a çekmeden)."
**Kabul kriterleri:** 10.000+ seans kaydı olan bir test verisinde dashboard 2 saniyenin altında yükleniyor.

### F5-2 — Haftalık salon/muhasebe raporu (scheduled Cloud Functions + mail)
**Prompt:** "Firebase 'Trigger Email' extension'ını kur. `functions/src/scheduled/weekly-gym-report.ts`, `weekly-accounting-report.ts` — her Pazartesi 06:00'da (RC: `weeklyReportDayOfWeek`, `weeklyReportHour`) çalışır, ilgili haftanın verisini toplar, HTML e-posta şablonuyla `mail` koleksiyonuna yazar (extension otomatik gönderir)."
**Kabul kriterleri:** Test ortamında admin salon ve admin muhasebe maili doğru alıcılara, doğru veri kapsamıyla gidiyor.
**Not (F5-12):** Bu task orijinalinde `weekly-trainer-report.ts` (antrenöre kendi haftalık özetini gönderen ayrı bir mail) da içeriyordu — F5-12 kararıyla kaldırıldı, rapor mailleri artık sadece admin'e gidiyor.

### F5-3 — Giderler ekranı
**Prompt:** "`modules/expenses/` — kategori bazlı gider girişi, F5-1'deki dashboard'a kâr/zarar özeti olarak entegre."
**Kabul kriterleri:** Gider kategorileri RC'den okunuyor (yeni kategori eklemek kod değişikliği gerektirmiyor).

### F5-4 — Feedback sistemi + aylık özet raporu
**Prompt:** "`modules/feedback/` — yıldız + yorum. Scheduled function: RC'deki `feedbackReminderDayOfMonth` değeri (-1 = ayın son günü) geldiğinde tüm üyelere push. Ayrı bir scheduled function ayın son günü admin'e özet mail atar."
**Kabul kriterleri:** Ayın son günü hesaplaması (28/29/30/31 gün farkları) doğru çalışıyor.

### F5-5 — Remote Config feature flag paneli (LiveOps kontrolü)
**Prompt:** "Bu bir Claude Code görevi değil — Firebase Console'da RC'nin kendi arayüzü kullanılacak. Bunun yerine: koddaki her feature flag kontrol noktasının merkezi bir `FeatureFlags` sınıfında toplandığından emin ol (`core/remote_config/feature_flags.dart`) — kod içinde dağınık `remoteConfigService.getBool('...')` çağrıları yerine `featureFlags.isGroupSessionsEnabled` gibi isimlendirilmiş getter'lar."
**Kabul kriterleri:** Yeni bir feature flag eklerken tek bir dosya (`feature_flags.dart`) değişiyor.

### F5-6 — Analytics event taksonomisi
**Prompt:** "`core/analytics/analytics_service.dart` — tüm event isimlerini enum olarak topla (`AnalyticsEvent.sessionCompleted` vb.), ham string event adı hiçbir yerde geçmesin. En az şu event'leri instrumente et: üyelik oluşturma, ders tamamlama, ders iptali, paket satın alma, feedback gönderme."
**Kabul kriterleri:** Firebase Analytics DebugView'da tüm event'ler doğru parametrelerle görünüyor.

### F5-7 — Rapor snapshot veri modeli (mail ve app'in ortak veri kaynağı)
**Prompt:** "`functions/src/scheduled/weekly-gym-report.ts` hesapladığı özet veriyi (toplam/tamamlanan/iptal seans, tahmini ciro, gider, net, antrenör bazlı performans) HTML mail'e yazmadan önce ayrıca `gyms/{gymId}/reportSnapshots/{docId}` koleksiyonuna yazsın — `docId` periyot + tarih içersin (ör. `weekly_2026-01-19`), doküman `{ period: 'weekly'|'monthly', periodStart, periodEnd, ...F5-1'deki DashboardReport alanlarının aynısı }` şeklinde olsun. Amaç: mail ve F5-9'daki Raporlar ekranı aynı hesaplamayı iki kez yapmasın, tek gerçek kaynaktan (bu snapshot) beslensin. PDF üretimi yok — sadece yapılandırılmış veri."
**Kabul kriterleri:** Bir hafta sonu gönderilen mail ile aynı hafta için Firestore'a yazılan snapshot dokümanındaki sayılar birebir eşleşiyor.

### F5-8 — Aylık salon raporu scheduled function'ı
**Prompt:** "`functions/src/scheduled/monthly-gym-report.ts` — RC'deki `monthlyReportDayOfMonth` (-1 = ayın son günü) ve `monthlyReportHour` değerlerinde çalışır, o ayın verisini `weekly-gym-report.ts` ile aynı mantıkla (F5-7'deki ortak hesaplama/snapshot yazma kodu paylaşılarak — `functions/src/shared/` altına çıkarılmalı) hesaplar; hem HTML mail atar hem `period: 'monthly'` snapshot'ı yazar."
**Kabul kriterleri:** Ay sonunda tetiklenince o ayın toplam verisiyle hem mail hem snapshot doğru oluşuyor; ayın 28/29/30/31 gün farkları doğru hesaplanıyor.

### F5-9 — Raporlar ekranı: haftalık/aylık filtre + geçmiş rapor listesi
**Prompt:** "`AdminDashboardPanel`'i genişlet: üstte haftalık/aylık toggle filtre, altında seçilen periyoda ait `reportSnapshots` dokümanlarının tarih sıralı listesi (ör. '13-19 Ocak', 'Ocak 2026'). Listeden bir öğeye dokununca, panelin metrik kartları + antrenör performans bar chart'ı canlı aggregation yerine seçilen snapshot dokümanının verisiyle render edilsin — mevcut `DashboardReport` domain modeli ve UI bileşenleri (`_MetricCard`, `_TrainerPerformanceChart`) yeniden kullanılsın, yeni bir görüntüleyici yazılmasın. Üstteki 'bugünkü özet' görünümü (F5-1) ile geçmiş bir snapshot görüntüleme durumu net şekilde ayrılsın (başlıkta seçili periyodun tarihi görünsün)."
**Kabul kriterleri:** Geçmiş bir haftayı/ayı seçince o periyodun sayıları görünüyor, güncel (canlı) özetle karıştırılmıyor; liste boşsa (henüz hiç snapshot yoksa) anlamlı bir boş durum mesajı gösteriliyor.

### F5-10 — Snapshot'tan cihaz üzerinde (client-side) PDF dışa aktarma
**Prompt:** "`pdf` ve `printing` paketlerini ekle. F5-9'daki snapshot detay görünümüne 'PDF olarak dışa aktar/paylaş' butonu ekle — buton, o an ekranda gösterilen metrik ve antrenör performans verisinden **cihazda** bir PDF üretip sistem paylaş sayfasını açar. Sunucu tarafında (Cloud Functions) hiçbir PDF üretimi yapılmaz — maliyet ve bakım yükü bu yüzden tercih edilmedi (bkz. proje kararı notu)."
**Kabul kriterleri:** Butona dokununca sistem paylaş/kaydet sheet'i açılıyor; üretilen PDF'te metrik kartları ve antrenör dökümü doğru ve okunabilir görünüyor; işlem tamamen cihazda gerçekleşiyor (network isteği yok).

> **Karar notu (2026-08-27):** Rapor sistemi için "her hafta/ay otomatik PDF üretip mail'e ekleme" yaklaşımı yerine bu dört task'taki hibrit model seçildi — tek gerçek kaynak olarak yapılandırılmış veri (`reportSnapshots`), e-posta HTML olarak kalır, in-app ekran bu veriden native render eder, PDF sadece istenirse cihazda üretilir. Gerekçe: sunucu tarafı PDF üretimi (Puppeteer/headless Chrome) yüksek bellek/cold-start maliyeti getirir ve çoğu otomatik üretilen PDF hiç açılmaz; büyük SaaS ürünlerinin (Stripe, Mixpanel, Mindbody/Zenoti vb.) izlediği desen de budur.

### F5-11 — Salon rapor mailini zengin template'e taşı (grafik/emoji/UX)
**Prompt:** "`weekly-gym-report.ts`/`monthly-gym-report.ts`'in HTML gövdesini, mock verilerle onaylanan tasarıma göre yeniden yaz (`functions/src/shared/report-email-template.ts`, tek template hem haftalık hem aylık için). Bölümler: (1) toplam/tamamlanan/iptal ders + segment bar + yüzdeler, (2) antrenör bazlı tamamlanan/iptal/toplam + kendi mini bar'ı, en çok tamamlayana göre sıralı, ilk 3'e madalya, (3) dönem içinde satın alınan paketler `packageName`'e göre gruplanıp satış adedine göre sıralı (`memberPackages.purchasedAt` aralığı), (4) dönem içinde üyelerin ödediği toplam tutar (`memberPackages.paidAmount` toplamı — zaten F5-1'de var), (5) dönem içindeki toplam giderler (`expenses.amountTl` toplamı — zaten F5-1'de var), (6) gelir-gider net farkı, (7) dönem içindeki toplam grup dersi + etkinlik sayısı, bu ikisinin toplam kontenjanı ve toplam KATILAN kişi sayısı (kapasite değil — `attendeeIds.length`, `groupSessions`/`events` dokümanları düşük hacimli olduğundan doğrudan okunuyor, bkz. `report-extras-stats.ts`). Grafikler e-posta istemcileri (Gmail/Outlook) yüzünden SVG/Canvas değil, tablo hücre genişliğine dayalı ('email-safe bar chart') teknikle çizilir."
**Kabul kriterleri:** Mock önizlemedeki tüm 7 veri bloğu gerçek Firestore verisiyle doğru hesaplanıyor; haftalık ve aylık mail birebir aynı template'i kullanıyor (sadece tarih aralığı/sayılar farklı).

### F5-12 — Antrenör haftalık rapor mailini kaldır
**Prompt:** "`functions/src/scheduled/weekly-trainer-report.ts`'i ve `index.ts`'teki export'unu sil. Rapor mailleri (haftalık + aylık) artık SADECE admin'e (`gyms/{gymId}.reportEmails.gym`) gidiyor — antrenöre ayrı bir özet mail yok."
**Kabul kriterleri:** `weekly-trainer-report.ts` repoda yok, `functions/src/index.ts`'te ilgili export yok, antrenöre hiçbir otomatik rapor maili gitmiyor.

### F5-13 — Rapor maili yerelleştirme (salonun saat dilimine göre tr/en)
**Prompt:** "Rapor mailinin dili, alıcının cihaz diline değil salonun `gyms/{gymId}.timeZone`'una göre seçilsin — `Europe/Istanbul` ise Türkçe, değilse İngilizce (`notification-locale.ts`'teki `resolveNotificationLocale`, push bildirimlerinde zaten kullanılan aynı desen). `report-email-template.ts`'teki tüm metinler (başlıklar, buton, tarih aralığı formatı) `locale` parametresine göre iki dilde de tanımlansın."
**Kabul kriterleri:** Türkiye dışı bir `timeZone`'a sahip mock bir salon için gönderilen mail tamamen İngilizce, İstanbul için Türkçe geliyor; tarih aralığı formatı da dile göre değişiyor ("17 Ağustos 2026" / "August 17, 2026").

### F5-14 — Rapor mailinden uygulamaya derin bağlantı (deep link)
**Prompt:** "Mail'deki 'Uygulamada Gör' butonu `egoractive://reports` özel URL şemasını açsın. `ios/Runner/Info.plist`'e `CFBundleURLTypes` (`egoractive` şeması), `android/.../AndroidManifest.xml`'e `android.intent.action.VIEW` intent-filter (`scheme=egoractive`) ekle. `app_links` paketiyle `core/deep_links/app_deep_link_service.dart` — gelen `egoractive://reports` linkini dinler, `currentRoleProvider` ile admin olduğunu doğrulayıp `PanelStackController` üzerinden `AdminDashboardPanel`'i açar (admin değilse sessizce yok sayılır — `push_notification_service.dart`'taki aynı yaklaşım). `main.dart`'ta `PushNotificationService` ile aynı yerde, aynı try/catch güvenliğiyle başlatılır."
**Kabul kriterleri:** Uygulama kapalıyken/arka plandayken/açıkken `egoractive://reports` linkine dokununca uygulama açılıp doğrudan Raporlar paneline gidiyor; admin olmayan bir hesapta link sessizce yok sayılıyor (crash/permission-denied hatası yok).

### F5-15 — Rapor e-postasını tek alana indir, ayrı muhasebe maili/kaydet butonunu kaldır
**Prompt:** "F5-11'deki zengin rapor maili ciro/gider/net'i zaten içerdiğinden `weekly-accounting-report.ts` (ayrı bir muhasebe özeti maili) artık gereksiz — sil, `index.ts`'teki export'unu kaldır. `GymInfoPanel`'deki 'RAPOR E-POSTALARI' bölümünü tek alana indir: 'Muhasebe raporu e-postası' input'unu ve o karttaki ayrı 'Rapor e-postalarını kaydet' butonunu kaldır. `ReportRecipients` domain modelinden `accountingReportEmail`'i sil. Panelin en altındaki genel 'Kaydet' butonu artık salon bilgileri + tema + logo ile birlikte bu tek rapor e-postasını da kaydetsin (`_save()` akışına ekle, geçersiz e-postada genel kaydetme hatası olarak göster)."
**Kabul kriterleri:** Salon Bilgileri ekranında tek bir 'Rapor e-postası' alanı var, ayrı bir kaydet butonu yok; en alttaki 'Kaydet'e basınca hem profil hem rapor e-postası tek seferde kaydediliyor; `gyms/{gymId}.reportEmails.gym` boşsa hem haftalık hem aylık rapor fonksiyonu o salonu atlıyor (F5-11/F5-13'teki davranış korunuyor).

### F5-16 — Salon oluşturma ekranına opsiyonel rapor e-postası
**Prompt:** "`GymSetupPanel`'e (F2-9 salon kurulum akışı) 'Rapor e-postası (opsiyonel)' kartı ekle — kısa bir açıklama ('haftalık/aylık özet bu adrese gönderilir, sonra da eklenebilir') + tek bir e-posta alanı. Zorunlu değil, boş bırakılırsa salon yine sorunsuz oluşturulur (F5-15'teki davranışla aynı: boşsa rapor fonksiyonları o salonu atlar). `CreateGymService.createGym`/`CreateGymController.submit` ve `signup-gym-admin.ts` callable'ı bu opsiyonel değeri `reportEmails.gym` olarak `gyms/{gymId}`'e yazsın (`timeZone`'daki `optionalNonEmptyString` deseniyle aynı)."
**Kabul kriterleri:** Alan boş bırakılıp 'Salonu oluştur'a basıldığında salon hatasız oluşuyor ve `gyms/{gymId}.reportEmails` alanı hiç yazılmıyor; alan doldurulduğunda `gyms/{gymId}.reportEmails.gym` doğru değerle oluşuyor ve GymInfoPanel'de aynı e-posta önceden dolu görünüyor.

### F5-17 — Admin üye detayına "Paketi Yenile" butonu (Yeni Üyelik sihirbazının 2-3. adımlarını yeniden kullan)
**Prompt:** "`AdminMemberDetailPanel`e, ödeme durumu kartının altına 'Paketi Yenile' butonu ekle. Mevcut paketin borcu (`detail.paymentDueTl`) sıfır değilse buton pasif olsun, altında bunu açıklayan bir not görünsün — yeni paket, öncekinin borcu kapanmadan tanımlanamaz. Tıklanınca Yeni Üyelik sihirbazının 1. adımı (üye bilgileri) ATLANIR, doğrudan `NewMembershipPackagePanel`e (2. adım) geçilir — `MemberRegistrationController`e mevcut üyeyi paket akışının yazma hedefi olarak işaretleyen bir `beginRenewal(memberId)` eklendi (`isRenewal` bayrağı). Bu bayrak sayesinde 2/3. adımlardaki 'Vazgeç' ve kaydetme-sonrası yönlendirme, tüm sihirbazı sıfırlayan `popToRoot()` yerine sadece kendi eklenen adımlarını kapatıp (`pop()`) üye detayına döner. `NewMembershipController.save(memberId)` zaten yeniden kullanılabilir haldeydi (yeni bir `memberPackages` dokümanı yazıyor) — değişiklik gerekmedi. 'Güncel paket' kavramı zaten `purchasedAt`'e göre en son dokümanla temsil edildiğinden (bkz. `_latestPackageForMemberProvider`/`watchLatestPackageDoc`), üyenin kendi ekranı da otomatik olarak sadece yeni paketin taksitlerini gösterir — eski paketin verisi ayrıca filtrelenmesine gerek kalmadan artık okunmuyor."
**Kabul kriterleri:** Borcu olan bir üyede buton pasif ve uyarı notu görünür; borcu biten bir üyede buton aktif, tıklanınca doğrudan paket seçim ekranına gidiyor (üye bilgileri adımı hiç görünmüyor); ödeme adımında kaydedince admin üye detayına dönüyor (sihirbazın kökten sıfırlandığı ana ekrana değil) ve yeni taksit planını gösteriyor.
> **Not:** Araştırma sırasında `PackageController` (üyenin kendi "Paketim" ekranı) `memberPackages` koleksiyonunu doğrudan sorguluyor, ama `firestore.rules`'taki `memberPackages` okuma kuralı sadece `admin` rolüne izin veriyor — üye kendi taksitlerini görmeye çalıştığında bu muhtemelen `permission-denied` ile başarısız oluyor (bu task'ın kapsamı dışında, ayrı bir hata/task olarak ele alınmalı, burada dokunulmadı).

### F5-18 — Deep link soğuk başlangıçta giriş akışıyla yarışıp kilitleniyordu (fix)
**Prompt:** "Rapor mailindeki 'Uygulamada Gör' butonuyla uygulama kapalıyken açılınca: admin zaten oturum açmış olsa bile giriş ekranı görünüyor, giriş denemesi hiç bitmiyordu (uygulama kapatılıp yeniden açılınca sorunsuz giriş yapılmış oluyordu). Kök neden: `AppDeepLinkService`, `main()` içinde `runApp()`'tan ÖNCE `currentRoleProvider.future`'ı bekliyordu — bu, Firebase Auth'un kalıcı oturumu geri yüklemesini bloklarcasına bekleyip uygulamanın kendi `appAccessProvider` tabanlı giriş/erişim akışıyla (bkz. `app_access.dart`'taki 'Çmt Saloon' kilitlenme notu) yarışıyordu. Fix: ilk link'in işlenmesi artık `await` edilmiyor (arka planda `unawaited`), `runApp()` hiçbir zaman deep link'i beklemiyor; `_handle` artık ayrı bir `currentRoleProvider` okuması yapmıyor, uygulamanın UI'ının da beklediği AYNI `appAccessProvider`'ı bekleyip `ready` + admin olduğunda push ediyor."
**Kabul kriterleri:** Uygulama tamamen kapalıyken rapor mailindeki linke dokununca, admin zaten oturum açıksa doğrudan (giriş ekranı hiç görünmeden) Raporlar paneline gidiyor; oturum yoksa normal giriş akışı hiç bozulmadan çalışıyor.

### F5-19 — "Paketi Yenile" akışında isim/`memberId` sıfırlanıyordu (fix)
**Prompt:** "F5-17'nin ödeme adımında üyenin adı yerine '?' avatarı görünüyor, Kaydet'e basınca sessizce hiçbir şey olmuyordu (`memberId` null olduğu için). Kök neden: `newMemberControllerProvider`/`memberRegistrationControllerProvider` (`autoDispose`) — normal Yeni Üyelik akışında 1. adım ekranı (`MemberInfoPanel`) bunları sürekli `ref.watch` edip stack'te kaldığından canlı kalıyorlar; 'Paketi Yenile' 1. adımı atladığı için `_startRenewal`'in `ref.read` ile yazdığı değerler, 2. adım ekranı ilk kez izlemeye başlamadan önceki boşlukta Riverpod tarafından siliniyordu. Fix: `AdminMemberDetailPanel` (sihirbaz boyunca stack'te kalan tek ekran) artık bu iki provider'ı da `ref.watch` ediyor, boşluk kapandı."
**Kabul kriterleri:** Paketi Yenile ile paket seçilip ödeme adımına geçildiğinde üyenin adı/soyadı başlıkta doğru görünüyor, Kaydet'e basınca paket gerçekten kaydedilip üye detayına dönülüyor.

### F5-20 — Raporlar ekranı geri dönüşte eski veriyi gösteriyordu (fix)
**Prompt:** "Admin bir üyenin taksit ödeme durumunu değiştirip Raporlar ekranına dönünce ciro hâlâ eski değeri gösteriyordu; ayrıca 'Geçmiş Raporlar' listesi bazen sonsuza kadar yükleniyor gibi takılı kalıyordu. Kök neden: `PanelStackController` panelleri hiç dispose etmiyor (`Visibility(maintainState: true)`) — Raporlar ekranı arka planda gizliyken bile `DashboardReportController`/`ReportSnapshotController`'ın altındaki `autoDispose` provider'lar hâlâ izlendiği için hiç yeniden tetiklenmiyor, ilk açılıştaki veride donup kalıyordu. Fix: `AdminDashboardPanel`, `onPanelShow()` içinde (ekran her ön plana geldiğinde — ilk açılış dahil) her iki controller'ın `retry()`'ını çağırıp canlı özeti ve geçmiş rapor listesini elden tazeliyor."
**Kabul kriterleri:** Bir üyenin ödeme durumu değiştirilip Raporlar ekranına dönüldüğünde ciro/gider güncel değeri gösteriyor; Geçmiş Raporlar listesi ekran her açıldığında yeniden denenip (varsa geçici bir hata durumundan) kurtulabiliyor.
> **Ek not (aynı gün):** `onPanelShow` düzeltmesi canlı özeti çözdü ama "Geçmiş Raporlar" hâlâ sonsuza kadar dönüyordu — ikinci, daha derin bir bağlanma hatası vardı: `ReportSnapshotController.build()` sadece seçili `ReportPeriod`'u tutuyordu, asıl veriyi (`_snapshotsForGym` family provider'ı) SADECE getter'lar (`snapshots`/`isLoading`/`hasError`) izliyordu. Veri yüklenip bittiğinde controller'ın KENDİ çıktısı (`ReportPeriod`) değişmediğinden, Riverpod `_PastReportsSection` widget'ını (bu controller'ı izleyen) hiç yeniden tetiklemiyordu — widget sonsuza dek İLK (loading) durumda donuk kalıyordu. Fix: family provider public'e çevrilip (`reportSnapshotsForGymProvider`) `_PastReportsSection` bunu DOĞRUDAN `ref.watch` ediyor; controller artık sadece filtre state'i + `retry()` sağlıyor.

### F5-21 — PDF export'u mail template'iyle birebir aynı yap (WIP — yarım kaldı)
**Prompt:** "Export edilen PDF (`report_pdf_export_service.dart`) eski hali basit tablo bordürlü görünüyordu, F5-11'deki zengin mail template'i (`report-email-template.ts`) kadar güzel değildi. Kullanıcı: 'mail templatinin birebir aynısını yap geliştir.'"
**Durum (2026-08-27 itibarıyla):** Kod tarafı TAMAMLANDI, doğrulama/teslim adımları YARIM KALDI. Bir sonraki oturum şuradan devam etmeli:
1. Yapılanlar: `report_pdf_export_service.dart` sıfırdan yeniden yazıldı — mail template'indeki aynı renk paleti (`COLOR` map hex değerleri), header/hero banner, ders özeti segmented bar + legend, grup dersleri & etkinlikler doluluk bölümü, antrenör performans satırları, satılan paketler (sıralı, madalya yerine "1./2./3." numaralandırma), mali özet (ciro/gider bar + net kâr/zarar kutusu) — `pw.MultiPage` + `pw.Row`/`pw.Expanded`/`flex` ile (tablo hack'i gerekmiyor, PDF tek render motoru). Emoji/madalya bilinçli olarak KULLANILMADI (gömülü font emoji glifi içermiyor, boş kutu olarak görünürdü) — bu, "birebir aynı" isteğinden bilinçli/gerekçeli bir sapma.
   Domain modelleri güncellendi: `TrainerPerformance.cancelledSessions`, yeni `ReportPackageSale`/`ReportOccupancy` sınıfları, `ReportSnapshot.packages/groupSessions/events`. `report_snapshot_service.dart` Firestore parse'ı güncellendi. `remote_config_service.dart` + `remoteconfig.template.json`'a ~27 yeni ikili (TR/EN) RC key eklendi (`reportsPdf*`), 3 ölü key kaldırıldı. `report_snapshot_detail_panel.dart`'ın `_exportPdf()`'i yeni 29 alanlı `ReportPdfLabels`'ı dolduracak + `gymName` (`gymProfileControllerProvider`'dan) geçecek şekilde güncellendi.
   `flutter analyze` (hem modül bazlı hem tam) TEMİZ — sadece bu oturumun başından beri var olan 5 ilgisiz info-seviye lint var (create_gym_service.dart:52, member_registration_service.dart:88-89, subscription_panel.dart:97,191).
2. Yapılmayanlar (sırayla):
   - `flutter test` çalıştırılmadı (bu değişiklik için).
   - Görsel/runtime doğrulama yapılmadı — bir smoke-test taslağı yazılmıştı (scratchpad'de, session'a özel, kalıcı değil) ama çalıştırılmadan kesildi: `TestWidgetsFlutterBinding.ensureInitialized()` + mock `ReportSnapshot`/`ReportPdfLabels` ile `ReportPdfExportService().buildPdf(...)` çağırıp byte sayısını ve (varsa) sayfalama/overflow exception'ı olup olmadığını doğrulamak gerekiyor.
   - `dart format` değişen dosyalara uygulanmadı (uygulanınca ilgisiz dosyalarda hash-only değişiklik çıkabilir — established practice: `git diff --stat` kontrol edip ilgisizleri `git checkout --` ile geri al).
   - Git commit/push yapılmadı — mevcut çalışma ağacında commit edilmemiş halde duruyor.
   - `firebase deploy --only remoteconfig` yapılmadı (yeni ~27 RC key için).
   - `flutter build ios --debug --no-codesign` yapılmadı ("hazırla" adımı, kullanıcı henüz istemedi).
**Kabul kriterleri:** Export edilen PDF, mail template'iyle aynı renk/bölüm/bar-chart görünümünde (emoji hariç); `flutter test` yeşil; commit + push yapılmış; RC deploy edilmiş; kullanıcı "hazırla" dediğinde iOS build hazır.

---

## FAZ 6 — Monetizasyon ve Çoklu Salon SaaS

### F6-1 — RevenueCat entegrasyonu
**Prompt:** "`purchases_flutter` paketini ekle, RevenueCat dashboard'unda aylık/yıllık salon aboneliği ürünlerini tanımla. `modules/subscription/` — `SubscriptionController` RevenueCat webhook'unu (Cloud Function ile) dinleyip `gyms/{gymId}.subscriptionStatus` alanını günceller."
**Kabul kriterleri:** Sandbox ortamında satın alma → webhook → Firestore güncellemesi uçtan uca test edilmiş.

### F6-2 — AdMob entegrasyonu
**Prompt:** "`google_mobile_ads` — `subscriptionStatus != active` olan salonların üyelerinde banner reklam gösterilir (F1-7'deki `freeVersionAdsEnabled` RC flag'iyle de global olarak kapatılabilir)."
**Kabul kriterleri:** Abone salon reklam görmüyor, ücretsiz salon görüyor; RC flag kapatıldığında hiç kimse görmüyor.

### F6-3 — Çoklu salon onboarding akışı
**Prompt:** "Yeni bir salonun sisteme kaydolma akışını uçtan uca gözden geçir (F2-1'den beri var olan akış) — trial süresi (RC: `trialDurationDays`), trial bitince kısıtlama davranışı."
**Kabul kriterleri:** Trial süresi dolan bir salon admin'i, yazma işlemlerinde net bir "aboneliğini yenile" uyarısı görüyor.

### F6-4 — Admin manuel bildirim gönderme (callable function)
**Prompt:** "`functions/src/callable/send-manual-notification.ts` — admin, hedef (tek üye/tüm salon) + başlık + metin gönderir, fonksiyon ilgili FCM token'lara push atar. Client: `SendNotificationPanel`."
**Kabul kriterleri:** Kötüye kullanımı önlemek için rate-limit var (aynı admin'den saatte N bildirim).

---

## FAZ 7 — Sertleştirme ve Genel Lansman

### F7-1 — Security Rules kapsamlı testi
**Prompt:** "`@firebase/rules-unit-testing` ile her koleksiyon için pozitif + negatif test matrisi yaz (3 rol × her koleksiyon). Özellikle antrenör-üye izolasyonu ve fiyat alanının üyeye asla dönmediğini test et."
**Kabul kriterleri:** Rules coverage raporu tüm koleksiyonları kapsıyor, tüm testler yeşil.

### F7-2 — Performans/yük testi
**Prompt:** "10.000 üye / 100.000 seans içeren bir seed script yaz (`scripts/seed_load_test_data.ts`), F5-1 dashboard ve F2-2 üye listesi ekranlarının bu ölçekte performansını ölç."
**Kabul kriterleri:** Kritik ekranlar 3 saniyenin altında ilk render'a ulaşıyor.

### F7-3 — Cloud Functions monitoring/alarm kurulumu
**Prompt:** "Google Cloud Console'da bütçe alarmı ($10/$25/$100 eşiklerinde). Cloud Functions için Crashlytics/Cloud Logging tabanlı hata alarmı — bir scheduled/trigger function art arda 3 kez hata verirse admin'e (geliştirici) mail."
**Kabul kriterleri:** Bilinçli olarak tetiklenen bir test hatası, alarm mailini gerçekten üretiyor.

### F7-4 — Store listing'in tam hali
**Prompt (insan görevi):** Görseller, tanıtım videosu, App Store/Play Store açıklama metinleri, anahtar kelime optimizasyonu.
**Kabul kriterleri:** Her iki store listing'i de "yayınlanmaya hazır" durumda.

### F7-5 — Final review ve genel lansman
**Prompt (insan görevi):** Production build, son review gönderimi, yayına alma.
**Kabul kriterleri:** Uygulama her iki store'da da canlı ve indirilebilir.

---

## FAZ 8 — Global Telefon Numarası Desteği

Şu an tüm telefon inputları (`shared/utils/phone_number_formatter.dart`'taki `TrPhoneNumberInputFormatter`, RC metinlerindeki literal "+90") Türkiye'ye hardcoded. Karar: `phone_form_field` paketi (Google'ın libphonenumber metadata'sının saf Dart portu — native platform bağımlılığı yok, gerçek bölgesel doğrulama + ülke seçici widget hazır geliyor). Telefon her yerde **E.164** formatında (`+<ülke kodu><numara>`) saklanacak. Riskin en yüksek olduğu auth/login akışı önce, sonra iletişim telefon formları — tek seferde her yeri değiştirmemek için kademeli.

### F8-1 — Ortak `AppPhoneField` bileşeni (altyapı, henüz hiçbir ekranda kullanılmıyor)
**Prompt:** "`phone_form_field` paketini ekle. `shared/widgets/app_phone_field.dart` — `PhoneFormField`'ı sarmalayan, projenin `AppTextField` görsel dilinde (renk/köşe/tipografi `AppColorScheme`/`AppTypography`'den) bir bileşen. Varsayılan ülke `TR`, `onChanged` E.164 (`PhoneNumber.international`) döndürsün. Henüz hiçbir ekrana bağlanmasın — sadece bileşen + component showcase'e örnek."
**Kabul kriterleri:** `component_showcase_panel.dart`'ta bileşen görülebiliyor, ülke seçici açılıp aranabiliyor, yazarken TR için "532 418 76 05" gibi canlı formatlanıyor.

### F8-2 — Telefonla giriş (hesap arama) akışını E.164 + ülke seçiciye taşı
> **Düzeltme notu:** Bu görev ilk yazıldığında "telefon girişi = SMS OTP" varsayılmıştı — YANLIŞ. Gerçek mimari (`phone_login_panel.dart`'ın kendi doc comment'i, Egoractive Authentication Sistemi §2/§8): **tek authentication yöntemi email OTP'dir, SMS hiçbir yerde kullanılmıyor.** Telefon numarası sadece `startLogin(identifierType: 'phone', value: ...)` Cloud Function'ıyla hesabı BULMAK için bir kimlik alanı — telefonla girişte bile doğrulama kodu her zaman `result.email!`'e gidiyor (`OtpVerificationPanel`). Asıl risk SMS deliverability değil, backend'in E.164 telefon eşleştirmesi.
**Prompt:** "`phone_login_panel.dart` artık `AppPhoneField` kullanıyor (bugünkü hardcoded '+90' + `TrPhoneNumberInputFormatter` satırları kaldırılıyor). `AuthController.setPhoneDigits`/`startLogin`, `auth_repository.dart`, `auth_service.dart` tam E.164 numarayla çalışacak şekilde güncellensin. `functions/src/callable/start-login.ts` — `identifierType: 'phone'` geldiğinde artık `+90` varsaymadan, gelen E.164 numarayı olduğu gibi Firestore'daki kayıtlı telefonla eşleştirmeli (bu dosyanın bugün nasıl eşleştirdiği önce incelenmeli — muhtemelen bir normalizasyon/canonicalization adımı var, o adım TR'ye özel olabilir). RC'deki literal '+90' içeren metinler varsa `{phone}` zaten tam E.164 içerecek şekilde güncellensin."
**Kabul kriterleri:** TR dışında bir ülke kodu seçilip (gerçek bir test hesabıyla) telefonla giriş başlatıldığında hesap doğru bulunuyor ve e-postaya OTP gidiyor (SMS YOK — bu bir email teslim testi); mevcut TR kullanıcıların girişi bozulmamış; `email_login_panel.dart`/`EmailSetupPanel` akışına dokunulmuyor (kapsam dışı).

### F8-3 — Mevcut Firestore telefon kayıtlarını E.164'e migrate et ✅ (koda alındı)
> **Kapsam düzeltmesi:** F8-2 sırasında incelenince tek canonical login-kimliği alanının `users/{uid}.phoneNumber` olduğu netleşti (`members`/`trainers` alt koleksiyonlarındaki `phone` alanları sadece görüntüleme amaçlı ayrı kopyalar — F8-4 kapsamında) — migration'ın kapsamı sadece `users` koleksiyonuna daraltıldı.
**Prompt:** "`functions/src/scripts/migrate-phone-e164.ts` — `users` koleksiyonundaki mevcut çıplak (prefiksiz, TR varsayılan) `phoneNumber` alanlarına `+90` prepend edip E.164'e çevirsin (idempotent — zaten `+` ile başlayanlara dokunmaz). Migration bitene kadar okuma tarafında prefiksiz kayıtlar için TR fallback bırakılsın (geçiş penceresi güvenliği)."
**Yapılanlar:** `functions/src/shared/phone-lookup.ts` — `findUserByPhone()`/`phoneLookupCandidates()` ortak fallback helper'ı (E.164 bulunamazsa eski çıplak TR halini dener); `start-login.ts`, `check-phone-available.ts`, `signup-gym-admin.ts`'in telefon eşleştirme/çakışma kontrolü hepsi bu helper'a taşındı. `migrate-phone-e164.ts` — `--dry-run` destekli, batch'li (400/batch), idempotent migration script'i; `npm run migrate:phone-e164` ile çalıştırılıyor.
**Kabul kriterleri:** ✅ Migration script'i Firestore emulator'da 5 senaryoyu (çıplak TR, zaten E.164 TR, zaten E.164 yabancı, telefonsuz, ikinci çıplak TR) kapsayan seed veriyle test edildi — `--dry-run` doğru sayıları raporladı, gerçek çalıştırma sonrası tüm kayıtlar `+90`/E.164 ile doğrulandı, ikinci çalıştırmada 0 migrasyon (idempotent) doğrulandı. `phoneLookupCandidates()` için 4 birim testi (`phone-lookup.test.ts`) geçiyor. **Production'da manuel onaylı tek seferlik çalıştırma henüz yapılmadı** — bu insan kararı gerektiren bir adım.

### F8-4 — İletişim telefon formlarını `AppPhoneField`'a geçir ✅
> **Kapsam genişlemesi:** Uygulanırken doküman'da listelenmeyen 5 ekran/dosya daha aynı `TrPhoneNumberInputFormatter`/`formatTrPhoneDigits` desenini kullandığı ortaya çıktı — hepsi kapsama alındı: `trainer_info_panel.dart`/`trainer_profile_controller.dart` (antrenörün kendi profili — `member_self_info_panel.dart`'ın birebir eşi), `profile_panel.dart`/`admin_member_detail_panel.dart`/`admin_trainer_detail_panel.dart`/`trainer_member_detail_panel.dart` (salt-okunur gösterim yerleri).
**Prompt:** "Üye (`member_info_panel.dart`), antrenör (`admin_trainer_management_panel.dart`), salon (`gym_setup_panel.dart`, `gym_info_panel.dart`) gibi ekranlardaki telefon alanları `AppPhoneField`'a geçirilsin. Eski `TrPhoneNumberInputFormatter` artık hiçbir yerden çağrılmıyorsa kaldırılsın."
**Yapılanlar:** Toplam 9 UI dosyası (4 doküman'da listelenen + 5 keşfedilen) + 4 controller (`new_member_controller`, `member_profile_controller`, `trainer_profile_controller`, `gym_profile_controller`) `phoneDigits`/TR-varsayımlı alanlardan `phoneE164`/`isPhoneValid`'e geçirildi. `shared/utils/phone_number_formatter.dart` (TrPhoneNumberInputFormatter + formatTrPhoneDigits + formatTrPhoneDisplay) tamamen silindi — hiçbir yerden çağrılmıyordu.
**Kabul kriterleri:** ✅ Listelenen + keşfedilen tüm ekranlarda ülke seçici çalışıyor, kaydedilen değer E.164; `flutter analyze` temiz, `flutter test` 127/128 (kalan 1 hata pre-existing, bu işten bağımsız doğrulandı).

### F8-5 — Son seçilen ülkeyi hatırlama + ülke ismi TR lokalizasyonu (nice-to-have)
**Prompt:** "`AppPhoneField`, cihazda son seçilen ülkeyi (basit local storage) hatırlasın — her seferinde TR'den başlamak zorunda kalınmasın. `phone_form_field`'ın ülke isimleri sadece İngilizce geldiğinden, uygulama dili TR iken ülke seçici listesinde Türkçe isim gösterecek bir çeviri katmanı eklensin (RC'ye taşımaya gerek yok — ISO kod → TR isim eşlemesi build-time sabit)."
**Kabul kriterleri:** Uygulama TR dilindeyken ülke seçicide "Türkiye", "Almanya" gibi Türkçe isimler görünüyor; ikinci girişte son seçilen ülke hatırlanıyor.

---

## FAZ 9 — Global Para Birimi Desteği

**Kullanıcıyla netleşen kararlar (bunlara göre geliştirilecek):**
1. **Para birimi salon (gym) seviyesinde bir ayar** — `gyms/{gymId}.currency` (ISO 4217 kodu, örn. `"TRY"`). Bir salonun TÜM üyeleri/antrenörleri/raporları hep aynı para biriminde. Telefon numarasındaki ülke koduna paralel bir tasarım — `timeZone`/`themeColors` gibi zaten var olan salon-seviyesi alan pattern'iyle aynı yerde yaşıyor.
2. **Para birimi SADECE salon kurulurken (`gym_setup_panel.dart`) seçilir, sonradan DEĞİŞTİRİLEMEZ.** `gym_info_panel.dart`'ta salt-okunur gösterilir, düzenleme UI'ı YOK. Gerekçe: dönüşüm/kur mantığı yok (bilinçli karar — "salon kendi kazandığını/giderini kendi para biriminde girer, karşılaştırır", çapraz kur hesaplama ihtiyacı yok), para birimi değişirse geçmiş raporlar anlamsızlaşır.
3. **Firestore alan adları DEĞİŞMİYOR** (`priceTl`, `amountTl`, `estimatedRevenueTl`, `totalExpensesTl`, `netTl` vb. `Tl` son eki aynen kalıyor) — isim yanıltıcı olsa da alan adı değişikliği + Firestore veri taşıma maliyeti/hata riski gereksiz bulundu. Sayının hangi para biriminde olduğu artık salonun `currency` alanından okunuyor, alan adından değil.
4. **Desteklenecek para birimi listesi (B seçeneği — küratörlü ~30 kod, TRY sabit ilk sırada):**
   `TRY, USD, EUR, CAD, GBP, CHF, SEK, NOK, DKK, PLN, CZK, AED, SAR, QAR, KWD, ILS, AZN, GEL, KZT, RON, BGN, RSD, AUD, NZD, JPY, SGD, HKD, MXN, BRL, ZAR, EGP, INR, RUB`
   Format kuralları (sembol/ondalık ayracı/basamak sayısı) `intl` paketinin `NumberFormat.simpleCurrency(name: code)`'undan otomatik geliyor — biz kendi tablomuzu tutmuyoruz, sadece kod listesi + TR/EN görünen isim gerekiyor. Liste ileride tek satır eklemekle genişletilebilir (format zaten hazır).

### F9-1 — Para birimi metadata'sı + ortak `AppMoneyFormatter`/`AppMoneyInputFormatter`
**Prompt:** "`lib/core/constants/currency_constants.dart` — yukarıdaki 33 kodluk sabit liste (`const List<String> supportedCurrencyCodes`, TRY index 0/sabit ilk sırada) + kod→TR/EN görünen isim eşlemesi (`const Map<String, String> currencyNameTr/currencyNameEn` — RC'ye TAŞINMAZ, build-time sabit, CLAUDE.md §2.5 kapsamında 'iş kuralı' değil 'sabit katalog' sayılır). `lib/core/money/app_money_formatter.dart` — `intl` paketinin `NumberFormat.simpleCurrency(name: currencyCode, locale: locale)`'unu saran, `formatMoney(int amountMinorOrWhole, String currencyCode, String locale)` fonksiyonu. `AppMoneyInputFormatter` — para girişi yapılan `AppTextField`'larda kullanılacak, seçili para biriminin ondalık/basamak kuralına göre canlı formatlayan bir `TextInputFormatter` (bugünkü `ThousandsInputFormatter`'ın yerine geçecek, TL'ye özel değil)."
**Kabul kriterleri:** `formatMoney(50000, 'USD', 'en')` → `$50,000.00` benzeri, `formatMoney(50000, 'TRY', 'tr')` → `₺50.000,00` benzeri doğru locale kurallarıyla çıkıyor (JPY gibi 0 ondalıklı para birimlerinde de doğru); component showcase'e örnek eklendi. Birim testleri en az 5 farklı para birimi/locale kombinasyonunu kapsıyor.

### F9-2 — Salon oluşturma ekranına para birimi seçici (kilitli, sonradan değiştirilemez)
**Prompt:** "`gym_setup_panel.dart`'a aranabilir bir para birimi seçici eklensin (TRY varsayılan/sabit ilk sırada, F9-1'deki 33 kodluk liste, F8'deki ülke seçiciyle aynı UI ailesi — arama, tek seçim). `create_gym_controller.dart`/`create_gym_service.dart`, seçilen `currency` kodunu `gyms/{gymId}.currency` alanına yazacak şekilde güncellensin. `gym_info_panel.dart`'ta para birimi salt-okunur bir satır olarak gösterilsin (etiket + kod, örn. 'Para birimi: USD ($)') — düzenleme/kaydetme UI'ı KESİNLİKLE eklenmesin, bu bilinçli bir kısıtlama."
**Kabul kriterleri:** Yeni salon oluştururken USD/EUR gibi TRY dışı bir para birimi seçilip kaydedildiğinde Firestore'da `gyms/{gymId}.currency` doğru yazılıyor; `gym_info_panel.dart`'ta bu alana dokunacak hiçbir buton/input yok.

### F9-3 — Mevcut tüm para gösterim/giriş noktalarını `AppMoneyFormatter`'a geçir
**Prompt:** "Aktif salonun `currency`'sini (`gymProfileControllerProvider`/`activeGymIdProvider` üzerinden, `theme_controller.dart`'taki pattern gibi) okuyup F9-1'deki formatter'ı kullanan TÜM ekranlar: paket fiyatı (`studio_packages_panel.dart`, `edit_studio_package_panel.dart`, paket oluşturma), üye ödeme/taksit ekranları (`new_membership_payment_panel.dart`, `edit_member_payment_panel.dart`, `admin_member_detail_panel.dart`), gider ekranı (`add_expense_panel.dart`, gider listesi), dashboard özet kutuları (`admin_dashboard_panel.dart`, `ReportFinanceSummaryCard`). Hardcoded '₺' sembolü geçen HİÇBİR yer kalmayacak — hepsi `formatMoney` üzerinden. Eski `ThousandsInputFormatter` artık hiçbir yerden çağrılmıyorsa `shared/utils/thousands_input_formatter.dart` silinsin."
**Kabul kriterleri:** `grep -rn "₺" lib/` (veya benzeri) sonuç döndürmüyor (hardcoded RC metinleri hariç, onlar F9-4'te); `flutter analyze`/`flutter test` temiz; TRY dışı bir para biriminde kurulmuş bir salonda tüm bu ekranlar o para biriminin sembolüyle doğru gösteriyor.

### F9-4 — Rapor maili + PDF export'u salonun para birimine göre formatla
**Prompt:** "`functions/src/shared/report-email-template.ts` ve `report_pdf_export_service.dart` artık salonun `currency` alanını okuyup (email için gym doc'undan, PDF için `gymProfileControllerProvider`'dan) F9-1'deki formatlama mantığının TS/Dart eşdeğerini kullanacak. `writeReportSnapshot` (`report-snapshots.ts`) artık raporun yazıldığı andaki `currency` kodunu da snapshot dokümanına kaydetsin (gelecekte para birimi kilidinin kaldırılması ihtimaline karşı tarihsel doğruluk için) — `ReportSnapshot` domain modeline (`report_snapshot.dart`) ve `report_snapshot_service.dart` parse'ına da eklensin. RC'deki literal '₺'/'TL' içeren metinler (varsa) `{currency}` yer tutucusuna çevrilsin."
**Kabul kriterleri:** USD para biriminde bir salon için tetiklenen haftalık/aylık rapor maili ve PDF export'u `$` sembolüyle doğru gösteriyor; Firestore'daki `reportSnapshots/{id}.currency` alanı doğru yazılıyor.

### F9-5 — Mevcut salonlara varsayılan `currency: "TRY"` migration
**Prompt:** "Tek seferlik bir Cloud Function/script (`functions/src/scripts/`, F8-3'teki telefon migration'ıyla aynı desende) — `gyms` koleksiyonunda `currency` alanı olmayan tüm dokümanlara `currency: 'TRY'` yazsın. Client tarafında da `currency` alanı boş/eksik gelirse `'TRY'` fallback'i (migration tamamlanana kadar güvenlik ağı) tutulsun."
**Kabul kriterleri:** Migration script'i staging/emulator'da çalıştırılıp tüm mevcut salonların `currency: "TRY"` aldığı doğrulanmış; production'da manuel onaylı tek seferlik çalıştırma planı var.

---

## FAZ 10 — Performans: Açılış ve İşlem Sürelerini Düşürme

**Problem tespiti (2026-09-02, gerçek production ölçümleriyle doğrulandı):**
Gerçek cihazda mobil veriyle login ~1,5-2 dk, salon listesi ~1 dk, salon oluşturma ~1 dk sürüyordu. Kök sebepler:
1. **Bölge:** Firestore + Functions + Storage üçü de `us-central1` (Iowa). Türkiye'den her round-trip'te ~200-220 ms (Avrupa'ya göre 2 kat). *(Bu fazın kapsamı DIŞINDA — ayrı bir migration projesi, bkz. aşağıdaki not.)*
2. **Cold start:** Hiçbir fonksiyonda `minInstances` yok, hepsi scale-to-zero. **Her Cloud Function ayrı bir Cloud Run servisi** olduğu için birini ısıtmak diğerini ısıtmıyor — kullanıcının dokunduğu her yeni fonksiyon ayrı cold start yaşıyor. Ölçülen: `startLogin` 18 sn, `listPartnerGyms` 16 sn, `signupGymAdmin` 5 sn.
3. **`runApp()` blokajı:** UI, 7 ardışık `await` (biri 255 KB'lık Remote Config fetch, biri FCM token kaydı) bitene kadar hiç çizilmiyor.
4. **Ardışık round-trip'ler:** `appAccess` zinciri 4 adımı sırayla bekliyor.

**Maliyet notu:** Bu fazdaki TÜM görevler **ücretsizdir** (aylık gider yaratmaz). Ölçüm: 1 salon/10 antrenör/130 üye ve 10 salon/100 antrenör/1300 üye senaryolarında Firestore/Functions kullanımı ücretsiz kotanın sırasıyla ~%12 ve ~%120'si (aşım ~$0,20/ay). Aylık gider yaratacak tek seçenek `minInstances` (~$8/fonksiyon/ay) — **bilinçli olarak bu fazın dışında bırakıldı**, önce ücretsiz optimizasyonlar yapılıp ölçülecek.

**Hedeflenen hızlar (F10-1 ölçümü bu tabloyu doldurup doğrulayacak):**

| Akış | Şu an (mobil, bildirilen) | Hedef | Hangi görev |
|---|---|---|---|
| Uygulama açılış → ilk kare | 5-12 sn | **< 1,5 sn** (uçak modunda: anında) | F10-2 → ✅ **ULAŞILDI: 457 ms** (temiz kurulumda 61.645 ms → 457 ms, bkz. ölçüm tablosu) |
| Login → OTP ekranı | 20-120 sn | **3-10 sn** (soğuk) / **1-2 sn** (sıcak) | F10-4 + F10-2 |
| Anlaşmalı Salonlar listesi | ~60 sn | **3-10 sn** (soğuk) / **1-2 sn** (sıcak) | F10-4 |
| Login → ana ekran | 1-2 sn | **0,5-1 sn** | F10-3 |
| Seans oluşturma | ~60 sn | **1-3 sn** | F10-2 (dolaylı) — ⚠️ bkz. not |

**"Soğuk" / "sıcak" ayrımı:** F10-4 cold start'ı bitirmiyor, KISALTIYOR (ölçülen 18 sn → beklenen ~7-9 sn). Bir fonksiyon ~15 dk çağrılmazsa tekrar soğur. Gerçek kullanımda birden fazla kullanıcı oldukça fonksiyonlar daha sık sıcak kalır. Kalan soğuk başlangıcı sıfırlamanın tek yolu `minInstances` (~$8/fonksiyon/ay) — bilinçli olarak kapsam dışı.

**⚠️ Seans oluşturma hakkında dürüst not:** Bu akış hiç Cloud Function kullanmıyor (doğrudan Firestore) ve ~4 ardışık round-trip içeriyor; teorik olarak 1-2 sn sürmeli, ~60 sn statik analizle AÇIKLANAMADI. Çalışan hipotez: uygulama açılışta bloklayan işleri (255 KB RC fetch + FCM kaydı) sürdürürken tıkalı bir mobil ağda tüm istekler bant genişliği için yarışıyordu — bu doğruysa F10-2 bunu da düzeltir. **F10-1 baseline'ı bu hipotezi test etmeli:** ölçümü hem "uygulama yeni açıldı" hem "uygulama 1 dakikadır açık" durumunda ayrı ayrı al.

**Bu görevlerle ULAŞILAMAYACAKLAR (para gerektiriyor, bilinçli kapsam dışı):**
- Kalan ~7-9 sn'lik cold start → `minInstances` gerekir
- Her round-trip'teki ~120 ms bölge cezası → bölge taşıma gerekir

**📊 ÖLÇÜM SONUÇLARI (2026-09-02, Android emülatör / fiber WiFi, A/B testi)**

A/B yöntemi: `677bfce` (F10-1 — ölçüm altyapısı var, `main()` hâlâ bloklayan) ile `a879590` (F10-2 + F10-3 uygulanmış) aynı emülatörde, aynı ağda, aynı build komutuyla (`flutter build apk --profile`) karşılaştırıldı.

**Senaryo A — TEMİZ KURULUM** (`adb shell pm clear`: RC cache boş, bildirim izni henüz verilmemiş). Gerçek kullanıcının uygulamayı ilk kez açtığı durum:

| Adım | ÖNCE (bloklayan) | SONRA (F10-2) |
|---|---|---|
| `firebase_init` | 365 ms | 396 ms |
| Remote Config | **2.114 ms** ⛔ blokluyor | 44 ms (sadece varsayılanlar) |
| `prefs_init` | 1 ms | 1 ms |
| Push izni | **59.138 ms** ⛔ blokluyor | — arka planda |
| **İLK KARE** | **61.645 ms** | **457 ms** |
| RC fetch (arka plan) | — | 2.158 ms (ilk kareyi bloklamıyor) |

**🔴 KÖK SEBEP BULUNDU — kullanıcının bildirdiği "1 dakikaya yakın açılış" tam olarak buydu.** Eski kodda `runApp()` ÖNCESİNDE `await PushNotificationService().init()` vardı; bu da `requestPermission()` çağırıp **sistem izin diyaloğunu** açıyor. Emülatörde doğrulandı: loglar `prefs_init`'te duruyor, `İLK KARE` hiç gelmiyor ve `dumpsys window` çıktısı `mCurrentFocus=GrantPermissionsActivity` gösteriyor — yani **uygulama, kullanıcı izin diyaloğuna cevap verene kadar BOMBOŞ ekranda bekliyor.** Diyalog 59 sn açık bırakıldığında ilk kare 61,6 saniyede geldi. Yeni kodda aynı test: **izin diyaloğu HÂLÂ ekranda dururken uygulama 457 ms'de açılmıştı** — diyalog artık çalışan bir arayüzün üstünde çıkıyor.

**Senaryo B — ISINMIŞ AÇILIŞ** (RC cache dolu, izin verilmiş): ÖNCE 644-661 ms, SONRA ~490 ms. Fark emülatör gürültüsünün içinde kaldı — beklenen davranış: `minimumFetchInterval: 24 saat` yüzünden ısınmış durumda RC fetch throttle'a takılıp anında dönüyor, yani bloklayacak bir şey zaten yok.

**F10-2'nin kazancı şu üç durumda ortaya çıkıyor:** (1) ilk kurulum → **61 sn → 0,5 sn**, (2) 24 saat sonraki ilk açılış (RC throttle sıfırlanır) → ~2 sn, (3) zayıf/tıkalı mobil ağ → RC fetch uzadıkça kazanç büyür.

**Cold start (ayrıca ölçüldü, `listPartnerGyms` doğrudan çağrılarak):** soğuk 2,67 sn · sıcak 0,47 sn → ceza **~2,2 sn**. F10-4 yapılmadığı için değişmedi (zaten ~%2 kazandıracaktı, bkz. F10-4 notu). Bunu sıfırlamanın tek yolu `minInstances`.

**⚠️ Bu ölçümler fiber WiFi üzerinde alındı.** Kullanıcının bildirdiği asıl senaryo (mobil veri) daha kötüdür: RC fetch ve tüm round-trip'ler uzar, dolayısıyla F10-2'nin kazancı gerçek cihazda daha da büyük olmalıdır. Gerçek cihazda mobil veriyle doğrulama hâlâ faydalı olur.

### F10-1 — Baseline performans ölçümü (İLK yapılacak, atlanmamalı)
**Prompt:** "Herhangi bir optimizasyon yapmadan ÖNCE, gerçek bir cihazda **mobil veriyle** (WiFi değil) şu 4 akışın süresini ölç ve kaydet: (a) uygulama açılışı → ilk kare, (b) login butonuna basış → OTP ekranı, (c) Anlaşmalı Salonlar → liste görünmesi, (d) seans oluştur → tamamlanma. Ölçüm için `Stopwatch` + `debugPrint` yeterli; istersen Firebase Performance Monitoring (ücretsiz) da eklenebilir. Sonuçları bu dosyaya bir tabloya yaz. Her F10-x görevinden sonra aynı ölçüm tekrarlanacak."
**Kabul kriterleri:**
- [ ] 4 akış için de "önce" değerleri kayıt altında (mobil veriyle, en az 3 tekrarın ortalaması)
- [ ] Ölçüm yöntemi tekrarlanabilir şekilde dokümante edilmiş

### F10-2 — `runApp()` blokajını kaldır (EN BÜYÜK KAZANÇ)
**Prompt:** "`main.dart`'ta `runApp()` öncesindeki ardışık `await` zinciri UI'ı blokluyor. Şu yapıya geçir: (1) `Firebase.initializeApp` await kalsın (zorunlu). (2) `LocalePrefs.init()`, `OnboardingPrefs.init()`, `AppPhoneFieldPrefs.init()` — üçü de SharedPreferences (yerel disk, hızlı), `Future.wait` ile PARALEL await edilsin. (3) `RemoteConfigService.init()` İKİYE bölünsün: `applyDefaults()` (sadece `setConfigSettings` + `setDefaults` — ağ YOK, ~ms) ve `fetchInBackground()` (`fetchAndActivate` + `onConfigUpdated` listener). Sadece `applyDefaults()` await edilsin. (4) `runApp()` çağrılsın. (5) `runApp()`'ten SONRA `unawaited(...)` ile: `fetchInBackground()`, `PushNotificationService().init()`, `AppDeepLinkService().init()`."
**Neden güvenli:** `_defaults` (1496 anahtar, kodda gömülü) `applyDefaults()` ile anında yükleniyor — ilk kare doğru metinlerle açılır. `AppDeepLinkService._handle()` zaten `await appAccessProvider.future` yapıyor, UI'ı kendi bekliyor.
**⚠️ BİLİNÇLİ KABUL EDİLEN DAVRANIŞ DEĞİŞİKLİĞİ:** `rcTextProvider` (889 kullanım) yalnızca `remoteConfigServiceProvider` (const, hiç değişmez) + `localeControllerProvider` izliyor. Bu yüzden arka plan fetch bitince ekrandaki metinler O OTURUMDA tazelenmez; yeni RC değerleri **bir sonraki açılışta** görünür (Firebase RC aktive edilen değerleri yerelde kalıcı tutuyor). Bu, mevcut `onConfigUpdated` davranışıyla zaten aynı (o da UI'ı tazelemiyordu) — yani regresyon değil. **GÜNCELLEME (2026-09-03):** `onConfigUpdated` (RC Realtime) tamamen kaldırıldı ve `minimumFetchInterval` 24 saatten 2 saate çekildi — RC 1 Eylül 2026'da kullandıkça-öde modeline geçti (günde 100.000 fetch ücretsiz) ve realtime, her yayında çevrimiçi her istemciye bir fetch tetikliyordu. Metinler zaten bir sonraki açılışta göründüğü için kaybedilen tek şey `cfg_*` bayraklarının anlık güncellenmesiydi. **Sonucu:** `remoteconfig.template.json` ile Dart `_defaults` haritasının senkron tutulması artık daha kritik; RC'de bir metin değiştirildiğinde koddaki default'u da güncelle.
**Kabul kriterleri:**
- [ ] **Uçak modunda** uygulama açılışı ANINDA giriş ekranı gösteriyor (şu an 10 sn RC timeout'u bekliyor)
- [ ] Normal ağda ilk kare < 1,5 sn
- [ ] TR/EN dil seçimi ilk karede doğru
- [ ] Bildirime tıklayarak açılış doğru ekrana gidiyor (deep link regresyonu yok)
- [ ] Push bildirim izni/token kaydı hâlâ çalışıyor (sadece gecikmeli)
- [ ] F10-1 ölçümü tekrarlandı, (a) akışında belirgin düşüş var

### F10-3 — `appAccess` zincirini paralelleştir
**Prompt:** "`lib/core/router/app_access.dart`'taki `appAccess` provider'ı 4 adımı ARDIŞIK bekliyor: `currentRole` → `currentUserEmail` → `activeGymId` → `subscriptionStateForGym`. Kritik gözlem: `currentRole` ve `activeGymId` AYNI `authIdTokenResultProvider`'dan geliyor (zaten memoize edilmiş), yani token çözülür çözülmez ikisi de bedava hazır. Yeni akış: (1) `authIdTokenResultProvider` bir kez await edilsin, `role` ve `gymId` aynı anda claim'lerden okunsun. (2) `role == null` → `signedOut` (değişmedi). (3) `gymId == null` → `ready` (değişmedi). (4) `gymId != null` ise `currentUserEmail` okuması ile `subscriptionStateForGym` listener'ı PARALEL başlatılsın. (5) Email `null` çıkarsa `emailSetupRequired` yayınlansın ve açılmış abonelik listener'ı `ref.onDispose` ile mutlaka kapatılsın."
**Kabul kriterleri:**
- [ ] Admin / antrenör / üye — üç rolle de giriş doğru shell'i açıyor
- [ ] Email'i olmayan hesapla giriş → `EmailSetupPanel` açılıyor
- [ ] Aboneliği bitmiş salon → admin `SubscriptionOnboardingPanel`, antrenör/üye `blocked`
- [ ] Salonu olmayan admin → `ready`
- [ ] Uygulama AÇIKKEN abonelik durumu değişince ekran anında tepki veriyor (canlı listener korunmuş)
- [ ] `otp_verification_panel.dart`'taki `ref.invalidate(appAccessProvider)` akışı bozulmamış
- [ ] Gereksiz açılan listener sızmıyor (dispose doğrulandı)

### F10-4 — Cloud Functions'ı iki codebase'e böl — ❌ ÖLÇÜLDÜ, YAPILMADI (2026-09-02)

**KARAR: Uygulanmadı.** Task yazılırken "cold start'ta %40-60 kazanç" tahmin edilmişti; uygulamadan ÖNCE ölçüldü ve **bu tahmin yanlış çıktı.** Gerçek ölçümler:

| Ölçüm | Sonuç |
|---|---|
| Derlenmiş `lib/index.js`'in TAMAMININ yüklenmesi | **107 ms** |
| `@apple/app-store-server-library` yüklemesi | 34 ms |
| `google-auth-library` yüklemesi | 13 ms |
| **Codebase bölerek kazanılacak toplam** | **~47 ms** |
| Production'da tipik cold start (gerçek loglar) | **1,4 – 3,5 sn** |
| **Kazanç oranı** | **~%2** |

Production cold start ölçümleri (`Starting new instance` → `STARTUP TCP probe`): `startLogin` 2,6 / 2,4 / 17,6 / 1,8 sn · `verifyLoginOtp` 3,5 / 1,9 / 12,4 / 1,4 sn · `listPartnerGyms` 15,9 / 1,5 sn · `signupGymAdmin` 1,4 / 2,0 / 3,2 / 5,0 sn. **12-17 sn'lik sıçramaların hepsi 1 Eylül 17:48-18:10 aralığında** (kullanıcının demo yaptığı saatler); aynı fonksiyon dakikalar sonra 1,8 sn'ye düşmüş — yani bunlar image'ın host cache'inden düşmesi kaynaklı, kod kaynaklı değil.

**Cold start'ın gerçek kaynağı kod yükleme DEĞİL** (107 ms), container sağlama (image çekme + sandbox kurulumu) — Google'ın altyapısı. Deploy paketi zaten sadece 382 KB (node_modules yüklenmiyor, Cloud Build kendi kuruyor), `@apple`'ı çıkarmak image'da ~6 MB / ~150 MB kazandırır, o da marjinal.

**%2 kazanç karşılığında alınacak riskler** (yeni codebase, paylaşılan kod paketi, deploy topolojisi değişikliği, yanlış `--only` bayrağıyla fonksiyon silme riski) bu takası kötü kılıyor. **Cold start'ı gerçekten bitiren tek yol `minInstances`'tır** (~$8/fonksiyon/ay) — F10-1 ölçümleri alındıktan sonra, hâlâ gerekiyorsa yalnızca `startLogin` + `listPartnerGyms` için değerlendirilmeli (~$16/ay).

<details>
<summary>Orijinal task tanımı (uygulanmadı, referans için korunuyor)</summary>

**Prompt:** "Tüm fonksiyonlar tek `functions/` paketinden deploy ediliyor; `@apple/app-store-server-library` ve `google-auth-library` gibi ağır bağımlılıklar, basit bir `startLogin` çağrısında bile cold start'ta modül grafiğine giriyor. Auth grubunun bağımlılık kapanışı DOĞRULANDI: sadece `firebase-admin` + `node:crypto`, ağır lib YOK. Yeni bir `functions-auth/` codebase'i oluştur (kendi `package.json`'ı, dependencies SADECE `firebase-admin` + `firebase-functions`) ve şu fonksiyonları taşı: `startLogin`, `verifyLoginOtp`, `sendEmailSetupOtp`, `verifyEmailSetupOtp`, `sendEmailChangeOtp`, `verifyEmailChangeOtp`, `listPartnerGyms`, `signupGymAdmin`, `deleteAccount`. Gereken shared dosyalar: `firestore-paths`, `phone-lookup`, `otp`, `otp-email-template`, `mail`, `login-token`. `firebase.json`'a iki codebase tanımı eklensin (`{source: functions, codebase: default}`, `{source: functions-auth, codebase: auth}`). `functions/src/index.ts`'ten taşınan export'lar kaldırılsın."
**⚠️ EN BÜYÜK RİSK — paylaşılan dosyalar:** `shared/` dosyaları iki codebase'de de gerekiyor. Seçenekler: (a) kopyala — **YAPMA**, iki kopya sessizce ayrışırsa `firestore-paths.ts` farklılığı veri hatasına yol açar; (b) symlink — tek kaynak ama TS/paketleme sorun çıkarabilir; (c) local npm paketi (`file:../shared`) — **ÖNERİLEN**, en temiz.
**Diğer notlar:** Fonksiyon isimleri ve bölge DEĞİŞMİYOR → client tarafında hiçbir değişiklik gerekmiyor, URL'ler aynı. `firebase deploy --only functions` artık iki codebase'i birden deploy eder — ilk deploy'da `--only functions:auth` ile başla, mevcut fonksiyonların silinmediğini doğrula.
**Kabul kriterleri:**
- [ ] Her iki codebase de `npm run build` + `npm run lint` temiz
- [ ] `npm test` (76+ test) geçiyor
- [ ] Deploy sonrası `firebase functions:list` — hiçbir fonksiyon kaybolmamış
- [ ] Login akışı uçtan uca çalışıyor (telefon → OTP → giriş)
- [ ] Salon oluşturma çalışıyor (logo yükleme dahil)
- [ ] Email değiştirme akışı çalışıyor
- [ ] **Cold start ölçümü:** deploy sonrası ~15 dk bekle, `startLogin` çağır, logdan boot süresini oku — 18 sn'den belirgin düşüş beklentisi (~7-9 sn)
</details>

### F10-5 — Ölü kod ve küçük israfların temizliği — ✅ 5a YAPILDI, 5b/5c/5d ÖLÇÜLDÜ VE ATLANDI (2026-09-02)

**✅ 5a — `requestCustomToken` silindi.** Kodda yoktu (F1-10'da kaldırılmış, sadece yorum referansları kalmış) ama production'da canlı duruyordu. `firebase functions:delete` ile silindi; sonrasında `functions:list` ile diğer 36 fonksiyonun sağlam olduğu doğrulandı.

**❌ 5b — `listPartnerGyms` özet dokümanı: ATLANDI, bugün HİÇ hız kazancı yok.** Gerekçe: Firestore, `gyms` koleksiyonunun tamamını **TEK bir sorgu round-trip'inde** döndürüyor (şu an 6 doküman / ~11,8 KB). Tek bir özet dokümanına indirmek de **yine tek round-trip** olurdu — yani kullanıcının gördüğü sürede ölçülebilir bir fark YOK. Kazanç sadece yüksek salon sayısında ortaya çıkar ve o da *gecikme* değil *okuma maliyeti* tarafında (ki ücretsiz kotanın çok altındayız). Karşılığında yeni bir koleksiyon + trigger + backfill + "index dokümanı bayatlarsa yanlış salon listesi gösterme" riski geliyor. Salon sayısı 50+'ye çıkarsa yeniden değerlendirilmeli.

**❌ 5c — `weeklySubscriberSummary` saatlik tetikleme: ATLANDI.** Ayda 720 çalışma, her biri 1 ucuz Firestore point-read (RC cache dokümanı). Ücretsiz kotanın çok altında, kullanıcıya görünen hiçbir etkisi yok. Schedule'ı seyrekleştirmek RC ile saat ayarlama esnekliğini (LiveOps) azaltırdı — takas değmez.

**❌ 5d — `recordSuccess` ekstra okuması: ATLANDI, kritik yolda DEĞİL.** Doğrulandı: `withFailureAlerting` yalnızca scheduled/task/trigger fonksiyonlarını sarıyor. Kullanıcının BEKLEDİĞİ callable'ların (`startLogin`, `verifyLoginOtp`, `listPartnerGyms`, `signupGymAdmin`) hiçbiri sarılı değil — yani bu ekstra okuma hiçbir zaman kullanıcının beklediği sürenin parçası olmuyor. Trigger'lar zaten yazma işleminden SONRA, asenkron çalışıyor.

<details>
<summary>Orijinal task tanımı (referans için korunuyor)</summary>

**Prompt:** "(a) `requestCustomToken` fonksiyonu kodda YOK ama production'da hâlâ canlı (F1-10'da silinmiş olmalıydı) — `firebase functions:delete requestCustomToken --project egoractive-e92bd --force` ile sil. (b) `listPartnerGyms` her çağrıda tüm `gyms` koleksiyonunu okuyor; bir trigger'la güncel tutulan tek bir `publicGyms/index` özet dokümanına indir (çağrı başına sabit 1 okuma). (c) `weeklySubscriberSummary` saatte bir tetikleniyor (ayda 720 kez) ama işini ayda ~4 kez yapıyor — schedule'ı günde 2-3 kereye indirmeyi değerlendir (RC esnekliği biraz azalır, düşük öncelik). (d) `withFailureAlerting`'deki `recordSuccess` her başarılı trigger çalışmasında fazladan bir `functionHealth` okuması yapıyor — yüksek frekanslı trigger'larda atlanabilir (düşük öncelik)."
**Kabul kriterleri:**
- [ ] `firebase functions:list` çıktısında `requestCustomToken` yok
- [ ] (b) yapıldıysa: Anlaşmalı Salonlar listesi doğru salonları gösteriyor, yeni salon eklenince index tazeleniyor
- [ ] Tüm mevcut testler geçiyor
</details>

---

### FAZ 10 kapsamı DIŞINDA bırakılanlar (ayrıca karar verilecek)

**Bölge taşıma (`us-central1` → `europe-west3`) — KARAR: şimdilik YAPILMIYOR (2026-09-02).** Gerekçe: kazanç gerçek ama sınırlı (round-trip başına ~120 ms → tipik akışlarda 0,3-1,5 sn), buna karşılık migration riski yüksek ve çözülmemiş bir maliyet belirsizliği var (aşağıya bkz.). Önce F10-1…F10-5 yapılıp ölçülecek; kalan yavaşlık kabul edilemezse yeniden değerlendirilecek. Aşağıdaki teknik notlar, o gün gelirse hazır olsun diye korunuyor.
**⚠️ Yeniden değerlendirilirse ÖNCE şu netleşmeli:** Firestore ücretsiz kotasının yalnızca `(default)` veritabanına mı uygulandığı (https://firebase.google.com/docs/firestore/pricing). Eğer öyleyse "aynı projede ikinci veritabanı" yolu ücretsiz kotayı kaybettirir ve yeni bir Firebase projesi (yeni API key'ler, FCM/IAP/Analytics yeniden kurulum) gerekir — bu da işi kat kat büyütür.

Teknik notlar: en büyük tekil kazanç (her round-trip 2 kat hızlanır) ama ayrı ve dikkatli bir migration projesi. **Firestore'un bölgesi oluşturulduktan sonra değiştirilemez** — çözüm: aynı proje içinde ikinci bir veritabanı (`gcloud firestore databases create --database=eu --location=europe-west3`), export/import ile veri taşıma, client'ta `FirebaseFirestore.instanceFor(databaseId:)` (SDK destekliyor, doğrulandı). Dikkat: rules/index'ler veritabanı başına ayrı; Trigger Email extension'ı `DATABASE=(default)` ile kurulu, güncellenmeli; Firestore trigger'ları veritabanıyla aynı bölgede olmalı; Storage bucket'ı taşınırsa Firestore'daki mutlak `logoUrl`'ler yeniden yazılmalı. **Not:** Ücretsiz kota bölgeden bağımsız aynıdır — bu taşıma bugünkü kullanımda ek maliyet YARATMAZ (doğrulanmalı: https://firebase.google.com/docs/firestore/pricing). Store'a çıkmadan yapmak en ucuz an.

**`minInstances: 1` (cold start'ı tamamen bitirir):** ~$8/fonksiyon/ay. F10-2/F10-3/F10-4 tamamlanıp ölçüm yapıldıktan SONRA, hâlâ gerekiyorsa sadece `startLogin` + `listPartnerGyms` için değerlendirilmeli (~$16/ay). Maliyet doğrulaması: https://cloud.google.com/run/pricing

**Remote Config payload küçültme (`_tr`/`_en` birleştirme) — YAPILAMAZ, teknik engel var:** 1573 parametre / 255 KB. Akla gelen çözüm `lbl_x_tr` + `lbl_x_en` yerine RC *conditions* ile tek `lbl_x` tutmak (~%50 azalma). **Ama bu, uygulama içi dil değiştiriciyi bozar** — `language_select_panel.dart` kullanıcının cihaz dilinden BAĞIMSIZ olarak dili değiştirmesine izin veriyor (`LocalePrefs.override`). RC conditions dil seçimini SUNUCUYA devreder: değer fetch anında seçilir ve tek bir dil gönderilir. Kullanıcı uygulama içinde TR→EN geçtiğinde RC'de hâlâ eski dilin değerleri durur ve `minimumFetchInterval: 24 saat` yüzünden 24 saat boyunca yenilenemez. Zorla fetch de çözüm değil: her dil değişimi ağa çıkmayı gerektirir, çevrimdışı hiç çalışmaz. **Mevcut `_tr`/`_en` son eki tam olarak bunun için var — anlık, çevrimdışı çalışan dil değiştirme; her iki dil de cihazda hazır bekliyor. Bilinçli bir tasarım, "gereksiz tekrar" değil.**
Ayrıca kazanç zaten küçük: RC yanıtı gzip'li geldiği ve JSON çok tekrarlı olduğu için ağdan geçen gerçek veri ~50-70 KB; yarıya inmesi ~25-35 KB (mobilde ~0,05-0,3 sn) kazandırır — F10-2'den sonra bu fetch arka planda olduğu için kullanıcıya görünen kazanç sıfırdır. Ölçülebilir tek gerçek kazanç `applyDefaults()`'ta ~10-25 ms olurdu; 889 kullanım noktası + 1496 default'u değiştirme riskine değmez.

**`rcTextProvider` tazeleme sinyali:** F10-2'nin notunda açıklanan davranış (RC değişiklikleri bir sonraki açılışta görünür) kabul edilebilir bulunmazsa, `rcVersionProvider` deseniyle çözülebilir. Dikkat: 889 widget'ın aynı anda yeniden çizilmesi frame hitch'e yol açabilir.

**App Check:** Şu an kurulu değil (`"app":"MISSING"`). Güvenlik konusu, performans değil — ayrı ele alınmalı.

---

## FAZ 11 — Admin'in Kendini Antrenör Olarak Eklemesi (Gölge Antrenör)

**Problem:** Pilot salonda adminin kendisi aynı zamanda antrenör. Telefon numarası admin hesabına bağlı olduğu için aynı numarayla ikinci bir hesap açılamıyor; seans ve grup dersi atarken kendi adı antrenör listesinde çıkmıyor.

**Seçilen çözüm — "gölge antrenör":** Admin, "Antrenör Ekle" akışındaki bir toggle ile `users` koleksiyonuna kendisi için **telefonsuz ve e-postasız** bir `role: 'trainer'` dokümanı açar. Bu doküman hiçbir zaman giriş yapamaz (kimlik sorgularının ikisi de eşleşmez), sadece "atanabilir antrenör" olarak var olur. Antrenöre giden push bildirimleri, gölge dokümandaki `notificationProxyUid` alanı üzerinden adminin cihazına yönlendirilir.

**Neden bu yol (değerlendirilen alternatifler):**
- `role` alanını bitmask'e çevirmek (`admin|trainer`) — ~6 gün, `firestore.rules`'taki 41 `myRole()` kullanımı + custom claim zinciri + kırıcı şema migration'ı gerektiriyor. Rules dilinde bitwise operatör olmadığı için kazancı da sınırlı.
- `role` string kalıp yanına `isTrainer` bayrağı — ~2 gün, tek kimlik üretmesi açısından daha temiz ama antrenör sorgularını ve claim/rules tarafını yine de elliyor.
- Aynı telefon/e-posta ile ikinci doküman — **YAPILAMAZ.** `sendEmailSetupOtp` aynı e-postayı ikinci hesaba vermiyor (`already-exists`), ve `findUserByPhone` `.limit(1)` ile sorguladığı için iki dokümandan biri doküman ID sırasına göre kalıcı olarak erişilemez hale geliyor — %50 ihtimalle adminin kendi hesabı.

**Bu yolun kabul edilen bedelleri:** Adminin antrenör kimliği ayrı bir dokümanda yaşıyor (ikinci bir "kişi" kaydı). Admin dokümanında isim tutulmadığı için raporlarda isim tekrarı oluşmuyor. Antrenör görünümü/shell'i açılmıyor — admin zaten kendi panelinden seans tamamlayabiliyor (`admin_session_management_panel.dart`, rules'ta `sessions` update dalı admin için salonun tamamını kapsıyor).

**Doğrulanmış önkoşullar (kod okunarak teyit edildi, tekrar araştırmaya gerek yok):**
- Telefon hiçbir yerde SMS ile doğrulanmıyor; OTP e-postaya gidiyor. Telefon sadece bir tanımlayıcı.
- `admin_trainer_management_panel.dart:302` — telefon tekrar kontrolü `phoneNumber.isNotEmpty` koşuluna bağlı, yani boş telefon bugün de kabul ediliyor.
- `resolvePhoneIndexSync` boş/olmayan numarada `phoneIndex`'e hiçbir şey yazmıyor.
- `deactivateTrainer`, Auth kaydı hiç olmayan uid'ler için `auth/user-not-found`'u zaten yutuyor (lazy account creation).
- Antrenör sayısı hiçbir limit/abonelik hesabına girmiyor, sadece ekranda gösteriliyor.
- `onUserRoleAssigned` gölge doküman için hep `auth/user-not-found` verip yeniden denenecek; bu hata `isIgnorable` ile alarm dışı bırakılmış durumda. Bugün de her yeni antrenör/üye için ilk girişe kadar aynısı oluyor — kabul edilen gürültü.

---

**Canlı etki (kod okunarak doğrulandı) — geliştirirken bunlara göre hareket edilecek:**

*Mevcut kullanıcılar için veri göçü, zorunlu güncelleme ve yeniden giriş YOK.* Hiçbir mevcut dokümana dokunulmuyor; `notificationProxyUid`/`trainerProfileUid` yeni alanlar. `role`, custom claim'ler, `phoneIndex` ve giriş akışı değişmiyor. Antrenör sorguları `gymId` filtreli olduğu için gölge antrenör sadece kendi salonunun admin ekranlarında görünür. Üyeye giden 5 bildirim yolu (`send-session-reminder-task`, `community-broadcast`, `feedback-reminder-check`, `send-manual-notification`, `notify-member-package-quota`) bu fazın dokunduğu yerlerden token okumuyor — kapsam dışı. Eski uygulama sürümleri sorunsuz çalışmaya devam eder (proxy alanı olmayan dokümanlar için sunucu davranışı birebir aynı).

**🔴 RİSK 1 — F11-2 tüm salonların personel bildirimlerinin ortak yolunda.** `fetchTokensForUids`/`fetchGymStaffTokens`, gölge antrenörü hiç kullanmayan salonlarda da antrenör seans hatırlatması, grup dersi hatırlatması, etkinlik personel hatırlatması ve "dersini onaylar mısın?" push'unu besliyor. Buradaki bir hata bildirimleri **sessizce** keser — hata görünmez, sadece push gelmez (`sendEachForMulticast`'in dönüş değeri hiçbir yerde incelenmiyor). Bu yüzden regresyon kriteri ve birim testleri zorunlu, deploy sonrası canlı teyit şart.

**🔴 RİSK 2 — F11-3 rules deploy'u anında ve herkese birden yayılır.** Kademeli çıkış yok; yanlış bir koşul tüm kullanıcıları aynı anda `PERMISSION_DENIED`'a düşürür. Kısıtlanacak alanların bugün hiçbir canlı akışta yazılmadığı DOĞRULANDI: `member_registration_service` (name, nameLower, phoneNumber, role, gymId, trainerId, trainerName, createdAt, gender, canConfirmAttendance), `addTrainer` ve `updateOwnInfo` (name, nameLower, phoneNumber) `email`/`emailLower`'a dokunmuyor; `signupGymAdmin` Admin SDK olduğu için rules'a tabi değil. Yani kısıtlama bugün kimsenin kullanmadığı bir kapıyı kapatıyor — yine de emulator testleri olmadan deploy EDİLMEZ.

**⚠️ DEPLOY SIRASI — önce sunucu, sonra client:** `F11-2 + F11-3` (Cloud Functions + rules) → sonra `F11-1, F11-4, F11-6` (store sürümü). Ters sırada, admin gölge antrenörü oluşturur ama yönlendirme canlıda olmadığı için o antrenörün bildirimleri **hiçbir yere gitmez** (gölge dokümanda `fcmTokens` alanı hiç yok) ve bu sessizce olur. F11-2 client değişikliği gerektirmediği için bu sırayı tutturmak kolay.

**Geri dönüş:** F11-2/F11-3 tek `firebase deploy` ile eski haline döner. Oluşturulmuş gölge doküman `deactivateTrainer` ile pasife alınır; seanslar ve rapor satırları geçmişte kalır. Kalıcı/geri alınamaz hiçbir veri dönüşümü yok.

---

### F11-1 — Gölge antrenör dokümanının oluşturulması (client)

**Prompt:** "`admin_trainer_management_panel.dart`'taki antrenör ekleme sheet'ine, formun en üstüne 'Kendimi antrenör olarak ekle' toggle'ı ekle (varsayılan kapalı, metin Remote Config'ten). Toggle açıkken telefon alanı boşaltılıp `enabled: false` yapılsın ve tekrar kontrolüne hiç girilmesin; sadece ad-soyad ve uzmanlıklar girilir. `AdminTrainersController`'a `addSelfAsTrainer({name, specialties})` metodu ekle: `users` koleksiyonuna `{name, nameLower, role: 'trainer', gymId, specialties, createdAt: serverTimestamp(), isActive: true, notificationProxyUid: <adminUid>}` yazar — `phoneNumber` ve `email` alanlarını HİÇ yazmaz (boş string de değil, alan hiç bulunmaz). Aynı işlemde adminin kendi `users/{adminUid}` dokümanına `trainerProfileUid: <yeni doküman id>` yazılır; bu alan bir daha silinmez (F11-5'te tekrar açma bunun üzerinden çalışır). Admin dokümanında `trainerProfileUid` zaten varsa toggle hiç gösterilmez."

**Kabul kriterleri:**
- [ ] Toggle kapalıyken mevcut antrenör ekleme akışı bit birebir aynı davranıyor
- [ ] Oluşan dokümanda `phoneNumber` ve `email` alanları YOK (Firestore Console'da doğrulanır)
- [ ] `phoneIndex` koleksiyonuna hiçbir doküman yazılmadı
- [ ] `startLogin`, adminin telefonuyla çağrıldığında hâlâ ADMIN dokümanını döndürüyor
- [ ] Gölge antrenör, seans oluşturma sheet'i ve grup dersi panelindeki antrenör seçicilerinde görünüyor
- [ ] `trainerProfileUid` yazılı adminde toggle görünmüyor
- [ ] Toggle etiketi/açıklaması Remote Config'e **iki dilde de** (`_tr`/`_en`) girildi — girilmezse etiket boş görünür, sürüm çıkmadan kontrol edilmeli
- [ ] `flutter analyze` temiz, mevcut testler geçiyor

---

### F11-2 — Bildirim token yönlendirmesi (`notificationProxyUid`)

**Prompt:** "`functions/src/shared/staff-notifications.ts`'te token çözümlemesine yönlendirme ekle: bir `users` dokümanında `notificationProxyUid` alanı varsa, o dokümanın kendi `fcmTokens`'ı yerine işaret edilen dokümanın `fcmTokens`'ı kullanılır. Yönlendirme TEK adım — proxy'nin proxy'si takip edilmez (sonsuz döngü koruması), işaret edilen doküman yoksa boş liste döner. `fetchTokensForUids` (satır 43) ve `fetchGymStaffTokens` (satır 60) bu mantığı kullanacak. `send-session-completion-task.ts:79` bugün antrenör dokümanını doğrudan okuyup `fcmTokens`'ı alıyor — onu `fetchTokensForUids([trainerId], db)` çağrısına dönüştür ki yönlendirme tek yerde kalsın. Çözümleme mantığını saf bir fonksiyon olarak ayır ve `staff-notifications.test.ts` desenine uygun birim testleri yaz."

**Kabul kriterleri:**
- [ ] Proxy'si olmayan dokümanlar için davranış birebir aynı (regresyon yok)
- [ ] Proxy'si olan doküman için işaret edilen dokümanın token'ları dönüyor
- [ ] Proxy zinciri (A→B→C) takip edilmiyor, tek adımda duruyor
- [ ] İşaret edilen doküman silinmişse boş liste dönüyor, fonksiyon çökmüyor
- [ ] `send-session-completion-task.ts` artık `fcmTokens`'ı doğrudan okumuyor
- [ ] `npm test` ve `npx tsc --noEmit` temiz
- [ ] **Client tarafında hiçbir değişiklik yok** — bu görev store güncellemesi gerektirmez
- [ ] Deploy sonrası ilk gün, gölge antrenörü OLMAYAN bir salonda gerçek bir antrenör seans hatırlatmasının gittiği teyit edildi (sessiz kesinti riski — bkz. RİSK 1)

---

### F11-3 — `notificationProxyUid`/`trainerProfileUid` alanlarını Security Rules ile koru

**Prompt:** "`firestore.rules`'ta `match /users/{uid}` altındaki `allow update` kuralının self-update dalı bugün sadece `email`/`emailLower` alanlarını koruyor. Bu listeye `notificationProxyUid` ve `trainerProfileUid` alanlarını da ekle — bir üye/antrenör kendi dokümanına `notificationProxyUid` yazarak KENDİ bildirimlerini başka bir kullanıcının cihazına yönlendirebilir (kendi verisini kurbanın telefonuna sızdırma + spam vektörü). Bu alanları sadece admin dalı ve Admin SDK yazabilmeli. AYRICA: `allow create` dalında hiçbir alan kısıtı yok; `email`/`emailLower`'ın oluşturma anında client'tan yazılabilmesi, `update`'teki 'email sadece OTP sonrası Admin SDK ile yazılır' kuralını deliyor — create dalına da aynı kısıtı ekle."

**Kabul kriterleri:**
- [ ] Üye/antrenör kendi dokümanına `notificationProxyUid` yazamıyor (rules testi)
- [ ] Üye/antrenör kendi dokümanına `trainerProfileUid` yazamıyor
- [ ] Client oluşturma akışları `email`/`emailLower` yazamıyor
- [ ] Admin, gölge antrenör dokümanını (F11-1) hâlâ oluşturabiliyor
- [ ] Mevcut ad/telefon güncelleme akışları (`updateOwnInfo`) bozulmadı
- [ ] Üye ekleme (`member_registration_service`) ve antrenör ekleme (`addTrainer`) akışları bozulmadı
- [ ] Admin, KENDİ dokümanına `trainerProfileUid` yazabiliyor (self-update dalı bunu engelliyor ama admin dalı `gymId` eşleşmesiyle izin veriyor — OR mantığı doğrulanmalı)
- [ ] Emulator'da rules testleriyle doğrulandı — rules deploy'u kademeli değil, testsiz çıkılmaz (bkz. RİSK 2)

> Rules testleri `functions/src/rules/*.rules-test.ts` altında, `cd functions && npm run test:rules` ile (Firestore emulator'ı `firebase emulators:exec` içinde açılır). `npm test`'in globu (`*.test.js`) bu dosyaları BİLEREK kapsamıyor — emulator gerektirdikleri için ayrı komut. Emulator Java istiyor: `export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"`.

---

### F11-4 — Antrenör bildirimlerinin admin oturumunda doğru ekrana açılması

**Prompt:** "`push_notification_service.dart`'taki `_navigateForData`, `session_completion` tipinde `TrainerCalendarPanel`'e gidiyor. Gölge antrenör senaryosunda bu bildirim ADMİN cihazına düşüyor ama panel `FirebaseAuth.currentUser.uid` (= admin uid) ile sorgu yaptığı için boş ekran açılıyor. `session_completion` ve `trainer_session_reminder` tiplerinde aktif rol admin ise `AdminSessionManagementPanel`'e (mümkünse `sessionId` odaklı) yönlendir; rol antrenörse mevcut davranış korunur. Rol okuması için `app_deep_link_service.dart:57`'deki desen izlenmeli — ayrı/erken bir `currentRoleProvider` okuması yapılmaz, `appAccessProvider` beklenir."

**Kabul kriterleri:**
- [ ] Admin oturumunda `session_completion` bildirimine dokunulunca boş ekran değil, ilgili seansın yönetim ekranı açılıyor
- [ ] Antrenör oturumunda mevcut davranış (Takvimim + onay sheet'i) değişmedi
- [ ] Bildirim, giriş yapılmamış durumda geldiğinde normal giriş akışının önüne geçmiyor

---

### F11-5 — Antrenörlükten çıkma / tekrar açma

**Prompt:** "Antrenör listesinde gölge antrenör satırı için (adminin `trainerProfileUid`'i ile eşleşen doküman) 'Antrenörü sil' yerine 'Antrenörlükten çık' aksiyonu göster. Bu aksiyon `deactivateTrainer` callable'ını çağırır (`isActive: false`) — geçmiş seanslar, aylık istatistikler ve rapor satırları KORUNUR. Adminin `trainerProfileUid` alanı SİLİNMEZ; toggle'ın açık/kapalı durumu gölge dokümanın `isActive` alanından okunur. Tekrar açılırsa yeni doküman oluşturulmaz, aynı doküman `isActive: true` yapılır (istatistiklerin bölünmemesi için). `deactivateTrainer`'daki `trainerId === callerUid` guard'ı bu akışta tetiklenmiyor (uid'ler farklı), doğrulanmalı."

**Kabul kriterleri:**
- [ ] Antrenörlükten çıkınca gölge antrenör, seans/grup dersi atama listelerinde görünmüyor
- [ ] `fetchGymStaffTokens` artık bu dokümanı toplamıyor (`isActive !== false` filtresi)
- [ ] Geçmiş raporlarda o dönemin seansları hâlâ görünüyor
- [ ] Tekrar açıldığında YENİ doküman oluşmuyor, aynı doküman canlanıyor
- [ ] Aylık istatistik bucket'ı bölünmüyor

---

### F11-6 — Antrenör listesi ve detay ekranlarında telefonsuz antrenör

**Prompt:** "Antrenör listesi ve antrenör detay ekranlarında `phoneNumber` alanı boş/eksik olan antrenör için telefon satırı gösterilmesin (ya da '—' gösterilsin, tutarlı olan hangisiyse). Gölge antrenör satırında adminin kendisi olduğunu belirten bir rozet/etiket göster. Düzenleme formunda bu satır açıldığında telefon alanı pasif kalır."

**Kabul kriterleri:**
- [ ] Boş telefonlu antrenör satırı bozuk/boş bir alan göstermiyor
- [ ] Gölge antrenör listede ayırt edilebiliyor
- [ ] Düzenleme formunda telefon alanı pasif, kaydetme telefon yazmaya çalışmıyor
- [ ] Bugün elle telefonsuz eklenmiş antrenörler varsa (mevcut form buna zaten izin veriyor) onların satırı da düzgün görünüyor — bu görev sadece gölge antrenörü değil, o kayıtları da etkiler

---

### F11-7 — Uçtan uca doğrulama (manuel senaryo)

**Prompt:** "Gerçek cihazda (emulator değil, push gerektiği için) aşağıdaki senaryoyu baştan sona çalıştır ve her adımı işaretle."

**Kabul kriterleri:**
- [ ] Admin kendini antrenör olarak ekliyor, listede görünüyor
- [ ] Kendine bireysel seans atıyor; seans hatırlatma push'u ADMIN cihazına geliyor
- [ ] "Dersini onaylar mısın?" push'u geliyor, dokununca doğru ekran açılıyor (F11-4)
- [ ] Seansı admin panelinden tamamlıyor, üyenin `remainingSessions` değeri düşüyor
- [ ] Kendine grup dersi atıyor; grup dersi hatırlatmasında **tek** bildirim geliyor (antrenör metni — admin metni `excludeTokens` ile eleniyor, bkz. commit 47caf86)
- [ ] Etkinlik personel hatırlatmasında tek bildirim geliyor
- [ ] Haftalık rapor mailinde antrenör performans tablosunda gölge antrenör satırı, doğru seans sayılarıyla görünüyor
- [ ] Uygulamadan çıkış yapıp tekrar giriliyor; bildirimler hâlâ geliyor (token yenilenmesi yönlendirmeyi bozmuyor — F11-2'nin asıl kazancı bu)
- [ ] Antrenörlükten çıkılıyor, bildirimler kesiliyor, geçmiş rapor bozulmuyor

---

### FAZ 11 kapsamı DIŞINDA bırakılanlar

**Grup dersi/etkinlik katılımcı listeleri.** `send-group-session-reminder-task.ts:122` ve `send-event-reminder-task.ts:106` `attendeeIds`'teki uid'lerin `fcmTokens`'ını DOĞRUDAN okuyor, `notificationProxyUid` yönlendirmesini bilmiyor. Bugün sorun değil: katılımcı listelerine sadece üyeler giriyor, gölge antrenör giriş yapamadığı için kendini derse ekleyemiyor. "Antrenör de derse katılımcı olarak eklenebilsin" denirse yönlendirmenin bu iki noktaya da taşınması gerekir.

**Adminin kendi antrenörlük performansını antrenör gözüyle görmesi.** Gölge antrenörün "Seans Raporum" karşılığı yok; admin salon raporlarından ve antrenör performans tablosundan takip eder. İstenirse admin paneline ayrı bir "Benim seanslarım" sekmesi olarak eklenebilir.

**Çoklu rol mimarisi (bitmask / `roles` dizisi).** Gölge antrenör, `role` alanının anlamına hiç dokunmadığı için bu geçişi engellemiyor; ileride gerçekten gerekirse ayrı bir faz olarak ele alınır. Geçiş planı ve dosya envanteri bu konuşmada çıkarıldı, gerekirse yeniden üretilebilir.
