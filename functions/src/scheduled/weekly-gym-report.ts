import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { REPORTS_DEEP_LINK } from "../shared/deep-links";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { safeTimeZone, resolveNotificationLocale } from "../shared/notification-locale";
import { buildReportEmailHtml } from "../shared/report-email-template";
import { fetchEventOccupancy, fetchGroupSessionOccupancy, fetchPackageSalesBreakdown } from "../shared/report-extras-stats";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";
import { writeReportSnapshot } from "../shared/report-snapshots";
import { formatDateInZone } from "../shared/timezone-math";
import { fetchGymTrainerPerformance, fetchGymWeeklyStats } from "../shared/weekly-report-stats";
import { isWeeklyReportDue, previousWeekRange } from "../shared/weekly-schedule";

/**
 * F5-2/F5-11 — RC'deki `cfg_weekly_report_day_of_week`/`cfg_weekly_report_hour`
 * zamanı geldiğinde (varsayılan Pazartesi 06:00, İstanbul saati) her salonun
 * zengin haftalık özet mailini `gyms/{gymId}.reportEmails.gym`'e gönderir.
 * Mail dili salonun `timeZone`'una göre seçilir (Türkiye ise tr, değilse en
 * — bkz. `resolveNotificationLocale`). Antrenöre ayrı bir haftalık mail
 * ARTIK gönderilmiyor — rapor mailleri sadece admin'e gider (F5-12 kararı).
 */
export const weeklyGymReport = onSchedule("every 60 minutes", withFailureAlerting("weeklyGymReport", async () => {
  const db = getFirestore();
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch (error) {
    logger.warn("Remote Config cache okunamadı, haftalık salon raporu atlandı.", error);
    return;
  }

  if (!isWeeklyReportDue(template, now)) return;

  const { weekStart, weekEnd } = previousWeekRange(now);
  const lastDay = new Date(weekEnd.getTime() - 24 * 60 * 60 * 1000);

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
    const periodLabel = `${formatDateInZone(weekStart, timeZone, locale, true)} – ${formatDateInZone(lastDay, timeZone, locale, true)}`;
    const gymName = (data.name as string | undefined) ?? "Salonunuz";

    const [stats, trainerPerformance, packages, groupSessions, events] = await Promise.all([
      fetchGymWeeklyStats(db, gymDoc.id, weekStart, weekEnd),
      fetchGymTrainerPerformance(db, gymDoc.id, weekStart, weekEnd),
      fetchPackageSalesBreakdown(db, gymDoc.id, weekStart, weekEnd),
      fetchGroupSessionOccupancy(db, gymDoc.id, weekStart, weekEnd),
      fetchEventOccupancy(db, gymDoc.id, weekStart, weekEnd),
    ]);

    const html = buildReportEmailHtml({
      gymName,
      kind: "weekly",
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
      subject: `${gymName} · ${locale === "tr" ? "Haftalık Özet" : "Weekly Summary"} (${periodLabel})`,
      html,
    });

    await writeReportSnapshot(db, gymDoc.id, {
      period: "weekly",
      periodStart: weekStart,
      periodEnd: weekEnd,
      periodLabel,
      stats,
      trainerPerformance,
      packages,
      groupSessions,
      events,
    });
  }
}));
