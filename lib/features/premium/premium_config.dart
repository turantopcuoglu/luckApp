/// Premium abonelik ürünleri ve doğrulama kuralları.
///
/// GOOGLE PLAY CONSOLE KURULUMU (geliştirici yapar):
/// 1. Uygulamayı en az "Dahili test" kanalına bir kez yükle (faturalandırma
///    izni ancak yüklü bir sürümle etkinleşir).
/// 2. Para kazanma > Ürünler > Abonelikler bölümünde aşağıdaki kimliklerle
///    İKİ abonelik oluştur; her birine bir "temel plan" ekle (otomatik
///    yenilenen, aylık / yıllık) ve etkinleştir. İstersen yıllık plana
///    ücretsiz deneme teklifi ekle.
/// 3. Para kazanma > Ürünler > Uygulama içi ürünler bölümünde
///    [raporUrunId] kimliğiyle TEK SEFERLİK bir ürün oluştur, fiyatını
///    belirle ve etkinleştir (Numeroloji Raporu kalıcı kilidi). Aynı
///    bölümde [satistakiYil] için `kader_yil_<yıl>` kimlikli ikinci bir
///    tek seferlik ürün oluştur (ör. `kader_yil_2027`, Kişisel Yıl Raporu).
///    Her yıl yeni yılın ürününü açıp [satistakiYil]'ı güncellemek yeterli;
///    eski yılların ürünleri satın alanlar için geçerli kalır.
/// 4. Ayarlar > Lisans testi bölümüne test Google hesabını ekle; bu hesapla
///    yapılan satın alımlar ücretlendirilmez ve yenileme süreleri kısalır.
abstract final class PremiumConfig {
  /// Aylık abonelik ürün kimliği.
  static const String aylikUrunId = 'kader_premium_aylik';

  /// Yıllık abonelik ürün kimliği.
  static const String yillikUrunId = 'kader_premium_yillik';

  /// Numeroloji Raporu'nu kalıcı olarak açan tek seferlik ürün kimliği.
  ///
  /// Abonelik değildir: [urunKimlikleri] içinde yer almaz ve Premium
  /// yetkisi vermez; yalnızca raporun kilidini açar.
  static const String raporUrunId = 'kader_rapor_tam';

  /// Kişisel Yıl Raporu'nun şu an satılan yılı.
  static const int satistakiYil = 2027;

  /// Yıl raporu ürün kimliklerinin ön eki.
  static const String yilRaporuOnEki = 'kader_yil_';

  /// [yil] için Kişisel Yıl Raporu ürün kimliği ("kader_yil_2027").
  static String yilRaporuUrunId(int yil) => '$yilRaporuOnEki$yil';

  /// Mağazadan fiyatı yüklenen (satıştaki) tek seferlik ürünler.
  static List<String> get satistakiTekSeferlikler => <String>[
    raporUrunId,
    yilRaporuUrunId(satistakiYil),
  ];

  /// [urunId] uygulamanın tanıdığı bir tek seferlik ürün mü? (Satıştan
  /// kalkmış eski yıl raporları da tanınır.)
  static bool tekSeferlikMi(String urunId) =>
      urunId == raporUrunId || urunId.startsWith(yilRaporuOnEki);

  /// Uygulamanın tanıdığı tüm abonelik kimlikleri (gösterim sırası).
  static const List<String> urunKimlikleri = <String>[
    yillikUrunId,
    aylikUrunId,
  ];

  /// Mağazaya ulaşılamadığında önbellekteki aktif aboneliğin geçerli
  /// sayılacağı süre (çevrimdışı kullanım toleransı).
  static const Duration cevrimdisiTolerans = Duration(days: 7);

  /// Premium olmadan uyum ekranına kaydedilebilecek kişi sayısı.
  static const int ucretsizKisiSiniri = 1;
}
