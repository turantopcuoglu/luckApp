import 'package:flutter/animation.dart';

/// Ortak sahne bileşenlerinin ([SahneArkaPlani], [AltinButon],
/// [CamPanel]) ölçü, süre ve opaklık sabitleri.
///
/// Magic number yasağı gereği (CLAUDE.md kural 6) bu bileşenler yalnızca
/// buradan okur; ekrana özgü ayarlar kurucu parametreleriyle verilir.
abstract final class SahneConfig {
  // ---- Ken Burns ve yıldızlar ----

  /// Ken Burns (yavaş yakınlaşma/kayma) ve parıltı döngüsünün periyodu.
  static const Duration sahneDongusu = Duration(seconds: 24);

  /// Ken Burns'ün ulaştığı azami ölçek.
  static const double kenBurnsOlcegi = 1.06;

  /// Ken Burns yatay kayması (ekran genişliği oranı).
  static const double kenBurnsKaymasi = 0.012;

  /// Ekranda parıldayan yıldız sayısı.
  static const int yildizSayisi = 40;

  /// Yıldızların yerleştiği üst bölge (ekran yüksekliği oranı).
  static const double yildizBolgesiOrani = 0.55;

  /// Yıldız çapı üst sınırı.
  static const double yildizMaksCapi = 1.9;

  /// Bir sahne döngüsünde her yıldızın parıldama sayısı (tam sayı:
  /// döngü sonunda desen kesintisiz başa sarar).
  static const int parildamaKati = 6;

  /// Yıldız konumlarının sabit tohumu (yalnızca görsel).
  static const int yildizTohumu = 11;

  /// En küçük yıldızın çapının [yildizMaksCapi]'na oranı.
  static const double yildizMinCapOrani = 0.4;

  /// Sönükken yıldızın çapının tam parlak çapa oranı.
  static const double yildizSonukCapOrani = 0.6;

  /// Parıltı eğrisinin keskinliği (sin^n): büyüdükçe yıldız kısa
  /// süre parlar, uzun süre söner.
  static const double parildamaKeskinligi = 4;

  /// Bu parlaklığın altındaki yıldızlar hiç çizilmez (performans).
  static const double yildizCizimEsigi = 0.02;

  /// Yıldız halesinin bulanıklık yarıçapı.
  static const double yildizBulanikligi = 1.2;

  /// Bu orandan büyük çaplı yıldızlar ([yildizMaksCapi]'na göre) nokta
  /// yerine dört uçlu parıltı sprite'ıyla çizilir.
  static const double spriteYildizEsigi = 0.85;

  /// Sprite yıldızın kenar uzunluğunun yıldız çapına oranı.
  static const double spriteYildizCarpani = 9;

  // ---- Karartmalar ----

  /// Alt karartma geçişinin varsayılan başlangıcı (ekran oranı).
  static const double altKarartmaBaslangici = 0.48;

  /// Alt karartmanın varsayılan tam opak olduğu yükseklik (ekran oranı).
  static const double altKarartmaSonu = 0.92;

  /// Bu kadar kaydırınca arka plan azami karartmaya ulaşır.
  static const double kaydirmaKarartmaMesafesi = 420;

  /// Kaydırmayla inen azami karartma opaklığı.
  static const double kaydirmaKarartmaMaks = 0.72;

  // ---- Ön plan (paralaks) katmanı ----

  /// Ön plan sütunlarının genişliğinin ekran genişliğine oranı: sütunlar
  /// kenarlardan biraz taşar, ortadaki içerik alanı boş kalır.
  static const double onPlanGenislikOrani = 1.18;

  /// Ön plan katmanının kaydırmaya göre hız çarpanı (1 = içerikle aynı).
  /// Arka plan sabit, içerik 1, ön plan arada: derinlik hissi.
  static const double onPlanKaydirmaCarpani = 0.35;

  /// Sahne geçişinde (kapı açılınca) ön planın yaklaştığı ölçek: kamera
  /// kapıdan içeri ilerliyormuş gibi.
  static const double onPlanGecisOlcegi = 1.08;

  /// Ön planın Ken Burns ölçeği (arka plandan güçlü: paralaks).
  static const double onPlanKenBurnsOlcegi = 1.03;

  /// Ön plan katmanının opaklığı (sahneyi boğmasın).
  static const double onPlanOpakligi = 0.92;

  // ---- Altın buton ----

  /// Altın butonun varsayılan genişliği.
  static const double altinButonGenisligi = 220;

  /// Altın buton gölgesinin bulanıklığı.
  static const double altinButonGolgesi = 18;

  /// Altın buton gölgesinin opaklığı.
  static const double altinButonGolgeOpakligi = 0.35;

  // ---- Cam panel ----

  /// Cam panel zemininin opaklığı (surface rengi üzerinden).
  static const double camZeminOpakligi = 0.62;

  /// Cam panelin altın kenar çizgisinin opaklığı.
  static const double camKenarOpakligi = 0.28;

  /// Cam paneldeki mermer dokusunun opaklığı.
  static const double camDokuOpakligi = 0.35;

  /// Cam panelin bulanıklık (arka plan) yarıçapı.
  static const double camBulanikligi = 12;

  // ---- Sahneli ekran başlığı ----

  /// Görsel üst bant yüksekliğinin ekran genişliğine oranı (yatay
  /// başlık görselleri için: 1536×1024 → ~0.66, alt kısmı zemine erir).
  static const double bantYukseklikOrani = 0.62;

  /// Bant görselinin zemine eridiği gradyanın başlangıcı (bant oranı).
  static const double bantErimeBaslangici = 0.45;

  // ---- Görsel afiş (yatay, sol yarı yazı) ----

  /// Afişin en/boy oranı (görseller 1536×1024).
  static const double afisOrani = 1.5;

  /// Oranla çizilen afişin azami yüksekliği (tablet/geniş ekran).
  static const double afisAzamiYukseklik = 300;

  /// Afişte karartmanın sıfırlandığı sol bölgenin genişliği (oran).
  static const double afisYaziBolgesi = 0.62;

  /// Afişin sol kenarındaki karartmanın opaklığı.
  static const double afisKarartmasi = 0.88;

  /// Afiş yazı sütununun genişliği (afiş genişliği oranı).
  static const double afisYaziGenislikOrani = 0.58;

  /// Kart biçimindeki afişlerin (araç, yıl kartı) yüksekliği.
  static const double afisKartYuksekligi = 132;

  /// Yoğun metinli ekranlarda (ayarlar, detay) karartmanın başladığı
  /// yükseklik (ekran oranı).
  static const double yogunKarartmaBaslangici = 0.10;

  /// Yoğun metinli ekranlarda karartmanın tam opak olduğu yükseklik.
  static const double yogunKarartmaSonu = 0.45;

  /// Uzun ayar listelerinde karartmanın başladığı yükseklik: sahne yalnız
  /// en üstte sezilir.
  static const double listeKarartmaBaslangici = 0;

  /// Uzun ayar listelerinde karartmanın tam opak olduğu yükseklik.
  static const double listeKarartmaSonu = 0.32;

  /// Hata/boş durum görselinin boyutu.
  static const double hataGorselBoyutu = 150;

  /// Sahne geçiş eğrisi (arka plan crossfade).
  static const Curve gecisEgrisi = Curves.easeInOut;
}
