import '../../core/theme/app_dimens.dart';

/// Kader Kartı Koleksiyonu ekranının görsel sabitleri.
///
/// Magic number yasağı (CLAUDE.md kural 6) gereği grid ölçüleri ve
/// minik kartın iç ölçüleri burada tanımlıdır. Renk rampası ve "Altın
/// Gün" eşiği ise mevcut tek kaynaklardan (`HistoryConfig.bandRampasi`,
/// `HistoryAnalizConfig.altinGunEsigi`) yeniden kullanılır.
abstract final class CollectionConfig {
  /// V4 sahne galerisi: odak görseli ve detay önizlemesi.
  static const double sceneHeroHeight = 250;

  /// Açılan detay görselinin yüksekliği.
  static const double sceneDetailHeight = 280;

  /// Standart yazıda sahne + başlık hücresi.
  static const double sceneTileHeight = 174;

  /// Büyük yazıda hücre alanı.
  static const double sceneLargeTileHeight = 240;

  /// Başlık yazısında iki sütuna geçiş ölçüsü.
  static const double largeTextThreshold = 22;

  /// Galerinin sütun aralığı.
  static const double sceneColumnGap = 12;

  /// Galerinin satır aralığı.
  static const double sceneRowGap = 14;

  /// Thumbnail çözme bütçesi.
  static const int sceneThumbnailWidth = 320;

  /// Detay çözme bütçesi.
  static const int sceneDetailWidth = 512;

  /// Grid sütun sayısı (oyun kartı destesi hissi için 3'lü dizilim).
  static const int sutunSayisi = 3;

  /// Büyük erişilebilirlik yazısında daha geniş kartlar.
  static const int buyukYaziSutunSayisi = 2;

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

  /// Küçük kart için tam ekran görselinden daha düşük decode bütçesi.
  static const int kartGorselGenisligi = 384;

  /// Yazı tipine bağlı olmayan Altın Gün yıldızının boyutu.
  static const double rozetBoyutu = 18;

  /// Detay bottom sheet'inin dış dolgusu.
  static const double detayDolgu = AppSpacing.lg;
}
