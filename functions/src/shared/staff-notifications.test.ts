import assert from "node:assert/strict";
import test from "node:test";

import { excludeTokens, firstName, formatNameList } from "./staff-notifications";

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
