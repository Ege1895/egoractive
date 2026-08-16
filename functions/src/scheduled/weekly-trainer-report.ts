import { getFirestore } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { formatWeekRangeTr } from "../shared/format";
import { withFailureAlerting } from "../shared/function-health";
import { queueEmail } from "../shared/mail";
import { fetchTrainerWeeklyStats } from "../shared/weekly-report-stats";
import { isWeeklyReportDue, previousWeekRange } from "../shared/weekly-schedule";

function buildHtml(trainerName: string, weekLabel: string, stats: Awaited<ReturnType<typeof fetchTrainerWeeklyStats>>): string {
  return `
    <h2>${trainerName} · Haftalık Ders Özetin</h2>
    <p>${weekLabel}</p>
    <table cellpadding="8" style="border-collapse: collapse;">
      <tr><td>Toplam ders</td><td><b>${stats.totalSessions}</b></td></tr>
      <tr><td>Tamamlanan</td><td><b>${stats.completedSessions}</b></td></tr>
    </table>
  `;
}

/**
 * F5-2 — her antrenöre SADECE kendi verisini içeren haftalık özeti
 * gönderir (`trainerId` filtreli sorgu — başka antrenörün verisi hiç
 * çekilmiyor). Antrenörün e-postası `users/{uid}.email` alanından okunur;
 * ayarlanmamışsa o antrenör atlanır.
 */
export const weeklyTrainerReport = onSchedule("every 60 minutes", withFailureAlerting("weeklyTrainerReport", async () => {
  const db = getFirestore();
  const now = new Date();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, haftalık antrenör raporu atlandı.", error);
    return;
  }

  if (!isWeeklyReportDue(template, now)) return;

  const { weekStart, weekEnd } = previousWeekRange(now);
  const weekLabel = formatWeekRangeTr(weekStart, weekEnd);

  const trainersSnapshot = await db.collection("users").where("role", "==", "trainer").get();
  for (const trainerDoc of trainersSnapshot.docs) {
    const data = trainerDoc.data();
    const email = (data.email as string | undefined)?.trim();
    const gymId = data.gymId as string | undefined;
    if (!email || !gymId) {
      logger.info(`Antrenör ${trainerDoc.id} için e-posta/salon bilgisi yok, atlandı.`);
      continue;
    }

    const stats = await fetchTrainerWeeklyStats(db, gymId, trainerDoc.id, weekStart, weekEnd);
    await queueEmail({
      to: email,
      subject: `Haftalık Ders Özetin (${weekLabel})`,
      html: buildHtml((data.name as string | undefined) ?? "Antrenör", weekLabel, stats),
    });
  }
}));
