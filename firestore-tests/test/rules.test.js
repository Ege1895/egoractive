const fs = require("node:fs");
const path = require("node:path");
const test = require("node:test");
const assert = require("node:assert/strict");
const { setDoc, updateDoc, deleteDoc, getDoc, doc, Timestamp, runTransaction, arrayUnion } = require("firebase/firestore");
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
    await setDoc(doc(db, "gyms/gym-a"), { name: "Gym A", subscriptionStatus: "trial" });
    await setDoc(doc(db, "gyms/gym-b"), { name: "Gym B", subscriptionStatus: "trial" });
    // F6-3 — deneme süresi dolmuş/aboneliği sona ermiş bir salon.
    await setDoc(doc(db, "gyms/gym-expired"), { name: "Gym Expired", subscriptionStatus: "expired" });
    // Salon Abonelik ve Erişim Akışı — subscriptionExempt=true, alanı hiç
    // olmayan (eski/legacy) bir salon da dahil, abonelik durumundan bağımsız
    // her zaman aktif sayılmalı.
    await setDoc(doc(db, "gyms/gym-exempt"), { name: "Gym Exempt", subscriptionExempt: true });
    await setDoc(doc(db, "users/admin-exempt"), { role: "admin", gymId: "gym-exempt" });
    await setDoc(doc(db, "users/admin-expired"), { role: "admin", gymId: "gym-expired" });
    await setDoc(doc(db, "users/trainer-expired"), { role: "trainer", gymId: "gym-expired" });
    await setDoc(doc(db, "users/member-expired"), {
      role: "member",
      gymId: "gym-expired",
      trainerId: "trainer-expired",
      name: "Member Expired",
    });
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
    for (let i = 1; i <= 10; i++) {
      await setDoc(doc(db, `users/load-${i}`), { role: "member", gymId: "gym-a", trainerId: "trainer-a" });
    }
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

test("a user from a different gym cannot read this gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "gyms/gym-a")));
});

test("trainer cannot create a gym doc (negative — sadece admin onboarding'i)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-new" }).firestore();
  await assertFails(setDoc(doc(db, "gyms/gym-new"), { name: "New Gym", subscriptionStatus: "trial" }));
});

test("admin can delete their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(deleteDoc(doc(db, "gyms/gym-a")));
});

test("non-admin cannot delete a gym (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "gyms/gym-a")));
});

test("admin of a different gym cannot delete this gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(deleteDoc(doc(db, "gyms/gym-a")));
});

// --- gyms/{gymId}/packages/{packageId} — paket kataloğu (F4-9) ---

test("member can read their own gym's package catalog (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "gyms/gym-a/packages/pkg-1")));
});

test("a user from a different gym cannot read this gym's package catalog (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 });
  });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "gyms/gym-a/packages/pkg-1")));
});

test("admin can create a package catalog entry for their own (non-expired) gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 }),
  );
});

test("trainer cannot create a package catalog entry (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 }),
  );
});

test("admin can delete a package catalog entry (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(deleteDoc(doc(db, "gyms/gym-a/packages/pkg-1")));
});

test("trainer cannot delete a package catalog entry (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-a/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "gyms/gym-a/packages/pkg-1")));
});

// --- gyms/{gymId} subscription fields (F6-1) ---

test("admin can create a gym doc without any subscription field (positive — gerçek akış Admin SDK üzerinden, bu client yolu sadece güvenlik ağı)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-new" }).firestore();
  await assertSucceeds(setDoc(doc(db, "gyms/gym-new"), { name: "New Gym" }));
});

test("admin cannot create a gym doc directly as 'trial' (negative — Salon Abonelik ve Erişim Akışı: trial artık sadece gerçek mağaza satın almasıyla başlar)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-new" }).firestore();
  await assertFails(
    setDoc(doc(db, "gyms/gym-new"), { name: "New Gym", subscriptionStatus: "trial" }),
  );
});

