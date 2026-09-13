# V3 — canlı ana sahne ve işlenmiş kozmik amblem

8 Eylül 2026. Kullanıcı V2 ana ekranını soluk, vektör logosunu fazla sade buldu.
Bu kayıt yalnız görsel sistemin bu düzeltmesini kapsar; isim/seed/erişim değişmedi.

## Solukluğun nedeni ve düzeltme

V2 CosmicBackdrop, görüntünün üzerine %62 (üst)–%80 (orta) lacivert perde koyuyordu.
Parlak altın ve turkuaz detaylar da aynı laciverte karıştığı için sahne düzleşiyordu.
Ana sayfada artık vivid görünümü kullanılır: nötr siyaha yakın, üst/ortada hafif,
en altta daha kuvvetli bir karartma. Kaynak sahneye doygunluk/renk değiştiren
filtre veya bulanıklık uygulanmaz. Yardımcı sayfaların mevcut sakin ayarı korunur.

Metin okunaklılığı tüm sahneyi söndürerek değil, yerel yüzeylerle sağlanır:

- Tarih/karşılama çevresinde küçük nötr gölge alanı.
- Skorun arkasında daha dar karartma; mevcut /100 ve etiket levhası korunur.
- Kısa yorumun arkasında ayrı koyu yüzey.
- Kategori kutularında transparan pastel renk yerine koyu taban ve renkli kenar.

Yüksek DPR'de ana sahne ve skor görseli 768 px'e zorlanmaz. İstenen piksel ölçüsü
1024 px kaynak genişliğiyle sınırlıdır. Arka planın cover hesabı ekran yüksekliğini
de dikkate alır: 390×844, DPR 1 için 563 px; DPR 3 için kaynak sınırı 1024 px.
Bu bir keskinleştirme efekti değil, gereksiz küçültüp büyütmeyi önleyen decode seçimidir.

## Logo ve dosyalar

| Dosya | Kullanım |
| --- | --- |
| assets/images/cosmic_mark_v3.png | 1254×1254 nihai opak üretim amblemi, uygulama içi logo. |
| assets/launcher/cosmic-icon-v3.png | 1024×1024 ikon kaynağı; küçük kenar boşluğu. |
| assets/launcher/cosmic-foreground-v3.png | Adaptive/splash için 1024 tuval, merkezde güvenli ölçek. |
| assets/svg/cosmic_mark_v2.svg | Önceki kaynak korunur, artık aktif logo değildir. |

İşlenmiş altın kapı, obsidyen/mavi mine, turkuaz kristal yıldız ve yörünge halkası.
Logo üzerinde metin yoktur; Kader/Nuvarya ad kararı bundan bağımsızdır.
Uygulama içi küçük amblem minimum 256 px kaynaktan medium filtreyle çizilir;
tüm kart havuzu değil yalnız kullanılan amblem çözülür.

Yerleşik image_gen kullanıldı; CLI/API fallback yok. İki çağrı:
1. Portal ve Premium görselleri yalnız malzeme/stil referansı olarak verildi.
2. İlk çıktı gerçek alfa yerine dama desenli RGB ürettiği için üretime alınmadı.
   İkinci çağrı arka planı koyu laciverte çevirdi. Nihai kaynak opaktır;
   şeffaf arka planlı bir logo diye tanımlanmamalıdır.
Native foreground dosyasında dış padding şeffaftır; amblem resmi kendi koyu zeminini taşır.

Native launcher/adaptive ve splash araçları çalıştırıldı. Foreground zaten
güvenli ölçekte paketlendiği için adaptive_icon_foreground_inset: 0 kullanılır.
Paket/applicationId/bundle ID, depolama ve kullanıcı verileri değişmedi.
Eski üretim kaynakları silinmedi. Native ikon/splash kaynakları yeni tasarımla güncellendi.

## Kontrol ve tekrar üretim

- flutter analyze --no-pub: temiz.
- flutter test --no-pub: 495 test.
- AA yerel metin kontrastı, vivid katmanın ışık kaybı, DPR/cover decode,
  logo dosyası/semantics, küçük ekran/büyük yazı ve skor gizliliği sınanır.
- design/previews/kader-cosmic-{low,balanced,high,rare}.png gerçek Flutter ekranları.
- design/previews/v2/profile.png yeni logonun gerçek uygulama içi görünümü.
- Fiziksel Android/iOS ekranı, ikon maskeleri ve FPS/bellek ölçümü geliştiricide.
  Yeni native ikonu görmek için yeniden derleme/yükleme gerekir; hot reload yetmez.

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/shared/cosmic_scene_test.dart
flutter test --no-pub --dart-define=KADER_EXPORT_BRAND=true test/brand/brand_asset_export_test.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Tam prompt — ilk amblem üretimi

```text
Use case: logo-brand.
Asset type: final production app emblem, square 1024x1024 transparent PNG, for a premium futuristic-spiritual daily card app.
Input images: Image 1 and Image 2 are STYLE REFERENCES ONLY: match their sculpted gold, obsidian, celestial lighting and rich premium 3D realism. Do NOT reproduce the full environment or key.
Primary request: a visually rich, memorable jewel-like COSMIC GATE SEAL, not a flat line logo. One front-facing dimensional emblem: a thick pointed golden portal enclosing a large floating four-point faceted champagne star with a bright cyan crystal heart. Deep blue-black enamel within the portal, fine restrained metallic engraving along broad beveled gold edges, a compact elliptical gold orbit passing behind the arch and in front of the lower base, a curved luminous gold path below the star. Strong bold silhouette, visual hierarchy: arch first, star second, orbit third. Opulent polished craftsmanship and clean crisp luminous edges; sapphire/teal inner reflections and concentrated warm gold specular glints. Rich darks and saturated light, not grey, washed-out or over-bloomed.
Composition: one centered emblem fully contained within central 62% of square, generous even TRANSPARENT padding on every side for adaptive app icon masks; main mark must still read clearly at 48 px. Tight controlled glow only next to the material, not a diffuse cloud. No tiny floating specks outside the emblem.
Background: genuinely transparent alpha outside the isolated emblem, NOT a checkerboard drawing, NOT white, no background plate or square.
Constraints: no words, letters, typography, numerals, watermark, people, eyes, zodiac signs, shields, crowns, extra objects, card deck or mockup. It must feel like a tangible celestial artifact from the reference artwork, while remaining an iconic logo rather than an entire scene.
```

## Tam prompt — nihai arka plan

```text
Use case: precise-object-edit.
Input image: edit target, a finished gold/teal cosmic gate emblem. KEEP THIS EXACT EMBLEM, engraved metalwork, geometry, orbit, star, gemstone, crispness and saturated colors.
Change ONLY the surrounding background: replace ALL the grey checkerboard outside the emblem (including enclosed gaps between the orbit and arch) with a perfectly clean, smooth deep midnight navy #020710. The result must be a normal OPAQUE square app-brand image, no checkerboard anywhere, no transparency simulation, no grey fringe. Keep the emblem complete and centered, slightly reduce its size only as needed to give a clean 8% navy margin from the highest and lowest points of the emblem to the square edges. Do NOT add a card border, rounded square, frame, scene, extra glow, text, watermark or objects. Preserve the intricate 3D gold artifact design exactly. Output a crisp high-resolution square production logo.
```

