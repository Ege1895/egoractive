import {
  DocumentReference,
  FieldValue,
  Firestore,
  Timestamp,
  WriteBatch,
  getFirestore,
} from "firebase-admin/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { expensesCollection } from "../shared/firestore-paths";
import { withFailureAlerting } from "../shared/function-health";
import { resolveGymTimeZone } from "../shared/notification-locale";
import { clampDayToMonth, monthKey, pendingRecurringMonths } from "../shared/recurring-expenses";
import { localDateParts, zonedTimeToUtc } from "../shared/timezone-math";

/** Firestore batch üst sınırı 500; pay bırakarak parçalıyoruz. */
const batchChunkSize = 400;

/**
 * Kopyalar günün ORTASINA (yerel 12:00) yazılır. Client, gideri cihazın
 * yerel saatine göre bir aya yerleştiriyor (`expenses_service.watchMonth`);
 * gece yarısına yakın bir saat, salonun saat diliminden farklı bir cihazda
 * gideri komşu güne — ayın ilk/son gününde komşu AYA — kaydırabilirdi.
 * Öğlen, her iki yöne de 12 saatlik tolerans bırakıyor.
 */
const copyHourLocal = 12;

/**
 * "Her ay tekrar et" işaretli giderleri takip eden aylara kopyalar.
 *
 * Hata: toggle işaretlense de `recurring: true` sadece dokümanda duruyordu,
 * onu okuyup yeni ay kaydı üreten hiçbir taraf yoktu — gider yalnızca
 * girildiği ayda görünüyordu (kullanıcı raporu, 2026-09-02: Ağustos'a
 * "her ay tekrar et" ile girilen kira Eylül'de yok).
 *
 * Günlük çalışır, aylık değil: ayın 1'inde çalışan tek bir cron kaçırılan
 * (fonksiyon hatası, yeni deploy, uzun kapalı kalma) bir ayı bir sonraki aya
 * kadar telafi edemezdi. Günlük + idempotent kurgu kendi kendini onarır —
 * eksik aylar bir sonraki çalışmada tamamlanır.
 *
 * İdempotanlık iki katmanlı:
 * 1. Kopyanın doküman id'si deterministik (`{şablonId}_{2026-09}`), yani
 *    aynı ay iki kez yazılsa bile tek doküman olur — mükerrer gider imkânsız.
 * 2. Şablondaki `recurringMaterializedThrough` imleci, üretilmiş bir ayın
 *    kopyası SİLİNDİĞİNDE onu geri getirmemeyi sağlar.
 *
 * Kopyalar `recurring: false` ile yazılır: aksi halde kopya da şablon sayılıp
 * bir sonraki ay kendi kopyasını üretir ve zincir katlanarak büyürdü.
 */
export const recurringExpenseCheck = onSchedule(
  { schedule: "every 24 hours", timeZone: "Europe/Istanbul" },
  withFailureAlerting("recurringExpenseCheck", async () => {
    await materializeRecurringExpenses();
  }),
);

/**
 * Asıl iş — `onSchedule` sarmalayıcısından ayrı tutuldu ki emulator'a karşı
 * doğrudan çağrılıp uçtan uca doğrulanabilsin (tarih hangi aya düşüyor,
 * ikinci çalıştırma mükerrer kayıt üretiyor mu). Üretilen kopya sayısını
 * döner.
 */
export async function materializeRecurringExpenses(): Promise<number> {
  const db = getFirestore();
  const templates = await db.collection(expensesCollection()).where("recurring", "==", true).get();
  if (templates.empty) return 0;

  const timeZones = new Map<string, string>();
  const writer = new ChunkedWriter(db);
  let createdCount = 0;

  for (const templateDoc of templates.docs) {
    const data = templateDoc.data();
    const gymId = data.gymId as string | undefined;
    const templateDate = (data.date as Timestamp | undefined)?.toDate();
    if (!gymId || !templateDate) {
      logger.warn(`Tekrarlı gider ${templateDoc.id} eksik alanlı (gymId/date), atlandı.`);
      continue;
    }

    let timeZone = timeZones.get(gymId);
    if (!timeZone) {
      timeZone = await resolveGymTimeZone(gymId);
      timeZones.set(gymId, timeZone);
    }

    const templateParts = localDateParts(templateDate, timeZone);
    const currentMonth = localDateParts(new Date(), timeZone);
    const months = pendingRecurringMonths({
      templateMonth: templateParts,
      materializedThrough: data.recurringMaterializedThrough as string | undefined,
      currentMonth,
    });
    if (months.length === 0) continue;

    for (const month of months) {
      const day = clampDayToMonth(templateParts.day, month);
      const date = zonedTimeToUtc(month.year, month.month, day, copyHourLocal, 0, timeZone);
      const copyRef = db
        .collection(expensesCollection())
        .doc(`${templateDoc.id}_${monthKey(month)}`);
      writer.set(copyRef, {
        gymId,
        category: data.category ?? "",
        title: data.title ?? "",
        date: Timestamp.fromDate(date),
        amountTl: data.amountTl ?? 0,
        recurring: false,
        recurringSourceId: templateDoc.id,
        createdAt: FieldValue.serverTimestamp(),
      });
      createdCount++;
    }

    writer.update(templateDoc.ref, {
      recurringMaterializedThrough: monthKey(months[months.length - 1]),
    });
  }

  await writer.flush();
  if (createdCount > 0) {
    logger.info(
      `${createdCount} tekrarlı gider kopyası üretildi (${templates.size} şablon tarandı).`,
    );
  }
  return createdCount;
}

/**
 * Firestore batch'i 500 işlemle sınırlı; tek bir salonun geçmişi
 * doldurulurken bu sınır aşılabildiği için yazmalar parçalar hâlinde
 * commit ediliyor.
 */
class ChunkedWriter {
  constructor(private readonly db: Firestore) {}

  private readonly operations: ((batch: WriteBatch) => void)[] = [];

  set(ref: DocumentReference, data: Record<string, unknown>): void {
    this.operations.push((batch) => batch.set(ref, data));
  }

  update(ref: DocumentReference, data: Record<string, unknown>): void {
    this.operations.push((batch) => batch.update(ref, data));
  }

  /**
   * Parçalar EKLENME SIRASINDA, sırayla commit edilir: bir şablonun imleç
   * güncellemesi hep kendi kopyalarından sonra yazılır. Ortadaki bir parça
   * hata verirse imleç ilerlememiş olur, bir sonraki çalışma aynı
   * deterministik id'lerle aynı kopyaları yazar — mükerrer kayıt oluşmaz.
   */
  async flush(): Promise<void> {
    for (let index = 0; index < this.operations.length; index += batchChunkSize) {
      const batch = this.db.batch();
      for (const operation of this.operations.slice(index, index + batchChunkSize)) {
        operation(batch);
      }
      await batch.commit();
    }
    this.operations.length = 0;
  }
}
