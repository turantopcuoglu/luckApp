import '../luck_engine/luck_category.dart';

/// Genel skorun yorum tonunu belirleyen beş bant.
///
/// Eşikler [ContentConfig] içinde tanımlıdır; bantlar yalnızca metin
/// seçiminde kullanılır, skor hesabını etkilemez.
enum SkorBandi {
  /// 0..14: nadir "çok şanssız" gün.
  cokDusuk,

  /// 15..39: temkinli gün.
  dusuk,

  /// 40..59: dengeli gün.
  orta,

  /// 60..85: rüzgârı arkasına almış gün.
  yuksek,

  /// 86..100: nadir "çok şanslı" gün.
  cokYuksek;

  /// [skor] için uygun bandı döndürür.
  static SkorBandi bandiBul(int skor) {
    if (skor < ContentConfig.cokDusukEsik) {
      return SkorBandi.cokDusuk;
    }
    if (skor < ContentConfig.dusukEsik) {
      return SkorBandi.dusuk;
    }
    if (skor < ContentConfig.ortaEsik) {
      return SkorBandi.orta;
    }
    if (skor <= ContentConfig.yuksekEsik) {
      return SkorBandi.yuksek;
    }
    return SkorBandi.cokYuksek;
  }
}

/// Tek bir kategorinin skoruna göre yorum tonu.
enum KategoriTonu {
  /// Kategori skoru düşük: koruyucu, yavaşlatıcı ton.
  dusuk,

  /// Kategori skoru orta: dengeli, akışta ton.
  orta,

  /// Kategori skoru yüksek: cesaretlendirici ton.
  yuksek;

  /// [skor] için uygun tonu döndürür.
  static KategoriTonu tonuBul(int skor) {
    if (skor < ContentConfig.kategoriDusukEsik) {
      return KategoriTonu.dusuk;
    }
    if (skor > ContentConfig.kategoriYuksekEsik) {
      return KategoriTonu.yuksek;
    }
    return KategoriTonu.orta;
  }
}

/// İçerik sisteminin eşikleri, sınırları ve tohum amaç etiketleri.
///
/// Magic number yasağı (CLAUDE.md kural 6) gereği içerik seçimiyle
/// ilgili tüm sabitler buradadır.
abstract final class ContentConfig {
  // ---- Genel skor bant eşikleri (eski DailyLuckConfig değerleri) ----

  /// Bu eşiğin altı "çok düşük" gündür.
  static const int cokDusukEsik = 15;

  /// Bu eşiğin altı "düşük", üstü "orta" başlangıcıdır.
  static const int dusukEsik = 40;

  /// Bu eşiğin üstü "iyi" gündür.
  static const int ortaEsik = 60;

  /// Bu eşiğin üstü "çok yüksek" gündür.
  static const int yuksekEsik = 85;

  // ---- Kategori ton eşikleri (eski CategoriesConfig değerleri) ----

  /// Kategori yorumu için "düşük" eşiği (altı düşük).
  static const int kategoriDusukEsik = 40;

  /// Kategori yorumu için "yüksek" eşiği (üstü yüksek).
  static const int kategoriYuksekEsik = 70;

  // ---- Şanslı sayı sınırları ----

  /// Günün şanslı sayısının alt sınırı (dahil).
  static const int sansliSayiMin = 1;

  /// Günün şanslı sayısının üst sınırı (dahil).
  static const int sansliSayiMaks = 99;

  // ---- Minimum havuz boyutları (bütünlük testleri için) ----

  /// Bant başına en az açılış cümlesi sayısı.
  static const int enAzAcilisVaryanti = 9;

  /// (kategori, ton) başına en az orta cümle sayısı.
  ///
  /// Orta cümle havuzu en küçük ve baskın kategori günlerce
  /// değişmeyebildiği için tekrar hissi en çok buradan doğar; bu
  /// yüzden bilinçli olarak yüksek tutulur.
  static const int enAzOrtaVaryanti = 6;

  /// En az kapanış cümlesi sayısı.
  static const int enAzKapanis = 12;

  /// En az günün tavsiyesi sayısı.
  static const int enAzTavsiye = 24;

  /// En az şans rengi sayısı.
  static const int enAzRenk = 12;

  /// (kategori, ton) başına en az kategori açılış cümlesi sayısı.
  static const int enAzKategoriVaryanti = 6;

  /// Kategori başına en az tavsiye cümlesi sayısı.
  static const int enAzKategoriTavsiye = 4;

  // ---- Tohum amaç etiketleri ----
  // Her içerik alanı kendi etiketiyle bağımsız tohumdan seçim yapar;
  // etiket değişirse o alanın seçimi değişir, diğerleri etkilenmez.

  /// Günlük yorumun açılış cümlesi.
  static const String amacAcilis = 'acilis';

  /// Günlük yorumun orta (baskın kategori) cümlesi.
  static const String amacOrta = 'orta';

  /// Günlük yorumun kapanış cümlesi.
  static const String amacKapanis = 'kapanis';

  /// Günün tavsiyesi.
  static const String amacTavsiye = 'tavsiye';

  /// Günün şans rengi.
  static const String amacRenk = 'renk';

  /// Günün şanslı sayısı.
  static const String amacSayi = 'sayi';

  /// [kategori] detayındaki [alan] için amaç etiketi üretir.
  ///
  /// Örn. `kategoriAmaci(LuckCategory.ask, 'acilis')` → `'ask:acilis'`.
  static String kategoriAmaci(LuckCategory kategori, String alan) =>
      '${kategori.name}:$alan';
}
