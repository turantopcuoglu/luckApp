# Görsel Yenileme Planı ve Devir Notu

> **Yeni sohbete başlarken (Claude için):** Bu dosyayı, `CLAUDE.md`'yi ve
> gerekiyorsa `GORSEL_URETIM_REHBERI.md`'nin ilgili bölümünü oku. Sonra
> "Oturum sırası"nda işaretlenmemiş ilk uygun oturumu (görselleri hazırsa)
> yap. Oturum sonunda: ilgili kutuyu `[x]` yap, "Son durum" tablosunu ve
> `GORSEL_URETIM_REHBERI.md` Bölüm 6'daki durum tablosunu güncelle.
>
> **Turan için:** Yeni sohbette Bölüm 7'deki hazır komutu yapıştırman
> yeterli. Çizim yaptıracaksan `GORSEL_URETIM_REHBERI.md`'yi kullan.

İlgili dosyalar:
- `GORSEL_URETIM_REHBERI.md` — GPT'ye görsel ürettirme rehberi (stil, istemler, durum tablosu).
- `INGILIZCE_SURUM_PLANI.md` — paralel yürüyen i18n planı. Bu plandaki her
  yeni metin `*_strings.dart` dosyalarına yazılır ki i18n taşıması kolay olsun.
- `CIZIM_LISTESI.md` — ESKİ stil; yalnızca tarihçe.

---

## 1. Son durum

| Bilgi | Değer |
|---|---|
| Tarih | 3 Ekim 2026 |
| Son kod commit'i | `638cb17` Bugün ekranı: sahne arka planı ve kart açılış koreografisi (V1) |
| Testler | 351 test, tamamı yeşil |
| Analiz | `flutter analyze` → No issues found |
| Görsel durumu | Bugün ekranı yeni stilde. Diğer tüm ekranlar hâlâ düz lacivert zemin + Material ikonları. |

### Tamamlanan görsel işler

- **V1 — Bugün ekranı (daily_luck):** tam ekran yaşayan sahne arka planı,
  4 fazlı kart açılışı, skora göre 3 sahne, yeni kategori karoları,
  "Kartımı aç" butonu, erişilebilirlik ("hareketi azalt"), sekme gizliyken
  animasyonların durması. Ayrıntı Bölüm 3.

### Turan'ın bekleyen işleri

- [ ] V1'i emülatörde dene: kart açılışı akıcı mı (özellikle orta seviye
      Android), arka plan Ken Burns rahatsız ediyor mu, alt menüyle çakışma var mı.
- [ ] `GORSEL_URETIM_REHBERI.md` P1 görsellerini GPT ile çizdir.
- [ ] Bölüm 4'teki açık kararları ver (özellikle K1 gezinme, K2 Koleksiyon).

---

## 2. Tasarım sistemi

### 2.1 Görsel dil (özet; ayrıntı `GORSEL_URETIM_REHBERI.md` Bölüm 1)

- **Tek dünya:** ay ışıklı gece âlemi; kemerler, kapılar, mavi mermer,
  altın işleme, cam, yansıyan göl, ışık yolu.
- **İmza motif:** açılan kapı/kart = yeni gün. Ana ekranda kart ikiye
  ayrılıp kapıya dönüşüyor; aynı dil onboarding, paywall ve paylaşımda sürmeli.
- **Işık rengi anlam taşır:** turkuaz = yüksek gün (≥60), amber = dengeli
  (40–59), lavanta = yavaş gün (<40), altın = kullanıcı/ödül/premium.
- **Ekran düzeni:** üstte gökyüzü + başlık, ortada odak nesnesi (kart,
  küre, madalyon), altta sakin su üzerine oturan cam/mermer paneller.
- **Yasak:** fal çağrışımı (tarot, kristal küre falcısı, fincan, el),
  görselde yazı/rakam, insan/yüz.

### 2.2 Renk ve tipografi (kodda)

