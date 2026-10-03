/// Raster (JPEG) görsellerin asset yolları.
///
/// Görseller `assets/images/` altındadır; telefona göre küçültülmüş,
/// opak JPEG'lerdir. Kaynak çizimler ve hangi dosyanın nereden geldiği
/// `GORSEL_URETIM_REHBERI.md` içinde listelenir.
abstract final class AppImages {
  /// Kader kartının kapalı yüzü: lacivert mermer, ortada altın mühür,
  /// tam ortadan dikey altın dikiş (kart buradan iki kanada ayrılır).
  static const String kartArkaYuzu = 'assets/images/kart_arka_yuzu.jpg';

  /// Kart açılmadan önceki sakin sahne: sütunlar, hilal, bulutlar.
  static const String sahneKapali = 'assets/images/sahne_kapali.jpg';

  /// Yüksek skor sahnesi: turkuaz ışıkla açılmış kapılar.
  static const String sahneYuksek = 'assets/images/sahne_yuksek.jpg';

  /// Orta skor sahnesi: altın kemer ardında gün doğumu.
  static const String sahneOrta = 'assets/images/sahne_orta.jpg';

  /// Düşük skor sahnesi: lavanta ışıklı, sakin kapılar.
  static const String sahneDusuk = 'assets/images/sahne_dusuk.jpg';
}
