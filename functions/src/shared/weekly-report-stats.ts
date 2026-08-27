import { AggregateField, Firestore, Timestamp } from "firebase-admin/firestore";

export interface GymWeeklyStats {
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
  revenueTl: number;
  expensesTl: number;
}

export interface TrainerWeeklyStats {
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
}

export interface TrainerPerformance {
  trainerId: string;
  name: string;
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
}

/** F5-1'deki dashboard ile aynı yaklaşım: sayımlar `count()`/`sum()`
 * aggregation query'leriyle, hiçbir doküman client'a (fonksiyona) çekilmeden
 * hesaplanır. */
export async function fetchGymWeeklyStats(
  db: Firestore,
  gymId: string,
  weekStart: Date,
  weekEnd: Date,
): Promise<GymWeeklyStats> {
  const start = Timestamp.fromDate(weekStart);
  const end = Timestamp.fromDate(weekEnd);

  const weekSessions = db
    .collection("sessions")
    .where("gymId", "==", gymId)
    .where("startTime", ">=", start)
    .where("startTime", "<", end);

  const [totalSnap, completedSnap, cancelledSnap, revenueSnap, expensesSnap] = await Promise.all([
    weekSessions.count().get(),
    weekSessions.where("status", "==", "completed").count().get(),
    weekSessions.where("status", "==", "cancelled").count().get(),
    db
      .collection("memberPackages")
      .where("gymId", "==", gymId)
      .where("purchasedAt", ">=", start)
      .where("purchasedAt", "<", end)
      .aggregate({ total: AggregateField.sum("paidAmount") })
      .get(),
    db
      .collection("expenses")
      .where("gymId", "==", gymId)
      .where("date", ">=", start)
      .where("date", "<", end)
      .aggregate({ total: AggregateField.sum("amountTl") })
      .get(),
  ]);

  return {
    totalSessions: totalSnap.data().count,
    completedSessions: completedSnap.data().count,
    cancelledSessions: cancelledSnap.data().count,
    revenueTl: Math.round(revenueSnap.data().total ?? 0),
    expensesTl: Math.round(expensesSnap.data().total ?? 0),
  };
}

export async function fetchTrainerWeeklyStats(
  db: Firestore,
  gymId: string,
  trainerId: string,
  weekStart: Date,
  weekEnd: Date,
): Promise<TrainerWeeklyStats> {
  const start = Timestamp.fromDate(weekStart);
  const end = Timestamp.fromDate(weekEnd);
  const weekSessions = db
    .collection("sessions")
    .where("gymId", "==", gymId)
    .where("trainerId", "==", trainerId)
    .where("startTime", ">=", start)
    .where("startTime", "<", end);

  const [totalSnap, completedSnap, cancelledSnap] = await Promise.all([
    weekSessions.count().get(),
    weekSessions.where("status", "==", "completed").count().get(),
    weekSessions.where("status", "==", "cancelled").count().get(),
  ]);

  return {
    totalSessions: totalSnap.data().count,
    completedSessions: completedSnap.data().count,
    cancelledSessions: cancelledSnap.data().count,
  };
}

/** F5-7 — gym rapor snapshot'ı için salonun tüm antrenörlerinin performans
 * dökümü. `fetchGymWeeklyStats` ile aynı `count()` aggregation yaklaşımı,
 * antrenör başına iki sorguya bölünmüş halde. */
export async function fetchGymTrainerPerformance(
  db: Firestore,
  gymId: string,
  weekStart: Date,
  weekEnd: Date,
): Promise<TrainerPerformance[]> {
  const trainersSnapshot = await db
    .collection("users")
    .where("gymId", "==", gymId)
    .where("role", "==", "trainer")
    .get();

  const trainerPerformance = await Promise.all(
    trainersSnapshot.docs.map(async (trainerDoc) => {
      const stats = await fetchTrainerWeeklyStats(db, gymId, trainerDoc.id, weekStart, weekEnd);
      return {
        trainerId: trainerDoc.id,
        name: (trainerDoc.data().name as string | undefined) ?? "—",
        totalSessions: stats.totalSessions,
        completedSessions: stats.completedSessions,
        cancelledSessions: stats.cancelledSessions,
      };
    }),
  );

  return trainerPerformance.sort((a, b) => b.completedSessions - a.completedSessions);
}
