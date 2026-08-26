import { getFirestore } from "firebase-admin/firestore";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { mapWithConcurrency } from "../shared/concurrency";
import { withFailureAlerting } from "../shared/function-health";
import { getCachedRemoteConfigTemplate } from "../shared/remote-config-cache";

/** Aynı anda en fazla bu kadar üye işlenir — büyük salonlarda (F7-2'nin
 * 10.000 üyelik yük testi ölçeği) tamamen sıralı işlemek fonksiyonun zaman
 * aşımına yaklaşmasına yol açabiliyordu, tamamen paralel işlemek ise
 * Firestore'a aynı anda onbinlerce sorgu göndermek anlamına gelirdi. */
const MEMBER_CONCURRENCY = 25;

export interface BadgeCriterion {
  id: string;
  type:
    | "sessionsCompleted"
    | "groupSessionJoins"
    | "eventJoins"
    | "membershipMonths"
    | "feedbackCount"
    | "measurementEntries";
  threshold: number;
}

export interface MemberMetrics {
  sessionsCompleted: number;
  groupSessionJoins: number;
  eventJoins: number;
  membershipMonths: number;
  feedbackCount: number;
  measurementEntries: number;
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

/**
 * Sadece yıl/ay farkını almak (eski hâli) takvim ayı sınırını GÜN'e
 * bakmadan geçmiş sayıyordu — ör. 31 Ocak'ta katılan bir üye 1 Temmuz'da
 * (yani sadece ~5 ay 1 gün sonra) "6 ay üyelik" rozetini kazanıyordu. Gün
 * henüz katılım gününe ulaşmadıysa o ay tam sayılmıyor — membership_6_months/
 * membership_12_months gibi en zor rozetler bu yüzden gerçekte olduğundan
 * erken açılmasın diye eklendi.
 */
export function membershipMonthsSince(createdAt: FirebaseFirestore.Timestamp | undefined): number {
  if (!createdAt) return 0;
  const now = new Date();
  const created = createdAt.toDate();
  let months = (now.getFullYear() - created.getFullYear()) * 12 + (now.getMonth() - created.getMonth());
  if (now.getDate() < created.getDate()) months -= 1;
  return Math.max(0, months);
}

/**
 * Her gün 03:00'te çalışır: her üye için ders/grup dersi/etkinlik katılım
 * sayılarını ve üyelik süresini hesaplar, `cfg_badge_criteria`deki eşikleri
 * geçen ama henüz `users/{uid}.badges` içinde olmayan rozetleri ekler.
 */
export const badgeCheck = onSchedule("every day 03:00", withFailureAlerting("badgeCheck", async () => {
  const db = getFirestore();

  let template: RemoteConfigTemplate;
  try {
    template = await getCachedRemoteConfigTemplate();
  } catch (error) {
    logger.warn("Remote Config cache okunamadı, badge kontrolü atlandı.", error);
    return;
  }

  const criteria = readBadgeCriteria(template);
  if (criteria.length === 0) {
    logger.info("cfg_badge_criteria boş, kontrol edilecek rozet yok.");
    return;
  }

  const membersSnapshot = await db.collection("users").where("role", "==", "member").get();
  if (membersSnapshot.empty) return;

  await mapWithConcurrency(membersSnapshot.docs, MEMBER_CONCURRENCY, async (memberDoc) => {
    const uid = memberDoc.id;
    const data = memberDoc.data();
    const existingBadgeIds = (data.badges as string[] | undefined) ?? [];

    const [completedSessions, groupSessionJoins, eventJoins, feedbackCount, measurementEntries] =
      await Promise.all([
        db.collection("sessions").where("memberId", "==", uid).where("status", "==", "completed").where("attended", "==", true).count().get(),
        db.collection("groupSessions").where("attendeeIds", "array-contains", uid).count().get(),
        db.collection("events").where("attendeeIds", "array-contains", uid).count().get(),
        db.collection("feedback").where("memberId", "==", uid).count().get(),
        db.collection("measurements").doc(uid).collection("entries").count().get(),
      ]);

    const metrics: MemberMetrics = {
      sessionsCompleted: completedSessions.data().count,
      groupSessionJoins: groupSessionJoins.data().count,
      eventJoins: eventJoins.data().count,
      membershipMonths: membershipMonthsSince(data.createdAt as FirebaseFirestore.Timestamp | undefined),
      feedbackCount: feedbackCount.data().count,
      measurementEntries: measurementEntries.data().count,
    };

    const newlyEarned = computeNewlyEarnedBadgeIds(criteria, metrics, existingBadgeIds);
    if (newlyEarned.length === 0) return;

    await memberDoc.ref.update({ badges: [...existingBadgeIds, ...newlyEarned] });
    logger.info(`Üye ${uid} yeni rozet kazandı: ${newlyEarned.join(", ")}`);
  });
}));
