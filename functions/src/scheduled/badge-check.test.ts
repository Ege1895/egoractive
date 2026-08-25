import assert from "node:assert/strict";
import test from "node:test";

import { computeNewlyEarnedBadgeIds, membershipMonthsSince, MemberMetrics } from "./badge-check";

function fakeTimestamp(date: Date): FirebaseFirestore.Timestamp {
  return { toDate: () => date } as FirebaseFirestore.Timestamp;
}

const baseMetrics: MemberMetrics = {
  sessionsCompleted: 0,
  groupSessionJoins: 0,
  eventJoins: 0,
  membershipMonths: 0,
  feedbackCount: 0,
  measurementEntries: 0,
};

const criteria = [
  { id: "first_session", type: "sessionsCompleted" as const, threshold: 1 },
  { id: "sessions_5", type: "sessionsCompleted" as const, threshold: 5 },
  { id: "group_session_join", type: "groupSessionJoins" as const, threshold: 1 },
];

test("returns empty when no metric meets its threshold", () => {
  assert.deepEqual(computeNewlyEarnedBadgeIds(criteria, baseMetrics, []), []);
});

test("returns badges whose threshold is met and not already earned", () => {
  const metrics = { ...baseMetrics, sessionsCompleted: 1 };
  assert.deepEqual(computeNewlyEarnedBadgeIds(criteria, metrics, []), ["first_session"]);
});

test("returns multiple newly-earned badges when several thresholds are met at once", () => {
  const metrics = { ...baseMetrics, sessionsCompleted: 5, groupSessionJoins: 2 };
  assert.deepEqual(computeNewlyEarnedBadgeIds(criteria, metrics, []), [
    "first_session",
    "sessions_5",
    "group_session_join",
  ]);
});

test("excludes badges already present in existingBadgeIds even if threshold is met", () => {
  const metrics = { ...baseMetrics, sessionsCompleted: 5 };
  assert.deepEqual(computeNewlyEarnedBadgeIds(criteria, metrics, ["first_session"]), ["sessions_5"]);
});

test("supports feedbackCount and measurementEntries metric types", () => {
  const extraCriteria = [
    ...criteria,
    { id: "feedback_given", type: "feedbackCount" as const, threshold: 1 },
    { id: "measurement_logged", type: "measurementEntries" as const, threshold: 1 },
  ];
  const metrics = { ...baseMetrics, feedbackCount: 1, measurementEntries: 2 };
  assert.deepEqual(computeNewlyEarnedBadgeIds(extraCriteria, metrics, []), [
    "feedback_given",
    "measurement_logged",
  ]);
});

test("membershipMonthsSince counts only fully completed months (day-of-month aware)", () => {
  const now = new Date();
  const exactlySixMonthsAgo = new Date(now.getFullYear(), now.getMonth() - 6, now.getDate());
  assert.equal(membershipMonthsSince(fakeTimestamp(exactlySixMonthsAgo)), 6);

  // Katılım gününe henüz ulaşılmadıysa (bir gün eksik) o ay tam sayılmamalı —
  // önceki hatalı davranışta bu durum yine de 6 olarak sayılıyordu. Takvim
  // bileşenleriyle yeniden inşa etmek yerine milisaniye eklemek, ay
  // taşması (ör. ayın son günü) kenar durumlarından kaçınıyor.
  const oneDayShortOfSixMonths = new Date(exactlySixMonthsAgo.getTime() + 24 * 60 * 60 * 1000);
  assert.equal(membershipMonthsSince(fakeTimestamp(oneDayShortOfSixMonths)), 5);
});

test("returns empty when every eligible badge is already earned", () => {
  const metrics = { ...baseMetrics, sessionsCompleted: 5, groupSessionJoins: 1 };
  assert.deepEqual(
    computeNewlyEarnedBadgeIds(criteria, metrics, ["first_session", "sessions_5", "group_session_join"]),
    [],
  );
});
