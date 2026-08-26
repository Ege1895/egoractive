/// Salon logosu Storage kısıtları — Storage'ın ücretsiz kotasında kalmak
/// için görsel her zaman client-side bu boyuta indirilip PNG olarak
/// yüklenir; `storage.rules` bunu bir güvenlik tabanı olarak da zorunlu kılar.
///
/// 128 iken `gym_info_panel.dart`'ın 84 mantıksal px'lik önizlemesinde (3x
/// bir cihazda 252 fiziksel px) belirgin şekilde bulanık görünüyordu — 256'ya
/// çıkarıldı, hâlâ `gymLogoMaxBytes` sınırının çok altında kalıyor.
const gymLogoMaxDimension = 256;
const gymLogoMaxBytes = 300 * 1024;
