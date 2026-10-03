import '../../core/luck_engine/uyum.dart';
import '../../shared/widgets/app_images.dart';

/// Uyum ekranlarına özgü ölçü ve görsel sabitleri.
abstract final class UyumConfig {
  /// Uyum ekranının üstündeki iki ışıklı yörünge görselinin boyutu.
  static const double kahramanBoyutu = 180;

  /// Kişi listesindeki burç madalyonunun boyutu.
  static const double kisiMadalyonBoyutu = 44;

  /// Sonuç sahnesinin alt karartmasının başladığı yükseklik (ekran oranı).
  static const double karartmaBaslangici = 0.30;

  /// Sonuç sahnesinin tam opak olduğu yükseklik (ekran oranı).
  static const double karartmaSonu = 0.62;

  /// Sonuç metinlerindeki satır yüksekliği çarpanı.
  static const double metinSatirAraligi = 1.5;

  /// Uyum derecesine göre sonuç ekranının arka plan sahnesi: iki kemer
  /// arasında tamamlanmış (güçlü/dengeli) ya da oluşmakta olan köprü.
  static String sahne(UyumDerecesi derece) => switch (derece) {
    UyumDerecesi.guclu => AppImages.uyumGuclu,
    UyumDerecesi.dengeli => AppImages.uyumDengeli,
    UyumDerecesi.gelistiren => AppImages.uyumGelistiren,
  };
}
