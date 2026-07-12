import '../daily_luck/tr_strings.dart';

/// Kader Kartı Koleksiyonu ekranının Türkçe metinleri.
///
/// Metinler koddan ayrı tutulur (proje deseni); ileride çoklu dil
/// gerekirse tek dokunma noktası burasıdır.
abstract final class CollectionStrings {
  /// Ekranın (AppBar) başlığı.
  static const String baslik = 'Koleksiyon';

  /// Hiç kayıt yokken gösterilen boş durum başlığı.
  static const String bosBaslik = 'Koleksiyonun henüz boş';

  /// Boş durum davet metni.
  static const String bosMetin =
      'Her gün kartını açtıkça buraya eklenir. '
      'Nadir Altın Günler burada parlar.';

  /// Detay bottom sheet'inin başlığı.
  static const String detayBaslik = 'Kader kartın';

  /// "Altın Gün" kartının köşe rozeti.
  static const String altinRozet = '🌟';

  /// Üstteki özet satırı: "$kart kart · $altin Altın Gün".
  static String ozet(int kart, int altin) => '$kart kart · $altin Altın Gün';

  /// [gun] için minik kart üstündeki kısa tarih ("6 Temmuz").
  static String kartTarihi(DateTime gun) =>
      '${gun.day} ${TrStrings.ayAdlari[gun.month - 1]}';

  /// "Altın Gün"ün ekran okuyucuda okunan sözcük karşılığı (emoji değil).
  static const String altinGunSozcuk = 'Altın Gün';

  /// Minik kartın ekran okuyucu (erişilebilirlik) etiketi.
  ///
  /// Kartı tek anlamlı, dokunulabilir düğüme indirger:
  /// "6 Temmuz: 95 / 100, Altın Gün" (altın değilse son ek olmaz).
  static String kartErisim(DateTime gun, int skor, int maks, bool altinGun) {
    final String temel = '${kartTarihi(gun)}: $skor / $maks';
    return altinGun ? '$temel, $altinGunSozcuk' : temel;
  }
}
