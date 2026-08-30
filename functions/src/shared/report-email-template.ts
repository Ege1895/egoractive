import { OccupancyStats, PackageSaleCount } from "./report-extras-stats";
import { GymWeeklyStats, SessionTypeBreakdown, TrainerPerformance } from "./weekly-report-stats";

export type ReportEmailLocale = "tr" | "en";
export type ReportEmailKind = "weekly" | "monthly";

export interface ReportEmailData {
  gymName: string;
  kind: ReportEmailKind;
  periodLabel: string;
  locale: ReportEmailLocale;
  sessions: GymWeeklyStats;
  individualSessions: SessionTypeBreakdown;
  duetSessions: SessionTypeBreakdown;
  trainers: TrainerPerformance[];
  packages: PackageSaleCount[];
  groupSessions: OccupancyStats;
  events: OccupancyStats;
  deepLinkUrl: string;
}

const COLOR = {
  ink: "#12181F",
  muted: "#5F6B7A",
  faint: "#93A0B0",
  line: "#E7ECF3",
  lineSoft: "#F1F4F8",
  brand: "#05A6FA",
  brandDark: "#0576B3",
  good: "#17916A",
  goodWash: "#E5F6EE",
  bad: "#D14B3F",
  badWash: "#FDEBE9",
  amber: "#C97A1B",
  other: "#C7CFDA",
  fill: "#DCE6F2",
};

