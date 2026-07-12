/// Kategori detayı ve paywall'un Türkçe metinleri.
abstract final class CategoriesStrings {
  /// Şanslı saat kartının başlığı.
  static const String sansliSaatBaslik = 'Şanslı saat aralığın';

  /// Kilitli kategoride skor yerine gösterilen maske metni.
  ///
  /// Gerçek skor kilitliyken widget ağacına HİÇ girmez; blur'a
  /// güvenilmez (gizlilik: ekran okuyucu/ekran görüntüsü sızıntısı).
  static const String kilitliSkor = '••';

  /// Kategori kartının ekran okuyucu (erişilebilirlik) etiketi.
  ///
  /// Kart içeriğini tek anlamlı düğüme indirger: "Aşk: 72 / 100".
  static String kartErisim(String etiket, int skor, int maks) =>
      '$etiket: $skor / $maks';

  /// Kilitli kategori kartının erişilebilirlik etiketi.
  ///
  /// Gerçek skoru İÇERMEZ (gizlilik: ekran okuyucuya da sızmamalı;
  /// bkz. [kilitliSkor] gerekçesi). "Aşk: kilitli" biçiminde okunur.
  static String kilitliErisim(String etiket) => '$etiket: kilitli';

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