| Token | Değer | Yer |
|---|---|---|
| `AppColors.background` | `#0A0E1A` | zemin |
| `AppColors.surface` | `#131A2E` | panel |
| `AppColors.gold` / `goldAcik` | `#F4C95D` / `#FFE9B8` | vurgu, CTA gradyanı |
| `AppColors.purple` | `#8B7EC8` | ikincil |
| `AppColors.sahneYuksek/Orta/Dusuk` | `#6FE6DA` / `#FFD27A` / `#C3B2F5` | skor sahnesi ışıkları |
| `AppColors.kategori*` | pembe/altın/yeşil/mavi/turuncu | kategori karoları |
| `AppColors.isikCekirdegi` | `#FFF8E6` | ışık çekirdeği, kıvılcım |
| Başlık fontu | Playfair Display (`headlineMedium`, `displayLarge`) | `app_theme.dart` |
| Gövde fontu | Inter | `app_theme.dart` |

### 2.3 Hareket dili

| İlke | Uygulama |
|---|---|
| Tek zaman çizgisi | Bir ekrandaki büyük koreografi tek `AnimationController` (0→1) ile sürülür; fazlar `Interval` oranlarıyla bölünür, oranlar config'te. Arka plan, kart ve metinler aynı controller'ı dinler. |
| Tasarımdaki süreler | Kart açılışı: Mühür 0–250 ms, Işık 250–650, Açılış 650–1300, Yerleşme 1300–2000 (mockup `9f0eb26b`). Karolar: 120 ms aralıkla 350 ms flip. |
| Bekleme (idle) hareketi | Kapalı/bekleyen nesne nefes alır (süzülme ±4 px, parıltı nabzı, yörünge). Etkileşim başlayınca durdurulur (pil). |
| Arka plan | Ken Burns: 24 sn döngü, %6 yakınlaşma; yıldız parıltısı; kaydırınca koyulaşma. |
| Haptik | Dokunuş: `mediumImpact`; ana olay anı (kapı açılması): `lightImpact`. |
| Ses | Henüz yok (paket onayı bekliyor, K3). Tasarım: tok dokunuş → ışık yükselişi → yumuşak çan → sakin atmosfer. |
| Erişilebilirlik | `MediaQuery.disableAnimationsOf(context)` true ise: döngüler başlamaz, koreografi 300 ms'lik kısa geçişe iner. Gizlenen metinler `ExcludeSemantics` + `IgnorePointer`. |
| Pil | `IndexedStack`'teki sekmeler görünmezken `TickerMode(enabled: false)`. |
| Performans | Her animasyonlu katman `RepaintBoundary` içinde; görseller `precacheImage` ile önden çözülür; CustomPainter'larda rastgele değerler sabit tohumla bir kez üretilir. |

### 2.4 Bileşen kalıpları

- **Altın CTA:** hap şekli, `goldAcik → gold` gradyanı + altın hale gölgesi
  (`daily_luck_screen.dart` → `_AltinButon`). Başka ekranlarda gerekirse
  `shared/widgets`'a taşınmalı (V2).
- **Cam karo:** `surface` %55 opak + ince altın/kategori rengi kenar,
  `AppRadius.md` (`category_card.dart`).
- **Tam ekran sahne:** `SahneArkaPlani` (görsel + Ken Burns + yıldızlar +
  alt karartma + kaydırma karartması).

---

## 3. Teknik notlar (V1'de kurulanlar)

