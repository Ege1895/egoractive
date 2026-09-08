import assert from "node:assert/strict";
import test from "node:test";

import type { Firestore } from "firebase-admin/firestore";

import { removeFromAttendeeLists } from "./account-cleanup";

interface RecordedUpdate {
  collection: string;
  docId: string;
}

/**
 * `collection().where().get()` ve `batch()` zincirini karşılayan en küçük
 * Firestore taklidi. `docsByCollection`, o koleksiyonda ARANAN uid'i
 * içeren dokümanların id'lerini temsil ediyor; `updates` ise hangi
 * dokümanlara yazıldığını sırasıyla kaydediyor.
 */
function fakeDb(docsByCollection: Record<string, string[]>): { db: Firestore; updates: RecordedUpdate[] } {
  const updates: RecordedUpdate[] = [];
  const db = {
    collection: (collectionName: string) => ({
      where: () => ({
        get: async () => {
          const ids = docsByCollection[collectionName] ?? [];
          return {
            empty: ids.length === 0,
            docs: ids.map((docId) => ({ ref: { collectionName, docId } })),
          };
        },
      }),
    }),
    batch: () => ({
      update: (ref: { collectionName: string; docId: string }) =>
        updates.push({ collection: ref.collectionName, docId: ref.docId }),
      commit: async () => {},
    }),
  } as unknown as Firestore;
  return { db, updates };
}

test("removeFromAttendeeLists iki koleksiyondan da çıkarır", async () => {
  const { db, updates } = fakeDb({ groupSessions: ["gs1", "gs2"], events: ["ev1"] });
  const updated = await removeFromAttendeeLists("uye1", db);
  assert.equal(updated, 3);
  assert.deepEqual(updates, [
    { collection: "groupSessions", docId: "gs1" },
    { collection: "groupSessions", docId: "gs2" },
    { collection: "events", docId: "ev1" },
  ]);
});

test("removeFromAttendeeLists eşleşme yoksa yazma yapmaz", async () => {
  const { db, updates } = fakeDb({});
  assert.equal(await removeFromAttendeeLists("uye1", db), 0);
  assert.deepEqual(updates, []);
});

test("removeFromAttendeeLists yalnızca bir koleksiyonda eşleşme olsa da çalışır", async () => {
  const { db, updates } = fakeDb({ events: ["ev1", "ev2"] });
  assert.equal(await removeFromAttendeeLists("uye1", db), 2);
  assert.deepEqual(updates.map((u) => u.collection), ["events", "events"]);
});

// Firestore'un 500 işlem sınırı: çok sayıda derse katılmış bir üyede
// yazmalar birden fazla batch'e bölünmeli, hiçbiri düşmemeli.
test("removeFromAttendeeLists 400'den fazla dokümanı batch'lere böler", async () => {
  const many = Array.from({ length: 950 }, (_, i) => `gs${i}`);
  const { db, updates } = fakeDb({ groupSessions: many });
  assert.equal(await removeFromAttendeeLists("uye1", db), 950);
  assert.equal(updates.length, 950);
});
