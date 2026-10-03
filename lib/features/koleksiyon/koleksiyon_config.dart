/// Koleksiyon ekranlarının ölçüleri.
abstract final class KoleksiyonConfig {
  /// Kart görsellerinin en/boy oranı (600×900).
  static const double kartOrani = 2 / 3;

  /// Izgaradaki sütun sayısı.
  static const int izgaraSutunu = 3;

  /// Izgara hücresinin en/boy oranı (kart + altında ad).
  static const double hucreOrani = 0.52;

  /// Izgarada kart adının en fazla satır sayısı.
  static const int adSatirSayisi = 2;

  /// Öne çıkan kartın ekran genişliğine oranı.
  static const double oneCikanOrani = 0.55;

  /// Öne çıkan kartın yüksekliğinin ekran yüksekliğine azami oranı.
  static const double oneCikanYukseklikOrani = 0.42;

  /// Detay ekranındaki kartın yüksekliğinin ekran yüksekliğine azami oranı.
  static const double detayYukseklikOrani = 0.55;

  /// Detay ekranındaki kartın ekran genişliğine oranı.
  static const double detayOrani = 0.72;

  /// Kazanılmamış kartın karartma opaklığı.
  static const double kilitliKarartma = 0.72;

  /// Kazanılmamış kartın bulanıklığı.
  static const double kilitliBulaniklik = 3;

  /// Kazanılmamış karttaki kilit ambleminin kart genişliğine oranı.
  static const double kilitOrani = 0.32;

  /// Ana ekran panelindeki küçük kartın genişliği.
  static const double panelKartGenisligi = 56;

  /// Profil özetindeki küçük kartların genişliği.
  static const double ozetKartGenisligi = 48;

  /// Profil özetinde gösterilen en fazla kart.
  static const int ozetKartSayisi = 4;

  /// Nadir kartın altın halesinin bulanıklığı.
  static const double nadirHalesi = 18;

  /// Nadir kart halesinin opaklığı.
  static const double nadirHaleOpakligi = 0.45;

  /// Kart köşe yarıçapının kart genişliğine oranı (çerçeve görseliyle
  /// uyumlu yuvarlaklık).
  static const double koseOrani = 0.06;
}