test("admin cannot create a gym doc directly as 'active' (negative — bedava premium'a geçemez)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-new" }).firestore();
  await assertFails(
    setDoc(doc(db, "gyms/gym-new"), { name: "New Gym", subscriptionStatus: "active" }),
  );
});

test("admin cannot upgrade their own gym's subscriptionStatus by writing to it directly (negative)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "gyms/gym-a"), { subscriptionStatus: "active" }, { merge: true }),
  );
});

test("admin can still update non-subscription fields on their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "gyms/gym-a"), { name: "Gym A Renamed" }, { merge: true }),
  );
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

test("trainer cannot create a user document for someone else (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-a", trainerId: "trainer-a" }),
  );
});

test("member cannot create a user document for someone else (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-a", trainerId: "" }),
  );
});

test("admin can delete a member in their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(deleteDoc(doc(db, "users/member-a1")));
});

test("admin of a different gym cannot delete a member (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(deleteDoc(doc(db, "users/member-a1")));
});

test("trainer cannot delete a member (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "users/member-a1")));
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

test("trainer cannot create a memberPackages doc (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 }),
  );
});

test("member cannot create a memberPackages doc (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 }),
  );
});

test("admin can read a memberPackages doc in their own gym (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "memberPackages/pkg-1")));
});

test("admin can update/delete a memberPackages doc in their own gym (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(setDoc(doc(db, "memberPackages/pkg-1"), { paidAmount: 4800 }, { merge: true }));
  await assertSucceeds(deleteDoc(doc(db, "memberPackages/pkg-1")));
});

test("admin of a different gym cannot update/delete a memberPackages doc (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("memberPackages/pkg-1"), { memberId: "member-a1", gymId: "gym-a", totalAmount: 9600 });
  });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(setDoc(doc(db, "memberPackages/pkg-1"), { paidAmount: 4800 }, { merge: true }));
  await assertFails(deleteDoc(doc(db, "memberPackages/pkg-1")));
});

// --- expenses/{id} (F5-1 — dashboard'ın okuduğu, F5-3'te giriş ekranı gelecek) ---

test("admin can create an expenses doc for their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 }),
  );
});

test("admin cannot create an expenses doc for a different gym (negative)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "expenses/exp-1"), { gymId: "gym-b", category: "Kira", amountTl: 65000 }),
  );
});

test("member cannot read an expenses doc (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "expenses/exp-1")));
});

test("trainer cannot read an expenses doc (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "expenses/exp-1")));
});

test("trainer cannot create an expenses doc (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(setDoc(doc(db, "expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 }));
});

test("member cannot create an expenses doc (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(setDoc(doc(db, "expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 }));
});

test("admin can read an expenses doc in their own gym (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "expenses/exp-1")));
});

test("admin can update/delete an expenses doc in their own gym (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(setDoc(doc(db, "expenses/exp-1"), { amountTl: 70000 }, { merge: true }));
  await assertSucceeds(deleteDoc(doc(db, "expenses/exp-1")));
});

test("admin of a different gym cannot update/delete an expenses doc (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("expenses/exp-1"), { gymId: "gym-a", category: "Kira", amountTl: 65000 });
  });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(setDoc(doc(db, "expenses/exp-1"), { amountTl: 70000 }, { merge: true }));
  await assertFails(deleteDoc(doc(db, "expenses/exp-1")));
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

test("trainer can create a session for themselves (positive — own calendar/member detail screen)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
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

test("trainer cannot create a session for another trainer (negative)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "sessions/s1"), {
      gymId: "gym-a",
      trainerId: "trainer-b",
      memberId: "member-a1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("member cannot create a session (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
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

test("admin of a different gym cannot read/update a session (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "sessions/s1")));
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
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

test("trainer cannot cancel their own session when canCancelMemberSessions is explicitly false (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "gyms/gym-a"),
      { trainerPermissions: { "trainer-a": { canCancelMemberSessions: false } } },
      { merge: true },
    );
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("trainer can still cancel their own session when only canRescheduleMemberSessions is false (positive — ayrı yetkiler)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "gyms/gym-a"),
      { trainerPermissions: { "trainer-a": { canRescheduleMemberSessions: false } } },
      { merge: true },
    );
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "sessions/s1"), { status: "cancelled" }));
});

