import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Referans değerler Jean Meeus, "Astronomical Algorithms" (2. baskı)
/// çözümlü örneklerinden alınmıştır.
void main() {
  const double rad = math.pi / 180;

  group('Jülyen günü (Meeus bölüm 7)', () {
    test('J2000.0 ve kitap örnekleri', () {
      expect(
        Astronomi.julyenGunu(DateTime.utc(2000, 1, 1, 12)),
        closeTo(2451545.0, 1e-9),
      );
      // Örnek 7.a: 1957 Ekim 4.81 → 2436116.31.
      expect(
        Astronomi.julyenGunu(DateTime.utc(1957, 10, 4, 19, 26, 24)),
        closeTo(2436116.31, 1e-6),
      );
      // 1987 Haziran 19.5 → 2446966.0.
      expect(
        Astronomi.julyenGunu(DateTime.utc(1987, 6, 19, 12)),
        closeTo(2446966.0, 1e-9),
      );
    });
  });

  group('Güneş ve Ay boylamı', () {
    test('Ay, örnek 47.a: 1992-04-12 0h → λ = 133.162655°', () {
      expect(Astronomi.ayBoylami(2448724.5), closeTo(133.162655, 0.0005));
    });

    test('Güneş, örnek 25.a: 1992-10-13 0h → görünür λ = 199.90895°', () {
      expect(Astronomi.gunesBoylami(2448908.5), closeTo(199.90895, 0.001));
    });

    test('Ay günde ~13° ilerler (11.5° – 15.5° aralığında)', () {
      for (int i = 0; i < 400; i++) {
        final double jd = 2451545.0 + i * 9.3;
        final double fark = Astronomi.normalize(
          Astronomi.ayBoylami(jd + 1) - Astronomi.ayBoylami(jd),
        );
        expect(fark, inInclusiveRange(11.5, 15.5), reason: 'jd $jd');
      }
    });
  });

  group('Yıldız zamanı ve eğiklik', () {
    test('örnek 12.a/12.b: 1987-04-10 0h ve 19:21 UT', () {
      expect(
        Astronomi.greenwichYildizZamani(2446895.5),
        closeTo(197.693195, 1e-4),
      );
      expect(
        Astronomi.greenwichYildizZamani(
          Astronomi.julyenGunu(DateTime.utc(1987, 4, 10, 19, 21)),
        ),
        closeTo(128.7378734, 1e-4),
      );
    });

    test('örnek 22.a: 1987-04-10 ortalama eğiklik 23°26′27.407″', () {
      expect(Astronomi.egiklik(2446895.5), closeTo(23.440946, 1e-5));
    });
  });

  group('Yükselen', () {
    // 1987-04-10 0h UT'de Greenwich yıldız zamanı 197.693195°.
    const double jd = 2446895.5;
    const double gst = 197.693195;

    test('ekvatorda: yıldız zamanı 0° → Yengeç başı, 90° → Terazi başı', () {
      expect(Astronomi.yukselenBoylami(jd, 0, -gst), closeTo(90, 1e-3));
      expect(Astronomi.yukselenBoylami(jd, 0, 90 - gst), closeTo(180, 1e-3));
    });

    test('hesaplanan nokta doğu ufkundadır (yükseklik 0, doğu yarıküre)', () {
      final double eps = Astronomi.egiklik(jd);
      for (int i = 0; i < 300; i++) {
        final double enlem = -60 + (i * 37) % 121;
        final double boylam = -180 + (i * 53) % 360;
        final double asc = Astronomi.yukselenBoylami(jd, enlem, boylam);
        // Ekliptik (λ, β=0) → ekvatoral (α, δ).
        final double alfa =
            math.atan2(
              math.sin(asc * rad) * math.cos(eps * rad),
              math.cos(asc * rad),
            ) /
            rad;
        final double delta =
            math.asin(math.sin(eps * rad) * math.sin(asc * rad)) / rad;
        final double saatAcisi = Astronomi.normalize(gst + boylam - alfa);
        final double yukseklik =
            math.asin(
              math.sin(enlem * rad) * math.sin(delta * rad) +
                  math.cos(enlem * rad) *
                      math.cos(delta * rad) *
                      math.cos(saatAcisi * rad),
            ) /
            rad;
        expect(yukseklik, closeTo(0, 1e-6), reason: '$enlem $boylam');
        // Doğuda: saat açısı 180°-360° (sin H < 0).
        expect(math.sin(saatAcisi * rad), lessThan(0), reason: '$enlem');
      }
    });

    test('bir günde 12 burcun hepsinden geçer', () {
      final Set<Burc> gorulen = <Burc>{
        for (int dakika = 0; dakika < 24 * 60; dakika += 10)
          Astronomi.burc(
            Astronomi.yukselenBoylami(jd + dakika / 1440, 41.0, 29.0),
          ),
      };
      expect(gorulen, hasLength(12));
    });
  });

  group('burç eşlemesi', () {
    test('boylam → burç ve sınır uzaklığı', () {
      expect(Astronomi.burc(0), Burc.koc);
      expect(Astronomi.burc(29.999), Burc.koc);
      expect(Astronomi.burc(30), Burc.boga);
      expect(Astronomi.burc(359.9), Burc.balik);
      expect(Astronomi.burc(-1), Burc.balik);
      expect(Astronomi.sinirUzakligi(31), closeTo(1, 1e-9));
      expect(Astronomi.sinirUzakligi(58), closeTo(2, 1e-9));
    });
  });

  group('DogumHaritasi', () {
    test('Güneş burcu, tarih tablosuyla sınır günleri dışında aynıdır', () {
      for (int i = 0; i < 600; i++) {
        final DateTime gun = DateTime(1950, 1, 1).add(Duration(days: i * 37));
        if (Burc.sinirGunuMu(gun)) {
          continue;
        }
        final DogumHaritasi h = DogumHaritasi.hesapla(
          yerelDogum: DateTime(gun.year, gun.month, gun.day, 12),
          utcFarkiSaat: 3,
          saatBiliniyor: true,
        );
        expect(h.gunesBurcu, Burc.dogumTarihinden(gun), reason: '$gun');
      }
    });

    test('saat bilinmiyorsa Yükselen yok; Ay o gün burç değiştirdiyse '
        'kesin değil', () {
      int kesinOlmayan = 0;
      for (int i = 0; i < 365; i++) {
        final DateTime gun = DateTime(2026, 1, 1).add(Duration(days: i));
        final DogumHaritasi h = DogumHaritasi.hesapla(
          yerelDogum: gun,
          utcFarkiSaat: 3,
          saatBiliniyor: false,
          enlem: 41,
          boylam: 29,
        );
        expect(h.yukselen, isNull);
        expect(h.yukselenSinirda, isFalse);
        if (!h.ayBurcuKesin) {
          kesinOlmayan++;
        }
      }
      // Ay ~2.5 günde bir burç değiştirir: yılda ~145 geçiş günü.
      expect(kesinOlmayan, inInclusiveRange(130, 160));
    });

    test('saat ve konum biliniyorsa Yükselen hesaplanır; konum yoksa yok', () {
      final DogumHaritasi tam = DogumHaritasi.hesapla(
        yerelDogum: DateTime(1994, 3, 14, 8, 30),
        utcFarkiSaat: 2,
        saatBiliniyor: true,
        enlem: 41.0082,
        boylam: 28.9784,
      );
      expect(tam.yukselen, isNotNull);
      expect(tam.gunesBurcu, Burc.balik);
      final DogumHaritasi konumsuz = DogumHaritasi.hesapla(
        yerelDogum: DateTime(1994, 3, 14, 8, 30),
        utcFarkiSaat: 2,
        saatBiliniyor: true,
      );
      expect(konumsuz.yukselen, isNull);
      expect(konumsuz.ayBurcu, tam.ayBurcu);
    });

    test('UTC farkı doğru uygulanır: aynı an, farklı yerel saat', () {
      final DogumHaritasi istanbul = DogumHaritasi.hesapla(
        yerelDogum: DateTime(2000, 6, 1, 15),
        utcFarkiSaat: 3,
        saatBiliniyor: true,
        enlem: 41,
        boylam: 29,
      );
      final DogumHaritasi utc = DogumHaritasi.hesapla(
        yerelDogum: DateTime(2000, 6, 1, 12),
        utcFarkiSaat: 0,
        saatBiliniyor: true,
        enlem: 41,
        boylam: 29,
      );
      expect(istanbul.ayBoylami, closeTo(utc.ayBoylami, 1e-9));
      expect(istanbul.yukselenBoylami, closeTo(utc.yukselenBoylami!, 1e-9));
    });
  });
}
