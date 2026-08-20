# Egoractive

**Spor salonu ve PT stüdyo yönetim uygulaması** — Admin, Antrenör ve Üye rolleri için tek bir Flutter kod tabanı.

<p align="left">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img alt="Firebase" src="https://img.shields.io/badge/Firebase-Firestore%20%C2%B7%20Functions%20%C2%B7%20FCM-FFCA28?logo=firebase&logoColor=black">
  <img alt="Riverpod" src="https://img.shields.io/badge/State-Riverpod-1B1B1F">
  <img alt="Platforms" src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey">
  <img alt="License" src="https://img.shields.io/badge/License-Private-red">
</p>

---

## 🎯 Ne yapar

Egoractive (yayıncı: **Egora Games**), spor salonlarının/PT stüdyolarının üye, paket, ders ve antrenör yönetimini tek bir mobil uygulamadan yürütmesini sağlar. Üç rol tek kod tabanında ayrı deneyimler sunar:

| Rol | Neler yapar |
|---|---|
| 👑 **Admin** | Salon ayarları, üye/antrenör yönetimi, paket satışı, ders/seans takvimi, giderler, raporlar |
| 🏋️ **Antrenör** | Kendi programı, üye detayları, ölçüm takibi, ders tamamlama onayı |
| 🙋 **Üye** | Seans takibi, katılım onayı ("Gelicem"/"Gelmeyeceğim"), paket durumu, geri bildirim |

Öncelik **LiveOps**: uygulama store güncellemesi beklemeden Firebase Remote Config ile davranış değiştirebilir, TR/EN dil desteğiyle anında yerelleşir.

## 🧱 Mimari

Feature-first modüler yapı — her modül kendi `controller/service/repository/domain/ui` katmanlarını taşır, modüller arası doğrudan bağımlılık yasaktır.

```
lib/
  core/       → BasePanel + PanelStackController (navigasyon), ThemeController,
                RemoteConfigService, LocaleController, go_router (ince katman)
  modules/    → auth, members, trainers, sessions, packages, group_sessions,
                events, measurements, badges, feedback, notifications,
                reports, expenses, subscription
  shared/     → ortak widget'lar ve util'ler

functions/    → Cloud Functions (TypeScript) — trigger'lar, scheduled job'lar,
                callable fonksiyonlar
```

**Öne çıkan tasarım kararları:**
- 🧭 Navigasyon merkezi: `Navigator.push/pop` hiçbir yerde çağrılmaz, her şey `PanelStackController` üzerinden — `BasePanel` her ekranın show/hide yaşam döngüsünü ve sistem geri tuşunu yönetir.
- 🎨 Renk paleti/tema salon bazlı, Firestore'dan (`gyms/{gymId}.themeColors`) dinamik yüklenir — hiçbir widget'ta literal `Color(0xFF...)` yoktur.
- 🌍 Tüm statik metinler Firebase Remote Config'te `_tr`/`_en` çiftleriyle tutulur; dil değişimi tüm uygulamayı anında, reaktif olarak günceller.
- 🔒 Yetkilendirme, iş mantığında rol dallanması yerine tamamen **Firestore Security Rules**'ta yaşar (`role`/`gymId` custom claim'leri üzerinden).
- ⚙️ İş kuralı sabitleri (limitler, süreler, feature flag) Remote Config'te; build-time sabitleri (`lib/core/constants/`) `const` olarak ayrı tutulur.

## 🛠️ Teknoloji

- **Client:** Flutter (iOS + Android, tek kod tabanı)
- **State management:** Riverpod (`@riverpod` code-gen, `Notifier`/`AsyncNotifier`)
- **Backend:** Firebase — Firestore, Cloud Functions, FCM, Remote Config, Authentication, Analytics, Crashlytics
- **Model üretimi:** Freezed + `build_runner`

## 🚀 Başlarken

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Firebase yapılandırması için `flutterfire configure` çalıştırılmış olmalı (bu repoda `firebase_options.dart` mevcut). Cloud Functions için:

```bash
cd functions && npm install
```

## ✅ Değişiklik göndermeden önce

```bash
dart run build_runner build --delete-conflicting-outputs
dart format .
flutter analyze
flutter test
```

Kod stili ve mimari kurallar için [CLAUDE.md](CLAUDE.md) — üye sıralaması, isimlendirme, klasör yapısı ve hardcode/Remote Config ayrımı burada tanımlı.

## 📦 Firestore koleksiyonları (özet)

`gyms`, `users` (rol: admin/trainer/member), `sessions`, `groupSessions`, `events`, `memberPackages`, `measurements`, `expenses`, `feedback` — her biri `firestore.rules` içinde rol + salon bazlı erişim kontrolüyle korunur.
