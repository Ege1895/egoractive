import assert from "node:assert/strict";
import test from "node:test";

import { resolvePhoneIndexSync } from "./on-user-write-sync-phone-index";

test("returns null when phoneNumber is unchanged (e.g. only name updated)", () => {
  const before = { name: "Ada", phoneNumber: "+905324187605" };
  const after = { name: "Ada Kaya", phoneNumber: "+905324187605" };
  assert.equal(resolvePhoneIndexSync("uid1", before, after), null);
});

test("returns null when neither before nor after has a phoneNumber", () => {
  assert.equal(resolvePhoneIndexSync("uid1", { name: "Ada" }, { name: "Ada" }), null);
});

test("new user document: writes the phone, nothing to remove", () => {
  assert.deepEqual(resolvePhoneIndexSync("uid1", undefined, { phoneNumber: "+905324187605" }), {
    removePhone: null,
    writePhone: { phoneNumber: "+905324187605", uid: "uid1" },
  });
});

test("phone number changed: removes the old entry, writes the new one", () => {
  const before = { phoneNumber: "+905324187605" };
  const after = { phoneNumber: "+905321112233" };
  assert.deepEqual(resolvePhoneIndexSync("uid1", before, after), {
    removePhone: "+905324187605",
    writePhone: { phoneNumber: "+905321112233", uid: "uid1" },
  });
});

test("user document deleted: removes the entry, nothing to write", () => {
  assert.deepEqual(resolvePhoneIndexSync("uid1", { phoneNumber: "+905324187605" }, undefined), {
    removePhone: "+905324187605",
    writePhone: null,
  });
});

test("user created without a phoneNumber yet: no-op", () => {
  assert.equal(resolvePhoneIndexSync("uid1", undefined, { name: "Ada" }), null);
});
