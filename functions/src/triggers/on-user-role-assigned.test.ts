import assert from "node:assert/strict";
import test from "node:test";

import { isUserNotFoundError, resolveClaimsUpdate } from "./on-user-role-assigned";

test("isUserNotFoundError recognizes the Firebase Auth 'user-not-found' code", () => {
  assert.equal(isUserNotFoundError({ code: "auth/user-not-found" }), true);
});

test("isUserNotFoundError is false for other error codes", () => {
  assert.equal(isUserNotFoundError({ code: "auth/internal-error" }), false);
});

test("isUserNotFoundError is false for non-error values", () => {
  assert.equal(isUserNotFoundError(new Error("boom")), false);
  assert.equal(isUserNotFoundError("boom"), false);
  assert.equal(isUserNotFoundError(null), false);
  assert.equal(isUserNotFoundError(undefined), false);
});

test("returns null when there is no after-data (document deleted)", () => {
  assert.equal(resolveClaimsUpdate({ role: "member" }, undefined), null);
});

test("returns null when role is missing on the new document", () => {
  assert.equal(resolveClaimsUpdate(undefined, { gymId: "demo-gym" }), null);
});

test("returns an update on a brand-new document with a role", () => {
  assert.deepEqual(resolveClaimsUpdate(undefined, { role: "admin", gymId: "demo-gym" }), {
    role: "admin",
    gymId: "demo-gym",
  });
});

test("returns an update when role changes", () => {
  const before = { role: "member", gymId: "demo-gym" };
  const after = { role: "trainer", gymId: "demo-gym" };
  assert.deepEqual(resolveClaimsUpdate(before, after), { role: "trainer", gymId: "demo-gym" });
});

test("returns an update when gymId changes but role stays the same", () => {
  const before = { role: "trainer", gymId: "old-gym" };
  const after = { role: "trainer", gymId: "new-gym" };
  assert.deepEqual(resolveClaimsUpdate(before, after), { role: "trainer", gymId: "new-gym" });
});

test("returns null when role and gymId are unchanged (e.g. only claimsSyncedAt written)", () => {
  const before = { role: "admin", gymId: "demo-gym", claimsSyncedAt: null };
  const after = { role: "admin", gymId: "demo-gym", claimsSyncedAt: "2026-08-05T00:00:00Z" };
  assert.equal(resolveClaimsUpdate(before, after), null);
});

test("treats a missing gymId as null", () => {
  assert.deepEqual(resolveClaimsUpdate(undefined, { role: "member" }), {
    role: "member",
    gymId: null,
  });
});
