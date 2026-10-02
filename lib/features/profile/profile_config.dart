/// Kader Profili ekranına özgü ölçüler.
abstract final class ProfileConfig {
  /// "Nasıl hesaplandı?" satırlarında etiket sütununun genişliği.
  static const double adimEtiketGenisligi = 96;

  /// Kilitli bölüm metninin bulanıklık şiddeti.
  static const double kilitBulanikligi = 4;

  /// Kilitli bölümde bulanık gösterilen en fazla satır.
  static const int kilitliSatirSayisi = 3;

  /// Uzun okuma metinlerinin satır yüksekliği çarpanı.
  static const double metinSatirAraligi = 1.5;

  // ---- Numeroloji raporu zaman çizelgesi ----

  /// Dönem dairesinin çapı.
  static const double donemDairesiCapi = 40;

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

  /// Akış/zorlu ay çipinin arka plan saydamlığı.
  static const double ayCipiOpakligi = 0.18;
}
