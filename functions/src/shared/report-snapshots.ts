import { Firestore, Timestamp } from "firebase-admin/firestore";

import { OccupancyStats, PackageSaleCount } from "./report-extras-stats";
import { GymWeeklyStats, SessionTypeBreakdown, TrainerPerformance } from "./weekly-report-stats";

export type ReportPeriod = "weekly" | "monthly";

export interface ReportSnapshotInput {
  period: ReportPeriod;
  periodStart: Date;
  periodEnd: Date;
  periodLabel: string;
  stats: GymWeeklyStats;
  individualSessions: SessionTypeBreakdown;
  duetSessions: SessionTypeBreakdown;
  trainerPerformance: TrainerPerformance[];
  packages: PackageSaleCount[];
  groupSessions: OccupancyStats;
  events: OccupancyStats;
  currency: string;
}

function snapshotDocId(period: ReportPeriod, periodStart: Date): string {
  return `${period}_${periodStart.toISOString().slice(0, 10)}`;
}

/**
 * F5-7 — haftalık/aylık mail fonksiyonları ile Raporlar ekranının (F5-9)
 * ortak veri kaynağı. Aynı aggregation hesaplaması iki kez (bir mail için,
 * bir de app için) yapılmasın diye scheduled fonksiyon hesapladığı özeti
 * burada da saklar; PDF üretilmez, sadece yapılandırılmış veri.
 */
export async function writeReportSnapshot(db: Firestore, gymId: string, input: ReportSnapshotInput): Promise<void> {
  const docId = snapshotDocId(input.period, input.periodStart);
  await db
    .collection("gyms")
    .doc(gymId)
    .collection("reportSnapshots")
    .doc(docId)
    .set({
      period: input.period,
      periodStart: Timestamp.fromDate(input.periodStart),
      periodEnd: Timestamp.fromDate(input.periodEnd),
      periodLabel: input.periodLabel,
      totalSessions: input.stats.totalSessions,
      completedSessions: input.stats.completedSessions,
      cancelledSessions: input.stats.cancelledSessions,
      estimatedRevenueTl: input.stats.revenueTl,
      totalExpensesTl: input.stats.expensesTl,
      individualSessions: input.individualSessions,
      duetSessions: input.duetSessions,
      trainerPerformance: input.trainerPerformance.map((trainer) => ({
        trainerId: trainer.trainerId,
        name: trainer.name,
        totalSessions: trainer.totalSessions,
        completedSessions: trainer.completedSessions,
        cancelledSessions: trainer.cancelledSessions,
        soloSessions: trainer.soloSessions,
        duetSessions: trainer.duetSessions,
        groupSessions: trainer.groupSessions,
      })),
      packages: input.packages,
      groupSessions: input.groupSessions,
      events: input.events,
      currency: input.currency,
      createdAt: Timestamp.now(),
    });
}
