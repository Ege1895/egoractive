import { getFirestore } from "firebase-admin/firestore";

import { subscriptionTransactionDoc } from "./firestore-paths";

/**
 * Store webhook bildirimleri (Apple ASN V2, Google RTDN) sadece bir
 * transaction/purchase-token taşır, gymId taşımaz — bu, `applySubscriptionUpdate`'in
 * her başarılı doğrulamada yazdığı `subscriptionTransactions` lookup index'inden
 * geriye dönük bulunur. Salon hiç bulunamazsa (ör. bu transaction hiç bizim
 * `verifySubscriptionPurchase`'ımızdan geçmemişse) `null` döner — çağıran taraf
 * bildirimi loglayıp yok sayar.
 */
export async function resolveGymIdForTransaction(transactionKey: string): Promise<string | null> {
  const snap = await getFirestore().doc(subscriptionTransactionDoc(transactionKey)).get();
  const gymId = snap.data()?.gymId;
  return typeof gymId === "string" ? gymId : null;
}
