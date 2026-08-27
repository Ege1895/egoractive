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
