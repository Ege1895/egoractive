import assert from "node:assert/strict";
import test from "node:test";

import { computeNewlyEarnedBadgeIds, MemberMetrics } from "./badge-check";

const baseMetrics: MemberMetrics = {
  sessionsCompleted: 0,
  groupSessionJoins: 0,
  eventJoins: 0,
  membershipMonths: 0,
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

test("returns empty when every eligible badge is already earned", () => {
  const metrics = { ...baseMetrics, sessionsCompleted: 5, groupSessionJoins: 1 };
  assert.deepEqual(
    computeNewlyEarnedBadgeIds(criteria, metrics, ["first_session", "sessions_5", "group_session_join"]),
    [],
  );
});
