import '../../core/luck_engine/luck_engine.dart';

/// Kategori detay ve premium iskeletine özgü sabitler.
abstract final class CategoriesConfig {
  /// Premium olmadan kilitli görünen kategoriler (plan Session 9,
  /// madde 2: aşk ve para).
  static const Set<LuckCategory> kilitliKategoriler = <LuckCategory>{
    LuckCategory.ask,
    LuckCategory.para,
  };

  /// Kategori yorumu için "düşük" eşiği (altı düşük).
  static const int dusukEsik = 40;

  /// Kategori yorumu için "yüksek" eşiği (üstü yüksek).
  static const int yuksekEsik = 70;

  /// Kilitli kutulardaki blur şiddeti.
  static const double blurSigma = 3;

  /// Kilit ikonunun boyutu.
  static const double kilitIkonBoyutu = 28;

  /// Detay sayfasındaki skor halkasının çapı.
  static const double detayHalkaCapi = 180;

  /// Detay sayfasındaki skor halkasının kalınlığı.
  static const double detayHalkaKalinligi = 14;

  /// Detay sayfasındaki kategori ikonunun boyutu.
  static const double detayIkonBoyutu = 32;

  /// Paywall'daki kristal küre illüstrasyonunun boyutu.
  static const double paywallIllustrasyonBoyutu = 140;
}
