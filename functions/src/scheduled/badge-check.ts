import { getFirestore } from "firebase-admin/firestore";
import { getRemoteConfig, RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

export interface BadgeCriterion {
  id: string;
  type: "sessionsCompleted" | "groupSessionJoins" | "eventJoins" | "membershipMonths";
  threshold: number;
}

export interface MemberMetrics {
  sessionsCompleted: number;
  groupSessionJoins: number;
  eventJoins: number;
  membershipMonths: number;
}

function readBadgeCriteria(template: RemoteConfigTemplate): BadgeCriterion[] {
  const param = template.parameters["cfg_badge_criteria"];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    if (!Array.isArray(parsed)) return [];
    return parsed.filter(
      (item): item is BadgeCriterion =>
        typeof item?.id === "string" && typeof item?.type === "string" && typeof item?.threshold === "number",
    );
  } catch (error) {
    logger.warn("cfg_badge_criteria JSON parse edilemedi.", error);
    return [];
  }
}

/**
 * F4-4 — kriterlerdeki `type`e göre üyenin metriğini eşiğe karşı ölçer,
 * halihazırda kazanılmamış olanlardan yeni hak edilenlerin id'lerini döner.
 * Kriterler kodda değil Remote Config'te (`cfg_badge_criteria`) tanımlı —
 * yeni bir rozet eklemek için store güncellemesi gerekmiyor (kabul kriteri).
 */
export function computeNewlyEarnedBadgeIds(
  criteria: BadgeCriterion[],
  metrics: MemberMetrics,
  existingBadgeIds: string[],
): string[] {
  return criteria
    .filter((criterion) => !existingBadgeIds.includes(criterion.id))
    .filter((criterion) => metrics[criterion.type] >= criterion.threshold)
    .map((criterion) => criterion.id);
}

function membershipMonthsSince(createdAt: FirebaseFirestore.Timestamp | undefined): number {
  if (!createdAt) return 0;
  const now = new Date();
  const created = createdAt.toDate();
  return (now.getFullYear() - created.getFullYear()) * 12 + (now.getMonth() - created.getMonth());
}

/**
 * Her gün 03:00'te çalışır: her üye için ders/grup dersi/etkinlik katılım
 * sayılarını ve üyelik süresini hesaplar, `cfg_badge_criteria`deki eşikleri
 * geçen ama henüz `users/{uid}.badges` içinde olmayan rozetleri ekler.
 */
export const badgeCheck = onSchedule("every day 03:00", async () => {
  const db = getFirestore();

  let template: RemoteConfigTemplate;
  try {
    template = await getRemoteConfig().getTemplate();
  } catch (error) {
    logger.warn("Remote Config okunamadı, badge kontrolü atlandı.", error);
    return;
  }

  const criteria = readBadgeCriteria(template);
  if (criteria.length === 0) {
    logger.info("cfg_badge_criteria boş, kontrol edilecek rozet yok.");
    return;
  }

  const membersSnapshot = await db.collection("users").where("role", "==", "member").get();
  if (membersSnapshot.empty) return;

  for (const memberDoc of membersSnapshot.docs) {
    const uid = memberDoc.id;
    const data = memberDoc.data();
    const existingBadgeIds = (data.badges as string[] | undefined) ?? [];

    const [completedSessions, groupSessionJoins, eventJoins] = await Promise.all([
      db.collection("sessions").where("memberId", "==", uid).where("status", "==", "completed").count().get(),
      db.collection("groupSessions").where("attendeeIds", "array-contains", uid).count().get(),
      db.collection("events").where("attendeeIds", "array-contains", uid).count().get(),
    ]);

    const metrics: MemberMetrics = {
      sessionsCompleted: completedSessions.data().count,
      groupSessionJoins: groupSessionJoins.data().count,
      eventJoins: eventJoins.data().count,
      membershipMonths: membershipMonthsSince(data.createdAt as FirebaseFirestore.Timestamp | undefined),
    };

    const newlyEarned = computeNewlyEarnedBadgeIds(criteria, metrics, existingBadgeIds);
    if (newlyEarned.length === 0) continue;

    await memberDoc.ref.update({ badges: [...existingBadgeIds, ...newlyEarned] });
    logger.info(`Üye ${uid} yeni rozet kazandı: ${newlyEarned.join(", ")}`);
  }
});
