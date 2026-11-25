import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// Ana ekrana (daily_luck) özgü ölçü, eşik ve animasyon sabitleri.
///
/// Magic number yasağı gereği ekrandaki tüm özel ölçüler buradan okunur;
/// genel boşluk/radius değerleri `core/theme/app_dimens.dart`tan gelir.
abstract final class DailyLuckConfig {
  /// Onboarding tamamlanana kadar kullanılan misafir ismi.
  ///
  /// Dile göre ÇEVRİLMEZ: skor tohumu isimden türer (D5), dil değişince
  /// misafirin skoru değişmemeli.
  static const String misafirIsmi = 'Misafir';

  /// Skor halkasının dış çapı (kategori detay ve uyum ekranlarının
  /// varsayılanı; [ScoreRing] bunu okur).
  static const double halkaCapi = 220;

  /// Skor halkasının çizgi kalınlığı.
  static const double halkaKalinligi = 18;

  // ---- Şans ögeleri kartı (renk / sayı / tavsiye) ----

  /// Şans rengi yuvarlağının çapı.
  static const double sansRengiCapi = 28;

  // ---- Kader kartı ölçüleri ----

  /// Kader kartının genişliği (deste kartı oranı: 2:3).
  static const double kartGenisligi = 220;

  /// Kader kartının yüksekliği.
  static const double kartYuksekligi = 330;

  /// 3D dönüşlerin perspektif katsayısı (Matrix4 satır 3, sütun 2).
  static const double kartFlipPerspektifi = 0.001;

  // ---- Mühür katmanı (kartın ortasındaki altın madalyon) ----

  /// Mühür çapının kart genişliğine oranı (eski tek parça kart
  /// görselindeki madalyonla aynı boy).
  static const double muhurCapOrani = 0.56;

  /// Dokunuştan ışık fazı sonuna kadar mühürün döndüğü açı (radyan).
  static const double muhurDonusAcisi = 0.6;

  /// Beklemede mühürün hafif salınım açısı (radyan).
  static const double muhurSallanmaAcisi = 0.035;

  /// Beklemede mühürün nefesle büyüme payı (ölçek).
  static const double muhurNefesOlcegi = 0.018;

  /// Her kaç kıvılcımdan biri nokta yerine parıltı sprite'ıyla çizilir.
  static const int kivilcimSpriteAraligi = 3;

  /// Sprite kıvılcımın kenarının kıvılcım çapına oranı.
  static const double kivilcimSpriteCarpani = 8;

  // ---- Kart açılışı: Mühür → Işık → Açılış → Yerleşme ----
  //
  // Tasarımdaki hareket taslağı: 0-250 ms mühür, 250-650 ms ışık,
  // 650-1300 ms açılış, 1300-2000 ms yerleşme. Aşağıdaki oranlar
  // tek controller'ın (0→1) bu dilimlere bölünmesidir.

  /// Kart açılışının toplam süresi.
  static const Duration kartAcilisSuresi = Duration(milliseconds: 2000);

  /// "Hareketi azalt" açıkken açılışın süresi (yalnız kısa geçiş).
  static const Duration azaltilmisAcilisSuresi = Duration(milliseconds: 300);

  /// Mühür fazının bitişi (250 ms / 2000 ms).
  static const double muhurSonu = 0.125;

  /// Işık (dikiş) fazının bitişi (650 ms / 2000 ms).
  static const double isikSonu = 0.325;

  /// Kanatların açılma fazının bitişi (1300 ms / 2000 ms).
  static const double acilisSonu = 0.65;

  /// Arka plan sahnesinin kapalı sahneden skor sahnesine geçiş dilimi.
  static const double sahneGecisBaslangici = 0.30;

  /// Sahne geçişinin bitişi.
  static const double sahneGecisSonu = 0.80;

  /// Skor count-up'ının başladığı an (kanatlar aralanırken).
  static const double skorSayacBaslangici = 0.40;

  /// Skor count-up eğrisi.
  static const Curve skorSayacEgrisi = Curves.easeOutCubic;

  /// Mühüre basılınca kartın sıkıştığı ölçek ("tok dokunuş").
  static const double muhurBasmaOlcegi = 0.955;

  /// Işık fazında kartın hafifçe yükseldiği ölçek.
  static const double isikYukselmeOlcegi = 1.03;

  /// Kanatların açılmada ulaştığı taşma açısı (radyan, ~82°).
  static const double kanatTasmaAcisi = 1.43;

  /// Kanatların yerleşmede oturduğu son açı (radyan, ~70°).
  static const double kanatSonAcisi = 1.22;

  /// Yerleşmede her kanadın dışa kayma miktarı (kart genişliği oranı).
  static const double kanatKaymaOrani = 0.22;