test("trainer cannot reschedule their own session when canRescheduleMemberSessions is explicitly false (negative)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "gyms/gym-a"),
      { trainerPermissions: { "trainer-a": { canRescheduleMemberSessions: false } } },
      { merge: true },
    );
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    updateDoc(doc(db, "sessions/s1"), {
      startTime: hoursFromNow(72),
      endTime: hoursFromNow(73),
      confirmationRequested: false,
      completionPushSent: false,
    }),
  );
});

test("trainer can reschedule their own session when canRescheduleMemberSessions is unset (positive — varsayılan true)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(48) });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    updateDoc(doc(db, "sessions/s1"), {
      startTime: hoursFromNow(72),
      endTime: hoursFromNow(73),
      confirmationRequested: false,
      completionPushSent: false,
    }),
  );
});

test("admin can cancel a trainer's session even when that trainer's canCancelMemberSessions is false (positive — admin sınırsız)", async () => {
  await seedSession("s1", { trainerId: "trainer-a", memberId: "member-a1", startTime: hoursFromNow(1) });
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(
      doc(context.firestore(), "gyms/gym-a"),
      { trainerPermissions: { "trainer-a": { canCancelMemberSessions: false } } },
      { merge: true },
    );
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
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

test("trainer can update both remainingSessions and plannedSessionsCount together (positive — seans oluşturma/tamamlama sayaçları)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("users/member-a1"), {
      role: "member",
      gymId: "gym-a",
      trainerId: "trainer-a",
      remainingSessions: 5,
      plannedSessionsCount: 2,
    });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    updateDoc(doc(db, "users/member-a1"), { remainingSessions: 4, plannedSessionsCount: 3 }),
  );
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

test("trainer can read+write their assigned member's measurement entry (positive — üye detayından ölçüm ekranı)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "measurements/member-a1/entries/e1")));
  await assertSucceeds(setDoc(doc(db, "measurements/member-a1/entries/e2"), { bel: 73.0 }));
});

test("trainer not assigned to the member cannot read their measurement entry (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    // member-a2'nin trainerId'si trainer-x, trainer-a değil.
    await setDoc(context.firestore().doc("measurements/member-a2/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-a2/entries/e1")));
});

test("admin can read+write a member's measurement entry in their own gym (positive — üye detayından ölçüm ekranı)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "measurements/member-a1/entries/e1")));
  await assertSucceeds(setDoc(doc(db, "measurements/member-a1/entries/e2"), { bel: 73.0 }));
});

test("admin of a different gym cannot read a member's measurement entry (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-a1/entries/e1"), { bel: 74.5 });
  });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-a1/entries/e1")));
});

// --- groupSessions/{id} (F4-2) ---

async function seedGroupSession(id, { capacity, attendeeIds = [] }) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc(`groupSessions/${id}`), {
      gymId: "gym-a",
      title: "Reformer Grup",
      trainerName: "Selin Kara",
      capacity,
      attendeeIds,
    });
  });
}

test("admin can create a group session for their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-a", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("trainer can create a group session for their own gym (positive)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-a", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("member cannot create a group session (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-a", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("admin of a different gym cannot create a group session for another gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-a", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("admin can update any field of a group session (positive)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "groupSessions/gs1"), { title: "Reformer Grup (güncel)", capacity: 10 }));
});

test("admin can delete a group session (positive)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(deleteDoc(doc(db, "groupSessions/gs1")));
});

test("member cannot delete a group session (negative)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "groupSessions/gs1")));
});

test("member can join a group session with room left (positive)", async () => {
  await seedGroupSession("gs1", { capacity: 2, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "groupSessions/gs1"), { attendeeIds: arrayUnion("member-a1") }));
});

