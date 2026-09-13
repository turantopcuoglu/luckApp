# Kozmik üretim görselleri — v1

Tarih: 8 Eylül 2026. Onaylı sanat yönünün başlangıç/Bugün uygulama dilimi.

Üretim: yerleşik image_gen aracı (built-in); CLI/API fallback kullanılmadı.
Görseller orijinal üretim çıktılarından kopyalanmıştır; eski varlıklar silinmedi.
Ekran mockup'ı değildir: yazı ve kontroller Flutter, hareketler CustomPainter /
AnimationController katmanlarıdır. Aşağıdaki dosyalar mevcut `assets/images/`
pubspec kaydı üzerinden paketlenir. Üretim PNG'lerinin toplamı yaklaşık 8,4 MB;
decode genişliği 768 px ile sınırlıdır. Dağıtım sıkıştırması sonraki performans
kontrolünde, kalite karşılaştırmasıyla değerlendirilmelidir.

| Varlık | Uygulamada kullanımı |
| --- | --- |
| `assets/images/cosmic_atmosphere_v1.png` | CosmicBackdrop: başlangıç/Bugün arka planı; canlı ışık şeritleri ve parçacıklar ayrı çizilir. |
| `assets/images/cosmic_card_back_v1.png` | CosmicCardFace: kapalı kart; CardRevealMotion iki ayrı kanada bölüp açar. |
| `assets/images/cosmic_portal_v1.png` | CosmicPortal: açılan kartın arkası ve sonuç skoru sahnesi; skor gerçek metindir. |

## Tam üretim promptları

### cosmic_atmosphere

```text
Use case: stylized-concept. Production bitmap BACKGROUND ASSET for approved Kader futuristic-spiritual mobile app. A single full-bleed portrait 1024x1536 image, NO UI, NO TEXT, NO numerals, NO phone frames, NO card object, NO logo. Midnight navy #07162F and sophisticated cyan-gold star dust. Grand very dim cosmic stone arch columns at the extreme left/right, delicate engraved champagne edges, a distant luminous winding river/path and blue mist in lower third, distant pointed mountains. Central upper 60 percent mostly deep navy starlit negative space where an animated card and score will be composited in Flutter. Soft celestial depth and luxurious fine detail like the approved Kader concept, not flat vector. Subtle tiny gold stars, atmospheric volumetric cyan light at sides, dark top/bottom gradually blending to #07162F. No bright central disk, no drawn loading ring, no pre-painted orbit or particle streaks: live Flutter layers supply those. Full bleed edge-to-edge, high quality cinematic environment.
```

### cosmic_card_back

```text
Use case: stylized-concept. Production card-face TEXTURE ASSET for approved Kader app. Single flat rectangular portrait card surface filling entire canvas edge to edge, ratio 2:3, NO surrounding background and NO perspective. Obsidian midnight blue-black marble and exquisitely detailed thin champagne gold etched botanical/celestial filigree around inset border, precise symmetrical elegant line work. Center is mostly dark, with a hairline vertical seam and an ornate engraved circular GOLD seal in exact center; seal has an abstract four-point star/doorway emblem, no words, no letters, no moon. Bright thin metal rim just inside image edge, comfortable protected border margin; all four corners inside canvas, not cropped. Luxurious foil iridescence very subtle cyan. No luminous environmental effects baked in, no floating debris, no cards behind, no phone UI, no typography, no numerals, no mockup. This rectangular texture will be mapped to a rounded card and split into two hinged animated panels in Flutter. Straight-on orthographic texture, not a perspective product photograph.
```

### cosmic_portal

```text
Use case: stylized-concept. Production bitmap HERO SCENE ASSET for approved Kader app. One portrait 1024x1536 atmospheric image without ANY text, UI, phone frame, numerals, cards, or typography. A tall luminous elegant GOLD ARCHWAY centered, flanked by slender dark obsidian columns with delicate etched gold lines, looking onto a distant calm luminous winding path and distant mountain horizon across mirror water. Opening occupies central 62 percent width and 78 percent height, top of arch at 10 percent image height; middle upper opening DARK deep navy starfield for readable huge score overlay. Cyan aurora mist at edges, warm gold horizon lower down, luxurious dimensional spiritual-futuristic mood. No opaque door panels: reveal panels supplied separately in Flutter. Outer frame sides fade into deep midnight #07162F, no rectangular illustration border. Refined realistic cosmic fantasy environment, cinematic materials, not cartoon. No giant moon centered behind future score. No swirls painted across score area. Gold highlights controlled. This is hero artwork, not a whole app screenshot.
```

## Gerçek ekran kontrolü

`design/previews/kader-cosmic-{low,high,rare}.png`, `kader-preparing.png`,
`kader-reveal-{seal,seam,unfold}.png` dosyaları Flutter widget testlerinden
üretilir; yapay zekâ ekran taslağı değildir. Statik PNG'ler ses, hareketin zaman
çizelgesi ve cihaz FPS sonucunu kanıtlamaz.

