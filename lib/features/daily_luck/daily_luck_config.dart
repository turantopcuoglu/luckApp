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
  static const double puanHaleOpakligi = 0.35;

  // ---- Kategori karoları ----

  /// Kategori karosunun yüksekliği.
  static const double kategoriKaroYuksekligi = 96;

  /// Açık karodaki kategori ikonunun boyutu.
  static const double kategoriIkonBoyutu = 22;

  /// Kapalı karodaki ikonun boyutu.
  static const double kapaliKutuIkonBoyutu = 26;

  /// Açık karo zeminindeki kategori renginin opaklığı.
  static const double karoZeminOpakligi = 0.20;

  /// Açık karo kenar çizgisinin opaklığı.
  static const double karoKenarOpakligi = 0.55;

  /// Karo skor rakamının kategori renginden beyaza açılma oranı.
  static const double karoSkorAcikligi = 0.35;

  /// Kapalı karo zemininin opaklığı (cam görünümü).
  static const double kapaliKaroOpakligi = 0.55;

  /// Kapalı karodaki ikonun opaklığı.
  static const double kapaliIkonOpakligi = 0.7;

  /// Kutunun açılış (mini flip) süresi.
  static const Duration kutuAcilisSuresi = Duration(milliseconds: 350);

  /// Ardışık kutu açılışları arasındaki gecikme.
  static const Duration kutuGecikmesi = Duration(milliseconds: 120);

  /// Yorum kartının kutulardan sonra belirme (fade) süresi.
  static const Duration yorumBelirmeSuresi = Duration(milliseconds: 400);

  // ---- Günlük okuma v2 ----

  /// Okuma bölüm kartı ikon boyutu.
  static const double bolumIkonBoyutu = 18;

  /// Büyük harfli bölüm etiketlerinin harf aralığı.
  static const double etiketHarfAraligi = 1.2;

  /// "Neden bugün?" ay evresi açıklamasındaki ay görselinin boyutu.
  static const double nedenAyBoyutu = 88;

  /// Bu saatten sonra (akşam) geri bildirim kartı gösterilir.
  static const int aksamKartiSaati = 18;
}
