# Kader Arketip İllüstrasyon Kaynakları

Bu klasördeki PNG dosyaları, Kader 2.0'ın beş günlük arketipi için üretilen
yüksek çözünürlüklü master görsellerdir. Uygulama bu dosyaları doğrudan bundle
etmez; `assets/images/archetypes/` altındaki 1024×768 WebP karşılıklarını
kullanır.

## Dosya eşlemesi

| Master | Üretim asset'i | Deneyim alanı |
|---|---|---|
| `archetype_akis.png` | `assets/images/archetypes/archetype_akis.webp` | Akış |
| `archetype_bag.png` | `assets/images/archetypes/archetype_bag.webp` | Bağ |
| `archetype_uretim.png` | `assets/images/archetypes/archetype_uretim.webp` | Üretim |
| `archetype_cesaret.png` | `assets/images/archetypes/archetype_cesaret.webp` | Cesaret |
| `archetype_denge.png` | `assets/images/archetypes/archetype_denge.webp` | Denge |

## Ortak üretim istemi

Görseller Codex'in yerleşik görsel üretim aracıyla, aşağıdaki ortak sanat
yönü kullanılarak ayrı ayrı üretilmiştir:

```text
Use case: stylized-concept
Asset type: production mobile-app daily archetype illustration, landscape
4:3 card artwork

Match the approved Kader concept boards: premium editorial vector-like
illustration, crisp layered shapes, subtle tactile paper grain, restrained
fine gold line accents, sophisticated adult playfulness and clear mobile
silhouettes.

Composition: exact landscape 4:3, generous safe inset, no frame, no text,
no UI and no logo. The artwork must read at about 330×240 logical pixels.

Palette: deep ink navy, warm cream, electric lime, warm coral, iris violet,
ice blue and very restrained soft gold.

Avoid: zodiac, tarot, crystal balls, stars, moons, constellations, clover,
dice, casino, fortune-teller imagery, photorealism, 3D render, childish game
art and watermarks.
```

## Sahne istemleri

- **Akış:** Kıvrılan krem yol, katmanlı lacivert tepeler, açık kemerli kapı,
  yolu izleyen kâğıt uçak ve sınırlı renkli şeritler.
- **Bağ:** İki alt köşeden gelen yolun küçük bir köprüde birleşmesi, eşleşen
  bitkiler, coral/iris şeritler; kalp sembolü yok.
- **Üretim:** Yol boyunca tohumun filize ve düzenli geometrik bir yapıya
  dönüşmesi; para ve ofis klişesi yok.
- **Cesaret:** Açık bir yol ayrımı, yükselen patikayı seçen kâğıt uçak, küçük
  lime yön işaretleri; tehlike veya risk övgüsü yok.
- **Denge:** Sakin su, üç dengeli taş, yapraklar ve suya yansıyan kemerli
  açıklık; spiritüel sembol yok.

## Üretim dönüşümü

- Master: PNG, 4:3.
- Uygulama: WebP, 1024×768, quality 88, smart chroma subsampling.
- PNG master'lar kaynak olarak korunur.
- Yeni WebP üretilirken dosya adı ve 4:3 oran değiştirilmez.
- Görsel revizyonu yapılırsa mevcut dosyanın üzerine sessizce yazılmaz;
  önce `-v2` varyantı üretilip görsel onay alınır.
