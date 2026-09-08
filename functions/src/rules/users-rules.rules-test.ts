import assert from "node:assert/strict";
import test, { after, before, beforeEach } from "node:test";

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { readFileSync } from "node:fs";
import { setDoc, doc, updateDoc, getDoc, getDocs, query, collection, where } from "firebase/firestore";

/**
 * F11-3 — `match /users/{uid}` yazma kurallarının emulator testleri.
 *
 * Bu dosya `npm test` ile ÇALIŞMAZ (adı `*.test.ts` değil): Firestore
 * emulator'ı gerektirdiği için ayrı `npm run test:rules` script'iyle,
 * `firebase emulators:exec` içinde koşuyor.
 *
 * Neden var: rules deploy'unun kademeli çıkışı YOK — yanlış bir koşul tüm
 * kullanıcıları aynı anda `PERMISSION_DENIED`'a düşürür. Bu yüzden korunan
 * alanların yanında, bugün canlıda çalışan yazma akışlarının hâlâ geçtiği de
 * test ediliyor (regresyon).
 */

const PROJECT_ID = "egoractive-rules-test";
const GYM_ID = "gym1";

let testEnv: RulesTestEnvironment;

/** Abonelik aktif olmayan salonda `users` create'i zaten reddedilir. */
async function seedActiveGym(): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "gyms", GYM_ID), { subscriptionStatus: "active" });
  });
}

async function seedUser(uid: string, data: Record<string, unknown>): Promise<void> {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), "users", uid), data);
  });
}

function dbFor(uid: string, role: string) {
  return testEnv.authenticatedContext(uid, { role, gymId: GYM_ID }).firestore();
}

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: { rules: readFileSync("../firestore.rules", "utf8") },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seedActiveGym();
});

// --- Korunan alanlar: kullanıcı KENDİ dokümanına yazamaz ---

test("üye kendi dokümanına notificationProxyUid yazamaz (bildirim yönlendirme saldırısı)", async () => {
  await seedUser("member1", { role: "member", gymId: GYM_ID, name: "Ayşe" });
  const db = dbFor("member1", "member");
  await assertFails(updateDoc(doc(db, "users", "member1"), { notificationProxyUid: "kurban" }));
});

test("antrenör kendi dokümanına trainerProfileUid yazamaz", async () => {
  await seedUser("trainer1", { role: "trainer", gymId: GYM_ID, name: "Berk" });
  const db = dbFor("trainer1", "trainer");
  await assertFails(updateDoc(doc(db, "users", "trainer1"), { trainerProfileUid: "x" }));
});

test("kullanıcı kendi dokümanına email/emailLower yazamaz (mevcut koruma)", async () => {
  await seedUser("member1", { role: "member", gymId: GYM_ID, name: "Ayşe" });
  const db = dbFor("member1", "member");
  await assertFails(updateDoc(doc(db, "users", "member1"), { email: "a@b.com" }));
  await assertFails(updateDoc(doc(db, "users", "member1"), { emailLower: "a@b.com" }));
});

test("korunan alanlar OLUŞTURMA anında da yazılamaz", async () => {
  const db = dbFor("yeni", "member");
  await assertFails(setDoc(doc(db, "users", "yeni"), { name: "Ayşe", emailLower: "a@b.com" }));
  await assertFails(setDoc(doc(db, "users", "yeni"), { name: "Ayşe", notificationProxyUid: "kurban" }));
});

// --- Regresyon: bugün canlıda çalışan yazma akışları hâlâ geçmeli ---

test("kullanıcı kendi ad/telefonunu güncelleyebilir (updateOwnInfo)", async () => {
  await seedUser("member1", { role: "member", gymId: GYM_ID, name: "Ayşe", phoneNumber: "+905550000000" });
  const db = dbFor("member1", "member");
  await assertSucceeds(
    updateDoc(doc(db, "users", "member1"), {
      name: "Ayşe Yılmaz",
      nameLower: "ayşe yılmaz",
      phoneNumber: "+905551112233",
    }),
  );
});

test("kullanıcı kendi dokümanına fcmToken yazabilir (push kaydı)", async () => {
  await seedUser("member1", { role: "member", gymId: GYM_ID, name: "Ayşe" });
  const db = dbFor("member1", "member");
  await assertSucceeds(updateDoc(doc(db, "users", "member1"), { fcmTokens: ["abc"] }));
});

test("admin üye ekleyebilir (member_registration_service)", async () => {
  const db = dbFor("admin1", "admin");
  await assertSucceeds(
    setDoc(doc(db, "users", "yeniUye"), {
      name: "Ayşe",
      nameLower: "ayşe",
      phoneNumber: "+905551112233",
      role: "member",
      gymId: GYM_ID,
      trainerId: "trainer1",
      trainerName: "Berk",
      canConfirmAttendance: true,
    }),
  );
});

