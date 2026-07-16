import '../../core/localization/app_dil.dart';

/// Kategori detayı ve paywall'un metinleri (TR + EN).
abstract final class CategoriesStrings {
  /// Şanslı saat kartının başlığı.
  static String sansliSaatBaslik(AppDil dil) =>
      dil.sec('Şanslı saat aralığın', 'Your lucky hour');

  /// Kilitli kategoride skor yerine gösterilen maske metni (dil-nötr).
  static const String kilitliSkor = '••';

  /// Kategori kartının ekran okuyucu etiketi ("Aşk: 72 / 100").
  ///
  /// [etiket] zaten aktif dilde gelir; biçim dil-nötrdür.
  static String kartErisim(String etiket, int skor, int maks) =>
      '$etiket: $skor / $maks';

  /// Kilitli kategori kartının erişilebilirlik etiketi.
  ///
  /// Gerçek skoru İÇERMEZ (gizlilik). "Aşk: kilitli" / "Love: locked".
  static String kilitliErisim(AppDil dil, String etiket) =>
      dil.sec('$etiket: kilitli', '$etiket: locked');

  /// Paywall başlığı (marka).
  static const String paywallBaslik = 'Kader Premium';

  /// Paywall açıklaması.
  static String paywallAciklama(AppDil dil) => dil.sec(
    'Aşk ve para kaderini her gün, tüm detaylarıyla gör.',
    'See your love and money fortune every day, in full detail.',
  );

  /// Paywall'da listelenen özellikler.
  static List<String> paywallOzellikler(AppDil dil) => dil.sec(
    const <String>[
      'Aşk ve Para kategorileri açık',
      'Kategoriye özel günlük yorumlar',
      'Şanslı saat aralıkları',
    ],
    const <String>[
      'Love and Money categories unlocked',
      'Category-specific daily readings',
      'Lucky hour ranges',
    ],
  );

  /// Paywall satın alma butonu (placeholder).
  static String paywallButon(AppDil dil) =>
      dil.sec("Premium'a Geç", 'Go Premium');

  /// Satın alma entegrasyonu gelmeden önceki bilgi mesajı.
  static String paywallYakinda(AppDil dil) => dil.sec(
    'Satın alma çok yakında burada olacak ✨',
    'Purchases will be available here very soon ✨',
  );
}
