# CODEX.md — Kader 2.0 Ürün ve Uygulama Dönüşüm Planı

> Bu belge, mevcut çalışan Flutter uygulamasını yeni **Modern Tesadüf** ürün
> yönüne dönüştürecek Codex oturumlarının ana uygulama planıdır.
>
> Başlangıç tarihi: 2 Eylül 2026  
> Güncel durum (8 Eylül 2026): FAZ 0–10; bütünleşik tam sayfa sahne ve dokulu kategoriler V6 uygulandı. Son test kaydı aşağıda.  
> Ürün adı: **Kader** (geçici); **Nuvarya** önerisi kullanıcı onayını bekliyor.  
> Platform: Flutter / Android / iOS  
> Arayüz dilleri: Türkçe ve İngilizce

## 8 Eylül 2026 — V6: uygulamayla bütünleşik sahne ve doygun doku

V6, kullanıcının V5'te resmin ayrı bir alan gibi kalmasına ilişkin düzeltmesidir.
V5'in yalnız ana ekran sahne sınırları ve kategori malzemesi kararları değişir.

- Yeni tek parça gece/turkuaz/lavanta çizimleri: `sanctuary_*_v6.png`.
  Başlık ve kart aynı `TodaySceneStage` içinde; çizim tam genişlikte, üstten
  başlayıp hero altından 240 px öteye uzanır. Hero sınırında kırpma/fade yoktur.
- İkinci portal bitmap'ini ana hero'ya bindirme. Bağımsız koleksiyon skoru V5
  görünümünü korur; logo, diğer sayfalar ve marka kararı değişmedi.
- `CategoryJewelSurface`: doygun beş taş/cam paleti; gren, ince damar, renkli
  yansıma ve kenar ışığı. Statik ve kodla çizilir; gizli skora bağlı değildir.
- Açılış saati, kayıt kapısı, maskelenmiş skorlar, reduced-motion, haptic ve
  paylaşım/gün sonu davranışları korunur. Yeni paket veya veri şeması yok.
- Üretim promptları/varlık yolları: `design/source/cosmic-v6/URETIM_NOTLARI.md`.
- Gerçek ekranlar: `design/previews/v6/home-{closed,high,low}.png`;
  hareket kaydı: `design/previews/v6/reveal-motion.gif`.
- Analyze temiz; **513 test başarılı**. Fiziksel cihaz performansı ölçülmedi.
  Yeni varlıkları görmek için tam yeniden başlatma gerekir.

## 8 Eylül 2026 — V5: aydınlık kapı, renkli kategori kutuları ve hafif menü (sahne sınırları tarihsel)

Bu bölüm son eklenen üç ekranlı referansı uygular ve V4'ün **ana ekran** için
“hareketli koyu kanatlar sonuçta kalır” kararından önceliklidir. Logo ve diğer
sayfaların V4 görselleri korunur; tarihsel işleri yeniden başlatma.

- Üç yeni yazısız üretim resmi: parlak mermer kart, turkuaz–altın açık kapı,
  lavanta–pembe açık kapı. Aktif dosyalar pubspec'te isimleriyle listelenir.
- Son karede hareketli yarımlar kaybolur; ayrıntılı, ışıklı açık kapı çizimi
  kalır. Mühür/dikiş/kanat/sonuç sırası ve 250/650/1300/2000 ms ritmi korunur.
- Sahneyi örten koyu halo hafifletildi; geniş yatay/dikey soldurma kaldırıldı.
  Yalnız kısa üst/alt birleşim kenarı yumuşar. Skor gökyüzündedir; etiket gölgesi
  yereldir. Ana mimari ve renkler tam canlı kalır.
- Beş dikdörtgen kategori kutusu, kompakt küçük adım/Paylaş paneli, kitap ikonlu
  ve ince seçili ışık çizgili yuvarlak alt menü. Büyük yazı/dar ekran uyarlanır.
- Yüksek skor turkuaz–altın, düşük skor parlak lavanta; sahneye üç kontrollü
  gerçek ışık akışı eklendi. 18 sn döngü, reduced-motion/lifecycle korunur.
- Önceden açılmış kart/kilitli skor/gün sonu/paylaşım mantığı, seed, hesap ve
  kayıt şeması değişmedi. Yeni ses/mağaza paketi veya sahte hoparlör düğmesi yok.
- Tam promptlar, varlık eşlemesi, hareket sınırları ve cihaz kabul listesi:
  `design/source/cosmic-v5/URETIM_NOTLARI.md`.
- Gerçek Flutter önizlemeleri: `design/previews/v5/home-{closed,high,low}.png`;
  açılış QA GIF'i: `design/previews/v5/reveal-motion.gif`.
- `flutter analyze --no-pub` temiz; `flutter test --no-pub`: **510 test başarılı**.
  Fiziksel cihaz FPS testi yapılmadı. Yeni resimler için tam yeniden başlatma gerekir.

## 8 Eylül 2026 — V4: tek odak, hassas açılış, sedef logo (ana ekran kısmı tarihsel)

Kullanıcının son isteği V2/V3'ten önceliklidir. Büyük sahneleri üst üste bindirme;
ağır altın/obsidyen amblemi veya eski Story yerleşimlerini geri getirme.

- 19 yeni yazısız bitmap: sakin gece, ay/ışık yolu, cam küre, Gece/Işık/Mor,
  sedef hilal tam kare logo ve 12 özgün nadir koleksiyon sahnesi.
- Açılış: 0–250 mühür, 250–650 ışık, 650–1300 iki menteşeli kanat,
  1300–2000 yalnız metin yerleşmesi. Kanatlar sonuçta kalır; sahne sönmez.
- Hazırlık: gerçek cam dokusu içinde kodla dolan ince ışık/dalga ve ilerleme izi.
  Atmosfer tek sakin zemindir; büyük hareketli şeritler kaldırıldı.
- Story üç sahne seçicisi, PNG/önizleme ortak verisi ve tüm skorları gizleme.
- Ana Koleksiyon sekmesi mevcut kanıt analizinden 12 kart gösterir; sabit ödül
  sayısı yok. Günlük kart arşivi ve geçmiş ayrı çalışan rotalarda korundu.
- Profil sadeleştirildi, Premium tek ışık kapısıyla yenilendi. Satın alma veya
  ses entegrasyonu yapılmış gibi kontrol/fiyat gösterilmez.
- Kader adı, seed, skor algoritması, yetkiler ve kayıtlar korundu. Yeni paket yok.
  Eski görseller silinmedi; aktif kök PNG dosyaları pubspec'te açıkça listelendi.
- Üretim promptları, eşlemeler, hareket sözleşmesi ve cihaz kabul listesi:
  `design/source/cosmic-v4/URETIM_NOTLARI.md`.
- Gerçek widget önizlemeleri: `design/previews/v4/`; açılış ve hazırlık GIF'leri
  20 fps inceleme çıktısıdır, cihaz performans ölçümü değildir.
- `flutter analyze --no-pub` temiz; `flutter test --no-pub`: 506 test başarılı.
  Native ikon/splash üretildi; yeniden derleme gerekir. Cihaz GPU/bellek/fps,
  launcher maskeleri, ses ve mağaza entegrasyonu henüz kabul edilmedi.

## 8 Eylül 2026 — V3 ana ekran canlılığı ve zengin logo (tarihsel)

Kullanıcı V2 ana sahneyi soluk, vektör amblemi fazla sade buldu. Bu bölüm
V2'nin tüm ekranı koyulaştırma ve aktif vektör logo kararından önceliklidir.

- Ana ekran `CosmicBackdrop(vivid: true)` kullanır. %62–80 lacivert örtü yerine
  hafif nötr karartma; yorum ve kategori metinlerinin altında yerel koyu yüzeyler.
  Okunaklılık için yeniden tüm sahnenin renklerini bastırma. Yardımcı sayfaların
  sakin arka planları bu istek kapsamında değiştirilmedi.
- Ana sahne/kapı decode ölçüsü DPR ve cover geometrisine uyar, 1024 px kaynak
  sınırını aşmaz. Logo küçük ölçekte minimum 256 px kaynaktan çizilir.
- Yeni `assets/images/cosmic_mark_v3.png`: işlenmiş altın/obsidyen kapı,
  turkuaz kristal yıldız ve yörünge. Nihai bitmap koyu zeminli/opaktır;
  eski SVG kaynak korunur. Uygulama içi logo ve native ikon/splash yenilendi.
- Skor, kayıt, paket kimlikleri ve isim kararı değişmedi. Yeni paket eklenmedi.
- Kaynaklar ve iki tam üretim promptu: `design/source/cosmic-v3/URETIM_NOTLARI.md`.
- `flutter analyze --no-pub`: temiz; `flutter test --no-pub`: 495 başarılı test.
  Gerçek ekranlar: `design/previews/kader-cosmic-{low,balanced,high,rare}.png`,
  yeni logo uygulama içi: `design/previews/v2/profile.png`.
- Native ikon/splash için yeniden derleme gerekir. Fiziksel maske, ekran ve
  performans denetimi hâlâ cihazda yapılmalıdır. Sonraki iş sırası V2'deki
  isim onayı, cihaz kabulü ve ayrıca onaylı ses/mağaza entegrasyonudur.

## 8 Eylül 2026 — V2 okunaklılık, logo ve ortak sahne sistemi

Bu bölüm V2 uygulama kaydıdır; yukarıdaki V3 kararları önceliklidir. İlk dilimin "sonraki"
maddeleri tarihsel plandır; burada tamamlanan işler yeniden başlatılmaz.

### Uygulananlar

- Açılmış kartta skorun altında kontrollü koyu ışık perdesi, skor gölgesi ve
  `/100 · Günün şans puanı` için yüksek opaklıklı ayrı etiket yüzeyi var.
  Ana arka plan da koyulaştırıldı; desen başlıklarla yarışmaz.
- `CosmicTone.sceneAsset` ortak sahne kaynağıdır: <40 mor/bakır sığınak,
  40–69 turkuaz gözlemevi, 70–91 altın kapı, >=92 radyal yıldız tacı.
  Bunlar dört farklı bitmap kompozisyondur; yalnız renk filtresi değildir.
  Ana kart, açılmış günün zemini, küçük koleksiyon kartı ve Story aynı
  aileye bağlandı. Kapalı kart hâlâ sonuçtan bağımsız görünür.
- Yeni altın kapı/yıldız/yol amblemi gerçek SVG olarak çizildi. Uygulama içi
  logo, Android adaptive/launcher ve iOS uygulama ikonları ile başlangıç
  görselleri yenilendi. İsim onayı gelmediği için yazısız amblem kullanıldı;
  uygulama adı, applicationId, bundle ID ve kayıt anahtarları değiştirilmedi.
- Ayarlar/Profil, İzler girişi, günlük kart koleksiyonu, geçmiş, gün sonu
  değerlendirme, kategori detayı ve Premium ortak kozmik yüzey kullanır.
  Gerçek formlar, erişim yetkileri ve kayıt davranışı korunur.
- Premium için ayrı anahtar/obsidyen kart illüstrasyonu var. Gerçek erişim
  durumu anlatılır; mağaza bağlantısı olmadığı açıkça belirtilir. Sahte satın
  alma düğmesi, fiyat, başarı akışı veya skor artırma vaadi eklenmedi.
- Story düzenleyicisinde Kapı / Yörünge / Hatıra seçilebilir: dört sahne ×
  üç düzen = 12 görsel varyant. Koleksiyondaki her günlük kayıt kendi tarihi
  ve sonucuyla açılır; bugünün sonucu ile değiştirilmez veya yeniden hesaplanmaz.
  Bu, 12 farklı nadir işaret çiziminin koleksiyon entegrasyonu demek değildir.
- Story 1080×1920 gerçek PNG üretir. PNG, sahne yüklenmeden yakalanmaz;
  image/render kaynakları bırakılır. Kilitli kategori skorları hem önizlemede
  hem dışa aktarımda gizlidir. Stil seçimi kendiliğinden paylaşım başlatmaz.
  Paylaşım platformun sistem menüsüdür; doğrudan Instagram gönderisi değildir.
- Yardımcı sayfalar statiktir; mevcut Bugün atmosferi ve açılış hareketi
  korunur. Bu dilimde yeni ses veya mağaza bağımlılığı eklenmedi.

### Kaynak ve doğrulama

- Üretim dosyaları, yerleşim eşlemesi, tam imagegen promptları ve tekrar
  üretme komutları: `design/source/cosmic-v2/URETIM_NOTLARI.md`.
- İsim önerisi, mağaza başlığı ve sınırlı benzerlik taraması:
  `design/source/cosmic-v2/ISIM_ONERISI.md`. Nuvarya henüz kesinleşmedi;
  marka sicili/mağaza paneli uygunluğu ayrıca doğrulanmalıdır.
- `flutter analyze --no-pub`: temiz. `flutter test --no-pub`: 491 başarılı test.
  Bunlara gerçek PNG boyutu/gizlilik, TR/EN, 320 px ve 2× yazı, geçmiş kartın
  Story'ye taşınması ve paylaşımın açık kullanıcı eylemi olması dahildir.
- Gerçek Flutter önizlemeleri: `design/previews/v2/` (6 ekran, 12 Story),
  güncel Bugün varyantları: `design/previews/kader-cosmic-{low,high,rare}.png`.
  Native ikon üreticileri çalıştırıldı; iOS 1024 ikon RGB/alfasız doğrulandı.

### Buradan sonraki sıra

1. Kullanıcı görsel/isim kararını al; isim onaylanırsa görünen marka metinlerini
   tek kaynağa bağla. Yeniden markalama gerekçesiyle veri/seed/uygulama ID taşıma.
2. Gerçek Android/iOS cihazda soğuk açılış, görsel yükleme, FPS/GPU belleği,
   uygulama yaşam döngüsü, azaltılmış hareket, yazı ölçeği ve sistem paylaşımını
   kontrol et. Bitmap sıkıştırma/decode bütçesini ölçüme göre sonlandır.
3. Önceki ses işi: kısa özgün/lisanslı sesler, sessizleştirme ve yaşam döngüsü
   davranışı. Yeni paket gerekiyorsa eklemeden kullanıcı onayını al.
4. Nadir işaret koleksiyonunun kazanılmış/kilitli durumları ve kalan uzun
   yorum/bildirim metinlerinin editoryal turu; günlük kart koleksiyonuyla karıştırma.
5. Ayrı onaylı mağaza entegrasyonu: gerçek ürünler, satın alma/geri yükleme,
   iptal/hata/erişim yenileme ve mağaza sandbox testleri. Bu tamamlanmadan
   Premium'u satışa hazır veya uygulamayı yayıma hazır diye işaretleme.

## 8 Eylül 2026 — Onaylı sanat yönü güncellemesi (ilk dilim kaydı)

Kullanıcı `design/reviews/2026-09-08-futuristik-ruhani-v1/` altındaki dört
panoyu onayladı ve uygulamaya başlamamızı istedi. Bu karar, aşağıdaki eski
fazların doğum tarihsiz form / Akış-Bağ-Üretim kategori adları / sade vektör
görsel yönü maddelerinden önceliklidir. Tarihsel faz kayıtları silinmez.

- Doğum tarihi başlangıç formuna geri gelir; mevcut v1/v2 kimlikler ve günlük
  sonuçlar yeniden hesaplanmaz. V2 doğum tarihi profil bilgisidir, seed değildir.
