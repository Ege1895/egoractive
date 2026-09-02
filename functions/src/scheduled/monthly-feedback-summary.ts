import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { currentMonthRange, isLastDayOfMonth } from "../shared/monthly-schedule";
import { resolveNotificationLocale, safeTimeZone } from "../shared/notification-locale";
import { formatMonthInZone } from "../shared/timezone-math";

/**
 * Metinler salonun bulunduğu yere göre — haftalık/aylık salon raporlarıyla
 * aynı kural (bkz. `notification-locale.ts`). Önceden bu özet dilden
 * bağımsız olarak Türkçe gidiyordu; ay adı da `formatMonthLabelTr` ile
 * sabit Türkçe biçimleniyordu.
 */
const COPY = {
  tr: {
    subjectSuffix: "Aylık Geri Bildirim Özeti",
    heading: "Aylık Geri Bildirim Özeti",
    average: "Ortalama puan",
    total: "Toplam değerlendirme",
    fallbackGymName: "Salonunuz",
  },
  en: {
    subjectSuffix: "Monthly Feedback Summary",
    heading: "Monthly Feedback Summary",
    average: "Average rating",
    total: "Total reviews",
    fallbackGymName: "Your gym",
  },
} as const;

function buildHtml(
  gymName: string,
  monthLabel: string,
  average: number,
  totalCount: number,
  locale: "tr" | "en",
): string {
  const copy = COPY[locale];
  return `
    <h2>${gymName} · ${copy.heading}</h2>
    <p>${monthLabel}</p>
    <table cellpadding="8" style="border-collapse: collapse;">
      <tr><td>${copy.average}</td><td><b>${totalCount === 0 ? "—" : average.toFixed(1)}</b> / 5</td></tr>
      <tr><td>${copy.total}</td><td><b>${totalCount}</b></td></tr>
    </table>
  `;
}

/**
 * F5-4 — ayın son günü, her salonun `reportEmails.gym` adresine o ayın
 * geri bildirim özetini (ortalama puan + toplam sayı) gönderir.
 * `feedbackReminderCheck` ile aynı günlük "İstanbul 10:00" cron'unu
 * paylaşır — ikisi de tek bir RC kontrolü yerine kendi mantığını (sabit
 * gün vs. ayın son günü) bağımsız uyguluyor.
 */
export const monthlyFeedbackSummary = onSchedule(
  { schedule: "every day 10:00", timeZone: "Europe/Istanbul" },
  withFailureAlerting("monthlyFeedbackSummary", async () => {
    const now = new Date();
    if (!isLastDayOfMonth(now)) return;

    const db = getFirestore();
    const { monthStart, monthEnd } = currentMonthRange(now);

    const gymsSnapshot = await db.collection("gyms").get();
    for (const gymDoc of gymsSnapshot.docs) {
      const data = gymDoc.data();
      const email = (data.reportEmails?.gym as string | undefined)?.trim();
      if (!email) {
        logger.info(`Salon ${gymDoc.id} için rapor e-postası ayarlanmamış, aylık feedback özeti atlandı.`);
        continue;
      }

      const snapshot = await db
        .collection("feedback")
        .where("gymId", "==", gymDoc.id)
        .where("createdAt", ">=", monthStart)
        .where("createdAt", "<", monthEnd)
        .get();

      const timeZone = safeTimeZone(data.timeZone as string | undefined);
      const locale = resolveNotificationLocale(timeZone);
      const copy = COPY[locale];
      const monthLabel = formatMonthInZone(monthStart, timeZone, locale);
      const gymName = (data.name as string | undefined) ?? copy.fallbackGymName;

      const totalCount = snapshot.size;
      const totalStars = snapshot.docs.reduce((sum, doc) => sum + ((doc.data().stars as number | undefined) ?? 0), 0);
      const average = totalCount === 0 ? 0 : totalStars / totalCount;

      await queueEmail({
        to: email,
        subject: `${gymName} · ${copy.subjectSuffix}`,
        html: buildHtml(gymName, monthLabel, average, totalCount, locale),
      });
    }
  }),
);
