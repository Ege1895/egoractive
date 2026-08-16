import assert from "node:assert/strict";
import test from "node:test";

import { shouldAlert } from "./function-health";

test("shouldAlert is false before the threshold", () => {
  assert.equal(shouldAlert(1), false);
  assert.equal(shouldAlert(2), false);
});

test("shouldAlert is true exactly at the threshold (3rd consecutive failure)", () => {
  assert.equal(shouldAlert(3), true);
});

test("shouldAlert is false after the threshold — one alert per incident, not a mail per failure", () => {
  assert.equal(shouldAlert(4), false);
  assert.equal(shouldAlert(5), false);
  assert.equal(shouldAlert(100), false);
});
