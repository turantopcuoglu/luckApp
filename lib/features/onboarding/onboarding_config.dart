/// Onboarding akışına özgü ölçü ve animasyon sabitleri.
///
/// Magic number yasağı gereği (CLAUDE.md kural 6).
abstract final class OnboardingConfig {
  /// Kısa ve okunabilir görünen ad/rumuz sınırı (grapheme).
  static const int isimMaksUzunluk = 40;

  /// Büyük yazıda doğrulama mesajının satır alanı.
  static const int hataMaksSatir = 4;

  /// Karşılama ekranındaki uygulama ikonunun kenar uzunluğu.
  static const double ikonBoyutu = 120;

  /// İkonun köşe yuvarlaklığı (uygulama ikonu hissi için).
  static const double ikonKoseYaricapi = 28;

  /// Kart hazırlama geçişinin toplam süresi.
  static const Duration hesaplamaSuresi = Duration(milliseconds: 1600);

  /// Hazırlama sahnesinin genişliği.
  static const double hazirlamaBoyutu = 240;

  /// Sahnedeki kapalı kartın genişliği.
  static const double hazirlamaKartGenisligi = 160;

  /// Kartın ilk yerleşme açısı (radyan).
  static const double hazirlamaAci = 0.065;

  /// Kart yerleşme mesafesi.
  static const double hazirlamaMesafe = 18;

  /// Folyo üzerindeki ışığın azami opaklığı.
  static const double isikOpakligi = 0.24;

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