test("admin antrenör ekleyebilir (addTrainer)", async () => {
  const db = dbFor("admin1", "admin");
  await assertSucceeds(
    setDoc(doc(db, "users", "yeniAntrenor"), {
      name: "Berk",
      phoneNumber: "+905551112244",
      role: "trainer",
      gymId: GYM_ID,
      specialties: ["Fonksiyonel"],
    }),
  );
});

// --- F11-1'in yazma akışı ---

test("admin gölge antrenör dokümanını notificationProxyUid ile oluşturabilir", async () => {
  const db = dbFor("admin1", "admin");
  await assertSucceeds(
    setDoc(doc(db, "users", "golge"), {
      name: "Ege",
      nameLower: "ege",
      role: "trainer",
      gymId: GYM_ID,
      specialties: ["Fonksiyonel"],
      isActive: true,
      notificationProxyUid: "admin1",
    }),
  );
});

// Bu, `addSelfAsTrainer`'daki WriteBatch'in İKİNCİ yazması. Self dalı
// `trainerProfileUid`'i reddediyor, admin dalı (gymId eşleşmesiyle) izin
// veriyor — kuralın OR mantığına bağlı olduğu için ayrıca test ediliyor.
test("admin KENDİ dokümanına trainerProfileUid yazabilir", async () => {
  await seedUser("admin1", { role: "admin", gymId: GYM_ID });
  const db = dbFor("admin1", "admin");
  await assertSucceeds(updateDoc(doc(db, "users", "admin1"), { trainerProfileUid: "golge" }));
});

// F11-5 — antrenörlükten çıkıp tekrar eklenirken YENİ doküman açılmıyor,
// mevcut gölge doküman `isActive: true` ile canlandırılıyor.
test("admin gölge antrenör dokümanını yeniden aktive edebilir", async () => {
  await seedUser("golge", {
    role: "trainer",
    gymId: GYM_ID,
    name: "Ege",
    isActive: false,
    notificationProxyUid: "admin1",
  });
  const db = dbFor("admin1", "admin");
  await assertSucceeds(
    updateDoc(doc(db, "users", "golge"), { isActive: true, name: "Ege", specialties: ["Fonksiyonel"] }),
  );
});

// F12-2 — antrenörün adı değişince üye dokümanlarındaki denormalize
// `trainerName` güncelleniyor. Bunun için admin, üyeleri trainerId ile
// sorguluyor; rules admin okumasını `gymId` şartına bağladığı ve Firestore
// liste sorgusuna ancak o alan sorgunun kendi filtresinde de varsa izin
// verdiği için sorgu gymId'yi ZORUNLU taşıyor.
test("admin kendi salonundaki üyeleri gymId+trainerId ile sorgulayabilir", async () => {
  await seedUser("uye1", { role: "member", gymId: GYM_ID, trainerId: "trainer1", trainerName: "Berk" });
  const db = dbFor("admin1", "admin");
  const snapshot = await assertSucceeds(
    getDocs(query(collection(db, "users"), where("gymId", "==", GYM_ID), where("trainerId", "==", "trainer1"))),
  );
  assert.equal((snapshot as { size: number }).size, 1);
});

// gymId filtresi olmadan aynı sorgu reddedilmeli — düşerse yukarıdaki
// filtrenin gerçekten zorunlu olduğu kanıtlanmış olmuyor.
test("admin gymId filtresi olmadan üye sorgulayamaz", async () => {
  await seedUser("uye1", { role: "member", gymId: GYM_ID, trainerId: "trainer1" });
  const db = dbFor("admin1", "admin");
  await assertFails(getDocs(query(collection(db, "users"), where("trainerId", "==", "trainer1"))));
});

test("admin BAŞKA salonun kullanıcısına dokunamaz", async () => {
  await seedUser("yabanci", { role: "member", gymId: "baskaGym", name: "X" });
  const db = dbFor("admin1", "admin");
  await assertFails(updateDoc(doc(db, "users", "yabanci"), { name: "Y" }));
});

test("gölge antrenör dokümanı oluşturulduktan sonra okunabiliyor (seed doğrulaması)", async () => {
  await seedUser("golge", { role: "trainer", gymId: GYM_ID, notificationProxyUid: "admin1" });
  const db = dbFor("admin1", "admin");
  const snap = await getDoc(doc(db, "users", "golge"));
  assert.equal(snap.data()?.notificationProxyUid, "admin1");
});
