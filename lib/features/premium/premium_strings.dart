/// Premium ve kilit akışlarının Türkçe metinleri.
abstract final class PremiumStrings {
  /// Paywall başlığı.
  static const String baslik = 'Kader Premium';

  /// Paywall alt başlığı.
  static const String altBaslik =
      'Kaderinin tamamını gör: her gün, her kategori, reklamsız.';

  /// Premium'un sunduğu özellikler.
  static const List<String> ozellikler = <String>[
    'Aşk ve Para kategorileri her gün açık',
    'Tam Kader Profili: gölge yanın, aşk, iş, yaşam dersin, iç sesin',
    'Kişisel yıl okuması ve yılın teması',
    'Sınırsız uyum hesabı',
    'Reklamsız deneyim',
  ];

  /// Yıllık plan etiketi.
  static const String yillik = 'Yıllık';

  /// Aylık plan etiketi.
  static const String aylik = 'Aylık';

  /// Yıllık plan rozeti.
  static const String enAvantajli = 'En avantajlı';

  /// Yıllık planın aylık karşılığı metni.
  static String ayliginaDusen(String fiyat) => 'aylık yaklaşık $fiyat';

  /// Deneme süresi metni.
  static String deneme(int gun) => '$gun gün ücretsiz dene';

  /// Dönem son eki.
  static String donem({required bool yillik}) => yillik ? '/ yıl' : '/ ay';

  /// Satın alma butonu.
  static const String abonelikBaslat = 'Aboneliği başlat';

  /// Deneme varsa satın alma butonu.
  static const String denemeBaslat = 'Ücretsiz denemeyi başlat';

  /// Geri yükleme butonu.
  static const String geriYukle = 'Satın alımları geri yükle';

  /// Planlar yüklenirken.
  static const String yukleniyor = 'Abonelik seçenekleri yükleniyor…';

  /// Mağaza yoksa / ürün bulunamadıysa.
  static const String planYok =
      'Abonelik seçenekleri şu an görüntülenemiyor. Uygulamanın Google Play '
      'üzerinden yüklendiğinden ve internet bağlantının açık olduğundan emin ol.';

  /// Tekrar dene butonu.
  static const String tekrarDene = 'Tekrar dene';

  /// Otomatik yenileme ve iptal bilgisi (Play politikası gereği zorunlu).
  static const String yenilemeBilgisi =
      'Abonelik, dönem bitmeden en az 24 saat önce iptal edilmezse aynı süre '
      've fiyatla otomatik yenilenir. Ücretsiz deneme bitmeden iptal '
      'edilmezse ücretli döneme geçilir. Aboneliğini Google Play > Ödemeler '
      've abonelikler bölümünden istediğin zaman iptal edebilirsin.';

  /// Zaten premium olan kullanıcıya.
  static const String zatenPremium = 'Premium üyeliğin aktif ✨';

  /// Premium açıldı mesajı.
  static const String basarili = 'Premium açıldı. Keyfini çıkar ✨';

  /// Kilit sheet başlığı.
  static const String kilitBaslik = 'Bu içerik Premium';

  /// Kilit sheet: premium seçeneği.
  static const String premiumaGec = 'Premium\'a geç';

  /// Kilit sheet: reklam seçeneği.
  static const String reklamlaAc = 'Reklam izle, bugün için aç';

  /// Kilit sheet: reklam yok.
  static const String reklamYok =
      'Şu an gösterilecek reklam bulunamadı. Biraz sonra tekrar deneyebilirsin.';

  /// Kilit sheet: reklam yarıda kaldı.
  static const String odulYok =
      'Reklam tamamlanmadığı için içerik açılamadı.';

  /// Kilit sheet: açıldı.
  static const String acildi = 'Bugün için açıldı ✨';

  /// Kişi sınırı mesajı.
  static const String kisiSiniri =
      'Ücretsiz sürümde bir kişiyle uyum hesaplayabilirsin. Sınırsız kişi '
      'için Premium\'a geçebilirsin.';

  /// Abonelik yönetimi bilgisi.
  static const String yonetimBilgisi =
      'Aboneliğini Google Play Store uygulamasında Profil > Ödemeler ve '
      'abonelikler > Abonelikler bölümünden yönetebilir veya iptal '
      'edebilirsin.';
}
