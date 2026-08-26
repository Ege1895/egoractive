import assert from "node:assert/strict";
import test from "node:test";

import { resolveMemberPackageAlert } from "./on-member-package-quota-changed";

test("returns null when there is no before data (document creation)", () => {
  assert.equal(
    resolveMemberPackageAlert(undefined, { role: "member", remainingSessions: 0, plannedSessionsCount: 0 }, 3),
    null,
  );
});

test("returns null for a non-member role", () => {
  assert.equal(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 5, plannedSessionsCount: 0 },
      { role: "trainer", remainingSessions: 0, plannedSessionsCount: 0 },
      3,
    ),
    null,
  );
});

test("returns null when the total increases (admin tops up a package)", () => {
  assert.equal(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 0, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 12, plannedSessionsCount: 0 },
      3,
    ),
    null,
  );
});

test("returns null when the total decreases but stays above the threshold", () => {
  assert.equal(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 9, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 8, plannedSessionsCount: 0 },
      3,
    ),
    null,
  );
});

test("returns endingSoon when the total newly crosses the threshold from above (12 total, 9 remaining example)", () => {
  assert.deepEqual(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 1, plannedSessionsCount: 3 },
      { role: "member", remainingSessions: 0, plannedSessionsCount: 3 },
      3,
    ),
    { alert: "endingSoon", totalRemaining: 3 },
  );
});

test("does not re-alert on every further decrease while already ending soon (2 -> 1)", () => {
  assert.equal(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 2, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 1, plannedSessionsCount: 0 },
      3,
    ),
    null,
  );
});

test("returns none when the total reaches zero", () => {
  assert.deepEqual(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 1, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 0, plannedSessionsCount: 0 },
      3,
    ),
    { alert: "none", totalRemaining: 0 },
  );
});

test("returns none directly when a single write drops the total from well above zero straight to zero", () => {
  assert.deepEqual(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 5, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 0, plannedSessionsCount: 0 },
      3,
    ),
    { alert: "none", totalRemaining: 0 },
  );
});

test("returns null when already at zero and staying at zero", () => {
  assert.equal(
    resolveMemberPackageAlert(
      { role: "member", remainingSessions: 0, plannedSessionsCount: 0 },
      { role: "member", remainingSessions: 0, plannedSessionsCount: 0 },
      3,
    ),
    null,
  );
});

test("missing fields default to zero", () => {
  assert.deepEqual(resolveMemberPackageAlert({ role: "member" }, { role: "member" }, 3), null);
});
