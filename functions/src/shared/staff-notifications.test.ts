import assert from "node:assert/strict";
import test from "node:test";

import type { Firestore } from "firebase-admin/firestore";

import {
  excludeTokens,
  fetchTokensForUids,
  firstName,
  formatNameList,
  readTokens,
  resolveTokenSource,
} from "./staff-notifications";

test("firstName sadece ilk ismi döner", () => {
  assert.equal(firstName("Ayşe Yılmaz"), "Ayşe");
  assert.equal(firstName("Mehmet Can Öztürk"), "Mehmet");
  assert.equal(firstName("Ayşe"), "Ayşe");
});

test("firstName bozuk/boş girdide çökmez", () => {
  assert.equal(firstName(undefined), "");
  assert.equal(firstName(""), "");
  assert.equal(firstName("   "), "");
  // Araya fazladan boşluk sıkışmış isimler (elle girilen üye adları).
  assert.equal(firstName("  Ayşe   Yılmaz "), "Ayşe");
});

// Düet ders 2 kişiyle sınırlı değil; isim sayısı ne olursa olsun ayraç virgül.
test("formatNameList isimleri virgülle birleştirir", () => {
  assert.equal(formatNameList(["Ayşe", "Mehmet"]), "Ayşe, Mehmet");
  assert.equal(formatNameList(["Ayşe", "Mehmet", "Can"]), "Ayşe, Mehmet, Can");
  assert.equal(
    formatNameList(["Ayşe", "Mehmet", "Can", "Zeynep", "Ali"]),
    "Ayşe, Mehmet, Can, Zeynep, Ali",
  );
});

test("formatNameList tek isimde ayraç eklemez", () => {
  assert.equal(formatNameList(["Ayşe"]), "Ayşe");
});

// Adı kayıtlı olmayan bir üye listeyi bozmamalı: "Ayşe ve " gibi bir metin
// çıkmasın diye boşlar eleniyor.
test("formatNameList boş isimleri eler", () => {
  assert.equal(formatNameList(["Ayşe", ""]), "Ayşe");
  assert.equal(formatNameList(["Ayşe", "", "Can"]), "Ayşe, Can");
  assert.equal(formatNameList(["", "  "]), "");
  assert.equal(formatNameList([]), "");
});

// Grup dersi hatırlatması antrenörlere ve adminlere AYRI çağrılarla, farklı
// metinlerle gidiyor; hem dersin antrenörü hem salonun admini olan bir
// kullanıcı aynı ders için iki bildirim alıyordu.
test("excludeTokens iki listede birden bulunan token'ları eler", () => {
  assert.deepEqual(excludeTokens(["a", "b", "c"], ["b"]), ["a", "c"]);
  assert.deepEqual(excludeTokens(["a", "b"], ["a", "b"]), []);
});

test("excludeTokens kesişim yoksa listeyi olduğu gibi bırakır", () => {
  assert.deepEqual(excludeTokens(["a", "b"], ["c"]), ["a", "b"]);
  assert.deepEqual(excludeTokens(["a", "b"], []), ["a", "b"]);
  assert.deepEqual(excludeTokens([], ["a"]), []);
});

// Eleme token bazında yapılıyor, uid bazında değil — çağıran taraf aynı
// listeyi sonra başka bir amaçla kullanabilir, girdi bozulmamalı.
test("excludeTokens girdiyi değiştirmez", () => {
  const keep = ["a", "b"];
  excludeTokens(keep, ["a"]);
  assert.deepEqual(keep, ["a", "b"]);
});

// --- F11-2: notificationProxyUid yönlendirmesi ---

test("readTokens alanı olmayan/bozuk dokümanda boş liste döner", () => {
  assert.deepEqual(readTokens({ fcmTokens: ["a", "b"] }), ["a", "b"]);
  assert.deepEqual(readTokens({}), []);
  assert.deepEqual(readTokens(undefined), []);
  // Elle düzenlenmiş/bozuk kayıtlar fonksiyonu çökertmemeli.
  assert.deepEqual(readTokens({ fcmTokens: "abc" }), []);
  assert.deepEqual(readTokens({ fcmTokens: ["a", 42, null] }), ["a"]);
});

