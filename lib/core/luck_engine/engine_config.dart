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

  /// Şanslı saat aralığının başlayabileceği en erken saat.
  static const int sansliSaatEnErken = 8;

  /// Şanslı saat aralığının başlayabileceği en geç saat.
  static const int sansliSaatEnGecBaslangic = 20;

  /// Şanslı saat aralığının uzunluğu (saat).
  static const int sansliSaatSuresi = 2;

  // ---- Numeroloji ----

  /// Tek haneli numeroloji tabanı: sayılar 1..9'a indirgenir.
  static const int numerolojiTabani = 9;

  /// İndirgenmeden korunan usta sayılar.
  static const Set<int> ustaSayilar = <int>{11, 22, 33};

  // ---- Ay evresi ----

  /// Sinodik ayın bölündüğü evre sayısı (yeni ay … küçülen hilal).
  static const int ayEvresiSayisi = 8;

  // ---- Burç ----

  /// Burç sınırına bu kadar gün yakın doğanlar için "sınır günü"
  /// uyarısı gösterilir (burç, doğum saatine göre değişebilir).
  static const int burcSinirToleransiGun = 1;

  // ---- Uyum hesabı ----

  /// Uyum skorunun başlangıç tabanı.
  static const int uyumTaban = 52;

  /// Aynı yaşam yolu sayısı ("ayna") katkısı.
  static const int uyumAynaPuani = 16;

  /// Aynı uyum grubundaki yaşam yolları katkısı.
  static const int uyumAyniGrupPuani = 22;

  /// Destekleyici gruplardaki yaşam yolları katkısı.
  static const int uyumDestekleyiciPuani = 8;

  /// Aynı element katkısı.
  static const int uyumAyniElementPuani = 12;

  /// Tamamlayıcı elementler (ateş-hava, toprak-su) katkısı.
  static const int uyumTamamlayiciElementPuani = 10;

  /// Zıt elementler (ateş-su, toprak-hava) katkısı.
  static const int uyumZitElementPuani = -4;

  /// Ruh sayıları aynı gruptaysa katkı.
  static const int uyumRuhPuani = 8;

  /// Çiftlere özgü deterministik küçük sapmanın mutlak sınırı.
  static const int uyumSapmaSiniri = 3;

  /// Uyum skorunun alt sınırı.
  static const int uyumMin = 35;

  /// Uyum skorunun üst sınırı.
  static const int uyumMaks = 98;

  /// Bu skor ve üstü "güçlü uyum".
  static const int uyumGucluEsik = 80;

  /// Bu skor ve üstü "dengeli uyum" (altı "geliştiren uyum").
  static const int uyumDengeliEsik = 62;

  // ---- Tekrarsız içerik seçimi ----

  /// Döngüsel indekste gün numarasının sayıldığı referans yıl (1 Ocak).
  static const int donguReferansYili = 2000;
}
