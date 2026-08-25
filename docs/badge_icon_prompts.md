# Rozet İkonları — ChatGPT Görsel Üretim Prompt'ları

Tüm rozetler **aynı tasarım dilini** paylaşır (aynı madalyon formu, aynı ışık kurgusu, aynı kompozisyon kuralları) — sadece rozetin **zorluk kademesine göre malzeme/parlaklık/arka plan** değişir. Bu yüzden kolay bir rozetle (ör. ilk ders) zor bir rozet (ör. 1 yıl üyelik) yan yana durduğunda ikincisinin gözle görülür şekilde daha değerli/premium hissettirmesi hedeflendi — düz "aynı renk, farklı sembol" yaklaşımı (eski versiyon) bunu sağlamıyordu.

## Kademe sistemi

Rozetler zorluk sırasına göre 5 kademeye ayrıldı — Bronz → Gümüş → Altın → Platin → Elmas. Her kademe yükseldikçe: malzeme daha değerli, parlama/işık efekti daha yoğun, arka plan daha dramatik, detay daha zengin oluyor. Uygulamanın primary rengi ya da app ikonunun tam renk paleti şart değil — asıl korunan şey **madalyon formu ve genel ikon dili** (app ikonundaki gibi 3D camsı/metalik rozet hissi), renk kademeye göre serbest.

| Kademe | Rozetler | Neden bu kademe |
|---|---|---|
| 🥉 Bronz | `first_session`, `feedback_given`, `measurement_logged`, `group_session_join`, `event_join` | Tek seferlik, düşük eforlu ilk aksiyonlar |
| 🥈 Gümüş | `sessions_5` | İlk süreklilik adımı |
| 🥇 Altın | `sessions_20`, `membership_6_months` | Orta vadeli ciddi bir bağlılık |
| 💎 Platin | `sessions_50` | Yüksek hacimli, zor kazanılan bir eşik |
| 💠 Elmas | `membership_12_months` | En uzun soluklu bağlılık — uygulamadaki en prestijli rozet |

