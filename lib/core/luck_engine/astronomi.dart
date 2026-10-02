/// Doğum haritasının temel noktaları: Güneş, Ay ve Yükselen — saf Dart
/// (CLAUDE.md kural 3), paket kullanmadan.
///
/// Algoritmalar Jean Meeus, "Astronomical Algorithms" (2. baskı):
/// - Jülyen günü (bölüm 7), Güneş'in görünür boylamı (bölüm 25, düşük
///   hassasiyet, ~0.01°), Ay'ın boylamı (bölüm 47, Tablo 47.A'nın tüm
///   boylam terimleri, ~0.003°), ortalama yıldız zamanı (bölüm 12),
///   ekliptiğin eğikliği (bölüm 22).
/// - Yükselen: yerel yıldız zamanı ve enlemden standart formül.
///
/// Dinamik zaman ile evrensel zaman farkı (ΔT ≈ 1 dk) ihmal edilir: Ay'ı
/// en fazla ~0.0005° kaydırır, burç sınırı için önemsizdir. Burç sınırına
/// çok yakın sonuçlar [DogumHaritasi] içinde "sınırda" olarak işaretlenir.
library;

import 'dart:math' as math;

import 'burc.dart';
import 'engine_config.dart';

/// Ekliptik boylam sırasıyla burçlar (Koç 0°'den başlar).
const List<Burc> ekliptikBurclari = <Burc>[
  Burc.koc,
  Burc.boga,
  Burc.ikizler,
  Burc.yengec,
  Burc.aslan,
  Burc.basak,
  Burc.terazi,
  Burc.akrep,
  Burc.yay,
  Burc.oglak,
  Burc.kova,
  Burc.balik,
];

/// Astronomik hesap fonksiyonları (açılar derece, zaman Jülyen günü).
abstract final class Astronomi {
  static const double _dereceRadyan = math.pi / 180;

  /// J2000.0 başlangıcının Jülyen günü.
  static const double j2000 = 2451545.0;

  /// Bir Jülyen yüzyılındaki gün sayısı.
  static const double yuzyilGun = 36525.0;

  /// [utc] anının Jülyen günü (Gregoryen takvim; Meeus bölüm 7).
  static double julyenGunu(DateTime utc) {
    final DateTime t = utc.toUtc();
    int yil = t.year;
    int ay = t.month;
    if (ay <= 2) {
      yil -= 1;
      ay += 12;
    }
    final int a = yil ~/ 100;
    final int b = 2 - a + a ~/ 4;
    final double gunKesri =
        t.day +
        (t.hour + (t.minute + (t.second + t.millisecond / 1000) / 60) / 60) /
            24;
    return (365.25 * (yil + 4716)).floor() +
        (30.6001 * (ay + 1)).floor() +
        gunKesri +
        b -
        1524.5;
  }

  /// J2000.0'dan bu yana geçen Jülyen yüzyılı.
  static double yuzyil(double jd) => (jd - j2000) / yuzyilGun;

  /// Açıyı 0-360 aralığına indirger.
  static double normalize(double derece) {
    final double d = derece % 360;
    return d < 0 ? d + 360 : d;
  }

  static double _sin(double derece) => math.sin(derece * _dereceRadyan);

  static double _cos(double derece) => math.cos(derece * _dereceRadyan);

  /// Güneş'in görünür ekliptik boylamı (Meeus bölüm 25, düşük hassasiyet).
  static double gunesBoylami(double jd) {
    final double t = yuzyil(jd);
    final double l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
    final double m = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
    final double c =
        (1.914602 - 0.004817 * t - 0.000014 * t * t) * _sin(m) +
        (0.019993 - 0.000101 * t) * _sin(2 * m) +
        0.000289 * _sin(3 * m);
    final double omega = 125.04 - 1934.136 * t;
    // Gerçek boylam + sapınç (aberasyon) ve nütasyon düzeltmesi.
    return normalize(l0 + c - 0.00569 - 0.00478 * _sin(omega));
  }

  /// Ay'ın geometrik ekliptik boylamı (Meeus bölüm 47, nütasyonsuz).
  static double ayBoylami(double jd) {
    final double t = yuzyil(jd);
    final double t2 = t * t;
    final double t3 = t2 * t;
    final double t4 = t3 * t;
    final double lp =
        218.3164477 +
        481267.88123421 * t -
        0.0015786 * t2 +
        t3 / 538841 -
        t4 / 65194000;
    final double d =
        297.8501921 +
        445267.1114034 * t -
        0.0018819 * t2 +
        t3 / 545868 -
        t4 / 113065000;
    final double m =
        357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000;
    final double mp =
        134.9633964 +
        477198.8675055 * t +
        0.0087414 * t2 +
        t3 / 69699 -
        t4 / 14712000;
    final double f =
        93.2720950 +
        483202.0175233 * t -
        0.0036539 * t2 -
        t3 / 3526000 +
        t4 / 863310000;
    final double a1 = 119.75 + 131.849 * t;
    final double a2 = 53.09 + 479264.290 * t;
    // Dünya yörüngesinin dış merkezliliğine bağlı genlik düzeltmesi.
    final double e = 1 - 0.002516 * t - 0.0000074 * t2;

    double toplam = 0;
    for (final List<int> terim in _ayBoylamTerimleri) {
      final int mKatsayi = terim[1];
      final double genlikDuzeltmesi = switch (mKatsayi.abs()) {
        1 => e,
        2 => e * e,
        _ => 1,
      };
      toplam +=
          terim[4] *
          genlikDuzeltmesi *
          _sin(terim[0] * d + mKatsayi * m + terim[2] * mp + terim[3] * f);
    }
    // Venüs, Jüpiter ve Dünya'nın basıklığından gelen ek terimler.
    toplam += 3958 * _sin(a1) + 1962 * _sin(lp - f) + 318 * _sin(a2);
    return normalize(lp + toplam / 1000000);
  }

