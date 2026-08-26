import assert from "node:assert/strict";
import test from "node:test";

import { localDateParts, oneDayBeforeAt21Local, zonedTimeToUtc } from "./timezone-math";

test("zonedTimeToUtc: Europe/Istanbul (UTC+3, no DST) converts correctly", () => {
  const result = zonedTimeToUtc(2026, 9, 15, 21, 0, "Europe/Istanbul");
  assert.equal(result.toISOString(), "2026-09-15T18:00:00.000Z");
});

test("zonedTimeToUtc: America/New_York (UTC-4 in summer, DST) converts correctly", () => {
  const result = zonedTimeToUtc(2026, 7, 14, 21, 0, "America/New_York");
  assert.equal(result.toISOString(), "2026-07-15T01:00:00.000Z");
});

test("localDateParts reads the correct calendar day in a far-ahead timezone", () => {
  // 2026-01-01T01:00:00Z is already 2026-01-01 10:00 in Tokyo (UTC+9).
  const parts = localDateParts(new Date("2026-01-01T01:00:00Z"), "Asia/Tokyo");
  assert.deepEqual(parts, { year: 2026, month: 1, day: 1 });
});

test("oneDayBeforeAt21Local: Istanbul event, simple case", () => {
  const eventStart = new Date("2026-09-15T10:00:00Z"); // 13:00 Istanbul local
  const reminder = oneDayBeforeAt21Local(eventStart, "Europe/Istanbul");
  assert.equal(reminder.toISOString(), "2026-09-14T18:00:00.000Z");
});

test("oneDayBeforeAt21Local: month rollover (event on the 1st)", () => {
  const eventStart = new Date("2026-03-01T10:00:00Z"); // 13:00 Istanbul local, March 1st
  const reminder = oneDayBeforeAt21Local(eventStart, "Europe/Istanbul");
  assert.equal(reminder.toISOString(), "2026-02-28T18:00:00.000Z");
});

test("oneDayBeforeAt21Local: year rollover (event on Jan 1)", () => {
  const eventStart = new Date("2027-01-01T10:00:00Z"); // 13:00 Istanbul local, Jan 1st
  const reminder = oneDayBeforeAt21Local(eventStart, "Europe/Istanbul");
  assert.equal(reminder.toISOString(), "2026-12-31T18:00:00.000Z");
});

test("oneDayBeforeAt21Local: far-west timezone (America/Los_Angeles)", () => {
  // 2026-06-10T02:00:00Z is 2026-06-09 19:00 in Los Angeles (UTC-7, PDT).
  const eventStart = new Date("2026-06-10T02:00:00Z");
  const reminder = oneDayBeforeAt21Local(eventStart, "America/Los_Angeles");
  // One day before (June 8) at 21:00 PDT = June 9 04:00 UTC.
  assert.equal(reminder.toISOString(), "2026-06-09T04:00:00.000Z");
});