**Ortak madalyon çerçevesi (her prompt'ta aynı, kademe fark etmeksizin tekrar ediyor):**
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting.

Aşağıdaki her kademe bloğu bu ortak çerçeveye eklenen **malzeme + arka plan + ışık** tarifidir; her rozetin tam prompt'u bu ikisinin (ortak çerçeve + kademe bloğu) sembol tarifiyle birleşimidir — aşağıdaki 10 madde doğrudan kopyala-yapıştır için hazır, tekrar birleştirmene gerek yok.

---

### 🥉 Bronz kademe malzemesi
Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects.

### 🥈 Gümüş kademe malzemesi
Background: cool dark slate vignette (#10151C). Medallion material: polished silver/chrome metal with crisp cool highlights and clean reflections, brighter rim light (#D8E4EE to #8FA6BC), a light soft halo glow behind the medallion — noticeably more refined and precise than bronze, still restrained.

### 🥇 Altın kademe malzemesi
Background: deep navy-black with a soft radial glow (#0A0E1A center fading to black). Medallion material: lustrous polished gold metal with rich specular highlights, warm radiant glow (#FFD76A to #C9911A), a subtle radial light burst directly behind the medallion, a few small drifting light-particle motes near the rim — clearly premium, celebratory.

### 💎 Platin kademe malzemesi
Background: near-black deep vignette (#05070D) with a faint cool-toned aura. Medallion material: platinum/white-gold metal with a faint iridescent sheen, cool-bright glow (#EAF6FF to #9AD6FF), pronounced rim lighting, finely engraved micro-detail along the medallion border, gently floating light particles around it — elevated, cinematic, unmistakably hard-earned.

### 💠 Elmas kademe malzemesi
Background: near-black void with a dramatic radial glow and faint prismatic light rays fanning outward. Medallion material: faceted crystal/diamond-like surface with prismatic rainbow refractions catching the light at the edges, layered over a brilliant white-to-cyan-to-violet core glow (#FFFFFF to #7FE0FF to #B98CFF), intense sparkling light particles and subtle lens-flare highlights surrounding the medallion, an ornate finely engraved rim with tiny gemstone-like accent points — maximum premium, legendary-tier presentation; this must visibly read as the single most valuable badge in the whole set.

---

## Rozet prompt'ları

### 1. İlk dersin (first_session) — 🥉 Bronz
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects. The symbol: a single kettlebell with a small checkmark badge overlapping its bottom-right, symbolizing a first completed session.

### 2. Geri bildirim (feedback_given) — 🥉 Bronz
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects. The symbol: a rounded speech-bubble shape with a small five-point star centered inside it, symbolizing giving feedback.

### 3. Ölçüm takibi (measurement_logged) — 🥉 Bronz
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects. The symbol: a simplified measuring tape coiled into a spiral with a small ruler tip extending outward, symbolizing body measurement tracking.

### 4. Grup dersi (group_session_join) — 🥉 Bronz
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects. The symbol: three simplified overlapping human silhouettes standing side by side, symbolizing a group class.

### 5. Etkinlik (event_join) — 🥉 Bronz
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: soft dark charcoal-brown vignette (#1A1410). Medallion material: brushed matte bronze/copper metal with warm amber undertones and faint surface scratches, gentle warm glow (#C9793B to #8B4A22), a single soft shadow, modest specular highlight — solid, humble, entry-level craftsmanship, no sparkle effects. The symbol: a simplified calendar page icon with a small star in the corner, symbolizing joining a special event.

### 6. 5 ders tamam (sessions_5) — 🥈 Gümüş
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: cool dark slate vignette (#10151C). Medallion material: polished silver/chrome metal with crisp cool highlights and clean reflections, brighter rim light (#D8E4EE to #8FA6BC), a light soft halo glow behind the medallion — noticeably more refined and precise than bronze, still restrained. The symbol: a kettlebell with five small filled dots/pips arranged in an arc above it, symbolizing 5 completed sessions.

### 7. 20 ders tamam (sessions_20) — 🥇 Altın
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: deep navy-black with a soft radial glow (#0A0E1A center fading to black). Medallion material: lustrous polished gold metal with rich specular highlights, warm radiant glow (#FFD76A to #C9911A), a subtle radial light burst directly behind the medallion, a few small drifting light-particle motes near the rim — clearly premium, celebratory. The symbol: a medal/star badge shape with a small kettlebell silhouette embossed in its center, symbolizing a stronger training milestone.

### 8. 6 ay üyelik (membership_6_months) — 🥇 Altın
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: deep navy-black with a soft radial glow (#0A0E1A center fading to black). Medallion material: lustrous polished gold metal with rich specular highlights, warm radiant glow (#FFD76A to #C9911A), a subtle radial light burst directly behind the medallion, a few small drifting light-particle motes near the rim — clearly premium, celebratory. The symbol: a shield outline with a half-filled circular clock/dial embossed inside it, symbolizing 6 months of steady membership.

### 9. 50 ders tamam (sessions_50) — 💎 Platin
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: near-black deep vignette (#05070D) with a faint cool-toned aura. Medallion material: platinum/white-gold metal with a faint iridescent sheen, cool-bright glow (#EAF6FF to #9AD6FF), pronounced rim lighting, finely engraved micro-detail along the medallion border, gently floating light particles around it — elevated, cinematic, unmistakably hard-earned. The symbol: a trophy cup with a laurel wreath wrapped around its base, symbolizing a major training milestone.

### 10. 1 yıl üyelik (membership_12_months) — 💠 Elmas
> Minimalist 3D glossy app-icon-style badge illustration, a symmetrical circular medallion with a raised beveled metallic rim, a single centered symbol rendered in relief at the medallion's core, no text, no extra scenery, clean vector illustration with realistic 3D depth and physically-based material rendering, square 1:1 canvas, high detail, centered composition, dramatic studio lighting. Background: near-black void with a dramatic radial glow and faint prismatic light rays fanning outward. Medallion material: faceted crystal/diamond-like surface with prismatic rainbow refractions catching the light at the edges, layered over a brilliant white-to-cyan-to-violet core glow (#FFFFFF to #7FE0FF to #B98CFF), intense sparkling light particles and subtle lens-flare highlights surrounding the medallion, an ornate finely engraved rim with tiny gemstone-like accent points — maximum premium, legendary-tier presentation; this must visibly read as the single most valuable badge in the whole set. The symbol: a fully filled circular clock/dial embossed inside a shield, with a small star crowning the top of the shield, symbolizing a full year of unbroken membership.
