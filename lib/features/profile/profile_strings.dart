/// Kader Profili ekranının Türkçe metinleri.
abstract final class ProfileStrings {
  /// Ekran başlığı.
  static const String baslik = 'Kader Profilin';

  /// Başlık altı açıklama.
  static const String aciklama =
      'Doğum tarihin ve adından hesaplanan, zamanla değişmeyen sayıların. '
      'Her sayıya dokunarak nasıl hesaplandığını görebilirsin.';

  /// Yaşam yolu karo etiketi.
  static const String yasamYolu = 'Yaşam Yolu';

  /// İsim sayısı karo etiketi.
  static const String isimSayisi = 'İsim';

  /// Ruh sayısı karo etiketi.
  static const String ruhSayisi = 'Ruh';

  /// Kişilik sayısı karo etiketi.
  static const String kisilikSayisi = 'Kişilik';

  /// Tam ad yokken karo metni.
  static const String tamAdEkle = 'Tam adını ekle';

  /// Tam ad eksik kartı.
  static const String tamAdEksikBaslik = 'İsim sayıların eksik';

  /// Tam ad eksik açıklaması.
  static const String tamAdEksikAciklama =
      'İsim, ruh ve kişilik sayıların doğumdaki tam adından hesaplanır. '
      'Tam adını eklersen profiline iki yeni bölüm açılır.';

  /// Nasıl hesaplandı başlığı.
  static const String nasilHesaplandi = 'Nasıl hesaplandı?';

  /// Hesap sistemi notu.
  static const String sistemNotu =
      'Kader, Pitagor numeroloji sistemini kullanır: A=1 … I=9, J=1 … R=9, '
      'S=1 … Z=8. Türkçe harfler Latin karşılıklarının değerini alır '
      '(Ç=3, Ğ=7, I/İ=9, Ö=6, Ş=1, Ü=3). 11, 22 ve 33 usta sayı olarak '
      'korunur. Farklı numeroloji sistemleri farklı sonuçlar verebilir.';

  /// Adım etiketleri.
  static const String adimAy = 'Doğum ayı';

  /// Adım etiketleri.
  static const String adimGun = 'Doğum günü';

  /// Adım etiketleri.
  static const String adimYil = 'Doğum yılı';

  /// Adım etiketleri.
  static const String adimToplam = 'Toplam';

  /// Adım etiketleri.
  static const String adimHarfler = 'Tüm harfler';

  /// Adım etiketleri.
  static const String adimSesliler = 'Sesli harfler';

  /// Adım etiketleri.
  static const String adimSessizler = 'Sessiz harfler';

  /// Usta sayı notu.
  static const String ustaSayi = 'Usta sayı';

  /// Kilitli bölüm butonu.
  static const String kilidiAc = 'Kilidi aç';

  /// Kilit açıklaması.
  static const String kilitAciklamasi =
      'Profilinin tamamı — gölge yanın, aşk ve iş hayatın, yaşam dersin, '
      'iç sesin ve bu yılın teması — Premium üyelere açık. İstersen kısa '
      'bir reklam izleyerek bugün için de açabilirsin.';

  /// Burç sınır uyarısı çipi.
  static const String sinirGunu = 'Burç sınırı';

  // ---- Numeroloji raporu ----

  /// Profilden rapora giriş kartının başlığı.
  static const String raporGirisBaslik = 'Numeroloji Raporun';

  /// Profilden rapora giriş kartının açıklaması.
  static const String raporGirisAciklama =
      'Hayatının dört dönemi, karmik sayıların ve isminin gizli anlamları.';

  /// Rapor ekranı başlığı.
  static const String raporBaslik = 'Numeroloji Raporun';

  /// Rapor ekranı açıklaması.
  static const String raporAciklama =
      'Doğum tarihin ve tam adından hesaplanan, hayatının uzun dönemlerine '
      'dair temalar. Bu rapor bir eğilim haritasıdır; olayları değil, '
      'dönemlerin sana neyi öğretmeye çalıştığını anlatır.';

  /// Zaman çizelgesi başlığı.
  static const String zamanCizelgesiBaslik = 'Hayatının dört dönemi';

  /// Aktif dönem etiketi.
  static const String suAn = 'Şu an';

  /// Zaman çizelgesinde zirve sayısı etiketi.
  static String zirveEtiketi(int zirve) => 'Zirve $zirve';

  // ---- Kişisel Yıl Raporu ----

  /// Ana ekran tanıtım kartı başlığı.
  static String yilRaporuKartBaslik(int yil) => '$yil Kişisel Yıl Raporun';

  /// Ana ekran tanıtım kartı açıklaması ("2027 senin için Tohum Yılı.").
  static String yilRaporuKartAciklama(int yil, String yilLakabi) =>
      '$yil senin için $yilLakabi. Yılın fırsatları, akışta olduğun aylar '
      've ay ay rehberin hazır.';

  /// Yıl raporu ekran başlığı.
  static String yilRaporuBaslik(int yil) => '$yil Raporun';

  /// Yıl raporu üst bilgisindeki etiket.
  static const String kisiselYilEtiketi = 'Kişisel yılın';

  /// Ay ay bölümü başlığı.
  static String ayAyBaslik(int yil) => 'Ay ay $yil';

  /// Akış ayı çipi.
  static const String akisCipi = 'Akışta';

  /// Zorlu ay çipi.
  static const String zorluCipi = 'Zorlayıcı';

  /// Tam ad yokken rapor kartı başlığı.
  static const String raporTamAdEksikBaslik = 'Raporun yarım kaldı';

  /// Tam ad yokken rapor kartı açıklaması.
  static const String raporTamAdEksikAciklama =
      'Karmik derslerin, gizli tutkun, olgunluk sayın ve isminin harfleri '
      'doğumdaki tam adından hesaplanır. Tam adını eklersen raporuna beş '
      'yeni bölüm açılır.';
}
