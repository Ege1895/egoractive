import assert from "node:assert/strict";
import test from "node:test";
import { Timestamp } from "firebase-admin/firestore";

import { buildStatsPayload, computeBucketDeltas, toBucket, yearMonthUtc } from "./on-session-write-update-trainer-stats";

function ts(isoUtc: string): Timestamp {
  return Timestamp.fromDate(new Date(isoUtc));
}

test("yearMonthUtc formats single-digit months with a leading zero", () => {
  assert.equal(yearMonthUtc(new Date(Date.UTC(2026, 0, 15))), "2026-01");
  assert.equal(yearMonthUtc(new Date(Date.UTC(2026, 8, 1))), "2026-09");
});

test("toBucket returns null when data is undefined", () => {
  assert.equal(toBucket(undefined), null);
});

test("toBucket returns null when gymId/trainerId/startTime is missing", () => {
  assert.equal(toBucket({ trainerId: "t1", startTime: ts("2026-08-15T00:00:00Z") }), null);
  assert.equal(toBucket({ gymId: "g1", startTime: ts("2026-08-15T00:00:00Z") }), null);
  assert.equal(toBucket({ gymId: "g1", trainerId: "t1" }), null);
});

test("toBucket extracts the bucket fields, defaulting name to '' and completed to false", () => {
  const bucket = toBucket({
    gymId: "g1",
    trainerId: "t1",
    startTime: ts("2026-08-15T10:00:00Z"),
    status: "planned",
  });
  assert.deepEqual(bucket, {
    gymId: "g1",
    trainerId: "t1",
    yearMonth: "2026-08",
    trainerName: "",
    isCompleted: false,
  });
});

test("toBucket reads trainerName and marks isCompleted for status 'completed'", () => {
  const bucket = toBucket({
    gymId: "g1",
    trainerId: "t1",
    trainerName: "Berk Aydın",
    startTime: ts("2026-08-15T10:00:00Z"),
    status: "completed",
  });
  assert.equal(bucket?.trainerName, "Berk Aydın");
  assert.equal(bucket?.isCompleted, true);
});

test("computeBucketDeltas: create (before null, after set) → +1 total to the new bucket, name written", () => {
  const after = toBucket({ gymId: "g1", trainerId: "t1", trainerName: "Ada", startTime: ts("2026-08-01T00:00:00Z") });
  const deltas = computeBucketDeltas(null, after);
  assert.deepEqual(deltas, [{ bucket: after, delta: { total: 1, completed: 0, writeName: true } }]);
});

test("computeBucketDeltas: delete (before set, after null) → -1 total from the old bucket, no name write", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "completed" });
  const deltas = computeBucketDeltas(before, null);
  assert.deepEqual(deltas, [{ bucket: before, delta: { total: -1, completed: -1, writeName: false } }]);
});

test("computeBucketDeltas: same bucket, status planned -> completed → single write, completed +1, total untouched", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "planned" });
  const after = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "completed" });
  const deltas = computeBucketDeltas(before, after);
  assert.deepEqual(deltas, [{ bucket: after, delta: { total: 0, completed: 1, writeName: false } }]);
});

test("computeBucketDeltas: same bucket, status completed -> cancelled → completed -1", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "completed" });
  const after = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "cancelled" });
  const deltas = computeBucketDeltas(before, after);
  assert.deepEqual(deltas, [{ bucket: after, delta: { total: 0, completed: -1, writeName: false } }]);
});

test("computeBucketDeltas: same bucket, no status change and no name change → no writes at all", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "planned" });
  const after = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "planned" });
  assert.deepEqual(computeBucketDeltas(before, after), []);
});

test("computeBucketDeltas: reschedule across a month boundary → decrement old month, increment new month", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-31T23:00:00Z"), status: "planned" });
  const after = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-09-01T09:00:00Z"), status: "planned" });
  const deltas = computeBucketDeltas(before, after);
  assert.deepEqual(deltas, [
    { bucket: before, delta: { total: -1, completed: 0, writeName: false } },
    { bucket: after, delta: { total: 1, completed: 0, writeName: true } },
  ]);
});

