# Kozmik V4 — Referansa dönüş / üretim notları

Tarih: 8 Eylül 2026. Bu kayıt V2/V3'ün üst üste büyük sahne, ağır altın amblem
ve üç farklı Story yerleşimi kararlarını geçersiz kılar. Kullanıcının son isteği
önceliklidir; referanstaki örnek ad/tarih/skor/ödül sayısı uygulama verisi değildir.

## Referansın yorumu

- Bir ekran, bir görsel odak: merkezde kart, dışta sakin gece. Aynı kapı görselini
  ayrıca tam ekran arka plana basma.
- İnce şampanya çizgiler, sedef/cam ve mavi gece; ağır altın geometrik rozet yok.
- Yazılar bitmap'e gömülü değil. Skor, tarih, kart adı ve kısa cümle gerçek metin.
- Kanatlar ayrı fiziksel yarımlar, dış kenarlardan menteşeli. Sonuçta yok olmazlar.
- Panolar durağandır. Hareket karakteri ve zaman aralıkları yorumlanarak kodlandı;
  “aynı video”, gerçek cihaz 60/120 fps veya ölçülmüş performans iddiası yok.

## Uygulama eşlemesi

| Dosya (assets/images/) | Kullanım |
| --- | --- |
| quiet_night_v4.png | Ortak sakin gece zemini. Ana ekranda hafif, formlarda daha koyu. |
| moon_path_v4.png | Açılan kanatların arkasındaki ay/dağ/ışıklı yol; iki eksende kenar yumuşatma. |
| glass_orb_v4.png | Hazırlıkta fiziksel cam kırılması; dolum, dalgalar ve ilerleme kodla çizilir. |
| story_night_v4.png | Gece paylaşımı ve ikincil sayfa başlıkları. |
| story_light_v4.png | Işık paylaşımı ve Premium hero. |
| story_violet_v4.png | Mor paylaşımı. |
| cosmic_mark_v4.png | Tam kare opak marka sahnesi; uygulama içi logo, launcher ve splash. |
| rare_*_v4.png (12 dosya) | Gerçek koşullarla açılan koleksiyon sahneleri. |

12 nadir dosyanın kimlikleri:
- assets/images/rare_acik_kapi_v4.png
- assets/images/rare_kesisen_yollar_v4.png
- assets/images/rare_sessiz_tohum_v4.png
- assets/images/rare_ucan_not_v4.png
- assets/images/rare_dengeli_tas_v4.png
- assets/images/rare_yeni_patika_v4.png
- assets/images/rare_geri_donen_serit_v4.png
- assets/images/rare_kucuk_kopru_v4.png
- assets/images/rare_acik_pencere_v4.png
- assets/images/rare_beklenmedik_durak_v4.png
- assets/images/rare_yan_yana_izler_v4.png
- assets/images/rare_parlak_yol_v4.png

- AppIllustrations.rareSignAssets tek eşleme kaynağıdır; eski WebP kaynakları silinmedi.
- İlk 17 dikey sahne 1024×1536; logo 1254×1254, cam küre 1254×1254.
- 19 yeni PNG master toplamı 46.24 MB (sıkıştırılmış dosya boyutları).
  Görsel kaliteyi düşüren bir dönüşüm uygulanmadı. Yayın öncesi WebP/AVIF adayları
  gerçek cihazda kalite/bellek ölçümü ile ayrı karşılaştırılmalı.
- pubspec kök images klasörünü toptan almaz; aktif dosyaları açık listeler.
  Eski deneysel PNG'ler diskte korunur, yeni pakete otomatik eklenmez.
- DPR/cover hesabı ve thumbnail çözme bütçeleri korunur. Galeri SliverGrid ile lazily
  kurulur; kayıtlı günler ayrı “Günlük kartların” rotasında durur.

## Hareket sözleşmesi

| Süre | Aşama | Davranış |
| --- | --- | --- |
| 0–250 ms | Mühür | Küçük kontrollü basma/nabız; aynı kapalı geometriye geri döner. |
| 250–650 ms | Işık | Ortada alttan üste ilerleyen ince camgöbeği/şampanya ışık. |
| 650–1300 ms | Açılış | İki dış menteşe; easeInOutCubic; kontrollü eliptik ışık ve 12 parçacık. |
| 1300–2000 ms | Yerleşme | Kapı sabit görünür; yalnız skor/metin/eylem katmanı fade ile gelir. |

