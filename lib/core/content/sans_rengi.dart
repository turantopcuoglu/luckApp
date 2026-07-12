import '../localization/app_dil.dart';

/// Günün şans rengi: kullanıcıya gösterilen ad (TR + EN) + ARGB değeri.
///
/// Saf Dart kalması için Flutter'ın `Color` tipi kullanılmaz; UI
/// katmanı `Color(sansRengi.hexArgb)` ile çevirir. Ad iki dilde
/// tutulur; [hexArgb] dilden bağımsızdır.
class SansRengi {
  /// [adTr]/[adEn] ve [hexArgb] ile bir şans rengi oluşturur.
  const SansRengi({
    required this.adTr,
    required this.adEn,
    required this.hexArgb,
  });

  /// Türkçe renk adı (örn. "Gece Mavisi").
  final String adTr;

  /// İngilizce renk adı (örn. "Midnight Blue").
  final String adEn;

  /// Tam opak ARGB değeri (örn. 0xFF1B2A4A).
  final int hexArgb;

  /// [dil]'e göre gösterilecek renk adı.
  String ad(AppDil dil) => dil.sec(adTr, adEn);

  @override
  bool operator ==(Object other) =>
      other is SansRengi &&
      other.adTr == adTr &&
      other.adEn == adEn &&
      other.hexArgb == hexArgb;

  @override
  int get hashCode => Object.hash(adTr, adEn, hexArgb);

  @override
  String toString() =>
      'SansRengi($adTr/$adEn, 0x${hexArgb.toRadixString(16).toUpperCase()})';
}