  /// Kanat döndükçe yüzüne inen azami gölge opaklığı.
  static const double kanatGolgeOpakligi = 0.55;

  /// Yerleşme sonunda kanatların kalan opaklığı (sahnenin kapıları
  /// görünür kalsın diye kanatlar neredeyse tamamen söner).
  static const double kanatSonOpakligi = 0.0;

  /// Işık dikişinin çekirdek kalınlığı.
  static const double dikisKalinligi = 2.5;

  /// Işık dikişi halesinin bulanıklık yarıçapı.
  static const double dikisHaleBulanikligi = 10;

  /// Işık dikişi halesinin kalınlığı.
  static const double dikisHaleKalinligi = 14;

  /// Mühür parıltısının yarıçapı (kart genişliği oranı).
  static const double muhurParlamaOrani = 0.42;

  /// Bekleme sırasında mühür parıltısının en düşük opaklığı.
  static const double muhurNefesMin = 0.18;

  /// Bekleme sırasında mühür parıltısının en yüksek opaklığı.
  static const double muhurNefesMaks = 0.45;

  /// Bir bekleme döngüsünde mühürün kaç kez "nefes aldığı".
  static const double muhurNefesKati = 2;

  /// Mühür halesinin en küçük yarıçap çarpanı (parlaklık 0 iken).
  static const double muhurHaleMinCarpani = 0.8;

  /// Mühür halesinin parlaklıkla büyüme payı.
  static const double muhurHaleBuyumesi = 0.4;

  /// Radyal halelerde iç renk durağının konumu (0-1).
  static const double haleIcDuragi = 0.38;

  /// Radyal halelerde iç durağın dış renge göre opaklık çarpanı.
  static const double haleIcOpakligi = 0.45;

  /// Açılış anındaki ışık patlamasının yarıçapı (kart genişliği oranı).
  static const double patlamaYaricapOrani = 1.1;

  /// Açık yüzün (skor) belirmeye başladığı ölçek.
  static const double onYuzBaslangicOlcegi = 0.9;

  /// Açılışta saçılan kıvılcım sayısı.
  static const int kivilcimSayisi = 32;

  /// Kıvılcımların gidebileceği azami mesafe (kart genişliği oranı).
  static const double kivilcimMesafeOrani = 0.95;

  /// Kıvılcım çapı üst sınırı.
  static const double kivilcimMaksCapi = 2.6;

  /// Kıvılcım dağılımının sabit tohumu. Yalnızca görseldir; skorla
  /// ilgisi yoktur (her açılışta aynı desen).
  static const int kivilcimTohumu = 7;

  /// En yavaş kıvılcımın hızının en hızlıya oranı.
  static const double kivilcimMinHizOrani = 0.35;

  /// En küçük kıvılcımın çapının [kivilcimMaksCapi]'na oranı.
  static const double kivilcimMinCapOrani = 0.4;

  /// Kıvılcımların dikiş boyunca doğduğu dikey yayılım (kart yüksekliği
  /// oranı, merkezden her iki yöne).
  static const double kivilcimDogumYayilimi = 0.35;

  /// Kıvılcım sönüm eğrisinin üssü ((1 - t)^n).
  static const double kivilcimSonumUssu = 1.5;

  /// Kıvılcım halesinin çapının çekirdeğe oranı.
  static const double kivilcimHaleCarpani = 2;

  /// Kıvılcım halesinin bulanıklığı.
  static const double kivilcimBulanikligi = 3;

  /// Açılışta kartın önünden geçen ışık şeritlerinin sayısı.
  static const int seritSayisi = 2;

  /// Işık şeridinin çizgi kalınlığı.
  static const double seritKalinligi = 2;

  /// Işık şeridi halesinin kalınlığının çekirdeğe oranı.
  static const double seritHaleCarpani = 3;

  /// Işık şeridi halesinin bulanıklığı.
  static const double seritBulanikligi = 6;

  /// Işık şeridinin genliği (kart yüksekliği oranı).
  static const double seritGenligi = 0.12;

  /// Şerit eğrisinin örnekleme adımı (nokta sayısı).
  static const int seritAdimSayisi = 40;

  /// Şeridin kartın solundan taşarak başladığı yer (kart genişliği oranı).
  static const double seritBaslangicX = -0.35;

  /// Şeridin yatay boyu (kart genişliği oranı; kartın iki yanından taşar).
  static const double seritYatayBoyu = 1.7;

  /// İlk şeridin dikey merkezi (kart yüksekliği oranı).
  static const double seritIlkMerkezY = 0.42;

  /// Ardışık şeritlerin dikey aralığı (kart yüksekliği oranı).
  static const double seritAraligi = 0.16;

  /// Şerit halesinin tepe opaklığı.
  static const double seritHaleOpakligi = 0.6;

