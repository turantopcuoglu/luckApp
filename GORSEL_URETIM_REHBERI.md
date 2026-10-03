# Kader — Görsel Üretim Rehberi (GPT için)

Bu dosya, uygulamanın tüm görsellerini **tek, tutarlı bir dokuyla** GPT'ye
ürettirmek için yazıldı. Her öğede: dosya adı, nerede kullanılacağı, boyut,
animasyon için nasıl katmanlanacağı, GPT'ye yüklenecek referans görseller,
İngilizce istem, kaçınılacaklar ve kabul kriteri var.

> **Bu dosya `CIZIM_LISTESI.md`'nin yerini alır.** O dosyadaki "ince altın
> çizgi, düz renk" stili terk edildi; uygulama artık 8 Eylül'de üretilen
> **ışıklı, foto-gerçekçi fantastik gece** stilini kullanıyor (kapılar,
> mermer, altın, ay, yansıyan su). Eski dosyadaki dosya adları ve kod
> konumları hâlâ doğru; stil ve istemler bu dosyadakiler geçerli.

**Kaynak klasör** (mevcut GPT çıktıları):
`C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\`
Görseller `exec-` önekinden sonraki ilk 8 karakterle anılır
(ör. `38f451fb` = `exec-38f451fb-e1ad-...png`).

---

## İçindekiler

0. Nasıl kullanılır (iş akışı)
1. Görsel dil: stil bibliyası (GPT'ye ilk mesaj)
2. Teknik kurallar (boyut, şeffaflık, güvenli alan, katmanlar)
3. Referans kütüphanesi (mevcut iyi görseller)
4. Öğe listesi — öncelik sırasıyla
   - P1: yayından önce (Bugün cilası, marka, onboarding, paylaşım, profil)
   - P2: ilk güncelleme (raporlar, uyum, keşfet, koleksiyon)
   - P3: isteğe bağlı
5. Kalite kontrol listesi
6. Teslim ve durum tablosu

---

## 0. Nasıl kullanılır

1. GPT'de **yeni bir sohbet** aç. Önce **Bölüm 1**'deki stil bibliyasını
   yapıştır, ardından Bölüm 3'teki **"çekirdek referanslar"**ı (4 görsel)
   yükle ve "Bundan sonraki tüm görseller bu dünyaya ait olsun" de.
2. Öğeleri **aynı sohbette** sırayla üret (tutarlılık için). Her öğede
   "Referans" satırındaki görselleri ayrıca yükle.
3. Beğendiğin sonucu **"Dosya" satırındaki adla** kaydet. Bir öğe birden
   fazla dosya istiyorsa her biri ayrı üretim olabilir.
4. Dosyaları `assets/images/` altına koy (PNG olarak bırak; telefona göre
   küçültme, JPEG/şeffaf PNG dönüşümü ve kırpmayı ben yaparım).
5. **Bölüm 6**'daki tabloda durumu "çizildi" yap ve bana
   `GORSEL_YENILEME_PLANI.md`'deki ilgili oturumu başlatmamı söyle.

**İpuçları**
- GPT bir görseli "beğenmediğin yerinden" düzeltmekte iyidir: "Same image,
  but move the moon to the upper right and keep everything else identical"
  gibi düzeltme istemleri kullan.
- Şeffaf görsellerde mutlaka "transparent background, PNG with alpha"
  yaz. Sonuç damalı desen *çizilmiş* opak görsel gelirse reddet, tekrar iste.
- Çoklu ikon/madalyon setlerinde tek görselde ızgara iste (kırpmayı ben
  yaparım); böylece set içi tutarlılık artar.
- Yazı çıkarsa (harf, rakam, logo) reddet: uygulama çok dilli olacak,
  tüm metinler kodla çizilir.

---

## 1. Görsel dil — stil bibliyası

Aşağıdaki bloğu GPT'ye **ilk mesaj** olarak yapıştır:

```
You are the art director and illustrator for "Kader", a premium daily
ritual app (self-discovery and entertainment, NOT fortune telling).
Every image you make must belong to ONE consistent world:

WORLD
- An endless moonlit night realm: tall ornate arches and colonnades of
  dark stone and polished gold, open gates and doors, a calm mirror-like
  lake that reflects everything, a glowing path of light on the water,
  distant spires and mountains, soft clouds at the horizon, a crescent
  moon, a deep starry sky with faint nebula.
- Materials: deep blue marble with white/gold veins, engraved antique
  gold filigree, clear glass, liquid light, starlight.
- Mood: calm, magical, hopeful, luxurious, quiet. Never scary, never dark
  or occult.

RENDERING
- Photorealistic fantasy / cinematic matte painting quality, crisp
  details, soft volumetric light, gentle bloom and lens glow, small
  sparkles floating in the air.
- Main light source is always INSIDE the scene (a gate, an orb, the
  horizon or the moon), warm gold core fading into cool blue.
- High contrast but rich shadows; shadows are deep navy, never pure black.

PALETTE (keep the overall image within this palette)
- Night navy  #0A0E1A   (backgrounds, shadows)
- Deep blue   #131A2E / #1C2A4F (sky, marble)
- Gold        #F4C95D   (ornaments, light core)
- Light gold  #FFE9B8   (highlights)
- Accent per mood: teal #6FE6DA (high energy), lavender #C3B2F5 (calm,
  slow day), warm amber #FFD27A (balanced day)

HARD RULES
- No text, no letters, no digits, no logos, no watermarks.
- No people, no faces, no hands, no animals.
- No tarot cards, crystal-ball fortune tellers, coffee cups, palms,
  evil-eye beads, skulls, religious symbols, occult symbols, pentagrams.
