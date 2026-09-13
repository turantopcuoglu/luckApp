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

/// Ekran ve dokunma alanı sınırları; yükseklikler minimumdur, metin büyüyebilir.
abstract final class AppLayout {
  /// İç dolgu dahil tek sütun ekran genişliğinin üst sınırı.
  static const double maxContentWidth = 560;

  /// Dokunulabilir kontrolün en küçük boyutu.
  static const double minTouchTarget = 48;

  /// Ana/ikincil eylemin minimum yüksekliği.
  static const double buttonMinHeight = 56;

  /// Ortak işlev ikonları.
  static const double iconSize = 24;

  /// Buton içindeki yükleme işareti.
  static const double progressSize = 20;

  /// Alt gezinme hedefinin yazı büyüdükçe artabilen taban yüksekliği.
  static const double navigationMinHeight = 64;

  /// Seçili sekmenin ikon arkasındaki gösterge yüksekliği.
  static const double navigationIndicatorHeight = 32;
}

/// Kenarlık kalınlıkları.
abstract final class AppStroke {
  /// Kart ayırıcı ve ince folyo.
  static const double thin = 1;

  /// Etkileşimli kontrol sınırı.
  static const double control = 1.5;

  /// Klavye odağı ve yükleme çizgisi.
  static const double focus = 2;
}

/// Kontrollü yüzey derinliği; büyük bulanık gölgeler kullanılmaz.
abstract final class AppElevation {
  /// Düz yüzey.
  static const double flat = 0;

  /// Hover veya hafif kalkmış kart.
  static const double raised = 2;

  /// Sheet ve dialog.
  static const double overlay = 6;
}
