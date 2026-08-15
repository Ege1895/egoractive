import assert from "node:assert/strict";
import test from "node:test";
import { RemoteConfigTemplate } from "firebase-admin/remote-config";

import { currentMonthRange, isFeedbackReminderDue, isLastDayOfMonth, istanbulYearMonthDay } from "./monthly-schedule";

function template(overrides: Record<string, string>): RemoteConfigTemplate {
  const parameters: RemoteConfigTemplate["parameters"] = {};
  for (const [key, value] of Object.entries(overrides)) {
    parameters[key] = { defaultValue: { value } };
  }
  return { parameters } as RemoteConfigTemplate;
}

// İstanbul UTC+3'te sabit (2016'dan beri DST yok) — Istanbul yerel saat
// 12:00 için UTC 09:00 kullanılıyor, gece yarısı sınırlarından uzak durmak için.
function istanbulNoon(year: number, month: number, day: number): Date {
  return new Date(Date.UTC(year, month - 1, day, 9, 0, 0));
}

test("31 günlük ay: 31 Ocak son gün, 30 Ocak değil", () => {
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 1, 31)), true);
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 1, 30)), false);
});

test("30 günlük ay: 30 Nisan son gün, 31 Nisan yok/29 değil", () => {
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 4, 30)), true);
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 4, 29)), false);
});

test("28 günlük ay (artık olmayan yıl): 28 Şubat 2025 son gün", () => {
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 2, 28)), true);
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 2, 27)), false);
});

test("29 günlük ay (artık yıl): 29 Şubat 2024 son gün, 28 Şubat 2024 değil", () => {
  assert.equal(isLastDayOfMonth(istanbulNoon(2024, 2, 29)), true);
  assert.equal(isLastDayOfMonth(istanbulNoon(2024, 2, 28)), false);
});

test("31 günlük ay (Aralık): yıl sonu geçişi doğru", () => {
  assert.equal(isLastDayOfMonth(istanbulNoon(2025, 12, 31)), true);
});

test("istanbulYearMonthDay UTC gece yarısı sınırını doğru İstanbul gününe çevirir", () => {
  // 31 Ocak 23:00 UTC = 1 Şubat 02:00 İstanbul (UTC+3)
  const result = istanbulYearMonthDay(new Date("2025-01-31T23:00:00Z"));
  assert.deepEqual(result, { year: 2025, month: 2, day: 1 });
});

test("isFeedbackReminderDue: -1 ayın son gününe eşdeğer", () => {
  const t = template({ cfg_feedback_reminder_day_of_month: "-1" });
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2025, 2, 28)), true);
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2025, 2, 27)), false);
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2024, 2, 29)), true);
});

test("isFeedbackReminderDue: sabit bir gün (ör. 15) sadece o gün doğru", () => {
  const t = template({ cfg_feedback_reminder_day_of_month: "15" });
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2025, 3, 15)), true);
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2025, 3, 14)), false);
  assert.equal(isFeedbackReminderDue(t, istanbulNoon(2025, 3, 31)), false);
});

test("isFeedbackReminderDue: RC param eksikse -1 (ayın son günü) varsayılanına düşer", () => {
  assert.equal(isFeedbackReminderDue(template({}), istanbulNoon(2025, 4, 30)), true);
  assert.equal(isFeedbackReminderDue(template({}), istanbulNoon(2025, 4, 29)), false);
});

test("currentMonthRange bir aylık, o ayın 1. gününden başlayan bir pencere döner", () => {
  const { monthStart, monthEnd } = currentMonthRange(istanbulNoon(2025, 2, 15));
  assert.deepEqual(istanbulYearMonthDay(monthStart), { year: 2025, month: 2, day: 1 });
  assert.deepEqual(istanbulYearMonthDay(monthEnd), { year: 2025, month: 3, day: 1 });
});
