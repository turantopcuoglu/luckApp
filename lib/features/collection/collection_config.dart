import '../../core/theme/app_dimens.dart';

/// Kader Kartı Koleksiyonu ekranının görsel sabitleri.
///
/// Magic number yasağı (CLAUDE.md kural 6) gereği grid ölçüleri ve
/// minik kartın iç ölçüleri burada tanımlıdır. Renk rampası ve "Altın
/// Gün" eşiği ise mevcut tek kaynaklardan (`HistoryConfig.bandRampasi`,
/// `HistoryAnalizConfig.altinGunEsigi`) yeniden kullanılır.
abstract final class CollectionConfig {
  /// Grid sütun sayısı (oyun kartı destesi hissi için 3'lü dizilim).
  static const int sutunSayisi = 3;

  /// Minik kartın en/boy oranı (genişlik / yükseklik).
  ///
  /// 0.7 ≈ klasik oyun/tarot kartı oranına yakın: dikey, dar kart hissi.
  static const double kartOrani = 0.7;

  /// Grid hücreleri arası (yatay + dikey) boşluk.
  static const double kartAraligi = AppSpacing.sm;

  /// "Altın Gün" kartının altın kenar kalınlığı.
  static const double altinKenarKalinligi = 2;

  /// Minik kartın iç dolgusu.
  static const double kartIcDolgu = AppSpacing.sm;

  /// Altın rozetinin köşeden iç boşluğu.
  static const double rozetKenarBoslugu = AppSpacing.xs;

  /// Detay bottom sheet'inin dış dolgusu.
  static const double detayDolgu = AppSpacing.lg;
}