test("member cannot join a full group session (negative — kontenjan dolu)", async () => {
  await seedGroupSession("gs1", { capacity: 1, attendeeIds: ["member-a2"] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "groupSessions/gs1"), { attendeeIds: arrayUnion("member-a1") }));
});

test("member cannot join on behalf of another member (negative)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "groupSessions/gs1"), { attendeeIds: arrayUnion("member-a2") }));
});

test("member can leave a group session they joined (positive)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: ["member-a1"] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    updateDoc(doc(db, "groupSessions/gs1"), { attendeeIds: [] }),
  );
});

test("member cannot change other fields while joining (negative — sadece attendeeIds)", async () => {
  await seedGroupSession("gs1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    updateDoc(doc(db, "groupSessions/gs1"), { attendeeIds: arrayUnion("member-a1"), capacity: 100 }),
  );
});

test("YÜK TESTİ: 10 eşzamanlı katılım isteğinde kontenjan (capacity=5) hiçbir zaman aşılmıyor", async () => {
  await seedGroupSession("gs-load", { capacity: 5, attendeeIds: [] });

  async function join(uid) {
    const db = contextFor(uid, { role: "member", gymId: "gym-a" }).firestore();
    const ref = doc(db, "groupSessions/gs-load");
    try {
      await runTransaction(db, async (transaction) => {
        const snapshot = await transaction.get(ref);
        const data = snapshot.data();
        const attendeeIds = data.attendeeIds || [];
        if (attendeeIds.includes(uid)) return;
        if (attendeeIds.length >= data.capacity) {
          throw new Error("Kontenjan doldu.");
        }
        transaction.update(ref, { attendeeIds: arrayUnion(uid) });
      });
      return true;
    } catch {
      return false;
    }
  }

  const uids = Array.from({ length: 10 }, (_, i) => `load-${i + 1}`);
  const results = await Promise.all(uids.map(join));
  const succeeded = results.filter(Boolean).length;

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const finalSnapshot = await getDoc(context.firestore().doc("groupSessions/gs-load"));
    const finalAttendees = finalSnapshot.data().attendeeIds || [];
    assert.equal(finalAttendees.length, 5, "kontenjan (5) ile bitmeli, aşmamalı ya da eksik kalmamalı");
    assert.equal(succeeded, 5, "sadece 5 istek başarılı olmalı");
    assert.equal(new Set(finalAttendees).size, 5, "attendeeIds içinde tekrar olmamalı");
  });
});

// --- events/{id} (F4-3) — groupSessions ile aynı kontenjan kuralları ---

async function seedEvent(id, { capacity, attendeeIds = [] }) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc(`events/${id}`), {
      gymId: "gym-a",
      name: "Yaz Şenliği",
      location: "Bahçe",
      capacity,
      attendeeIds,
    });
  });
}

test("admin can create an event for their own gym (positive)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "events/ev1"), { gymId: "gym-a", name: "Yaz Şenliği", capacity: 20, attendeeIds: [] }),
  );
});

test("trainer can create an event for their own gym (positive)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "events/ev1"), { gymId: "gym-a", name: "Yaz Şenliği", capacity: 20, attendeeIds: [] }),
  );
});

test("member cannot create an event (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "events/ev1"), { gymId: "gym-a", name: "Yaz Şenliği", capacity: 20, attendeeIds: [] }),
  );
});

test("admin of a different gym cannot create an event for another gym (negative)", async () => {
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(
    setDoc(doc(db, "events/ev1"), { gymId: "gym-a", name: "Yaz Şenliği", capacity: 20, attendeeIds: [] }),
  );
});

test("admin can update any field of an event (positive)", async () => {
  await seedEvent("ev1", { capacity: 20, attendeeIds: [] });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "events/ev1"), { name: "Yaz Şenliği (güncel)", capacity: 25 }));
});

test("admin can delete an event (positive)", async () => {
  await seedEvent("ev1", { capacity: 20, attendeeIds: [] });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(deleteDoc(doc(db, "events/ev1")));
});

test("member cannot delete an event (negative)", async () => {
  await seedEvent("ev1", { capacity: 20, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "events/ev1")));
});

