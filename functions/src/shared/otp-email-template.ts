import { OtpPurpose } from "./otp";

export type EmailLocale = "tr" | "en";

/**
 * Email OTP sistemi — giriş/aktivasyon/email değişikliği için gönderilen tek
 * doğrulama kodu e-postasının konu/gövde metni. `queueEmail` (bkz.
 * `shared/mail.ts`) ile `mail` koleksiyonu üzerinden, mevcut Trigger Email
 * extension altyapısıyla gönderilir — F5-2'deki rapor e-postalarıyla aynı yol.
 *
 * Tasarım, iOS/Android'in email'den kod yakalayıp klavye üstü öneri
 * şeridine/QuickType'a taşımasını hedefliyor (resmi bir API değil, sezgisel
 * bir eşleştirme — SMS'teki gibi garanti değil ama isabeti artırıyor):
 * - Kod HEM konu satırının başında HEM görünmez bir preheader'da tekrarlanıyor
 *   — bildirim/QuickType bunları açmadan okuyor.
 * - Kod her zaman tamamen düz metin, kesintisiz tek bir sayı dizisi
 *   (`letter-spacing` sadece görsel genişletme, metin düğümünü bölmüyor;
 *   ayraç/tire YOK — bunlar eşleştirmeyi bozuyor).
 * - Kodun yanına başka bir sayı (süre vb.) yakın koyulmuyor, karışmasın diye.
 */

const LOGO_URL =
  "https://storage.googleapis.com/egoractive-e92bd.firebasestorage.app/branding/egora-logo-132.png";

type OtpCopy = { subjectSuffix: string; eyebrow: string; heading: string; intro: string };

/**
 * Metinler alıcının salonunun bulunduğu yere göre seçiliyor — push
 * bildirimleriyle aynı kural (bkz. `notification-locale.ts`). Önceden bu
 * e-postalar dilden bağımsız olarak Türkçe gidiyordu; İngilizce arayüz
 * kullanan bir salonun üyesi de Türkçe giriş kodu maili alıyordu
 * (kullanıcı raporu, 2026-09-02).
 */
const COPY: Record<OtpPurpose, Record<EmailLocale, OtpCopy>> = {
  login: {
    tr: {
      subjectSuffix: "Egoractive giriş kodun",
      eyebrow: "GİRİŞ",
      heading: "Giriş kodun hazır",
      intro: "Egoractive hesabına giriş yapmak için aşağıdaki kodu uygulamaya gir.",
    },
    en: {
      subjectSuffix: "Your Egoractive sign-in code",
      eyebrow: "SIGN IN",
      heading: "Your sign-in code is ready",
      intro: "Enter the code below in the app to sign in to your Egoractive account.",
    },
  },
  activation: {
    tr: {
      subjectSuffix: "Egoractive hesabını doğrula",
      eyebrow: "HESAP AKTİVASYONU",
      heading: "Hesabını doğrula",
      intro:
        "Egoractive hesabını bu email adresine bağlamak için aşağıdaki kodu uygulamaya gir.",
    },
    en: {
      subjectSuffix: "Verify your Egoractive account",
      eyebrow: "ACCOUNT ACTIVATION",
      heading: "Verify your account",
      intro:
        "Enter the code below in the app to link your Egoractive account to this email address.",
    },
  },
  emailChange: {
    tr: {
      subjectSuffix: "Yeni email'ini doğrula",
      eyebrow: "EMAIL DEĞİŞİKLİĞİ",
      heading: "Yeni email'ini doğrula",
      intro:
        "Egoractive hesabındaki email adresini bu adresle değiştirmek için aşağıdaki kodu uygulamaya gir.",
    },
    en: {
      subjectSuffix: "Verify your new email",
      eyebrow: "EMAIL CHANGE",
      heading: "Verify your new email",
      intro:
        "Enter the code below in the app to change your Egoractive account email to this address.",
    },
  },
};

const PREHEADER: Record<EmailLocale, (code: string, minutes: number) => string> = {
  tr: (code, minutes) => `${code} kodunu ${minutes} dakika içinde uygulamaya gir.`,
  en: (code, minutes) => `Enter the code ${code} in the app within ${minutes} minutes.`,
};

/** Gövdedeki, amaçtan bağımsız ortak metinler. */
const CHROME: Record<
  EmailLocale,
  { enterCode: string; expiry: (minutes: number) => string; ignore: string; footer: string }