| Konu | Ayrıntı |
|---|---|
| Asset klasörü | `assets/images/` (pubspec'te kayıtlı, kullanıcı onayıyla). Opak sahneler JPEG (kalite 84), şeffaflar PNG kalacak. Yollar `lib/shared/widgets/app_images.dart` → `AppImages`. |
| Görsel boyutları | Tam ekran sahne ~948×1659 (~300 KB), kart 720×1080 (~270 KB). Telefon 3x ekran için yeterli. |
| Skor → sahne | `lib/features/daily_luck/skor_sahnesi.dart` → `SkorSahnesi.skordan(skor)`; eşikler `SkorBandi` (content) ile aynı. Testi: `test/daily_luck/skor_sahnesi_test.dart`. |
| Kart | `widgets/fortune_reveal_card.dart`: `FortuneRevealCard(acilis, arkaYuz, onYuz, onDokun, vurgu)`. Açılış controller'ı ebeveynde (`_IcerikState._kartKontrol`). Kart ≤ ışık fazında tek parça, sonra `OverflowBox` ile kırpılmış iki `_Kanat`. |
| Skor | `widgets/gunun_puani.dart`: count-up + ışık kemeri, şeffaf zemin. |
| Arka plan | `widgets/sahne_arka_plani.dart`: `SahneArkaPlani(acikSahne, gecis, kaydirma)` ve `SahneArkaPlani.kapali()`. Diğer ekranlar kullanacaksa önce `shared/widgets`'a taşınmalı (V2). |
| Sabitler | Tüm süre/oran/ölçüler `daily_luck_config.dart`'ta (kural 6). |
| Silinenler | `animated_score_ring.dart` (kart artık halka değil büyük rakam gösteriyor). `ScoreRing` hâlâ kategori detay ve uyum sonucunda kullanılıyor. |
| Eski SVG'ler | `AppIllustrations.kartArkaYuzu` ve `yildizDeseni` artık kullanılmıyor ama silinmedi (`app_icons.dart`); `kristalKure` paywall'da hâlâ var (V5'te kalkacak). |

### 3.1 Görsel işleme hattı (Windows, Python yok)

GPT'nin PNG'leri PowerShell + System.Drawing ile küçültülür. Opak sahneler
için (JPEG):

```powershell
Add-Type -AssemblyName System.Drawing
$enc = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object System.Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 84L
function Kaydet($kaynak, $hedef, $cx, $cy, $cw, $ch, $ow, $oh) {
  $img = [System.Drawing.Image]::FromFile($kaynak)
  if ($cw -eq 0) { $cw = $img.Width; $ch = $img.Height }
  $bmp = New-Object System.Drawing.Bitmap $ow, $oh
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0,0,$ow,$oh), (New-Object System.Drawing.Rectangle $cx,$cy,$cw,$ch), [System.Drawing.GraphicsUnit]::Pixel)
  $bmp.Save($hedef, $enc, $ep); $g.Dispose(); $bmp.Dispose(); $img.Dispose()
}
```

Şeffaf PNG'lerde `Bitmap` `[System.Drawing.Imaging.PixelFormat]::Format32bppArgb`
ile oluşturulur ve `ImageFormat::Png` ile kaydedilir; `$g.Clear([System.Drawing.Color]::Transparent)` unutulmasın.
Izgara setleri (burç, kategori) aynı fonksiyonla hücre hücre kırpılır.

### 3.2 Görsel doğrulama tekniği (emülatörsüz)

Animasyon kareleri geçici bir widget testiyle PNG'ye dökülür, sonra
PowerShell ile tek sayfada birleştirilip incelenir. Geçici dosya
`test/zz_onizleme_test.dart` olarak yazılır ve **iş bitince silinir**.
Kritik noktalar:

- Hive kutuları ve `put` çağrıları **`tester.runAsync` içinde** olmalı
  (FakeAsync içinde açılırsa test sonsuza kadar asılır).
- `tester.view.physicalSize = Size(1170, 2532); devicePixelRatio = 3`.
- Okunur yazı için `FontLoader('Roboto')` ile `C:\Windows\Fonts\segoeui.ttf` yükle; `ThemeData.dark()` kullan (GoogleFonts testte ağa çıkar).
- Görsellerin çözülmesi için `pumpWidget`'tan sonra `runAsync` içinde ~800 ms bekle.
- Kare almak: kökü `RepaintBoundary(key: anahtar)` ile sar; `runAsync` içinde `toImage(pixelRatio: 1)` → `toByteData(png)` → dosya.
- Material ikon fontu testte yok; ikonlar kare (□) görünür, normaldir.
- Çıktı klasörünü ortam değişkeniyle ver (`ONIZLEME_DIZINI`), scratchpad'e yaz; repoya PNG koyma.

---

## 4. Açık kararlar (Turan verecek)

| # | Karar | Seçenekler / not | Cevap |
|---|---|---|---|
| K1 | Alt gezinme | Mockup'lar 3 sekme gösteriyor (Bugün · Koleksiyon · Profil; Ayarlar profilin içinde). Şu an 5 sekme (Bugün, Profilim, Uyum, Keşfet, Ayarlar). Uyum ve Keşfet nereye gider? | |
| K2 | Koleksiyon özelliği | Her gün bir kart "kazanılır" (deterministik seçim, luck_engine + storage + UI = 3 oturum). Mevcut 16 kart görseli hazır. Yapılsın mı? | |
| K3 | Ses | `audioplayers` (ya da `just_audio`) paketi + 4 kısa ses (dokunuş, ışık, çan, ortam). Ses dosyalarını kim üretecek? | |
| K4 | Ayarlar'da "Ses / Titreşim / Hareketi azalt" anahtarları | Mockup'ta var. Uygulama içi "hareketi azalt" sistem ayarına ek olarak tutulsun mu? (storage alanı gerekir) | |
| K5 | Uygulama ikonu üretimi | `flutter_launcher_icons` (dev paketi, onay) ya da Claude elle mipmap PNG'leri üretir. | |
| K6 | Premium kahraman görseli | `2dca1663` (ışıklı kapı) mı, yeni çizim mi? | |

---

## 5. Oturum sırası

Her satır tek oturum (CLAUDE.md kural 1). "Görsel" sütunu, oturumdan önce
`assets/images/`'a konmuş olması gereken çizimleri gösterir
(`GORSEL_URETIM_REHBERI.md` kimlikleri). Görsel hazır değilse oturum
mevcut görsellerle yapılabilir ama sonra tekrar ele alınır.

- [x] **V1 — Bugün ekranı: sahne + kart açılışı** (daily_luck). Görsel: mevcut set.
- [ ] **V2 — Ortak sahne altyapısı** (shared). `SahneArkaPlani`, `_AltinButon`
      ve cam panel kalıbını `lib/shared/widgets/`'a taşı (genel API: görsel
      yolu, opsiyonel ön plan katmanı, karartma ayarları); daily_luck onları
      kullansın. Davranış değişmez, testler yeşil kalır. Görsel: yok.
- [ ] **V3 — Marka: uygulama ikonu + bildirim ikonu** (android/ios kaynakları
      + `feedback/notification_service.dart`). K5 kararı gerekir. Görsel:
      `784120f8`, `122a7f6e` (P1-M1); bildirim ikonunu Claude vektör çizer.
- [ ] **V4 — Bugün cilası** (daily_luck). Mühür ayrı katman: dokununca döner,
      ışık fazında ikiye çatlar; ön plan sütunları ile paralaks; parıltı
      sprite'lı kıvılcımlar; yeni kategori glifleri; orta sahne kapılı sürüm.
      Görsel: P1-B1…B5.
- [ ] **V5 — Premium + rapor kilidi** (premium). Paywall'ı mockup `9635f67f`
      4. ekrana göre yenile, kristal küreyi kaldır; rapor kilidinde kitap
      görseli. Görsel: K6, P2-R2, P2-R3.
- [ ] **V6 — Onboarding** (onboarding + legal/uyari ekranı görünümü).
      Mockup `ee9545f3`: sahne arka planı, dönen astrolab, ışıkla dolan küre +
      3 adımlı kontrol listesi, "Kartın hazır" kartı → ana ekran kartına Hero.
      Görsel: P1-O1…O4.
- [ ] **V7 — Paylaşım kartları** (share). 3 tema seçimi (Gece/Işık/Mor),
      "Skoru gizle" anahtarı (mockup `9635f67f` 1. ekran). Görsel: P1-S1.
- [ ] **V8 — Kader Profili + doğum haritası** (profile). Başlık sahnesi,
      Büyük Üçlü madalyonları, burç madalyonları. Görsel: P1-P1…P3.
- [ ] **V9 — Yıl raporu + numeroloji raporu** (profile). 9 yıl afişi, rapor
      kitabı, kilitli bölüm görünümü. Görsel: P2-R1…R3.
- [ ] **V10 — Uyum** (compatibility). Görsel: P2-U1, P2-U2.
- [ ] **V11 — Keşfet** (tools). Görsel: P2-K1.
- [ ] **V12 — Ayarlar + geri bildirim + kategori detay** (settings, feedback,
      categories): ortak sahne arka planı, akşam sahnesi. Görsel: P3-2.
- [ ] **V13 — Gezinme** (home). K1 kararına göre alt menü yeniden düzeni ve
      mockup'taki altın vurgulu menü stili.
- [ ] **V14–V16 — Koleksiyon** (K2 onayıyla): V14 luck_engine (günün kartı
      seçimi, deterministik, unit test), V15 storage (kazanılan kartlar),
      V16 UI (ızgara, kart detayı, nadirlik çerçevesi). Görsel: 16 mevcut kart, P2-C1, P2-C2.
- [ ] **V17 — Ses ve haptik** (K3 onayıyla).

---

## 6. Bozulmaması gerekenler

| # | Kural | Neden |
|---|---|---|
| G1 | Skor algoritmasına ve içerik seçimine görsel işler dokunmaz. Görsel seçimi (sahne, kart) yalnızca skordan ya da (kullanıcı, gün)'den **deterministik** türer. | CLAUDE.md kural 8 |
| G2 | Animasyonlar setState kullanmaz (lokal animasyon state hariç); büyük koreografinin controller'ı ekran state'inde, alt widget'lar `Animation` alır. | kural 5 |
| G3 | Tüm süre/oran/renk sabitleri config veya `AppColors`'ta. | kural 6 |
| G4 | Metinler `*_strings.dart`'ta (i18n planı). Görsellerde yazı yok. | INGILIZCE_SURUM_PLANI |
| G5 | "Hareketi azalt" yolu her yeni animasyonda çalışır ve test edilir. | erişilebilirlik |
| G6 | Testlerin beklediği akış: ana ekran testleri kartı açtıktan sonra ~3,6 sn pompalar (`kartiAc`: 2100 + 1500 + 500 ms). Açılış süresi uzarsa bu yardımcılar güncellenir (`daily_luck_screen_test.dart`, `categories_test.dart`). | |
| G7 | Fal çağrışımlı görsel yok (677 sayılı Kanun riski; konumlandırma "eğlence / kendini keşif"). | |

---

## 7. Hazır komutlar (yeni sohbete yapıştır)

**Ortak giriş:**

```
GORSEL_YENILEME_PLANI.md ve CLAUDE.md dosyalarını oku. "Tasarım sistemi" ve
"Bozulmaması gerekenler" bölümlerine uy. Sıradaki işaretlenmemiş oturumu
(ya da aşağıda söylediğimi) yap, yalnızca o oturumun kapsamında kal.
Görsel lazımsa GORSEL_URETIM_REHBERI.md'deki durumuna bak; yoksa bana söyle.
Sonunda flutter analyze + flutter test, animasyon varsa önizleme kareleriyle
görsel kontrol, kısa özet; plan dosyalarındaki kutuları ve durum tablolarını
güncelle. Commit'i ben isteyince at.
```

**Örnekler:**
- `Ortak giriş + "V2'yi yap."`
- `Ortak giriş + "P1-B1 ve P1-B3 çizildi, assets/images'a koydum. V4'ü yap."`
- `Ortak giriş + "K1: 3 sekme olsun, Uyum ve Keşfet Profil'in altına girsin. V13'ü yap."`
- Yeni görsel ihtiyacı doğarsa: `"GORSEL_URETIM_REHBERI.md'ye <ekran> için öğe ekle, istemleriyle."`

---

## 8. Tuzaklar (bu projede yaşandı)

- `dart format` klasöre toplu atılırsa dokunulmamış dosyalar yeni "tall"
  stile geçer ve diff şişer. Yalnızca yeni dosyaları formatla; yanlışlıkla
  biçimlenenleri `git checkout -- <dosya>` ile geri al.
- Widget testinde ekran 800×600: yeni ekran düzeninde aşağıda kalan öğelere
  dokunmadan önce `tester.ensureVisible(...)`.
- Testte sonsuz döngülü controller'lar varken `pumpAndSettle` asılır; ana
  ekranı içeren testlerde `pump(Duration)` kullan.
- Bash'te Türkçe karakterli `awk length` bayt sayar; satır uzunluğu için
  güvenilmez (lint zaten uzunluk denetlemiyor).
- Kiril harf karışması: md'lerde dosya adı yazarken dikkat (`URETIM`).

---

## 9. Hızlı başvuru

| Konu | Dosya |
|---|---|
| Ana ekran | `lib/features/daily_luck/daily_luck_screen.dart` |
| Kart koreografisi | `lib/features/daily_luck/widgets/fortune_reveal_card.dart` |
| Sahne arka planı | `lib/features/daily_luck/widgets/sahne_arka_plani.dart` |
| Skor gösterimi | `lib/features/daily_luck/widgets/gunun_puani.dart` |
| Ana ekran sabitleri | `lib/features/daily_luck/daily_luck_config.dart` |
| Renkler / tema | `lib/core/theme/app_colors.dart`, `app_theme.dart` |
| Görsel yolları | `lib/shared/widgets/app_images.dart` (raster), `app_icons.dart` (SVG) |
| Görseller | `assets/images/` |
| Mockup'lar | kaynak klasörde `42699425`, `9f0eb26b`, `ee9545f3`, `9635f67f` |
