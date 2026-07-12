import '../../core/localization/app_dil.dart';

/// Ay Sonu Şans Raporu özelliğinin metinleri (TR + EN).
abstract final class RecapStrings {
  /// Kartın üst-başlığı.
  static String ustBaslik(AppDil dil) => dil.sec('ŞANS RAPORU', 'LUCK REPORT');

  /// History ekranındaki bölüm başlığı.
  static String bolumBasligi(AppDil dil) =>
      dil.sec('Bu Ayın Şans Raporu', "This Month's Luck Report");

  /// History ekranındaki paylaş butonu.
  static String paylasButonu(AppDil dil) =>
      dil.sec('Ay raporunu paylaş ✨', 'Share monthly report ✨');

  /// Paylaşım menüsüne eklenen kısa metin.
  static String paylasimMetni(AppDil dil) =>
      dil.sec('Bu ayki şans raporum ✨', 'My luck report this month ✨');

  /// En şanslı gün istatistiği etiketi.
  static String enSansliGunEtiketi(AppDil dil) =>
      dil.sec('En şanslı günün', 'Your luckiest day');

  /// Ortalama skor istatistiği etiketi.
  static String ortalamaEtiketi(AppDil dil) =>
      dil.sec('Ortalama skorun', 'Your average score');

  /// Altın gün sayısı istatistiği etiketi.
  static String altinGunEtiketi(AppDil dil) =>
      dil.sec('Altın Gün', 'Golden Day');

  /// En uzun seri istatistiği etiketi.
  static String enUzunSeriEtiketi(AppDil dil) =>
      dil.sec('En uzun serin', 'Your longest streak');

  /// Baskın kategori istatistiği etiketi.
  static String baskinKategoriEtiketi(AppDil dil) =>
      dil.sec('Öne çıkan', 'Standout');

  /// Kayıtlı gün sayısı istatistiği etiketi.
  static String gunSayisiEtiketi(AppDil dil) =>
      dil.sec('Kayıtlı gün', 'Days logged');

  /// Altın gün değerinin yıldız ekli gösterimi ($sayi 🌟, dil-nötr).
  static String altinGunDegeri(int sayi) => '$sayi 🌟';

  /// En uzun seri değerinin alev ekli gösterimi ($gun 🔥, dil-nötr).
  static String enUzunSeriDegeri(int gun) => '$gun 🔥';

  /// "$gun gün" / "$gun days" biçiminde gün değeri.
  static String gunDegeri(AppDil dil, int gun) =>
      dil.sec('$gun gün', '$gun days');

  /// History kartındaki özet satırı ($ay $yil · $gun gün · ortalama $ort).
  ///
  /// [ay] zaten aktif dilde (ay adı) gelir.
  static String kartOzeti(AppDil dil, String ay, int yil, int gun, int ort) =>
      dil.sec(
        '$ay $yil · $gun gün · ortalama $ort',
        '$ay $yil · $gun days · avg $ort',
      );
}
