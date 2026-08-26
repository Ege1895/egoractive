import { RemoteConfigTemplate } from "firebase-admin/remote-config";

/**
 * `lbl_notif_*` metinlerini okuyan ortak yardımcı — seans hatırlatma/
 * tamamlama/feedback dosyalarındaki (ör. `tasks/send-session-reminder-task.ts`)
 * aynı desenin tekrarı, sadece burada paylaşılıyor ki yeni bildirim türleri
 * (etkinlik/grup dersi duyurusu+hatırlatması) her seferinde aynı 6-8
 * satırı kopyalamasın. Eski dosyalar bilerek dokunulmadan bırakıldı —
 * çalışan koda gereksiz risk almamak için.
 */
export function readRemoteConfigParam(template: RemoteConfigTemplate, key: string): string | undefined {
  const param = template.parameters[key];
  return param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
}

export function readLocalizedNotificationText(
  template: RemoteConfigTemplate,
  baseKey: string,
  locale: string,
  vars: Record<string, string>,
  defaults: Record<string, { tr: string; en: string }>,
): string {
  const lang = locale === "tr" ? "tr" : "en";
  const raw = readRemoteConfigParam(template, `${baseKey}_${lang}`) ?? defaults[baseKey][lang];
  return Object.entries(vars).reduce((text, [key, value]) => text.replaceAll(`{${key}}`, value), raw);
}
