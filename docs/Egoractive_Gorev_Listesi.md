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

### F8-3 — Mevcut Firestore telefon kayıtlarını E.164'e migrate et
**Prompt:** "Tek seferlik bir Cloud Function/script (`functions/src/scripts/` veya benzeri) — `users`/`members`/`trainers` vb. koleksiyonlarındaki mevcut çıplak (prefiksiz, TR varsayılan) `phoneNumber` alanlarına `+90` prepend edip E.164'e çevirsin. Migration bitene kadar okuma tarafında prefiksiz kayıtlar için TR fallback bırakılsın (geçiş penceresi güvenliği)."
**Kabul kriterleri:** Migration script'i staging/emulator'da çalıştırılıp tüm kayıtların `+90` ile başladığı doğrulanmış; production'da manuel onaylı tek seferlik çalıştırma planı var.

### F8-4 — İletişim telefon formlarını `AppPhoneField`'a geçir
**Prompt:** "Üye (`member_info_panel.dart`), antrenör (`admin_trainer_management_panel.dart`), salon (`gym_setup_panel.dart`, `gym_info_panel.dart`) gibi ekranlardaki telefon alanları `AppPhoneField`'a geçirilsin. Eski `TrPhoneNumberInputFormatter` artık hiçbir yerden çağrılmıyorsa kaldırılsın."
**Kabul kriterleri:** Listelenen ekranların hepsinde ülke seçici çalışıyor, kaydedilen değer E.164; `flutter analyze` temiz.

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
