/// Uygulama genelinde kullanılan boşluk (spacing) ve köşe yarıçapı
/// (radius) sabitleri.
///
/// Magic number yasağı gereği tüm ölçüler buradan okunur
/// (bkz. CLAUDE.md kural 6).
abstract final class AppSpacing {
  /// 4dp — en küçük boşluk birimi.
  static const double xs = 4;

  /// 8dp — sıkışık öğeler arası.
  static const double sm = 8;

  /// 16dp — varsayılan içerik dolgusu.
  static const double md = 16;

  /// 24dp — bölümler arası.
  static const double lg = 24;

  /// 32dp — büyük bölüm ayrımları.
  static const double xl = 32;

  /// 48dp — ekran kenarı geniş boşluklar / min dokunma alanı.
  static const double xxl = 48;
}

/// Köşe yarıçapı sabitleri.
abstract final class AppRadius {
  /// 8dp — küçük öğeler (chip, etiket).
  static const double sm = 8;

  /// 16dp — kartlar.
  static const double md = 16;

  /// 24dp — büyük kartlar, sheet üst köşeleri.
  static const double lg = 24;

  /// Tam yuvarlak (stadium) buton ve halkalar için.
  static const double full = 999;
}
