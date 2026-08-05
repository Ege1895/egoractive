const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");
const { setDoc, getDoc, doc } = require("firebase/firestore");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");

/**
 * F2-6 — firestore.rules'daki gyms/{gymId} ve users/{uid} kurallarını
 * (rol/salon bazlı okuma-yazma) her rol için pozitif + negatif senaryolarla
 * doğrular. `npm test` (firestore-tests/) Firestore emulator'ını ayağa
 * kaldırıp bu dosyayı çalıştırır.
 */

let testEnv;

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "egoractive-e92bd",
    firestore: {
      rules: fs.readFileSync(path.resolve(__dirname, "../../firestore.rules"), "utf8"),
    },
  });
});

test.after(async () => {
  await testEnv?.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
  // Kural testleri kendi verisini admin bağlamıyla (kurallara tabi değil)
  // seed eder.
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "gyms/gym-a"), { name: "Gym A" });
    await setDoc(doc(db, "gyms/gym-b"), { name: "Gym B" });
    await setDoc(doc(db, "users/admin-a"), { role: "admin", gymId: "gym-a" });
    await setDoc(doc(db, "users/trainer-a"), { role: "trainer", gymId: "gym-a" });
    await setDoc(doc(db, "users/member-a1"), {
      role: "member",
      gymId: "gym-a",
      trainerId: "trainer-a",
      name: "Member A1",
    });
    await setDoc(doc(db, "users/member-a2"), {
      role: "member",
      gymId: "gym-a",
      trainerId: "trainer-x",
      name: "Member A2",
    });
    await setDoc(doc(db, "users/admin-b"), { role: "admin", gymId: "gym-b" });
  });
});

function contextFor(uid, claims) {
  return testEnv.authenticatedContext(uid, claims);
}

// --- gyms/{gymId} ---

test("unauthenticated user cannot read a gym (negative)", async () => {
  const db = testEnv.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, "gyms/gym-a")));
});

test("signed-in user can read their own gym (positive)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "gyms/gym-a")));
});

test("admin can write to their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(setDoc(doc(db, "gyms/gym-a"), { name: "Gym A Updated" }, { merge: true }));
});

test("non-admin cannot write to their own gym (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(setDoc(doc(db, "gyms/gym-a"), { name: "Hacked" }, { merge: true }));
});

test("admin of a different gym cannot write to this gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(setDoc(doc(db, "gyms/gym-a"), { name: "Hacked" }, { merge: true }));
});

// --- users/{uid} ---

test("a user can read their own users/{uid} document (positive)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "users/member-a1")));
});

test("a member cannot read another member's document (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "users/member-a2")));
});

test("admin can read any user in their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "users/member-a1")));
});

test("admin cannot read a user from a different gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "users/member-a1")));
});

test("trainer can read a member assigned to them (positive)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "users/member-a1")));
});

test("trainer cannot read a member not assigned to them (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "users/member-a2")));
});

test("admin can create a new user document in their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-a", trainerId: "" }),
  );
});

test("admin cannot create a user document for a different gym (negative)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-b", trainerId: "" }),
  );
});

// --- memberPackages/{id} (F3-2) ---

test("admin can create a memberPackages doc for their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 }),
  );
});

test("admin cannot create a memberPackages doc for a different gym (negative)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-b", totalAmount: 9600 }),
  );
});

test("member cannot read a memberPackages doc, even their own (negative — fiyat üyeye gösterilmez)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("memberPackages/pkg-1"), {
      memberId: "member-a1",
      gymId: "gym-a",
      totalAmount: 9600,
    });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "memberPackages/pkg-1")));
});

test("trainer cannot read a memberPackages doc (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("memberPackages/pkg-1"), {
      memberId: "member-a1",
      gymId: "gym-a",
      totalAmount: 9600,
    });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "memberPackages/pkg-1")));
});
