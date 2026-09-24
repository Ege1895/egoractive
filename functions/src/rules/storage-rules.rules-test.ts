import assert from "node:assert/strict";
import test, { after, before, beforeEach } from "node:test";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { readFileSync } from "node:fs";
import { ref, uploadBytes, getBytes } from "firebase/storage";

/**
 * F13-4 — `gym_logos/{fileName}` yazma kurallarının emulator testleri.
 *
 * Önceden yazma yetkisi "giriş yapmış herhangi biri"ydi ve dosya adı
 * tahmin edilebilir (`{gymId}.png`) olduğu için herhangi bir üye BAŞKA bir
 * salonun logosunu ezebiliyordu. Testler hem yeni kısıtı hem de bozulmaması
 * gereken davranışları (admin kendi logosunu yükleyebilir, logo herkese
 * açık okunur) kapsıyor.
 */

const PROJECT_ID = "egoractive-storage-rules-test";
const GYM_ID = "gym1";
const PNG = new Uint8Array([0x89, 0x50, 0x4e, 0x47]);
const PNG_META = { contentType: "image/png" };

let testEnv: RulesTestEnvironment;

function storageFor(uid: string, claims: Record<string, unknown>) {
  return testEnv.authenticatedContext(uid, claims).storage();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    storage: { rules: readFileSync("../storage.rules", "utf8") },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearStorage();
});

test("salonun admini kendi logosunu yükleyebilir", async () => {
  const storage = storageFor("admin1", { role: "admin", gymId: GYM_ID });
  await assertSucceeds(uploadBytes(ref(storage, `gym_logos/${GYM_ID}.png`), PNG, PNG_META));
});

// Asıl açık buydu: dosya adı tahmin edilebilir olduğu için herhangi bir
// oturum sahibi başka salonun logosunu ezebiliyordu.
test("başka salonun admini o logoyu ezemez", async () => {
  const storage = storageFor("admin2", { role: "admin", gymId: "baskaGym" });
  await assertFails(uploadBytes(ref(storage, `gym_logos/${GYM_ID}.png`), PNG, PNG_META));
});

test("üye ve antrenör logo yazamaz", async () => {
  const member = storageFor("uye1", { role: "member", gymId: GYM_ID });
  await assertFails(uploadBytes(ref(member, `gym_logos/${GYM_ID}.png`), PNG, PNG_META));

  const trainer = storageFor("antrenor1", { role: "trainer", gymId: GYM_ID });
  await assertFails(uploadBytes(ref(trainer, `gym_logos/${GYM_ID}.png`), PNG, PNG_META));
});

test("giriş yapmamış kullanıcı logo yazamaz", async () => {
  const storage = testEnv.unauthenticatedContext().storage();
  await assertFails(uploadBytes(ref(storage, `gym_logos/${GYM_ID}.png`), PNG, PNG_META));
});

// Logo giriş ekranlarında da gösteriliyor; okuma açık kalmalı.
test("logo giriş yapmamış kullanıcıya da okunabilir", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), `gym_logos/${GYM_ID}.png`), PNG, PNG_META);
  });
  const storage = testEnv.unauthenticatedContext().storage();
  const bytes = await assertSucceeds(getBytes(ref(storage, `gym_logos/${GYM_ID}.png`)));
  assert.equal(new Uint8Array(bytes as ArrayBuffer).length, PNG.length);
});

test("admin PNG olmayan ya da çok büyük dosya yükleyemez", async () => {
  const storage = storageFor("admin1", { role: "admin", gymId: GYM_ID });
  await assertFails(
    uploadBytes(ref(storage, `gym_logos/${GYM_ID}.png`), PNG, { contentType: "image/jpeg" }),
  );
  await assertFails(
    uploadBytes(ref(storage, `gym_logos/${GYM_ID}.png`), new Uint8Array(400 * 1024), PNG_META),
  );
});
