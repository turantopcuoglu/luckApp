/// Kategori detayı ve paywall'un Türkçe metinleri.
abstract final class CategoriesStrings {
  /// Şanslı saat kartının başlığı.
  static const String sansliSaatBaslik = 'Şanslı saat aralığın';

  /// Paywall başlığı.
  static const String paywallBaslik = 'Kader Premium';

  /// Paywall açıklaması.
  static const String paywallAciklama =
      'Aşk ve para kaderini her gün, tüm detaylarıyla gör.';

  /// Paywall'da listelenen özellikler.
  static const List<String> paywallOzellikler = <String>[
    'Aşk ve Para kategorileri açık',
    'Kategoriye özel günlük yorumlar',
    'Şanslı saat aralıkları',
  ];

  /// Paywall satın alma butonu (placeholder).
  static const String paywallButon = "Premium'a Geç";

  /// Satın alma entegrasyonu gelmeden önceki bilgi mesajı.
  static const String paywallYakinda =
      'Satın alma çok yakında burada olacak ✨';
}
