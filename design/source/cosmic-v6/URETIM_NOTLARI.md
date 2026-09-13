# Kozmik V6 — Tek parça sahne ve dokulu kategoriler
Tarih: 8 Eylül 2026.

## Son isteğin uygulanması

Kullanıcı V5'teki görsel alanının uygulamadan ayrı kaldığını ve kategori yüzeylerinin
referanstaki doygunluk/dokuya ulaşmadığını belirtti. V6 yalnız Bugün sahnesini ve
kategori malzemelerini değiştirir. Logo, ses, satın alma ve diğer sayfalar bu kapsamda değildir.

- Ana ekranın resmi artık bir hero kutusu değildir. TodaySceneStage, gerçek
  başlık ve kart geometrisini birlikte sarar. Tek çizim üst kenardan başlar,
  her iki yana tam genişlikte yayılır, hero sonundan 240 px aşağıya devam eder.
- Üstte/yanda maske, hero bittiği yerde clip veya kısa fade yoktur. En alttaki
  %16, diğer içeriğin altındaki lacivert zemine yavaşça karışır.
- Başlık, skor, kısa cümleler ve kategori kontrolleri gerçek Flutter metni ve
  dokunulabilir bileşenlerdir. Referansın örnek sayıları/adı üretime sabitlenmez.
- Açılışta ortak saat ve V5 koreografisi korunur. Kapalı ortam, yalnız nötr
  turkuaz ortama açılır. Kayıt başarıyla bitmeden gerçek skor rengi kullanılmaz.
  Lavanta sonuç sahnesi mevcut 700 ms giriş saati ile gelir.
- Kanatlar ve ışıklar Flutter katmanlarıdır; büyük mimari, su ve bazı ipek ışık
  ayrıntıları bitmap'te sabittir. Bu çalışma gerçek 3B/video dönüşümü iddiası değildir.
- Ana ekrandaki CardRevealMotion.showScene=false ve CosmicScoreHero.embeddedScene=true:
  ortak arka planın üzerine ikinci bir portal bitmap'i kurulmaz. Koleksiyondaki
  bağımsız skor görünümü V5'i kullanmaya devam eder.
- Kategori malzemeleri ayrı doygun pembe, altın, zümrüt, mavi ve bakır paletleridir.
  Işık kaynağı pastel beyaz örtü değil renkli alt yansımadır. 180 ince gren noktası,
  üç mineral damarı ve üst kenar yansıması kodla çizilir. Doku statiktir; beş ek
  animasyon saati veya bitmap eklenmez.
- Doku sadece kategori kimliği ve kartın açılma durumuna bağlıdır. Kilitli sayı,
  bar oranı ya da gizli veri malzeme bileşenine aktarılmaz. Kilitli/erişilebilir
  kutunun dokusunun gizli skora göre değişmesi yasaktır.
- Renk ayrımına ek olarak ad, sayı/kilit ve semantics vardır. Büyük yazıda kutular
  büyür ve iki sütuna geçer. Gerçek InkWell tepkisi ve 48 px dokunma alanı korunur.
- Skor motoru, seed, Hive şeması, kayıtlar, paylaşma ve gün sonu rotaları değişmedi.
  Yeni paket veya mağaza/ses entegrasyonu eklenmedi.

## Üretim varlıkları

| Dosya (assets/images/) | Boyut | Kullanım |
| --- | --- | --- |
| sanctuary_sealed_v6.png | 948×1659 | Kartın arkasındaki kapalı/nötr gece mimarisi; kart resmi içermez. |
| sanctuary_radiant_v6.png | 948×1659 | Başlıktan kategori alanına uzanan ışıklı turkuaz–altın ortam. |
| sanctuary_twilight_v6.png | 948×1660 | Aynı kapsamda aydınlık lavanta/rose-gold ortam. |

Üç dosya toplam 7.56 MB (ondalık dosya boyutu). Orijinaller silinmeden kopyalandı.
V5 resimleri bağımsız koleksiyon skorunda kullanıldığı için korundu.
pubspec yalnız adı belirtilen dosyaları paketler. V6 decoder genişliği cihaz
pikseline göre seçilir, gerçek 948 px kaynağı aşmaz. Ön yükleme üç sahneyi de
genel/kategori sonucu okumadan yapar.

