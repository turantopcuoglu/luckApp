/// Ana ekrana (daily_luck) özgü ölçü ve eşik sabitleri.
///
/// Magic number yasağı gereği ekrandaki tüm özel ölçüler buradan okunur;
/// genel boşluk/radius değerleri `core/theme/app_dimens.dart`tan gelir.
abstract final class DailyLuckConfig {
  /// Skor halkasının dış çapı.
  static const double halkaCapi = 220;

  /// Skor halkasının çizgi kalınlığı.
  static const double halkaKalinligi = 18;

  /// Kategori mini kartının genişliği.
  static const double kategoriKartGenisligi = 116;

  /// Yatay kategori listesinin yüksekliği.
  static const double kategoriListeYuksekligi = 116;

  /// Kategori kartındaki skor barının kalınlığı.
  static const double kategoriBarYuksekligi = 4;

  /// Kategori kartındaki ikonun kenar uzunluğu.
  static const double kategoriIkonBoyutu = 16;

  /// Yorumda kullanılacak en fazla modifiyer cümlesi sayısı
  /// (açılış cümlesiyle birlikte toplam 2-3 cümle hedefi).
  static const int yorumModifiyerSayisi = 2;

  /// Skor yorum aralıkları: bu eşiğin altı "çok düşük" gündür.
  static const int cokDusukEsik = 15;

  /// Bu eşiğin altı "düşük", üstü "orta" başlangıcıdır.
  static const int dusukEsik = 40;

  /// Bu eşiğin üstü "iyi" gündür.
  static const int ortaEsik = 60;

  /// Bu eşiğin üstü "çok yüksek" gündür.
  static const int yuksekEsik = 85;
}
