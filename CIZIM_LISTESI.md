# Çizim Listesi (GPT ile üretilecek görseller)

Bu dosya, uygulamada çizilmesi gereken her görseli tek tek tarif eder:
nerede kullanılacağı (kod referansıyla), boyutu, biçimi, GPT'ye verilecek
İngilizce istem (prompt) ve kaçınılacak şeyler.

**Nasıl kullanılır:**

1. Önce **"Ortak stil rehberi"** bölümünü GPT'ye bir kez yapıştır ve
   "bundan sonraki tüm görsellerde bu stile uy" de.
2. **"Stil referansı"** satırında geçen eski SVG dosyaları basittir; GPT'ye
   yalnızca **yerleşim/kompozisyon fikri** olarak göster (tarayıcıda açıp
   ekran görüntüsü al), çizim kalitesini örnek alma. Asıl stil rehberi
   1. bölümdeki metindir. İlk beğendiğin P1 görselini sonraki görseller için
   stil referansı olarak yükle ki set tutarlı olsun.
3. Her öğe için istem metnini yapıştır, beğendiğin sonucu **"Dosya adı"**
   satırındaki adla kaydet.
4. Kaydettiğin görselleri koda bağlamak için yeni bir sohbette
   "CIZIM_LISTESI.md'deki P1 görsellerini koda bağla" demen yeterli. Bunun
   için bir `pubspec.yaml` asset satırı onayı gerekecek (aşağıda "Entegrasyon
   ön koşulları").

---

## 1. Ortak stil rehberi (GPT'ye ilk mesaj olarak ver)

```
You are designing assets for "Kader", a premium numerology & astrology
self-discovery app (dark, elegant, mystical but modern and minimal).

STYLE
- Fine gold line-art and subtle gold gradients on a deep navy night sky.
- Sacred-geometry feel: thin concentric circles, four-pointed stars,
  small dots, delicate filigree corners. Calm, luxurious, not cartoonish.
- Soft inner glow allowed; no heavy 3D, no photorealism, no clutter.
- Flat or near-flat shading. Clean edges suitable for small sizes.

COLOR PALETTE (use only these unless told otherwise)
- Background navy:   #0A0E1A
- Surface navy:      #131A2E
- Card purple:       #231C4E → #342A6E → #43317A (gradients)
- Gold (primary):    #F4C95D
- Light gold:        #FFE9B8
- Lavender accent:   #8B7EC8
- Text white:        #F2F3F7

RULES
- NO text, letters or numbers inside images unless explicitly requested
  (the app is translated into multiple languages).
- NO tarot cards, coffee cups, crystal-ball fortune tellers, palms,
  evil-eye beads, religious symbols, skulls, or occult/dark imagery.
- NO human faces (abstract silhouettes are OK only when stated).
- Keep important content inside the central safe area I give you.
```

> Neden "fal" görselleri yok: Uygulama "kendini keşif / eğlence" olarak
> konumlanıyor (Türkiye'de 677 sayılı Kanun riski). Kristal küre, tarot,
> kahve fincanı gibi fal çağrışımlı görseller bu konumlandırmayı zayıflatır.
> Mevcut boş durum ve paywall görseli bir kristal küre; aşağıda (P1-6)
> değiştirilmesi öneriliyor.

---

## 2. Teknik kurallar

| Konu | Kural |
|---|---|
| Biçim | PNG, **şeffaf arka plan** (aksi belirtilmedikçe), sRGB |
| Çözünürlük | Ekrandaki mantıksal boyutun **3 katı** (aşağıda her öğede piksel olarak yazılı) |
| Boyanabilir ikonlar | Tek renk (saf beyaz `#FFFFFF`) çizgi, şeffaf zemin. Uygulama bunları kodda altın/mor renge boyar. Gradyan ve ikinci renk kullanma. |
| Kenar boşluğu | İkonlarda çizimin etrafında %10 boşluk bırak |
| Kayıt yeri | `assets/png/` (yeni klasör; bkz. ön koşullar). Adlar küçük harf, Türkçe karakter yok, alt çizgili. |
| Vektör | GPT PNG üretir. Uygulamada mevcut ikonlar SVG'dir. Çok küçük gösterilen ikonlar (24 px) için PNG'yi bir vektörleştirme aracından (ör. vectorizer.ai, Inkscape "Bitmap izle") geçirip SVG olarak `assets/svg/` altına koymak daha keskin sonuç verir. |

### Entegrasyon ön koşulları (kodlama oturumunda onay istenecek)

- `pubspec.yaml` → `flutter: assets:` altına `- assets/png/` satırı.
- Uygulama ikonu için ya elle `android/app/src/main/res/mipmap-*` güncellemesi
  ya da `flutter_launcher_icons` geliştirme paketi (paket = onay).

---

## 3. Mevcut görseller: hepsi değiştirilecek

**Durum (3 Ekim 2026):** Uygulamada henüz hiçbir "gösterişli" görsel yok.
Telefondaki uygulama ikonu Flutter'ın varsayılan mavi logosu; uygulama
içindeki tüm görseller Session 4'te elle yazılmış basit SVG'ler. Aşağıdaki
tablodaki **her satır P1'de bir yeni görselle değiştirilir**; yayında eski
basit görsel kalmamalı. Eski SVG'leri GPT'ye yalnızca "kompozisyon fikri"
olarak göster; çizim kalitesini referans alma.

| Eski dosya | Ne | Boyut | Kullanıldığı yer | Yerine geçen |
|---|---|---|---|---|
| Flutter varsayılan ikonu (`android/app/src/main/res/mipmap-*/ic_launcher.png`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`) | Mavi Flutter logosu | — | Telefon ana ekranı, mağaza | **P1-1** |
| `assets/svg/app_icon_yonca.svg` | Yonca ikon taslağı | 512×512 | `onboarding/welcome_screen.dart:35` | **P1-1** |
| `assets/svg/kart_arka_yuzu.svg` | Kart arka yüzü: mor zemin, altın çerçeve, dört uçlu yıldız | 240×360 (2:3) | `daily_luck/daily_luck_screen.dart:429` | **P1-3** |
| `assets/svg/arka_plan_yildizlar.svg` | Soluk yıldız deseni karosu | 200×200 | `daily_luck/daily_luck_screen.dart:87,94` | **P1-9** |
| `assets/svg/bos_durum_kristal_kure.svg` | Line-art kristal küre | 120×120 | `premium/paywall_screen.dart:78` | **P1-6** |
| `assets/svg/kategori_*.svg` (kalp, para, yaprak, zar, sosyal) | Kategori ikonları, tek renk | 24×24 | `shared/widgets/app_icons.dart` → ana ekran kutuları, kategori detay | **P1-8** |
| Bildirim ikonu (launcher ikonu kullanılıyor) | — | — | `feedback/notification_service.dart:38` | **P1-2** |

Kod tarafında renkler: `lib/core/theme/app_colors.dart`. Yazı tipleri: başlıklar
Playfair Display, gövde Inter (`lib/core/theme/app_theme.dart`).

---

## 4. Öncelik 1 (yayından önce — 9 öğe, eski görsellerin tamamını değiştirir)

### P1-1 · Uygulama ikonu (mağaza + launcher)

- **Kullanım:** Play Store ikonu, telefon ana ekranı (`android/app/src/main/res/mipmap-*`,
  `AndroidManifest.xml:9`), karşılama ekranı (`welcome_screen.dart:35`).
- **Stil referansı:** `assets/svg/app_icon_yonca.svg`
- **Çıktılar:**
  1. `icon_store_512.png`: 512×512, **opak** (şeffaflık yok), köşeleri yuvarlatma (Play kendisi yuvarlatır).
  2. `icon_adaptive_foreground.png`: 1024×1024 şeffaf. Çizim yalnızca ortadaki
     **%61'lik daire** (≈ 624 px çap) içinde olmalı.
  3. `icon_adaptive_background.png`: 1024×1024 opak, sade zemin.
- **İstem:**
  ```
  App icon for "Kader". A single elegant four-leaf clover formed by four
  thin gold (#F4C95D) heart-shaped leaves, each leaf containing a tiny
  four-pointed star; a thin gold circle behind it with 8 small dots.
  Deep navy (#0A0E1A) to purple (#231C4E) radial background with a very
  faint starfield. Centered, bold enough to read at 48 px. No text.
  ```
- **Kaçın:** İnce detayın 48 px'te kaybolması, metin, kenara taşan öğeler.

### P1-2 · Bildirim küçük ikonu (Android)

- **Neden önemli:** Bildirimler şu an launcher ikonunu kullanıyor
  (`feedback/notification_service.dart:38`). Android'de renkli ikon bildirim
  çubuğunda **beyaz kare** görünür.
- **Çıktı:** `ic_notification.png`, 96×96, saf beyaz siluet, şeffaf zemin, gradyan yok.
- **İstem:**
  ```
  Android notification status-bar icon: a simple solid white silhouette of
  a four-leaf clover with a small four-pointed star in the center.
  Transparent background, flat, no gradients, no thin lines (minimum
  stroke 6 px at 96 px), centered with 8 px padding.
  ```

### P1-3 · Kader kartı arka yüzü

- **Kullanım:** Ana ekrandaki kapalı kart (`daily_luck_screen.dart:422-433`,
  `_KapaliKartYuzu`). Ekranda 220×330 (`DailyLuckConfig.kartGenisligi/Yuksekligi`).
- **Stil referansı:** `assets/svg/kart_arka_yuzu.svg`
- **Çıktı:** `kart_arka_yuzu.png`, **720×1080** (2:3), opak, köşeler düz (kod yuvarlatıyor).
- **İstem:**
  ```
  Back side of a mystical playing card, portrait 2:3. Deep purple gradient
  (#342A6E top-left to #231C4E bottom-right). Gold (#F4C95D) double thin
  border inset 24 px, ornate filigree in the four corners, and at the
  center a four-pointed star inside two concentric thin circles surrounded
  by a ring of 12 small dots. Small diamond accents at top and bottom
  center. Subtle gold glow around the central star. Symmetric, no text.
  ```
- **Kaçın:** Tarot kartı görünümü (figür, arkana), yazı.

### P1-4 · Büyük Üçlü simgeleri (Güneş, Ay, Yükselen)

- **Kullanım:** Kader Profili > Büyük Üçlü kartı, üç sütunun başlığı
  (`profile/dogum_haritasi_screen.dart`, `BuyukUcluKarti`). Ekranda 28×28.
- **Çıktı:** `simge_gunes.png`, `simge_ay.png`, `simge_yukselen.png`; her biri
  **168×168**, beyaz çizgi, şeffaf (boyanabilir ikon kuralı).
- **İstem (üçü aynı sette):**
  ```
  A matching set of three minimal line icons, white strokes on transparent
  background, consistent 6 px stroke at 168 px, rounded caps:
  1) Sun: a small circle with 8 short rays.
  2) Moon: a crescent moon with one tiny star beside it.
  3) Rising: a half sun emerging above a horizon line with a small upward
     arrow above it.
  Same visual weight and padding for all three. No text.
  ```

### P1-5 · 12 burç simgesi

- **Kullanım:** Doğum haritası ekranındaki Güneş/Ay/Yükselen bölüm başlıkları
  ve Büyük Üçlü kartındaki burç adlarının yanı (`dogum_haritasi_screen.dart`),
  ileride paylaşım kartı. Ekranda 32×32 ve 64×64.
- **Çıktı:** 12 dosya, her biri **192×192**, beyaz çizgi, şeffaf. Dosya adları
  koddaki `Burc` enum adlarıyla aynı:
  `burc_koc.png, burc_boga.png, burc_ikizler.png, burc_yengec.png,
  burc_aslan.png, burc_basak.png, burc_terazi.png, burc_akrep.png,
  burc_yay.png, burc_oglak.png, burc_kova.png, burc_balik.png`
- **İstem:**
  ```
  A consistent set of 12 zodiac glyph icons (Aries, Taurus, Gemini,
  Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn, Aquarius,
  Pisces). Each is the classic astrological glyph drawn as an elegant
  single-weight white line (6 px at 192 px) inside a thin white circle,
  with one tiny four-pointed star accent at the top of the circle.
  Transparent background, identical framing and stroke weight across all
  12. Deliver as 12 separate square images. No animal illustrations, no
  text.
  ```
- **Not:** GPT 12'yi tek görselde verirse, her birini ayrı kare olarak kırp.

### P1-6 · Paywall ve rapor kilidi görseli (kristal kürenin yerine)

- **Kullanım:** Premium sayfasının üstü (`premium/paywall_screen.dart:78`,
  şu an `AppIllustrations.kristalKure`), rapor kilit penceresi
  (`premium/rapor_kilidi.dart`, şu an Material ikonu).
- **Çıktı:** `premium_kahraman.png`, **720×480** (3:2), şeffaf.
- **İstem:**
  ```
  Hero illustration for a premium upgrade screen: an open book seen from
  the front whose pages release a gentle stream of small gold numbers-like
  dots and four-pointed stars rising into a circular orbit of thin gold
  rings; a crescent moon and a small sun sit on the outer ring. Gold
  (#F4C95D, #FFE9B8) line-art with soft glow, lavender (#8B7EC8) accents,
  transparent background, centered, generous empty space around. No text,
  no actual digits.
  ```

### P1-7 · Keşfet araç simgeleri

- **Kullanım:** Keşfet sekmesindeki üç kart (`tools/tools_screen.dart`, şu an
  `Icons.badge_outlined`, `Icons.dialpad_rounded`, `Icons.child_care_rounded`).
  Ekranda 28×28.
- **Çıktı:** `arac_isim.png`, `arac_numara.png`, `arac_bebek.png`; her biri
  **168×168**, beyaz çizgi, şeffaf.
- **İstem:**
  ```
  A matching set of three minimal line icons, white 6 px strokes on
  transparent background (168 px), rounded caps, same weight as a modern
  outline icon set:
  1) Name analysis: a name tag / label shape with a small four-pointed
     star in its corner.
  2) Number analysis: a smartphone outline with a small keypad grid of
     dots and a tiny star above it.
  3) Baby name: a small crescent moon cradling a tiny star, with a soft
     ribbon below.
  No text, no digits.
  ```

### P1-8 · Kategori ikonları (5 adet)

- **Kullanım:** Ana ekrandaki beş kategori kutusu ve kategori detay sayfası
  (`shared/widgets/app_icons.dart` → `daily_luck/widgets/category_card.dart`,
  `categories/category_detail_screen.dart`). Ekranda 24-40 px; kod altın renge boyar.
- **Çıktı:** `kategori_ask.png`, `kategori_para.png`, `kategori_saglik.png`,
  `kategori_risk.png`, `kategori_sosyal.png`; her biri **192×192**, beyaz
  çizgi, şeffaf (boyanabilir ikon kuralı). Küçük boyut için vektörleştirilmesi önerilir.
- **İstem:**
  ```
  A matching set of five premium minimal line icons, white 6 px strokes on
  transparent background (192 px), rounded caps, each with one tiny
  four-pointed star accent:
  1) Love: a heart formed by two gently curved lines meeting at the bottom.
  2) Money: three stacked coins seen at a slight angle.
  3) Health: a single leaf with a central vein and a small sprout.
  4) Risk/decisions: a die showing three pips, tilted 15 degrees.
  5) Social: two overlapping circles like two people's auras.
  Same visual weight and padding for all five. No text.
  ```

### P1-9 · Ana ekran yıldız deseni

- **Kullanım:** Ana ekranın sol üst ve sağ alt köşelerindeki soluk desen
  (`daily_luck/daily_luck_screen.dart:87,94`, `AppIllustrations.yildizDeseni`).
  Ekranda 200×200, çok düşük opaklıkla.
- **Çıktı:** `yildiz_deseni.png`, **600×600**, şeffaf, yalnızca altın ve beyaz.
- **İstem:**
  ```
  Decorative corner ornament for a dark app background: a delicate cluster
  of tiny four-pointed stars of different sizes, small dots, and two thin
  partial gold (#F4C95D) orbit arcs, arranged loosely toward one corner
  and fading out toward the opposite corner. Transparent background, very
  fine lines, elegant and sparse, about 30 elements total. No text.
  ```
- **Not:** Kod bu görseli düşük opaklıkla (yaklaşık %6-10) çizer; görselin
  kendisi tam opak olabilir.

---

## 5. Öncelik 2 (yayından sonra ilk güncelleme)

### P2-1 · Kişisel Yıl Raporu afişleri (9 adet)

- **Kullanım:** Yıl raporu ekranının başlığı (`profile/yil_raporu_screen.dart`,
  `_YilBasligi`) ve ana ekrandaki tanıtım kartı (`profile/yil_raporu_karti.dart`).
  Her kişisel yıl sayısı için bir afiş. Bu görsel satışı doğrudan etkiler.
- **Çıktı:** 9 dosya, her biri **1200×600** (2:1), opak navy zemin, sağ yarıda
  çizim; sol yarı boş kalacak (kod oraya yazı koyacak).
  `yil_1.png … yil_9.png`
- **Ortak istem başı:**
  ```
  Wide 2:1 banner, deep navy (#0A0E1A) background with faint stars. Keep
  the LEFT HALF empty (text will be placed there). In the RIGHT HALF draw
  a single gold (#F4C95D) line-art scene with soft glow, lavender
  (#8B7EC8) accents. No text, no digits. Theme:
  ```
- **Temalar (istem başının sonuna ekle):**

  | Dosya | Yılın adı (uygulamada) | Tema |
  |---|---|---|
  | `yil_1.png` | Tohum Yılı | `a single seed sprouting a small plant with a four-pointed star above it, sunrise rays behind` |
  | `yil_2.png` | Sabır ve Ortaklık Yılı | `two crescent moons facing each other forming a gentle bridge, a small star between them` |
  | `yil_3.png` | İfade ve Genişleme Yılı | `a blooming flower whose petals turn into small stars and musical-like curves spreading outward` |
  | `yil_4.png` | Temel Atma Yılı | `a stable geometric foundation of stacked stones forming a small arch, with a steady star above` |
  | `yil_5.png` | Değişim Yılı | `a winding path with a paper-plane-like bird flying along swirling wind lines toward a star` |
  | `yil_6.png` | Yuva ve Sorumluluk Yılı | `a small house outline embraced by a heart-shaped orbit, warm light in the window` |
  | `yil_7.png` | İç Görü Yılı | `a calm lake reflecting a crescent moon, a single lantern-like star above, deep stillness` |
  | `yil_8.png` | Hasat ve Güç Yılı | `golden wheat stalks forming a circle around an infinity-like orbit, abundant but elegant` |
  | `yil_9.png` | Tamamlama Yılı | `a full circle orbit completing with a sunset on the horizon and leaves gently drifting away` |

### P2-2 · Paylaşım kartı arka planları

- **Kullanım:** Günün kartı (`share/story_card.dart`) ve Keşfet sonuç kartı
  (`share/arac_story_card.dart`). Şu an kodla çizilen mor gradyan
  (`ShareConfig.gradyanRenkleri`).
- **Çıktı:** `paylasim_arka_gunluk.png` ve `paylasim_arka_kesfet.png`, **1080×1920**, opak.
- **İstem:**
  ```
  Instagram story background 1080x1920. Diagonal gradient from #0A0E1A
  (top-left) through #231C4E to #43317A (bottom-right). Very subtle
  starfield and thin gold (#F4C95D, 15% opacity) sacred-geometry circles
  near the top-right and bottom-left corners only. The central area
  (from y=300 to y=1600) must stay calm and nearly empty for large text
  and numbers. No text.
  ```

### P2-3 · Karşılama (onboarding) görseli

- **Kullanım:** Karşılama ekranı (`onboarding/welcome_screen.dart`), şu an
  ikon gösteriliyor.
- **Çıktı:** `karsilama.png`, **1080×1080**, şeffaf.
- **İstem:**
  ```
  Welcome illustration: a large thin gold circle like an astrolabe with
  the 12 zodiac glyph positions marked by tiny dots (no glyphs), a
  four-pointed star at the center, a crescent moon and a small sun on the
  ring, delicate lavender orbit lines. Transparent background, centered,
  calm and elegant. No text.
  ```

### P2-4 · Boş durum görseli (Uyum, Keşfet)

- **Kullanım:** Uyum sekmesinde kayıtlı kişi yokken (`compatibility/uyum_screen.dart`,
  `UyumStrings.bosDurum` metninin üstü).
- **Çıktı:** `bos_durum_uyum.png`, **480×480**, şeffaf.
- **İstem:**
  ```
  Empty-state illustration: two small four-pointed stars on two
  intersecting thin gold orbits, a dotted line connecting them, lavender
  glow at the intersection. Minimal, lots of empty space, transparent
  background. No text, no people.
  ```

### P2-5 · Numeroloji raporu dönem simgeleri (4 adet)

- **Kullanım:** Numeroloji raporundaki "Hayatının dört dönemi" zaman çizelgesi
  (`profile/numeroloji_raporu_screen.dart`, `_DonemSatiri`). Şu an daire içinde sayı.
- **Çıktı:** `donem_1.png … donem_4.png`, **144×144**, beyaz çizgi, şeffaf.
- **İstem:**
  ```
  A matching set of four minimal line icons (white 5 px strokes, 144 px,
  transparent) showing the four seasons of life as moon phases inside a
  thin circle: 1) new crescent, 2) first quarter, 3) full moon,
  4) waning gibbous with a small star. Identical framing. No text.
  ```

---

## 6. Öncelik 3 (isteğe bağlı)

| ID | Dosya | Boyut | Kullanım | Kısa istem |
|---|---|---|---|---|
| P3-2 | `play_ozellik_grafigi.png` | 1024×500 opak | Play Store öne çıkan görsel | `Store feature graphic: left 40% empty navy for title, right side shows the gold four-leaf clover app emblem over a softly glowing astrolabe ring; no text.` |
| P3-3 | `ay_evresi_*.png` (8) | 96×96 beyaz | "Neden bugün?" çiplerine ay evresi simgesi (`daily_luck/widgets/neden_cipleri.dart`) | `Eight moon phase icons (new, waxing crescent, first quarter, waxing gibbous, full, waning gibbous, last quarter, waning crescent), white, flat, transparent.` |

---

## 7. Teslim kontrol listesi

- [ ] Her dosya bu listedeki adla ve boyutla kaydedildi.
- [ ] Boyanabilir ikonlar (P1-4, P1-5, P1-7, P1-8, P2-5, P3-3) **tek renk beyaz** ve şeffaf.
- [ ] Bölüm 3 tablosundaki her eski görselin yerine yenisi hazır (yayında eski basit görsel yok).
- [ ] Hiçbir görselde yazı/rakam yok (P1-1 dahil).
- [ ] Fal çağrışımlı öğe yok (tarot, fincan, kristal küre, el).
- [ ] 48 px'e küçültüldüğünde ikon hâlâ okunuyor (P1-1, P1-2).
- [ ] Görseller `assets/png/` altına kondu; koda bağlama için yeni sohbette
      "CIZIM_LISTESI.md P1 görsellerini bağla" denecek.
