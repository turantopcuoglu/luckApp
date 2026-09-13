# Kozmik V5 — Aydınlık kapı ve ana ekran
Tarih: 8 Eylül 2026.

## Öncelik ve kapsam

Kullanıcının son referansı: exec-42699425-a857-4c9c-b16b-7a55fa2ec3a5.png.
Bu kayıt V4'ün ana ekranda kalan koyu yarım kartlar, geniş iki eksenli soldurma,
daire biçimli kategoriler ve düz alt menü kararlarının yerine geçer.
V4 logo, hazırlık küresi, koleksiyon, Story, profil ve Premium bu turda yeniden
tasarlanmadı. Referansın Ada/86/34 gibi değerleri yalnız QA fixture'larıdır.
Üretim ekranı gerçek tarih, profil, skor ve erişim durumunu kullanır.

## Üretim dosyaları

| Dosya (assets/images/) | Boyut | Kullanım |
| --- | --- | --- |
| card_luminous_v5.png | 1024×1536 | Parlak mavi mermer mühür; kapalı kart ve hareketli yarımlar. |
| portal_radiant_v5.png | 1182×1330 | Açılmış >=40 skor için turkuaz–altın kapı; >=92 skorda ek folyo ışığı. |
| portal_twilight_v5.png | 1182×1330 | Açılmış <40 skor için aydınlık lavanta–pembe kapı. |

Toplam 9.25 MB (ondalık dosya boyutu). Asıl kaynaklar korunarak kopyalandı.
Eski kart resmi diskte durur; pubspec'teki aktif doku V5'e taşındı.
Yeni paket, veri şeması, seed veya skor hesabı değişikliği yok.
CosmicTone.homeSceneAsset yalnız bu ana ekranın iki yeni görselini seçer;
ikincil sayfaların/Story'nin mevcut sceneAsset eşlemesi ayrıdır.
Sahneler DPR'ye göre, 1024 px çözme tavanıyla açılır. İki renk de sonuç okunmadan
önbelleğe alınır; disk kaydı tamamlanmadan sonuç veya kategori değeri kurulmaz.

## Yerleşim ve okunaklılık

- Merkezli marka/tarih/selamlama; kenarlarda 16 px metin boşluğu.
- Ana kapı çizimi tam genişliğe taşar. Yatay soldurma YOKTUR. Yalnız üst %5,5 ve
  alt %6,5 birleşim kenarı yumuşatılır; çizimin orta %88'i tam opaktır.
- Kapının üzerindeki büyük koyu skor perdesi %70'ten en fazla %15'e indirildi.
  İki küçük beyaz etiketin yerel gölgesi daha kuvvetlidir; mimariye yayılmaz.
- Büyük skor çizime gömülü değildir. Flutter metni ve tek anlamlı semantics
  düğümüdür; kapı içindeki üst gökyüzüne taşındı.
- Aşk/Para/Sağlık/Sosyal/Risk renkli dikdörtgen kutular: dolgu ikon, ad, serif
  sayı. Para işareti kodla çizilmiş sikke yığınıdır. Dairesel çerçeve ve bar yok.
- Açılmamış kartta beş nötr kutu yalnız “–” taşır. Kilitli sonuçlar null,
  kilit etiketi/ikonu; widget, semantics ve paylaşım verisinde gizli sayı yok.
- 280 px kullanılabilir içerikte beş sütun; büyük yazıda iki sütun.
  Kutuların yüksekliği metinle büyüyebilir. Minimum dokunma alanı korunur.
- Küçük adım tek kompakt panel; dar/büyük yazıda Paylaş alta geçer.
  İsteğe bağlı oluşu semantics'te açıklanır. Gün sonu değerlendirme aşağıda
  gerçek çalışan rota olarak korunur; yeni sahte görev/puan artırma yok.
- Alt menü: yuvarlak üst köşeler, ince mavi sınır, lacivert yüzey, seçili
  sekmede küçük ışık ve alt çizgi. Koleksiyon kitap ikonuyla gösterilir.
  Büyük yazı, SafeArea, seçili semantics, klavye odağı ve rota davranışı korunur.

## Gerçek hareket / bitmap ayrımı

