/// Ay Sonu Şans Raporu özelliğinin Türkçe metinleri.
abstract final class RecapStrings {
  /// Kartın üst-başlığı.
  static const String ustBaslik = 'ŞANS RAPORU';

  /// History ekranındaki bölüm başlığı.
  static const String bolumBasligi = 'Bu Ayın Şans Raporu';

  /// History ekranındaki paylaş butonu.
  static const String paylasButonu = 'Ay raporunu paylaş ✨';

  /// Paylaşım menüsüne eklenen kısa metin.
  static const String paylasimMetni = 'Bu ayki şans raporum ✨';

  /// En şanslı gün istatistiği etiketi.
  static const String enSansliGunEtiketi = 'En şanslı günün';

  /// Ortalama skor istatistiği etiketi.
  static const String ortalamaEtiketi = 'Ortalama skorun';

  /// Altın gün sayısı istatistiği etiketi.
  static const String altinGunEtiketi = 'Altın Gün';

  /// En uzun seri istatistiği etiketi.
  static const String enUzunSeriEtiketi = 'En uzun serin';

  /// Baskın kategori istatistiği etiketi.
  static const String baskinKategoriEtiketi = 'Öne çıkan';

  /// Kayıtlı gün sayısı istatistiği etiketi.
  static const String gunSayisiEtiketi = 'Kayıtlı gün';

  /// Altın gün değerinin yıldız ekli gösterimi ($sayi 🌟).
  static String altinGunDegeri(int sayi) => '$sayi 🌟';

  /// En uzun seri değerinin alev ekli gösterimi ($gun 🔥).
  static String enUzunSeriDegeri(int gun) => '$gun 🔥';

  /// "$gun gün" biçiminde gün değeri.
  static String gunDegeri(int gun) => '$gun gün';

  /// History kartındaki özet satırı ($ay $yil · $gun gün · ortalama $ort).
  static String kartOzeti(String ay, int yil, int gun, int ortalama) =>
      '$ay $yil · $gun gün · ortalama $ortalama';
}
