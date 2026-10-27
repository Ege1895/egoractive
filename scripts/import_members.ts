/**
 * Bir salonun üye listesini Excel'den toplu aktarır (pilot salonlar için:
 * 100+ üyeyi uygulamadan tek tek girmek yerine). Şablon:
 * `Egoractive_Uye_Aktarim_Sablonu.xlsx` ("Üyeler" ve "Listeler" sayfaları).
 *
 * Uygulamanın kendi akışıyla birebir aynı veriyi yazar:
 * - `users/{auto}`: `member_registration_service.dart` `registerMember` ile
 *   aynı alanlar + paketi varsa `new_membership_controller.dart`'taki
 *   denormalize alanlar (`remainingSessions`, `packageEndDate`,
 *   `packageName`). Firebase Auth hesabı AÇILMAZ; uygulamada da açılmıyor,
 *   üyenin ilk girişinde oluşuyor. Rol claim'i ve `phoneIndex` mevcut
 *   tetikleyicilerle (`on-user-role-assigned`, `on-user-write-sync-phone-index`)
 *   kendiliğinden yazılır.
 * - `memberPackages/{auto}`: paket satış akışıyla aynı alanlar. Tek fark
 *   `purchasedAt`: aktarım anı yerine paketin başlangıç tarihi yazılır;
 *   aksi halde 130 eski paket bu ayın cirosuna eklenip raporları şişirirdi.
 *
 * Varsayılan DENEME modudur: hiçbir şey yazmaz, satır satır doğrular ve bir
 * rapor üretir. Yazmak için `--commit` + `--allow-production` +
 * `CONFIRM_PRODUCTION_BACKFILL=yes` birlikte gerekir.
 *
 * Her yazılan dokümana `importBatchId` eklenir; geri almak için
 * `--rollback=<batchId>` (aynı üretim bayraklarıyla) o partinin tüm
 * dokümanlarını siler.
 *
 * Örnek:
 *   npx tsx import_members.ts --file=uyeler.xlsx --gym=<gymId>
 *   CONFIRM_PRODUCTION_BACKFILL=yes npx tsx import_members.ts \
 *     --file=uyeler.xlsx --gym=<gymId> --commit --allow-production
 */
import ExcelJS from "exceljs";
import { writeFileSync } from "node:fs";
import { initializeApp, applicationDefault } from "firebase-admin/app";
import { getFirestore, Timestamp, type Firestore } from "firebase-admin/firestore";

const PRODUCTION_PROJECT = "egoractive-e92bd";

function arg(name: string): string | undefined {
  const hit = process.argv.find((a) => a.startsWith(`--${name}=`));
  return hit?.slice(name.length + 3);
}
const flag = (name: string) => process.argv.includes(`--${name}`);

// ---------- Sütunlar (şablonla aynı sıra) ----------
const COL = {
  firstName: 1,
  lastName: 2,
  phone: 3,
  trainer: 4,
  gender: 5,
  registeredAt: 6,
  canConfirm: 7,
  email: 8,
  packageName: 9,
  remaining: 10,
  pkgStart: 11,
  pkgEnd: 12,
  total: 13,
  paid: 14,
  makeup: 15,
  dueDate: 16,
} as const;
const FIRST_DATA_ROW = 3; // 1: başlık, 2: örnek satır

interface Trainer { id: string; name: string }
interface StudioPackage { id: string; name: string; sessionType: string; sessionCount: number }

interface ParsedRow {
  row: number;
  name: string;
  phone: string;
  trainer: Trainer;
  gender?: "erkek" | "kadin";
  registeredAt: Date;
  canConfirmAttendance: boolean;
  email?: string;
  pkg?: {
    def: StudioPackage;
    remaining: number;
    start: Date;
    end: Date;
    total: number;
    paid: number;
    makeup: number;
    dueDate?: Date;
  };
}

