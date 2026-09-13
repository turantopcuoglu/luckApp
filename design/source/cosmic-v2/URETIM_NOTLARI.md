# Kozmik tasarım sistemi V2 — 8 Eylül 2026

## Üretim ve kullanım

Üç yeni kart ailesi ve Premium illüstrasyonu yerleşik image_gen ile üretildi.
CLI/API fallback kullanılmadı. Eski görseller korundu; yeni sürümler aşağıdadır.
Logo mevcut SVG marka sisteminde kodla çizildi; piksel boyutları tek vektör
kaynağından Flutter ve projede zaten bulunan ikon/açılış araçlarıyla üretildi.

| Dosya | Kullanım |
| --- | --- |
| `assets/images/cosmic_sanctuary_v2.png` | <40: mor/bakır sığınak; kart, ana zemin, Story ve koleksiyon. |
| `assets/images/cosmic_observatory_v2.png` | 40–69: turkuaz gözlemevi; kart, zemin, Story; yardımcı sayfa atmosferi. |
| `assets/images/cosmic_portal_v1.png` | 70–91: mevcut altın kapı ailesi. |
| `assets/images/cosmic_celestial_v2.png` | >=92: radyal yıldız tacı; nadir görsel varyant. |
| `assets/images/cosmic_premium_v2.png` | Premium sayfasındaki anahtar ve kartlar; yalnız görsel. |
| `assets/svg/cosmic_mark_v2.svg` | Uygulama içi logo ve ikonların ana kaynağı. |
| `assets/launcher/cosmic-icon-v2.png` | 1024 px launcher/store ikon kaynağı. |
| `assets/launcher/cosmic-foreground-v2.png` | Saydam adaptive-icon ve splash katmanı. |

Bu eşleme yalnız genel skordan türeyen sunumdur. Kategori kilitleri, motor,
nadir işaret kazanma koşulları ve eski kayıtlar değiştirilmez. Kapalı kartın
zemini nötr kalır; sonucuna ait sahne ancak açılınca gösterilir.

## Gerçek arayüz

- Skorun arkasına yumuşak koyu kontrast alanı; etiketin arkasına %95 opak,
  altın çerçeveli levha kondu. Etiket beyazı en parlak zeminle bile AA testini geçer.
- Profil/ayarlar, Desenlerim giriş ekranı, geçmiş, kategori detayı, geri bildirim,
  koleksiyon ve Premium aynı kozmik yüzey ailesine taşındı. Geri/ayar/feedback
  davranışları korunur. Yardımcı sayfaların zemini statiktir.
- Her günlük karta Kapı, Yörünge, Hatıra olmak üzere üç Story yerleşimi uygulanır.
  Dört sahne ailesiyle 12 görsel kombinasyon vardır; her kayıt kendi tarihini ve
  skorunu taşır. Her gün için yeni yapay zekâ görseli üretilmez.
- Koleksiyon kartının detayından o güne ait Story düzenleyicisi açılır.
- PNG gerçek 1080×1920 tuvaldir. Görsel yüklenmeden yakalama yapılmaz; biten
  render ağacı ve ui.Image kaynakları serbest bırakılır. Kilitli sayılar/barlar
  paylaşım görseline girmez. Önizleme seçimi paylaşım başlatmaz.
- Story sabit baskı tuvalidir; uygulama yazı ölçeği resmi değiştirmez. Tasarım
  seçenekleri, düğmeler ve açıklamalar sistemin büyük yazı tercihine uyar.
- Paylaşım sistem menüsünü açar. Instagram'a otomatik Story gönderimi veya
  uygulama seçimi garantisi yoktur; paylaşım uygulamasının desteğine bağlıdır.
- Premium gerçek mağaza entegrasyonu içermediğinden fiyat/abonelik/başarılı
  ödeme taklidi yoktur. Durum bilgisi ve çalışan kartlara dönüş eylemi vardır.
- İsim önerisi ayrı belgede. İsim onayı verilmeden Kader metinleri / paket
  kimlikleri topluca değiştirilmedi.

## Önizlemeler ve yeniden üretim

`design/previews/v2/` altındaki `story-{34,55,86,95}-{portal,orbit,keepsake}.png`
dosyaları gerçek ShareService çıktılarıdır. Diğer PNG'ler Flutter ekranlarından
alınır. `design/previews/kader-cosmic-{low,high,rare}.png` okunaklı yeni ana
ekranları gösterir.

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/design/cosmic_v2_design_test.dart test/shared/cosmic_scene_test.dart
flutter test --no-pub --dart-define=KADER_EXPORT_BRAND=true test/brand/brand_asset_export_test.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