const COPY: Record<ReportEmailLocale, {
  brandKicker: string;
  kindLabel: (kind: ReportEmailKind) => string;
  heroPositive: (net: string) => string;
  heroNegative: (net: string) => string;
  heroSubPositive: string;
  heroSubNegative: string;
  sessionsTitle: string;
  individualSessionsLabel: string;
  duetSessionsLabel: string;
  totalSessions: string;
  completed: string;
  cancelled: string;
  other: string;
  groupEventsTitle: string;
  groupSessionsLabel: string;
  eventsLabel: string;
  sessionsUnit: string;
  eventsUnit: string;
  attendanceLine: (attendance: string, capacity: string, pct: number) => string;
  trainersTitle: string;
  trainersEmpty: string;
  completedShort: string;
  cancelledShort: string;
  totalShort: string;
  soloPillLabel: string;
  duetPillLabel: string;
  groupPillLabel: string;
  completionRateLine: (completedPct: number, cancelledPct: number) => string;
  packagesTitle: string;
  packagesEmpty: string;
  salesUnit: string;
  financeTitle: string;
  revenue: string;
  expenses: string;
  netProfit: string;
  netLoss: string;
  ctaButton: string;
  footer: string;
}> = {
  tr: {
    brandKicker: "EGORACTIVE RAPOR",
    kindLabel: (kind) => (kind === "weekly" ? "Haftalık Özet" : "Aylık Özet"),
    heroPositive: (net) => `Bu dönem net <b>${net}</b> kâr ettin 🎉`,
    heroNegative: (net) => `Bu dönem net <b>${net}</b> gider fazlası oluştu ⚠️`,
    heroSubPositive: "Detaylar aşağıda — antrenör performansı ve en çok satan paketleri incelemeyi unutma.",
    heroSubNegative: "Aşağıdaki gider ve paket satış dökümü, nereden tasarruf edebileceğini görmene yardımcı olabilir.",
    sessionsTitle: "📊&nbsp; Ders Özeti",
    individualSessionsLabel: "🧍&nbsp; Birebir Seans",
    duetSessionsLabel: "👯&nbsp; Düet Dersi",
    totalSessions: "Toplam",
    completed: "Tamamlanan",
    cancelled: "İptal Edilen",
    other: "Diğer",
    groupEventsTitle: "🗓️&nbsp; Grup Dersleri &amp; Etkinlikler",
    groupSessionsLabel: "🧑‍🤝‍🧑&nbsp; Grup Dersleri",
    eventsLabel: "🎉&nbsp; Etkinlikler",
    sessionsUnit: "ders",
    eventsUnit: "etkinlik",
    attendanceLine: (attendance, capacity, p) => `${attendance} / ${capacity} kişi katıldı &nbsp;·&nbsp; <b>%${p} doluluk</b>`,
    trainersTitle: "🏋️&nbsp; Antrenör Performansı",
    trainersEmpty: "Bu dönemde antrenör verisi yok.",
    completedShort: "tamamlandı",
    cancelledShort: "iptal",
    totalShort: "toplam",
    soloPillLabel: "🧍&nbsp;Seans",
    duetPillLabel: "👯&nbsp;Düet",
    groupPillLabel: "👥&nbsp;Grup",
    completionRateLine: (c, x) => `%${c} tamamlanma · %${x} iptal oranı`,
    packagesTitle: "📦&nbsp; Satın Alınan Paketler",
    packagesEmpty: "Bu dönemde paket satışı olmadı.",
    salesUnit: "satış",
    financeTitle: "💼&nbsp; Mali Özet",
    revenue: "💰&nbsp; Ciro",
    expenses: "💸&nbsp; Gider",
    netProfit: "🧮&nbsp; Net Kâr",
    netLoss: "🧮&nbsp; Net Zarar",
    ctaButton: "Uygulamada Gör →",
    footer: "Bu rapor Egoractive tarafından otomatik oluşturuldu.",
  },
  en: {
    brandKicker: "EGORACTIVE REPORT",
    kindLabel: (kind) => (kind === "weekly" ? "Weekly Summary" : "Monthly Summary"),
    heroPositive: (net) => `You made <b>${net}</b> net profit this period 🎉`,
    heroNegative: (net) => `This period ended with a <b>${net}</b> net loss ⚠️`,
    heroSubPositive: "See the details below — check trainer performance and your best-selling packages.",
    heroSubNegative: "The expense and package breakdown below can help you spot where to save.",
    sessionsTitle: "📊&nbsp; Session Overview",
    individualSessionsLabel: "🧍&nbsp; Individual Sessions",
    duetSessionsLabel: "👯&nbsp; Duet Classes",
    totalSessions: "Total",
    completed: "Completed",
    cancelled: "Cancelled",
    other: "Other",
    groupEventsTitle: "🗓️&nbsp; Group Classes &amp; Events",
    groupSessionsLabel: "🧑‍🤝‍🧑&nbsp; Group Classes",
    eventsLabel: "🎉&nbsp; Events",
    sessionsUnit: "classes",
    eventsUnit: "events",
    attendanceLine: (attendance, capacity, p) => `${attendance} / ${capacity} attended &nbsp;·&nbsp; <b>%${p} full</b>`,
    trainersTitle: "🏋️&nbsp; Trainer Performance",
    trainersEmpty: "No trainer data for this period.",
    completedShort: "completed",
    cancelledShort: "cancelled",
    totalShort: "total",
    soloPillLabel: "🧍&nbsp;Solo",
    duetPillLabel: "👯&nbsp;Duet",
    groupPillLabel: "👥&nbsp;Group",
    completionRateLine: (c, x) => `%${c} completion · %${x} cancellation rate`,
    packagesTitle: "📦&nbsp; Packages Sold",
    packagesEmpty: "No packages were sold this period.",
    salesUnit: "sold",
    financeTitle: "💼&nbsp; Financial Summary",
    revenue: "💰&nbsp; Revenue",
    expenses: "💸&nbsp; Expenses",
    netProfit: "🧮&nbsp; Net Profit",
    netLoss: "🧮&nbsp; Net Loss",
    ctaButton: "Open in App →",
    footer: "This report was generated automatically by Egoractive.",
  },
};

function fmtTl(amount: number, locale: ReportEmailLocale): string {
  return "₺" + Math.round(amount).toLocaleString(locale === "tr" ? "tr-TR" : "en-US");
}

function fmtInt(n: number, locale: ReportEmailLocale): string {
  return n.toLocaleString(locale === "tr" ? "tr-TR" : "en-US");
}

function pct(part: number, total: number): number {
  return total === 0 ? 0 : Math.round((part / total) * 1000) / 10;
}

interface Segment {
  value: number;
  color: string;
}

/**
 * E-posta istemcileri (Gmail/Outlook/Apple Mail) modern CSS'in çoğunu
 * desteklemediğinden grafikler SVG/Canvas yerine hücre genişliğine göre
 * renklenen tablolarla ("email-safe bar chart" tekniği) çiziliyor.
 *
 * Gmail'de (özellikle mobil uygulamada) `<td width="X%">` yüzdesi, SARAN
 * `<table>`'a açık bir genişlik verilmediğinde güvenilir çalışmıyor —
 * Gmail tabloyu içeriğe göre daraltıp bar'ı ince bir çizgiye indirgiyordu
 * (gerçek gönderimde görüldü). Bu yüzden hem HTML `width` niteliği hem
 * eşdeğer `style="width"` birlikte, saran tabloda da HER ZAMAN yazılıyor.
 */