  /// Greenwich ortalama yıldız zamanı, derece (Meeus denklem 12.4).
  static double greenwichYildizZamani(double jd) {
    final double t = yuzyil(jd);
    return normalize(
      280.46061837 +
          360.98564736629 * (jd - j2000) +
          0.000387933 * t * t -
          t * t * t / 38710000,
    );
  }

  /// Ekliptiğin ortalama eğikliği, derece (Meeus denklem 22.2, kısaltılmış).
  static double egiklik(double jd) {
    final double t = yuzyil(jd);
    return 23.4392911 - 0.0130042 * t - 0.00000016 * t * t;
  }

  /// [enlem] ve [boylam] (doğu pozitif) konumunda Yükselen'in ekliptik
  /// boylamı.
  ///
  /// Yerel yıldız zamanı θ ve eğiklik ε ile:
  /// ASC = atan2(cos θ, −(sin θ · cos ε + tan φ · sin ε)).
  static double yukselenBoylami(double jd, double enlem, double boylam) {
    final double teta = normalize(greenwichYildizZamani(jd) + boylam);
    final double eps = egiklik(jd);
    final double y = _cos(teta);
    final double x =
        -(_sin(teta) * _cos(eps) + math.tan(enlem * _dereceRadyan) * _sin(eps));
    return normalize(math.atan2(y, x) / _dereceRadyan);
  }

  /// Ekliptik [boylam]ın burcu.
  static Burc burc(double boylam) =>
      ekliptikBurclari[normalize(boylam) ~/ EngineConfig.burcGenisligi];

  /// [boylam]ın en yakın burç sınırına uzaklığı (derece, 0-15).
  static double sinirUzakligi(double boylam) {
    final double burcIci = normalize(boylam) % EngineConfig.burcGenisligi;
    return math.min(burcIci, EngineConfig.burcGenisligi - burcIci);
  }

  /// Ay boylamı serisinin terimleri: D, M, M', F katsayıları ve genlik
  /// (10⁻⁶ derece). Meeus Tablo 47.A, boylam sütununun sıfır olmayan
  /// tüm terimleri.
  static const List<List<int>> _ayBoylamTerimleri = <List<int>>[
    <int>[0, 0, 1, 0, 6288774],
    <int>[2, 0, -1, 0, 1274027],
    <int>[2, 0, 0, 0, 658314],
    <int>[0, 0, 2, 0, 213618],
    <int>[0, 1, 0, 0, -185116],
    <int>[0, 0, 0, 2, -114332],
    <int>[2, 0, -2, 0, 58793],
    <int>[2, -1, -1, 0, 57066],
    <int>[2, 0, 1, 0, 53322],
    <int>[2, -1, 0, 0, 45758],
    <int>[0, 1, -1, 0, -40923],
    <int>[1, 0, 0, 0, -34720],
    <int>[0, 1, 1, 0, -30383],
    <int>[2, 0, 0, -2, 15327],
    <int>[0, 0, 1, 2, -12528],
    <int>[0, 0, 1, -2, 10980],
    <int>[4, 0, -1, 0, 10675],
    <int>[0, 0, 3, 0, 10034],
    <int>[4, 0, -2, 0, 8548],
    <int>[2, 1, -1, 0, -7888],
    <int>[2, 1, 0, 0, -6766],
    <int>[1, 0, -1, 0, -5163],
    <int>[1, 1, 0, 0, 4987],
    <int>[2, -1, 1, 0, 4036],
    <int>[2, 0, 2, 0, 3994],
    <int>[4, 0, 0, 0, 3861],
    <int>[2, 0, -3, 0, 3665],
    <int>[0, 1, -2, 0, -2689],
    <int>[2, 0, -1, 2, -2602],
    <int>[2, -1, -2, 0, 2390],
    <int>[1, 0, 1, 0, -2348],
    <int>[2, -2, 0, 0, 2236],
    <int>[0, 1, 2, 0, -2120],
    <int>[0, 2, 0, 0, -2069],
    <int>[2, -2, -1, 0, 2048],
    <int>[2, 0, 1, -2, -1773],
    <int>[2, 0, 0, 2, -1595],
    <int>[4, -1, -1, 0, 1215],
    <int>[0, 0, 2, 2, -1110],
    <int>[3, 0, -1, 0, -892],
    <int>[2, 1, 1, 0, -810],
    <int>[4, -1, -2, 0, 759],
    <int>[0, 2, -1, 0, -713],
    <int>[2, 2, -1, 0, -700],
    <int>[2, 1, -2, 0, 691],
    <int>[2, -1, 0, -2, 596],
    <int>[4, 0, 1, 0, 549],
    <int>[0, 0, 4, 0, 537],
    <int>[4, -1, 0, 0, 520],
    <int>[1, 0, -2, 0, -487],
    <int>[2, 1, 0, -2, -399],
    <int>[0, 0, 2, -2, -381],
    <int>[1, 1, 1, 0, 351],
    <int>[3, 0, -2, 0, -340],
    <int>[4, 0, -3, 0, 330],
    <int>[2, -1, 2, 0, 327],
    <int>[0, 2, 1, 0, -323],
    <int>[1, 1, -1, 0, 299],
    <int>[2, 0, 3, 0, 294],
  ];
}