Kalıcı yazım yavaşsa sonuç girişinden önce ek bekleme vardır. Sonuç, kayıt başarılı
olmadan görünmez. Aynı günün önceden açılmış kartı hareket/yazım/haptic tekrarlamaz.
Skor motoruna, seed'e, kayıt şemasına ve premium yetki algoritmasına dokunulmadı.

- RevealFrame saf ve test edilebilir; zaman örnekleri 1 ms aralıklarla süreklilik kontrolü alır.
- Atmosfer 18 saniyelik düşük yoğunluklu döngü. Dış zemin .18, odak sahne .55 yoğunluk.
  Büyük sinüs şeritleri kaldırıldı; az sayıdaki yıldız ve yerel ışık korunur.
- Hazırlık 1600 ms görsel ritüel: cam bitmap sabit, ışık hacmi ve ilerleme kodla dolar.
  Kaydetme tamamlanmadan %100 başarı yanılsaması göstermez; bilimsel analiz değildir.
- TickerMode, uygulama arka planı ve sistem hareket azaltma tercihi gözetilir.
- Haptic mühür ve sonuçta birer kez; arka planda sonuç titreşimi yok.
  Yeni ses motoru veya ses kaydı eklenmedi. Referansın çan/atmosfer sesleri ayrı
  cihaz/izin/tercih ve entegrasyon çalışmasıdır; sahte ses anahtarı çizilmedi.

## Ekran davranışları

- Story: korunmuş enum kimlikleri portal/orbit/keepsake → Gece/Işık/Mor.
  Önizleme ile 1080×1920 dışa aktarım aynı sahne ve veriyi kullanır.
  “Skorları gizle” bütün sayısal skorları (genel + kategoriler) metin ve semantics'ten
  kaldırır. Yetkisiz kategori değerleri hiçbir zaman sızmaz.
- Koleksiyon: patternsSummaryProvider'ın gerçek RareSignProgress kanıtları.
  Sayaç sabit 5/12 değildir. Doğrulanmamış paylaşım, Uçan Not ödülü sayılmaz.
  Kilitli karta dokunmak açıklama/ilerleme gösterir; ücret karşılığı rastgele ödül yok.
- Profil: kompakt baş harf avatarı, mevcut ad/doğum tarihi, ince Premium bandı,
  çalışan isim/dil/bildirim/saat denetimleri. Büyük dekoratif hero kaldırıldı.
- Premium: tek yumuşak ışık kapısı ve mevcut gerçek yetki durumu. Mağaza bağlı değil;
  sahte fiyat, plan satın alma veya restore başarısı eklenmedi.
- Ürün adı halen Kader. Nuvarya onaysız öneridir. Paket/bundle kimlikleri değişmedi.

## Üretim ve kontrol

Görsel oluşturma yöntemi: yerleşik imagegen aracı, kullanıcının panoları görsel
referans verilerek yeni yazısız üretim bitmap'leri. Orijinaller generated_images
alanında bırakıldı; sonuçlar projeye kopyalandı. Vektör/painter efektler Flutter
kodudur. Hiçbir telefon mockup'ı uygulamaya ekran görüntüsü olarak yapıştırılmadı.

Native kaynaklar:
- assets/launcher/cosmic-icon-v4.png
- assets/launcher/cosmic-foreground-v4.png
- flutter_launcher_icons ve flutter_native_splash ile Android/iOS kaynakları üretildi.
- Native ikon değişikliği hot reload ile görünmez; yeniden derleme/kurulum gerekir.
  Yuvarlak/squircle launcher maskeleri ve Android 12 splash cihazda kontrol edilmeli.

Kontrol çıktıları:
- design/previews/v4/reveal-motion.gif — gerçek widget ağacı, 20 fps inceleme kopyası.
- design/previews/v4/preparation-motion.gif — gerçek dolum widget'ı, 20 fps inceleme kopyası.
- design/previews/v4/reveal-{0,250,650,1000,1300,2000}ms.png
- design/previews/v4/rare-art-contact.png — 12 çizimin birlikte kontrolü.
- design/previews/v4/{collection,profile,premium,story-designer}.png
- design/previews/v4/story-{34,55,86,95}-{portal,orbit,keepsake}.png
- design/previews/kader-cosmic-{low,balanced,high,rare}.png
- design/previews/kader-preparing.png

GIF 20 fps, uygulamanın hedef/ölçülen fps'si değildir. GIF paleti PNG'den sınırlıdır.
Önizlemeler örnek test profilidir; kullanıcı verileri değiştirilmedi.
Gerçek cihazdaki kare süreleri, GPU/bellek, ses ve mağaza kabulü ayrıca yapılmalıdır.

