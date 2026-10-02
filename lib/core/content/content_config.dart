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
  static const int enAzAcilisVaryanti = 6;

  /// (kategori, ton) başına en az orta cümle sayısı.
  static const int enAzOrtaVaryanti = 4;

  /// En az kapanış cümlesi sayısı.
  static const int enAzKapanis = 12;

  /// En az günün tavsiyesi sayısı.
  static const int enAzTavsiye = 24;

  /// En az şans rengi sayısı.
  static const int enAzRenk = 12;

  /// (kategori, ton) başına en az kategori açılış cümlesi sayısı.
  static const int enAzKategoriVaryanti = 4;

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

  // ---- Günlük okuma amaç etiketleri ----

  /// Günün başlığı.
  static const String amacBaslik = 'baslik';

  /// Günün durum cümlesi (tema × ton).
  static const String amacEnerji = 'enerji';

  /// Günün teması ile kişinin doğasının buluşma cümlesi.
  static const String amacBulusma = 'bulusma';

  /// Kategori durum cümlesi (kategori × kişinin durumu × ton).
  static const String amacDurum = 'durum';

  /// Dönem (kişisel yıl) cümlesi.
  static const String amacYil = 'yil';

  /// Şanslı saatli eylem cümlesi.
  static const String amacEylem = 'eylem';

  /// Dikkat cümlesi.
  static const String amacDikkat = 'dikkat';

  /// Buluşma türüne göre karakter önerisi.
  static const String amacOneri = 'oneri';

  /// Kişinin bir kategorideki tarz cümlesi.
  static const String amacTarz = 'tarz';

  /// Tarz cümlesinin öne çıkan alan ve dikkat paragrafları arasında
  /// dönüşüm periyodu (gün): çift günlerde öne çıkan alanda, tek günlerde
  /// dikkat paragrafında yer alır.
  static const int tarzDonusumu = 2;

  /// Günün temasının gündelik hayattaki sahnesi.
  static const String amacSahne = 'sahne';

  /// Tema × uğraş başına en az sahne varyantı.
  static const int enAzSahneVaryanti = 2;

  /// Kategori detay sayfasındaki seçimlerin amaç eki (günlük kartla aynı
  /// cümleyi göstermemek için).
  static const String amacDetayEki = 'detay';

  // ---- Günlük okuma ayarları ----

  /// Kişisel güne bağlı havuzların yaklaşık kullanım aralığı (gün):
  /// kişisel gün sayısı 1-9 arasında döndüğü için ~9 günde bir gelir.
  static const int kisiselGunAdimi = 9;

  /// Beğenilmeyen varyantlar çıkarıldıktan sonra havuzda kalması gereken
  /// en az varyant; daha azı kalırsa filtre uygulanmaz. İki varyantlı
  /// havuzlarda "beni anlatmadı" denen varyantın bir daha gelmemesi için 1.
  static const int enAzKalanVaryant = 1;

  /// Günün teması durum havuzlarında (tema × ton) en az varyant.
  ///
  /// Kişisel gün ~9 günde bir geldiği için iki varyant yeterlidir.
  static const int enAzDurumVaryanti = 2;

  /// Kategori durum havuzlarında (kategori × durum × ton) en az varyant.
  ///
  /// Öne çıkan kategori ayda 10-15 kez aynı tonda gelebildiği için
  /// gün temasından daha geniş tutulur.
  static const int enAzKategoriDurumVaryanti = 4;

  /// Buluşma türü başına en az "doğanla buluşma" cümlesi (her gün
  /// kullanılır).
  static const int enAzBulusmaVaryanti = 5;

  /// Karakter başına her öneri türünde (güç/gölge/denge) en az varyant.
  static const int enAzOneriVaryanti = 4;

  /// Karakter başına her kategori tarzında en az varyant.
  static const int enAzTarzVaryanti = 4;

  /// Kişisel yıl başına en az dönem cümlesi ve kişisel ay başına en az
  /// "bu ay" cümlesi.
  static const int enAzDonemVaryanti = 4;

  /// Kategori başına en az şanslı saatli eylem cümlesi.
  static const int enAzEylemDikkat = 6;

  // ---- Tekrar denetimi (bkz. test/content/tekrar_denetimi_test.dart) ----

  /// Tekrar ölçümünün yapıldığı ardışık gün sayısı.
  static const int denetimGunSayisi = 30;

  /// Denetim penceresinde aynı cümlenin en fazla görülme sayısı.
  static const int denetimEnFazlaAyniCumle = 6;

  /// Denetim penceresinde benzersiz cümlelerin tüm cümlelere oranının
  /// alt sınırı (yüzde).
  static const int denetimEnAzBenzersizYuzde = 55;

  /// Ardışık gün çiftlerinden (kapanış hariç) hiç ortak cümle
  /// içermeyenlerin alt sınırı (yüzde).
  static const int denetimEnAzArdisikFarkYuzde = 80;

  /// Tek okumada "Bugün" ile başlayan en fazla cümle sayısı.
  static const int denetimEnFazlaBugunBasi = 1;

  /// Tek okumada kalıp ifadelerin toplam en fazla geçme sayısı.
  static const int denetimEnFazlaKalip = 2;

  /// Okuru ezber hissine sokan kalıp ifadeler (küçük harf).
  static const List<String> kalipIfadeler = <String>[
    'uygun bir gün',
    'elverişli bir gün',
    'anlamına gelebilir',
    'iyi gelir',
    'iyi gelecek',
  ];

  /// Rapordaki ayrıntılı metinlerin (zirve, zorluk, karmik borç) en az
  /// kelime sayısı.
  static const int raporUzunEnAzKelime = 35;

  /// Rapordaki kısa metinlerin (isim analizleri, özetler) en az kelime
  /// sayısı.
  static const int raporKisaEnAzKelime = 8;

  /// Profil bölümü başına en az kelime sayısı (yüzeysel metin olmasın).
  static const int profilEnAzKelime = 18;

  /// Tüm profil okumasının toplam en az kelime sayısı.
  static const int profilToplamEnAzKelime = 300;

  /// Günlük okuma toplamı için en az kelime sayısı.
  static const int gunlukEnAzKelime = 90;

  /// Uygun olmayan içerik testinde yasaklı ifadeler (küçük harf).
  ///
  /// Kelime başında eşleşir ("ölüm" yasak, "bölüm" serbest). Kesinlik
  /// vaadi, sağlık teşhisi/tedavisi, yatırım yönlendirmesi ve
  /// korku üreten ifadeler yorum metinlerinde kullanılamaz.
  static const List<String> yasakliIfadeler = <String>[
    'kesinlikle',
    'garanti ederim',
    'mutlaka',
    'teşhis',
    'ilaç',
    'yatırım yap',
    'borsa',
    'kripto',
    'hisse senedi',
    'hastalık',
    'ölüm',
    'kaza geçir',
    'kazası',
    '%100',
  ];
}
