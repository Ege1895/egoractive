import { Firestore, Timestamp } from "firebase-admin/firestore";

export interface PackageSaleCount {
  packageName: string;
  count: number;
}

export interface OccupancyStats {
  count: number;
  capacity: number;
  attendance: number;
}

/** F5-11 — dönem içinde satın alınan paketlerin `packageName`'e göre satış
 * adedi, en çok satılandan aza sıralı. */
export async function fetchPackageSalesBreakdown(
  db: Firestore,
  gymId: string,
  periodStart: Date,
  periodEnd: Date,
): Promise<PackageSaleCount[]> {
  const snapshot = await db
    .collection("memberPackages")
    .where("gymId", "==", gymId)
    .where("purchasedAt", ">=", Timestamp.fromDate(periodStart))
    .where("purchasedAt", "<", Timestamp.fromDate(periodEnd))
    .get();

  const counts = new Map<string, number>();
  for (const doc of snapshot.docs) {
    const name = (doc.data().packageName as string | undefined) ?? "Diğer";
    counts.set(name, (counts.get(name) ?? 0) + 1);
  }

  return [...counts.entries()]
    .map(([packageName, count]) => ({ packageName, count }))
    .sort((a, b) => b.count - a.count);
}

/** F5-11 — grup dersleri ve etkinlikler için hacim düşük olduğundan (haftada/
 * ayda genelde birkaç düzine kayıt) dokümanlar doğrudan okunuyor —
 * `attendeeIds.length` bir `count()` aggregation'ı ile alınamaz. */
export async function fetchGroupSessionOccupancy(
  db: Firestore,
  gymId: string,
  periodStart: Date,
  periodEnd: Date,
): Promise<OccupancyStats> {
  const snapshot = await db
    .collection("groupSessions")
    .where("gymId", "==", gymId)
    .where("startTime", ">=", Timestamp.fromDate(periodStart))
    .where("startTime", "<", Timestamp.fromDate(periodEnd))
    .get();

  let capacity = 0;
  let attendance = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const attendeeCount = (data.attendeeIds as string[] | undefined)?.length ?? 0;
    capacity += (data.capacity as number | undefined) ?? 0;
    attendance += attendeeCount;
  }

  return { count: snapshot.size, capacity, attendance };
}

/** F5-11 — etkinlik `capacity`si `null` olabilir (sınırsız kontenjan); bu
 * durumda doluluk oranını anlamsızca düşürmemek için o etkinliğin kontenjanı
 * kendi katılımcı sayısıyla eşitlenir (o etkinlik %100 dolu sayılır). */
export async function fetchEventOccupancy(
  db: Firestore,
  gymId: string,
  periodStart: Date,
  periodEnd: Date,
): Promise<OccupancyStats> {
  const snapshot = await db
    .collection("events")
    .where("gymId", "==", gymId)
    .where("dateTime", ">=", Timestamp.fromDate(periodStart))
    .where("dateTime", "<", Timestamp.fromDate(periodEnd))
    .get();

  let capacity = 0;
  let attendance = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const attendeeCount = (data.attendeeIds as string[] | undefined)?.length ?? 0;
    const rawCapacity = data.capacity as number | null | undefined;
    capacity += rawCapacity ?? attendeeCount;
    attendance += attendeeCount;
  }

  return { count: snapshot.size, capacity, attendance };
}