## Kontrol kaydı

- flutter analyze --no-pub: temiz.
- flutter test --no-pub: 513 test başarılı.
- TR/EN, 320/390/430 px, 1×/2× yazı; kayıt/erişim maskesi, hareket azaltma,
  haptic, arka plan/sekme duraklatma ve etkileşim regresyonları.
- Gerçek AppShell geometrisinde sahnenin başlıktan önce başladığı, tam genişlikte
  olduğu ve hero sonundan 240 px öteye devam ettiği doğrulandı.
- Yeni malzeme testleri: beş farklı palet; aydınlık tabanda metin kontrastı >4.5;
  deterministik doku; kategori değişince farklı piksel; doku dokunmayı engellemez.
  Bu ölçüm kategori malzemesi içindir, tüm bitmap'in her pikseli için AA iddiası değildir.
- Gerçek widget görüntüleri: design/previews/v6/home-{closed,high,low}.png.
- Gerçek açılış örnek kaydı: design/previews/v6/reveal-motion.gif (20 fps QA çıktısı).
  Gerçek cihaz FPS/bellek testi yapılmadı; geliştirici cihaz kabulünde kontrol etmeli.
- Test olay kaydı: design/previews/v6/test-results.jsonl.
- Üretim varlıkları değiştiği için uygulamayı tam yeniden başlat.

## Üretim promptları ve araç

Imagegen becerisi; yerleşik image_gen aracı kullanıldı. Mod: generate / stylized-concept.
Üç ayrı çağrı, her çağrıda bir yeni bitmap. Referans mevcut ekranın düzenlenecek
hedefi değil, stil ve kompozisyon kılavuzudur. Sonraki bitmap rötuşu yapılmadı.
Kategori dokuları imagegen değil Flutter CustomPainter üretimidir.

Referans:
C:/Users/SUPERU~1/AppData/Local/Temp/codex-clipboard-acadd105-7d24-4e49-9af3-0d41696374b3.png

### sanctuary_radiant_v6

Kaynak çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-37f95a85-c5ca-4b59-ad6c-9f96d5f0cffc.png

Projedeki nihai dosya: assets/images/sanctuary_radiant_v6.png

Tam prompt:

Use case: stylized-concept. Image 1 is a STYLE/COMPOSITION REFERENCE, not an edit target. Produce ONE standalone FULL-PAGE mobile background illustration, portrait 1024x1792. Not a UI mockup or triptych: NO phone frames, NO interface panels, NO letters, numbers, icons, logos or text. Match the rich, cinematic celestial marble sanctuary in the reference. Critical composition: this is the continuous backdrop BEHIND the app's heading, central score and bottom category controls, not a square hero image. Pull camera back. Outer carved columns extend continuously along the full left and right edges, a huge vaulted arch extends over the top edge. At top center x25–75%, y0–20% keep deep navy starry negative space for heading. Main portal arch TOP exactly at y24%, door leaves extend y25–65%, threshold at y66%, detailed outer atmosphere continues all the way to edges. Quiet central space x35–65% y29–44% for live score typography, no objects or bright ribbons crossing it. A glowing distant river valley horizon at y52%, NOT giant centered moon. Flowing water and small star dust continue beneath threshold, but bottom y76–100% is low-detail deep midnight navy with fine textured mist and only faint scattered reflections, so actual colored category tiles and controls can overlay naturally. Never create a rectangular frame around the illustration; lighting flows through the entire canvas. Keep luminous threshold and edges BRIGHT and saturated, never muddy, gray, milky, or dim. Refined physically rendered fantasy materials and rich intricate detail. Match reference MIDDLE phone. Bright TURQUOISE/TEAL cosmos, warm champagne-gold illuminated portal and two visibly OPEN engraved obsidian-gold door leaves at x17–29% and x71–83%. Rich cyan light ribbons around outer sides at y30–65% and across threshold at y66–71%. Gold sparks and cool blue planets near far outer edges. Jewel-like color and luminous architecture, while top heading area and bottom controls area stay calm.

### sanctuary_twilight_v6

Kaynak çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-4643c18c-3f0f-49b4-9ead-b9635f40faf1.png