  /// Şerit çekirdeğinin tepe opaklığı.
  static const double seritCekirdekOpakligi = 0.8;

  // ---- Kapalı kartın bekleme (idle) hareketi ----

  /// Bekleme döngüsünün periyodu (yörünge turu + nefes).
  static const Duration beklemeDongusu = Duration(seconds: 7);

  /// Kartın süzülme genliği (dikey, piksel).
  static const double suzulmeGenligi = 4;

  /// Yörünge elipsinin genişliği (kart genişliği oranı).
  static const double yorungeGenislikOrani = 1.6;

  /// Yörünge elipsinin yüksekliği (kart genişliği oranı).
  static const double yorungeYukseklikOrani = 0.38;

  /// Yörünge elipsinin eğimi (radyan).
  static const double yorungeEgimi = -0.32;

  /// Yörüngedeki küçük gezegenin çapı.
  static const double gezegenCapi = 8;

  /// Gezegen halesinin yarıçapının gezegen yarıçapına oranı.
  static const double gezegenHaleCarpani = 2.5;

  /// Gezegen halesinin opaklığı.
  static const double gezegenHaleOpakligi = 0.35;

  /// Gezegen üzerindeki parlak noktanın konumu (ışık sol üstten).
  static const Alignment gezegenIsikNoktasi = Alignment(-0.4, -0.4);

  /// Yörünge çizgisinin kalınlığı.
  static const double yorungeKalinligi = 1;

  /// Yörünge çizgisinin opaklığı.
  static const double yorungeOpakligi = 0.55;

  // ---- Günün puanı (kart açılınca görünen skor) ----

  /// Skor rakamının yazı boyutu.
  static const double puanYaziBoyutu = 76;

  /// Işık kemerinin çizgi kalınlığı.
  static const double kemerKalinligi = 1.6;

  /// Kemer halesinin kalınlığının çekirdeğe oranı.
  static const double kemerHaleCarpani = 2;

  /// Işık kemeri halesinin bulanıklığı.
  static const double kemerBulanikligi = 5;

  /// Işık kemerinin iç kenar boşluğu (kart genişliği oranı).
  static const double kemerKenarOrani = 0.08;

  /// Skorun arkasındaki yumuşak ışık halesinin opaklığı.
  static const double puanHaleOpakligi = 0.22;

  /// Skorun oturduğu koyu plakanın (madalyonun) yarıçapı (kart genişliği
  /// oranı).
  ///
  /// Sahne görselleri kartın arkasında en parlak hâlini alır (altın kapı,
  /// gün batımı, su yansıması). Kenara doğru sönen yarı saydam bir zemin
  /// Ken Burns yakınlaşmasında ve kısa ekranlarda yetmiyordu: güneş
  /// rakamın tam arkasına düşünce altın rakam kayboluyordu. Plaka bu
  /// yüzden neredeyse opak ve keskin kenarlıdır.
  static const double puanPlakaYariCapOrani = 0.43;

  /// Plakanın opaklığı (neredeyse opak: arkadaki ışık rakama sızmaz).
  static const double puanPlakaOpakligi = 0.92;

  /// Plakanın dışındaki koyu gölge halkasının yarıçapı (plaka yarıçapının
  /// katı): plakayı parlak sahneden ayırır.
  static const double puanPlakaGolgeCarpani = 1.35;

  /// Dış gölge halkasının iç kenardaki opaklığı.
  static const double puanPlakaGolgeOpakligi = 0.55;

  /// Plakanın altın kenar çizgisinin kalınlığı.
  static const double puanPlakaKenarKalinligi = 1.4;

  /// Plakanın altın kenar çizgisinin opaklığı.
  static const double puanPlakaKenarOpakligi = 0.75;

  /// Sahnenin doğrudan üstündeki başlıkların (selamlama, günün başlığı)
  /// gölge opaklığı: parlak su yansımasının üstünde de okunsunlar.
  static const double sahneYaziGolgeOpakligi = 0.9;

  /// Sahne üstü başlıkların gölge bulanıklığı.
  static const double sahneYaziGolgeBulanikligi = 16;

  /// Kart üzerindeki yazıların gölge opaklığı.
  static const double puanYaziGolgeOpakligi = 0.75;

  /// Kart üzerindeki yazıların gölge bulanıklığı.
  static const double puanYaziGolgeBulanikligi = 10;

  // ---- Kategori satırları ("Bugünün alanları") ----
  //
  // Eski tek satırlık beş küçük karo (genişlik ~60 px) dar ekranda
  // göze çarpmıyordu ve kilitli olanlar bulanık bir boşluk gibi
  // görünüyordu. Her kategori artık tam genişlikte bir satır.