/// Bir doğum anının harita noktaları: Güneş, Ay ve (konum ve saat
/// biliniyorsa) Yükselen.
class DogumHaritasi {
  /// Tüm alanlarıyla harita oluşturur (genelde [hesapla] kullanılır).
  const DogumHaritasi({
    required this.gunesBoylami,
    required this.ayBoylami,
    required this.ayBurcu,
    required this.ayBurcuKesin,
    required this.yukselenBoylami,
  });

  /// [yerelDogum] (yerel saat, saat bilinmiyorsa günün herhangi bir anı)
  /// ve [utcFarkiSaat] (ör. Türkiye 2016 sonrası +3) ile harita hesaplar.
  ///
  /// [saatBiliniyor] false ise: Ay burcu öğlen için hesaplanır; Ay o gün
  /// burç değiştiriyorsa [ayBurcuKesin] false olur. Yükselen ancak saat
  /// biliniyorsa ve [enlem]/[boylam] verilmişse hesaplanır.
  factory DogumHaritasi.hesapla({
    required DateTime yerelDogum,
    required double utcFarkiSaat,
    required bool saatBiliniyor,
    double? enlem,
    double? boylam,
  }) {
    DateTime utc(int saat, int dakika) =>
        DateTime.utc(
          yerelDogum.year,
          yerelDogum.month,
          yerelDogum.day,
          saat,
          dakika,
        ).subtract(
          Duration(minutes: (utcFarkiSaat * Duration.minutesPerHour).round()),
        );

    final DateTime an = saatBiliniyor
        ? utc(yerelDogum.hour, yerelDogum.minute)
        : utc(EngineConfig.bilinmeyenSaat, 0);
    final double jd = Astronomi.julyenGunu(an);
    final double ay = Astronomi.ayBoylami(jd);

    bool ayKesin;
    if (saatBiliniyor) {
      ayKesin = Astronomi.sinirUzakligi(ay) >= EngineConfig.aySinirToleransi;
    } else {
      // Gün boyunca (00:00 – 23:59) Ay aynı burçta kaldıysa kesin.
      final Burc sabah = Astronomi.burc(
        Astronomi.ayBoylami(Astronomi.julyenGunu(utc(0, 0))),
      );
      final Burc gece = Astronomi.burc(
        Astronomi.ayBoylami(
          Astronomi.julyenGunu(
            utc(Duration.hoursPerDay - 1, Duration.minutesPerHour - 1),
          ),
        ),
      );
      ayKesin = sabah == gece;
    }

    return DogumHaritasi(
      gunesBoylami: Astronomi.gunesBoylami(jd),
      ayBoylami: ay,
      ayBurcu: Astronomi.burc(ay),
      ayBurcuKesin: ayKesin,
      yukselenBoylami: saatBiliniyor && enlem != null && boylam != null
          ? Astronomi.yukselenBoylami(jd, enlem, boylam)
          : null,
    );
  }

  /// Güneş'in ekliptik boylamı (derece).
  final double gunesBoylami;

  /// Ay'ın ekliptik boylamı (derece).
  final double ayBoylami;

  /// Ay burcu (saat bilinmiyorsa öğlen için).
  final Burc ayBurcu;

  /// Ay burcu kesin mi? (saat biliniyorsa sınırdan yeterince uzak; saat
  /// bilinmiyorsa Ay o gün burç değiştirmemiş).
  final bool ayBurcuKesin;

  /// Yükselen'in ekliptik boylamı; saat ya da konum yoksa null.
  final double? yukselenBoylami;

  /// Güneş burcu (gökyüzündeki gerçek konuma göre).
  Burc get gunesBurcu => Astronomi.burc(gunesBoylami);

  /// Yükselen burç; saat ya da konum yoksa null.
  Burc? get yukselen =>
      yukselenBoylami == null ? null : Astronomi.burc(yukselenBoylami!);

  /// Yükselen sınıra çok yakın mı? (birkaç dakikalık saat hatası burcu
  /// değiştirebilir). Yükselen yoksa false.
  bool get yukselenSinirda =>
      yukselenBoylami != null &&
      Astronomi.sinirUzakligi(yukselenBoylami!) <
          EngineConfig.yukselenSinirToleransi;
}