Komutlar:
```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test test/daily_luck/reveal_motion_test.dart --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens
flutter test test/onboarding/onboarding_design_test.dart --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens
flutter test test/design/cosmic_v2_design_test.dart test/design/cosmic_v4_motion_test.dart --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens
flutter test test/brand/brand_asset_export_test.dart --dart-define=KADER_EXPORT_BRAND=true
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Tam üretim promptları

### quiet_night_v4

Referans: exec-9f0eb26b-e679-47f4-bffb-cae175387d8c.png

```text
Use case: stylized-concept. Production portrait 1024x1536 background only for the app in the reference: deeply restful blue-black starry night, very sparse small stars, soft moonlit clouds ONLY at left/right lower edges and gently reflective still water in bottom 25%. The center and upper half are clean midnight negative space. Match the soft silver-blue realism and restrained champagne accents of the reference. NO architecture, arch, doors, planet, orb, logo, lines, rings, bright star at center, text, UI, phone frame or panels. This goes behind real UI and an independently animated central card. Full bleed; dark corners. Rich clear navy, not fog over everything.
```

### moon_path_v4

Referans: exec-9f0eb26b-e679-47f4-bffb-cae175387d8c.png

```text
Use case: stylized-concept. Production portrait 1024x1536 environment layer for the OPEN CENTER in panel 4 of the reference. Recreate the calm silver-blue cosmic water, distant low mountains and beautiful thin winding champagne-white path of light across water toward a sunrise horizon. A huge translucent celestial moon low behind the distant mountains at y62%, dark clear midnight star field in UPPER 55% for actual UI score. Soft clouds at far sides only. Elegant, soothing, high clarity, slight champagne glow. NO architectural arch or door leaves (we render those separately), NO text, score, UI, phone frame, card border, glyph or radial sunburst. Full bleed, no huge bright central sun; sides and top blend smoothly into deep navy.
```

### story_night_v4

Referans: exec-9635f67f-3977-4415-b63c-760f67907348.png

```text
Use case: stylized-concept. Production 1024x1536 portrait illustration ONLY matching the LEFT share card in the reference. A refined rounded silver-blue stone arch, delicate champagne rim accents, softly moonlit climbing leaves and two small side lanterns, peaceful dark blue lake and distant mountains, a small crescent high to the right inside the arch, crisp tiny stars. Center y25–55% is dark unobstructed starry sky reserved for real typography; bottom has softly reflective blue stone steps. Match the reference composition and softness very closely; no extraneous props. No actual words, numerals, logo, phone, controls or UI. Full bleed, no extra outer card frame. Mostly navy and moonlight, only 10% warm gold accents.
```

### story_light_v4

Referans: exec-9635f67f-3977-4415-b63c-760f67907348.png

```text
Use case: stylized-concept. Production portrait 1024x1536 environment artwork, matching the PREMIUM gate / light sharing card in the reference. Elegant softly luminous rounded champagne stone gateway with restrained fine engraving, calm pale blue cloud sea, white-gold winding walkway into distant sky, moonlike planets at far sides. Blue shadowed foliage at outer edges. Soft luxurious cinematic illumination, NOT glaring yellow gold, not gilded black treasure or key. The gate fills center, top 25% deep navy, middle is airy blue with clear darker space for actual score; softly reflecting water/stone bottom. No text, numbers, UI, phone frame, card deck, key or logo. Full bleed. This illustration is also the premium hero.
```

### story_violet_v4

Referans: exec-9635f67f-3977-4415-b63c-760f67907348.png

```text
Use case: stylized-concept. Portrait 1024x1536 production illustration matching the PURPLE sharing thumbnail in the reference. Same refined rounded stone gateway, peaceful lake and distant mountains as the night card, but lit by soft lilac and rose-violet starlight with cool silver arch edging, two restrained champagne lanterns. Beautiful violet celestial atmosphere, a small moon at upper right, reflected narrow path on still water. Center y25–55% is unobstructed DARK navy-violet sky for real score text. Mostly deep night blue, restrained violet light, no saturated hot neon and no yellow-gold armor. Full bleed. No text, UI, score, phone, outer card frame, logo, crown or extra props.
```

### cosmic_mark_v4

Referans: exec-9635f67f-3977-4415-b63c-760f67907348.png

```text
Use case: logo-brand. Final square full-bleed app icon artwork 1024x1024 inspired by the reference app's soft blue celestial atmosphere. The ENTIRE SQUARE is the design, with rich midnight-to-sapphire-blue luminous cloud/glass texture flowing edge to edge. One bold silky pearl-silver CRESCENT cradling a small soft champagne four-point star, centered slightly above center, with a subtle reflected ribbon of moonlight below, as if a quiet moon above a lake. Smooth sculptural glass/pearl depth, polished app-brand sophistication, soft diffusion at edges but clearly readable moon silhouette at 48px. Blue is dominant; champagne/gold UNDER 8 percent. Composition fills the square, symbol occupies central 60%, no inset black rectangle, no empty margin around a separate medallion. It should belong naturally to this soft night app. NO ornate arch, shield, filigree, orbit ring, sharp jewel, chunky gold metal, lettering, phone mockup, rounded outer corners, border, watermark or UI. OPAQUE edge-to-edge square, no transparency.
```

### rare_acik_kapi_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one beautifully open rounded moonlit doorway onto a distant illuminated path. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_kesisen_yollar_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: two elegant moonlit stone bridges crossing above still blue water. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_sessiz_tohum_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one delicate luminous green sprout with three translucent leaves growing from a seed inside a glass bell dome, crystals at its base. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_ucan_not_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one folded pearl-gold paper airplane hovering over still water, narrow subtle starlight trail. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_dengeli_tas_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: five smooth blue-grey river stones balanced vertically with a tiny warm glint, mirrored in water. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_yeni_patika_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: a quiet winding narrow stone path among moonlit dark blue mountains toward one distant doorway. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_geri_donen_serit_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one flowing silk silver-blue ribbon tracing an elegant returning loop over water. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_kucuk_kopru_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one small curved moonlit stone footbridge connecting two mossy banks. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_acik_pencere_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one open tall arched silver-blue window with a distant blue moon and calm clouds. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_beklenmedik_durak_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one peaceful empty stone bench beside a small lantern and a still moonlit pool. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_yan_yana_izler_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: two parallel softly luminous trails on wet dark sand leading toward a gentle horizon. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### rare_parlak_yol_v4

```text
Use case: stylized-concept. A single final production collectible-card illustration, portrait 1024x1536. Recreate the exquisite soft realistic 3D celestial style of the collectible gallery in the supplied reference, especially its glass-dome seed card. Subject: one narrow luminous champagne path crossing a midnight lake toward a soft rising star. ONE clear large focal object, serene sapphire and midnight blue setting, fine restrained champagne edge lights, soft silver-blue clouds, a few tiny stars, subtle rounded stone architectural frame at far sides, foreground water reflections. Rich dimensional materials, high detail but calm uncluttered composition. Not flat vector, not collage, not excessive gold. Subject is centered in upper-middle so it survives a landscape hero crop and portrait thumbnail. Full bleed with deep navy bottom edge for real UI caption. NO words, numbers, UI, phone, grid, badge, border overlay, zodiac icons, faces, watermark. Return just the single illustration, not the reference contact sheet.
```

### glass_orb_v4

```text
Create a SINGLE PRODUCTION BITMAP ASSET for a Flutter loading animation, inspired by the glass orb in the CENTER phone of this reference board. NOT a phone mockup, NOT a storyboard, NOT a UI. Square 1024x1024 canvas. One stunning, realistically rendered three-dimensional celestial glass sphere, perfectly centered at (512,512) with radius 405 px. Very dark midnight navy (#061428) quiet exterior seamlessly fading to uniform dark navy at canvas corners. Sphere interior deep midnight transparent glass with many randomly scattered tiny warm-white and cool-white pinprick stars in varied depths, subtle cosmic dust, beautiful subtle curved refractions, brilliant thin pearl-white and icy-cyan layered refractive rim. Restrained champagne highlights ONLY on small parts of the rim. Match the magic and physical glossy glass depth of the reference's center sphere. IMPORTANT this is an EMPTY glass volume for a CODE-ANIMATED rising liquid surface, so NO water level, NO horizontal waves, NO spiral, NO bright central object, NO liquid fill. No external orbital ellipses, no surrounding metal rings, no pedestal, no reflection below sphere, no architecture or clouds outside the sphere. These elements are drawn in real time in Flutter. The orb must occupy exactly the central ~80 percent width and height, circular and symmetrical. Premium cinematic otherworldly refined, not flat vector gradient, not a plastic ball. NO letters, logos, captions, borders, progress bars, watermark.
```
