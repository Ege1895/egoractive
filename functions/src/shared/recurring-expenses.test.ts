import assert from "node:assert/strict";
import test from "node:test";

import {
  addMonths,
  clampDayToMonth,
  compareMonths,
  maxRecurringCatchUpMonths,
  monthKey,
  parseMonthKey,
  pendingRecurringMonths,
} from "./recurring-expenses";

test("monthKey ay numarasını iki haneye tamamlar", () => {
  assert.equal(monthKey({ year: 2026, month: 9 }), "2026-09");
  assert.equal(monthKey({ year: 2026, month: 12 }), "2026-12");
});

test("parseMonthKey geçersiz girdide undefined döner", () => {
  assert.deepEqual(parseMonthKey("2026-09"), { year: 2026, month: 9 });
  assert.equal(parseMonthKey(undefined), undefined);
  assert.equal(parseMonthKey("2026-13"), undefined);
  assert.equal(parseMonthKey("saçma"), undefined);
});

test("addMonths yıl sınırını iki yönde de aşar", () => {
  assert.deepEqual(addMonths({ year: 2026, month: 12 }, 1), { year: 2027, month: 1 });
  assert.deepEqual(addMonths({ year: 2026, month: 1 }, -1), { year: 2025, month: 12 });
  assert.deepEqual(addMonths({ year: 2026, month: 9 }, 12), { year: 2027, month: 9 });
});

test("compareMonths takvim sırasını verir", () => {
  assert.ok(compareMonths({ year: 2026, month: 8 }, { year: 2026, month: 9 }) < 0);
  assert.ok(compareMonths({ year: 2027, month: 1 }, { year: 2026, month: 12 }) > 0);
  assert.equal(compareMonths({ year: 2026, month: 9 }, { year: 2026, month: 9 }), 0);
});

test("clampDayToMonth 31'i kısa aylara çeker", () => {
  assert.equal(clampDayToMonth(31, { year: 2026, month: 2 }), 28);
  assert.equal(clampDayToMonth(31, { year: 2028, month: 2 }), 29); // artık yıl
  assert.equal(clampDayToMonth(31, { year: 2026, month: 4 }), 30);
  assert.equal(clampDayToMonth(15, { year: 2026, month: 2 }), 15);
});

// Kullanıcı raporundaki asıl senaryo: Ağustos'a "her ay tekrar et" ile
// girilen kira, Eylül'de görünmüyordu.
test("şablon ayının kendisi üretilmez, sonraki ay üretilir", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 9 },
    }),
    [{ year: 2026, month: 9 }],
  );
});

test("aradaki tüm boş aylar tek seferde doldurulur", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 11 },
      materializedThrough: undefined,
      currentMonth: { year: 2027, month: 2 },
    }),
    [
      { year: 2026, month: 12 },
      { year: 2027, month: 1 },
      { year: 2027, month: 2 },
    ],
  );
});

test("imleç ilerlemişse o aya kadar tekrar üretilmez", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: "2026-10",
      currentMonth: { year: 2026, month: 12 },
    }),
    [
      { year: 2026, month: 11 },
      { year: 2026, month: 12 },
    ],
  );
});

test("her şey üretilmişse boş döner — günlük çalışmanın normal hâli", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: "2026-09",
      currentMonth: { year: 2026, month: 9 },
    }),
    [],
  );
});

test("geleceğe tarihli şablon için henüz kopya üretilmez", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 11 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 9 },
    }),
    [],
  );
});

test("çok eski şablonda sadece son maxMonths ay doldurulur", () => {
  const months = pendingRecurringMonths({
    templateMonth: { year: 2015, month: 1 },
    materializedThrough: undefined,
    currentMonth: { year: 2026, month: 9 },
  });
  assert.equal(months.length, maxRecurringCatchUpMonths);
  assert.deepEqual(months[months.length - 1], { year: 2026, month: 9 });
  assert.deepEqual(months[0], addMonths({ year: 2026, month: 9 }, -(maxRecurringCatchUpMonths - 1)));
});

test("imleç şablondan eskiyse yok sayılır (bozuk/elle yazılmış veri)", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: "2020-01",
      currentMonth: { year: 2026, month: 9 },
    }),
    [{ year: 2026, month: 9 }],
  );
});