> = {
  tr: {
    enterCode: "Bu kodu uygulamaya gir",
    expiry: (minutes) => `⏱ ${minutes} dakika içinde geçerliliğini yitirir`,
    ignore:
      "Bu isteği sen yapmadıysan güvenle görmezden gelebilirsin — hesabın etkilenmedi. Kodu kimseyle paylaşma, Egoractive ekibi bunu senden asla istemez.",
    footer: "Egora Games tarafından gönderildi · bu otomatik bir e-postadır",
  },
  en: {
    enterCode: "Enter this code in the app",
    expiry: (minutes) => `⏱ Expires in ${minutes} minutes`,
    ignore:
      "If you did not request this, you can safely ignore this email — your account is unaffected. Never share this code; the Egoractive team will never ask you for it.",
    footer: "Sent by Egora Games · this is an automated email",
  },
};

/** Kod konunun EN BAŞINDA — bildirim/QuickType önce konuyu okuyor. */
export function otpEmailSubject(purpose: OtpPurpose, code: string, locale: EmailLocale): string {
  return `${code} · ${COPY[purpose][locale].subjectSuffix}`;
}

export function otpEmailHtml(
  purpose: OtpPurpose,
  code: string,
  validMinutes: number,
  locale: EmailLocale,
): string {
  const c = COPY[purpose][locale];
  const preheader = PREHEADER[locale](code, validMinutes);
  const chrome = CHROME[locale];
  // Bazı istemciler önizlemeyi gövdenin GÖRÜNEN ilk metninden alıyor —
  // preheader'ı görünmez tutmak için dolgu (zero-width olmayan boşluk)
  // ekleniyor ki gerçek gövde metni önizlemeye sızmasın.
  const preheaderPadding = "&#8199;".repeat(28);

  return `<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="color-scheme" content="light dark">
<meta name="supported-color-schemes" content="light dark">
<style>
  body,table,td { font-family: 'Outfit','IBM Plex Sans',-apple-system,'Segoe UI',Roboto,Arial,sans-serif; }
  body { margin:0; padding:0; background:#eef2f8; }
  .paper { background:#eef2f8; }
  .card { background:#ffffff; }
  .ink { color:#0b1220; }
  .muted { color:#5b6472; }
  .border { border-color:#e3e9f1; }
  .tint { background:#e4f4ff; }
  @media (prefers-color-scheme: dark) {
    .paper { background:#0c1016 !important; }
    .card { background:#161b24 !important; }
    .ink { color:#eef2f8 !important; }
    .muted { color:#9aa3b5 !important; }
    .border { border-color:#262d3a !important; }
    .tint { background:#17273a !important; }
  }
</style>
</head>
<body class="paper">
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;mso-hide:all;">
    ${preheader}${preheaderPadding}
  </div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" class="paper">
    <tr><td align="center" style="padding:40px 20px;">
      <table role="presentation" width="100%" style="max-width:480px;" cellpadding="0" cellspacing="0">
        <tr><td align="center" style="padding-bottom:26px;">
          <img src="${LOGO_URL}" width="44" height="44" alt="Egoractive" style="border-radius:12px;display:block;">
        </td></tr>
        <tr><td>
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0" class="card border" style="border-radius:20px;border-width:1px;border-style:solid;box-shadow:0 1px 2px rgba(11,18,32,.04),0 12px 32px rgba(11,18,32,.08);">
            <tr><td style="padding:38px 36px 34px;">
              <div class="muted" style="font-size:11px;font-weight:600;letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px;">${c.eyebrow}</div>
              <div class="ink" style="font-size:22px;font-weight:600;line-height:1.3;margin-bottom:10px;letter-spacing:-.01em;">${c.heading}</div>
              <div class="muted" style="font-size:14.5px;line-height:1.6;margin-bottom:28px;">${c.intro}</div>

              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr><td align="center" style="background:#05a6fa;background-image:linear-gradient(135deg,#05a6fa,#0576b8);border-radius:16px;padding:22px 12px;">
                  <div style="font-size:40px;font-weight:700;letter-spacing:9px;color:#ffffff;font-variant-numeric:tabular-nums;font-family:'Outfit',sans-serif;">${code}</div>
                </td></tr>
              </table>

              <div class="muted" style="font-size:12.5px;text-align:center;margin-top:12px;">${chrome.enterCode}</div>

              <table role="presentation" cellpadding="0" cellspacing="0" style="margin:22px auto 0;">
                <tr><td class="tint" style="border-radius:999px;padding:7px 16px;">
                  <span class="ink" style="font-size:12.5px;font-weight:500;">${chrome.expiry(validMinutes)}</span>
                </td></tr>
              </table>

              <div class="border" style="border-top-width:1px;border-top-style:solid;margin:30px 0 22px;"></div>

              <div class="muted" style="font-size:12.5px;line-height:1.6;">
                ${chrome.ignore}
              </div>
            </td></tr>
          </table>
        </td></tr>
        <tr><td align="center" style="padding-top:24px;">
          <div class="muted" style="font-size:11.5px;line-height:1.7;">
            ${chrome.footer}
          </div>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}
