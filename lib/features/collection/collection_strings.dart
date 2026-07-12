import '../../core/localization/app_dil.dart';
import '../daily_luck/tr_strings.dart';

/// Kader Kartı Koleksiyonu ekranının metinleri (TR + EN).
abstract final class CollectionStrings {
  /// Ekranın (AppBar) başlığı.
  static String baslik(AppDil dil) => dil.sec('Koleksiyon', 'Collection');

  /// Hiç kayıt yokken gösterilen boş durum başlığı.
  static String bosBaslik(AppDil dil) =>
      dil.sec('Koleksiyonun henüz boş', 'Your collection is empty');

  /// Boş durum davet metni.
  static String bosMetin(AppDil dil) => dil.sec(
    'Her gün kartını açtıkça buraya eklenir. '
        'Nadir Altın Günler burada parlar.',
    'Each day you open your card, it is added here. '
        'Rare Golden Days shine here.',
  );

  /// Detay bottom sheet'inin başlığı.
  static String detayBaslik(AppDil dil) =>
      dil.sec('Kader kartın', 'Your fate card');

  /// "Altın Gün" kartının köşe rozeti (dil-nötr).
  static const String altinRozet = '🌟';

  /// "Altın Gün"ün ekran okuyucuda okunan sözcük karşılığı (emoji değil).
  static String altinGunSozcuk(AppDil dil) =>
      dil.sec('Altın Gün', 'Golden Day');

  /// Üstteki özet satırı: "$kart kart · $altin Altın Gün".
  static String ozet(AppDil dil, int kart, int altin) => dil.sec(
    '$kart kart · $altin Altın Gün',
    '$kart cards · $altin Golden Days',
  );

  /// [gun] için minik kart üstündeki kısa tarih ("6 Temmuz" / "6 July").
  static String kartTarihi(AppDil dil, DateTime gun) =>
      '${gun.day} ${TrStrings.ayAdlari(dil)[gun.month - 1]}';

  /// Minik kartın ekran okuyucu (erişilebilirlik) etiketi.
  ///
  /// "6 Temmuz: 95 / 100, Altın Gün" (altın değilse son ek olmaz).
  static String kartErisim(
    AppDil dil,
    DateTime gun,
    int skor,
    int maks,
    bool altinGun,
  ) {
    final String temel = '${kartTarihi(dil, gun)}: $skor / $maks';
    return altinGun ? '$temel, ${altinGunSozcuk(dil)}' : temel;
  }
}