// ---------- Hücre okuma ----------
function text(cell: ExcelJS.Cell): string {
  const v = cell.value;
  if (v == null) return "";
  if (typeof v === "object" && "richText" in v) return v.richText.map((t) => t.text).join("").trim();
  if (typeof v === "object" && "text" in v) return String(v.text).trim(); // köprü
  if (typeof v === "object" && "result" in v) return String(v.result ?? "").trim(); // formül
  if (v instanceof Date) return v.toISOString();
  return String(v).trim();
}

const normalizeName = (s: string) => s.replace(/\s+/g, " ").trim().toLocaleLowerCase("tr");

/** E.164'e çevirir; Türkiye yerel biçimlerini (+90 eksik, başta 0) kabul eder. */
function toE164(raw: string): string | null {
  const digits = raw.replace(/[^\d+]/g, "");
  let p = digits;
  if (p.startsWith("00")) p = `+${p.slice(2)}`;
  else if (!p.startsWith("+")) {
    if (/^0\d{10}$/.test(p)) p = `+90${p.slice(1)}`;
    else if (/^5\d{9}$/.test(p)) p = `+90${p}`;
    else if (/^90\d{10}$/.test(p)) p = `+${p}`;
    else return null;
  }
  return /^\+\d{10,15}$/.test(p) ? p : null;
}

/** "GG.AA.YYYY" metni ya da Excel tarihi → yerel gece yarısı. */
function toDate(cell: ExcelJS.Cell): Date | null | undefined {
  const v = cell.value;
  if (v == null || text(cell) === "") return undefined;
  if (v instanceof Date) return new Date(v.getUTCFullYear(), v.getUTCMonth(), v.getUTCDate());
  const m = /^(\d{1,2})[./-](\d{1,2})[./-](\d{4})$/.exec(text(cell));
  if (!m) return null;
  const d = new Date(Number(m[3]), Number(m[2]) - 1, Number(m[1]));
  return d.getDate() === Number(m[1]) && d.getMonth() === Number(m[2]) - 1 ? d : null;
}

function toNumber(cell: ExcelJS.Cell): number | null | undefined {
  const t = text(cell);
  if (t === "") return undefined;
  const cleaned = t.replace(/\./g, "").replace(",", ".").replace(/[^\d.-]/g, "");
  const n = Number(cleaned);
  return Number.isFinite(n) ? n : null;
}

