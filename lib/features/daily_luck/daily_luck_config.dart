import 'package:flutter/animation.dart';

/// Ana ekrana (daily_luck) özgü ölçü, eşik ve animasyon sabitleri.
///
/// Magic number yasağı gereği ekrandaki tüm özel ölçüler buradan okunur;
/// genel boşluk/radius değerleri `core/theme/app_dimens.dart`tan gelir.
abstract final class DailyLuckConfig {
  /// Skor halkasının dış çapı.
  static const double halkaCapi = 220;

  /// Skor halkasının çizgi kalınlığı.
  static const double halkaKalinligi = 18;

  /// Kategori mini kartının genişliği.
  static const double kategoriKartGenisligi = 116;

  /// Yatay kategori listesinin yüksekliği.
  static const double kategoriListeYuksekligi = 116;

  /// Kategori kartındaki skor barının kalınlığı.
  static const double kategoriBarYuksekligi = 4;

  /// Kategori kartındaki ikonun kenar uzunluğu.
  static const double kategoriIkonBoyutu = 16;

  // ---- Şans ögeleri kartı (renk / sayı / tavsiye) ----

  /// Şans rengi yuvarlağının çapı.
  static const double sansRengiCapi = 28;

  // ---- Animasyon sabitleri (Session 5) ----

  /// Skor count-up ve halka dolumunun süresi.
  static const Duration skorSayacSuresi = Duration(milliseconds: 1200);

  /// Skor count-up eğrisi.
  static const Curve skorSayacEgrisi = Curves.easeOutCubic;

  /// Yorum kartı flip süresi.
  static const Duration kartFlipSuresi = Duration(milliseconds: 500);

  /// Yorum kartı flip eğrisi (hafif taşmalı, "fizikli" his).
  static const Curve kartFlipEgrisi = Curves.easeInOutBack;

  /// 3D flip perspektif katsayısı (Matrix4 satır 3, sütun 2).
  static const double kartFlipPerspektifi = 0.001;

  /// Kategori kartları arasındaki sahneye giriş gecikmesi.
  static const Duration kategoriGecikmesi = Duration(milliseconds: 80);

  /// Tek bir kategori kartının giriş (fade+slide) süresi.
  static const Duration kategoriGirisSuresi = Duration(milliseconds: 400);

  /// Kategori kartının başladığı dikey ofset (yükseklik oranı).
  static const double kategoriSlideOrani = 0.35;

  // ---- Kader kartı (kapalı kart açılış akışı) ----

  /// Kader kartının genişliği (deste kartı oranı: 2:3).
  static const double kartGenisligi = 220;

  /// Kader kartının yüksekliği.
  static const double kartYuksekligi = 330;

  /// Kart ön yüzündeki skor halkasının çapı.
  static const double kartHalkaCapi = 170;

  /// Kart ön yüzündeki skor halkasının çizgi kalınlığı.
  static const double kartHalkaKalinligi = 12;

  /// Kartın "ekrana yaklaşma + düşme" (iniş) efektinin süresi;
  /// flip süresi [kartFlipSuresi]'dir, toplam açılış ikisinin toplamı.
  static const Duration kartInisSuresi = Duration(milliseconds: 600);

  /// Yaklaşma anındaki azami ölçek (karta "ekrana geliyor" hissi).
  static const double kartYaklasmaOlcegi = 1.30;

  /// Ekrana "düşme" anındaki sıkışma ölçeği (çarpma hissi).
  static const double kartCarpmaOlcegi = 0.965;

  /// Kapalı kategori kutusundaki büyük ikonun boyutu.
  static const double kapaliKutuIkonBoyutu = 32;

  /// Kutunun açılış (mini flip) süresi.
  static const Duration kutuAcilisSuresi = Duration(milliseconds: 350);

  /// Ardışık kutu açılışları arasındaki gecikme.
  static const Duration kutuGecikmesi = Duration(milliseconds: 120);

  /// Yorum kartının kutulardan sonra belirme (fade) süresi.
  static const Duration yorumBelirmeSuresi = Duration(milliseconds: 400);

  /// Kart ile "Kartına dokun" ipucu metni arasındaki dikey boşluk.
  static const double ipucuBoslugu = 12;

  // ---- Arka plan yıldız deseni yerleşimi ----

  /// Köşelere yerleştirilen yıldız desen karosunun boyutu.
  static const double yildizDesenBoyutu = 280;

  /// Desenin ekran köşesinden dışarı taşma miktarı (negatif konum).
  static const double yildizDesenTasmasi = -60;
}
