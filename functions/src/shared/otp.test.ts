import assert from "node:assert/strict";
import test from "node:test";

import { hashOtp, otpDocId } from "./otp";

test("otpDocId: purpose+uid'e göre deterministik ve tekil", () => {
  assert.equal(otpDocId("login", "abc"), "login_abc");
  assert.equal(otpDocId("activation", "abc"), "activation_abc");
  assert.notEqual(otpDocId("login", "abc"), otpDocId("emailChange", "abc"));
});

test("hashOtp: aynı kod+salt aynı hash, farklı kod farklı hash", () => {
  const salt = "fixed-salt";
  assert.equal(hashOtp("123456", salt), hashOtp("123456", salt));
  assert.notEqual(hashOtp("123456", salt), hashOtp("654321", salt));
});

test("hashOtp: plaintext kodu hiç içermeyen bir hex string döner", () => {
  const hash = hashOtp("123456", "salt");
  assert.equal(/^[0-9a-f]{64}$/.test(hash), true);
  assert.equal(hash.includes("123456"), false);
});
