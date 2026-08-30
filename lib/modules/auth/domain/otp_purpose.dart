/// Email OTP sisteminin hangi akış için çalıştığı — [OtpVerificationPanel]
/// bu değere göre doğrulama sonrası ne yapacağına karar verir (giriş yap /
/// aktivasyon tamamlayıp giriş yap / sadece email'i güncelle).
enum OtpPurpose { login, activation, emailChange }
