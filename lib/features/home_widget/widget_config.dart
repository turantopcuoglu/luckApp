/// Ana ekran widget'ının native köprü sabitleri.
///
/// Bu sabitler native tarafla (Android Kotlin, iOS Swift) **birebir**
/// eşleşmelidir: veri anahtarları aynı string'lerle okunur/yazılır,
/// provider/target adları native kaynakların adlarıyla aynıdır.
/// Magic string yasağı (kural 6) gereği tek kaynak burasıdır.
abstract final class WidgetConfig {
  /// Android AppWidget provider sınıf adı (KaderWidgetProvider.kt).
  static const String androidProvider = 'KaderWidgetProvider';

  /// iOS WidgetKit widget adı (KaderWidget.swift).
  static const String iosName = 'KaderWidget';

  /// iOS App Group kimliği (Runner + widget target paylaşır).
  ///
  /// iOS'ta veri App Group UserDefaults ile paylaşılır; Android'de
  /// [setAppGroupId] zararsızdır.
  static const String appGroupId = 'group.com.turan.kader';

  /// Genel skor veri anahtarı.
  static const String anahtarSkor = 'skor';

  /// Biçimli tarih veri anahtarı.
  static const String anahtarTarih = 'tarih';

  /// Kısa ipucu (teaser) veri anahtarı.
  static const String anahtarTeaser = 'teaser';
}