- Kullanıcıya görünen kategoriler Aşk, Para, Sağlık, Sosyal ve Risk olur.
- Lacivert üzerinde katmanlı kozmik atmosfer, obsidyen/altın kart, dolan ışık
  hazırlığı, mühür/dikiş/iki kanat açılışı ve skora göre efekt varyantları.
- Sağlık/para tahmini, düşük skorda korku ve satın alarak şans artırma yoktur.
- İlk uygulama dilimi: başlangıç + Bugün görsel/animasyon dikey akışı.
  Paylaşım düzenleyicisi, koleksiyon, tam Profil/Premium dönüşümü ve özel ses
  oynatımı sonraki dilimlerdir. Hiçbiri yalnız konsept üretildi diye tamamlanmış
  sayılmaz. Yeni ses/mağaza paketleri ayrıca onay gerektirir.
- Ekran PNG'leri UI olarak gömülmez: ayrı üretim sahneleri, gerçek Flutter
  metin/kontrolleri ve bağımsız çizim/animasyon katmanları kullanılır.
- Nihai cihaz akıcılığı ve görsel eşleşme gerçek ekran önizlemeleriyle denetlenir.

### İlk uygulama dilimi — yapılanlar

- Başlangıç formunda açık doğum tarihi seçimi, eksik/gelecek tarih doğrulaması,
  klavyeden güvenli geçiş; v1 profil tohumu ve v2 ritüel kimliği korunur.
  Tarih seçimi alt paneldedir; konseptteki sürekli açık takvim birebir kopyalanmadı.
- Karşılama ve Bugün ekranına ayrı kozmik arka plan/kart/kapı üretim görselleri
  bağlandı. Kaynaklar ve tam promptlar: `design/source/cosmic-v1/PROMPTLAR.md`.
- Hazırlıkta cam küre içinde yükselen ışık/dalga ve eşzamanlı dolum izi var.
  Bu ritüel geçişidir, işlemci/bilimsel hesaplama yüzdesi değildir; kayıt
  başarılı olmadan ana ekrana geçilmez. Başlangıç süresi 1600 ms'dir.
- Kart açılışı: 1400 ms mühür, folyo/dikiş ışığı, perspektifli iki kanat,
  yıldız/ışık tozu; ardından 600 ms sonuç girişi. Mühür ve sonuç dokunsal
  geri bildirimi korunur. Özel ses dosyası veya ses oynatıcısı eklenmedi.
- Bugün ekranında 18 saniyelik kesintisiz ışık/28 parçacık çevrimi var.
  Yalnız açılmış genel skor atmosferi belirler: <40 mor/bakır ve sakin hareket,
  >=70 turkuaz/altın, >=92 ek dönen folyo yayı. Son eşik görsel varyanttır;
  koleksiyonun nadir kart kazanma kuralını değiştirmez.
- Kapalı kart sonuç bilgisini renk/etiket/semantics üzerinden sızdırmaz.
  Kilitli kategori skorları maskelenir; hata/çift dokunma/geç kayıt güvenliği korunur.
- Aşk, Para, Sağlık, Sosyal, Risk başlıkları geri geldi. Günlük puan başlıkları
  ve düşük skorun küçük adımı yenilendi; 100 Türkçe görev cümlesi düzeltildi.
  Tüm uzun kategori/yorum havuzlarının editoryal kontrolü tamamlandı sayılmaz.
- Atmosfer döngüsü arka planda, gizli sekmede ve azaltılmış hareket tercihinde
  durur. Kart hareketi gizli sekmede durur; azaltılmış harekette tilt/haptic yoktur.

### Doğrulama ve sınırlar

- `flutter analyze --no-pub`: temiz; `flutter test --no-pub`: 452 başarılı test.
- Tarih/seed geriye uyumluluğu, kayıt hatası, tekrar deneme, çift dokunma,
  açılmadan skor gizliliği, büyük yazı/küçük ekran ve iki dil sınandı.
- Işık ressamının deterministik kareleri, ilerleyen animasyonun farklı kare
  üretmesi ve döngünün son/ilk karesinin eşitliği test edildi.
- `design/previews/kader-cosmic-{low,high,rare}.png`,
  `kader-reveal-{seal,seam,unfold}.png`, `kader-preparing.png` gerçek Flutter
  widget önizlemeleridir; çizim panolarının yerine geçmez.
- Gerçek cihaz FPS/GPU belleği, düşük güçlü Android, iOS, fiziksel haptic,
  soğuk açılışta görsel yüklenmesi ve uygulamayı arka plana alıp dönme testi
  geliştiricide kalır. Piksel-piksel eşleşme veya 60 FPS ölçüldü denmez.
- Üretim PNG'leri yaklaşık 8,4 MB; bitmap decode genişliği 768 px. Dağıtımdan
  önce görsel kaliteyi koruyan sıkıştırma ve ilk yükleme ölçümü yapılmalıdır.

### Sonraki dilimlerin doğru sırası

1. Bu gerçek ekranları cihazda onayla; dolum/açılış/arkaplan süre ve ışık
   yoğunluğunu cihaz bulgularına göre sonlandır.
2. Açılışın tamamı için uygulama yaşam döngüsü ve ses sessizleştirme davranışını
   tamamla; mevcut bağımlılıklarla ses fizibilitesini değerlendir. Yeni paket
   gerekiyorsa eklemeden onay al. Lisanslı/özgün kısa sesler, ses anahtarı ve
   azaltılmış hareketle uyum olmadan ses işini tamamlandı sayma.
3. Paylaşım düzenleyicisi + 9:16 gerçek kart çıktısı; sonra koleksiyonun zengin
   sahneleri ve kazanılmış/kilitli/nadir durumları. Geçerli erişim kuralları korunur.
4. Profil/ayarlar ve Premium'un tam sanat yönü dönüşümü; çalışmayan satın alma
   kontrolü koyma. Mağaza entegrasyonu yoksa mevcut gerçek erişim durumunu anlat.
5. Kalan metin havuzları ve bildirim tonu denetimi; tam cihaz/erişilebilirlik/
   performans kabul turu. Eski FAZ 11 maddeleri bu sıranın ardından değerlendirilir.

---

## 1. Bu Belge Nasıl Kullanılacak?

Codex her geliştirme oturumunun başında sırasıyla şunları okumalıdır:

1. Kullanıcının o oturumdaki açık isteği.
2. Bu dosya: `CODEX.md`.
3. Repo kökündeki `CLAUDE.md` kod kalitesi ve mimari kuralları.
4. İlgili mevcut kaynak kodu ve testler.
5. Gerekli olduğunda `README.md` ve `docs/ios_widget_setup.md`.

`SANS_APP_GELISTIRME_PLANI.md`, uygulamanın ilk sürümünü kurmak için yazılmış
tarihsel plandır. Büyük bölümü zaten uygulanmıştır. Yeni oturumlarda yeniden
uygulanmayacak; yalnızca mevcut kararların gerekçesini anlamak için okunacaktır.

### Talimat önceliği

Bir çelişki varsa aşağıdaki sıra geçerlidir:

1. Kullanıcının güncel ve açık talimatı.
2. Güvenlik, veri kaybını önleme ve geriye uyumluluk kuralları.
3. `CODEX.md`.
4. `CLAUDE.md`.
5. Eski geliştirme planı ve eski yorum satırları.

Bu belge tek seferde bütünüyle uygulanacak bir “büyük yeniden yazım” değildir.
Her oturum aşağıdaki fazlardan yalnızca birini veya açıkça belirtilen küçük bir
alt adımı tamamlamalıdır. Her faz çalışır, testleri geçen bir ara ürün bırakır.

---

## 2. Codex Çalışma Sözleşmesi

### 2.1 Değiştirilemez kurallar

- Mevcut kullanıcı verileri silinmez ve Hive kutuları sıfırlanmaz.
- `LuckEngine` saf Dart kalır; Flutter veya platform import'u almaz.
- Aynı tohum, gün ve aynı açık algoritma girdileri aynı sonucu üretir.
- Saklanmış günlük sonuç, yeniden hesaplanan sonuçtan her zaman daha
  yetkilidir.
- Mevcut `LuckCategory` enum adları doğrudan yeniden adlandırılmaz. Bu adlar
  Hive içinde saklanmıştır; doğrudan değişiklik eski kayıtları bozar.
- Yeni kullanıcı deneyimi isimleri bir sunum/deneyim katmanıyla eşlenir.
- Riverpod dışındaki küresel state çözümleri kullanılmaz.
- `setState` yalnızca widget'a özel, kısa ömürlü animasyon veya form durumu
  için kullanılabilir.
- Yeni paket ancak mevcut SDK ve paketlerle çözülemeyen açık bir ihtiyaç varsa
  ve kullanıcı onayladıysa eklenir.
- Üretim kodunda geçici paywall, çalışmayan satın alma butonu, sahte başarı
  mesajı veya kullanıcıyı yanıltan doğrudan paylaşım butonu bırakılmaz.
- Kullanıcıya görünür hiçbir metin “kesin sonuç”, sağlık, para, yatırım,
  ilişki veya güvenlik kararı vaat etmez.
- Tasarım konseptlerindeki telefon çerçevesi, sunum başlığı ve açıklama
  etiketleri uygulama arayüzünün parçası değildir.
- Kullanıcıya ait veya kapsam dışı değişiklikler korunur. Özellikle başlangıç
  durumunda değiştirilmiş `android/gradle.properties` dosyasına gerekmedikçe
  dokunulmaz.
- Codex kullanıcı istemedikçe commit, merge, rebase veya branch silme işlemi
  yapmaz.

### 2.2 Her oturumun zorunlu başlangıcı

1. `git status --short` ile mevcut değişiklikleri belirle.
2. Fazın dokunacağı dosyaları oku; isimlere bakarak varsayım yapma.
3. İlgili mevcut testleri çalıştır ve başlangıç davranışını doğrula.
4. Değişiklik kapsamını tek cümleyle sabitle.
5. Veri şemasına dokunulacaksa önce geriye uyumluluk testini yaz.

### 2.3 Her oturumun zorunlu kapanışı

1. Değişen Dart dosyalarını `dart format` ile biçimlendir.
2. Fazın hedefli testlerini çalıştır.
3. `flutter analyze` çalıştır; sıfır hata ve sıfır uyarı beklenir.
4. Tam `flutter test` paketini çalıştır; testler yeşil olmalıdır.
5. Kullanıcıya şunları bildir:
   - Tamamlanan faz ve davranış.
   - Değişen önemli dosyalar.
   - Çalıştırılan testler ve sonuçları.
   - Gerçek cihazda kontrol edilmesi gereken maddeler.
   - Varsa dış bağımlılık veya karar engeli.

Bir fazın “tamamlandı” sayılması için yalnız kod yazılmış olması yetmez;
fazın kabul kriterleri ve testleri de tamamlanmalıdır.

---

## 3. Mevcut Uygulama: Korunacak Temel

Uygulama sıfırdan kurulmayacaktır. Aşağıdaki sistemler halihazırda vardır ve
gerekli yerlerde yeniden kullanılacaktır:

- Deterministik günlük skor motoru.
- Beş kategori skoru ve genel skor.
- Hive profil ve günlük kayıt depolaması.
- Riverpod provider katmanı.
- Günlük kart açılışı ve skor animasyonu.
- TR/EN dil seçimi.
- Akşam geri bildirimi.
- Geçmiş heatmap'i ve aylık özet.
- Günlük kart koleksiyonu.
- 1080×1920 paylaşım görseli üretimi.
- Yerel bildirimler.
- Android ana ekran widget'ı ve iOS WidgetKit hazırlığı.
- Ayarlar, erişilebilirlik testleri ve yasal eğlence ibaresi.

### Başlangıç kalite durumu

- `flutter analyze`: başarılı, sorun yok.
- `flutter test`: ilk ürün tabanında 212 test vardı; görsel testleriyle 214,
  FAZ 0 sonunda 217, FAZ 1 sonunda 225, FAZ 2 sonunda 234,
  FAZ 3 sonunda 253, FAZ 4 sonunda 288, FAZ 5 ve ek başlangıç
  düzenlemeleri sonunda 311 test başarılıdır.
- FAZ 0'da `test/categories/categories_test.dart` premium gate dokunma uyarısı,
  gerçek GestureDetector görünür alana getirilip hedeflenerek giderildi.
- `design/concepts/` altındaki üç PNG, yeni sanat yönünün kaynağıdır.

---

## 4. Yeni Ürün Tanımı

### 4.1 Tek cümlelik vaat

**Kader, geleceği tahmin etmeyen; sabah merak, gün içinde küçük bir oyun ve
akşam kişisel farkındalık sunan günlük şans ritüelidir.**

### 4.2 Kullanıcı döngüsü

1. Kullanıcı sabah uygulamayı veya widget'ı görür.
2. Günün kapalı işaret kartını açar.
3. Günlük puanı, gün arketipini ve beş yaşam alanını görür.
4. İsterse güvenli ve küçük bir “mikro görev” uygular.
5. Sonucu kişisel bilgi sızdırmadan story olarak paylaşabilir.
6. Akşam günün nasıl geçtiğini 10 saniyede işaretler.
7. Zamanla kendi ritmini, geri bildirimlerini ve kart koleksiyonunu
   “Desenlerim” ekranında görür.

### 4.3 Ürün ilkeleri

- **Merak var, kehanet yok.** Uygulama bir geleceği bildiğini iddia etmez.
- **Oyun var, kumar yok.** Para yatırma, bahis, kayıp telafisi, loot-box veya
  satın alınabilir rastgele ödül mekaniği bulunmaz.
- **Ritüel var, suçluluk yok.** Seri bozuldu mesajı, geri sayım baskısı,
  korku veya kaçırma tehdidi kullanılmaz.
- **Kişiselleştirme var, gereksiz veri yok.** Yeni onboarding doğum tarihi
  istemez. Veriler varsayılan olarak cihazda kalır.
- **Renkli ama yetişkin.** Oyuncu ve neşeli olabilir; çocuk oyunu, casino,
  neon cyberpunk veya klişe fal estetiğine dönüşmez.
- **Paylaşılabilir ama mahrem.** İsim ve geri bildirim story kartına varsayılan
  olarak girmez; skor da kullanıcı isterse gizlenebilir.
- **Açıklanabilir sınırlar.** Eğlence amaçlı olduğu onboarding, Profil ve
  gerekli paylaşım bağlamlarında açıkça belirtilir.

### 4.4 Ürün dışı kapsam

Bu dönüşümde aşağıdakiler yapılmayacaktır:

- Burç, doğum haritası, tarot, fal, medyum veya gerçek öngörü sistemi.
- Sosyal ağ, kullanıcı profili keşfi, arkadaş listesi veya mesajlaşma.
- Bulut hesap, senkronizasyon veya backend.
- Reklam SDK'sı veya davranışsal izleme.
- Sağlık, finans, hukuk veya ilişki kararı tavsiyesi.
- AI sohbeti veya kullanıcıya özel serbest metin kehanet üretimi.

---

## 5. Bilgi Mimarisi ve Hedef Ekranlar

Ana navigasyon üç sekmeden oluşur:

1. **Bugün**
2. **Desenlerim**
3. **Profil**

Kök navigasyon bir `IndexedStack` veya eşdeğer state koruyan yapı kullanmalı;
sekmeler arasında geçerken scroll ve seçili durum korunmalıdır.

### 5.1 Bugün

#### Açılmadan önce

- Sıcak krem arka plan.
- Tarih ve “Günaydın, {isim}” selamlaması.
- Ortada büyük, lacivert, dokulu, mühürlü günlük kart.
- Ana eylem: **“Bugünün işaretini aç”**.
- Kart açılmadan skor, kategori skorları ve arketip widget ağacına girmez.
- Bildirim ve widget kart açılmadan sayısal sonucu sızdırmaz.

