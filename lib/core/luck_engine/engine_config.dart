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

  /// Karmik borç sayıları: bir hesabın indirgenme zincirinde (ya da doğum
  /// gününde) görüldüklerinde "karmik borç" olarak raporlanır.
  static const Set<int> karmikBorcSayilari = <int>{13, 14, 16, 19};

  /// İlk zirve döneminin bittiği yaş = bu taban − yaşam yolu (tek hane).
  static const int zirveIlkBitisTabani = 36;

  /// İkinci ve üçüncü zirve dönemlerinin uzunluğu (yıl).
  static const int zirveDonemYili = 9;

  /// Zirve/zorluk dönemi sayısı.
  static const int zirveDonemSayisi = 4;

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

  // ---- Doğum haritası (astronomi) ----

  /// Bir burcun ekliptik genişliği (derece).
  static const double burcGenisligi = 30;

  /// Ay burcu bu kadar dereceden sınıra yakınsa "kesin değil" sayılır:
  /// Ay saatte ~0.5° ilerler; ~0.5° ≈ 1 saatlik doğum saati belirsizliği.
  static const double aySinirToleransi = 0.5;

  /// Yükselen bu kadar dereceden sınıra yakınsa "sınırda" sayılır:
  /// Yükselen 4 dakikada ~1° ilerler; 2° ≈ 8 dakikalık saat belirsizliği.
  static const double yukselenSinirToleransi = 2;

  /// Doğum saati bilinmiyorsa Ay burcu bu yerel saat için hesaplanır.
  static const int bilinmeyenSaat = 12;

  // ---- İsim uyumu (bebek ismi) ----

  /// İsim sayısı referans sayıyla aynı gruptaysa puan.
  static const int isimUyumAyniGrupPuani = 95;

  /// İsim sayısı referans sayıyla aynıysa puan (ayna: güçlü ama tek
  /// yönlü; aynı grubun biraz altında).
  static const int isimUyumAynaPuani = 90;

  /// Destekleyici gruplarda puan.
  static const int isimUyumDestekleyiciPuani = 80;

  /// Farklı ritimdeki gruplarda puan (öğretici uyum).
  static const int isimUyumZorlayiciPuani = 60;

  // ---- Tekrarsız içerik seçimi ----

  /// Döngüsel indekste gün numarasının sayıldığı referans yıl (1 Ocak).
  static const int donguReferansYili = 2000;

  // ---- Koleksiyon (günün kartı) ----

  /// Günün koleksiyon kartı seçiminin amaç etiketi (tekrarsız döngü).
  static const String koleksiyonAmaci = 'koleksiyon';

  /// Günün kartının nadir çekiliş olup olmadığının amaç etiketi.
  static const String koleksiyonNadirAmaci = 'koleksiyon_nadir';

  /// Nadir çekilişin paydası: ortalama her N günde bir kart nadir gelir.
  static const int nadirKartPaydasi = 8;
}