test("member can join an event with room left (positive)", async () => {
  await seedEvent("ev1", { capacity: 2, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "events/ev1"), { attendeeIds: arrayUnion("member-a1") }));
});

test("member cannot join a full event (negative — kontenjan dolu)", async () => {
  await seedEvent("ev1", { capacity: 1, attendeeIds: ["member-a2"] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "events/ev1"), { attendeeIds: arrayUnion("member-a1") }));
});

test("member can join an unlimited-capacity event (positive — capacity null)", async () => {
  await seedEvent("ev1", { capacity: null, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "events/ev1"), { attendeeIds: arrayUnion("member-a1") }));
});

test("member can leave an event they joined (positive)", async () => {
  await seedEvent("ev1", { capacity: 8, attendeeIds: ["member-a1"] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(updateDoc(doc(db, "events/ev1"), { attendeeIds: [] }));
});

test("member cannot change other fields while joining an event (negative — sadece attendeeIds)", async () => {
  await seedEvent("ev1", { capacity: 8, attendeeIds: [] });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    updateDoc(doc(db, "events/ev1"), { attendeeIds: arrayUnion("member-a1"), capacity: 100 }),
  );
});

// --- feedback/{id} (F5-4) ---

test("member can create their own feedback for their own gym (positive)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "feedback/fb1"), {
      gymId: "gym-a",
      memberId: "member-a1",
      memberName: "Member A1",
      trainerId: "trainer-a",
      trainerName: "Trainer A",
      stars: 5,
      comment: "Harikaydı",
    }),
  );
});

test("member cannot create feedback on behalf of another member (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "feedback/fb1"), {
      gymId: "gym-a",
      memberId: "member-a2",
      stars: 5,
      comment: "Harikaydı",
    }),
  );
});

test("member cannot create feedback for a different gym (negative)", async () => {
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "feedback/fb1"), {
      gymId: "gym-b",
      memberId: "member-a1",
      stars: 5,
      comment: "Harikaydı",
    }),
  );
});

test("admin cannot create feedback (negative — sadece üye gönderir)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5, comment: "Harikaydı" }),
  );
});

test("trainer cannot create feedback (negative — sadece üye gönderir)", async () => {
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(
    setDoc(doc(db, "feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5, comment: "Harikaydı" }),
  );
});

test("admin can read feedback for their own gym (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "feedback/fb1")));
});

test("admin from a different gym cannot read feedback (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("admin-b", { role: "admin", gymId: "gym-b" }).firestore();
  await assertFails(getDoc(doc(db, "feedback/fb1")));
});

test("trainer cannot read feedback (negative — antrenöre hiç açılmıyor)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("trainer-a", { role: "trainer", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "feedback/fb1")));
});

test("member cannot read another member's feedback (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("member-a2", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "feedback/fb1")));
});

test("member cannot read their own feedback either (negative — gönderim tek yönlü, admin dışında kimse okuyamaz)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "feedback/fb1")));
});

test("nobody can update feedback after it's submitted, not even admin (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(updateDoc(doc(db, "feedback/fb1"), { stars: 1 }));
});

test("nobody can delete feedback, not even the member who wrote it (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("feedback/fb1"), { gymId: "gym-a", memberId: "member-a1", stars: 5 });
  });
  const db = contextFor("member-a1", { role: "member", gymId: "gym-a" }).firestore();
  await assertFails(deleteDoc(doc(db, "feedback/fb1")));
});

// --- F6-3: gymSubscriptionAllowsWrite() — expired bir salon yeni içerik oluşturamaz ---

test("admin of an expired gym cannot create a new member (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-expired", trainerId: "" }),
  );
});

test("admin of an expired gym cannot create a memberPackages doc (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "memberPackages/pkg-1"), { memberId: "m1", gymId: "gym-expired", totalAmount: 9600 }),
  );
});

