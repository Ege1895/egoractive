import assert from "node:assert/strict";
import test from "node:test";

import { phoneLookupCandidates } from "./phone-lookup";

test("phoneLookupCandidates: +90 numarası için hem E.164 hem eski çıplak halini dener", () => {
  assert.deepEqual(phoneLookupCandidates("+905324187605"), [
    "+905324187605",
    "5324187605",
  ]);
});

test("phoneLookupCandidates: TR dışı bir numara için tek adayı (kendisini) döner", () => {
  assert.deepEqual(phoneLookupCandidates("+14155550132"), ["+14155550132"]);
});

test("phoneLookupCandidates: sadece '+90' (numara yok) için de tek adayı döner", () => {
  assert.deepEqual(phoneLookupCandidates("+90"), ["+90"]);
});

test("phoneLookupCandidates: zaten çıplak (prefiksiz) bir değer için tek adayı döner", () => {
  assert.deepEqual(phoneLookupCandidates("5324187605"), ["5324187605"]);
});
