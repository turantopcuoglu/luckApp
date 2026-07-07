import 'dart:ui';

/// Paylaşım (story kartı) özelliğine özgü ölçü sabitleri.
///
/// Kart, Instagram story formatında (1080x1920) tek seferde
/// off-screen render edilir; buradaki puntolar o tuvale görealdır.
abstract final class ShareConfig {
  /// Story kartının tuval boyutu (piksel = mantıksal, pixelRatio 1).
  static const Size kartBoyutu = Size(1080, 1920);

  /// Kart kenar boşluğu.
  static const double kenarBoslugu = 96;

  /// Paylaşılan dosyanın adı.
  static const String dosyaAdi = 'kader_gunun_sansi.png';

  /// Büyük skor halkasının çapı.
  static const double halkaCapi = 680;

  /// Büyük skor halkasının çizgi kalınlığı.
  static const double halkaKalinligi = 44;

  /// Tarih metni puntosu.
  static const double tarihPunto = 44;

  /// Dev skor sayısının puntosu.
  static const double skorPunto = 240;

  /// "GENEL SKOR" etiket puntosu.
  static const double skorEtiketPunto = 40;

  /// Kategori satırı yüksekliği.
  static const double kategoriSatirYuksekligi = 88;

  /// Kategori etiket puntosu.
  static const double kategoriPunto = 42;

  /// Kategori etiket sütunu genişliği.
  static const double kategoriEtiketGenisligi = 220;

  /// Kategori skor sütunu genişliği.
  static const double kategoriSkorGenisligi = 96;

  /// Kategori barının kalınlığı.
  static const double barYuksekligi = 18;

  /// Alt köşedeki uygulama adı puntosu.
  static const double markaPunto = 52;
}