test("admin of an expired gym cannot create a session (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "sessions/s1"), {
      gymId: "gym-expired",
      trainerId: "trainer-expired",
      memberId: "m1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("trainer of an expired gym cannot create a session for themselves either (negative — salon bazlı kısıt)", async () => {
  const db = contextFor("trainer-expired", { role: "trainer", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "sessions/s1"), {
      gymId: "gym-expired",
      trainerId: "trainer-expired",
      memberId: "m1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("admin of an expired gym cannot create a group session (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-expired", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("trainer of an expired gym cannot create a group session either (negative — salon bazlı kısıt)", async () => {
  const db = contextFor("trainer-expired", { role: "trainer", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "groupSessions/gs1"), { gymId: "gym-expired", title: "Mat Pilates", capacity: 8, attendeeIds: [] }),
  );
});

test("admin of an expired gym cannot create an event (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "events/ev1"), { gymId: "gym-expired", name: "Yaz Şenliği", capacity: 20, attendeeIds: [] }),
  );
});

test("admin of an expired gym cannot create an expense (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "expenses/exp-1"), { gymId: "gym-expired", category: "Kira", amountTl: 65000 }),
  );
});

test("admin of an expired gym cannot create a studio package catalog entry (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(
    setDoc(doc(db, "gyms/gym-expired/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 }),
  );
});

test("admin of an expired gym CAN still update an existing studio package (positive — sadece yeni oluşturma engelli)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-expired/packages/pkg-1"), {
      name: "10 Ders",
      sessionCount: 10,
      priceTl: 9600,
    });
  });
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "gyms/gym-expired/packages/pkg-1"), { name: "10 Ders (güncel)" }, { merge: true }),
  );
});

test("admin of an expired gym CAN still update an existing session (positive — ör. tamamlama/iptal)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("sessions/s1"), {
      gymId: "gym-expired",
      trainerId: "trainer-expired",
      memberId: "m1",
      startTime: hoursFromNow(48),
      endTime: hoursFromNow(49),
      status: "planned",
    });
  });
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertSucceeds(setDoc(doc(db, "sessions/s1"), { status: "cancelled" }, { merge: true }));
});

test("admin of a gym with subscriptionStatus 'active' CAN create a new member (positive — sadece 'trial' değil, 'active' de yazmaya izin veriyor)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-active"), { name: "Gym Active", subscriptionStatus: "active" });
  });
  const db = contextFor("admin-active", { role: "admin", gymId: "gym-active" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "users/new-member"), { role: "member", gymId: "gym-active", trainerId: "" }),
  );
});

// --- Salon Abonelik ve Erişim Akışı — abonelik inaktifken TÜM okuma da kesilir ---
// (F6-3'ün orijinal tasarımı sadece create'i engelliyordu; bu daha geniş
// kilitleme onun yerini alıyor — bkz. firestore.rules'daki gymSubscriptionActive() yorumu.)

test("gyms/{gymId} document itself stays readable even when the subscription is inactive (positive — client durumu görüp yönlenebilsin diye bilerek kapsam dışı)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertSucceeds(getDoc(doc(db, "gyms/gym-expired")));
});

test("a user can still read their OWN users/{uid} document even when their gym's subscription is inactive (positive — rol/salon çözüp engellendi ekranını gösterebilmek için gerekli asgari okuma)", async () => {
  const db = contextFor("member-expired", { role: "member", gymId: "gym-expired" }).firestore();
  await assertSucceeds(getDoc(doc(db, "users/member-expired")));
});

test("admin of an expired gym cannot read another user in the same gym (negative)", async () => {
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(getDoc(doc(db, "users/member-expired")));
});

test("trainer of an expired gym cannot read their own member (negative)", async () => {
  const db = contextFor("trainer-expired", { role: "trainer", gymId: "gym-expired" }).firestore();
  await assertFails(getDoc(doc(db, "users/member-expired")));
});

test("admin of an expired gym cannot read a session in their own gym (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("sessions/s-expired"), {
      gymId: "gym-expired",
      trainerId: "trainer-expired",
      memberId: "member-expired",
      startTime: hoursFromNow(48),
      status: "planned",
    });
  });
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(getDoc(doc(db, "sessions/s-expired")));
});