test("computeBucketDeltas: trainer reassigned to someone else → decrement old trainer, increment new trainer", () => {
  const before = toBucket({ gymId: "g1", trainerId: "t1", startTime: ts("2026-08-01T00:00:00Z"), status: "planned" });
  const after = toBucket({ gymId: "g1", trainerId: "t2", trainerName: "Yeni Antrenör", startTime: ts("2026-08-01T00:00:00Z"), status: "planned" });
  const deltas = computeBucketDeltas(before, after);
  assert.deepEqual(deltas, [
    { bucket: before, delta: { total: -1, completed: 0, writeName: false } },
    { bucket: after, delta: { total: 1, completed: 0, writeName: true } },
  ]);
});

test("computeBucketDeltas: both null (malformed doc on both sides) → no writes", () => {
  assert.deepEqual(computeBucketDeltas(null, null), []);
});

// --- buildStatsPayload: 2026-09-02'deki sessiz veri bozulmasının regresyonu ---
// Önceki sürüm `{ "stats.<trainerId>.total": increment(1) }` üretip `set()`
// çağırıyordu; `set()` noktalı anahtarı alan YOLU değil LİTERAL alan adı
// olarak yazdığı için doküman `stats` haritası yerine noktalı düz alanlar
// taşıyordu ve dashboard "Henüz antrenör yok" gösteriyordu.

test("buildStatsPayload: HİÇBİR anahtarda nokta olmamalı (asıl regresyon)", () => {
  const bucket = { gymId: "g1", trainerId: "t1", yearMonth: "2026-09", trainerName: "Umut", isCompleted: true };
  const payload = buildStatsPayload(bucket, { total: 1, completed: 1, writeName: true });
  const keysAtEveryLevel = (o: unknown): string[] =>
    typeof o === "object" && o !== null && !Array.isArray(o)
      ? Object.entries(o as Record<string, unknown>).flatMap(([k, v]) => [k, ...keysAtEveryLevel(v)])
      : [];
  const dotted = keysAtEveryLevel(payload).filter((k) => k.includes("."));
  assert.deepEqual(dotted, [], `noktalı anahtar bulundu: ${dotted.join(", ")}`);
});

test("buildStatsPayload: stats -> trainerId -> alanlar şeklinde İÇ İÇE olmalı", () => {
  const bucket = { gymId: "g1", trainerId: "t1", yearMonth: "2026-09", trainerName: "Umut", isCompleted: true };
  const payload = buildStatsPayload(bucket, { total: 1, completed: 1, writeName: true }) as Record<string, Record<string, Record<string, unknown>>>;
  assert.ok(payload.stats, "stats haritası yok");
  assert.ok(payload.stats.t1, "stats altında trainerId anahtarı yok");
  assert.equal(payload.stats.t1.name, "Umut");
  assert.ok("total" in payload.stats.t1 && "completed" in payload.stats.t1);
});

test("buildStatsPayload: yazacak bir şey yoksa null döner", () => {
  const bucket = { gymId: "g1", trainerId: "t1", yearMonth: "2026-09", trainerName: "", isCompleted: false };
  assert.equal(buildStatsPayload(bucket, { total: 0, completed: 0, writeName: false }), null);
});

test("buildStatsPayload: sadece completed değiştiyse total yazılmaz", () => {
  const bucket = { gymId: "g1", trainerId: "t1", yearMonth: "2026-09", trainerName: "Umut", isCompleted: true };
  const payload = buildStatsPayload(bucket, { total: 0, completed: 1, writeName: false }) as Record<string, Record<string, Record<string, unknown>>>;
  assert.ok(!("total" in payload.stats.t1), "total yazılmamalıydı");
  assert.ok(!("name" in payload.stats.t1), "name yazılmamalıydı");
  assert.ok("completed" in payload.stats.t1);
});