function segBar(segments: Segment[], height = 14): string {
  const total = segments.reduce((s, x) => s + x.value, 0) || 1;
  const cells = segments
    .map((seg, i) => {
      const w = Math.round((seg.value / total) * 10000) / 100;
      if (w <= 0) return "";
      let radius = "";
      if (i === 0) radius += `border-top-left-radius:${height / 2}px;border-bottom-left-radius:${height / 2}px;`;
      if (i === segments.length - 1) radius += `border-top-right-radius:${height / 2}px;border-bottom-right-radius:${height / 2}px;`;
      return `<td width="${w}%" bgcolor="${seg.color}" style="width:${w}%;height:${height}px;font-size:1px;line-height:${height}px;${radius}">&nbsp;</td>`;
    })
    .join("");
  return `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:separate;border-spacing:0;"><tr>${cells}</tr></table>`;
}

function legend(items: { color: string; pct: number; label: string }[]): string {
  const cells = items
    .map(
      (it, i) =>
        `<td style="padding-right:${i < items.length - 1 ? 18 : 0}px;white-space:nowrap;font-size:12.5px;color:${COLOR.muted};">` +
        `<span style="display:inline-block;width:9px;height:9px;border-radius:50%;background:${it.color};margin-right:6px;vertical-align:middle;"></span>` +
        `<b style="color:${COLOR.ink};">%${it.pct}</b>&nbsp;${it.label}</td>`,
    )
    .join("");
  return `<table role="presentation" cellpadding="0" cellspacing="0" style="margin-top:10px;"><tr>${cells}</tr></table>`;
}

function card(title: string, inner: string): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:16px;">` +
    `<tr><td style="background:#ffffff;border:1px solid ${COLOR.line};border-radius:16px;padding:20px 22px;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:15px;color:${COLOR.ink};margin-bottom:14px;">${title}</div>` +
    inner +
    `</td></tr></table>`
  );
}

function statBox(label: string, value: string, color: string): string {
  return (
    `<td width="33.33%" style="padding:4px;">` +
    `<div style="background:${COLOR.lineSoft};border-radius:12px;padding:14px 10px;text-align:center;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:22px;color:${color};">${value}</div>` +
    `<div style="font-size:11.5px;color:${COLOR.muted};margin-top:2px;">${label}</div>` +
    `</div></td>`
  );
}

