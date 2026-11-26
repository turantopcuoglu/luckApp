import 'engine_config.dart';

/// Bilinen bir yeniay anı (6 Ocak 2000 18:14 UTC) — evre hesabının
/// referans noktası. Paket kullanmadan basit astronomik hesap için yeterli.
final DateTime yeniayReferansi = DateTime.utc(2000, 1, 6, 18, 14);

/// [gun] takvim gününün (yıl, ay, gün alanları) yerel [saat]inin UTC anı.
///
/// [utcFarkiDakika]: kişinin o gündeki UTC farkı (Türkiye +180). Saat ve
/// saat dilimi [gun]den OKUNMAZ; makinenin saat dilimi sonucu etkilemez.
DateTime yerelGunAni(
  DateTime gun, {
  int saat = 0,
  int utcFarkiDakika = EngineConfig.varsayilanUtcFarkiDakika,
}) => DateTime.utc(
  gun.year,
  gun.month,
  gun.day,
  saat,
).subtract(Duration(minutes: utcFarkiDakika));

/// Ayın sekiz evresi.
///
/// Sinodik ay sekiz eşit dilime bölünür; her evre kendi merkezinin
/// ±1/16 çevresini kapsar (yeni ay dilimi 0 noktasının iki yanını).
enum AyEvresi {
  /// Yeni ay: ay görünmez; niyet ve başlangıç evresi.
  yeniAy(etiket: 'Yeni ay', buyuyor: true),

  /// Büyüyen hilal: ince ışık; filizlenme.
  buyuyenHilal(etiket: 'Büyüyen hilal', buyuyor: true),

  /// İlk dördün: yarım ay; harekete geçme.
  ilkDordun(etiket: 'İlk dördün', buyuyor: true),

  /// Büyüyen şişkin ay: olgunlaşma.
  buyuyenSiskin(etiket: 'Şişkin ay', buyuyor: true),

  /// Dolunay: zirve ve görünürlük.
  dolunay(etiket: 'Dolunay', buyuyor: false),

  /// Küçülen şişkin ay: paylaşma, şükran.
  kuculenSiskin(etiket: 'Küçülen şişkin ay', buyuyor: false),

  /// Son dördün: ayıklama, bırakma.
  sonDordun(etiket: 'Son dördün', buyuyor: false),

  /// Küçülen hilal: dinlenme, kapanış.
  kuculenHilal(etiket: 'Küçülen hilal', buyuyor: false);

  const AyEvresi({required this.etiket, required this.buyuyor});

  /// Kullanıcıya gösterilecek Türkçe ad.
  final String etiket;

  /// Ay ışığı artıyor mu? (yeni aydan dolunaya kadar true).
  final bool buyuyor;

  /// [gun] takviminin yerel gece yarısındaki ay evresi (günün evresi).
  ///
  /// Skor ([LuckEngine.hesapla]) ve "Neden bugün?" çipi aynı anı kullanır.
  static AyEvresi gunun(
    DateTime gun, {
    int utcFarkiDakika = EngineConfig.varsayilanUtcFarkiDakika,
  }) => bul(yerelGunAni(gun, utcFarkiDakika: utcFarkiDakika));

  /// [gun] anı için ay evresini döndürür.
  static AyEvresi bul(DateTime gun) {
    final double oran = ayEvresiOrani(gun);
    // Oran dilim merkezlerine göre kaydırılır: yeni ay dilimi
    // [-1/16, +1/16) aralığıdır, bu yüzden yarım dilim eklenip taban alınır.
    final int dilim =
        (oran * EngineConfig.ayEvresiSayisi + 0.5).floor() %
        EngineConfig.ayEvresiSayisi;
    return AyEvresi.values[dilim];
  }
}

/// [gun] için evre oranını döndürür: 0 = yeniay, 0.5 = dolunay, [0, 1).
///
/// Evre, referans yeniaydan geçen sürenin sinodik aya bölümünün kesir
/// kısmıdır. Ay evresi modifiyeri ve [AyEvresi.bul] aynı hesabı kullanır
/// ki "Neden bugün?" açıklaması skorla asla çelişmesin.
double ayEvresiOrani(DateTime gun) {
  // Dakika hassasiyeti evre için fazlasıyla yeterli.
  final double gecenGun =
      gun.toUtc().difference(yeniayReferansi).inMinutes /
      Duration.minutesPerHour /
      Duration.hoursPerDay;
  final double devir = gecenGun / EngineConfig.sinodikAyGun;
  // floor ile kesir alma, referans öncesi (negatif) tarihlerde de
  // 0..1 aralığında evre döndürür.
  return devir - devir.floorToDouble();
}
