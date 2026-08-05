const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");
const { setDoc, updateDoc, getDoc, doc, Timestamp } = require("firebase/firestore");
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

// --- sessions/{sessionId} (F3-3) ---

function hoursFromNow(hours) {
  return Timestamp.fromMillis(Date.now() + hours * 60 * 60 * 1000);
}

async function seedSession(id, { trainerId, memberId, startTime, endTime, status = "planned" }) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc(`sessions/${id}`), {
      gymId: "gym-a",
      trainerId,
      memberId,
      startTime,
      endTime: endTime ?? startTime,
      status,
    });
  });
}

test("admin can create a session for their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "sessions/s1"), {
      gymId: "gym-a",
      trainerId: "trainer-a",
      memberId: "member-a1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("trainer cannot create a session (negative — only admin screens create)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "sessions/s1"), {
      gymId: "gym-a",
      trainerId: "trainer-a",
      memberId: "member-a1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("admin can cancel a session starting in 1 hour (positive — no deadline for admin)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(1) });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("trainer cannot cancel their own session starting in 1 hour (negative — inside 24h window)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(1) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("trainer can cancel their own session starting in 48 hours (positive — outside 24h window)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("member cannot cancel another member's session (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a2", startTime: hoursFromNow(48) });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("member can read a session in their own gym (positive)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "sessions/s1")));
});

// --- sessions/{sessionId}.memberConfirmation (F3-4) ---

test("member can set memberConfirmation on their own session even 1 hour before (positive — 24h kuralına tabi değil)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(1) });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { memberConfirmation: "coming" }));
});

test("member cannot set memberConfirmation on another member's session (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a2", startTime: hoursFromNow(1) });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { memberConfirmation: "coming" }));
});

test("member cannot change status while setting memberConfirmation (negative — sadece o alanı değiştirebilir)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(1) });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { memberConfirmation: "coming", status: "cancelled" }));
});

// --- ders tamamlama onayı (F3-5) ---

test("trainer can mark their own past session as completed (positive — 24h kuralına tabi değil, ders zaten bitmiş)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(-2), endTime: hoursFromNow(-1) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { status: "completed", attended: true }));
});

test("trainer can mark their own past session as no-show (positive)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(-2), endTime: hoursFromNow(-1) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { status: "completed", attended: false }));
});

test("trainer cannot mark another trainer's session as completed (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-x", memberId: "member-a1", startTime: hoursFromNow(-2), endTime: hoursFromNow(-1) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "completed", attended: true }));
});

test("trainer cannot change other fields while marking a session completed (negative — sadece status+attended)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(-2), endTime: hoursFromNow(-1) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "completed", attended: true, memberId: "member-a2" }));
});

test("trainer can decrement remainingSessions on their own assigned member (positive — tamamlama transaction'ının parçası)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("users/member-a1"), {
      role: "member",
      gymId: "gym-a",
      trainerId: "trainer-a",
      remainingSessions: 5,
    });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "users/member-a1"), { remainingSessions: 4 }));
});

test("trainer cannot decrement remainingSessions on a member not assigned to them (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "users/member-a2"), { remainingSessions: 4 }));
});

test("trainer cannot change other fields while updating remainingSessions (negative — sadece o alan)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("users/member-a1"), {
      role: "member",
      gymId: "gym-a",
      trainerId: "trainer-a",
      remainingSessions: 5,
    });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "users/member-a1"), { remainingSessions: 4, name: "Hacked" }));
});

// --- measurements/{uid}/entries/{entryId} (F4-1) ---

test("member can write their own measurement entry (positive)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(setDoc(doc(db, "measurements/member-a1/entries/e1"), { bel: 74.5 }));
});

test("member can read their own measurement entry (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "measurements/member-a1/entries/e1")));
});

test("member cannot read another member's measurement entry (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a2/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-a2/entries/e1")));
});

test("trainer cannot read their member's measurement entry (negative — sağlık verisi tamamen özel)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-a1/entries/e1")));
});

test("admin cannot read a member's measurement entry (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-a1/entries/e1")));
});
