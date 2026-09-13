/// Desen analizinin UI ve platformdan bağımsız ürün eşikleri.
abstract final class PatternsConfig {
  /// Bugün dahil ritim penceresi.
  static const int rhythmDays = 30;

  /// Birbirini izleyen iki trend penceresinin ayrı ayrı uzunluğu.
  static const int trendDays = 7;

  /// Her iki pencerede de gereken yanıt sayısı; istatistiksel güven değildir.
  static const int minimumTrendResponses = 3;

  /// Seri içinde bir boş güne izin verilir; boş gün seriye eklenmez.
  static const int graceDays = 1;

  /// En az iki boş günden sonraki katılım bir geri dönüş sayılır.
  static const int returnGapDays = 3;

  /// Farklı katılım günlerine bağlı koleksiyon eşikleri.
  static const List<int> participationMilestones = <int>[3, 7, 14, 21];

  /// Farklı değerlendirme günlerine bağlı koleksiyon eşikleri.
  static const List<int> feedbackMilestones = <int>[5, 10];

  /// Parlak Yol için açılmış kartın genel skor alt sınırı.
  static const int brightPathScore = 92;
}
