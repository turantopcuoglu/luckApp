/// Günün şans rengi: kullanıcıya gösterilen ad + ARGB değeri.
///
/// Saf Dart kalması için Flutter'ın `Color` tipi kullanılmaz; UI
/// katmanı `Color(sansRengi.hexArgb)` ile çevirir.
class SansRengi {
  /// [ad] ve [hexArgb] ile bir şans rengi oluşturur.
  const SansRengi({required this.ad, required this.hexArgb});

  /// Kullanıcıya gösterilen Türkçe renk adı (örn. "Gece Mavisi").
  final String ad;

  /// Tam opak ARGB değeri (örn. 0xFF1B2A4A).
  final int hexArgb;

  @override
  bool operator ==(Object other) =>
      other is SansRengi && other.ad == ad && other.hexArgb == hexArgb;

  @override
  int get hashCode => Object.hash(ad, hexArgb);

  @override
  String toString() =>
      'SansRengi($ad, 0x${hexArgb.toRadixString(16).toUpperCase()})';
}
