import assert from "node:assert/strict";
import test from "node:test";

import { mapWithConcurrency } from "./concurrency";

test("returns results in the same order as input, regardless of completion timing", async () => {
  const delays = [30, 10, 20, 0];
  const results = await mapWithConcurrency(delays, 2, async (delay, index) => {
    await new Promise((resolve) => setTimeout(resolve, delay));
    return index;
  });
  assert.deepEqual(results, [0, 1, 2, 3]);
});

test("never runs more than `limit` items concurrently", async () => {
  let active = 0;
  let maxActive = 0;
  const items = Array.from({ length: 10 }, (_, i) => i);

  await mapWithConcurrency(items, 3, async () => {
    active++;
    maxActive = Math.max(maxActive, active);
    await new Promise((resolve) => setTimeout(resolve, 5));
    active--;
  });

  assert.ok(maxActive <= 3, `expected max 3 concurrent, got ${maxActive}`);
});

test("handles an empty list", async () => {
  const results = await mapWithConcurrency<number, number>([], 5, async (item) => item);
  assert.deepEqual(results, []);
});

test("handles a limit larger than the item count", async () => {
  const results = await mapWithConcurrency([1, 2, 3], 100, async (item) => item * 2);
  assert.deepEqual(results, [2, 4, 6]);
});
