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
| Son kod commit'i | `626910c` (V2–V16 entegrasyonu henüz commit'lenmedi; Turan isteyince atılacak) |
| Testler | 377 test, tamamı yeşil (+26: koleksiyon motoru, deposu ve ekranları, görsel yolları, paylaşım temaları) |
| Analiz | `flutter analyze` → No issues found |
| Görsel durumu | Tüm ekranlar yeni stilde. Üretilen 54 PNG + 16 eski koleksiyon kartı işlenip bağlandı (V1–V16). V17 (ses) K3 kararı bekliyor. |

### Tamamlanan görsel işler

- **V1 — Bugün ekranı (daily_luck):** tam ekran yaşayan sahne arka planı,
  4 fazlı kart açılışı, skora göre 3 sahne, yeni kategori karoları,
  "Kartımı aç" butonu, erişilebilirlik ("hareketi azalt"), sekme gizliyken
  animasyonların durması. Ayrıntı Bölüm 3.
- **3 Ekim 2026, tek oturumda V2–V16** (Turan "hepsine başla" dedi; kural 1
  bilinçli olarak esnetildi, her V adımı ayrı doğrulandı):
  - **Görsel işleme:** 122 MB kaynak PNG → 12 MB (opak JPEG q82–84, şeffaf
    WebP). Izgaralar parçalandı (5 kategori glifi, 3 Büyük Üçlü, 12 burç,
    8 ay evresi). Kaynaklar depo dışında: `../luckApp_gorsel_kaynak/`.
  - **V2** ortak altyapı `lib/shared/widgets/`: `SahneArkaPlani` (+ ön plan
    paralaksı, sprite yıldızlar), `SahneliZemin`, `AltinButon`, `CamPanel`,
    `GorselBant`, `GorselAfis`, `KilitAmblemi`, `HataGorunumu`,
    `PariltiSprite`, sabitler `SahneConfig`. Kartlar tema üzerinden cam
    stile geçti (`AppColors.camYuzey/camKenar`).
  - **V3** uygulama ikonu (`ikon_sade`): Android eski tip + uyarlanabilir
    ikon, iOS AppIcon seti; bildirim simgesi `ic_stat_kader` (vektör);
    Android açılış ekranı lacivert + amblem (beyaz parlama yok).
  - **V4** mühür ayrı katman (salınır, nefes alır, dokununca döner, kanatlarla
    ikiye bölünür), ön plan sütunları paralaksı, parıltı sprite'lı kıvılcım
    ve yıldızlar, yeni kategori glifleri, orta skor için kapılı sahne.
  - **V5** paywall (açık altın kapı sahnesi, yan yana planlar, altın CTA,
    "Premium, şans puanını değiştirmez"), kilit amblemi, rapor kilidinde kitap.
  - **V6** onboarding: ortak sahne, dönen astrolab, ışıkla dolan küre +
    3 adımlı liste, "Kartın hazır" → "Kartıma geç" (kart Hero ile ana
    ekrandaki karta uçar); uyarı ekranı aynı sahnede.
  - **V7** "Kartını paylaş" ekranı: canlı önizleme, Gece/Işık/Mor tema,
    "Skoru gizle"; hikâye kartı tema görselli (off-screen için görsel önden
    çözülür), Keşfet kartı da gece temalı.
  - **V8** profil başlık bandı + baş harfli avatar, burç madalyonu,
    Büyük Üçlü madalyonları, sayı madalyonu karoları, harita başlığı.
  - **V9** yıl afişi (rapor başlığı + ana ekran kartı), numeroloji raporunda
    kitap başlığı ve ay evreli dönem çizelgesi.
  - **V10** uyum: iki yörüngeli kahraman görsel, kişi listesinde burç
    madalyonu, sonuç ekranında dereceye göre köprü sahnesi.
  - **V11** Keşfet: üç araç afiş kartı.
  - **V12** ayarlar/kategori detay sahneli zemin, akşam geri bildirimi akşam
    sahnesinde (ana ekrandaki akşam kartı da), hata görünümü, "Neden bugün?"
    ay evresi çipinde günün ayı.
  - **V13** gezinme: 5 sekme korundu (K1), altın vurgulu yeni alt çubuk,
    görünmeyen sekmelerin animasyonları `TickerMode` ile durur.
  - **V14–V16** Koleksiyon (K2): motor `gununKarti` (tekrarsız 24 günlük döngü
    + 1/8 nadir), `KoleksiyonRepository` (app_state kutusu, `koleksiyon`
    anahtarı), koleksiyon ekranı, kart detayı, ana ekranda "Bugünün kartı",
    profilde özet. Kart açılınca o günün kartı koleksiyona katılır.

