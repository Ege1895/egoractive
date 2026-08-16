import { getFirestore } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatWeekRangeTr, formatTl } from "../shared/format";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { fetchGymWeeklyStats } from "../shared/weekly-report-stats";
import { isWeeklyReportDue, previousWeekRange } from "../shared/weekly-schedule";

function buildHtml(gymName: string, weekLabel: string, stats: Awaited<ReturnType<typeof fetchGymWeeklyStats>>): string {
  const completionPct = stats.totalSessions === 0 ? 0 : Math.round((stats.completedSessions / stats.totalSessions) * 100);
  return `
    <h2>${gymName} · Haftalık Özet</h2>
    <p>${weekLabel}</p>
    <table cellpadding="8" style="border-collapse: collapse;">
      <tr><td>Toplam ders</td><td><b>${stats.totalSessions}</b></td></tr>
      <tr><td>Tamamlanan</td><td><b>${stats.completedSessions}</b> (%${completionPct})</td></tr>
      <tr><td>İptal edilen</td><td><b>${stats.cancelledSessions}</b></td></tr>
      <tr><td>Tahmini ciro</td><td><b>${formatTl(stats.revenueTl)}</b></td></tr>
      <tr><td>Gider</td><td><b>${formatTl(stats.expensesTl)}</b></td></tr>
      <tr><td>Net</td><td><b>${formatTl(stats.revenueTl - stats.expensesTl)}</b></td></tr>
    </table>
  `;
}

/**
 * F5-2 — RC'deki `cfg_weekly_report_day_of_week`/`cfg_weekly_report_hour`
 * zamanı geldiğinde (varsayılan Pazartesi 06:00, İstanbul saati) her
 * salonun genel haftalık özetini `gyms/{gymId}.reportEmails.gym`'e
 * gönderir. Saatte bir çalışıp RC'yi kontrol etmesi, RC değeri
 * değiştiğinde yeniden deploy gerektirmemesi içindir.
 */
export const weeklyGymReport = onSchedule("every 60 minutes", withFailureAlerting("weeklyGymReport", async () => {
  const db = getFirestore();
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, haftalık salon raporu atlandı.", error);
    return;
  }

  if (!isWeeklyReportDue(template, now)) return;

  const { weekStart, weekEnd } = previousWeekRange(now);
  const weekLabel = formatWeekRangeTr(weekStart, weekEnd);

  const gymsSnapshot = await db.collection("gyms").get();
  for (const gymDoc of gymsSnapshot.docs) {
    const data = gymDoc.data();
    const email = (data.reportEmails?.gym as string | undefined)?.trim();
    if (!email) {
      logger.info(`Salon ${gymDoc.id} için rapor e-postası ayarlanmamış, atlandı.`);
      continue;
    }

    const stats = await fetchGymWeeklyStats(db, gymDoc.id, weekStart, weekEnd);
    await queueEmail({
      to: email,
      subject: `${(data.name as string | undefined) ?? "Salon"} · Haftalık Özet (${weekLabel})`,
      html: buildHtml((data.name as string | undefined) ?? "Salonunuz", weekLabel, stats),
    });
  }
}));
