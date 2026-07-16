/// Ay Sonu Şans Raporu paylaşım kartının ölçü sabitleri.
///
/// Kart, [ShareConfig.kartBoyutu] (1080x1920) tuvalinde off-screen
/// render edilir; puntolar o tuvale görealdır (magic number yasağı).
abstract final class RecapConfig {
  /// Üstteki "Şans Raporu" üst-başlığının puntosu.
  static const double ustBaslikPunto = 48;

  /// Dev ay/yıl başlığının puntosu.
  static const double ayBasligiPunto = 140;

  /// Öne çıkan istatistik satırının etiket puntosu.
  static const double statEtiketPunto = 40;

  /// Öne çıkan istatistik değerinin puntosu.
  static const double statDegerPunto = 72;

  /// İstatistik satırları arası dikey boşluk.
  static const double statAraligi = 40;

  /// Marka imzası puntosu.
  static const double markaPunto = 52;

  /// Emoji filigranın puntosu (yonca).
  static const double filigranPunto = 260;
}