#### Açılış sırasında

- Kart hafif 3B eğim ve folyo yansıması verir.
- Mühür nabız atar, hafif haptic gelir.
- Işık dikişi kart kenarında dolaşır.
- Kart katmanları yol ayrımı gibi açılır.
- Şerit, taş, tohum ve kâğıt uçak biçimli sınırlı parçacıklar yayılır.
- Çift dokunma yeni animasyon başlatmaz.

#### Açıldıktan sonra

- Arka plan kontrollü biçimde derin laciverte geçebilir.
- Büyük skor ve “{Arketip} Günü” başlığı.
- Arketipe ait özgün vektör illüstrasyon.
- Beş deneyim alanı: Akış, Bağ, Üretim, Cesaret, Denge.
- Günün tek mikro görevi.
- Paylaş butonu.
- Akşam saatinde ve feedback yoksa sakin geri bildirim kartı.
- Aynı gün tekrar açılışta sonuç doğrudan görünür; tam animasyon otomatik
  tekrarlanmaz.

### 5.2 Desenlerim

Tek, dikey kaydırılan bir ekran olarak aşağıdaki bölümleri içerir:

1. “Senin Desenin” başlığı.
2. Son 30 günün renkli ritim ızgarası.
3. Akşam geri bildirim eğrisi veya özet dağılımı.
4. “Bu ay sende en çok görünen alan” gibi nedensellik iddia etmeyen özet.
5. Şefkatli katılım bilgisi: “18 gündür ritüeldesin”.
6. Nadir işaret kartı ve son açılan koleksiyon öğeleri.
7. Tüm koleksiyona ve aylık özete geçiş.

“Kanıt Döngüsü” adı kullanılmayacaktır. Arayüz bir tahminin doğruluğunu
kanıtladığını söylememeli; yalnız kullanıcının kendi kayıtlarını betimlemelidir.

### 5.3 Profil

- Görünen ad veya rumuz.
- Dil: sistem / Türkçe / İngilizce.
- Sabah ve akşam hatırlatma ayarları.
- Hareket azaltma seçeneği; sistem ayarı varsayılan kaynak olmalı.
- Premium durumu ve satın alımı geri yükle eylemi, yalnız gerçek entegrasyon
  varsa.
- Gizlilik: verilerin cihazda tutulduğu açıklaması.
- Eğlence amaçlı kullanım ibaresi.
- Uygulama sürümü ve açık kaynak/lisans bilgileri.

### 5.4 Yardımcı yüzeyler

- Alan detay ekranı.
- Paylaşım düzenleyicisi.
- Akşam geri bildirim sheet'i veya ekranı.
- Koleksiyon detay sheet'i.
- Gerçek satın alma entegrasyonu varsa paywall.

---

## 6. Deneyim Alanları: Eski Veriyi Bozmadan Yeni Dil

Mevcut `LuckCategory` enum adları saklama formatında kullanıldığı için ilk
dönüşümde değiştirilmez. Saf Dart bir deneyim eşlemesi eklenir.

| Yeni kullanıcı alanı | Mevcut iç kategori | Anlam |
|---|---|---|
| Akış | `LuckCategory.sosyal` | Günün genel akıcılığı, karşılaşmalar, tempo |
| Bağ | `LuckCategory.ask` | Yakınlık, iletişim, dostluk, empati |
| Üretim | `LuckCategory.para` | Odak, iş, fikir, tamamlama, kaynak yönetimi |
| Cesaret | `LuckCategory.risk` | Küçük adımlar, deneme, inisiyatif |
| Denge | `LuckCategory.saglik` | Dinlenme, ritim, sınırlar, sakinlik |

### Uygulama kuralı

- `LuckCategory.values` sırası ve enum adları korunur.
- UI sırası yukarıdaki tabloda verilen yeni sıradır.
- Eşleme `lib/core/content/experience_dimension.dart` gibi saf Dart bir
  dosyada tek doğruluk noktası olarak tanımlanır.
- Renk, ikon ve yerelleştirilmiş etiket eşlemeleri dağınık `switch`
  bloklarında tekrarlanmaz.
- İç kategori adları kullanıcı metinlerine sızmaz.
- Paywall'da mevcut kilit mantığının karşılığı **Bağ** ve **Üretim** olur.
- Kilitli değerler semantics, paylaşım PNG'si, widget veya debug metniyle
  sızdırılmaz.

---

## 7. Günlük Deneyim Modeli

Sayısal `LuckResult` doğrudan UI modeli yapılmamalıdır. Saf Dart bir
`DailyExperience` görünüm modeli üretilmelidir.

Önerilen alanlar:

```text
DailyExperience
  date
  score
  archetype
  dominantDimension
  orderedDimensions
  microMission
  shortReflection
  illustrationId
  cardVariantId
```

### 7.1 Gün arketipi

Baskın deneyim alanına göre beş temel arketip bulunur:

- Akış Günü
- Bağ Günü
- Üretim Günü
- Cesaret Günü
- Denge Günü

Eşit skorda mevcut deterministik enum sırası kullanılmalı; map ekleme sırasına
güvenilmemelidir. Arketip, illüstrasyon ve mikro görev aynı saklanmış sonuçtan
üretilmelidir.

### 7.2 Mikro görev

Mikro görevler:

- 20 saniye ile 10 dakika arasında uygulanabilir olmalı.
- Para harcamayı, riskli davranışı, sağlık kararını veya yabancıyla tehlikeli
  etkileşimi teşvik etmemeli.
- Bir eylem fiiliyle başlamalı.
- Sonucu garanti etmemeli.
- TR ve EN havuzları aynı indeks yapısını korumalı.
- Aynı kullanıcı, gün ve amaç için deterministik seçilmelidir.
- Ardışık gün tekrarını önleyen mevcut seçim altyapısını kullanmalıdır.

Örnekler:

- “Bugün farklı bir yol dene.”
- “Bir işi bitirmeden önce iki dakika sadeleştir.”
- “Uzun zamandır konuşmadığın birine kısa bir selam gönder.”
- “Bir karar vermeden önce tek bir derin nefes al.”
- “Masanda yalnızca bir şeyi yerine koy.”

### 7.3 Günlük durum makinesi

UI aşağıdaki açık durumları kullanmalıdır:

```text
loading -> concealed -> revealing -> revealed -> feedbackAvailable -> feedbackDone
                  \-> error (yeniden dene)
```

- `concealed`: sonuç depoda bulunabilir ama kullanıcıya gösterilmez.
- `revealing`: tek seferlik animasyon sürer, giriş kilitlidir.
- `revealed`: sonuç gösterilir ve açılma zamanı saklanmıştır.
- `feedbackAvailable`: yerel saate göre akşam penceresi gelmiş ve feedback
  verilmemiştir.
- `feedbackDone`: o günün geri bildirimi kaydedilmiştir.

Bu durumlar yalnız widget içindeki geçici bool'larla modellenmemeli; günlük
kaydın kalıcı alanları ve türetilmiş provider'lar kullanılmalıdır.

---

## 8. Veri ve Geriye Uyumluluk Planı

### 8.1 Profil kimliği ve doğum tarihi

Yeni kullanıcı onboarding'i doğum tarihi istemeyecektir. Doğum tarihi
astroloji algısını güçlendirir ve ürün için gereksiz kişisel veridir.

Geriye uyumlu model:

- `UserProfile.dogumTarihi` eski profiller için okunmaya devam eder ve nullable
  hale getirilir.
- `UserProfile` içine `rituelKimligi` ve `seedSurumu` eklenir.
- Eski map'te `seedSurumu` yoksa sürüm 1 kabul edilir; mevcut isim + doğum
  tarihi seed'i değişmeden kullanılır.
- Yeni profiller sürüm 2 olur; `Random.secure` tabanlı, bir kez üretilip Hive'a
  kaydedilen anonim bir ritüel kimliği kullanır.
- Rastgele kimlik üretimi profile getter içinde yapılmaz. Tek seferlik üretim
  ayrı, testte değiştirilebilir bir factory/provider üzerinden yapılır.
- Sürüm 2'de görünen ad değiştirilse bile günlük sonuç değişmez.
- Eski profiller otomatik ve geri döndürülemez biçimde yeni seed'e taşınmaz.
- Yeni bir paket eklenmez; `dart:math` ve mevcut `crypto` yeterlidir.

Zorunlu testler:

- Eski profil map'i sorunsuz açılır.
- Eski profil için sabit bir tarih ve skor golden değeri değişmez.
- Yeni profil doğum tarihi olmadan round-trip yapar.
- Yeni profilde görünen ad değişikliği seed'i değiştirmez.
- Bildirim/dil tercihleri hiçbir seed sürümünü değiştirmez.

### 8.2 Günlük kayıt

`DailyRecord` geriye uyumlu olarak şu alanları kazanır:

- `DateTime? revealedAt`
- `FeedbackMood? feedbackMood` (`positive`, `neutral`, `difficult`)
- `List<String> feedbackTags` veya sabit enum kimlikleri

Mevcut `feedbackPozitif` alanı eski kayıtları okumak için korunur veya bir
migration adapter'ıyla şu şekilde çevrilir:

- `true` → `positive`
- `false` → `difficult`
- `null` → feedback yok

`copyWith` nullable alanları gerçekten temizleyebilecek sentinel yaklaşımına
geçmelidir; mevcut `??` kalıbı null'a dönüşü engeller.

Zorunlu testler:

- Eski daily record map'i açılır ve yeniden yazılmadan okunabilir.
- Reveal zamanı round-trip yapar.
- Aynı gün ikinci reveal çağrısı zamanı veya sonucu değiştirmez.
- Üç feedback durumu round-trip yapar.
- Eski boolean feedback doğru yeni duruma çevrilir.
- Hiçbir migration günlük skor veya kategori skorlarını değiştirmez.

### 8.3 Algoritma sınırı

Bu görsel ve deneyim dönüşümünde skor formülü değiştirilmeyecektir. Mevcut
ay evresi/numeroloji modifiyerleri kullanıcıya gösterilmeyecek ve yeni metin
dilinin kaynağı olmayacaktır. İleride formül kaldırılacaksa bu ayrı bir
algoritma sürümü ve ayrı migration planı gerektirir.

---

## 9. Görsel Sistem — “Modern Tesadüf”

### 9.1 Kaynak görseller

Codex aşağıdaki dosyaları sanat yönü olarak kullanmalıdır:

- `design/concepts/kader-product-vision.png`
- `design/concepts/kader-reveal-motion-storyboard.png`
- `design/concepts/kader-share-ecosystem.png`
- `design/catalog/kader-production-assets.png` — tüm üretim asset'lerinin
  birlikte ölçek ve tutarlılık kontrolü.

Üretilmiş yüksek çözünürlüklü arketip master'ları:

- `design/source/archetypes/archetype_akis.png`
- `design/source/archetypes/archetype_bag.png`
- `design/source/archetypes/archetype_uretim.png`
- `design/source/archetypes/archetype_cesaret.png`
- `design/source/archetypes/archetype_denge.png`

Bu görseller ilham ve kompozisyon kaynağıdır; içlerindeki sunum etiketleri,
telefon donanımı, olası yazım hataları veya mock tarihleri kopyalanmaz.
`design/source` altındaki master PNG'ler doğrudan uygulama bundle'ına eklenmez;
uygulama aşağıdaki optimize WebP karşılıklarını kullanır.

### 9.2 Renk token'ları

Renkler yalnız `core/theme` içinde semantik token olarak tanımlanır. İlk hedef
değerler:

| Token | Değer | Kullanım |
|---|---:|---|
| Ink | `#07162F` | Açılmış ana ekran, koyu kartlar |
| Ink Surface | `#10213B` | Koyu yüzey ve ikincil kart |
| Warm Cream | `#F7F0E5` | Açılmamış ekran, Desenlerim, Profil |
| Cream Surface | `#FFF9F0` | Açık kart yüzeyleri |
| Electric Lime | `#D8F04A` | Ana eylem, Akış, skor vurgusu |
| Warm Coral | `#FF8B73` | Bağ ve sıcak vurgu |
| Iris | `#9B8AF2` | Üretim ve ikincil vurgu |
| Ice Blue | `#BFE5F2` | Denge ve sakin yüzey |
| Soft Gold | `#D3A953` | Folyo çizgisi; ana CTA rengi değil |
| Text on Ink | `#F8F2E8` | Koyu zemin ana metni |
| Text on Cream | `#12203A` | Açık zemin ana metni |
| Muted | `#596477` | İkincil açık zemin metni; AA için koyulaştırıldı |

Kodlamadan önce gerçek kontrast oranları kontrol edilmeli; AA'yı geçmeyen
kombinasyon düzeltilmelidir. Renk tek başına anlam taşımamalıdır.

### 9.3 Tipografi

- Başlık: mevcut Playfair Display korunabilir.
- Gövde ve kontroller: mevcut Inter korunabilir.
- Büyük skor için tabular figures veya görsel olarak sabit genişlik
  sağlanmalıdır.
- Metinler 200% text scale'da taşmamalı; zorunlu sabit yüksekliklerden
  kaçınılmalıdır.
- Uzak sunucudan font indirmeye güvenen test kurulumu oluşturulmamalıdır.

### 9.4 Şekil dili

- Ana motif: kemerli kapı ve içinden geçen yol.
- Yardımcı motifler: kesişen yollar, şerit, çakıl taşı, tohum, yaprak, kâğıt
  uçak, açık pencere, küçük köprü.
- Köşeler yuvarlak ama her şey aynı kapsül biçiminde olmamalıdır.
- Altın yalnız ince folyo, mühür ve çizgi vurgusudur.
- Cam efekti yalnız okunabilirliği bozmadığı küçük yüzeylerde kullanılır.
- Dokular çok hafif olmalı; PNG gürültüsü yerine gerektiğinde CustomPainter
  veya küçük optimize asset kullanılmalıdır.

### 9.5 Kesinlikle kullanılmayacak görsel klişeler

- Burç ve takımyıldızları.
- Kristal küre.
- Tarot sembolizmi.
- Aşırı ay, yıldız ve galaksi.
- Dört yapraklı yoncanın ana marka sembolü olarak devamı.
- Zar, casino fişi, slot veya bahis çağrışımı.
- Genel mor-altın fal uygulaması görünümü.
- Yoğun neon ve bilimkurgu HUD görünümü.

---

## 10. Çizim ve Asset Manifestosu

Bu bölümde adı verilen üretim çizimleri 2 Eylül 2026 tarihinde oluşturulmuş ve
repo içine eklenmiştir. Codex bu asset'leri placeholder ile değiştirmeyecek,
yeniden üretmeyecek veya ekrana benzer şekilleri widget koduyla tekrar
çizmeyecektir. Gerekli olduğunda mevcut dosyayı tüketen API'yi yazacaktır.

Hazır ikon paketi görsel kimliğin yerine geçmez. Sistem ikonları yalnız ayarlar,
geri, kapat ve paylaş gibi standart işlevlerde kullanılabilir.

### 10.1 Marka asset'leri

- `assets/svg/kader_mark.svg` — kemer + yol ana işareti.
- `assets/svg/kader_card_back.svg` — kapalı günlük kart.
- `assets/svg/kader_path_pattern.svg` — açık/koyu zeminde düşük opaklıklı yol
  deseni.
- `assets/svg/kader_empty_path.svg` — boş durum illüstrasyonu.

