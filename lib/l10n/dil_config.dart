import '../core/content/icerik_paketi.dart';

/// Uygulama dili sabitleri (INGILIZCE_SURUM_PLANI.md K3, E3).
abstract final class DilConfig {
  /// İngilizce sürüm kullanıcılara açık mı?
  ///
  /// `false` iken (E12'ye kadar) uygulama her zaman Türkçe açılır: arayüz
  /// ve içerik çevirisi tamamlanmadan cihazı İngilizce olan Türk kullanıcı
  /// yarı çevrilmiş bir uygulama görmesin. Ayarlar'daki dil seçimi bu
  /// sürede yalnız debug derlemede görünür (emülatörde deneme için).
  static const bool ingilizceYayinda = false;

  /// Cihaz dili bu koddaysa Türkçe, değilse İngilizce seçilir (K3).
  static const String turkceKodu = 'tr';

  /// Dilin kendi dilindeki adı (dil seçiminde çevrilmeden gösterilir).
  static String yerelAd(IcerikDili dil) => switch (dil) {
    IcerikDili.tr => 'Türkçe',
    IcerikDili.en => 'English',
  };
}
