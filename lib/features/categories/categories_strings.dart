/// Kategori detayının Türkçe metinleri.
abstract final class CategoriesStrings {
  /// Şanslı saat kartının başlığı.
  static const String sansliSaatBaslik = 'Şanslı saat aralığın';

  /// Kilitli kategori açıklaması (kilit seçenekleri sayfasında).
  static String kilitAciklamasi(String kategori) =>
      '$kategori kategorisinin bugünkü skoru, sana özel yorumu ve şanslı '
      'saati Premium üyelere açık. İstersen kısa bir reklam izleyerek '
      'yalnızca bugün için de açabilirsin.';
}