“Kader” kelimesi lokalize edilmediği ve erişilebilir metin olarak kalması
gerektiği için wordmark görseli kullanılmaz; marka işaretinin yanında gerçek
Flutter `Text` widget'ı kullanılır.

### 10.2 Deneyim alanı ikonları

- `assets/svg/dimension_akis.svg` — akan çizgiler.
- `assets/svg/dimension_bag.svg` — birleşen iki yol.
- `assets/svg/dimension_uretim.svg` — filizlenen fikir.
- `assets/svg/dimension_cesaret.svg` — yönünü seçen kâğıt uçak.
- `assets/svg/dimension_denge.svg` — dengeli taşlar ve yaprak.

Kurallar:

- 24×24 viewBox.
- 1.75–2 px yuvarlak stroke.
- `currentColor` veya tek noktadan renklendirilebilir yapı.
- Küçük boyutta ayırt edilebilir siluet.
- Her SVG dosyasının başında açıklama yorumu.

### 10.3 Gün arketipi illüstrasyonları

- `assets/images/archetypes/archetype_akis.webp` — kıvrılan yol, açık kapı ve
  kâğıt uçak.
- `assets/images/archetypes/archetype_bag.webp` — birleşen iki patika, köprü ve
  iki renkli şerit.
- `assets/images/archetypes/archetype_uretim.webp` — tohumdan düzenli yapıya
  ilerleyen üretim yolu.
- `assets/images/archetypes/archetype_cesaret.webp` — yol ayrımından açık
  kemere yükselen kâğıt uçak.
- `assets/images/archetypes/archetype_denge.webp` — taş, yaprak, sakin su ve
  yansıyan kemer.

Üretim dosyaları 1024×768, 4:3 WebP ve kalite 88'dir. Tam çözünürlüklü PNG
master'ları `design/source/archetypes/` altında korunur. Uygulama yalnız WebP
dosyalarını bundle eder. `BoxFit.cover` kullanılabilir; fakat önemli ögeler
güvenli iç alanda olduğu için kırpma yatay/dikey merkezde tutulmalıdır.

### 10.4 Koleksiyon/Nadir İşaret seti

İlk setin 12 tam sahne illüstrasyonu hazırdır. Bunlar basit sembol veya ikon
değil; her biri kendi yol, bitki, mimari ve anlatı katmanlarına sahip 5:7
koleksiyon kartlarıdır. Görselin içine başlık yazılmaz; başlık ve kilit durumu
gerçek Flutter widget'larıyla TR/EN gösterilir.

| Kimlik ve başlık | Üretim dosyası | Önerilen şeffaf açılma koşulu |
|---|---|---|
| Açık Kapı | `assets/images/rare_signs/rare_acik_kapi.webp` | İlk kart açılışı |
| Kesişen Yollar | `assets/images/rare_signs/rare_kesisen_yollar.webp` | İlk akşam feedback'i |
| Sessiz Tohum | `assets/images/rare_signs/rare_sessiz_tohum.webp` | 3 farklı kullanım günü |
| Uçan Not | `assets/images/rare_signs/rare_ucan_not.webp` | İlk paylaşım |
| Dengeli Taş | `assets/images/rare_signs/rare_dengeli_tas.webp` | 5 feedback günü |
| Yeni Patika | `assets/images/rare_signs/rare_yeni_patika.webp` | 7 farklı kullanım günü |
| Geri Dönen Şerit | `assets/images/rare_signs/rare_geri_donen_serit.webp` | Bir aradan sonra geri dönüş |
| Küçük Köprü | `assets/images/rare_signs/rare_kucuk_kopru.webp` | 10 feedback günü |
| Açık Pencere | `assets/images/rare_signs/rare_acik_pencere.webp` | 14 farklı kullanım günü |
| Beklenmedik Durak | `assets/images/rare_signs/rare_beklenmedik_durak.webp` | 21 farklı kullanım günü |
| Yan Yana İzler | `assets/images/rare_signs/rare_yan_yana_izler.webp` | Beş arketipin tümünü görme |
| Parlak Yol | `assets/images/rare_signs/rare_parlak_yol.webp` | Genel skorun en az 92 olduğu gün |

Üretim dosyaları 800×1120, 5:7 WebP ve kalite 88'dir. Tam çözünürlüklü PNG
master'ları ve üretim prompt kaydı `design/source/rare_signs/` altında korunur.
İlk sade SVG denemeleri üretimde kullanılmaz; karşılaştırma ve geri dönüş için
`design/source/rare_signs/vector_drafts/` altında arşivlenmiştir. Uygulama
yalnız WebP kartları bundle eder. Kartın bütün yüzeyini doldurmak için
`BoxFit.cover` ve merkez hizası kullanılır; üstüne gelecek metin, kilit ve CTA
için dış kart kabuğu ayrı Flutter katmanıdır.

Nadirlik para ile satın alınmaz. Kilit açma şartı şeffaf, deterministik ve
ürün içi davranışa bağlıdır. Örnek: ilk kart açılışı, üç feedback, yedi farklı
gün, belirli arketipleri görme. Satın alınabilir rastgele ödül yoktur.

### 10.5 Native marka çıktıları

SVG kimliği onaylandıktan sonra en son fazda:

- `assets/launcher/icon.png`
- `assets/launcher/icon_foreground.png`
- `assets/launcher/splash.png`
- Android adaptive icon kaynakları.
- iOS AppIcon kaynakları.
- Widget önizleme/placeholder görselleri.

üretilir. Eski launcher dosyaları yeni ikon görsel olarak doğrulanmadan
üzerine yazılmaz.

### 10.6 Asset doğrulama

- Tüm SVG'ler `flutter_svg` ile parse testinden geçer.
- Beş arketip WebP, codec ile açılma ve 4:3 oran testinden geçer.
- On iki Nadir İşaret WebP, codec ile açılma ve 5:7 oran testinden geçer.
- 1×, 2× ve küçük ikon boyutunda kırpılma kontrol edilir.
- Kullanılmayan eski astroloji asset'leri ancak tüm referanslar kaldırıldıktan
  sonra silinir.
- Asset silme ayrı, geri alınabilir bir temizlik adımıdır.

### 10.7 Uygulamada kullanım sırası

Codex asset entegrasyonunu aşağıdaki sırayla yapar. Bir sonraki satıra geçmeden
önce ilgili ekran testi tamamlanır.

| Sıra | Asset | İlk kullanım | Kod erişimi |
|---:|---|---|---|
| 1 | `kader_mark.svg` | Welcome, hesaplama, Profil/Hakkında | `AppIllustrations.kaderMark()` |
| 2 | `kader_card_back.svg` | Bugün / concealed | `AppIllustrations.kaderCardBack()` |
| 3 | `kader_path_pattern.svg` | Welcome ve açık yüzey dekoru | `AppIllustrations.pathPattern()` |
| 4 | Beş `dimension_*.svg` | Reveal sonrası alan strip'i ve detay | `AppIcons.dimension(...)` |
| 5 | Beş `archetype_*.webp` | Reveal sonrası ana illüstrasyon | `AppIllustrations.archetype(...)` |
| 6 | `kader_empty_path.svg` | Desenlerim/koleksiyon boş durum | `AppIllustrations.emptyPath()` |
| 7 | On iki `rare_*.webp` | Nadir İşaret kartları ve detay sheet | `AppIllustrations.rareSign(...)` |
| 8 | Mark + arketip + nadir kartlar | Story şablonları | Mevcut share renderer üzerinden |
| 9 | Sadeleştirilmiş mark | Launcher, splash, bildirim, widget | FAZ 16 native çıktıları |

`AppIllustrations.archetype` ve `rareSign` dosya yolunu UI içinde string
birleştirerek üretmez. `ExperienceDimension` ve `RareSignId` için const map tek
doğruluk noktasıdır. Eksik map değeri release'te sessiz placeholder'a düşmez;
testte yakalanır.

### 10.8 Kompozisyon kuralları

- Aynı viewport'ta bir büyük arketip illüstrasyonu bulunur; diğer büyük
  görseller lazy olarak yüklenir.
- WebP `cacheWidth` cihaz piksel oranına göre sınırlandırılır; 1024 px master
  gereksiz çözünürlükte decode edilmez.
- Story render 1080×1920 olduğunda aynı WebP tekrar kullanılabilir; düşük
  çözünürlüklü thumbnail dosyası büyütülmez.
- Nadir kart WebP'sinin içine skor, başlık, tarih veya kilit durumu çizilmez.
  Bu bilgiler erişilebilir Flutter widget'ları olarak üzerine yerleşir.
- Kart arkası pre-reveal durumunda skor veya arketip asset'i build edilmez.

---

## 11. Hareket ve Efekt Sistemi

### 11.1 Açılış koreografisi

Hedef toplam süre 1.4–1.8 saniyedir:

1. Basma/tilt: 120–180 ms.
2. Mühür nabzı + `HapticFeedback.selectionClick`: yaklaşık 180 ms.
3. Işık dikişi: 420–520 ms.
4. Katman açılması: 480–600 ms.
5. Parçacık bloom: 500–700 ms; önceki adımla örtüşebilir.
6. Skor ve alanların girişi: 500–700 ms.

Animasyonlar `AnimationController`, `TweenSequence`, `AnimatedBuilder` ve
CustomPainter ile kurulabilir. Yeni animasyon paketi gerekmez.

### 11.2 Performans

- Kart, ışık dikişi ve parçacık katmanları ayrı `RepaintBoundary` olur.
- Controller değeri geniş widget ağacını rebuild etmez.
- Painter listeleri her frame yeniden üretilmez.
- Parçacık sayısı cihazdan bağımsız sabit ve ölçülüdür.
- Görünmeyen animasyon controller'ları durdurulur.
- Profil modunda düşük/orta segment Android cihazda gözle görülür jank
  olmamalıdır.

### 11.3 Hareket azaltma

`MediaQuery.disableAnimations` ve kullanıcı tercihi birlikte ele alınır.
Hareket azaltıldığında:

- 3B tilt, parçacık ve ani scale kaldırılır.
- 150–200 ms çapraz fade kullanılır.
- Sonuç ve semantics aynı kalır.
- Testlerde reduced-motion dalı doğrulanır.

### 11.4 Haptic

- Haptic yalnız kullanıcı eylemiyle başlar.
- Mühürde hafif, sonuçta en fazla bir orta seviye geri bildirim.
- Her frame veya alan girişi için ayrı haptic yoktur.
- Sistem erişilebilirlik/haptic tercihleri ihlal edilmez.

---

## 12. İçerik ve Yazım Standardı

### 12.1 Ton

- Sıcak, kısa, hafif meraklı.
- Kullanıcının karar verme gücünü elinde tutar.
- Kesinlik yerine olasılık ve oyun dili kullanır.
- “Bugün kesin…”, “Evren söylüyor…”, “Yıldızlar garantiliyor…” demez.
- Cinsiyet, yaş, medeni durum veya kültürel varsayım yapmaz.

### 12.2 Zorunlu ana metinler

- Karşılama: **“Gününü tahmin etme. Ona bir işaret bırak.”**
- Ana eylem: **“Bugünün işaretini aç”**
- Desen başlığı: **“Senin Desenin”**
- Widget: **“Bugünün işareti hazır”**
- Sabah bildirim örneği: **“Kartın seni bekliyor.”**
- Akşam bildirim örneği: **“Günün nasıl geçti? 10 saniyede işaretle.”**

İngilizce karşılıkları aynı anlamı taşımalı; birebir kötü çeviri olmamalıdır.

### 12.3 Yasaklı veya temizlenecek kullanıcı dili

Yeni kullanıcı metinlerinde şu ifadeler yer almamalıdır:

- “falında”
- “yıldızlar senin için dizildi”
- “ay evresi işini yaptı”
- “şans perileri”
- “kristal küre”
- “evren bugün ne fısıldıyor”
- “kesin olacak”, “garanti”, “kaçırırsan”
- “para kazanacaksın”, “sağlığın düzelecek” gibi sonuç vaatleri

İçerik havuzları için basit bir kelime/ifade regresyon testi yazılmalı; test
yalnız substring kontrolü değil, yeni eklenen tüm TR/EN havuzlarını dolaşmalıdır.

### 12.4 Şans rengi, sayı ve saat

- Şans rengi, şanslı sayı ve şanslı saat ana “Bugün” ekranından kaldırılır.
- Mevcut deterministik üretim kodu ilk aşamada veri uyumu için kalabilir.
- Şanslı saat push bildirimi yeni deneyimde planlanmaz.
- Sonraki temizlikte kullanılmayan UI ve bildirim kodu testleriyle birlikte
  kaldırılır; skor motoruna aynı fazda dokunulmaz.

---

## 13. Hedef Kod Yapısı

Mevcut feature-first yapı korunur. Gerekli yeni dosyalar küçük ve anlamlı
eklemeler olarak yapılır:

```text
lib/
  core/
    content/
      experience_dimension.dart
      daily_archetype.dart
      daily_experience.dart
      daily_experience_composer.dart
      mission_pools.dart
    storage/
      ... mevcut dosyalar
    theme/
      app_colors.dart
      app_dimens.dart
      app_motion.dart
      app_theme.dart
  features/
    shell/
      app_shell.dart
      shell_strings.dart
    daily_luck/
      ... mevcut dosyalar
      widgets/
        sealed_daily_card.dart
        reveal_daily_card.dart
        dimension_strip.dart
        micro_mission_card.dart
    patterns/
      patterns_screen.dart
      patterns_providers.dart
      patterns_strings.dart
      widgets/
        rhythm_grid.dart
        feedback_trend.dart
        rare_sign_card.dart
    share/
      share_composer_screen.dart
      share_template.dart
      ... mevcut render servisi
    feedback/
      ... mevcut dosyalar
    profile/
      profile_screen.dart
  shared/widgets/
    kader_scaffold.dart
    kader_card.dart
    kader_button.dart
    kader_bottom_navigation.dart
    app_icons.dart
```

Notlar:

- Mevcut `history` ve `collection` mantığı silinmez; `patterns` ekranı bunları
  provider ve saf analiz katmanı üzerinden birleştirir.
- Büyük dosyalar yalnız sırf satır sayısını azaltmak için bölünmez. Bileşen
  bağımsız test edilebilir veya birden fazla ekranda kullanılabilir olduğunda
  ayrılır.
- Her feature'ın metinleri kendi `*_strings.dart` dosyasında TR/EN olarak
  tutulur.
- Genel widget'lar gerçekten birden fazla feature kullanıyorsa `shared` içine
  taşınır.

---

## 14. Adım Adım Uygulama Fazları

Fazlar sırayla uygulanmalıdır. Bir fazın kabul kriterleri bitmeden sonraki
faza geçilmez.

### FAZ 0 — Başlangıç Fotoğrafı ve Test Temizliği

Durum: tamamlandı (3 Eylül 2026). Beş motor golden örneği ve ortak legacy
Hive fixture'ları eklendi; 217 test geçti, analiz temiz.

**Amaç:** Dönüşüm öncesi güvenli tabanı sabitlemek.

Görevler:

1. Mevcut değişiklikleri kaydetmeden yalnız `git status` ile envanter çıkar.
2. `flutter analyze` ve `flutter test` sonucunu doğrula.
3. `categories_test.dart` hit-test uyarısını gerçek görünürlük/dokunma akışıyla
   düzelt.
4. Beş sabit kullanıcı/gün örneği için genel skor ve kategori skorlarını
   golden veri olarak teste ekle. Bu test UI dönüşümünün motoru yanlışlıkla
   değiştirmesini yakalar.