function sessionTypeBlock(title: string, breakdown: SessionTypeBreakdown, locale: ReportEmailLocale): string {
  const t = COPY[locale];
  const completedPct = pct(breakdown.completed, breakdown.total);
  const cancelledPct = pct(breakdown.cancelled, breakdown.total);
  const otherCount = Math.max(breakdown.total - breakdown.completed - breakdown.cancelled, 0);
  const otherPct = Math.max(0, Math.round((100 - completedPct - cancelledPct) * 10) / 10);
  return (
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:12.5px;color:${COLOR.ink};margin-bottom:10px;">${title}</div>` +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:14px;"><tr>` +
    statBox(t.totalSessions, fmtInt(breakdown.total, locale), COLOR.ink) +
    statBox(t.completed, fmtInt(breakdown.completed, locale), COLOR.good) +
    statBox(t.cancelled, fmtInt(breakdown.cancelled, locale), COLOR.bad) +
    `</tr></table>` +
    segBar([
      { value: breakdown.completed, color: COLOR.good },
      { value: breakdown.cancelled, color: COLOR.bad },
      { value: otherCount, color: COLOR.other },
    ]) +
    legend([
      { color: COLOR.good, pct: completedPct, label: t.completed },
      { color: COLOR.bad, pct: cancelledPct, label: t.cancelled },
      { color: COLOR.other, pct: otherPct, label: t.other },
    ])
  );
}

/** F7-x — "Ders Özeti" bölümü artık tek bir genel toplam yerine Birebir
 * Seans ve Düet Dersi'ni ayrı bloklar olarak, her biri kendi tamamlanan/
 * iptal kırılımıyla gösteriyor. Grup dersleri burada değil, aşağıdaki
 * [groupEventsSection]'da kalıyor (kendi doluluk/kontenjan verisiyle bir
 * arada anlamlı).
 */
function sessionsSection(
  individualSessions: SessionTypeBreakdown,
  duetSessions: SessionTypeBreakdown,
  locale: ReportEmailLocale,
): string {
  const t = COPY[locale];
  const inner =
    sessionTypeBlock(t.individualSessionsLabel, individualSessions, locale) +
    `<div style="height:6px;"></div>` +
    sessionTypeBlock(t.duetSessionsLabel, duetSessions, locale);
  return card(t.sessionsTitle, inner);
}

function occupancyBlock(
  label: string,
  count: number,
  unit: string,
  stats: OccupancyStats,
  locale: ReportEmailLocale,
  // F7-x — Grup Dersleri kartına eklenen tamamlanan/iptal satırı.
  // `groupSessions` koleksiyonunda bir iptal durumu tutulmadığından
  // (dersi iptal etme akışı yok) "tamamlanan" dönemde gerçekleşen tüm
  // dersler, "iptal" her zaman 0 — bkz. `weekly-gym-report.ts` çağrı
  // noktası. Etkinlikler kartında bu satır hiç gösterilmiyor.
  completedCancelled?: { completed: number; cancelled: number },
): string {
  const t = COPY[locale];
  const occPct = pct(stats.attendance, stats.capacity);
  return (
    `<td width="50%" style="padding:4px;vertical-align:top;">` +
    `<div style="background:${COLOR.lineSoft};border-radius:12px;padding:16px;">` +
    `<div style="font-size:12.5px;color:${COLOR.muted};margin-bottom:2px;">${label}</div>` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:20px;color:${COLOR.ink};margin-bottom:10px;">${fmtInt(count, locale)} ${unit}</div>` +
    segBar([
      { value: stats.attendance, color: COLOR.brand },
      { value: Math.max(stats.capacity - stats.attendance, 0), color: COLOR.fill },
    ], 10) +
    `<div style="font-size:11.5px;color:${COLOR.muted};margin-top:8px;">${t.attendanceLine(fmtInt(stats.attendance, locale), fmtInt(stats.capacity, locale), occPct)}</div>` +
    (completedCancelled
      ? `<div style="font-size:11px;color:${COLOR.muted};margin-top:8px;padding-top:8px;border-top:1px dashed ${COLOR.line};">` +
        `<b style="color:${COLOR.good};">${fmtInt(completedCancelled.completed, locale)}</b> ${t.completedShort} &nbsp;·&nbsp; ` +
        `<b style="color:${COLOR.bad};">${fmtInt(completedCancelled.cancelled, locale)}</b> ${t.cancelledShort}</div>`
      : "") +
    `</div></td>`
  );
}

function groupEventsSection(groupSessions: OccupancyStats, events: OccupancyStats, locale: ReportEmailLocale): string {
  const t = COPY[locale];
  const inner =
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;"><tr>` +
    occupancyBlock(t.groupSessionsLabel, groupSessions.count, t.sessionsUnit, groupSessions, locale, {
      completed: groupSessions.count,
      cancelled: 0,
    }) +
    occupancyBlock(t.eventsLabel, events.count, t.eventsUnit, events, locale) +
    `</tr></table>`;
  return card(t.groupEventsTitle, inner);
}

function pill(label: string, value: number, locale: ReportEmailLocale): string {
  return (
    `<td style="padding-right:8px;">` +
    `<span style="display:inline-block;font-size:11px;color:${COLOR.brandDark};background:${COLOR.lineSoft};border-radius:20px;padding:3px 10px;white-space:nowrap;">` +
    `${label} <b>${fmtInt(value, locale)}</b></span></td>`
  );
}

