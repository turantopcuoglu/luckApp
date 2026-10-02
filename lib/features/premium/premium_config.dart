/// Premium abonelik ürünleri ve doğrulama kuralları.
///
/// GOOGLE PLAY CONSOLE KURULUMU (geliştirici yapar):
/// 1. Uygulamayı en az "Dahili test" kanalına bir kez yükle (faturalandırma
///    izni ancak yüklü bir sürümle etkinleşir).
/// 2. Para kazanma > Ürünler > Abonelikler bölümünde aşağıdaki kimliklerle
///    İKİ abonelik oluştur; her birine bir "temel plan" ekle (otomatik
///    yenilenen, aylık / yıllık) ve etkinleştir. İstersen yıllık plana
///    ücretsiz deneme teklifi ekle.
/// 3. Ayarlar > Lisans testi bölümüne test Google hesabını ekle; bu hesapla
///    yapılan satın alımlar ücretlendirilmez ve yenileme süreleri kısalır.
abstract final class PremiumConfig {
  /// Aylık abonelik ürün kimliği.
  static const String aylikUrunId = 'kader_premium_aylik';

  /// Yıllık abonelik ürün kimliği.
  static const String yillikUrunId = 'kader_premium_yillik';

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
