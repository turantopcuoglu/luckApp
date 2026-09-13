import '../../core/content/experience_dimension.dart';
import '../../core/luck_engine/luck_engine.dart';

/// Kategori detay ve premium iskeletine özgü sabitler.
abstract final class CategoriesConfig {
  /// Premium detayları olan deneyim alanlarının tek tanımı.
  static const Set<ExperienceDimension> kilitliAlanlar = <ExperienceDimension>{
    ExperienceDimension.bag,
    ExperienceDimension.uretim,
  };

  /// Eski ekran ve paylaşım çağrıları için aynı politikanın kategori karşılığı.
  static final Set<LuckCategory> kilitliKategoriler =
      Set<LuckCategory>.unmodifiable(
        kilitliAlanlar.map((ExperienceDimension alan) => alan.kategori),
      );

  /// Kilitli kutulardaki blur şiddeti.
  static const double blurSigma = 10;

  /// Kilitli kutunun üzerine binen karartma katmanının opaklığı.
  ///
  /// Blur tek başına yetmez: sayı gibi yüksek kontrastlı içerik zayıf
  /// blur'da okunabilir kalır. Scrim ikinci bir güvenlik katmanıdır.
  static const double kilitScrimOpaklik = 0.55;

  /// Kilitli kartta ilerleme barının sabit dolgu oranı.
  ///
  /// Gerçek skor oransal bar dolgusundan bile okunabildiği için
  /// kilitliyken bar hiç dolmaz.
  static const double kilitliBarOran = 0;

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