function trainerRow(trainer: TrainerPerformance, rankIcon: string | undefined, locale: ReportEmailLocale): string {
  const t = COPY[locale];
  const completedPct = pct(trainer.completedSessions, trainer.totalSessions);
  const cancelledPct = pct(trainer.cancelledSessions, trainer.totalSessions);
  const otherCount = Math.max(trainer.totalSessions - trainer.completedSessions - trainer.cancelledSessions, 0);
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:12px;">` +
    `<tr>` +
    `<td style="font-size:13.5px;color:${COLOR.ink};font-weight:600;padding-bottom:6px;">${rankIcon ? rankIcon + " " : ""}${trainer.name}</td>` +
    `<td align="right" style="text-align:right;font-size:12px;color:${COLOR.muted};padding-bottom:6px;white-space:nowrap;">` +
    `<b style="color:${COLOR.good};">${trainer.completedSessions}</b> ${t.completedShort} &nbsp;·&nbsp; ` +
    `<b style="color:${COLOR.bad};">${trainer.cancelledSessions}</b> ${t.cancelledShort} &nbsp;·&nbsp; ${trainer.totalSessions} ${t.totalShort}</td>` +
    `</tr>` +
    `<tr><td colspan="2">` +
    segBar([
      { value: trainer.completedSessions, color: COLOR.good },
      { value: trainer.cancelledSessions, color: COLOR.bad },
      { value: otherCount, color: COLOR.other },
    ], 8) +
    `</td></tr>` +
    `<tr><td colspan="2" style="font-size:11px;color:${COLOR.faint};padding-top:4px;padding-bottom:8px;">${t.completionRateLine(completedPct, cancelledPct)}</td></tr>` +
    `<tr><td colspan="2"><table role="presentation" cellpadding="0" cellspacing="0"><tr>` +
    pill(t.soloPillLabel, trainer.soloSessions, locale) +
    pill(t.duetPillLabel, trainer.duetSessions, locale) +
    pill(t.groupPillLabel, trainer.groupSessions, locale) +
    `</tr></table></td></tr>` +
    `</table>`
  );
}

function trainersSection(trainers: TrainerPerformance[], locale: ReportEmailLocale): string {
  const t = COPY[locale];
  if (trainers.length === 0) {
    return card(t.trainersTitle, `<div style="font-size:13px;color:${COLOR.muted};">${t.trainersEmpty}</div>`);
  }
  const medals = ["🥇", "🥈", "🥉"];
  const sorted = [...trainers].sort((a, b) => b.completedSessions - a.completedSessions);
  const rows = sorted.map((tr, i) => trainerRow(tr, medals[i], locale)).join("");
  return card(t.trainersTitle, rows);
}

function packagesSection(packages: PackageSaleCount[], locale: ReportEmailLocale): string {
  const t = COPY[locale];
  if (packages.length === 0) {
    return card(t.packagesTitle, `<div style="font-size:13px;color:${COLOR.muted};">${t.packagesEmpty}</div>`);
  }
  const medals = ["🥇", "🥈", "🥉"];
  const sorted = [...packages].sort((a, b) => b.count - a.count);
  const max = sorted[0]?.count || 1;
  const rows = sorted
    .map((p, i) => {
      // En düşük satışlı paket bile gözle görülür bir bar bıraksın diye
      // en az %6 genişlik garantisi — segBar oranı verilen iki segment
      // değerinden hesapladığı için gerçek sayı yerine bu payı temsil eden
      // kesirler veriliyor (1 = tam genişlik).
      const share = Math.max(p.count / max, 0.06);
      return (
        `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:10px;">` +
        `<tr>` +
        `<td style="font-size:13px;color:${COLOR.ink};font-weight:600;padding-bottom:5px;">${medals[i] ? medals[i] + " " : `${i + 1}. `}${p.packageName}</td>` +
        `<td align="right" style="text-align:right;font-size:12.5px;color:${COLOR.muted};padding-bottom:5px;white-space:nowrap;"><b style="color:${COLOR.ink};">${fmtInt(p.count, locale)}</b>&nbsp;${t.salesUnit}</td>` +
        `</tr>` +
        `<tr><td colspan="2">` +
        segBar([
          { value: share, color: COLOR.brand },
          { value: 1 - share, color: COLOR.lineSoft },
        ], 10) +
        `</td></tr>` +
        `</table>`
      );
    })
    .join("");
  return card(t.packagesTitle, rows);
}

