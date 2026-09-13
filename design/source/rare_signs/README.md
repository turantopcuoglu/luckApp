# Kader Nadir İşaret kartları

Bu klasör, ilk koleksiyon setindeki 12 kartın tam çözünürlüklü PNG
master'larını içerir. Uygulamanın bundle ettiği 800×1120, 5:7, kalite 88 WebP
çıktıları `assets/images/rare_signs/` altındadır. Kartların içine başlık, skor,
tarih, kilit veya CTA yazısı gömülmez; bunların tamamı erişilebilir Flutter
katmanlarıdır.

## Ortak sanat yönetimi

- Premium editoryal koleksiyon kartı; tek ikon değil, katmanlı minyatür dünya.
- Derin ink lacivert, sıcak krem, elektrik lime, mercan, iris moru, buz mavisi
  ve ölçülü fırçalanmış altın.
- Yoğun bitki katmanları, mimari kemerler, yollar, su ve anlatı derinliği.
- Vektör benzeri temiz geometri; kâğıt dokusu ve yumuşak kesme-kâğıt gölgeleri.
- Görsele bütünleşmiş ince, yuvarlatılmış altın çerçeve.
- Mobil kart boyutunda güçlü ana siluet; yakından bakıldığında zengin ayrıntı.
- Metin, logo, watermark, kişi, astroloji, tarot, kristal küre, yıldız/ay,
  burç, yonca, nal, zar ve casino çağrışımı yoktur.

## Kart anlatıları

| Dosya | Görsel anlatı |
|---|---|
| `rare_acik_kapi.png` | Katmanlı bahçeden aydınlık açık kemere giden yol; yeni fırsat. |
| `rare_kesisen_yollar.png` | Farklı renkli yolların boş tabelalı merkez meydanda buluşması. |
| `rare_sessiz_tohum.png` | Tohum, filiz ve olgun çiçekli kemere uzanan teraslı büyüme yolculuğu. |
| `rare_ucan_not.png` | Vadiler, açık pencereler ve boş notlar arasından ışığa uçan kâğıt uçak. |
| `rare_dengeli_tas.png` | Yansımalı su, basamak yolu ve kemer içinde dengeli taşlar. |
| `rare_yeni_patika.png` | Ana yoldan ayrılıp tepedeki aydınlık kemere çıkan keşif patikası. |
| `rare_geri_donen_serit.png` | Farklı manzaralardan geçip yeniden buluşan mercan ve iris şeritler. |
| `rare_kucuk_kopru.png` | İki ayrı kıyı yolunu tek rotaya bağlayan küçük, zarif köprü. |
| `rare_acik_pencere.png` | Bahçe stüdyosundan daha aydınlık bir vadiye açılan yeni bakış. |
| `rare_beklenmedik_durak.png` | Yol üstünde saklı bahçe, kaynak ve manzarayı ortaya çıkaran dinlenme yeri. |
| `rare_yan_yana_izler.png` | Aynı vadiyi yan yana aşan mercan ve iris yaprak izli iki rota. |
| `rare_parlak_yol.png` | Karanlık, zengin dünyayı aşıp açık kemere ulaşan altın-lime parlak yol. |

## Üretim ve yeniden çıktı alma

Master'lar yerleşik ImageGen ile, `stylized-concept` kullanımına göre ve beş
arketip illüstrasyonu stil referansı alınarak ayrı ayrı üretilmiştir. Her kart
için ortak sanat yönetimine yukarıdaki sahne anlatısı eklenir. Yeni varyant
üretilirse dosya adı değişmeden önce görsel olarak onaylanır; master PNG
korunur, üretim WebP'si merkezden 800×1120 boyutuna kırpılır ve kalite 88 ile
yeniden dışa aktarılır.

`vector_drafts/` altındaki SVG'ler ilk sade eskizlerdir. Üretim asset'i
değildir, `pubspec.yaml` ile bundle edilmez ve `RareSignId` eşlemesinde
kullanılmaz.