  /// Bir kategori satırının yüksekliği.
  static const double kategoriSatirYuksekligi = 76;

  /// Ardışık satırlar arasındaki boşluk.
  static const double kategoriSatirAraligi = 8;

  /// Satır içindeki en küçük dikey boşluk (başlık ↔ alt satır).
  static const double satirIcBosluk = 2;

  /// Satır zemininin koyu taban opaklığı. Satırlar sahnenin parlak ışık
  /// çizgilerinin üstüne düşebildiği için yazının okunması bu tabana
  /// bağlıdır.
  static const double satirZeminOpakligi = 0.86;

  /// Satır zemininin solundaki kategori tonunun opaklığı.
  static const double satirTonOpakligi = 0.22;

  /// Açık satır kenar çizgisinin opaklığı.
  static const double satirKenarOpakligi = 0.45;

  /// Günün yıldızı satırının (en yüksek skor) kenar opaklığı.
  static const double yildizSatirKenarOpakligi = 1;

  /// Kapalı satırın altın kenar opaklığı.
  static const double kapaliSatirKenarOpakligi = 0.2;

  /// Glifin oturduğu yuvarlağın çapı.
  static const double satirIkonZeminCapi = 44;

  /// Glif yuvarlağının kategori rengi opaklığı.
  static const double satirIkonZeminOpakligi = 0.16;

  /// Açık satırdaki glif boyutu.
  static const double satirIkonBoyutu = 26;

  /// Kapalı satırdaki glif boyutu.
  static const double kapaliSatirIkonBoyutu = 28;

  /// Kapalı satırdaki glifin opaklığı.
  static const double kapaliIkonOpakligi = 0.7;

  /// Sağdaki skor sütununun genişliği ("100" sığar, sayılar hizalı).
  static const double satirSkorGenisligi = 52;

  /// Skor rakamının kategori renginden beyaza açılma oranı.
  static const double karoSkorAcikligi = 0.55;

  /// Skor çubuğunun kalınlığı.
  static const double satirCubukYuksekligi = 5;

  /// Skor çubuğu zemininin opaklığı.
  static const double cubukZeminOpakligi = 0.10;

  /// Kilitliyken çubuğun sabit doluluğu (gerçek skor sezdirilmez).
  static const double gizliCubukDolulugu = 0.6;

  /// Kilitli çubuğun renk opaklığı.
  static const double gizliCubukOpakligi = 0.5;

  /// Kilitli çubuğun bulanıklığı.
  static const double gizliCubukBulanikligi = 2.5;

  /// Kilitli satırdaki kilit amblemi boyutu.
  static const double satirKilitBoyutu = 26;

  /// "Günün yıldızı" rozetinin zemin opaklığı.
  static const double rozetZeminOpakligi = 0.16;

  /// "Günün yıldızı" rozetindeki ikonun boyutu.
  static const double rozetIkonBoyutu = 12;

  /// Kutunun açılış (mini flip) süresi.
  static const Duration kutuAcilisSuresi = Duration(milliseconds: 350);

  /// Ardışık kutu açılışları arasındaki gecikme.
  static const Duration kutuGecikmesi = Duration(milliseconds: 120);

  /// Yorum kartının kutulardan sonra belirme (fade) süresi.
  static const Duration yorumBelirmeSuresi = Duration(milliseconds: 400);

  // ---- Günlük okuma v2 ----

  /// Gün gözcüsü zamanlayıcısının payı: zamanlayıcı tam sınırda (gece
  /// yarısı ya da akşam kartı saati) değil bu kadar sonra çalışır ki saat
  /// okunduğunda sınır kesin geçilmiş olsun.
  static const Duration gunDevriPayi = Duration(seconds: 1);

  /// Okuma bölüm kartı ikon boyutu.
  static const double bolumIkonBoyutu = 18;

  /// "Çünkü" satırının (okumanın dayanağı) altın tonlu zemin opaklığı.
  static const double cunkuZeminOpakligi = 0.08;

  /// "Çünkü" satırının kenar çizgisi opaklığı.
  static const double cunkuKenarOpakligi = 0.35;

  /// "Çünkü" satırının başındaki yıldız ikonunun boyutu.
  static const double cunkuIkonBoyutu = 16;

  /// Bölüm etiketlerinin harf aralığı.
  static const double etiketHarfAraligi = 0.4;

  /// Okuma metninin satır yüksekliği (uzun paragraflar rahat okunsun).
  static const double okumaSatirYuksekligi = 1.5;

  /// "Neden bugün?" ay evresi açıklamasındaki ay görselinin boyutu.
  static const double nedenAyBoyutu = 88;

  /// Bu saatten sonra (akşam) geri bildirim kartı gösterilir.
  static const int aksamKartiSaati = 18;
}
