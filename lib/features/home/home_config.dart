/// Ana kabuk (alt gezinme) ölçüleri.
abstract final class HomeConfig {
  /// Gezinme çubuğunun içerik yüksekliği (alt güvenli alan hariç).
  static const double cubukYuksekligi = 64;

  /// Gezinme ikonlarının boyutu.
  static const double ikonBoyutu = 24;

  /// Seçili sekmenin altındaki ışık çizgisinin genişliği.
  static const double isikCizgisiGenisligi = 28;

  /// Işık çizgisinin kalınlığı.
  static const double isikCizgisiKalinligi = 2;

  /// Işık çizgisi halesinin bulanıklığı.
  static const double isikHalesi = 8;

  /// Çubuk zemininin opaklığı (arkadaki sahne hafifçe sezilir).
  static const double zeminOpakligi = 0.94;

  /// Seçili olmayan sekmelerin ikon/etiket opaklığı.
  static const double pasifOpaklik = 0.7;

  /// Sekme geçiş animasyonunun süresi.
  static const Duration gecisSuresi = Duration(milliseconds: 220);
}
