import assert from "node:assert/strict";
import test from "node:test";

import { selectLiveSessions } from "./send-trainer-session-reminder-task";

const START = 1_800_000_000_000;
const solo = { id: "s1", status: "planned", startTimeMs: START };
const duetA = { id: "d1", status: "planned", startTimeMs: START };
const duetB = { id: "d2", status: "planned", startTimeMs: START };

test("tekil ders: planlıysa bildirim gider", () => {
  assert.deepEqual(selectLiveSessions([solo], START), [solo]);
});

test("iptal edilmiş ders elenir — hatırlatma gitmez", () => {
  assert.deepEqual(selectLiveSessions([{ ...solo, status: "cancelled" }], START), []);
});

// Ertelenen ders için YENİ bir görev kurulur; eskisi ateşlendiğinde saat
// tutmadığı için sessizce çıkmalı, yoksa antrenör iki kez bildirim alır.
test("ertelenmiş ders elenir — eski görev boşa ateşlenmiş demektir", () => {
  assert.deepEqual(selectLiveSessions([{ ...solo, startTimeMs: START + 3_600_000 }], START), []);
});

test("düet: iki üye de duruyorsa ikisi de listelenir", () => {
  assert.deepEqual(selectLiveSessions([duetA, duetB], START), [duetA, duetB]);
});

// Düet ders 2 kişiyle sınırlı değil — 5 kişilik bir grupta da hepsi tek
// bildirimde listelenmeli.
test("düet: 5 üyeli grupta hepsi listelenir", () => {
  const group = Array.from({ length: 5 }, (_, i) => ({
    id: `d${i}`,
    status: "planned",
    startTimeMs: START,
  }));
  assert.equal(selectLiveSessions(group, START).length, 5);
});

// Paylaşılan görev id'si yüzünden görevi İPTAL ETMİYORUZ; bunun yerine
// ateşlenme anında kalanlara bakıyoruz — tek üye iptal olduysa bildirim
// yine gider, ama sadece kalan üyenin adıyla.
test("düet: biri iptal edilse bile kalan üye için bildirim gider", () => {
  assert.deepEqual(selectLiveSessions([{ ...duetA, status: "cancelled" }, duetB], START), [duetB]);
});

test("düet: tamamı iptal edilmişse hiç bildirim gitmez", () => {
  assert.deepEqual(
    selectLiveSessions([{ ...duetA, status: "cancelled" }, { ...duetB, status: "cancelled" }], START),
    [],
  );
});

test("silinmiş seans (boş liste) çökme yaratmaz", () => {
  assert.deepEqual(selectLiveSessions([], START), []);
});
