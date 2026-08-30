import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";

import { userDoc } from "./firestore-paths";

/**
 * F1-10 — `role`/`gymId` custom claim'lerini custom token'a gömüp döner.
 * `verifyLoginOtp` ve `verifyEmailSetupOtp` (aktivasyon sonrası otomatik
 * giriş) tarafından paylaşılır — ilk oturumun ID token'ında role/gymId'nin
 * `onUserRoleAssigned` trigger'ının retry'ını beklemeden hazır olmasını
 * garanti eder.
 */
export async function mintLoginToken(uid: string): Promise<string> {
  const userSnap = await getFirestore().doc(userDoc(uid)).get();
  const userData = userSnap.data();
  const role = typeof userData?.role === "string" ? userData.role : undefined;
  const gymId = typeof userData?.gymId === "string" ? userData.gymId : null;
  const claims = role ? { role, gymId } : undefined;

  const token = await getAuth().createCustomToken(uid, claims);

  if (claims) {
    try {
      await getAuth().setCustomUserClaims(uid, claims);
    } catch (error) {
      if ((error as { code?: string }).code !== "auth/user-not-found") throw error;
    }
  }

  return token;
}