### Turan'ın bekleyen işleri

- [ ] Emülatör/cihaz turu: Bugün açılışı (mühür, sütun paralaksı), onboarding
      dolumu + Hero, paylaşım PNG'si (3 tema, skoru gizle), uyarlanabilir
      ikon (yuvarlak/kare maske), bildirim simgesi, açılış ekranı.
- [ ] Orta seviye Android'de akıcılık: sahne arka planları her sekmede
      Ken Burns döndürüyor (gizli sekmeler durur); takılma olursa bildir.
- [ ] Play Console: öne çıkan görsel `../luckApp_gorsel_kaynak/play_ozellik_1024x500.png`.
- [ ] iOS açılış ekranı (LaunchScreen.storyboard) hâlâ varsayılan; Xcode'da
      lacivert zemin + amblem yapılmalı.
- [ ] K3 (ses) ve K4 (Ayarlar'da ses/titreşim/hareket anahtarları) kararları.
- [ ] Bu oturumun commit'i (istendiğinde).

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

Hepsi `lib/shared/widgets/`'ta; sabitleri `SahneConfig`'te.

| Bileşen | Ne zaman |
|---|---|
| `AltinButon(metin, onPressed, genislik?, basIkon?, sonIkon?)` | Ekranın ana eylemi. `genislik: null` tam genişlik; `onPressed: null` pasif. İçinde `FilledButton` var (testler `find.byType(FilledButton)` ile bulabilir). |
| `CamPanel(child, mermer?, bulanik?, onTap?)` | Sahne üstünde özel panel. İçine ListTile konabilir (şeffaf Material sarar). Sıradan `Card`'lar da tema sayesinde cam görünür. |
| `SahneArkaPlani(gorsel, acikGorsel?, gecis?, kaydirma?, onPlan?, altKarartma…, hizalama?)` | Tam ekran yaşayan zemin. `onPlan: AppImages.onPlanSutunlar` paralaks sütunlar (yalnız Bugün). |
| `SahneliZemin(gorsel, child, altKarartma…)` | Sahne + üstünde şeffaf Material'lı içerik; liste ekranları için kısa yol. Yoğun metinde `SahneConfig.yogunKarartma*`, uzun listede `listeKarartma*`. |
| `GorselBant(gorsel, child?)` | Üstte zemine eriyen yatay bant (profil). |
| `GorselAfis(gorsel, child, yukseklik?)` | "Sol %45 yazı, sağda sahne" afiş/kart (yıl afişi, Keşfet). |
| `KilitAmblemi(boyut)` | Her kilit gösterimi (Material kilit ikonu kullanılmaz). Testte `find.byType(KilitAmblemi)`. |
| `HataGorunumu(metin)` | Hata/boş durum. |
| `PariltiSprite.yukle/ciz` | CustomPainter içinde dört uçlu parıltı çizmek. |

---

## 3. Teknik notlar

| Konu | Ayrıntı |
|---|---|
| Asset klasörü | `assets/images/` (düz klasör; pubspec yalnız bunu kaydeder, alt klasör açma). Opak görseller JPEG, şeffaflar WebP (alfa). Kaynak PNG konmaz (`test/shared/app_images_test.dart` engeller). Yollar `AppImages`. |
| Kaynak PNG'ler | `../luckApp_gorsel_kaynak/` (depo dışında, 54 PNG + SVG + istem/kontrol JSON'ları). `GORSEL_SETI.html` oraya bakar. 16 eski koleksiyon kartının kaynağı Codex klasöründe (Rehber §6). |
| Boyutlar | Tam ekran sahne 948×1660 / 948×1422 (q84), kart 720×1080, koleksiyon kartı + çerçeve 600×900 (q82), yatay afiş 1200×800, glif 160, madalyon/burç 256, ay 160, mühür 512, küre/astrolab 640, sütunlar 720×1080. Toplam ~12 MB. |
| Dosya adları | Izgara parçaları: `kategori_<ask/para/saglik/sosyal/risk>`, `madalyon_<gunes/ay/yukselen>`, `burc_<Burc.name>`, `ay_evresi_<AyEvresi.index>`. Koleksiyon: `koleksiyon_<id>.jpg` (id = katalog kimliği). |
| Skor → sahne | `SkorSahnesi.skordan(skor)`; orta bant artık `sahne_orta_kapili` (üç sahnede kapılar aynı yerde). Eski `sahne_orta.jpg` silindi. |
| Kart + mühür | `FortuneRevealCard(..., muhur: Image.asset(AppImages.muhur))`. Mühür kapalı yüzün üstünde ayrı katman; çap `DailyLuckConfig.muhurCapOrani`; bölünmede her kanat kendi yarısını taşır. Eski tek parça `kart_arka_yuzu.jpg` silindi. |
| Paylaşım render'ı | Off-screen render tek kare: `Image.asset` çözülmeden çizilir. Bu yüzden `ShareService.gorselCoz` görseli önden `ui.Image` yapar, kart `RawImage` ile çizer. Ekrandaki önizleme `Image.asset` kullanır (`StoryCard.arkaPlan` widget alır). |
| Koleksiyon | Motor: `LuckEngine.gununKarti` (`koleksiyon_secimi.dart`, `donguselIndeks` + bağımsız 1/8 nadir). Depo: `KoleksiyonRepository` (app_state kutusu, `StorageKeys.koleksiyonKaydi`), aynı gün idempotent. UI: `lib/features/koleksiyon/`. **Katalog sırası değişmez**, yeni kart yalnız sona eklenir. |
| İkon kaynakları | Android `mipmap-*/ic_launcher.png` (eski tip, zeminli) + `ic_launcher_foreground.png` (108 dp) + `mipmap-anydpi-v26/ic_launcher.xml`; zemin `drawable/ic_launcher_background.xml`, renkler `values/colors.xml`. Bildirim: `drawable/ic_stat_kader.xml` (+ `raw/keep.xml`, R8 silmesin), kod `FeedbackConfig.bildirimSimgesi`. iOS AppIcon seti opak (alfa yok). Üretim betiği aşağıda (§3.1). |
| Silinenler | SVG: kategori ikonları, yıldız deseni, kristal küre, yonca ikonu, eski kart arka yüzü (`AppIllustrations` sınıfı kalktı). `assets/svg/` yalnız `bildirim_kapi.svg` (kaynak). `flutter_svg` paketi artık kodda kullanılmıyor; kaldırmak pubspec değişikliği (Turan'a sorulmalı). |
| Sekme pili | `AnaKabuk` her sekmeyi `TickerMode(enabled: seçili)` ile sarar; sahneli sekmeler gizliyken animasyon çalışmaz. |

### 3.1 Görsel işleme hattı (Windows, Python yok)

2026-10 setinde kullanılan araçlar: PowerShell + `System.Drawing` (kırp,
küçült; alfa doğru ölçeklenir) ve **ffmpeg** (WinGet ile kurulu;
`libwebp` ile WebP). Akış: şeffaf görselin alfa kutusu bulunur (eşik 24;
burç ızgarasında komşu haleler değdiği için 128), kare kutuya %1–4 pay
eklenip küçültülür → geçici PNG → `ffmpeg -c:v libwebp -quality 88
-pix_fmt yuva420p`. Izgaralar satır/sütun alfa izdüşümündeki boşluklardan
otomatik bölünür (parça sayısı beklenenden farklıysa betik durur). Kırpma
kutusu kaynağın dışına taşarsa taşan kısım şeffaf kalır (aynalama yok).
Eski tek dosyalık JPEG fonksiyonu:

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
- `ThemeData.dark()` kullanıldığı için önizlemede AppBar opak ve kartlar düz
  görünür; cam kart görmek için önizleme temasına `cardTheme` (camYuzey/
  camKenar) ve şeffaf `appBarTheme` ekle.
- Birden çok ekran: `ac(tester, ekran, hazirla: ...)` yardımcısı; `hazirla`
  kutular kurulduktan sonra (ör. koleksiyona kart ekleme) çalışır.

---

## 4. Açık kararlar (Turan verecek)

| # | Karar | Seçenekler / not | Cevap |
|---|---|---|---|
| K1 | Alt gezinme | Mockup'lar 3 sekme gösteriyor (Bugün · Koleksiyon · Profil; Ayarlar profilin içinde). Şu an 5 sekme (Bugün, Profilim, Uyum, Keşfet, Ayarlar). Uyum ve Keşfet nereye gider? | **5 sekme kalsın, yeni stil** (3 Eki). Koleksiyona Profil'deki özet ve ana ekrandaki "Bugünün kartı" panelinden girilir. |
| K2 | Koleksiyon özelliği | Her gün bir kart "kazanılır" (deterministik seçim, luck_engine + storage + UI = 3 oturum). Mevcut 16 kart görseli hazır. Yapılsın mı? | **Evet** (3 Eki) — yapıldı (V14–V16). |
| K3 | Ses | `audioplayers` (ya da `just_audio`) paketi + 4 kısa ses (dokunuş, ışık, çan, ortam). Ses dosyalarını kim üretecek? | |
| K4 | Ayarlar'da "Ses / Titreşim / Hareketi azalt" anahtarları | Mockup'ta var. Uygulama içi "hareketi azalt" sistem ayarına ek olarak tutulsun mu? (storage alanı gerekir) | |
| K5 | Uygulama ikonu üretimi | `flutter_launcher_icons` (dev paketi, onay) ya da Claude elle mipmap PNG'leri üretir. | **Claude elle üretti** (3 Eki), paket eklenmedi. |
| K6 | Premium kahraman görseli | `2dca1663` (ışıklı kapı) mı, yeni çizim mi? | **`sahne_orta_kapili`** (3 Eki). |

---

## 5. Oturum sırası

Her satır tek oturum (CLAUDE.md kural 1). "Görsel" sütunu, oturumdan önce
`assets/images/`'a konmuş olması gereken çizimleri gösterir
(`GORSEL_URETIM_REHBERI.md` kimlikleri). Görsel hazır değilse oturum
mevcut görsellerle yapılabilir ama sonra tekrar ele alınır.

- [x] **V1 — Bugün ekranı: sahne + kart açılışı** (daily_luck). Görsel: mevcut set.
- [x] **V2 — Ortak sahne altyapısı** (shared). `SahneArkaPlani`, `_AltinButon`
      ve cam panel kalıbını `lib/shared/widgets/`'a taşı (genel API: görsel
      yolu, opsiyonel ön plan katmanı, karartma ayarları); daily_luck onları
      kullansın. Davranış değişmez, testler yeşil kalır. Görsel: yok.
