/// Geçmiş analizinin (Kanıt Döngüsü) saf eşikleri.
///
/// Flutter'sız tutulur (kural 3): analiz katmanı UI bilmez. Feature
/// tarafındaki `HistoryConfig` bu değeri re-export eder ki eşik tek
/// kaynaktan yönetilsin (magic number yasağı — kural 6).
abstract final class HistoryAnalizConfig {
  /// Kanıt yüzdesinin gösterilmesi için gereken en az örnek gün sayısı.
  ///
  /// Yüksek skorlu + geri bildirimli gün sayısı bu eşiğin altındayken
  /// yüzde anlamlı olmaz; UI "kayıt biriktir" durumunu gösterir.
  static const int enAzKanitGunu = 3;
}
