import { getFirestore } from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatMonthLabelTr } from "../shared/format";
import { queueEmail } from "../shared/mail";
import { currentMonthRange, isLastDayOfMonth } from "../shared/monthly-schedule";

function buildHtml(gymName: string, monthLabel: string, average: number, totalCount: number): string {
  return `
    <h2>${gymName} · Aylık Geri Bildirim Özeti</h2>
    <p>${monthLabel}</p>
    <table cellpadding="8" style="border-collapse: collapse;">
      <tr><td>Ortalama puan</td><td><b>${totalCount === 0 ? "—" : average.toFixed(1)}</b> / 5</td></tr>
      <tr><td>Toplam değerlendirme</td><td><b>${totalCount}</b></td></tr>
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
  async () => {
    const now = new Date();
    if (!isLastDayOfMonth(now)) return;

    const db = getFirestore();
    const { monthStart, monthEnd } = currentMonthRange(now);
    const monthLabel = formatMonthLabelTr(monthStart);

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

      const totalCount = snapshot.size;
      const totalStars = snapshot.docs.reduce((sum, doc) => sum + ((doc.data().stars as number | undefined) ?? 0), 0);
      const average = totalCount === 0 ? 0 : totalStars / totalCount;

      await queueEmail({
        to: email,
        subject: `${(data.name as string | undefined) ?? "Salon"} · Aylık Geri Bildirim Özeti`,
        html: buildHtml((data.name as string | undefined) ?? "Salonunuz", monthLabel, average, totalCount),
      });
    }
  },
);
