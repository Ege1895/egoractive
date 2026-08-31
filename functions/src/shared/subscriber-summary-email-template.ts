/**
 * `weeklySubscriberSummary` — Egora Games'in kendi haftalık abone özeti
 * maili. `report-email-template.ts`'teki (salon sahiplerine giden haftalık/
 * aylık rapor) AYNI görsel dili (marka rengi, kart/segBar/pill yapıları)
 * kullanır — bilerek AYRI bir dosya: buradaki helper'lar (card/statBox/
 * segBar) o dosyadakiyle neredeyse birebir aynı ama private olduğu için
 * import edilemiyor; iki maili birbirine bağımlı kılıp kırılganlaştırmak
 * yerine küçük bir kopya tercih edildi. Bu mail sadece Egora Games'in
 * kendi adresine gittiği için (F6-1) TR-only, locale parametresi yok.
 */

export interface SubscriberSummaryRow {
  name: string;
  status: string;
  trialEndsAt: Date | null;
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
  amber: "#C97A1B",
  amberWash: "#FBF1E1",
  bad: "#D14B3F",
  other: "#C7CFDA",
};

/** Bilinen durumlar için etiket/renk; bilinmeyen bir `subscriptionStatus`
 * değeri (ör. ileride eklenecek yeni bir durum) nötr griyle gösterilir. */
const STATUS_META: Record<string, { label: string; color: string; wash: string }> = {
  trial: { label: "Deneme", color: COLOR.brand, wash: "#E4F4FF" },
  active: { label: "Aktif", color: COLOR.good, wash: COLOR.goodWash },
  none: { label: "Abone Değil", color: COLOR.faint, wash: COLOR.lineSoft },
  expired: { label: "Süresi Doldu", color: COLOR.bad, wash: "#FDEBE9" },
  cancelled: { label: "İptal Edildi", color: COLOR.amber, wash: COLOR.amberWash },
};

function statusMeta(status: string): { label: string; color: string; wash: string } {
  return STATUS_META[status] ?? { label: status, color: COLOR.other, wash: COLOR.lineSoft };
}

function fmtInt(n: number): string {
  return n.toLocaleString("tr-TR");
}

interface Segment {
  value: number;
  color: string;
}

/** Bkz. `report-email-template.ts` — e-posta istemcileri modern CSS'in
 * çoğunu desteklemediği için grafik, hücre genişliğine göre renklenen bir
 * tabloyla ("email-safe bar chart") çizilir. */
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

function card(title: string, inner: string): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:16px;">` +
    `<tr><td style="background:#ffffff;border:1px solid ${COLOR.line};border-radius:16px;padding:20px 22px;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:15px;color:${COLOR.ink};margin-bottom:14px;">${title}</div>` +
    inner +
    `</td></tr></table>`
  );
}

function statusStatBox(status: string, count: number, widthPct: number): string {
  const meta = statusMeta(status);
  return (
    `<td width="${widthPct}%" style="padding:4px;">` +
    `<div style="background:${meta.wash};border-radius:12px;padding:14px 10px;text-align:center;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:24px;color:${meta.color};">${fmtInt(count)}</div>` +
    `<div style="font-size:11.5px;color:${COLOR.muted};margin-top:2px;font-weight:600;">${meta.label}</div>` +
    `</div></td>`
  );
}

function heroBanner(totalGyms: number, weekLabel: string): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:18px;">` +
    `<tr><td style="background:${COLOR.brand};background-image:linear-gradient(135deg,${COLOR.brand},${COLOR.brandDark});border-radius:16px;padding:22px 24px;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.75);">${weekLabel}</div>` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:800;font-size:32px;color:#ffffff;margin-top:6px;">${fmtInt(totalGyms)} salon</div>` +
    `<div style="font-size:12.5px;color:rgba(255,255,255,.85);margin-top:2px;">Egoractive'e kayıtlı toplam salon sayısı</div>` +
    `</td></tr></table>`
  );
}