test("resolveTokenSource proxy alanı yoksa dokümanın kendi token'larını verir", () => {
  assert.deepEqual(resolveTokenSource({ fcmTokens: ["a"] }), { kind: "tokens", tokens: ["a"] });
  assert.deepEqual(resolveTokenSource({}), { kind: "tokens", tokens: [] });
});

test("resolveTokenSource proxy alanı doluysa hedef uid'i verir", () => {
  assert.deepEqual(resolveTokenSource({ notificationProxyUid: "adminUid" }), { kind: "proxy", uid: "adminUid" });
  // Gölge antrenör dokümanında `fcmTokens` hiç olmasa da proxy kazanır;
  // yanlışlıkla ikisi birden yazılmışsa da proxy önceliklidir.
  assert.deepEqual(resolveTokenSource({ notificationProxyUid: "adminUid", fcmTokens: ["eski"] }), {
    kind: "proxy",
    uid: "adminUid",
  });
});

test("resolveTokenSource boş/bozuk proxy alanını yok sayar", () => {
  assert.deepEqual(resolveTokenSource({ notificationProxyUid: "", fcmTokens: ["a"] }), {
    kind: "tokens",
    tokens: ["a"],
  });
  assert.deepEqual(resolveTokenSource({ notificationProxyUid: "   ", fcmTokens: ["a"] }), {
    kind: "tokens",
    tokens: ["a"],
  });
  assert.deepEqual(resolveTokenSource({ notificationProxyUid: 42, fcmTokens: ["a"] }), {
    kind: "tokens",
    tokens: ["a"],
  });
});

/** Sadece `users/{uid}` point-read'i destekleyen minimal Firestore taklidi. */
function fakeDb(docs: Record<string, Record<string, unknown> | undefined>): Firestore {
  return {
    collection: () => ({
      doc: (id: string) => ({
        get: async () => ({ data: () => docs[id] }),
      }),
    }),
  } as unknown as Firestore;
}

test("fetchTokensForUids proxy'si olmayan kullanıcılarda davranışı değiştirmez", async () => {
  const db = fakeDb({ t1: { fcmTokens: ["a", "b"] }, t2: { fcmTokens: ["c"] } });
  assert.deepEqual(await fetchTokensForUids(["t1", "t2"], db), ["a", "b", "c"]);
});

test("fetchTokensForUids proxy'li kullanıcı için hedefin token'larını döner", async () => {
  const db = fakeDb({
    shadow: { notificationProxyUid: "admin" },
    admin: { fcmTokens: ["adminToken"] },
  });
  assert.deepEqual(await fetchTokensForUids(["shadow"], db), ["adminToken"]);
});

// Zincir izlenseydi iki dokümanın birbirini göstermesi sonsuz döngüye
// dönerdi; yönlendirme bilerek tek adım.
test("fetchTokensForUids proxy zincirini takip etmez", async () => {
  const db = fakeDb({
    a: { notificationProxyUid: "b" },
    b: { notificationProxyUid: "c", fcmTokens: ["bToken"] },
    c: { fcmTokens: ["cToken"] },
  });
  assert.deepEqual(await fetchTokensForUids(["a"], db), ["bToken"]);
});

test("fetchTokensForUids hedefi silinmiş proxy'de çökmez", async () => {
  const db = fakeDb({ shadow: { notificationProxyUid: "silinmis" } });
  assert.deepEqual(await fetchTokensForUids(["shadow"], db), []);
});

test("fetchTokensForUids boş/yinelenen uid listesinde okuma yapmaz", async () => {
  const db = fakeDb({ t1: { fcmTokens: ["a"] } });
  assert.deepEqual(await fetchTokensForUids([], db), []);
  assert.deepEqual(await fetchTokensForUids(["  ", ""], db), []);
  assert.deepEqual(await fetchTokensForUids(["t1", "t1"], db), ["a"]);
});