5. Mevcut eski Hive map fixture'larını test kaynaklarında sabitle.

Dokunulacak alan: yalnız testler; üretim davranışı değişmez.

Kabul:

- Tüm testler uyarısız geçer.
- Motor golden fixture'ı vardır.
- Eski profil ve daily record fixture'ı vardır.

### FAZ 1 — Deneyim Alanı Adapter'ı

Durum: tamamlandı (5 Eylül 2026). `experience_dimension.dart` saf eşlemesi,
TR/EN adları, açık gösterim sırası, eski motor sırasına göre eşitlik seçimi ve
`alanKilitliProvider` eklendi. Eski kategori provider'ı aynı politikayı izler.
Sekiz yeni test dahil 225 test geçti; analiz temiz. Ekran görünümü bu fazda
değişmedi. Bu fazın devamındaki içerik katmanı FAZ 2'de tamamlandı.

**Amaç:** Yeni Akış/Bağ/Üretim/Cesaret/Denge dilini veri kaybı olmadan kurmak.

Görevler:

1. Saf Dart `ExperienceDimension` modelini ekle.
2. Beş yeni alanı mevcut `LuckCategory` değerlerine tek noktadan eşle.
3. UI gösterim sırasını açıkça tanımla.
4. TR/EN etiketleri ekle.
5. Baskın alan seçim fonksiyonunu yaz; eşitlik deterministik olsun.
6. Premium kilit eşlemesini adapter üzerinden okunabilir hale getir.

Bu fazda hiçbir mevcut ekranın görünümü değiştirilmez.

Testler:

- Bire bir ve ters eşleme.
- Gösterim sırası.
- Eşit skor baskın alanı.
- TR/EN etiketleri.
- Mevcut `LuckCategory.values` sırasının değişmediğine dair regresyon.

### FAZ 2 — Günlük Deneyim ve Yeni İçerik

Durum: tamamlandı (5 Eylül 2026). Beş `DailyArchetype`, değiştirilemez
`DailyExperience` ve `composeDailyExperience` eklendi. Her alanda 20, toplam
100 mikro görev TR/EN çiftiyle `mission_pools.dart` içindedir. Eski
`FortunePools` / `CategoryPools` API'leri yeni düşünme davetleriyle beslenir;
mevcut ekranların metinleri de bu kaynaktan yenilenmiştir. Dokuz yeni test
dahil 234 test geçti; motor golden sonuçları değişmedi.

Entegrasyon notları:

- Composer `sonuc.gun` ve saklanmış skorları kullanır; `hesapla` çağırmaz.
- `microMissionId`, arketip ve illüstrasyon kimliği dil değişince korunur.
- Görev havuzları takvim günü paritesine göre iki ayrık gruba bölünür;
  grup içinde mevcut `tekrarsizSecimIndeksi` kullanılır. Böylece önceki ham
  indeksle sınırlı eski kontrolün nihai seçim tekrarı da önlenir.
- Kimlik, havuz sırası, grup sayısı ve `mission_v1` seçim amacı sürüm
  sözleşmesidir; bunlar gelişigüzel değiştirilmez. TR/EN aynı kayıttadır.
- `orderedDimensions` ham skor taşır. FAZ 8 ve 13'te kilitli değerler UI,
  semantics ve paylaşım görünümüne girmeden filtrelenmelidir.
- `illustrationId` ve ilk sürüm `cardVariantId`, mevcut arketip görselinin
  uzantısız adıdır. Asset yolu eşlemesi FAZ 5'te yapılır.
- Yeni modelin ekran yerleşimi FAZ 8'de bağlanacak. Bildirim, onboarding ve
  diğer feature metinlerinin kalan dönüşümü kendi fazlarında yapılacak.

Bu fazın devamındaki profil ve günlük kayıt migration'ı FAZ 3'te tamamlandı.

**Amaç:** UI'nın tüketebileceği arketip + mikro görev modelini üretmek.

Görevler:

1. `DailyArchetype`, `DailyExperience` ve composer'ı ekle.
2. Beş arketip için TR/EN başlık ve kısa reflection yaz.
3. Her alan için yeterli mikro görev havuzu oluştur; ilk sürümde alan başına
   en az 20 görev hedeflenir.
4. Mevcut `LuckResult` ve seed altyapısından deterministik seçim yap.
5. Eski fal ağırlıklı metinleri yeni tonla yeniden yaz.
6. Yasaklı ifade regresyon testini ekle.
7. TR ve EN havuzlarının indeks uyumunu test et.

Kabul:

- Aynı girdi aynı `DailyExperience` üretir.
- 30 günlük örnekte arketip, görev ve illüstrasyon kimliği boş değildir.
- Yeni içerikte yasaklı fal/garanti dili yoktur.
- Sayısal motor sonuçları golden fixture ile aynıdır.

### FAZ 3 — Profil ve Günlük Kayıt Migration'ı

Durum: tamamlandı (5 Eylül 2026). 19 yeni test dahil 253 test geçti;
`flutter analyze` temiz. Hedefli depolama/motor paketi: 91 test başarılı.

Uygulanan sözleşme ve sonraki fazlara entegrasyon notları:

- `UserProfileFactory` 32 baytlık `Random.secure` kimliği üretir.
  `userProfileFactoryProvider` testte değiştirilebilir. FAZ 7 onboarding'i
  `UserRepository.profilOlustur(isim: ..., factory: ...)` çağrısını beklemeli;
  widget build veya `seed` getter'ında profil/kimlik üretmemelidir.
- Yeni factory profili v2, doğum tarihsiz ve bildirimleri kapalı oluşturur.
  Mevcut profil varsa `profilOlustur` aynısını döndürür; eski kullanıcı
  otomatik v2'ye geçirilmez. Eski kurucu/onboarding bu aşamada korunmuştur.
- `UserSeed.fromRituelKimligi` kimliği `kader:rituel:v2:` önekiyle hash'ler;
  mevcut motorun tarih girdisi için `DateTime.utc(2000)` sabiti kullanılır.
  Bu tarih kullanıcıya ait değildir ve profilde doğum tarihi olarak saklanmaz.
  Önek ve sabit tarih v2 algoritma sözleşmesidir, gelişigüzel değiştirilmez.
  Skor formülü ve v1 isim/doğum tarihi girdileri değiştirilmemiştir.
- `DailyRecord` artık `revealedAt`, `FeedbackMood` ve değiştirilemez
  `feedbackTags` listesi taşır. Etiket kimlikleri yeni UI'da
  `ExperienceDimension.name` olmalıdır; ekranda yerelleştirilmiş ad gösterilir.
- Eski bool `true/false/null` → `positive/difficult/null`. Yeni mood anahtarı
  varsa açık null dahil önceliklidir. Nötr yanıt eski bool adapter'ında null
  döner; yanıt varlığı yeni ekranlarda `feedbackMood != null` ile kontrol edilir.
- `copyWith` açık null ile reveal, mood, emoji ve nullable profil tercihlerini
  temizler. Kalıcı kimlik, seed sürümü ve eski doğum tarihi tercih düzenleme
  metodundan değiştirilemez. Günlük skor kopyalanırken aynen korunur.
- FAZ 9 açılış tamamlanınca `revealKaydet(gun, revealedAt: ...)` çağrısını
  beklemeli. Tekrar çağrı ilk zamanı korur; olmayan güne kayıt üretmez.
- FAZ 12 `feedbackDurumuKaydet(gun, mood: ..., tags: ...)` kullanmalı.
  Bu yazım reveal/skoru korur, eski emojiyi temizler ve yalnız verilen güne
  işler. Eski `feedbackKaydet` iki seçenekli ekran için geçici olarak çalışır.
- `gunlukKayitProvider(gun)` kalıcı kart durumunu sağlar. Hive değişiklikleri
  `aktifProfilProvider` ve `tumKayitlarProvider` tüketicilerini ekran açıkken
  de yeniler; yalnız geri dönünce yenilenmeye güvenilmez.
- Eski map okumaları depoyu yeniden yazmaz. Bozuk tarih, tür, seed sürümü ve
  mood verisi anlaşılır `FormatException` verir; hata halinde kutu silinmez.
- Testler gerçek geçici Hive kutularını kapatıp yeniden açarak kimlik/reveal
  kalıcılığını; eşzamanlı çağrılarda ilk zamanı ve skorların korunmasını denetler.

Bu faz altyapı fazıdır: doğum tarihini formdan kaldırma FAZ 7, kart açılışını
bu kayda bağlama FAZ 8–9, üç seçenekli geri bildirim arayüzü FAZ 12 kapsamındadır.
Gerçek cihazda uygulamayı kapatıp yeniden açma ve canlı dil/geçmiş yenilemesi
manuel doğrulama bekler; otomatik test sonucu cihaz testi yerine geçmez.

Bu fazın devamındaki tema ve ortak UI temeli FAZ 4'te tamamlandı.

**Amaç:** Yeni kullanıcıdan doğum tarihi istemeden deterministik kimlik ve
kalıcı reveal/feedback durumu sağlamak.

Görevler:

1. `UserProfile` geriye uyumlu seed sürümünü ve ritüel kimliğini desteklesin.
2. Testte override edilebilir anonim kimlik factory'si ekle.
3. `DailyRecord` reveal zamanı ve üç durumlu feedback'i desteklesin.
4. Eski map'ler varsayılanlarla okunabilsin.
5. Repository'ye idempotent `revealKaydet` ve yeni feedback metodu ekle.
6. Provider'lar reveal/feedback değişiminde doğru invalidate edilsin.

Kabul:

- Eski veriler açılır ve skorlar değişmez.
- Yeni profil doğum tarihi olmadan çalışır.
- Aynı gün ikinci reveal kalıcı durumu bozmaz.
- Migration başarısızsa veri silinmez; anlaşılır hata döner.

### FAZ 4 — Tema Token'ları ve Ortak UI Temeli

Durum: tamamlandı (5 Eylül 2026). 35 yeni test dahil 288 test başarılı;
`flutter analyze` temiz. Önceki ekranların testleri de geçiyor.

Uygulanan temel ve sonraki fazlara kullanım sözleşmesi:

- `AppTheme.light` krem, `AppTheme.dark` ink yüzeyleri sağlar. Ana eylem
  lime/ink, ikincil eylem temaya uygun metin ve kontrastlı kenarlıktır.
  Eski ekranlar taşınana kadar `KaderApp` koyu temada kalır; bu faz tüm
  ekranları krem yapmaz veya yeni navigasyonu eklemez.
- Yeni widget'lar `Theme.of(context).colorScheme` ve `textTheme` kullanır.
  `AppColors.background/surface/gold/...` eski ekran uyumluluğu içindir;
  yeni açık ekranlarda koyu metin/yüzey sabitleri kullanılmaz.
- İlk Muted önerisi `#6E7889`, krem üstünde 3.94:1 çıktığından
  `#596477` yapıldı (5.28:1). Temanın etkin metin/zemin çiftleri en az
  4.5:1, etkileşimli sınırlar en az 3:1 kontrast testinden geçer.
  Coral/iris/ice vurguları üstünde ink kullanılır; pastel renkler krem
  üstünde küçük metin rengi yapılmaz. İnce dekoratif ayırıcılar kontrol
  sınırının yerine kullanılmaz.
- `AppLayout`: iç dolgu dahil maksimum sütun genişliği 560, minimum dokunma
  alanı 48, buton minimum yüksekliği 56. Sabit yükseklik değil minimumdur;
  metin sarılır. `AppStroke` ve `AppElevation` sınır/derinlik token'larıdır.
- `KaderCard` yalnız erişilebilir gerçek içeriği saran kart kabuğudur;
  kendiliğinden tıklanabilir veya anlamsız bir buton değildir.
- `KaderButton` ana/ikincil çeşidi, işlev ikonu, disabled ve loading sunar.
  Async işlemi çağıran katman yönetir: ilk dokunuşta `isLoading` güncellenir,
  işlem beklenir, hata gerçek hata olarak gösterilir. Loading sırasında
  `loadingLabel` aktif dilde zorunludur, buton tekrar eylem göndermez.
- `KaderChip` kontrollü bir seçim bileşenidir; seçim üst katmanda Riverpod
  ile tutulur. Alanlar `Wrap` içinde kullanılmalı; dar bir `Row` içine
  sıkıştırılmamalıdır. Seçim yalnız renk değil onay işareti ve semantics
  ile belirtilir. Disabled chip seçim bilgisini korur, dokunmayı kapatır.
- `KaderScaffold` SafeArea ve klavyeye uyum sağlar. Kısa içerikte
  `scrollable: true`; ListView/GridView kullanan ekranlarda varsayılan false.
  İç içe kontrolsüz kaydırma veya scroll içinde Expanded kurulmaz.
  Butonlara sınırlı genişlik verilir; yan yana butonlarda Expanded kullanılır.
- `AppMotion` süre/eğri token'ları ve sistem + kullanıcı hareket tercihini
  birleştiren yardımcılar içerir. Sistem azaltma isteği kullanıcı false
  seçse bile bastırılmaz. Buton/chip kendi `reduceMotion` girdisini destekler.
  Kalıcı Profil ayarı ve tam açılış koreografisi sonraki fazlardadır.
- Inter ve Playfair Display yerel değişken TTF dosyalarıyla paketlendi;
  tema artık GoogleFonts veya ağ çağrısı yapmaz. Kaynak/lisans/hash kaydı
  `assets/fonts/README.md` içindedir. Lisanslar main başlangıcında Material
  lisans kaydına eklenir. Yeni paket eklenmedi, mevcut bağımlılıklar silinmedi.
- `AppTypography.score` tabular rakamlar kullanır; gerçek fontla 111/888
  genişlik eşitliği test edildi. FAZ 8 skor yerleşimi büyük yazı ölçeğinde
  ayrıca doğrulanmalı; skor stili tek başına responsive skor widget'ı değildir.

Görsel doğrulama:

- `design/previews/kader-foundation-light.png`
- `design/previews/kader-foundation-dark.png`