function financeSection(revenueTl: number, expensesTl: number, locale: ReportEmailLocale): string {
  const t = COPY[locale];
  const net = revenueTl - expensesTl;
  const netColor = net >= 0 ? COLOR.good : COLOR.bad;
  const maxBar = Math.max(revenueTl, expensesTl) || 1;
  const revShare = Math.max(revenueTl / maxBar, 0.04);
  const expShare = Math.max(expensesTl / maxBar, 0.04);
  const inner =
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;">` +
    `<tr><td style="padding:8px 0;font-size:13px;color:${COLOR.muted};">${t.revenue}</td>` +
    `<td align="right" style="text-align:right;padding:8px 0;font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:16px;color:${COLOR.good};">${fmtTl(revenueTl, locale)}</td></tr>` +
    `<tr><td colspan="2">${segBar([
      { value: revShare, color: COLOR.good },
      { value: 1 - revShare, color: COLOR.lineSoft },
    ], 9)}</td></tr>` +
    `<tr><td colspan="2" style="height:12px;"></td></tr>` +
    `<tr><td style="padding:8px 0;font-size:13px;color:${COLOR.muted};">${t.expenses}</td>` +
    `<td align="right" style="text-align:right;padding:8px 0;font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:16px;color:${COLOR.amber};">${fmtTl(expensesTl, locale)}</td></tr>` +
    `<tr><td colspan="2">${segBar([
      { value: expShare, color: COLOR.amber },
      { value: 1 - expShare, color: COLOR.lineSoft },
    ], 9)}</td></tr>` +
    `</table>` +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-top:16px;">` +
    `<tr><td style="background:${net >= 0 ? COLOR.goodWash : COLOR.badWash};border-radius:12px;padding:14px 16px;">` +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;"><tr>` +
    `<td style="font-size:13px;color:${COLOR.ink};font-weight:600;">${net >= 0 ? t.netProfit : t.netLoss}</td>` +
    `<td align="right" style="text-align:right;font-family:Arial,Helvetica,sans-serif;font-weight:800;font-size:20px;color:${netColor};">${net >= 0 ? "+" : "−"}${fmtTl(Math.abs(net), locale)}</td>` +
    `</tr></table></td></tr></table>`;
  return card(t.financeTitle, inner);
}

function heroBanner(net: number, locale: ReportEmailLocale): string {
  const t = COPY[locale];
  const positive = net >= 0;
  const netStr = fmtTl(Math.abs(net), locale);
  const headline = positive ? t.heroPositive(netStr) : t.heroNegative(netStr);
  const sub = positive ? t.heroSubPositive : t.heroSubNegative;
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:18px;">` +
    `<tr><td style="background:${positive ? COLOR.goodWash : COLOR.badWash};border-radius:16px;padding:18px 22px;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:18px;color:${COLOR.ink};">${headline}</div>` +
    `<div style="font-size:12.5px;color:${COLOR.muted};margin-top:6px;">${sub}</div>` +
    `</td></tr></table>`
  );
}

/**
 * F5-11 — haftalık ve aylık salon rapor maili için TEK, zengin template.
 * Grafikler tablo hücre genişliği tekniğiyle ("email-safe bar chart")
 * çizilir; e-posta istemcileri modern CSS'in çoğunu desteklemediğinden
 * SVG/Canvas kullanılmaz. Dil, `data.locale`'e göre seçilir — çağıran
 * kod bunu salonun `timeZone`'undan (`resolveNotificationLocale`) belirler.
 */
export function buildReportEmailHtml(data: ReportEmailData): string {
  const t = COPY[data.locale];
  const revenueTl = data.sessions.revenueTl;
  const expensesTl = data.sessions.expensesTl;
  const net = revenueTl - expensesTl;

  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;">` +
    `<tr><td style="background:${COLOR.brand};padding:26px 28px;border-radius:18px 18px 0 0;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.75);">${t.brandKicker}</div>` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:800;font-size:24px;color:#ffffff;margin-top:6px;">${data.gymName}</div>` +
    `<div style="font-size:13px;color:rgba(255,255,255,.85);margin-top:3px;">${t.kindLabel(data.kind)} &nbsp;·&nbsp; ${data.periodLabel}</div>` +
    `</td></tr></table>` +
    `<div style="padding:22px 22px 4px;background:#ffffff;border-radius:0 0 18px 18px;">` +
    heroBanner(net, data.locale) +
    sessionsSection(data.individualSessions, data.duetSessions, data.locale) +
    groupEventsSection(data.groupSessions, data.events, data.locale) +
    trainersSection(data.trainers, data.locale) +
    packagesSection(data.packages, data.locale) +
    financeSection(revenueTl, expensesTl, data.locale) +
    `<div style="text-align:center;padding:6px 0 18px;">` +
    `<a href="${data.deepLinkUrl}" style="display:inline-block;border:1.5px solid ${COLOR.brand};color:${COLOR.brandDark};font-weight:600;font-size:13px;border-radius:10px;padding:10px 20px;text-decoration:none;font-family:Arial,Helvetica,sans-serif;">${t.ctaButton}</a>` +
    `</div>` +
    `<div style="text-align:center;font-size:11px;color:${COLOR.faint};padding-bottom:8px;font-family:Arial,Helvetica,sans-serif;">${t.footer}</div>` +
    `</div>`
  );
}