Projedeki nihai dosya: assets/images/sanctuary_twilight_v6.png

Tam prompt:

Use case: stylized-concept. Image 1 is a STYLE/COMPOSITION REFERENCE, not an edit target. Produce ONE standalone FULL-PAGE mobile background illustration, portrait 1024x1792. Not a UI mockup or triptych: NO phone frames, NO interface panels, NO letters, numbers, icons, logos or text. Match the rich, cinematic celestial marble sanctuary in the reference. Critical composition: this is the continuous backdrop BEHIND the app's heading, central score and bottom category controls, not a square hero image. Pull camera back. Outer carved columns extend continuously along the full left and right edges, a huge vaulted arch extends over the top edge. At top center x25–75%, y0–20% keep deep navy starry negative space for heading. Main portal arch TOP exactly at y24%, door leaves extend y25–65%, threshold at y66%, detailed outer atmosphere continues all the way to edges. Quiet central space x35–65% y29–44% for live score typography, no objects or bright ribbons crossing it. A glowing distant river valley horizon at y52%, NOT giant centered moon. Flowing water and small star dust continue beneath threshold, but bottom y76–100% is low-detail deep midnight navy with fine textured mist and only faint scattered reflections, so actual colored category tiles and controls can overlay naturally. Never create a rectangular frame around the illustration; lighting flows through the entire canvas. Keep luminous threshold and edges BRIGHT and saturated, never muddy, gray, milky, or dim. Refined physically rendered fantasy materials and rich intricate detail. Match reference RIGHT phone. Bright LAVENDER/PURPLE cosmos and ROSE-GOLD rounded portal with two visibly OPEN engraved lavender/rose-gold door leaves at x17–29% and x71–83%. Small planets at far outer edges. Translucent lavender silk light ribbons curve around sides at y30–65% and beneath threshold at y66–71%. Violet clouds, pink twilight horizon, welcoming luminous colors rather than gloom. Upper heading sky and bottom controls area remain deep navy-violet.

### sanctuary_sealed_v6

Kaynak çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-3fb4a097-6e9a-4325-a36a-5688fd0f21fb.png

Projedeki nihai dosya: assets/images/sanctuary_sealed_v6.png

Tam prompt:

Use case: stylized-concept. Image 1 is a STYLE/COMPOSITION REFERENCE, not an edit target. Produce ONE standalone FULL-PAGE mobile background illustration, portrait 1024x1792. Not a UI mockup or triptych: NO phone frames, NO interface panels, NO letters, numbers, icons, logos or text. Match the rich, cinematic celestial marble sanctuary in the reference. Critical composition: this is the continuous backdrop BEHIND the app's heading, central score and bottom category controls, not a square hero image. Pull camera back. Outer carved columns extend continuously along the full left and right edges, a huge vaulted arch extends over the top edge. At top center x25–75%, y0–20% keep deep navy starry negative space for heading. Main portal arch TOP exactly at y24%, door leaves extend y25–65%, threshold at y66%, detailed outer atmosphere continues all the way to edges. Quiet central space x35–65% y29–44% for live score typography, no objects or bright ribbons crossing it. A glowing distant river valley horizon at y52%, NOT giant centered moon. Flowing water and small star dust continue beneath threshold, but bottom y76–100% is low-detail deep midnight navy with fine textured mist and only faint scattered reflections, so actual colored category tiles and controls can overlay naturally. Never create a rectangular frame around the illustration; lighting flows through the entire canvas. Keep luminous threshold and edges BRIGHT and saturated, never muddy, gray, milky, or dim. Refined physically rendered fantasy materials and rich intricate detail. Match reference LEFT phone's ENVIRONMENT ONLY. A grand moonlit celestial blue-marble sanctuary with huge arch at the outer screen edges, luminous blue clouds, starry sky and reflective stone water floor. NO CARD, NO closed/open door leaves, NO seal and NO central portal ring: the physical card will be a separate real Flutter object at x25–75%, y22–65%. Leave that central rectangular area uncluttered starry cobalt space, continuous with the sky behind heading. Bright blue clouds curl along outside edges, subtle warm golden particles and reflections near the platform at y66%. Environment envelopes the entire screen. No empty black rectangular patch; no overlaid mockup card.
