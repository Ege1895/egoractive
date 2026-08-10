import assert from "node:assert/strict";
import test from "node:test";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";

import { istanbulDayAndHour, isWeeklyReportDue, previousWeekRange } from "./weekly-schedule";

function template(overrides: Record<string, string>): RemoteConfigTemplate {
  const parameters: RemoteConfigTemplate["parameters"] = {};
  for (const [key, value] of Object.entries(overrides)) {
    parameters[key] = { defaultValue: { value } };
  }
  return { parameters } as RemoteConfigTemplate;
}

// İstanbul UTC+3'te sabit (2016'dan beri DST yok) — 2024-01-01 bilinen bir Pazartesi.
const MONDAY_06_ISTANBUL = new Date("2024-01-01T03:00:00Z");
const MONDAY_07_ISTANBUL = new Date("2024-01-01T04:00:00Z");
const TUESDAY_06_ISTANBUL = new Date("2024-01-02T03:00:00Z");

test("istanbulDayAndHour reads Monday 06:00 correctly from a UTC timestamp", () => {
  assert.deepEqual(istanbulDayAndHour(MONDAY_06_ISTANBUL), { isoDayOfWeek: 1, hour: 6 });
});

test("istanbulDayAndHour reads Tuesday correctly", () => {
  assert.deepEqual(istanbulDayAndHour(TUESDAY_06_ISTANBUL), { isoDayOfWeek: 2, hour: 6 });
});

test("isWeeklyReportDue is true when day and hour both match RC defaults (Monday 06:00)", () => {
  const t = template({ cfg_weekly_report_day_of_week: "1", cfg_weekly_report_hour: "6" });
  assert.equal(isWeeklyReportDue(t, MONDAY_06_ISTANBUL), true);
});

test("isWeeklyReportDue is false when the hour doesn't match", () => {
  const t = template({ cfg_weekly_report_day_of_week: "1", cfg_weekly_report_hour: "6" });
  assert.equal(isWeeklyReportDue(t, MONDAY_07_ISTANBUL), false);
});

test("isWeeklyReportDue is false when the day doesn't match", () => {
  const t = template({ cfg_weekly_report_day_of_week: "1", cfg_weekly_report_hour: "6" });
  assert.equal(isWeeklyReportDue(t, TUESDAY_06_ISTANBUL), false);
});

test("isWeeklyReportDue falls back to Monday 06:00 defaults when RC params are missing", () => {
  assert.equal(isWeeklyReportDue(template({}), MONDAY_06_ISTANBUL), true);
  assert.equal(isWeeklyReportDue(template({}), TUESDAY_06_ISTANBUL), false);
});

test("previousWeekRange returns a 7-day window ending at the most recent Monday 00:00", () => {
  const { weekStart, weekEnd } = previousWeekRange(MONDAY_06_ISTANBUL);
  assert.equal(weekEnd.getTime() - weekStart.getTime(), 7 * 24 * 60 * 60 * 1000);
  assert.equal(istanbulDayAndHour(weekEnd).isoDayOfWeek, 1);
});