test("member of an expired gym cannot read their own measurements (negative — tam kilitleme niyeti)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("measurements/member-expired/entries/e1"), { kilo: 70 });
  });
  const db = contextFor("member-expired", { role: "member", gymId: "gym-expired" }).firestore();
  await assertFails(getDoc(doc(db, "measurements/member-expired/entries/e1")));
});

test("admin of an expired gym cannot read the studio package catalog (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-expired/packages/pkg-1"), { name: "10 Ders", sessionCount: 10, priceTl: 9600 });
  });
  const db = contextFor("admin-expired", { role: "admin", gymId: "gym-expired" }).firestore();
  await assertFails(getDoc(doc(db, "gyms/gym-expired/packages/pkg-1")));
});

test("admin of a trial/active gym CAN still read a session (positive — sadece expired kilitleniyor)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("sessions/s-a"), {
      gymId: "gym-a",
      trainerId: "trainer-a",
      memberId: "member-a1",
      startTime: hoursFromNow(48),
      status: "planned",
    });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertSucceeds(getDoc(doc(db, "sessions/s-a")));
});

// --- subscriptionHistory / subscriptionTransactions — Admin SDK-only ---

test("nobody (not even the gym's own admin) can read subscriptionHistory (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-a/subscriptionHistory/h1"), { status: "active" });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "gyms/gym-a/subscriptionHistory/h1")));
});

test("nobody can read subscriptionTransactions (negative)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("subscriptionTransactions/tx-1"), { gymId: "gym-a" });
  });
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(getDoc(doc(db, "subscriptionTransactions/tx-1")));
});

test("admin cannot set trialUsed directly on their own gym (negative — sadece Admin SDK yazabilir)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(setDoc(doc(db, "gyms/gym-a"), { trialUsed: true }, { merge: true }));
});

// --- subscriptionExempt — Console'dan elle "abonelik gerekmiyor" işaretlenmiş salonlar ---

test("admin of a subscriptionExempt gym (no subscriptionStatus field at all) CAN create a session (positive)", async () => {
  const db = contextFor("admin-exempt", { role: "admin", gymId: "gym-exempt" }).firestore();
  await assertSucceeds(
    setDoc(doc(db, "sessions/s-exempt"), {
      gymId: "gym-exempt",
      trainerId: "trainer-exempt",
      memberId: "m1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});

test("admin of a subscriptionExempt gym CAN read a session (positive)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("sessions/s-exempt"), {
      gymId: "gym-exempt",
      trainerId: "trainer-exempt",
      memberId: "m1",
      startTime: hoursFromNow(48),
      status: "planned",
    });
  });
  const db = contextFor("admin-exempt", { role: "admin", gymId: "gym-exempt" }).firestore();
  await assertSucceeds(getDoc(doc(db, "sessions/s-exempt")));
});

test("admin cannot set subscriptionExempt directly on their own gym (negative — sadece Console/Admin SDK)", async () => {
  const db = contextFor("admin-a", { role: "admin", gymId: "gym-a" }).firestore();
  await assertFails(setDoc(doc(db, "gyms/gym-a"), { subscriptionExempt: true }, { merge: true }));
});

test("a gym with neither subscriptionStatus nor subscriptionExempt set still blocks reads (negative — güvenli varsayılan)", async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(context.firestore().doc("gyms/gym-blank"), { name: "Gym Blank" });
    await setDoc(context.firestore().doc("users/admin-blank"), { role: "admin", gymId: "gym-blank" });
  });
  const db = contextFor("admin-blank", { role: "admin", gymId: "gym-blank" }).firestore();
  await assertFails(
    setDoc(doc(db, "sessions/s-blank"), {
      gymId: "gym-blank",
      trainerId: "trainer-blank",
      memberId: "m1",
      startTime: hoursFromNow(48),
      status: "planned",
    }),
  );
});
