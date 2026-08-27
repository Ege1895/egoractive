import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { currentMonthRange, isMonthlyReportDue } from "../shared/monthly-schedule";
import { REPORTS_DEEP_LINK } from "../shared/deep-links";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { safeTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { buildReportEmailHtml } from "../shared/report-email-template";
import { fetchEventOccupancy, fetchGroupSessionOccupancy, fetchPackageSalesBreakdown } from "../shared/report-extras-stats";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { writeReportSnapshot } from "../shared/report-snapshots";
import { formatMonthInZone } from "../shared/timezone-math";
import { fetchGymTrainerPerformance, fetchGymWeeklyStats } from "../shared/weekly-report-stats";

/**
 * F5-8/F5-11 — RC'deki `cfg_monthly_report_day_of_month`/`cfg_monthly_report_hour`
 * zamanı geldiğinde (varsayılan ayın son günü 06:00, İstanbul saati) her
 * salonun aylık özetini `weekly-gym-report.ts` ile AYNI zengin template'le
 * gönderir — tek fark kapsanan tarih aralığı. Hesaplama, aynı aggregation
 * fonksiyonlarıyla (F5-7) ay aralığı verilerek paylaşılıyor.
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

  const gymsSnapshot = await db.collection("gyms").get();
  for (const gymDoc of gymsSnapshot.docs) {
    const data = gymDoc.data();
    const email = (data.reportEmails?.gym as string | undefined)?.trim();
    if (!email) {
      logger.info(`Salon ${gymDoc.id} için rapor e-postası ayarlanmamış, atlandı.`);
      continue;
    }

    const timeZone = safeTimeZone(data.timeZone as string | undefined);
    const locale = resolveNotificationLocale(timeZone);
    const periodLabel = formatMonthInZone(monthStart, timeZone, locale);
    const gymName = (data.name as string | undefined) ?? "Salonunuz";

    const [stats, trainerPerformance, packages, groupSessions, events] = await Promise.all([
      fetchGymWeeklyStats(db, gymDoc.id, monthStart, monthEnd),
      fetchGymTrainerPerformance(db, gymDoc.id, monthStart, monthEnd),
      fetchPackageSalesBreakdown(db, gymDoc.id, monthStart, monthEnd),
      fetchGroupSessionOccupancy(db, gymDoc.id, monthStart, monthEnd),
      fetchEventOccupancy(db, gymDoc.id, monthStart, monthEnd),
    ]);

    const html = buildReportEmailHtml({
      gymName,
      kind: "monthly",
      periodLabel,
      locale,
      sessions: stats,
      trainers: trainerPerformance,
      packages,
      groupSessions,
      events,
      deepLinkUrl: REPORTS_DEEP_LINK,
    });

    await queueEmail({
      to: email,
      subject: `${gymName} · ${locale === "tr" ? "Aylık Özet" : "Monthly Summary"} (${periodLabel})`,
      html,
    });

    await writeReportSnapshot(db, gymDoc.id, {
      period: "monthly",
      periodStart: monthStart,
      periodEnd: monthEnd,
      periodLabel,
      stats,
      trainerPerformance,
      packages,
      groupSessions,
      events,
    });
  }
}));
