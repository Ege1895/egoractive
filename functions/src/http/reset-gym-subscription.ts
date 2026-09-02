import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { gymDoc, subscriptionTransactionsCollection } from "../shared/firestore-paths";

/**
 * Bak CLAUDE.md → "Abonelik sıfırlama aracı (resetGymSubscription)" bölümü —
 * abonelik sistemiyle ilgili herhangi bir değişiklik yaparsan bu fonksiyonun
 * da güncellenmesi gerekip gerekmediğini KONTROL ET.
 *
 * ELLE ÇALIŞTIRILAN bir bakım aracı — hiçbir client, trigger, scheduler ya da
 * webhook bunu OTOMATİK çağırmaz (bilerek: yanlışlıkla tetiklenirse bir
 * salonun gerçek aboneliğini siler). Sadece Google Cloud Console'daki
 * fonksiyonun "Testing" sekmesinden (JSON body: {"gymId": "...", "secret":
 * "..."}) ya da bir HTTP isteğiyle admin tarafından tetiklenir.
 *
 * `gyms/{gymId}` üzerindeki GERÇEK abonelik alanlarını (mağaza satın alması/
 * doğrulaması sonucu yazılanlar) ve `subscriptionTransactions` içindeki bu
 * salona ait kaydı siler — böylece salon hiç abone olmamış gibi (appAccess'in
 * `SubscriptionStatus.none` olarak okuyacağı) bir duruma döner. `gymId ==`
 * sorgusuyla `subscriptionTransactions`'da bu salona ait kaydı bulur — bkz.
 * `docs/Abonelik_Iptal_Rehberi.docx`'teki manuel eşdeğeri.
 *
 * `subscriptionExempt` alanına KESİNLİKLE dokunmaz — o, admin'in ayrı,
 * bilinçli bir kararı (bkz. `subscription_panel.dart`'taki exempt görünümü),
 * bu aracın işi değil.
 *
 * Maliyet BİLEREK minimum tutuldu: 1 doküman okuma (salon var mı doğrulamak
 * için) + 1 sorgu okuma (bu salona ait transaction kaydı/kayıtları) + TEK bir
 * batch yazma (salon alanlarının silinmesi + bulunan transaction kayıtlarının
 * silinmesi aynı batch'te).
 */
const resetGymSubscriptionSecret = defineSecret("RESET_GYM_SUBSCRIPTION_SECRET");

export const resetGymSubscription = onRequest(
  { secrets: [resetGymSubscriptionSecret] },
  async (req, res) => {
    const secret =
      typeof req.query.secret === "string" ? req.query.secret : (req.body?.secret as string | undefined);
    if (secret !== resetGymSubscriptionSecret.value()) {
      res.status(403).json({ error: "Yetkisiz." });
      return;
    }

    const gymId = typeof req.query.gymId === "string" ? req.query.gymId : (req.body?.gymId as string | undefined);
    if (!gymId) {
      res.status(400).json({ error: "gymId gerekli." });
      return;
    }

    const db = getFirestore();
    const gymRef = db.doc(gymDoc(gymId));
    const gymSnap = await gymRef.get();
    if (!gymSnap.exists) {
      res.status(404).json({ error: `gyms/${gymId} bulunamadı.` });
      return;
    }

    const claimedTransactions = await db
      .collection(subscriptionTransactionsCollection())
      .where("gymId", "==", gymId)
      .get();

    const batch = db.batch();
    batch.update(gymRef, {
      subscriptionStatus: FieldValue.delete(),
      subscriptionProductId: FieldValue.delete(),
      subscriptionExpiresAt: FieldValue.delete(),
      subscriptionStartedAt: FieldValue.delete(),
      subscriptionCancelAtPeriodEnd: FieldValue.delete(),
      subscriptionLastVerificationData: FieldValue.delete(),
      subscriptionLastVerificationPlatform: FieldValue.delete(),
      subscriptionPlatform: FieldValue.delete(),
    });
    for (const doc of claimedTransactions.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();

    const removedTransactionIds = claimedTransactions.docs.map((d) => d.id);
    logger.info(
      `resetGymSubscription: gyms/${gymId} (${gymSnap.data()?.name ?? "?"}) sıfırlandı, ` +
        `${removedTransactionIds.length} transaction kaydı silindi.`,
      { gymId, removedTransactionIds },
    );

    res.status(200).json({
      ok: true,
      gymId,
      gymName: gymSnap.data()?.name ?? null,
      removedTransactionIds,
    });
  },
);
