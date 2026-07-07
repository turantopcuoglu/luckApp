/// Onboarding akışına özgü ölçü ve animasyon sabitleri.
///
/// Magic number yasağı gereği (CLAUDE.md kural 6).
abstract final class OnboardingConfig {
  /// Karşılama ekranındaki uygulama ikonunun kenar uzunluğu.
  static const double ikonBoyutu = 120;

  /// İkonun köşe yuvarlaklığı (uygulama ikonu hissi için).
  static const double ikonKoseYaricapi = 28;

  /// Doğum tarihi seçicisinin yüksekliği.
  static const double tarihSeciciYuksekligi = 200;

  /// Varsayılan doğum tarihi (seçici ilk açıldığında).
  static final DateTime varsayilanDogumTarihi = DateTime(2000);

  /// Seçilebilir en eski doğum yılı.
  static const int enEskiDogumYili = 1920;

  /// Sahte hesaplama ekranının toplam süresi (plan: 2.5 sn).
  static const Duration hesaplamaSuresi = Duration(milliseconds: 2500);

  /// Parçacık sistemi: parçacık sayısı (plan: 50).
  static const int parcacikSayisi = 50;

  /// Parçacıkların ulaştığı azami yarıçapın ekrana oranı
  /// (kısa kenarın çarpanı).
  static const double parcacikYaricapOrani = 0.35;

  /// Parçacık çapı alt sınırı.
  static const double parcacikMinBoyut = 2;

  /// Parçacık çapı üst sınırı.
  static const double parcacikMaksBoyut = 5;

  /// Parçacık dağılımını üreten sabit tohum: her açılışta aynı
  /// koreografi (determinism ruhuna uygun, test edilebilir).
  static const int parcacikTohumu = 42;

  /// Hero olarak uçan halka yer tutucusunun boyutu.
  static const double heroHalkaBoyutu = 72;

  /// Hero halka yer tutucusunun çizgi kalınlığı.
  static const double heroHalkaKalinligi = 6;
}
