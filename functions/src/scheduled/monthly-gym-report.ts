import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { previousMonthRange } from "../shared/monthly-schedule";
import { REPORTS_DEEP_LINK } from "../shared/deep-links";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { safeTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { buildReportEmailHtml } from "../shared/report-email-template";
import { fetchEventOccupancy, fetchGroupSessionOccupancy, fetchPackageSalesBreakdown } from "../shared/report-extras-stats";
import { writeReportSnapshot } from "../shared/report-snapshots";
import { formatMonthInZone } from "../shared/timezone-math";
import {
  buildSessionTypeBreakdown,
  fetchDuetSessionDocs,
  fetchGymTrainerPerformance,
  fetchGymWeeklyStats,
} from "../shared/weekly-report-stats";

/**
 * F5-8/F5-11/F7-x — her ayın 1'inde 06:00'da (İstanbul saati, sabit cron —
 * artık Remote Config'ten okunmuyor, bkz. `weekly-gym-report.ts`'teki aynı
 * gerekçe) bir önceki ayı raporlar: örn. 1 Şubat'ta çalışınca Ocak raporu
 * gider (`previousMonthRange`). Her salonun aylık özetini
 * `weekly-gym-report.ts` ile AYNI zengin template'le gönderir — tek fark
 * kapsanan tarih aralığı. Hesaplama, aynı aggregation fonksiyonlarıyla
 * (F5-7) ay aralığı verilerek paylaşılıyor.
 */
export const monthlyGymReport = onSchedule(
  { schedule: "0 6 1 * *", timeZone: "Europe/Istanbul" },
  withFailureAlerting("monthlyGymReport", async () => {
  const db = getFirestore();
  const now = new Date();

  const { monthStart, monthEnd } = previousMonthRange(now);

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

    const [stats, packages, groupSessions, events, duetDocs] = await Promise.all([
      fetchGymWeeklyStats(db, gymDoc.id, monthStart, monthEnd),
      fetchPackageSalesBreakdown(db, gymDoc.id, monthStart, monthEnd),
      fetchGroupSessionOccupancy(db, gymDoc.id, monthStart, monthEnd),
      fetchEventOccupancy(db, gymDoc.id, monthStart, monthEnd),
      fetchDuetSessionDocs(db, gymDoc.id, monthStart, monthEnd),
    ]);
    const trainerPerformance = await fetchGymTrainerPerformance(db, gymDoc.id, monthStart, monthEnd, duetDocs);
    const { individualSessions, duetSessions } = buildSessionTypeBreakdown(stats, duetDocs);

    const html = buildReportEmailHtml({
      gymName,
      kind: "monthly",
      periodLabel,
      locale,
      sessions: stats,
      individualSessions,
      duetSessions,
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
      individualSessions,
      duetSessions,
      trainerPerformance,
      packages,
      groupSessions,
      events,
    });
  }
}));
