import 'dart:ui';

/// Paylaşım (story kartı) özelliğine özgü ölçü sabitleri.
///
/// Kart, Instagram story formatında (1080x1920) tek seferde
/// off-screen render edilir; buradaki puntolar o tuvale görealdır.
abstract final class ShareConfig {
  /// Telefon ekranındaki 9:16 önizlemenin en geniş hali.
  static const double designerPreviewWidth = 280;

  /// Sahne seçicisinin görsel yüksekliği.
  static const double styleThumbnailHeight = 90;

  /// Sahne seçicisinin çözme bütçesi.
  static const int styleThumbnailWidth = 256;

  /// PNG ve önizlemenin ortak bitmap çözme genişliği.
  static const int captureImageWidth = 1080;

  /// Story uygulamalarının üst kontrol alanından uzaklık.
  static const double storySafeTop = 160;

  /// Alt yanıt/paylaşım alanından uzaklık.
  static const double storySafeBottom = 180;

  /// Dekoratif dış çerçeve dolgusu.
  static const double frameInset = 40;

  /// Altın çerçevenin kalınlığı.
  static const double frameWidth = 2;

  /// Kartpostalı köşe yarıçapı.
  static const double frameRadius = 36;

  /// Skor levhasının köşe yarıçapı.
  static const double heroRadius = 180;

  /// Skor levhası iç dolgusu.
  static const double heroPadding = 56;

  /// Küçük öğe aralığı.
  static const double elementGap = 24;

  /// Bölümler arası aralık.
  static const double sectionGap = 48;

  /// Kısa destekleyici başlık boyutu.
  static const double quoteSize = 64;

  /// Kompakt kategori adı boyutu.
  static const double categoryLabelSize = 32;

  /// Alt açıklama boyutu.
  static const double noteSize = 30;

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

  /// Kilitli kategori satırında skor yerine çizilen kilit ikonunun
  /// boyutu (kategori puntosuyla aynı görsel ağırlıkta).
  static const double kilitIkonBoyutu = 42;

  /// Kategori barının kalınlığı.
  static const double barYuksekligi = 18;

  /// Alt köşedeki uygulama adı puntosu.
  static const double markaPunto = 52;
}
