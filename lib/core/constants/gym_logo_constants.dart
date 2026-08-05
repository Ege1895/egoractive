/// Salon logosu Storage kısıtları — Storage'ın ücretsiz kotasında kalmak
/// için görsel her zaman client-side bu boyuta indirilip PNG olarak
/// yüklenir; `storage.rules` bunu bir güvenlik tabanı olarak da zorunlu kılar.
const gymLogoMaxDimension = 128;
const gymLogoMaxBytes = 300 * 1024;
