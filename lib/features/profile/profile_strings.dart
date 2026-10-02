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

  // ---- Büyük Üçlü (doğum haritası) ----

  /// Kart ve ekran başlığı.
  static const String buyukUcluBaslik = 'Büyük Üçlün';

  /// Kart açıklaması.
  static const String buyukUcluAciklama =
      'Güneş burcun kim olduğunu, Ay burcun nasıl hissettiğini, Yükselenin '
      'dünyaya nasıl göründüğünü anlatır.';

  /// Sütun etiketleri.
  static const String gunes = 'Güneş';

  /// Sütun etiketi.
  static const String ay = 'Ay';

  /// Sütun etiketi.
  static const String yukselen = 'Yükselen';

  /// Bilinmeyen değer.
  static const String bilinmiyor = '?';

  /// Yükselen yokken düğme.
  static const String yukseleniniOgren = 'Yükselenini öğren';

  /// Harita ekranına giden düğme.
  static const String haritaniOku = 'Haritanı oku';

  /// Güneş bölümü başlığı.
  static String gunesBasligi(String burc) => 'Güneş burcun · $burc';

  /// Harita kilit açıklaması.
  static const String haritaKilitAciklamasi =
      'Yükselen yorumun Premium üyelere açık. İstersen kısa bir reklam '
      'izleyerek bugün için de açabilirsin.';

  // ---- Doğum bilgisi düzenleyici ----

  /// Düzenleyici başlığı.
  static const String dogumBilgisiBaslik = 'Doğum saatin ve yerin';

  /// Düzenleyici açıklaması.
  static const String dogumBilgisiAciklama =
      'Yükselen burcun doğum saatine ve doğduğun yere göre değişir. Nüfus '
      'kaydındaki ya da ailenin hatırladığı saati gir; birkaç dakikalık fark '
      'bile Yükseleni değiştirebilir.';

  /// Doğum saati satırı.
  static const String dogumSaati = 'Doğum saati';

  /// Saat bilinmiyor.
  static const String saatBilinmiyor = 'Bilmiyorum';

  /// Saat seç.
  static const String saatSec = 'Saat seç';

  /// Doğum ili alanı.
  static const String dogumIli = 'Doğduğun il';

  /// Doğum ili ipucu.
  static const String dogumIliIpucu = 'İl adı yaz (ör. İzmir)';

  /// Kaydet.
  static const String kaydet = 'Kaydet';

  /// Doğum saati gösterimi ("08:05").
  static String saatMetni(int dakika) =>
      '${(dakika ~/ Duration.minutesPerHour).toString().padLeft(2, '0')}:'
      '${(dakika % Duration.minutesPerHour).toString().padLeft(2, '0')}';

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
