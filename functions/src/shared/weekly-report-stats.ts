import { AggregateField, Firestore, Timestamp } from "firebase-admin/firestore";
import { isDeactivated } from "./user-active";

export interface GymWeeklyStats {
  totalSessions: number;
  completedSessions: number;
  cancelledSessions: number;
  revenueTl: number;
  expensesTl: number;
}

export interface SessionTypeBreakdown {
  total: number;
  completed: number;
  cancelled: number;
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
  soloSessions: number;
  duetSessions: number;
  // Grup dersleri hangi antrenöre ait olduğunu tutmuyor — `groupSessions`
  // koleksiyonu sadece admin oluşturabiliyor ve `trainerName` her zaman
  // oluşturan admin'in adı, gerçek bir antrenör seçici yok. Bu yüzden
  // antrenör bazlı grup dersi sayısı henüz hesaplanamıyor, her zaman 0.
  groupSessions: number;
}

export interface DuetSessionDoc {
  trainerId: string | undefined;
  duetGroupId: string | undefined;
  status: string | undefined;
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

/** F7-x — `sessions` koleksiyonu hem birebir (`sessionType: 'individual'`)
 * hem düet (`sessionType: 'duet'`) derslerini tutar; bir düet dersin her
 * üyesi kendi dokümanına sahip olduğundan (aynı `duetGroupId`'yi
 * paylaşırlar) çift saymamak için `duetGroupId`'ye göre tekilleştirme
 * gerekir. Bu tekilleştirme bir `count()` aggregation'ıyla yapılamadığından
 * — ve hacmi toplam seanslara göre çok daha düşük olduğundan (bkz.
 * `fetchGroupSessionOccupancy`'deki aynı yaklaşım) — düet dokümanları
 * doğrudan çekilip hem gym hem antrenör bazlı kırılım için burada
 * paylaşılıyor.
 */
export async function fetchDuetSessionDocs(
  db: Firestore,
  gymId: string,
  periodStart: Date,
  periodEnd: Date,
): Promise<DuetSessionDoc[]> {
  const snapshot = await db
    .collection("sessions")
    .where("gymId", "==", gymId)
    .where("sessionType", "==", "duet")
    .where("startTime", ">=", Timestamp.fromDate(periodStart))
    .where("startTime", "<", Timestamp.fromDate(periodEnd))
    .get();

  return snapshot.docs.map((doc) => ({
    trainerId: doc.data().trainerId as string | undefined,
    duetGroupId: doc.data().duetGroupId as string | undefined,
    status: doc.data().status as string | undefined,
  }));
}

function dedupeDuetBreakdown(docs: DuetSessionDoc[]): SessionTypeBreakdown {
  const total = new Set<string>();
  const completed = new Set<string>();
  const cancelled = new Set<string>();
  for (const doc of docs) {
    if (!doc.duetGroupId) continue;
    total.add(doc.duetGroupId);
    if (doc.status === "completed") completed.add(doc.duetGroupId);
    if (doc.status === "cancelled") cancelled.add(doc.duetGroupId);
  }
  return { total: total.size, completed: completed.size, cancelled: cancelled.size };
}

/** F7-x — Ders Özeti bölümünün Birebir/Düet kırılımı. Birebir sayıları,
 * `fetchGymWeeklyStats`'ın döndürdüğü (düet dokümanlarını da içeren) toplam
 * sayılardan ham düet doküman sayısı (tekilleştirilmemiş) çıkarılarak elde
 * edilir — bu sayede birebir için ayrı bir `count()` sorgusu/index
 * gerekmez.
 */
export function buildSessionTypeBreakdown(
  stats: GymWeeklyStats,
  duetDocs: DuetSessionDoc[],
): { individualSessions: SessionTypeBreakdown; duetSessions: SessionTypeBreakdown } {
  const duetSessions = dedupeDuetBreakdown(duetDocs);
  const duetRawTotal = duetDocs.length;
  const duetRawCompleted = duetDocs.filter((d) => d.status === "completed").length;
  const duetRawCancelled = duetDocs.filter((d) => d.status === "cancelled").length;

  const individualSessions: SessionTypeBreakdown = {
    total: Math.max(stats.totalSessions - duetRawTotal, 0),
    completed: Math.max(stats.completedSessions - duetRawCompleted, 0),
    cancelled: Math.max(stats.cancelledSessions - duetRawCancelled, 0),
  };

  return { individualSessions, duetSessions };
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
  duetDocs: DuetSessionDoc[],
): Promise<TrainerPerformance[]> {
  const trainersSnapshot = await db
    .collection("users")
    .where("gymId", "==", gymId)
    .where("role", "==", "trainer")
    .get();

  // Pasife alınmış antrenörler (bkz. `deactivateTrainer`) BİLEREK sorgunun
  // içinde kalıyor: `users` dokümanları silinmediği için, çalıştıkları
  // dönemlerin raporlarında geçmiş verileriyle görünmeye devam ederler —
  // ürün kararı buydu. Aşağıda sadece o dönemde HİÇ seansı olmayanlar
  // eleniyor, yoksa ayrıldıktan sonraki her raporda 0/0 ile yer kaplarlardı.
  const trainerPerformance = await Promise.all(
    trainersSnapshot.docs.map(async (trainerDoc) => {
      const stats = await fetchTrainerWeeklyStats(db, gymId, trainerDoc.id, weekStart, weekEnd);
      const trainerDuetDocs = duetDocs.filter((d) => d.trainerId === trainerDoc.id);
      const trainerDuetGroupIds = new Set(
        trainerDuetDocs.map((d) => d.duetGroupId).filter((id): id is string => !!id),
      );
      const performance: TrainerPerformance = {
        trainerId: trainerDoc.id,
        name: (trainerDoc.data().name as string | undefined) ?? "—",
        totalSessions: stats.totalSessions,
        completedSessions: stats.completedSessions,
        cancelledSessions: stats.cancelledSessions,
        soloSessions: Math.max(stats.totalSessions - trainerDuetDocs.length, 0),
        duetSessions: trainerDuetGroupIds.size,
        groupSessions: 0,
      };
      return { deactivated: isDeactivated(trainerDoc.data()), performance };
    }),
  );

  return trainerPerformance
    .filter((row) => !row.deactivated || row.performance.totalSessions > 0)
    .map((row) => row.performance)
    .sort((a, b) => b.completedSessions - a.completedSessions);
}
