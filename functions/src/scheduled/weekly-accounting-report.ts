import { getFirestore } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatWeekRangeTr, formatTl } from "../shared/format";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { fetchExpenseCategoryTotals, fetchGymWeeklyStats } from "../shared/weekly-report-stats";
import { isWeeklyReportDue, previousWeekRange } from "../shared/weekly-schedule";

function buildHtml(
  gymName: string,
  weekLabel: string,
  stats: Awaited<ReturnType<typeof fetchGymWeeklyStats>>,
  categoryTotals: Awaited<ReturnType<typeof fetchExpenseCategoryTotals>>,
): string {
  const categoryRows = categoryTotals.length === 0
    ? "<tr><td colspan=\"2\">Bu hafta gider girişi yok.</td></tr>"
    : categoryTotals.map((c) => `<tr><td>${c.category}</td><td>${formatTl(c.amountTl)}</td></tr>`).join("");

  return `
    <h2>${gymName} · Haftalık Muhasebe Özeti</h2>
    <p>${weekLabel}</p>
    <table cellpadding="8" style="border-collapse: collapse;">
      <tr><td>Tahmini ciro</td><td><b>${formatTl(stats.revenueTl)}</b></td></tr>
      <tr><td>Toplam gider</td><td><b>${formatTl(stats.expensesTl)}</b></td></tr>
      <tr><td>Net</td><td><b>${formatTl(stats.revenueTl - stats.expensesTl)}</b></td></tr>
    </table>
    <h3>Gider kırılımı</h3>
    <table cellpadding="8" style="border-collapse: collapse;">${categoryRows}</table>
  `;
}

/**
 * F5-2 — `gyms/{gymId}.reportEmails.accounting`'e haftalık ciro/gider
 * kırılımı gönderir. Zamanlama mantığı `weeklyGymReport` ile aynı (RC
 * kontrolü, saatte bir çalışır).
 */
export const weeklyAccountingReport = onSchedule("every 60 minutes", withFailureAlerting("weeklyAccountingReport", async () => {
  const db = getFirestore();
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, haftalık muhasebe raporu atlandı.", error);
    return;
  }

  if (!isWeeklyReportDue(template, now)) return;

  const { weekStart, weekEnd } = previousWeekRange(now);
  const weekLabel = formatWeekRangeTr(weekStart, weekEnd);

  const gymsSnapshot = await db.collection("gyms").get();
  for (const gymDoc of gymsSnapshot.docs) {
    const data = gymDoc.data();
    const email = (data.reportEmails?.accounting as string | undefined)?.trim();
    if (!email) {
      logger.info(`Salon ${gymDoc.id} için muhasebe e-postası ayarlanmamış, atlandı.`);
      continue;
    }

    const [stats, categoryTotals] = await Promise.all([
      fetchGymWeeklyStats(db, gymDoc.id, weekStart, weekEnd),
      fetchExpenseCategoryTotals(db, gymDoc.id, weekStart, weekEnd),
    ]);

    await queueEmail({
      to: email,
      subject: `${(data.name as string | undefined) ?? "Salon"} · Haftalık Muhasebe Özeti (${weekLabel})`,
      html: buildHtml((data.name as string | undefined) ?? "Salonunuz", weekLabel, stats, categoryTotals),
    });
  }
}));
