import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatDateTr, formatWeekRangeTr } from "../shared/format";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { isWeeklyReportDue, previousWeekRange } from "../shared/weekly-schedule";

/** Egora Games'in kendi işletme raporu — salon başına değil, tek bir sabit adrese gider. */
const OWNER_EMAIL = "egoragames@gmail.com";

interface GymSubscriptionRow {
  name: string;
  status: string;
  trialEndsAt: Date | null;
}

function readIntParam(template: RemoteConfigTemplate, key: string, fallback: number): number {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = raw === undefined ? NaN : Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function buildHtml(weekLabel: string, rows: GymSubscriptionRow[]): string {
  const counts = new Map<string, number>();
  for (const row of rows) counts.set(row.status, (counts.get(row.status) ?? 0) + 1);

  const countRows = [...counts.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([status, count]) => `<tr><td>${status}</td><td><b>${count}</b></td></tr>`)
    .join("");

  const now = new Date();
  const soon = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
  const expiringSoon = rows.filter((r) => r.status === "trial" && r.trialEndsAt && r.trialEndsAt <= soon);
  const expiringRows = expiringSoon.length === 0
    ? "<tr><td colspan=\"2\">Önümüzdeki 7 gün içinde deneme süresi biten salon yok.</td></tr>"
    : expiringSoon
        .map((r) => `<tr><td>${r.name}</td><td>${r.trialEndsAt ? formatDateTr(r.trialEndsAt) : "—"}</td></tr>`)
        .join("");

  return `
    <h2>Egoractive · Haftalık Abone Özeti</h2>
    <p>${weekLabel}</p>
    <p>Toplam salon: <b>${rows.length}</b></p>
    <table cellpadding="8" style="border-collapse: collapse;">${countRows}</table>
    <h3>Deneme süresi 7 gün içinde bitecek salonlar</h3>
    <table cellpadding="8" style="border-collapse: collapse;">${expiringRows}</table>
  `;
}

/**
 * F6-1 — RevenueCat kullanılmıyor: abonelik durumu `gyms/{gymId}.subscriptionStatus`
 * alanında tutuluyor (verifySubscriptionPurchase Cloud Function'ı yazıyor).
 * Bu fonksiyon haftalık olarak (F5-2'deki `weeklyGymReport` ile aynı RC
 * kontrolü — `cfg_weekly_report_day_of_week`/`cfg_weekly_report_hour`) tüm
 * salonların abonelik durumunu özetleyip Egora Games'in kendi mailine
 * (sabit adres, salon bazlı değil) gönderir.
 */
export const weeklySubscriberSummary = onSchedule("every 60 minutes", withFailureAlerting("weeklySubscriberSummary", async () => {
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch (error) {
    logger.warn("Remote Config cache okunamadı, haftalık abone özeti atlandı.", error);
    return;
  }

  if (!isWeeklyReportDue(template, now)) return;

  const db = getFirestore();
  const { weekStart, weekEnd } = previousWeekRange(now);
  const weekLabel = formatWeekRangeTr(weekStart, weekEnd);

  const trialDurationDays = readIntParam(template, "cfg_trial_duration_days", 14);
  const gymsSnapshot = await db.collection("gyms").get();
  const rows: GymSubscriptionRow[] = gymsSnapshot.docs.map((doc) => {
    const data = doc.data();
    const trialStartedAt = data.trialStartedAt?.toDate?.() as Date | undefined;
    const trialEndsAt = trialStartedAt
      ? new Date(trialStartedAt.getTime() + trialDurationDays * 24 * 60 * 60 * 1000)
      : null;

    return {
      name: (data.name as string | undefined) ?? doc.id,
      status: (data.subscriptionStatus as string | undefined) ?? "none",
      trialEndsAt,
    };
  });

  await queueEmail({
    to: OWNER_EMAIL,
    subject: `Egoractive · Haftalık Abone Özeti (${weekLabel})`,
    html: buildHtml(weekLabel, rows),
  });

  logger.info(`Haftalık abone özeti gönderildi: ${rows.length} salon.`);
}));