- [x] **V3 — Marka: uygulama ikonu + bildirim ikonu** (android/ios kaynakları
      + `feedback/notification_service.dart`). K5 kararı gerekir. Görsel:
      `784120f8`, `122a7f6e` (P1-M1); bildirim ikonunu Claude vektör çizer.
- [x] **V4 — Bugün cilası** (daily_luck). Mühür ayrı katman: dokununca döner,
      ışık fazında ikiye çatlar; ön plan sütunları ile paralaks; parıltı
      sprite'lı kıvılcımlar; yeni kategori glifleri; orta sahne kapılı sürüm.
      Görsel: P1-B1…B5.
- [x] **V5 — Premium + rapor kilidi** (premium). Paywall'ı mockup `9635f67f`
      4. ekrana göre yenile, kristal küreyi kaldır; rapor kilidinde kitap
      görseli. Görsel: K6, P2-R2, P2-R3.
- [x] **V6 — Onboarding** (onboarding + legal/uyari ekranı görünümü).
      Mockup `ee9545f3`: sahne arka planı, dönen astrolab, ışıkla dolan küre +
      3 adımlı kontrol listesi, "Kartın hazır" kartı → ana ekran kartına Hero.
      Görsel: P1-O1…O4.
- [x] **V7 — Paylaşım kartları** (share). 3 tema seçimi (Gece/Işık/Mor),
      "Skoru gizle" anahtarı (mockup `9635f67f` 1. ekran). Görsel: P1-S1.