Bunlar gerçek Flutter bileşenlerinin incelenmiş önizlemeleridir, bitmiş Bugün
ekranı veya mağaza screenshot'u değildir. Arketip/nadir işaret resimleri bu
örneklere konmadı; hazır dosyalar FAZ 5'te kendi erişim katmanına bağlanacak.
Normal testler platforma duyarlı piksel eşitliğine bağlı değildir. Önizlemeyi
aynı yerel fontlarla yenilemek için:

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/shared/kader_foundation_test.dart
```

Test kapsamı: iki tema × üç genişlik (320/390/430) × iki yazı ölçeği
(100/200%) × TR/EN; ayrıca klavye, semantics, disabled/loading, azaltılmış
hareket, tablet genişliği, safe area/klavye ve font lisansları.
Gerçek Android/iOS cihazda font ağırlıkları, TalkBack/VoiceOver ve ekran
kontrastı manuel doğrulama bekler. Native splash rengi FAZ 16'da güncellenir.

Bu fazın devamındaki görsel asset entegrasyonu FAZ 5'te tamamlandı.

**Amaç:** Ekranlardan önce yeni tasarım sistemini kodlamak.

Görevler:

1. `AppColors` semantik açık/koyu token'larla yenilenir.
2. Spacing, radius, elevation, stroke ve maksimum içerik genişliği eklenir.
3. `AppMotion` süre/eğri token'ları eklenir.
4. Açık krem ve koyu ink yüzeyleri destekleyen `ThemeData` kurulur.
5. Ortak `KaderCard`, ana/ikincil buton, chip ve scaffold bileşenleri yazılır.
6. 320, 390 ve 430 px genişliklerde örnek widget testleri eklenir.
7. 200% text scale taşma testleri eklenir.

Bu fazda feature ekranları topluca yeniden tasarlanmaz.

### FAZ 5 — Görsel Asset Entegrasyonu

Durum: tamamlandı (7 Eylül 2026). Kullanıcının ek talebiyle karşılama
hizalaması ve başlangıç animasyonu da bu oturumda yenilendi. 23 yeni test
dahil 311 test başarılı; `flutter analyze` temiz.

Uygulama sözleşmesi:

- `AppIcons.dimension` beş yeni alanı sabit `dimensionAssets` map'inden okur.
  Varsayılan renk temanın ikon rengidir; etiket verilmezse dekoratiftir.
- `AppIllustrations` artık `shared/widgets/app_illustrations.dart` içindedir.
  Eski import'lar kırılmasın diye `app_icons.dart` bu dosyayı export eder.
  `kaderMark`, `kaderCardBack`, `pathPattern`, `emptyPath`, `archetype` ve
  `rareSign` hazır çizimleri kullanır; çizimler yeniden üretilmedi.
- `RareSignId` saf enum ve 12 elemanlı `rareSignAssets` map'i eklendi.
  Açılma koşulları bu enum içinde değildir; FAZ 10'da uygulanacak.
- `pubspec.yaml` arketip ve nadir kart alt dizinlerini açıkça bundle eder.
  Testler artık yalnız disk dosyasını değil gerçek Flutter AssetManifest,
  rootBundle ve codec üzerinden tüm 17 WebP'yi doğrular.
- Ekranda arketipler 4:3, nadir kartlar 5:7 merkez hizalıdır. Decode genişliği
  yerleşim genişliği × DPR olarak hesaplanır ve 1024/800 px master'da durur.
  Story renderer `fullResolution: true` kullanır; thumbnail büyütmez.
- `precacheArchetype` ve `precacheRareSign` yalnız tek seçili görseli alır;
  görünümde kullanılacak aynı `logicalWidth` verilmelidir. Tüm map değerlerini
  dolaşıp başlangıçta yüklemek yasaktır. Precache hatası çağırana iletilir.
- `rareSign` FAZ 11'de `GridView.builder` öğesinde kullanılmalı. Lazy grid
  testi görünür öğelerin thumbnail ürettiğini ve 12 kartın birlikte
  oluşturulmadığını denetler. Koleksiyon ekranının yerleşimi henüz değişmedi.
- Eski kristal/yonca/yıldız/zar API'leri geçiş için korunur; dokümantasyonda
  deprecated ve yeni karşılıklarıyla işaretlidir. Eski dosyalar silinmedi.

Kullanıcının ek başlangıç ekranı talepleri:

- `WelcomeScreen` artık genişliği dolduran, en fazla 560 px sütunda merkezlenen
  ve kısa ekranda kaydırılabilen düzendedir. Başlık ve Başla butonunun merkezi
  320/390/430 px, TR/EN, %100/%200 yazı ölçeğinde test edilir.
- Yonca yerine hazır kemer/yol markası görünür. Slogan yeni ürün diliyle
  güncellendi. Ana lacivert renk ve mevcut tema token'ları değiştirilmedi.
  Kullanıcı renk kararını tam ekran tasarımları sonrasına bıraktı; sonraki
  fazlar bu tercihi göz ardı ederek global renk değişikliği yapmamalı.
- `CardPreparationMotion` eski 50 parçacık ve skor Hero halkasının yerine
  gerçek mühürlü kart üzerinde hafif yerleşme/eğim ve folyo ışığı uygular.
  Normal geçiş 1600 ms; azaltılmış harekette 180 ms fade, tilt/ışık yoktur.
  Arketip/skor yüklenmez, hesaplanıyormuş gibi sahte yüzde gösterilmez.
- `CalculatingScreen` yazımı bekler, tekrar tamamlamayı engeller, dispose
  sonrası gezinmez. Hata halinde yerelleştirilmiş tekrar deneme sunar.
  İlk animasyon sırasında veya kayıt beklenirken kapanma testleri vardır.
- Mevcut isim/doğum tarihi formu ve bildirim izin politikası bu ek taleple
  değiştirilmedi. FAZ 7'de v2 kimlik, doğum tarihsiz form ve opt-in akışı hâlâ
  yapılacak; tamamlanan karşılama/animasyon bileşenleri yeniden yazılmayacak.

İncelenmiş gerçek Flutter önizlemeleri:

- `design/previews/kader-welcome.png`
- `design/previews/kader-preparing.png` — animasyonun ara karesi, video değil.

Yeniden üretim:

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/onboarding/onboarding_design_test.dart
```

Gerçek cihazda ilk kurulum ekranının hizası, animasyon akıcılığı ve azaltılmış
hareket ayarı manuel doğrulama bekler. Skor/arketip ana ekranı ve tam nadir
kart koleksiyonu henüz son görünümünde değildir; FAZ 8/11'de bağlanacaktır.

FAZ 6–10 aşağıda tamamlandı; sonraki oturum FAZ 11'den devam eder.

**Amaç:** Hazır üretim asset'lerini tip güvenli ve test edilebilir biçimde
uygulamaya bağlamak.

Görevler:

1. Bölüm 10'daki tüm SVG ve WebP dosyalarının varlığını doğrula; yeniden çizme.
2. `AppIcons.dimension(ExperienceDimension)` eşlemesini ekle.
3. `AppIllustrations` içine mark, kart arkası, pattern, boş durum, arketip ve
   nadir işaret API'lerini ekle.
4. `RareSignId` → WebP ve `ExperienceDimension` → WebP map'lerini tek yerde
   tanımla; tüm değerlerin kapsandığını test et.
5. `precacheImage` yalnız yakındaki/günün arketipi ve görünmek üzere olan tek
   nadir kart için kullanılsın; 17 büyük görsel açılışta birlikte decode
   edilmesin.
6. Eski kristal küre, yonca, zar ve yıldız referanslarını henüz silmeden
   deprecated olarak işaretle.
7. Mevcut SVG tarama testi ve WebP oran/codec testini koru.

Kabul:

- Tüm asset'ler uygulama içinde parse edilir.
- Beş arketip WebP yalnız günün arketipi gerektiğinde yüklenir; on iki nadir
  kart koleksiyon grid'inde thumbnail decode genişliğiyle lazy yüklenir.
- Açık/koyu zeminde ikon kontrastı yeterlidir.
- Hiçbir yeni asset astroloji/casino sembolü içermez.

### FAZ 6 — Üç Sekmeli Uygulama Kabuğu

**Durum: Tamamlandı (7 Eylül 2026).** `flutter analyze --no-pub` temiz;
tam `flutter test --no-pub` paketi 330 test ile başarılı.

Uygulanan yapı:

- `lib/features/shell/app_shell.dart`: Bugün, Desenlerim ve Profil;
  ilk ziyarette kurulan ekranlar `IndexedStack` içinde korunur. Riverpod
  `shellProvider` seçili/ziyaret edilmiş sekmeleri tutar; kabuk kapanınca
  sıfırlanır. Gizli sekmelerin ticker, Hero ve odak etkileşimi kapalıdır.
- `lib/shared/widgets/kader_bottom_navigation.dart`: TR/EN etiketler,
  seçili durum semantics'i, minimum 48 px dokunma alanı ve büyük yazıda
  büyüyen çubuk. Sistem/kullanıcı azaltılmış hareket tercihi uygulanır.
- Bugün mevcut günlük kartı barındırır. Üstteki geçmiş/koleksiyon/ayarlar
  ikonları kaldırıldı; tarih ve selamlama tam satırı kullanır.
- Desenlerim marka görselli geçiş ekranıdır; çalışan Geçmiş ve Koleksiyon
  rotalarını açar. Bu, FAZ 11'in tamamlanmış analiz/koleksiyon tasarımı değildir.
- Profil mevcut Settings gövdesidir; bağımsız `SettingsScreen` kullanımı
  varsayılan Ayarlar başlığını korur. Kullanıcının lacivert teması korunmuştur.
- `main.dart` ve onboarding tamamlanışı aynı `AppShell` köküne gider.
  İç içe Navigator eklenmedi. Detay ve feedback ekranları kök Navigator'a
  açılır; geri ile kaynak sekme korunur. Sekme kökünde Android geri önce
  Bugün'e döner, Bugün'de normal platform geri davranışı bırakılır.

Doğrulama:

- `test/shell/shell_state_test.dart`: ilk seçim, ziyaret kümesi,
  değiştirilemez durum, tekrar seçim ve autoDispose.
- `test/daily_luck/settings_navigation_test.dart`: Profil form taslağı,
  kart state'i/kaydırma konumu, geçmiş/koleksiyon rotaları ve geri dönüş;
  bildirim callback'inin kullandığı kök Navigator'a Feedback açma/geri dönme.
  Gerçek bildirim plugin'inin teslim/tap davranışı bu widget testinin dışındadır.
- `test/shared/kader_bottom_navigation_test.dart`: 320/390/430 px,
  TR/EN, %100/%200 metin ölçeği, semantics ve azaltılmış hareket.
- Smoke ve tam onboarding testi artık `AppShell` açıldığını da doğrular.
- Üç sekme 390×844 gerçek Flutter render'ında görsel olarak incelendi:
  `design/previews/kader-shell-today.png`, `kader-shell-patterns.png`,
  `kader-shell-profile.png`. Bunlar nihai ürün konsepti değil, çalışan ara
  sürümün ekranlarıdır. Yeniden üretim:

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/daily_luck/settings_navigation_test.dart
```

Android geri/predictive-back, gerçek klavye ile Profil formu, TalkBack/VoiceOver
ve bildirimden açılış gerçek cihazda manuel doğrulama bekliyor.

FAZ 7 aşağıda tamamlandı. FAZ 5'te tamamlanan karşılama hizası/kart hazırlama
animasyonu korunmuştur; FAZ 8 de aşağıda tamamlandı.

**Amaç:** Yeni bilgi mimarisini kurmak.

Görevler:

1. `AppShell` ve üç sekmeli bottom navigation ekle.
2. Bugün mevcut `DailyLuckScreen`'i geçici olarak barındırsın.
3. Desenlerim geçici olarak mevcut History/Collection girişlerini barındırsın.
4. Profil mevcut Settings ekranını barındırsın.
5. Kök `main.dart` onboarding sonrası `AppShell` açsın.
6. Sekme state'i ve geri tuşu davranışını test et.
7. Eski üst bar history/collection/settings ikonlarını shell sonrası kaldır.

Kabul:

- Üç sekme erişilebilir adlarla görünür.
- Sekmeler state kaybetmez.
- Android geri tuşu non-root sekmede önce Bugün'e döner.
- Deep link/bildirim yardımcı ekranları açmaya devam eder.

### FAZ 7 — Onboarding Yeniden Tasarımı

**Durum: Tamamlandı (7 Eylül 2026).** `flutter analyze --no-pub` temiz;
tam test paketi 353 test ile başarılı.

Uygulananlar:

- `ProfileFormScreen`: yalnız ad/rumuz, yerel saklama ve hesap gerekmemesi
  açıklaması, eğlence amaçlı metin ve “İlk kartımı hazırla” eylemi. Tarih
  seçici ve kullanılmayan tarih seçici sabit/metinleri kaldırıldı.
- Kader marka görseli, lacivert tema, ortak kaydırılabilir ekran ve buton
  kullanıldı. FAZ 5 karşılama ve mühürlü kart animasyonu yeniden yazılmadı.
- `profile_form_state.dart`: Riverpod taslağı, boş giriş doğrulaması,
  40 karakter UI sınırı, kalıcı yazmayı bekleme, hata/tekrar deneme ve
  çift gönderim koruması. Yazım sürerken geri geçiş kapalıdır.
- Yeni profilde mevcut `UserProfileFactory` ile tek v2 anonim kimlik
  üretilir, doğum tarihi istenmez ve bildirim tercihi kapalı başlar.
  Yazma hatasının aynı oturumdaki tekrarında kimlik yeniden üretilmez.
- Karşılamaya geri dönülünce yazılmamış taslak oturum içinde korunur;
  uygulama kapanınca yalnız başarıyla kaydedilmiş profil geri yüklenir.
  Yarım kalmış v2 profil adı düzenlenebilir, kimliği değişmez. Yarım kalmış
  v1 profilde ad bu adımda salt okunurdur: motor girdisi değişmez ve adın
  daha sonra Profil'den değiştirilebileceği açıklanır.
- `CalculatingScreen` yalnız onboarding kaydını tamamlar ve AppShell açar;
  izin istemez, bildirim planlamaz. Eski tamamlanmış profiller doğrudan
  AppShell açmaya devam eder; veri şeması ve motor değiştirilmedi.
- Bu akışın kullanılabilir kalması için izin talebi `SettingsScreen` içindeki
  kullanıcının bildirim açma eylemine taşındı. İzin beklenirken tekrar istek
  engellenir; red halinde tercih kapalı kalır ve planlama yapılmaz.
  Bu dar bağlantı değişikliği FAZ 14'ün yeni bildirim metni/zamanlama/şanslı
  saat temizliği işlerinin tamamlandığı anlamına gelmez.

Doğrulama:

- Form controller testleri: boşluk girişi, trim, v2 varsayılanları, yazma
  bekleme, çift gönderim, disk hatası/aynı kimlikle retry, dispose, v1/v2 resume.
- Widget akışı: geri dönüşte taslak, yazımda geri kilidi, retry, tam akışta
  sıfır izin/sıfır planlama çağrısı ve onboarding'e geri dönülmemesi.
- Gerçek Hive kapat/aç testi: formdan üretilen kimlik, onboarding bayrağı,
  kapalı bildirim tercihi ve motorun tüm günlük skorları değişmeden kalır.
- TR/EN, 320/390/430 px ve %100/%200 metinde açık klavyeyle forma/eyleme
  ulaşılır; overflow yok. Mevcut legacy smoke ve migration testleri yeşil.
- `design/previews/kader-onboarding-profile.png`: 390×844 gerçek Flutter
  form render'ı görsel olarak incelendi. Yeniden üretim:

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/onboarding/onboarding_design_test.dart
```

