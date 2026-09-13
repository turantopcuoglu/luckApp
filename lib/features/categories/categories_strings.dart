import '../../core/localization/app_dil.dart';

/// Kategori detayı ve paywall'un metinleri (TR + EN).
abstract final class CategoriesStrings {
  /// Premium sanat yönünün ana başlığı.
  static String premiumHeadline(AppDil dil) =>
      dil.sec('Deneyimini zenginleştir', 'Enrich your experience');

  /// Mevcut gerçek hak durumu.
  static String active(AppDil dil) =>
      dil.sec('Premium erişimin açık', 'Premium access is active');

  /// Entegrasyon yapılana kadar açık durum bilgisi.
  static String unavailable(AppDil dil) => dil.sec(
    'Satın alma henüz kullanılamıyor',
    'Purchases are not available yet',
  );

  /// Fiyat veya sahte işlem vaat etmeyen açıklama.
  static String purchaseExplanation(AppDil dil, bool active) => active
      ? dil.sec(
          'Aşk ve Para kategorilerini ana ekrandan açabilirsin.',
          'Open Love and Money from the home screen.',
        )
      : dil.sec(
          'Bu sürümde mağaza bağlantısı bulunmuyor. Buradan ödeme alınmaz ve abonelik başlatılmaz.',
          'This version is not connected to a store. No payment is taken and no subscription is started here.',
        );

  /// Premium puanı değiştirmez.
  static String scoreUnchanged(AppDil dil) => dil.sec(
    'Premium şans puanını artırmaz. Kartlar eğlence ve düşünme amaçlıdır.',
    'Premium does not increase your score. Cards are for entertainment and reflection.',
  );

  /// Gerçek geri dönüş eylemi.
  static String backToCards(AppDil dil) =>
      dil.sec('Kartlarıma dön', 'Back to my cards');

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
    'Günlük kartının kilitli kategorilerini ve kısa yorumlarını keşfet.',
    'Explore your daily card’s locked categories and short reflections.',
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