- [x] **V8 — Kader Profili + doğum haritası** (profile). Başlık sahnesi,
      Büyük Üçlü madalyonları, burç madalyonları. Görsel: P1-P1…P3.
- [x] **V9 — Yıl raporu + numeroloji raporu** (profile). 9 yıl afişi, rapor
      kitabı, kilitli bölüm görünümü. Görsel: P2-R1…R3.
- [x] **V10 — Uyum** (compatibility). Görsel: P2-U1, P2-U2.
- [x] **V11 — Keşfet** (tools). Görsel: P2-K1.
- [x] **V12 — Ayarlar + geri bildirim + kategori detay** (settings, feedback,
      categories): ortak sahne arka planı, akşam sahnesi. Görsel: P3-2.
- [x] **V13 — Gezinme** (home). K1 kararına göre alt menü yeniden düzeni ve
      mockup'taki altın vurgulu menü stili.
- [x] **V14–V16 — Koleksiyon** (K2 onayıyla): V14 luck_engine (günün kartı
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
| G8 | Koleksiyon kataloğunun (`KoleksiyonKatalogu.kartlar`) sırası değişmez; yeni kart yalnız sona eklenir. Kart kimlikleri depolamada ve dosya adında kullanılır, yeniden adlandırılmaz. | kural 8, kullanıcı verisi |
| G9 | Onboarding "Kartın hazır" ekranında durur; ana ekrana "Kartıma geç" ile gidilir (`onboarding_flow_test.dart` buna göre). | |
| G10 | `assets/images/`'a ham GPT PNG'si konmaz; önce §3.1 hattıyla küçültülür (`app_images_test.dart` engeller). | paket boyutu |

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
- Widget testi ekranı **yatay** 800×600: genişliğe oranlı büyük öğeler
  (kart önizlemesi, afiş, koleksiyon kartı) çok uzar ve sonraki öğeler
  ListView'in önbellek alanının dışında kalıp hiç kurulmaz. Büyük görsellerin
  boyunu ekran yüksekliğiyle de sınırla (`min(genişlik·oran, yükseklik·oran)`).
- `scrollUntilVisible` önbellekte kurulmuş öğeyi "görünür" sayıp kaydırmaz;
  dokunmadan önce `ensureVisible`. Altta başka rota varsa (ör. profil formu
  → tanışma) `scrollable:` parametresiyle doğru listeyi seç.
- Aynı rotada aynı Hero etiketi iki kez olamaz (koleksiyonda öne çıkan kart
  Hero'suz, etiket ızgarada).
- Renkli `DecoratedBox` içindeki `ListTile` assert verir: arada şeffaf
  `Material` olmalı (`CamPanel`/`SahneliZemin` bunu yapar).
- Off-screen paylaşım render'ında `Image.asset` boş çıkar: görseli önden
  `ui.Image` olarak çöz (`ShareService.gorselCoz`).
- Bash aracında `'$...'` içeren uzun heredoc'lar bazen "unexpected EOF"
  veriyor; Dart dosyalarını Write aracıyla yaz. Perl değiştirmelerinde
  yerine-koymada `\$1` yazma (tek tırnakta düz `$1` metni kalır).
- WebP: ffmpeg'de `-alpha_quality` yok; `-quality 88 -pix_fmt yuva420p` yeterli.

---

## 9. Hızlı başvuru

| Konu | Dosya |
|---|---|
| Ana ekran | `lib/features/daily_luck/daily_luck_screen.dart` |
| Kart koreografisi | `lib/features/daily_luck/widgets/fortune_reveal_card.dart` |
| Sahne arka planı, ortak bileşenler | `lib/shared/widgets/` (`sahne_arka_plani.dart`, `altin_buton.dart`, `cam_panel.dart`, `gorsel_afis.dart`, `sahne_config.dart` …) |
| Skor gösterimi | `lib/features/daily_luck/widgets/gunun_puani.dart` |
| Ana ekran sabitleri | `lib/features/daily_luck/daily_luck_config.dart` |
| Renkler / tema | `lib/core/theme/app_colors.dart`, `app_theme.dart` |
| Görsel yolları | `lib/shared/widgets/app_images.dart` (raster), `app_icons.dart` (kategori glifleri) |
| Onboarding | `lib/features/onboarding/` (`widgets/astrolab.dart`, `widgets/isik_kuresi.dart`, `calculating_screen.dart`) |
| Paylaşım | `lib/features/share/paylasim_screen.dart`, `story_card.dart`, `paylasim_temasi.dart` |
| Koleksiyon | `lib/core/luck_engine/koleksiyon_secimi.dart`, `lib/core/storage/koleksiyon_repository.dart`, `lib/features/koleksiyon/` |
| Gezinme | `lib/features/home/ana_kabuk.dart` |
| Görseller | `assets/images/` |
| Mockup'lar | kaynak klasörde `42699425`, `9f0eb26b`, `ee9545f3`, `9635f67f` |

