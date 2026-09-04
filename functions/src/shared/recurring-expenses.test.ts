import assert from "node:assert/strict";
import test from "node:test";

import {
  addMonths,
  clampDayToMonth,
  compareMonths,
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
// girilen kira, yılın kalan TÜM aylarında görünmeli (takvimde ileriye dönük).
test("şablon ayından yıl sonuna kadar tüm aylar üretilir", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 9 },
    }),
    [9, 10, 11, 12].map((month) => ({ year: 2026, month })),
  );
});

// Yıl sınırı: 2027 için admin gideri yeniden girer.
test("sonraki yıla taşmaz", () => {
  const months = pendingRecurringMonths({
    templateMonth: { year: 2026, month: 11 },
    materializedThrough: undefined,
    currentMonth: { year: 2027, month: 2 },
  });
  assert.deepEqual(months, [{ year: 2026, month: 12 }]);
});

test("Aralık'a girilen şablon hiç kopya üretmez", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 12 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 12 },
    }),
    [],
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
      materializedThrough: "2026-12",
      currentMonth: { year: 2026, month: 9 },
    }),
    [],
  );
});

// Gelecek aya tarihli bir şablon da yıl sonuna kadar doldurulur — takvimde
// ileriye bakan admin sabit gideri görebilsin diye.
test("geleceğe tarihli şablon da kendi yılını doldurur", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 10 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 9 },
    }),
    [
      { year: 2026, month: 11 },
      { year: 2026, month: 12 },
    ],
  );
});

// Çok eski bir şablon, kendi yılı çoktan bittiği için hiç kopya üretmez —
// `maxMonths` penceresi zaten o yılın çok ilerisinde.
test("çok eski şablon yeni kopya üretmez", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2015, month: 1 },
      materializedThrough: undefined,
      currentMonth: { year: 2026, month: 9 },
    }),
    [],
  );
});

// Geçmiş boşluklar da doldurulur ama yine yıl sonunda durur: fonksiyon uzun
// süre çalışmamışsa Ocak'ta girilen şablon Aralık'a kadar tamamlanır.
test("geçmiş boşluklar yıl sonuna kadar tamamlanır", () => {
  const months = pendingRecurringMonths({
    templateMonth: { year: 2026, month: 1 },
    materializedThrough: undefined,
    currentMonth: { year: 2026, month: 9 },
  });
  assert.equal(months.length, 11);
  assert.deepEqual(months[0], { year: 2026, month: 2 });
  assert.deepEqual(months[months.length - 1], { year: 2026, month: 12 });
});

test("imleç şablondan eskiyse yok sayılır (bozuk/elle yazılmış veri)", () => {
  assert.deepEqual(
    pendingRecurringMonths({
      templateMonth: { year: 2026, month: 8 },
      materializedThrough: "2020-01",
      currentMonth: { year: 2026, month: 9 },
    }),
    [9, 10, 11, 12].map((month) => ({ year: 2026, month })),
  );
});
