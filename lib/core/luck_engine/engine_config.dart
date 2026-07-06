/// Şans motorunun tüm sayısal sabitleri.
///
/// Magic number yasağı (CLAUDE.md kural 6) gereği motorun kullandığı
/// eşikler, olasılıklar ve aralıklar yalnızca buradan okunur.
abstract final class EngineConfig {
  /// Skorların yoğunlaştığı bandın alt sınırı.
  static const double bandAlt = 40;

  /// Skorların yoğunlaştığı bandın üst sınırı.
  static const double bandUst = 85;

  /// Alt uç bölgesinin üst sınırı: bu değerin altı "çok şanssız" gün.
  static const double ucAltSinir = 15;

  /// Üst uç bölgesinin alt sınırı: bu değerin üstü "çok şanslı" gün.
  static const double ucUstSinir = 92;

  /// Her bir uca (alt ve üst) düşme olasılığı; toplam uç ihtimali %3.
  static const double ucOlasilik = 0.015;

  /// Skor ölçeğinin üst sınırı.
  static const int skorMaks = 100;

  /// Skor ölçeğinin alt sınırı.
  static const int skorMin = 0;

  /// Ay evresi ve numeroloji modifiyerlerinin mutlak azami etkisi.
  static const int modifiyerMaksEtki = 8;

  /// Son üç gün ortalaması bu eşiğin altındaysa seri dengesi devreye girer.
  static const double dusukSeriEsigi = 45;

  /// Seri dengesi bias'ının alt sınırı.
  static const int seriBiasMin = 5;

  /// Seri dengesi bias'ının üst sınırı.
  static const int seriBiasMaks = 10;

  /// Ortalama sinodik ay uzunluğu (gün) — ay evresi hesabında kullanılır.
  static const double sinodikAyGun = 29.530588853;
}