Gerçek Android/iOS ilk kurulumunda klavye, geri tuşu, ekran okuyucu ve izin
diyaloğu (yalnız Profil'den etkinleştirme) manuel doğrulama bekliyor.

FAZ 8 aşağıda tamamlandı. Kullanıcının renk
tercihi gereği lacivert tema korunacak; aşağıdaki ilk taslaktaki “krem ekran”
ifadesi tek başına global tema değiştirme talimatı sayılmayacak.

**Amaç:** Hızlı, astroloji çağrışımı yapmayan başlangıç akışı.

Hedef akış:

1. Marka + “Gününü tahmin etme. Ona bir işaret bırak.” + “Başla”.
2. Yalnız ad/rumuz girişi ve kısa yerel veri açıklaması.
3. Kısa kart hazırlama geçişi; doğum tarihi seçici yok.
4. Ana ekrana geçiş. Sistem bildirim izni bu noktada otomatik istenmez.

Görevler:

- Eski profil kullanıcıları onboarding'e geri gönderilmez.
- Yeni profil seed v2 ile oluşturulur.
- Parçacık animasyonu yeni şerit/tohum diline çevrilir.
- Eğlence amaçlı ve yerel veri açıklaması okunabilir kalır.
- Geri tuşu ve yarım kalmış form davranışı test edilir.

Kabul:

- Yeni kullanıcı doğum tarihi vermeden ana ekrana ulaşır.
- Seed uygulama kapanıp açıldıktan sonra aynıdır.
- Bildirim izin diyaloğu onboarding sırasında kendiliğinden açılmaz.

### FAZ 8 — Bugün Ekranı: Statik Yerleşim

**Durum: Tamamlandı (7 Eylül 2026).** `flutter analyze --no-pub` temiz;
tam test paketi 370 test ile başarılı.

Uygulananlar:

- `DailyLuckScreen` yeni `dailyExperienceProvider` üzerinden saklanmış
  sonucu tüketir. Motor, eski günlük kayıtlar ve seed değiştirilmedi.
- `TodayConcealedCard`: yeni 2:3 mühürlü SVG, tarih/selamlama, kısa davet
  ve “Bugünün işaretini aç” eylemi. Skor, alan bileşenleri, arketip ön yüzü,
  bitmap ve paylaşım eylemi bu durumda widget ağacına girmez.
- `TodayRevealedContent`: büyük tabular skor, arketip başlığı, yalnız günün
  WebP illüstrasyonu, kısa düşünme daveti, Akış/Bağ/Üretim/Cesaret/Denge,
  mikro görev, paylaşım ve gün sonu kartı. Eski şans rengi/sayı/saat bölümleri
  ana ekrandan çıkarıldı; eski bileşen dosyaları diğer tüketiciler için korundu.
- `TodayDimensionData` görünüm sınırında yetkiye göre maskelenir. Kilitli
  alanlarda skor null; sayı, bar oranı veya gizli semantics üretilmez.
  Yetki değişiminde beş satır reaktif yenilenir. Arketip herkese açık kalır.
- Lacivert tema korunur. Ortak ekranın opsiyonel `scrollController` desteği
  sayesinde statik açılışta skorun başına dönülür; sekme geçişleri ise aynı
  kaydırma konumunu korur. Şefkatli seri bilgisi korunmuştur.
- Loading/error/kapalı/açık durumlar ayrı yerleşimlerdir. Hata eylemi gerçek
  sonuç provider'ını yeniler; sahte sayı veya yüzde yoktur.
- Paylaş eylemi mevcut sisteme kilitli kategori kümesiyle bağlandı; tekrar
  gönderme engeli ve hata mesajı vardır. Mevcut alan detayı/erişim ekranı ile
  feedback rotası korunmuştur; yeni story editörü ve yeni üç durumlu akşam
  formu bu fazda tamamlanmış sayılmaz.

**FAZ 8 kapanışındaki tarihsel geçiş notu (FAZ 9'da aşağıda tamamlandı):**
Günlük kart FAZ 8 sonunda statik kapalı/açık
yerleşimlerini kullanır. Eski `FortuneRevealCard` flip zinciri ana ekrandan
ayrıldı; yeni imza efekti henüz eklenmedi. `todayRevealedProvider(day)`
oturum içinde açılmayı korur ve varsa mevcut `revealedAt` kaydını okur, fakat
ilk açılışı diske yazmaz. FAZ 9 bu geçici state'i animasyon state machine'i,
idempotent repository yazımı ve aynı gün uygulama yeniden açılınca otomatik
tekrar oynamama davranışıyla değiştirecek. Bu fazda kalıcı reveal tamamlandı
denmemelidir.

Doğrulama:

- `today_design_test.dart`: loading/error ve gerçek retry, concealed
  ağacında gizli içerik yokluğu, kilitli widget verisi/metin/semantics/bar
  maskesi, premium değişimi, 320/390/430 px × TR/EN × %100/%200 metin.
- Açma sonrasında scroll sıfırlanması ve son gün sonu eylemine kaydırarak
  erişim test edilir. Shell/ana ekran testleri yeni bileşenlere güncellendi;
  geçmiş, koleksiyon, alan detayı ve paylaşım maskesi testleri korunmuştur.
- İncelenmiş 390×844 gerçek Flutter önizlemeleri:
  `design/previews/kader-today-concealed.png`, `kader-today-revealed.png`,
  `kader-today-dimensions.png`, `kader-today-mission.png`.
  Shell'in `kader-shell-today.png` önizlemesi de yeni kapalı karta güncellendi.

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/daily_luck
```

Gerçek cihazda uzun metin/ekran okuyucu, görsel decode belleği ve sistem
paylaşımı manuel doğrulama bekliyor. Akşam kartının saat/önceki feedback
koşulları FAZ 12, paylaşım tasarımı FAZ 13, diğer widget/bildirim yüzeylerinin
pre-reveal gizliliği FAZ 14/15 kapsamındadır; bu faz yalnız Bugün ağacını kapsar.

FAZ 9–10 aşağıda tamamlandı; sonraki oturum FAZ 11'den devam eder.

**Amaç:** Animasyondan önce bitmiş ekran hiyerarşisini kurmak.

Görevler:

1. Pre-reveal krem ekranı ve büyük kapalı kartı kur.
2. Reveal sonrası büyük skor, arketip, illüstrasyon, beş alan ve mikro görev
   yerleşimini kur.
3. Görünüm `DailyExperience` tüketir; ham kategori etiketlerini kullanmaz.
4. Şans rengi/sayı/saat ana ekrandan çıkarılır.
5. Paylaş ve feedback yer tutucuları doğru hiyerarşiye konur.
6. Loading, error, concealed ve revealed durumları ayrı test edilir.
7. Kilitli alan skorunun hiçbir ağaçta sızmadığı yeniden doğrulanır.

Kabul:

- 320×568 küçük ekranda erişilemeyen içerik yoktur.
- 430 px genişlik ve 200% text scale'da kritik overflow yoktur.
- Konsept görseldeki görsel öncelik korunur.
- Statik ekran testleri geçer; animasyon henüz eklenmemiş olabilir.

### FAZ 9 — Kart Açılış Efekti

**Durum: Tamamlandı (7 Eylül 2026).** `flutter analyze --no-pub` temiz;
tam test paketi 385 test ile başarılı.

Uygulananlar:

- `reveal_controller.dart`: gün bazlı Riverpod makinesi
  `concealed → revealing → saving → revealed`; yazma hatasında `error`,
  ardından `retry → saving`. `start`, animasyon tamamlanışı ve retry tekrar
  çağrılarına karşı korumalıdır. Sonuç yalnız kalıcı yazma başarılıysa görünür.
- Başlangıç durumu gerçek günlük kaydın `revealedAt` alanından okunur;
  daha önce açılan kart doğrudan sonuçla başlar, animasyon ve haptic yapmaz.
  FAZ 8'in oturumluk bool yazımı kaldırıldı. Mevcut idempotent
  `LuckHistoryRepository.revealKaydet` kullanılır; motor veya şema değişmedi.
- Hedef gün animasyon başında sabittir; saat `revealClockProvider` üzerinden
  alınır. Kapanış sırasında tamamlanan yazım dispose olmuş state'i değiştirmez.
  Kayıt beklenirken sonuç/arketip widget'ı kurulmaz; retry animasyonu tekrarlamaz.
- `CardRevealMotion`: 3B basma eğimi, mühür halkası, kart kenarında ışık
  dikişi, folyo ışığı, iki ayrılan katman ve 12 sabit tohum/taş/şerit/uçak
  parçacığı. Kapalı kart, ışık ve parçacıklar ayrı RepaintBoundary kullanır;
  parçacık tanımları bir kez oluşturulur, geniş ekran ağacı frame başına kurulmaz.
- Normal süre: 1000 ms kart + 600 ms sonuç fade/yerleşmesi; disk beklemesi
  bu süreye eklenebilir. Kalıcı yazma için sahte başarı gösterilmez.
- Sistem hareket azaltmada kart statik kalır, sonuç 180 ms fade ile gelir;
  tilt, parçacık, ani scale ve haptic yoktur. Tercih hareketin ortasında
  değişirse kalan hareket kaldırılır. Profil'deki kalıcı hareket tercihi UI'sı
  sonraki Profil fazının işidir; mevcut sistem tercihi bastırılmaz.
- Mühürde bir `selectionClick`, başarılı yeni sonuçta en fazla bir
  `mediumImpact`. Platform hataları opsiyonel kabul edilir. Aynı frame'de
  değişen görünürlük/erişilebilirlik tercihi haptic gönderilmeden kontrol edilir.
- Gizli sekmede controller yalnız susturulmaz, gerçekten durdurulur;
  geri dönüldüğünde kaldığı ilerlemeden devam eder. Sonuç girişinde de aynı
  durdurma davranışı vardır. Sonuç görünürken mevcut kilit maskesi korunur.

Doğrulama:

- `reveal_controller_test.dart`: durum sırası, çift start/callback, bekleyen
  yazım, error/retry, dispose, eksik kayıt ve gerçek Hive kapat/aç kalıcılığı.
  İlk açılış zamanı, kategori skorları ve mevcut feedback değişmez; yeni gün
  kapalı başlar.
- `reveal_motion_test.dart`: aynı frame'de çift dokunma, yazım öncesi gizli
  içerik, sonuç semantics'i, haptic sayısı, statik tekrar açılış, reduced-motion
  ve hareket sırasında tercih değişimi, gizli sekmede pause/resume,
  animasyon/yazım sırasında dispose ve disk hatasında retry.
- Eski yerleşim testleri `test/fixtures/reveal_test_overrides.dart` ile
  yalnız disk yazmasını anında tamamlar; üretim controller/animasyonu çalışır.
  Gerçek Hive testi bu override'ı kullanmaz. Bu ayrım FakeAsync disk bekleme
  sorununu gizli bir üretim no-op'u eklemeden çözer.
- 320/390/430 px, TR/EN ve %200 metin testleri yeni efektle de geçer.
- `design/previews/kader-reveal-seal.png`, `kader-reveal-seam.png`,
  `kader-reveal-unfold.png` gerçek Flutter animasyon ara kareleri olarak
  incelendi (video değildir). Bugün/shell önizlemeleri de güncellendi.

```powershell
flutter test --no-pub --dart-define=KADER_WRITE_PREVIEWS=true --update-goldens test/daily_luck
```

**Manuel doğrulama:** Düşük/orta segment Android ve iOS'ta profil modunda
akıcılık/60 fps, mühür titreşim şiddeti, ışık banding'i ve kart kenarı kırpılması
gerçek cihazda kontrol edilmeli. Widget testleri cihaz performansı kanıtı değildir.

FAZ 10 aşağıda tamamlandı. Sonraki oturum **FAZ 11 — Desenlerim ve Koleksiyon
UI**; hazır saf analiz yeni görsel ekrana bağlanacak.

**Amaç:** Ürünün imza hareketini performanslı ve erişilebilir yapmak.

Görevler:

1. Açılış state machine'ini uygula.
2. Tilt/folyo, mühür, ışık dikişi, katman açılması ve parçacıkları ekle.
3. Haptic noktalarını ekle.
4. Reveal tamamlandığında repository'ye tek kez yaz.
5. Aynı gün yeniden açılışta animasyonu atla.
6. Reduced-motion alternatifini uygula.
7. Animasyon sırasında tekrar dokunmayı engelle.

Testler:

- State sırası ve idempotency.
- Hızlı çift dokunma.
- Reduced motion.
- Widget dispose edilirken controller hatası olmaması.
- Reveal sonrası skor ve alan semantics'i.

Gerçek cihaz kontrolü:

- 60 fps hissi.
- Haptic şiddeti.
- Kart kenarlarında kırpılma ve ışık banding'i.

### FAZ 10 — Desen Analizi Saf Katmanı

**Durum: Tamamlandı (7 Eylül 2026).** 58 yeni test; tam paket 443 test ile
başarılı. `flutter analyze --no-pub` temiz. Bu fazda ekran görünümü değişmedi.

Uygulananlar ve veri sözleşmesi:

- `lib/core/history/patterns_analyzer.dart`: `analyzePatterns(records,
  today: ..., firstSharedAt: ...)` saf Dart fonksiyonu. Saat okumaz, Hive'a
  yazmaz, motoru çalıştırmaz ve girdileri değiştirmez. `patterns_summary.dart`,
  `patterns_config.dart`, `rare_sign_progress.dart` değiştirilemez çıktı ve
  merkezi ürün eşiklerini tanımlar.
- Ritim bugün dahil son 30 takvim gününü eskiden yeniye taşır. Eksik günler
  `feedback: null` durumundadır; nötr veya zorlayıcı sayılmaz. Takvim aritmetiği
  Y/M/D'den UTC sıra numarasıyla yapılır; girdi saat dilimi dönüştürülmez.
  Gelecek kayıtlar ve gelecekteki açılış kanıtları sayılmaz.
- Katılım: kaydın gününde açılış veya feedback kanıtı bulunması. Sadece kartın
  hesaplanıp diske yazılması yeterli değildir. Eski bool feedback üç duruma
  uyarlanır, katılımı korunur; olmayan `revealedAt` uydurulmaz. Eski açılış
  bilgisi olmayan kayıtlar arketip/görülmüş kart ödüllerine dahil edilmez.
- Her takvim günü bir kayıt olmalıdır (repository zaten tarih anahtarlı).
  Çift tarihli girdi `ArgumentError` ile açıkça reddedilir; sıra-bağımlı son
  kaydı seçme veya çift gün sayma yapılmaz. Açılmış kartta eksik kategori varsa
  mevcut içerik katmanı gibi `StateError` üretilir; sahte tema hesaplanmaz.
- Feedback dağılımı son 30 günün üç ham yanıt sayısıdır. Trend bugün dahil
  son 7 gün ile önceki 7 günü karşılaştırır. Her pencerede en az 3 yanıt yoksa
  `insufficient`. Karşılaştırma ham adet değil yanıt oranları üzerinden tam
  sayı çapraz çarpımıyla yapılır; tek yön, karışık ve değişmemiş durumları vardır.
  Örnek sayıları gösterilir; bu eşik istatistiksel güven veya tahmin doğruluğu
  iddiası değildir. Genel skor bu hesabın girdisi değildir.
- En sık arketip/alan yalnız son 30 günde gerçekten açılmış kartlardan gelir.
  Eşit sıklıkta tüm temalar enum sırasında korunur. Kart içi skor eşitliği
  mevcut `ExperienceDimension.baskinAlan` kuralını kullanır. Çıktı kilitli
  alanların sayısal skorlarını içermez.
- Katılım sayısı ve en uzun seri tüm geçmişi kapsar. Arada bir boş gün seriyi
  korur ama sayıya eklenmez; iki boş gün yeni seri başlatır. Mevcut seri için
  son katılım bugün veya dün olmalıdır. Sıfır seri metni utandırmaz.
- 12 nadir kartın koşulu bölüm 10.4 ile eşleşir: ilk gerçek açılış, ilk
  feedback, 3/7/14/21 katılım günü, ilk paylaşım, 5/10 feedback günü, en az
  iki boş günden sonra dönüş, açılmış beş arketip ve açılmış kartta 92+ skor.
  İlerleme hedefte durur; şartı ilk sağlayan gün korunur. Aynı tarihte son
  kart seçimi katalog sırasıyla kararlıdır. Nadirlik tüm geçmişten hesaplanır,
  30 günlük pencere dışına çıkan kart yeniden kilitlenmez.
- `eligibleOn` mevcut kayıtların kanıtladığı koşul günüdür, kalıcı kazanım
  defteri veya kesin kazanım saati değildir. Feedback/katılım eşiklerinde
  kaydın ait olduğu gün kullanılır (feedback yazılma zamanı saklanmıyor).
  Açılışa bağlı şartlarda gecikmiş açılışın gerçek tarihi dikkate alınır.
  Geçmişin silinmesi/değişmesi yeniden hesaplamayı etkileyebilir; kalıcı ödül
  defteri gerekirse ayrıca tasarlanmalı, bu tarihler gerçek event log sanılmamalı.
- `features/patterns/patterns_strings.dart`: TR/EN katılım, seri, sık temalar,
  trend açıklamaları; 12 kartın adları ve açıklanabilir koşulları. Kart
  geçmişinden kişilik, gelecekte başarı veya nedensellik çıkarılmaz.
- `patternsSummaryProvider`, mevcut `tumKayitlarProvider` üzerinden gerçek
  Hive değişimlerini izler. `bugunProvider` yenilenince pencere yenilenir;
  bu faz kendi gece yarısı zamanlayıcısını eklemez. Eski History/Collection
  ekranları ve kanıt yüzdesi sağlayıcısı uyumluluk için değişmeden kaldı;
  yeni Desenlerim bunları değil yeni analiz sağlayıcısını tüketecek.

Doğrulama:

- `test/patterns/`: boş/1/7/30 gün; pencere uçları, artık yıl/ay/yıl ve saat
  bileşenleri; kapalı/yüksek skor/gelecek kayıt; eski feedback; tek/çift boş gün;
  tema eşitliği ve kategori eksikliği; 20 karışık sıralamada tüm çıktı eşitliği,
  girdi değişmezliği ve çıktı koleksiyonlarının değiştirilemezliği.
- Her adet eşiğinin altı/tam sınırı/üstü, ilk koşul günü, beş arketip,
  91/92 sınırı, gecikmiş açılış ve paylaşım kanıtı test edildi.
- Trendin tüm yönleri, eşit oran/farklı örnek adedi, eksik yanıt ve skor
  bağımsızlığı; tüm TR/EN kart koşulları ve yargılamayan özetler test edildi.
- Gerçek Hive yaz/açılış/feedback güncelleme ve kapat/aç testleri provider
  yenilenmesini doğrular. Aynı gün ikinci feedback çift katılım üretmez.

Sonraki entegrasyonlar:

- **FAZ 11:** `patternsSummaryProvider` + `PatternsStrings` yeni ekranın tek
  analiz kaynağı olsun. 30 günlük ve tüm geçmiş kapsamları açıkça etiketlensin.
  Eski “kanıt yüzdesi” yeni ekrana taşınmasın. Uygulamaya geri dönüş/gün değişimi
  yaşam döngüsünde `bugunProvider` yenilemesi ve veri hatası görünümü ele alınsın.
- **FAZ 13:** Kalıcı ve doğrulanmış ilk paylaşım kanıtını
  `firstShareEvidenceProvider` girişine bağla. Şimdilik null döner; Uçan Not
  kilitli, `evidenceAvailable: false` durumundadır. Menü açmak/iptal etmek veya
  bilinmeyen platform sonucu başarı sayılmaz. Ekranda kayıt bulunmadığı
  açıklanmalı; bu faz paylaşım geçmişi varmış gibi davranmaz.

**Amaç:** Yeni Desenlerim ekranının verisini UI'dan bağımsız hazırlamak.

Görevler:

1. Son 30 gün ritim modeli.
2. Üç durumlu feedback dağılımı ve trendi.
3. En sık arketip/alan.
4. Katılım günü ve şefkatli seri.
5. Nadir işaret açma koşulları.
6. Nedensellik iddiası taşımayan özet metin verisi.

Kurallar:

- Kayıp günler negatif sayılmaz.
- Seri sıfırsa utandırıcı metin gösterilmez.
- “Tahmin doğruluğu” yüzdesi üretilmez.
- Analiz fonksiyonları saf Dart ve sıra-bağımsızdır.

### FAZ 11 — Desenlerim ve Koleksiyon UI

**Amaç:** History + collection yeteneklerini tek yeni ekranda birleştirmek.

Görevler:

1. 30 günlük ritim grid'i.
2. Feedback trendi/dağılımı.
3. Özet insight kartları.
4. Son açılan nadir kart.
5. 12 kartlık koleksiyon grid'i ve detay sheet'i.
6. Eski History/Collection ekranlarını uyumluluk rotası olarak geçici tut veya
   tüm çağrıları yeni ekrana taşıdıktan sonra ayrı temizlik fazında kaldır.
7. Boş, 1 günlük, 7 günlük ve 30 günlük durumları test et.

Kabul:

- Ekran boşken kristal küre değil yeni boş yol çizimi görünür.
- Heatmap hücreleri renk dışında semantics etiketiyle anlam taşır.
- Koleksiyon ödül şartları kullanıcıya açıklanabilir.

### FAZ 12 — Akşam Geri Bildirimi

**Amaç:** 10 saniyelik, yargılamayan kapanış ritüeli.

Seçenekler:

- “İyi aktı”
- “Karışıktı”
- “Zorlayıcıydı”

Opsiyonel etiketler yeni beş deneyim alanıdır. Kullanıcı etiket seçmek zorunda
değildir.

Görevler:

1. Yeni feedback UI.
2. Üç durumlu storage yazımı.
3. Kaydetme sonrası Desenlerim provider'larını yenileme.
4. Bugün feedback verilmişse yeniden istenmemesi.
5. Dünün bildiriminden gelinirse doğru tarihe yazma.

Kabul:

- Yanlış güne feedback yazılmaz.
- Aynı gün seçim güncellenebilir ama çift kayıt oluşmaz.
- Ekran okuyucu her seçeneği anlamlı okur.

### FAZ 13 — Paylaşım Düzenleyicisi ve Story Kartları

**Amaç:** Tek butonla ham ekran görüntüsü yerine markalı ve mahrem paylaşım.

Üç şablon:

1. `minimalCream` — krem zemin, yol ve kapı.
2. `midnightDoor` — koyu illüstrasyon ve renkli şeritler.
3. `crossingPaths` — kâğıt uçak ve kesişen yollar.

Görevler:

1. Template seçici ekran/sheet.
2. “Skoru gizle” kontrolü.
3. İsim ve feedback'i varsayılan olarak tamamen dışarıda tutma.
4. 1080×1920 off-screen render'ı üç şablona genişletme.
5. Kilitli alanların sayı ve bar oranlarını sızdırmama.
6. Sistem paylaşım menüsü entegrasyonu.
7. Aylık recap'i yeni tasarım sistemine uyarlama.

Platform kuralı:

- `share_plus` ile belirli bir uygulamaya kesin yönlendirme yapılamıyorsa
  “Instagram'a gönderildi” veya “WhatsApp'a gönderildi” denmez.
- İlk üretim sürümünde ana eylem “Paylaş” ile sistem menüsünü açar.
- Instagram/WhatsApp isimli doğrudan kısayollar ancak gerçek native hedefleme,
  capability kontrolü ve cihaz testi tamamlandıysa gösterilir.

Testler:

- Üç şablon da tam 1080×1920 PNG.
- Skor gizli/açık durumu.
- Kilitli değer gizliliği.
- Türkçe ve İngilizce uzun metin taşması.

### FAZ 14 — Bildirimler ve Ana Ekran Widget'ı

**Amaç:** Kullanıcıyı zorlamadan günlük döngüyü desteklemek.

Bildirimler:

- Sabah: “Kartın seni bekliyor.”
- Akşam: “Günün nasıl geçti? 10 saniyede işaretle.”
- Şanslı saat bildirimi kaldırılır ve artık planlanmaz.
- İzin, kullanıcı Profil'de hatırlatmayı açtığında bağlamsal olarak istenir.
- Ret durumunda sistem ayarına zorlayan tekrar tekrar uyarı yapılmaz.

Widget:

- Reveal öncesi: “Bugünün işareti hazır”, kapalı kart; skor yok.
- Reveal sonrası: skor + arketip; yalnız kullanıcı açtıktan sonra.
- Tarih eskidiyse dünkü skor gösterilmez; kapalı yeni gün görünümü kullanılır.
- Widget tap'i uygulamada doğru Bugün durumunu açar.

Testler:

- Saat dilimi ve yaz/kış saati sınırları.
- İzin açık/kapalı.
- Reveal öncesi payload skor içermiyor.
- Reveal sonrası payload doğru.
- Bildirim payload'ı doğru güne gider.

Gerçek cihaz işleri:

- Android notification tap ve widget.
- iOS izin, timezone ve WidgetKit App Group.
- `docs/ios_widget_setup.md` yeni anahtarlarla güncellenir.

### FAZ 15 — Premium ve Paywall Üretim Kararı

**Amaç:** Kilitli alanları yanıltıcı placeholder bırakmadan tamamlamak.

Ürün önerisi:

- Ücretsiz: genel skor, arketip, mikro görev, Akış/Cesaret/Denge.
- Premium: Bağ ve Üretim detayları, geniş Desenlerim geçmişi, ek story
  şablonları ve koleksiyon görünümleri.

Zorunlu karar kapısı:

- RevenueCat veya mağazanın doğrudan satın alma yöntemi seçilmeden,
  product ID'ler ve test hesapları sağlanmadan gerçek entegrasyona geçilmez.
- Kullanıcı yeni paket ve servis entegrasyonunu açıkça onaylamalıdır.
- Entegrasyon yoksa üretim build'inde ölü satın alma butonu gösterilmez.
  Tüm alanlar açık bırakılır veya premium yüzey bütünüyle gizlenir.

Gerçek entegrasyon yapıldığında:

- Satın al, geri yükle, yükleniyor, iptal, hata ve çevrimdışı durumları.
- Tek entitlement doğruluk noktası.
- Store sonucu doğrulanmadan kilit açmama.
- Kilitli skor gizliliği.
- Fiyat ve deneme metnini mağaza verisinden okuma; hard-code etmeme.

### FAZ 16 — Native İkon, Splash ve Marka Sonlandırma

**Amaç:** Onaylanmış yeni kimliği platform kaynaklarına taşımak.

Görevler:

1. Kemer + yol ikonunun küçük boyut testleri.
2. Launcher PNG'leri ve adaptive foreground üretimi.
3. Splash görseli.
4. Android ve iOS kaynak üretim komutları.
5. Bildirim küçük ikonunun Android kurallarına uygun monokrom varyantı.
6. Widget renk ve ikonlarının güncellenmesi.

Kabul:

- Android adaptive icon kırpılmaz.
- iOS icon alpha kuralına uyar.
- Açık/koyu sistem splash geçişinde beyaz flaş yoktur.
- Gerçek cihazda ikon ayırt edilebilir.

### FAZ 17 — Erişilebilirlik, Performans ve Release Adayı

**Amaç:** Yeni deneyimi yayınlanabilir kaliteye getirmek.

Erişilebilirlik:

- Minimum 48×48 dokunma alanı.
- WCAG AA kontrast.
- 200% text scale.
- TalkBack/VoiceOver sırası.
- Kilitli skor sızıntısı yok.
- Reduced motion.
- Renk körlüğünde alanların ikon/etiketle ayırt edilmesi.

Performans:

- Açılış animasyonu profil modunda kontrol.
- Büyük SVG ve off-screen story render bellek kontrolü.
- Provider rebuild incelemesi.
- Uygulama başlangıcında bildirim/widget hatalarının ana ekranı bloklamaması.

Release:

- Tüm testler ve analyze temiz.
- README yeni ürün tanımı ve mimariyle güncel.
- Eski plan tarihsel belge olarak işaretli.
- Gizlilik ve eğlence amaçlı metinler güncel.
- Kullanılmayan eski asset/kod yalnız referans taramasından sonra kaldırılmış.
- Android ve iOS gerçek cihaz kontrol listesi tamamlanmış.
- Store ekran görüntüleri gerçek uygulamadan alınmış; konsept PNG'ler doğrudan
  store screenshot'u olarak kullanılmamış.

---

## 15. Fazlar Arası Test Matrisi

Her faz tüm testleri çalıştırır; ayrıca aşağıdaki alanlar özellikle korunur:

| Risk | Zorunlu koruma |
|---|---|
| Skor değişmesi | Sabit motor golden fixture'ları |
| Eski Hive verisinin açılmaması | Legacy map fixture testleri |
| Kilitli skor sızıntısı | Widget tree, semantics, story ve widget testleri |
| Dil indekslerinin kayması | TR/EN havuz uzunluğu ve seçim testi |
| Reveal tekrar etmesi | Repository idempotency + widget testi |
| Yanlış güne feedback | Sabit saat/tarih provider testleri |
| Bildirimden yanlış rota | Payload routing testi |
| Küçük ekranda overflow | 320×568 widget testi |
| Büyük yazıda kırılma | 200% text scale testi |
| Hareket hassasiyeti | Reduced-motion testi |
| Paylaşım boyutu | 1080×1920 PNG testi |
| SVG bozulması | Tüm asset parse/render testi |

Golden screenshot testleri font ve platform farkı yüzünden kararlı değilse
zorla eklenmez. Önce deterministik font yükleme sağlanır; aksi halde bileşen
widget testleri ve gerçek ekran görsel kontrol listesi kullanılır.

---

## 16. Manuel Olarak Turan'ın Yapacağı İşler

Codex kodu ve test altyapısını hazırlayabilir; aşağıdakiler geliştirici veya
harici hesap gerektirir:

- Android ve iOS gerçek cihaz görsel/haptic testi.
- iOS Widget Extension ve App Group kurulumu.
- App Store / Play Console ürün ve imzalama ayarları.
- RevenueCat veya in-app purchase ürün tanımları ve API anahtarları.
- Mağaza fiyatı, deneme süresi ve yasal satın alma metni kararı.
- Privacy policy URL'si ve destek URL'si.
- Store metadata ve son ekran görüntüleri.
- Bildirimlerin gerçek cihazda izin, zamanlama ve tap testi.

Codex bu işlerin tamamlandığını varsaymamalı; eksikse açıkça “manuel doğrulama
bekliyor” demelidir.

---

## 17. Bitmiş Ürün Tanımı

Kader 2.0 ancak aşağıdakilerin tamamı doğruysa bitmiş sayılır:

- Yeni kullanıcı doğum tarihi vermeden 30 saniyeden kısa sürede ilk karta
  ulaşabiliyor.
- Aynı günün sonucu kalıcı ve deterministik.
- Kart açılmadan hiçbir yüzey skor sızdırmıyor.
- Kart açılışı akıcı, tekrar güvenli ve reduced-motion uyumlu.
- Akış, Bağ, Üretim, Cesaret ve Denge her yüzeyde tutarlı.
- Kullanıcı metinlerinde fal, burç, casino ve kesin sonuç dili yok.
- Desenlerim ekranı en az boş, 1 gün, 7 gün ve 30 gün durumlarında anlamlı.
- Feedback doğru güne kaydediliyor ve kullanıcı suçlanmıyor.
- Üç story şablonu üretilebiliyor; isim/feedback paylaşılmıyor; skor
  gizlenebiliyor.
- Sabah ve akşam bildirimleri opt-in; şanslı saat bildirimi yok.
- Widget reveal öncesinde yalnız kapalı işareti gösteriyor.
- Paywall varsa gerçek satın alma/restore çalışıyor; yoksa ölü buton yok.
- TR ve EN arayüzleri tam.
- Erişilebilirlik, responsive layout ve veri migration testleri geçiyor.
- `flutter analyze` temiz ve tüm `flutter test` paketi yeşil.
- Yeni marka ikonu ve splash gerçek cihazda doğrulanmış.

Bu kontrol listesi tamamlanmadan yalnızca ekranların güzel görünmesi ürünün
“bitmiş” olduğu anlamına gelmez.