iOS 1024 ikon çıktısının PNG renk tipi 2 (RGB, alfa kanalı yok) doğrulandı.
Gerçek Android adaptive maskelemesi, iOS ikon/splash görünümü, fiziksel paylaşım
menüsü ve Instagram/WhatsApp kabulü cihazda kontrol edilmelidir. Mağaza
yayını, marka tescili, satın alma entegrasyonu veya FPS ölçümü yapılmadı.
PNG dağıtım sıkıştırması ve büyük bitmaplerin cihaz bellek ölçümü hâlâ gerekir.

## Tam görsel üretim promptları

### cosmic_sanctuary_v2

```text
Use case: stylized-concept. Production full-bleed portrait 1024x1536 environment artwork for a refined futuristic-spiritual daily card mobile app. Scene family SILENT SANCTUARY: a luminous rose-copper circular gateway inside a vast obsidian grotto, slender lavender quartz formations at sides, still mirror pool with concentric fine ripples, muted violet stardust sky. Sophisticated dimensional realistic cosmic fantasy materials, not flat illustration. The gate occupies 70 percent width, centered; DARK navy-black open negative space through its center for a large score overlay. Upper and lower edges fade smoothly to midnight navy #07162F. Intricate micro-etching in rose gold at sides, no major bright object in center; brightest scene details at outer sides and bottom quarter. Calm, kind, spectacular but restrained. No people, text, UI, numerals, cards, phone frames, moon faces or logos. Render a unique circular/cavern composition, NOT the existing pointed golden arch. Used both behind the daily card and as matching full-screen Story backdrop.
```

### cosmic_observatory_v2

```text
Use case: stylized-concept. Production full-bleed portrait 1024x1536 environment artwork for a refined futuristic-spiritual daily card mobile app. Scene family EQUILIBRIUM: a grand teal and silver celestial observatory with concentric delicate elliptical astrolabe rings suspended above calm midnight water, architectural twin pillars to far sides, precise geometric concentric floor engravings, a very distant luminous horizon. Dark midnight navy #07162F dominates. Center of rings from y20 to55 percent is DARK nearly empty negative space for a large real UI score, never paint text. Rich dimensional premium metallic surfaces, subtle blue-green atmospheric shafts at sides, tiny stars. No bright moon, no portal door panels, no card, no phone, no UI, no text or numerals. Seamless dark edge falloff. Original striking composition, balanced and serene, not flat vector. Middle lower horizon turquoise, restrained champagne rim highlights. Art must support white foreground typography.
```

### cosmic_celestial_v2

```text
Use case: stylized-concept. Production full-bleed portrait 1024x1536 environment artwork for a refined futuristic-spiritual daily card mobile app. Scene family CELESTIAL CROWN: a spectacular luminous golden sunburst halo high above a floating black marble stairway and a distant crystal celestial citadel. A crown of thin radiating gold architectural spires frames left/top/right, subtly iridescent violet and champagne dust, opulent but elegant, deep midnight navy #07162F, cinematic realistic 3D materials. Use a DISTINCT radial/sunburst composition versus a conventional pointed arch. Large central zone y22 to56 percent DARK empty starlit space for foreground UI score; no bright central orb. Bright accents at outer edges and below center. Lower third winding golden path toward citadel. Original exquisite detailed art; no typography, numerals, UI, phone, card panels, logos, people or zodiac symbols. Outer edge falloff navy, full bleed. Used as rare daily card art and a matching Story poster background.
```

### cosmic_premium_v2

```text
Use case: stylized-concept. Production full-bleed portrait 1024x1536 HERO ILLUSTRATION for the premium information page of a futuristic-spiritual daily reflection card app. A magnificent luminous golden celestial key with a four-point star bow floating above three slightly fanned obsidian cards with finely engraved champagne gold borders. Behind them an understated huge gold orbital ring and distant gilded cosmic pillars. Deep midnight navy #07162F, luxurious realistic etched metal, subtle cyan light and warm gold stardust. Composition main key and cards only in central 60 percent; upper and lower edges very dark to integrate with actual Flutter headings and panels. No crown on head, no people, no money, no promises, no phone frame, no app screenshot, no words, no numbers, no logos. Magical doorway to richer visual detail, refined and dimensional, no flat icon art.
```