Bu bir video kopyası veya gerçek 3B sahne motoru değildir. Mimari, su, açık
kapı yüzeyleri ve çizimin ayrıntılı ipek ışıkları resmin içindedir. Flutter
ayrıca gerçek zamanlı mühür, dikiş ışığı, perspektifli iki yarım, açılış tozu,
alt taraftaki üç ince hareketli ışık izi ve akan parıltıları çizer.

1. 0–250 ms: mühür darbesi.
2. 250–650 ms: alttan üste çıkan ışık dikişi.
3. 650–1300 ms: menteşeli yarımlar açılır. Açılımın %45'inden sonra hareketli
   dokular, ışık sırasında ayrıntılı açık kapı illüstrasyonuna karışır.
   Son karede panelOpacity=0, sceneOpacity=1; koyu yüzler üstte kalmaz.
4. Kayıt başarıyla tamamlandıktan sonra 700 ms sonuç girişi. Düşük skor
   nötr turkuaz sahneden lavanta sahneye karışır. Açılış sırasında gizli
   sonuç rengini kullanma. Yavaş kayıtta bekleme uzayabilir.
5. Açılmış kartta 18 saniyelik deterministik ışık çevrimi. Lavanta hareketi
   daha sakin; turkuaz hareketi iki akış turu yapar. Metnin içinden geçen
   kalın şerit yok. 28 parçacık, 3 ince şerit; 0/1 kareleri aynı.

TickerMode, arka plan ve sistem hareket azaltma tercihi saatleri durdurur.
Önceden açılmış kart ilk açılışı veya kaydı tekrarlamaz. Mühür ve sonuç haptic'i
birer kezdir. Yeni ses motoru/mağaza entegrasyonu yok; referansın hoparlör
düğmesi çalışıyormuş gibi eklenmedi.

## Doğrulama

- flutter analyze --no-pub: temiz.
- flutter test --no-pub: 510 başarılı test.
- 320/390/430 px, TR/EN, 1×/2× yazı; açılış, yetki maskesi, haptic/lifecycle,
  kaydetme hatası, tekrar deneme ve paylaşım regresyonları.
- V5 özel test: panel/çizim uç değerleri ve 1 ms aralıklı süreklilik, iki farklı
  skor sahnesi, yerel karartma sınırı, gerçek AppShell ve kategori/menü düzeni.
- Gerçek Flutter widget görüntüleri: design/previews/v5/home-{closed,high,low}.png.
- Gerçek açılışın QA kaydı: design/previews/v5/reveal-motion.gif (20 fps).
  Bu GIF kayıt örnekleme hızıdır; fiziksel cihaz FPS ölçümü değildir.
- design/previews/v5/test-results.jsonl tam test olay kaydıdır.
- Fiziksel cihaz GPU/fps/bellek, farklı safe-area ve launcher testi bu turda
  çalıştırılmadı. Geliştirici kabulünde düşük/orta Android ve iPhone üzerinde
  kontrol edilmeli. Üretim varlıkları değiştiğinden tam yeniden başlatma gerekir.

## Imagegen üretim kaydı

Araç: yerleşik image_gen, imagegen becerisi. Her çağrı tek üretim bitmap'i.
Mod: referanstan yeni sahne / stylized-concept; referans stil ve kompozisyon
kılavuzu, düzenlenecek arayüz ekranı değildir. Ek bir rötuş/dönüşüm yok.
referenced_image_paths:
C:/Users/Superuser/.codex/generated_images/01a06197-d23e-74a0-b368-6a1331013a95/exec-42699425-a857-4c9c-b16b-7a55fa2ec3a5.png

### portal_radiant_v5

Asıl çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-d5c24b1b-53f7-4a21-8507-ec11a416de23.png

Nihai dosya: assets/images/portal_radiant_v5.png

Tam prompt:

Use case: stylized-concept. Production illustration asset for Flutter, not a UI mockup. Image 1 is STYLE AND COMPOSITION REFERENCE only. Render ONE standalone scene, no phones, no collage. Portrait nearly-square 1024x1152. Reproduce the rich luminous cinematic CGI illustration of the reference's score hero area, with crisp illuminated materials, NO milky haze overlay, NO underexposure, NO dull washed-out colors. Full canvas art. No text, numbers, letters, logo, captions, progress bars, UI icons or watermark. Keep the central score area (x35–65%, y22–50%) quiet with a deep saturated color for actual Flutter text. Match the MIDDLE high-score phone's scene: a magnificent open celestial doorway in a deep teal/cyan night sanctuary. Two beautifully rendered obsidian-marble card door leaves, one on left at x15–28%, one right at x72–85%, with detailed warm gold engraved metalwork, physically opened outward, edges shining like white-hot champagne light. Rounded gold luminous arch at x28–72% spans y10–85%. Through the gateway a fantastical turquoise river valley with dramatic sculpted distant cliffs and small luminous sun at horizon y68%, NOT a giant centered moon behind score. Brilliant warm-gold light at threshold pours onto glossy water. Large sculptural columns on outer edges, deep teal cosmos and clouds. Thin flowing teal and gold translucent light ribbons circle OUTSIDE the central text area and sweep across lower threshold; energetic, magical, art-directed. Doors visibly bright, never black silhouettes. Strong local contrast, vibrant turquoise, white-gold highlights, refined deep navy negative space. The entire doorway fits within y8–90%.

### portal_twilight_v5

Asıl çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-65bbef06-6305-4508-a543-747f55ab0c1c.png

Nihai dosya: assets/images/portal_twilight_v5.png

Tam prompt:

Use case: stylized-concept. Production illustration asset for Flutter, not a UI mockup. Image 1 is STYLE AND COMPOSITION REFERENCE only. Render ONE standalone scene, no phones, no collage. Portrait nearly-square 1024x1152. Reproduce the rich luminous cinematic CGI illustration of the reference's score hero area, with crisp illuminated materials, NO milky haze overlay, NO underexposure, NO dull washed-out colors. Full canvas art. No text, numbers, letters, logo, captions, progress bars, UI icons or watermark. Keep the central score area (x35–65%, y22–50%) quiet with a deep saturated color for actual Flutter text. Match the RIGHT low-score phone's scene: a gentle but LUMINOUS lavender/rose celestial sanctuary. Same composition, rounded arch and outward opened engraved door leaves at x15–28% and x72–85%, metallic lavender with warm rose-gold shining edges, NOT dark silhouettes. Through the central gateway a dreamy lilac twilight river valley and small pale sunrise at horizon y68%. Fine rocky spires and clouds glowing in pink-lavender light. Small floating moon/planets near outer corners ONLY, not centered behind score. Flowing translucent lavender-silk ribbons curve round left and right and across bottom at y78–90%, leaving central x35–65% y22–50% calm muted violet for text. Strong jewel colors, crystalline reflections, soft radiant highlights, inviting rather than gloomy. Golden-pink rounded rim visibly emits light. Entire doorway fits within y8–90%, exterior remains deep midnight navy.

### card_luminous_v5

Asıl çıktı: C:\Users\Superuser\.codex\generated_images\01a06197-d23e-74a0-b368-6a1331013a95\exec-38f451fb-e1ad-4199-b376-6a462614bc48.png

Nihai dosya: assets/images/card_luminous_v5.png

Tam prompt:

Use case: stylized-concept. Image 1 is a STYLE REFERENCE, especially the CLOSED CARD in the LEFT phone. Generate ONE production card FACE texture, front orthographic view, portrait 1024x1536 (2:3). Artwork fills the rectangular canvas, not a card floating in a larger scene. Glossy midnight BLUE marble (clearly legible cobalt/silver veining, NOT near-black), finely worked bright champagne-metal corners, thin gold edge border inset 3%, large circular celestial seal centered exactly (50%,50%) with a finely engraved eight-point star, shimmering metallic radial detail, subtle pearl highlights on seal. Bright thin vertical light seam through center. Match the reference's ornate but readable luminous card, detailed physically based 3D materials, high contrast, properly lit blue stone surface. No external background, no drop shadow beyond card, no scenery, no perspective tilt, no words, numbers, labels, logo, interface or watermark. The card is split into moving half-panels at runtime.