function statusSection(rows: SubscriberSummaryRow[]): string {
  const counts = new Map<string, number>();
  for (const row of rows) counts.set(row.status, (counts.get(row.status) ?? 0) + 1);
  const sorted = [...counts.entries()].sort((a, b) => b[1] - a[1]);

  const boxWidth = Math.max(Math.floor(100 / Math.max(sorted.length, 1)), 20);
  const statBoxes = sorted.map(([status, count]) => statusStatBox(status, count, boxWidth)).join("");
  const bar = segBar(sorted.map(([status, count]) => ({ value: count, color: statusMeta(status).color })));
  const legendItems = sorted
    .map(([status, count]) => {
      const meta = statusMeta(status);
      return (
        `<td style="padding-right:16px;padding-top:10px;white-space:nowrap;font-size:12px;color:${COLOR.muted};">` +
        `<span style="display:inline-block;width:9px;height:9px;border-radius:50%;background:${meta.color};margin-right:6px;vertical-align:middle;"></span>` +
        `<b style="color:${COLOR.ink};">${fmtInt(count)}</b>&nbsp;${meta.label}</td>`
      );
    })
    .join("");

  const inner =
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;margin-bottom:14px;"><tr>${statBoxes}</tr></table>` +
    bar +
    `<table role="presentation" cellpadding="0" cellspacing="0"><tr>${legendItems}</tr></table>`;

  return card("📊&nbsp; Abonelik Durumu", inner);
}

function expiringRow(row: SubscriberSummaryRow, formatDate: (d: Date) => string, showDivider: boolean): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;${showDivider ? `border-bottom:1px solid ${COLOR.lineSoft};` : ""}">` +
    `<tr>` +
    `<td style="padding:11px 0;font-size:13.5px;color:${COLOR.ink};font-weight:600;">${row.name}</td>` +
    `<td align="right" style="text-align:right;padding:11px 0;">` +
    `<span style="display:inline-block;font-size:11.5px;font-weight:600;color:${COLOR.amber};background:${COLOR.amberWash};border-radius:20px;padding:4px 12px;white-space:nowrap;">` +
    `⏳&nbsp;${row.trialEndsAt ? formatDate(row.trialEndsAt) : "—"}</span>` +
    `</td>` +
    `</tr></table>`
  );
}

function expiringSection(rows: SubscriberSummaryRow[], formatDate: (d: Date) => string): string {
  const now = new Date();
  const soon = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
  const expiring = rows
    .filter((r) => r.status === "trial" && r.trialEndsAt && r.trialEndsAt <= soon)
    .sort((a, b) => (a.trialEndsAt?.getTime() ?? 0) - (b.trialEndsAt?.getTime() ?? 0));

  const inner =
    expiring.length === 0
      ? `<div style="font-size:13px;color:${COLOR.muted};">Önümüzdeki 7 gün içinde deneme süresi biten salon yok. 🎉</div>`
      : expiring.map((r, i) => expiringRow(r, formatDate, i < expiring.length - 1)).join("");

  return card("⏰&nbsp; Deneme Süresi 7 Gün İçinde Bitecek Salonlar", inner);
}

export function buildSubscriberSummaryEmailHtml(
  weekLabel: string,
  rows: SubscriberSummaryRow[],
  formatDate: (d: Date) => string,
): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;border-collapse:collapse;">` +
    `<tr><td style="background:${COLOR.ink};padding:26px 28px;border-radius:18px 18px 0 0;">` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.6);">EGORACTIVE İŞLETME RAPORU</div>` +
    `<div style="font-family:Arial,Helvetica,sans-serif;font-weight:800;font-size:22px;color:#ffffff;margin-top:6px;">Haftalık Abone Özeti</div>` +
    `</td></tr></table>` +
    `<div style="padding:22px 22px 4px;background:#ffffff;border-radius:0 0 18px 18px;">` +
    heroBanner(rows.length, weekLabel) +
    statusSection(rows) +
    expiringSection(rows, formatDate) +
    `<div style="text-align:center;font-size:11px;color:${COLOR.faint};padding-bottom:8px;font-family:Arial,Helvetica,sans-serif;">Bu rapor Egoractive tarafından otomatik oluşturuldu.</div>` +
    `</div>`
  );
}