- No borders or frames unless asked. No UI elements.
- Keep important content inside the safe area I give you.
```

### 1.1 Görsel dilin kuralları (benim için de geçerli)

| Kural | Açıklama |
|---|---|
| Tek dünya | Her ekran aynı gece âleminin farklı bir köşesi. Yeni nesne istersen onu bu dünyanın malzemeleriyle (mermer, altın, cam, ışık) tarif et. |
| Işık anlam taşır | Turkuaz = yüksek enerji/şanslı gün, amber = dengeli, lavanta = yavaş/sakin gün. Altın = kullanıcının kendisi, ödül, premium. |
| Kapı/kemer motifi | Uygulamanın imzası. "Yeni bir gün = açılan kapı". Kartlar, paywall, onboarding hep kemer/kapı içerir. |
| Su ve yansıma | Ekranların alt yarısı genelde göl/yansıma: UI kartları bu sakin alana oturur. |
| Boşluk | Tam ekran sahnelerin üst %15'i (saat, başlık) ve alt %35'i (kartlar, butonlar) sakin kalmalı. |
| Doku | Kartlar ve paneller mavi mermer + altın kenar; düz renk panel kullanılmaz. |

### 1.2 Hareket dili (görselleri bu animasyonlar için katmanlıyoruz)

| Hareket | Nerede | Görsel ihtiyacı |
|---|---|---|
| Ken Burns (yavaş yakınlaşma) | Tüm tam ekran sahneler | Kenarlarda %6 fazladan görüntü (kırpılabilir). |
| Paralaks (kaydırınca katmanlar farklı hızda) | Bugün, onboarding, profil | Ön plan sütunları ayrı şeffaf katman. |
| Parıldama | Yıldızlar, kıvılcımlar | Tek parıltı sprite'ı (P1-B3). |
| Işık dolumu | Onboarding küresi | Cam + sıvı + çerçeve ayrı katman. |
| Kapı/kart açılışı | Bugün, paylaşım, koleksiyon | Kart arka yüzü ve mühür ayrı katman. |
| Mühür kırılması/dönmesi | Bugün | Şeffaf madalyon. |
| Sahne geçişi (crossfade) | Skor bandına göre | Aynı kompozisyonda renk varyantları. |

---

## 2. Teknik kurallar

| Konu | Kural |
|---|---|
| Biçim | PNG. Opak sahneler ve şeffaf öğeler ayrı belirtilmiştir. |
| GPT boyutu | GPT'nin verdiği en yakın oranı seç: dikey **1024×1536** (2:3), yatay **1536×1024**, kare **1024×1024**. Daha uzun dikey (9:16) verebiliyorsa onu tercih et. |
| Telefon oranı | Telefon ekranı ~9:19.5'tir; 2:3 bir görsel ekrana sığdırılırken **yanlardan ~%15'er kırpılır**. Bu yüzden tam ekran sahnelerde önemli her şey **ortadaki %66 genişlikte** olmalı. |
| Güvenli alan (tam ekran) | Üst %15: sakin gökyüzü (saat + başlık). Orta %15–60: odak (kapı, kart, küre). Alt %40: sakin su/yansıma (UI buraya oturur, kod koyulaştırır). |
| Şeffaf öğeler | "transparent background, PNG with alpha". Kenarda %8 boş pay. Gölge/hale görselin içinde kalsın, kesilmesin. |
| Katmanlar | Katman isteyen öğelerde tüm katmanlar **aynı tuval boyutunda ve aynı konumda** olmalı (üst üste konunca birebir oturur). |
| İkonlar | 512×512 şeffaf, altın metal madalyon/glif. Kod küçük boyutlarda (24–40 px) gösterir; çizim kalın ve okunur olmalı. |
| Yazı | Hiçbir görselde harf veya rakam yok. |
| Dosya adı | küçük harf, Türkçe karakter yok, alt çizgi: `sahne_orta_kapili.png`. |

---

## 3. Referans kütüphanesi

### 3.1 Çekirdek referanslar (GPT sohbetinin başında 4'ünü birden yükle)

| Kimlik | Ne | Neyi temsil ediyor |
|---|---|---|
| `38f451fb` | Mavi mermer kart arka yüzü, altın mühür | Malzeme + ornament dili |
| `37f95a85` | Turkuaz ışıklı açık kapılar | Yüksek enerji sahnesi, kompozisyon |
| `3fb4a097` | Mavi sütunlar, hilal, bulutlar | Sakin varsayılan sahne |
| `769f7a6f` | Kemer, hilal, göl (koleksiyon kartı) | Kart illüstrasyonu dili |

### 3.2 Diğer iyi referanslar

| Kimlik | Ne | Kullanım |
|---|---|---|
| `4643c18c` | Lavanta kapılar | Düşük skor sahnesi (kullanılıyor) |
| `43821fb7` | Altın kemer, gün doğumu | Orta skor sahnesi (kullanılıyor) |
| `9124e6e4` | Cam küre, yıldızlı | Onboarding küresi |
| `3e57eb6c` | Yörünge halkaları, turkuaz ufuk | Onboarding/arka plan |
| `c75d47d5` | Dairesel portal | Uyum/arka plan |
| `0493d63c`, `5f0a1c2f` | Sade gece denizi, doğan ay | İkincil ekran arka planları |
| `784120f8` / `122a7f6e` | Kapı amblemi (şeffaf / koyu) | Uygulama ikonu |
| `7c2c7363` | Hilal + dört uçlu yıldız | Parıltı, ikon dili |
| Mockup'lar: `42699425` (Bugün), `9f0eb26b` (kart açılışı), `ee9545f3` (onboarding), `9635f67f` (paylaş/koleksiyon/ayarlar/premium) | Ekran tasarımları | Yerleşim referansı |

### 3.3 Kullanılmayanlar

- 2 Eylül tarihli 20 görsel (illüstratör tarzı patika/köprü kartları ve
  krem zeminli mockup'lar: `f1da7726` … `6da6eaa0`): eski stil, kullanılmayacak.
- `f7fefee2` (anahtar + kartlar): tarot çağrışımı, kullanılmayacak.

---

## 4. Öğe listesi

Biçim: **[Kimlik] Ad** — Dosya · Nerede · Boyut · Katman/Animasyon ·
Referans · İstem · Kaçın · Kabul.

### P1 — Yayından önce

#### P1-B — Bugün ekranı cilası

**[P1-B1] Mühür madalyonu + mühürsüz kart** — öncelik en yüksek

- **Dosya:** `muhur.png` (şeffaf), `kart_arka_yuzu_muhursuz.png` (opak)
- **Nerede:** Ana ekrandaki kapalı kart (`daily_luck/widgets/fortune_reveal_card.dart`).
- **Animasyon:** Dokununca mühür hafifçe döner ve parlar; ışık fazında
  ortadan çatlar, iki yarısı kanatlarla birlikte gider. Bunun için mühür
  kart görselinden ayrı olmalı.
- **Boyut:** muhur 1024×1024; kart 1024×1536.
- **Referans:** `38f451fb`
- **İstem 1 (muhur):**
  ```
  Isolate ONLY the circular gold compass-star medallion from the attached
  card back: the eight-pointed gold star with the pearl in the center,
  the engraved radial-ray disc, the dark inner ring with tiny gold dots,
  the two thin outer gold rings and the four small side spikes. Same
  lighting and detail, seen straight on. Transparent background (PNG
  with alpha), perfectly centered, 1024x1024, 8% padding. Nothing else.
  ```
- **İstem 2 (kart):**
  ```
  Recreate the attached card back EXACTLY (same blue marble pattern, same
  gold border, same corner ornaments, same vertical glowing gold seam in
  the middle, same size 1024x1536), but REMOVE the central medallion: the
  marble and the vertical seam simply continue through the center.
  ```
- **Kaçın:** Mühürde mermer arka planı kalması; kartta mühürden iz kalması.
- **Kabul:** muhur.png, kartın ortasına konunca orijinaldeki gibi oturuyor.

**[P1-B2] Ön plan sütun çerçevesi (paralaks katmanı)**

- **Dosya:** `on_plan_sutunlar.png` (şeffaf)
- **Nerede:** Bugün ekranı ve diğer tam ekran sahnelerin en önü. Kaydırınca
  ve kart açılırken arka plandan daha hızlı hareket eder → derinlik.
- **Boyut:** 1024×1536 (dikey).
- **Referans:** `3fb4a097`, `37f95a85` (sütunlar)
- **İstem:**
  ```
  A foreground frame layer for a portrait phone screen: two tall ornate
  dark-stone and gold columns at the very left and right edges, joined at
  the top by the lower part of a grand arch, with a few hanging tiny
  gold lanterns and sparse floating sparkles. Everything else is
  TRANSPARENT: the whole center (from 18% to 82% of the width) and the
  bottom 30% must be empty. Lit from the center (warm rim light on the
  inner edges of the columns). Transparent background, PNG with alpha,
  1024x1536.
  ```
- **Kaçın:** Ortaya taşan dal/sarmaşık, zemin, su.
- **Kabul:** Herhangi bir sahnenin üstüne konunca ortası tamamen görünüyor.

**[P1-B3] Parıltı sprite'ı**

- **Dosya:** `parilti.png` (şeffaf)
- **Nerede:** Kıvılcımlar, yıldız parıltısı, buton parlaması (tüm uygulama).
- **Boyut:** 512×512.
- **Referans:** `7c2c7363` (hilalin yanındaki yıldız)
- **İstem:**
  ```
  A single four-pointed sparkle star: thin long horizontal and vertical
  light rays, shorter diagonal rays, a small intensely bright warm-white
  core and a soft round golden glow. Centered, transparent background
  (PNG with alpha), 512x512, nothing else.
  ```
- **Kabul:** Siyah zeminde de, açık zeminde de kenarı kirli değil.

**[P1-B4] Orta skor sahnesi — kapılı sürüm**

- **Dosya:** `sahne_orta_kapili.png` (opak)
- **Nerede:** Skor 40–59 olan günlerde kart açılınca gelen arka plan. Şu
  an `43821fb7` (kapısız kemer) kullanılıyor; kartın kanatları sönerken
  sahnenin kapılarına dönüşmesi kapılı sahnede daha iyi oturuyor.
- **Boyut:** 1024×1536 (ya da 9:16).
- **Referans:** `37f95a85` + `4643c18c` (kompozisyon), `43821fb7` (renk)
- **İstem:**
  ```
  Same composition as the two attached gate scenes: two tall ornate
  doors swung open toward the viewer inside a glowing golden arch,
  columns and small planets on both sides, a lake with a bright light
  path leading to the horizon, distant spires. Doors at exactly the same
  position and size as in the references. Palette: warm golden dawn
  (amber #FFD27A), a soft sunrise glow behind the gate, gentle gold light
  ribbons. Balanced, calm mood. Portrait 1024x1536. No text.
  ```
- **Kabul:** Üç sahne (turkuaz/amber/lavanta) yan yana konunca kapılar aynı yerde.

**[P1-B5] Kategori glifleri (5 adet)**

- **Dosya:** `kategori_ask.png`, `kategori_para.png`, `kategori_saglik.png`,
  `kategori_sosyal.png`, `kategori_risk.png` — ya da tek ızgara `kategori_seti.png`
- **Nerede:** Ana ekrandaki 5 karo, kategori detay sayfası. Kod her birini
  kendi rengine boyar (pembe, altın, yeşil, mavi, turuncu).
- **Boyut:** her biri 512×512 ya da ızgara 1536×1024 (3+2).
- **Önemli:** **Tek renk saf beyaz**, şeffaf zemin (boyanabilmesi için).
- **Referans:** Mockup `42699425` (karolardaki ikonlar)
- **İstem:**
  ```
  A matching set of five app glyph icons, solid filled soft shapes in
  pure white (#FFFFFF) on a transparent background, no gradients, no
  outlines, slightly rounded and elegant, each with one tiny four-pointed
  star accent:
  1) Love: a heart.
  2) Money: a small stack of three coins seen at a slight angle.
  3) Health: a single leaf with a central vein.
  4) Social: two overlapping people silhouettes from the shoulders up
     (very simplified, no faces).
  5) Risk / bold moves: a lightning bolt.
  Same visual weight, same padding (12%). Arrange in a grid: 3 on the top
  row, 2 centered on the bottom row, 1536x1024, transparent background.
  ```
- **Kabul:** 24 px'te tanınıyor; hepsi aynı kalınlıkta.

#### P1-M — Marka

**[P1-M1] Uygulama ikonu** — çizim gerekmiyor

`784120f8` (şeffaf) ve `122a7f6e` (koyu zemin) kapı amblemi kullanılacak.
Yalnızca 48 px'te detay kaybolursa şu sade sürümü iste:
```
Simplify the attached app emblem for small sizes: keep the gold arch
gate, the four-pointed star with the cyan gem and the orbit ring; remove
the small inner engravings and thin side details; thicker gold strokes.
Transparent background, 1024x1024, the emblem fits inside a centered
circle of 66% diameter.
```
Dosya: `ikon_sade.png`.

**[P1-M2] Bildirim ikonu** — çizim gerekmiyor, **ben vektör olarak çizeceğim**
(Android bildirim ikonu tek renk siluet olmak zorunda; GPT'nin raster
çıktısı bunun için uygun değil).

**[P1-M3] Play Store öne çıkan görsel**

- **Dosya:** `play_ozellik.png` · **Boyut:** 1536×1024 (ben 1024×500'e kırparım).
- **Referans:** `37f95a85`, `784120f8`
- **İstem:**
  ```
  Wide store banner. The left 45% is a calm starry night sky over a dark
  lake (empty, the title will be added later). On the right, the golden
  arch emblem from the attached icon floats above the water inside a
  softly glowing open gate, teal and gold light ribbons swirl around it,
  reflections on the lake. 1536x1024, keep all important content in the
  vertical middle 50% (it will be cropped to 1024x500). No text.
  ```

#### P1-O — Onboarding

Mockup: `ee9545f3`. Ekranlar: `welcome_screen.dart`, `profile_form_screen.dart`,
`tanisma_screen.dart`, `calculating_screen.dart`, `legal/uyari_screen.dart`.

**[P1-O1] Onboarding arka planı**

- **Dosya:** `sahne_onboarding.png` (opak) · 1024×1536
- **Nerede:** Karşılama, uyarı, form ve tanışma ekranlarının ortak arka planı.
- **Referans:** `3fb4a097`, mockup `ee9545f3` 1. ekran
- **İstem:**
  ```
  Portrait 1024x1536 calm scene: a dim colonnade of arches receding into
  a starry night, a still mirror lake in the lower part, soft clouds at
  the horizon, a faint golden glow at the center of the upper third
  (where a small floating object will be placed later). Very calm, low
  detail in the bottom 55% because form fields will be placed there.
  No text.
  ```
- **Kabul:** Alt yarıda dikkat dağıtan detay yok; metin okunur.

**[P1-O2] Astrolab küre (karşılama kahramanı)**

- **Dosya:** `astrolab.png` (şeffaf) · 1024×1024
- **Nerede:** Karşılama ve "Seni tanıyalım" ekranının üstünde süzülür; yavaşça döner.
- **Animasyon:** Kod halkaları döndüreceği için iki katman iste:
  `astrolab_cekirdek.png` (ortadaki ışık kristali) ve `astrolab_halkalar.png`
  (çevredeki yörünge halkaları). Aynı tuval, aynı merkez.
- **Referans:** mockup `ee9545f3` 1. ekran (ortadaki küçük ışık kristali), `3e57eb6c`
- **İstem:**
  ```
  Two layers of the same object, each 1024x1024, transparent background,
  same center:
  1) Core: a small luminous crystal of light shaped like an elongated
     four-pointed star / almond, bright white-gold center fading to pale
     blue, tiny sparkles around it.
  2) Rings: three thin polished gold orbit rings tilted at different
     angles around that center (like an armillary sphere), each with one
     tiny gold bead, no core in the middle.
  ```

**[P1-O3] Cam küre katmanları (ışık dolumu)**

- **Dosya:** `kure_cam.png`, `kure_sivi.png`, `kure_cerceve.png` (hepsi şeffaf, 1024×1024)
- **Nerede:** "Kartın hazırlanıyor" (`calculating_screen.dart`). İlerleme
  arttıkça sıvı yükselir, dalgalanır, yıldızlar parlar.
- **Referans:** `9124e6e4`, mockup `ee9545f3` 2. ekran
- **İstem:**
  ```
  Three separate layers of the same glass orb as the attached image, each
  1024x1024 with transparent background, orb at exactly the same
  position and size (diameter 78% of the canvas, centered):
  1) Only the empty clear glass sphere: rim highlights, reflections,
     subtle refraction, otherwise see-through.
  2) Only the liquid light that fills the WHOLE sphere interior as a
     perfect circle: deep blue with tiny gold stars and swirling cyan
     light (no surface line, I will mask it).
  3) Only the thin gold orbit ring around the sphere with a small gold
     bead on top and bottom and short vertical light beams above and
     below.
  ```
- **Kabul:** Üçü üst üste konunca `9124e6e4`'e benziyor.

**[P1-O4] "Kartın hazır" kart yüzü**

- **Dosya:** `kart_hazir.png` (opak) · 1024×1536
- **Nerede:** Hesaplama bitince gösterilen kart (mockup `ee9545f3` 3. ekran),
  sonra ana ekrandaki karta Hero ile uçar.
- **Referans:** `38f451fb`, mockup 3. ekran
- **İstem:**
  ```
  Front of the same card as the attached card back (same dark marble,
  same gold border and corners), but in the middle there is a tall
  arched window cut into the card, through which you see a glowing gate
  of light and a tiny shining path on water; thin gold rays and small
  stars radiate from the top of the arch. Empty space at the bottom 12%
  (a word will be added in code). 1024x1536. No text.
  ```

#### P1-S — Paylaşım

Kod: `share/story_card.dart`, `share/arac_story_card.dart`. Mockup `9635f67f` 1. ekran.

**[P1-S1] Hikâye arka planları (3 tema)**

- **Dosya:** `paylasim_gece.png`, `paylasim_isik.png`, `paylasim_mor.png` (opak)
- **Boyut:** 1024×1536 (ben 1080×1920'ye uzatıp kırparım; önemli içerik ortada).
- **Nerede:** Kullanıcının Instagram hikâyesi kartı. Ortaya büyük skor,
  altına başlık, en alta "Kader" yazısı kodla gelir.
- **Referans:** `769f7a6f` (Gece), `2dca1663` (Işık), `51612667` (Mor)
- **Ortak istem:**
  ```
  Instagram story background, portrait 1024x1536, in the world of the
  attached reference. A grand arch frames the scene; the CENTRAL area
  (from 25% to 75% of the height, 15% to 85% of the width) is a calm,
  slightly darker open sky so large white numbers stay readable there.
  Bottom 15%: calm reflective water. No text. Theme:
  ```
  - Gece: `deep blue night, crescent moon upper right, silver-gold lanterns.`
  - Işık: `bright golden-white dawn light pouring through the arch, clouds.`
  - Mor: `violet and lavender nebula sky, pink-gold glow, calm.`
- **Kabul:** Ortaya beyaz 200 punto rakam koyunca okunuyor.

#### P1-P — Kader Profili

Kod: `profile/kader_profili_screen.dart`, `profile/dogum_haritasi_screen.dart`.

**[P1-P1] Profil başlık sahnesi**

- **Dosya:** `sahne_profil.png` (opak) · 1536×1024
- **Nerede:** Profil sekmesinin üst bandı (yaklaşık ilk 300 px), aşağı
  doğru zemine erir; avatar halkası ortaya gelir.
- **İstem:**
  ```
  Wide scene 1536x1024: a vast night sky with a huge faint golden zodiac
  ring (astrolabe-like circle with 12 small evenly spaced dots and thin
  engraved lines, NO zodiac glyphs, NO text) floating above a calm lake,
  arches at the far left and right edges. The center of the ring is
  empty (an avatar will be placed there). The bottom 30% fades into
  near-black navy. No text.
  ```

**[P1-P2] Büyük Üçlü madalyonları (Güneş, Ay, Yükselen)**

- **Dosya:** `madalyon_gunes.png`, `madalyon_ay.png`, `madalyon_yukselen.png`
  ya da tek ızgara `buyuk_uclu_seti.png` · her biri 512×512, şeffaf
- **Nerede:** Büyük Üçlü kartı (`BuyukUcluKarti`) ve doğum haritası bölüm başlıkları.
- **Referans:** `38f451fb` (madalyon dili)
- **İstem:**
  ```
  A matching set of three round antique-gold medallions, front view,
  same size and frame (thin double gold ring with tiny dots, dark blue
  marble inside), each with a raised polished gold emblem in the center:
  1) Sun: a sun disc with straight and wavy rays.
  2) Moon: a crescent moon with a tiny four-pointed star.
  3) Rising: a half sun rising over a horizon line with three short rays
     and a small upward chevron above.
  Transparent background, arranged side by side in one 1536x512 image,
  each medallion 460px wide, centered in its third. No text.
  ```

**[P1-P3] 12 burç madalyonu**

- **Dosya:** `burc_seti.png` (ben 12'ye kırparım → `burc_koc.png` … `burc_balik.png`)
- **Boyut:** 2048×1536 ızgara (4 sütun × 3 satır, her hücre 512×512), şeffaf.
- **Nerede:** Doğum haritası ekranı, Büyük Üçlü, paylaşım kartı, uyum ekranı.
- **Sıra (soldan sağa, yukarıdan aşağı):** Koç, Boğa, İkizler, Yengeç,
  Aslan, Başak, Terazi, Akrep, Yay, Oğlak, Kova, Balık.
- **İstem:**
  ```
  Twelve matching round antique-gold medallions in a 4x3 grid on a
  transparent background, 2048x1536, each centered in a 512x512 cell with
  8% padding. Same frame for all (thin double gold ring with tiny dots,
  deep blue marble disc), and in the center of each a raised polished
  gold classic astrological glyph, in this order left-to-right,
  top-to-bottom: Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra,
  Scorpio, Sagittarius, Capricorn, Aquarius, Pisces. Only the glyph, no
  animal drawings, no text.
  ```
- **Kabul:** Glifler doğru (özellikle Başak ♍ / Akrep ♏ karışmasın), 40 px'te okunuyor.

### P2 — İlk güncelleme

#### P2-R — Raporlar

**[P2-R1] Kişisel Yıl afişleri (9 adet)**

- **Dosya:** `yil_1.png` … `yil_9.png` (opak) · 1536×1024
- **Nerede:** Yıl raporu ekranı başlığı (`profile/yil_raporu_screen.dart`),
  ana ekrandaki tanıtım kartı (`profile/yil_raporu_karti.dart`). **Satışı
  doğrudan etkiler.** Sol %45 boş (yazı), sağda sahne.
- **Ortak istem başı:**
  ```
  Wide 1536x1024 banner in the world of the attached references. The LEFT
  45% is a calm dark starry sky over still water (text goes there). On
  the RIGHT, inside a softly glowing arch, this scene:
  ```

  | Dosya | Yıl | Sahne (istemin sonuna ekle) |
  |---|---|---|
  | `yil_1` | Tohum Yılı | `a single glowing seed sprouting a small luminous plant on a marble pedestal in the water, sunrise light behind the arch` |
  | `yil_2` | Sabır ve Ortaklık Yılı | `two crescent moons facing each other forming a bridge of light over the water, one star between them` |
  | `yil_3` | İfade ve Genişleme Yılı | `a blooming flower of light whose petals turn into sparkles spreading outward` |
  | `yil_4` | Temel Atma Yılı | `a stable stair of marble and gold blocks rising out of the water toward a steady star` |
  | `yil_5` | Değişim Yılı | `a golden paper plane gliding along swirling teal wind ribbons through an open gate` |
  | `yil_6` | Yuva ve Sorumluluk Yılı | `a small warm-lit pavilion on an island, a heart-shaped orbit of light around it` |
  | `yil_7` | İç Görü Yılı | `a perfectly still lake reflecting a crescent moon, one floating lantern, deep silence` |
  | `yil_8` | Hasat ve Güç Yılı | `golden wheat of light growing in a circle around an infinity-shaped glass ribbon` |
  | `yil_9` | Tamamlama Yılı | `a full golden circle closing on the horizon at sunset, leaves of light drifting away` |

**[P2-R2] Rapor kitabı (kilit ve numeroloji raporu)**

- **Dosya:** `rapor_kitap.png` (şeffaf) · 1024×1024
- **Nerede:** Rapor kilit penceresi (`premium/rapor_kilidi.dart`, şu an
  Material ikonu), numeroloji raporu başlığı, kilitli bölüm kartları.
- **İstem:**
  ```
  An ornate closed book with a deep blue marble cover, engraved gold
  corners and a gold compass-star clasp, standing slightly open with
  warm golden light and small sparkles escaping from between the pages.
  Three-quarter front view. Transparent background, PNG with alpha,
  1024x1024, 10% padding. No text on the cover.
  ```

**[P2-R3] Kilit amblemi**

- **Dosya:** `kilit.png` (şeffaf) · 512×512
- **Nerede:** Kilitli kategori karoları, kilitli rapor bölümleri (şu an Material kilit ikonu).
- **İstem:**
  ```
  A small ornate antique-gold padlock with a four-pointed star engraved
  on its body and a soft golden glow. Front view, transparent background,
  512x512, 10% padding.
  ```

#### P2-U — Uyum

Kod: `compatibility/uyum_screen.dart`, `uyum_sonuc_screen.dart`.

**[P2-U1] Uyum kahramanı / boş durum**

- **Dosya:** `uyum_bos.png` (şeffaf) · 1024×1024
- **İstem:**
  ```
  Two small glowing orbs of light (one gold, one lavender) on two thin
  intersecting gold orbit rings, a dotted line of light connecting them,
  a soft glow where the orbits cross. Transparent background, 1024x1024,
  lots of empty space. No people.
  ```

**[P2-U2] Uyum sonuç sahneleri (3 derece)**

- **Dosya:** `uyum_guclu.png`, `uyum_dengeli.png`, `uyum_gelistiren.png` (opak) · 1024×1536
- **Nerede:** Sonuç ekranının arka planı; dereceye göre değişir (`UyumDerecesi`).
- **Ortak istem:**
  ```
  Portrait 1024x1536 in the world of the attached references: two
  separate arches standing on a mirror lake, a bridge of light between
  them, the bottom 40% calm water. Mood:
  ```
  - Güçlü: `the bridge is complete and brilliant gold-teal, both arches glow strongly, sparkles everywhere.`
  - Dengeli: `the bridge is complete but soft amber, calm and steady.`
  - Geliştiren: `the bridge is still forming from floating stones of light, lavender glow, hopeful.`

#### P2-K — Keşfet

Kod: `tools/tools_screen.dart` (3 kart, şu an Material ikonları).

**[P2-K1] Araç kartı görselleri**

- **Dosya:** `arac_isim.png`, `arac_numara.png`, `arac_bebek.png` (opak) · 1536×1024
- **Nerede:** Keşfet sekmesindeki 3 kartın sağ yarısı (sol yarı yazı).
- **Ortak başlangıç:** `Wide 1536x1024, left 45% calm dark sky, on the right inside a small glowing arch:`
  - İsim: `a long ribbon of light with blank engraved gold plaques floating along it (no letters).`
  - Numara: `a constellation of glowing points connected in a 3x4 keypad-like grid pattern above the water (no digits).`
  - Bebek: `a crescent moon shaped like a cradle holding a tiny bright star, soft clouds.`

#### P2-C — Koleksiyon (yeni özellik; kararı bekliyor)

Mevcut 16 kart (`769f7a6f`, `2dca1663`, `51612667`, `4d82e7e6`, `7c2c7363`,
`acf7ed94`, `2013d9a4`, `d26a2f98`, `60899d22`, `cf13848c`, `ef40bb68`,
`a6162025`, `6a99dcf4`, `c240f848`, `e362e7d2`, `1c1ece02`) yeterli
başlangıç. Ek ihtiyaçlar:

**[P2-C1] Kart çerçeveleri (nadirlik)**

- **Dosya:** `cerceve_normal.png`, `cerceve_nadir.png` (şeffaf) · 1024×1536
- **İstem:**
  ```
  A card frame overlay, 1024x1536, transparent background, the whole
  inside (from 6% inset) is EMPTY/transparent. Rounded rectangle border.
  1) normal: thin double antique-gold border with small corner ornaments.
  2) rare: thicker glowing gold border with engraved filigree corners,
     a tiny four-pointed star at the top center and soft teal sparkles.
  ```

**[P2-C2] Ek kartlar** (koleksiyonu 24'e tamamlamak için 8 adet, 1024×1536, opak)
Ortak istem: `A collectible card illustration, portrait 1024x1536, in the exact style of the attached card images (arch frame, crescent moon, reflective water). Subject:`


| Dosya | Konu (istemin sonuna ekle) |
|---|---|
| `kart_acik_pencere` | `an open arched window with sheer curtains of light, a path on the water beyond it` |
| `kart_yuzen_fener` | `a single golden lantern floating on the lake, its reflection forming a light path` |
| `kart_kum_saati` | `a tall glass hourglass on a marble pedestal, glittering star dust falling inside` |
| `kart_altin_tuy` | `a single golden feather gliding down slowly through the air above the water` |
| `kart_cam_merdiven` | `a spiral staircase of glass and gold rising from the lake into the stars` |
| `kart_yildiz_cesmesi` | `a marble fountain whose water is made of tiny stars rising and falling` |
| `kart_ay_salincagi` | `an empty swing of gold chains hanging from the crescent moon over the lake` |
| `kart_pusula` | `an antique gold compass lying open on still water, its needle glowing` |

Mevcut 16 kartla çakışmaması için konular seçildi (köprü, patika, tohum,
uçan kâğıt, taşlar, sonsuzluk şeridi zaten var).

### P3 — İsteğe bağlı

| Kimlik | Dosya | Boyut | Nerede | Kısa istem |
|---|---|---|---|---|
| P3-1 | `ay_evreleri.png` (8'li ızgara, şeffaf) | 2048×1024 | "Neden bugün?" çipleri, numeroloji dönemleri | `Eight realistic glowing moon phases in a 4x2 grid (new, waxing crescent, first quarter, waxing gibbous, full, waning gibbous, last quarter, waning crescent), soft gold-white glow, transparent background, each centered in a 512x512 cell.` |
| P3-2 | `sahne_aksam.png` (opak) | 1024×1536 | Akşam geri bildirim kartı ve ekranı | `Same lake-and-arches world at dusk: last violet-amber light on the horizon, first stars, calm. Bottom 45% calm water.` |
| P3-3 | `mermer_doku.png` (opak, kenarları birleşen karo) | 1024×1024 | Kart/panel yüzeyleri | `Seamless tileable texture of very dark blue marble (#131A2E) with subtle thin white and gold veins, low contrast, flat lighting, no vignette.` |
| P3-4 | `hata_durumu.png` (şeffaf) | 1024×1024 | Hata/boş ekranlar | `A small cloud partly covering a crescent moon with a few sparkles, calm and friendly.` |
| P3-5 | `sayi_madalyonu.png` (şeffaf) | 1024×1024 | Numeroloji sayılarının çerçevesi (rakamı kod yazar) | `An empty round gold medallion frame with engraved rim and dark marble center, center completely empty.` |

---

## 5. Kalite kontrol listesi (her görselde)

- [ ] Yazı, harf, rakam, logo, filigran yok.
- [ ] İnsan, yüz, el, hayvan yok; tarot/kristal küre/fincan yok.
- [ ] Palet: lacivert + altın + (gerekiyorsa) tek vurgu rengi.
- [ ] Işık kaynağı sahnenin içinde; gölgeler lacivert, saf siyah değil.
- [ ] Tam ekran sahnede önemli öğeler ortadaki %66 genişlikte; üst %15 ve alt %40 sakin.
- [ ] Şeffaf istenen görsel gerçekten şeffaf (damalı desen çizilmemiş).
- [ ] Katmanlı öğelerde katmanlar aynı boyut ve konumda.
- [ ] İkon setlerinde tüm ikonlar aynı ağırlık ve boşlukta.
- [ ] Telefonda küçültünce (ikonlar 24–40 px) okunuyor.

---

## 6. Teslim ve durum tablosu

Çizdikçe "Durum" sütununu güncelle: `bekliyor` → `çizildi` → `bağlandı`
(bağlamayı ben yapıp işaretlerim).

| Kimlik | Dosya(lar) | Öncelik | Durum |
|---|---|---|---|
| — | `kart_arka_yuzu`, `sahne_kapali/yuksek/orta/dusuk` (mevcut görsellerden) | P1 | bağlandı |
| P1-B1 | `muhur`, `kart_arka_yuzu_muhursuz` | P1 | bağlandı |
| P1-B2 | `on_plan_sutunlar` | P1 | bağlandı |
| P1-B3 | `parilti` | P1 | bağlandı |
| P1-B4 | `sahne_orta_kapili` | P1 | bağlandı |
| P1-B5 | `kategori_seti` | P1 | bağlandı |
| P1-M1 | `ikon_sade.png` (yeni şeffaf sürüm) | P1 | bağlandı |
| P1-M2 | `assets/svg/bildirim_kapi.svg` (vektör kaynak) | P1 | bağlandı |
| P1-M3 | `play_ozellik` → `../luckApp_gorsel_kaynak/play_ozellik_1024x500.png` (mağaza, uygulamada yok) | P1 | hazır (Play Console'a Turan yükler) |
| P1-O1 | `sahne_onboarding` | P1 | bağlandı |
| P1-O2 | `astrolab_cekirdek`, `astrolab_halkalar` | P1 | bağlandı |
| P1-O3 | `kure_cam`, `kure_sivi`, `kure_cerceve` | P1 | bağlandı |
| P1-O4 | `kart_hazir` | P1 | bağlandı |
| P1-S1 | `paylasim_gece/isik/mor` | P1 | bağlandı |
| P1-P1 | `sahne_profil` | P1 | bağlandı |
| P1-P2 | `buyuk_uclu_seti` | P1 | bağlandı |
| P1-P3 | `burc_seti` | P1 | bağlandı |
| P2-R1 | `yil_1` … `yil_9` | P2 | bağlandı |
| P2-R2 | `rapor_kitap` | P2 | bağlandı |
| P2-R3 | `kilit` | P2 | bağlandı |
| P2-U1 | `uyum_bos` | P2 | bağlandı |
| P2-U2 | `uyum_guclu/dengeli/gelistiren` | P2 | bağlandı |
| P2-K1 | `arac_isim/numara/bebek` | P2 | bağlandı |
| P2-C1 | `cerceve_normal/nadir` | P2 | bağlandı |
| P2-C2 | 8 ek kart | P2 | bağlandı |
| P3-1…5 | ay evreleri, akşam, mermer doku, hata, sayı madalyonu | P3 | bağlandı |

### 3 Ekim 2026 üretim teslimi

- P1, P2, P3 ve koleksiyon ekleri: 54 PNG kaynak + 1 bildirim SVG kaynağı üretildi.
- PNG dosyaları `assets/images/`; bildirim kaynağı `assets/svg/bildirim_kapi.svg`.
- Toplu önizleme: `GORSEL_SETI.html`. Dosya araması ve koyu/açık/damalı zemin seçenekleri vardır.
- Son üretim istemleri, referanslar ve özgün çıktı yolları: `GORSEL_URETIM_ISTEMLERI.json`.
- Gerçek tuval ölçüleri ve örneklenmiş alfa kontrolü: `GORSEL_DOSYA_KONTROLU.json`.
- Kaynak PNG'ler küçültülmedi veya kırpılmadı. Üretici bazı kareleri 1254×1254 ve ızgaraları rehberdekinden farklı çözünürlükte verdi; gerçek ölçüler kontrol dosyasındadır. Küre ve astrolab katmanları kendi gruplarında aynı tuval boyutundadır.
- Alfa kanalları kontrol edildi. Önizlemelerde şeffaf piksellerin RGB rengi hale gibi görünebilir; alfa sıfır olduğunda bu renk görünmez.
- Telefon kırpımı, ikon ızgaralarının ayrılması, katman içeriğinin piksel düzeyinde hizalanması, mermer dokunun tekrar birleşimi ve 24–48 px/cihaz görünümü entegrasyonda doğrulanmalıdır. Bu kayıt bu kontrollerin yapıldığını iddia etmez.
- Durum yalnızca “çizildi”; yeni görseller uygulama ekranlarına bağlanmadı. Koleksiyon özelliği ve gezinme kararları değişmedi.
- Kontrol: `flutter analyze` → No issues found; `flutter test` → 351 test geçti.

### 3 Ekim 2026 entegrasyon (V2–V16)

- Tüm öğeler işlendi ve ekranlara bağlandı (ayrıntı: `GORSEL_YENILEME_PLANI.md`
  Bölüm 1 ve 3). Uygulamadaki dosyalar küçültülmüş JPEG/WebP'dir; özgün
  PNG'ler `../luckApp_gorsel_kaynak/` klasöründe (`GORSEL_SETI.html` oraya bakar).
- Izgaralar parçalandı: `kategori_<ad>.webp`, `madalyon_<gunes|ay|yukselen>.webp`,
  `burc_<burç>.webp` (12), `ay_evresi_<0-7>.webp`.
- Koleksiyon 24 kart: 8 yeni kart + Bölüm 4 P2-C'deki 16 eski kart
  (Codex klasöründen) `koleksiyon_<id>.jpg` olarak eklendi; `7c2c7363` kare
  olduğu için ortadan 2:3 kırpıldı.
- Kalite notları (yeniden çizim gerekmez, bilgi için): `kure_sivi` cama göre
  biraz büyük üretilmişti, kodda %93 ölçekle camın içine oturtuldu;
  `on_plan_sutunlar` telefonda kenarlardan taşacak genişlikte (×1,18) çizilir.
- Yeni görsel ihtiyacı yok. Ses (K3) kararı verilirse ses dosyaları için bu
  rehbere ayrı bölüm eklenmeli.
