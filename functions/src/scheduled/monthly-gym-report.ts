import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatMonthLabelTr, formatTl } from "../shared/format";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { currentMonthRange, isMonthlyReportDue } from "../shared/monthly-schedule";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { writeReportSnapshot } from "../shared/report-snapshots";
import { fetchGymTrainerPerformance, fetchGymWeeklyStats } from "../shared/weekly-report-stats";

function buildHtml(gymName: string, monthLabel: string, stats: Awaited<ReturnType<typeof fetchGymWeeklyStats>>): string {
  const completionPct = stats.totalSessions === 0 ? 0 : Math.round((stats.completedSessions / stats.totalSessions) * 100);
  return `
    <h2>${gymName} · Aylık Özet</h2>
    <p>${monthLabel}</p>
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
 * F5-8 — RC'deki `cfg_monthly_report_day_of_month`/`cfg_monthly_report_hour`
 * zamanı geldiğinde (varsayılan ayın son günü 06:00, İstanbul saati) her
 * salonun aylık özetini `gyms/{gymId}.reportEmails.gym`'e gönderir ve
 * F5-7'deki gibi bir `period: 'monthly'` snapshot yazar. Hesaplama, F5-7'de
 * haftalık rapor için yazılan aynı fonksiyonlarla (`fetchGymWeeklyStats`/
 * `fetchGymTrainerPerformance`) — sadece ay aralığı verilerek — paylaşılıyor.
 */
export const monthlyGymReport = onSchedule("every 60 minutes", withFailureAlerting("monthlyGymReport", async () => {
  const db = getFirestore();
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch (error) {
    logger.warn("Remote Config cache okunamadı, aylık salon raporu atlandı.", error);
    return;
  }

  if (!isMonthlyReportDue(template, now)) return;

  const { monthStart, monthEnd } = currentMonthRange(now);
  const monthLabel = formatMonthLabelTr(monthStart);

  const gymsSnapshot = await db.collection("gyms").get();
  for (const gymDoc of gymsSnapshot.docs) {
    const data = gymDoc.data();
    const email = (data.reportEmails?.gym as string | undefined)?.trim();
    if (!email) {
      logger.info(`Salon ${gymDoc.id} için rapor e-postası ayarlanmamış, atlandı.`);
      continue;
    }

    const stats = await fetchGymWeeklyStats(db, gymDoc.id, monthStart, monthEnd);
    await queueEmail({
      to: email,
      subject: `${(data.name as string | undefined) ?? "Salon"} · Aylık Özet (${monthLabel})`,
      html: buildHtml((data.name as string | undefined) ?? "Salonunuz", monthLabel, stats),
    });

    const trainerPerformance = await fetchGymTrainerPerformance(db, gymDoc.id, monthStart, monthEnd);
    await writeReportSnapshot(db, gymDoc.id, {
      period: "monthly",
      periodStart: monthStart,
      periodEnd: monthEnd,
      periodLabel: monthLabel,
      stats,
      trainerPerformance,
    });
  }
}));
