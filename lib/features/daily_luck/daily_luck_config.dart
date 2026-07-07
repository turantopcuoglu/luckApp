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

  /// Yorumda kullanılacak en fazla modifiyer cümlesi sayısı
  /// (açılış cümlesiyle birlikte toplam 2-3 cümle hedefi).
  static const int yorumModifiyerSayisi = 2;

  /// Skor yorum aralıkları: bu eşiğin altı "çok düşük" gündür.
  static const int cokDusukEsik = 15;

  /// Bu eşiğin altı "düşük", üstü "orta" başlangıcıdır.
  static const int dusukEsik = 40;

  /// Bu eşiğin üstü "iyi" gündür.
  static const int ortaEsik = 60;

  /// Bu eşiğin üstü "çok yüksek" gündür.
  static const int yuksekEsik = 85;

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

  // ---- Arka plan yıldız deseni yerleşimi ----

  /// Köşelere yerleştirilen yıldız desen karosunun boyutu.
  static const double yildizDesenBoyutu = 280;

  /// Desenin ekran köşesinden dışarı taşma miktarı (negatif konum).
  static const double yildizDesenTasmasi = -60;
}
