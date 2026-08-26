import { getFirestore } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/v2/https";

export interface PartnerGym {
  id: string;
  name: string;
  phone: string;
  city: string;
  address: string;
  logoUrl: string;
}

/**
 * Girişten önceki rol seçim ekranında ("Anlaşmalı Salonlar") gösterilir —
 * bu yüzden auth GEREKTİRMEZ (bkz. `request-custom-token.ts`'deki aynı
 * pre-auth callable deseni). `gyms/{gymId}` için firestore.rules hâlâ
 * `isSignedIn()` şartı taşıyor (bilerek — subscriptionStatus/trialStartedAt/
 * themeColors gibi hassas alanları anonim istemcilere açmamak için); rules'u
 * gevşetmek yerine burada Admin SDK ile rules bypass edilip yalnızca bu
 * public alan alt kümesi döndürülüyor.
 */
export const listPartnerGyms = onCall(async () => {
  const snapshot = await getFirestore().collection("gyms").get();

  const gyms: PartnerGym[] = snapshot.docs
    .map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        name: typeof data.name === "string" ? data.name : "",
        phone: typeof data.phone === "string" ? data.phone : "",
        city: typeof data.city === "string" ? data.city : "",
        address: typeof data.address === "string" ? data.address : "",
        logoUrl: typeof data.logoUrl === "string" ? data.logoUrl : "",
      };
    })
    .filter((gym) => gym.name !== "");

  return { gyms };
});
