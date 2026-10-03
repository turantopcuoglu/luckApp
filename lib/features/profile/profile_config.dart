/// Kader Profili ekranına özgü ölçüler.
abstract final class ProfileConfig {
  /// "Nasıl hesaplandı?" satırlarında etiket sütununun genişliği.
  static const double adimEtiketGenisligi = 96;

  /// Kilitli bölüm metninin bulanıklık şiddeti.
  static const double kilitBulanikligi = 4;

  /// Kilitli bölümde bulanık gösterilen en fazla satır.
  static const int kilitliSatirSayisi = 3;

  /// Kilitli bölüm başlığındaki kilit ambleminin boyutu.
  static const double kilitAmblemBoyutu = 26;

  // ---- Profil başlığı ve madalyonlar ----

  /// Avatarın bant genişliğine oranı (zodyak halkasının içine sığar).
  static const double avatarOrani = 0.22;

  /// Avatarın dikey hizası (bant içinde; halkanın merkezi biraz yukarıda).
  static const double avatarHizasiY = -0.12;

  /// Avatar altın kenarının kalınlığı.
  static const double avatarKenarKalinligi = 2;

  /// Avatar altın halesinin opaklığı.
  static const double avatarHaleOpakligi = 0.35;

  /// Kimlik kartındaki burç madalyonunun boyutu.
  static const double burcMadalyonBoyutu = 56;

  /// Büyük Üçlü kartındaki madalyonların boyutu.
  static const double ucluMadalyonBoyutu = 52;

  /// Büyük Üçlü kartında burç adının yanındaki küçük madalyon.
  static const double ucluBurcRozeti = 22;

  /// Sayı karolarındaki madalyon çerçevesinin boyutu.
  static const double sayiMadalyonBoyutu = 60;

  /// "Numeroloji raporu" satırındaki kitap görseli.
  static const double raporKitapIkonu = 44;

  /// Doğum haritası başlığındaki burç madalyonlarının boyutu.
  static const double haritaMadalyonBoyutu = 80;

  /// Harita başlığında burç madalyonuna bindirilen gezegen rozeti.
  static const double haritaGezegenRozeti = 32;

  /// Uzun okuma metinlerinin satır yüksekliği çarpanı.
  static const double metinSatirAraligi = 1.5;

  // ---- Numeroloji raporu zaman çizelgesi ----

  /// Dönemleri birbirine bağlayan dikey çizginin kalınlığı.
  static const double donemCizgiKalinligi = 2;

  /// Aktif olmayan dönemlerin saydamlığı.
  static const double pasifDonemOpakligi = 0.55;

  // ---- Kişisel Yıl Raporu ----

  /// Satıştaki yılın raporu, bir önceki yılın bu ayından itibaren ana
  /// ekranda tanıtılır (yılbaşı dönemi; ör. 2027 raporu Ekim 2026'dan).
  static const int yilRaporuTanitimAyi = 10;

  /// Yıl raporu başlığındaki kişisel yıl sayısının yazı boyutu.
  static const double kisiselYilSayiBoyutu = 56;

  /// Yıl raporu kartındaki açıklamanın en fazla satır sayısı.
  static const int yilKartiSatirSayisi = 3;

  /// Numeroloji raporu başlığındaki kitap görselinin yüksekliği.
  static const double raporKitapBuyuk = 140;

  /// Dönemler arasında atlanan ay evresi sayısı (8 evrede dört ana evre).
  static const int donemEvreAdimi = 2;

  /// Ay evresi görsellerinin sayısı.
  static const int ayEvresiSayisi = 8;

  /// Zaman çizelgesindeki ay evresi simgesinin boyutu.
  static const double donemAyBoyutu = 40;

  /// Akış/zorlu ay çipinin arka plan saydamlığı.
  static const double ayCipiOpakligi = 0.18;
}