/** Uygulamanın `DateTime.toIso8601String()` biçimi (yerel, saat diliminsiz). */
function dartIso(d: Date): string {
  const pad = (n: number, w = 2) => String(n).padStart(w, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T00:00:00.000`;
}

// ---------- Ana akış ----------
async function main() {
  const file = arg("file");
  const gymId = arg("gym");
  const rollback = arg("rollback");
  const projectId = arg("project") ?? PRODUCTION_PROJECT;
  const commit = flag("commit");
  const reportPath = arg("report") ?? "import_members_report.txt";

  const writes = commit || rollback !== undefined;
  if (writes && projectId === PRODUCTION_PROJECT) {
    if (!flag("allow-production") || process.env.CONFIRM_PRODUCTION_BACKFILL !== "yes") {
      throw new Error("Üretime yazmak için --allow-production ve CONFIRM_PRODUCTION_BACKFILL=yes birlikte gerekli.");
    }
  }

  initializeApp({ credential: applicationDefault(), projectId });
  const db = getFirestore();

  if (rollback !== undefined) return doRollback(db, rollback);
  if (!file || !gymId) throw new Error("Kullanım: --file=<xlsx> --gym=<gymId> [--commit --allow-production]");

  const gym = await db.collection("gyms").doc(gymId).get();
  if (!gym.exists) throw new Error(`Salon bulunamadı: ${gymId}`);
  console.log(`Salon: ${gym.data()?.name ?? "?"} (${gymId})  |  mod: ${commit ? "YAZMA" : "DENEME"}`);

  const trainers = new Map<string, Trainer>();
  for (const d of (await db.collection("users").where("gymId", "==", gymId).where("role", "==", "trainer").get()).docs) {
    const name = String(d.data().name ?? "");
    if (name) trainers.set(normalizeName(name), { id: d.id, name });
  }
  const packages = new Map<string, StudioPackage>();
  for (const d of (await db.collection("gyms").doc(gymId).collection("packages").get()).docs) {
    const x = d.data();
    packages.set(normalizeName(String(x.name ?? "")), {
      id: d.id,
      name: String(x.name ?? ""),
      sessionType: x.sessionType === "group" ? "group" : "solo",
      sessionCount: Number(x.sessionCount ?? 0),
    });
  }
  console.log(`Salonda ${trainers.size} antrenör, ${packages.size} paket tanımlı.`);

  const wb = new ExcelJS.Workbook();
  try {
    await wb.xlsx.readFile(file);
  } catch (e) {
    throw new Error(
      `Excel dosyası okunamadı (${e instanceof Error ? e.message : e}). Hücre yorumları varsa silip ` +
        "dosyayı Excel'de 'Farklı Kaydet → Excel Çalışma Kitabı (.xlsx)' ile yeniden kaydedin.",
    );
  }
  const ws = wb.getWorksheet("Üyeler");
  if (!ws) throw new Error('"Üyeler" sayfası bulunamadı.');

  const errors: string[] = [];
  const warnings: string[] = [];
  const parsed: ParsedRow[] = [];
  const seenPhones = new Map<string, number>();
  const seenEmails = new Map<string, number>();

  for (let r = FIRST_DATA_ROW; r <= ws.rowCount; r++) {
    const row = ws.getRow(r);
    const c = (k: keyof typeof COL) => row.getCell(COL[k]);
    const firstName = text(c("firstName"));
    const lastName = text(c("lastName"));
    const phoneRaw = text(c("phone"));
    if (!firstName && !lastName && !phoneRaw) continue; // boş satır

    const rowErrors: string[] = [];
    const err = (m: string) => rowErrors.push(m);
    if (!firstName) err("Ad boş");
    if (!lastName) err("Soyad boş");

    const phone = toE164(phoneRaw);
    if (!phoneRaw) err("Telefon boş");
    else if (!phone) err(`Telefon biçimi geçersiz: "${phoneRaw}"`);
    else if (seenPhones.has(phone)) err(`Telefon dosyada tekrar ediyor (satır ${seenPhones.get(phone)})`);
    else seenPhones.set(phone, r);

    const trainerRaw = text(c("trainer"));
    const trainer = trainers.get(normalizeName(trainerRaw));
    if (!trainerRaw) err("Antrenör boş");
    else if (!trainer) err(`Antrenör salonda yok: "${trainerRaw}"`);

    const genderRaw = normalizeName(text(c("gender")));
    let gender: ParsedRow["gender"];
    if (genderRaw === "erkek") gender = "erkek";
    else if (genderRaw === "kadın" || genderRaw === "kadin") gender = "kadin";
    else if (genderRaw) err(`Cinsiyet geçersiz: "${text(c("gender"))}"`);

    const registered = toDate(c("registeredAt"));
    if (registered === null) err(`Kayıt tarihi geçersiz: "${text(c("registeredAt"))}"`);

    const confirmRaw = normalizeName(text(c("canConfirm")));
    if (confirmRaw && confirmRaw !== "evet" && confirmRaw !== "hayır" && confirmRaw !== "hayir") {
      err(`Katılım onayı yetkisi Evet/Hayır olmalı: "${text(c("canConfirm"))}"`);
    }

    const emailRaw = text(c("email")).toLowerCase();
    if (emailRaw) {
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailRaw)) err(`E-posta geçersiz: "${emailRaw}"`);
      else if (seenEmails.has(emailRaw)) err(`E-posta dosyada tekrar ediyor (satır ${seenEmails.get(emailRaw)})`);
      else seenEmails.set(emailRaw, r);
    }

    // Paket bloğu: herhangi bir paket hücresi doluysa paket var sayılır.
    const pkgCells = ["packageName", "remaining", "pkgStart", "pkgEnd", "total", "paid", "makeup", "dueDate"] as const;
    let pkg: ParsedRow["pkg"];
    if (pkgCells.some((k) => text(c(k)) !== "")) {
      const pkgName = text(c("packageName"));
      const def = packages.get(normalizeName(pkgName));
      const remaining = toNumber(c("remaining"));
      const start = toDate(c("pkgStart"));
      const end = toDate(c("pkgEnd"));
      const total = toNumber(c("total"));
      const paid = toNumber(c("paid"));
      const makeup = toNumber(c("makeup"));
      const dueDate = toDate(c("dueDate"));
      if (!pkgName) err("Paket bilgisi var ama Paket adı boş");
      else if (!def) err(`Paket salonda yok: "${pkgName}"`);
      if (remaining == null || !Number.isInteger(remaining) || remaining < 0) err("Kalan ders 0 veya pozitif tam sayı olmalı");
      if (!start) err("Paket başlangıç tarihi boş veya geçersiz");
      if (!end) err("Paket bitiş tarihi boş veya geçersiz");
      if (start && end && end < start) err("Paket bitişi başlangıçtan önce");
      if (total == null || total < 0) err("Toplam tutar boş veya geçersiz");
      if (paid == null || paid < 0) err("Ödenen tutar boş veya geçersiz");
      if (total != null && paid != null && paid > total) err("Ödenen tutar toplamdan büyük");
      if (makeup === null || (makeup !== undefined && (!Number.isInteger(makeup) || makeup < 0))) err("Telafi ders hakkı geçersiz");
      if (dueDate === null) err("Kalan ödeme tarihi geçersiz");
      if (def && remaining != null && remaining > def.sessionCount) {
        warnings.push(`Satır ${r}: kalan ders (${remaining}) paketin toplamından (${def.sessionCount}) büyük`);
      }
      if (end && end < new Date()) warnings.push(`Satır ${r}: paketin bitiş tarihi geçmişte (${text(c("pkgEnd"))})`);
      if (rowErrors.length === 0 && def && start && end && total != null && paid != null && remaining != null) {
        pkg = { def, remaining, start, end, total, paid, makeup: makeup ?? 0, dueDate: dueDate ?? undefined };
      }
    }

    if (rowErrors.length) {
      errors.push(`Satır ${r} (${firstName} ${lastName}): ${rowErrors.join("; ")}`);
      continue;
    }
    parsed.push({
      row: r,
      name: `${firstName} ${lastName}`.replace(/\s+/g, " ").trim(),
      phone: phone!,
      trainer: trainer!,
      gender,
      registeredAt: (registered as Date | undefined) ?? new Date(),
      canConfirmAttendance: confirmRaw === "evet",
      email: emailRaw || undefined,
      pkg,
    });
  }

  // Uygulamada başka hesapta kayıtlı telefon / e-posta
  const conflicts: string[] = [];
  const ready: ParsedRow[] = [];
  for (const p of parsed) {
    const phoneTaken =
      (await db.collection("phoneIndex").doc(p.phone).get()).exists ||
      !(await db.collection("users").where("phoneNumber", "==", p.phone).limit(1).get()).empty;
    const emailTaken =
      p.email !== undefined &&
      !(await db.collection("users").where("emailLower", "==", p.email).limit(1).get()).empty;
    if (phoneTaken || emailTaken) {
      conflicts.push(
        `Satır ${p.row} (${p.name}): ${[phoneTaken && `telefon ${p.phone}`, emailTaken && `e-posta ${p.email}`]
          .filter(Boolean)
          .join(" ve ")} başka bir hesapta kayıtlı`,
      );
    } else {
      ready.push(p);
    }
  }

  const withPkg = ready.filter((p) => p.pkg).length;
  const report = [
    `Salon: ${gym.data()?.name ?? "?"} (${gymId})`,
    `Mod: ${commit ? "YAZMA" : "DENEME (hiçbir şey yazılmadı)"}`,
    "",
    `Aktarılabilir üye: ${ready.length} (paketli: ${withPkg})`,
    `Hatalı satır: ${errors.length}`,
    `Çakışan (uygulamada zaten kayıtlı): ${conflicts.length}`,
    `Uyarı: ${warnings.length}`,
    "",
    ...(errors.length ? ["HATALAR (düzeltilmeden aktarılmaz):", ...errors, ""] : []),
    ...(conflicts.length ? ["ÇAKIŞMALAR (aktarılmaz):", ...conflicts, ""] : []),
    ...(warnings.length ? ["UYARILAR (aktarılır, kontrol edin):", ...warnings, ""] : []),
  ];

  if (!commit) {
    writeFileSync(reportPath, report.join("\n"));
    console.log(report.join("\n"));
    console.log(`\nRapor: ${reportPath}`);
    return;
  }

  const batchId = `members-${new Date().toISOString().replace(/[:.]/g, "-")}`;
  let written = 0;
  for (const p of ready) {
    const batch = db.batch();
    const userRef = db.collection("users").doc();
    batch.set(userRef, {
      name: p.name,
      nameLower: p.name.toLowerCase(),
      phoneNumber: p.phone,
      role: "member",
      gymId,
      trainerId: p.trainer.id,
      trainerName: p.trainer.name,
      createdAt: Timestamp.fromDate(p.registeredAt),
      ...(p.gender ? { gender: p.gender } : {}),
      canConfirmAttendance: p.canConfirmAttendance,
      ...(p.email ? { email: p.email, emailLower: p.email } : {}),
      ...(p.pkg
        ? { remainingSessions: p.pkg.remaining, packageEndDate: dartIso(p.pkg.end), packageName: p.pkg.def.name }
        : {}),
      importBatchId: batchId,
    });
    if (p.pkg) {
      const due = p.pkg.total - p.pkg.paid;
      const installments = [
        ...(p.pkg.paid > 0 ? [{ amountTl: p.pkg.paid, dueDate: dartIso(p.pkg.start), paid: true }] : []),
        ...(due > 0 ? [{ amountTl: due, dueDate: dartIso(p.pkg.dueDate ?? p.pkg.start), paid: false }] : []),
      ].map((i, index) => ({ index, ...i }));
      batch.set(db.collection("memberPackages").doc(), {
        memberId: userRef.id,
        gymId,
        packageId: p.pkg.def.id,
        packageName: p.pkg.def.name,
        sessionType: p.pkg.def.sessionType,
        totalSessions: p.pkg.def.sessionCount,
        remainingSessions: p.pkg.remaining,
        makeupSessions: p.pkg.makeup,
        startDate: dartIso(p.pkg.start),
        endDate: dartIso(p.pkg.end),
        totalAmount: p.pkg.total,
        paidAmount: p.pkg.paid,
        dueAmount: due,
        installments,
        purchasedAt: Timestamp.fromDate(p.pkg.start),
        importBatchId: batchId,
      });
    }
    await batch.commit();
    written++;
  }
  report.push(`YAZILDI: ${written} üye. Parti kimliği: ${batchId}`, `Geri almak için: --rollback=${batchId}`);
  writeFileSync(reportPath, report.join("\n"));
  console.log(report.join("\n"));
}

async function doRollback(db: Firestore, batchId: string) {
  let deleted = 0;
  for (const col of ["memberPackages", "users"]) {
    const snap = await db.collection(col).where("importBatchId", "==", batchId).get();
    for (const d of snap.docs) {
      await d.ref.delete();
      deleted++;
    }
    console.log(`${col}: ${snap.size} doküman silindi`);
  }
  console.log(`Toplam ${deleted} doküman silindi (parti ${batchId}).`);
}

main().catch((e) => {
  console.error(e instanceof Error ? e.message : e);
  process.exit(1);
});
