import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('DogumYeri', () {
    test('Türkiye ili: koordinat ve saat dilimi il listesinden', () {
      final Il izmir = TurkiyeIlleri.plakadan(35)!;
      final DogumYeri yer = DogumYeri.il(izmir);
      expect(yer.ulkeKodu, 'TR');
      expect(yer.turkiyeMi, isTrue);
      expect(yer.ilPlaka, 35);
      expect(yer.sehirKimligi, isNull);
      expect(yer.ad, izmir.ad);
      expect(yer.enlem, izmir.enlem);
      expect(yer.boylam, izmir.boylam);
      expect(yer.saatDilimi, 'Europe/Istanbul');
    });

    test('Türkiye ilinde fark TurkiyeSaatDilimi ile aynı', () {
      final DogumYeri yer = DogumYeri.il(TurkiyeIlleri.plakadan(6)!);
      for (final DateTime d in <DateTime>[
        DateTime.utc(1965, 7, 1, 12),
        DateTime.utc(1994, 3, 14, 8, 30),
        DateTime.utc(2016, 12, 1, 12),
      ]) {
        expect(
          yer.saatDilimiSonucu(d).farkDakika,
          TurkiyeSaatDilimi.utcFarki(d).farkSaat * 60,
        );
      }
    });

    test('yabancı şehir: IANA farkı, Türkiye değil', () {
      const DogumYeri berlin = DogumYeri(
        ulkeKodu: 'DE',
        ad: 'Berlin',
        saatDilimi: 'Europe/Berlin',
        enlem: 52.52,
        boylam: 13.41,
        sehirKimligi: 2950159,
      );
      expect(berlin.turkiyeMi, isFalse);
      final DogumSaatDilimiSonucu yaz = berlin.saatDilimiSonucu(
        DateTime.utc(1990, 7, 1, 12),
      );
      expect(yaz.farkDakika, 120);
      expect(yaz.kesin, isTrue);
    });

    test('bilinmeyen kimlik: boylamdan yerel ortalama zaman, kesin değil', () {
      const DogumYeri yer = DogumYeri(
        ulkeKodu: 'XX',
        ad: 'Yok',
        saatDilimi: 'Mars/Olympus',
        enlem: 0,
        boylam: 30,
      );
      final DogumSaatDilimiSonucu r = yer.saatDilimiSonucu(DateTime.utc(2000));
      expect(r.farkDakika, 120);
      expect(r.kesin, isFalse);
      const DogumYeri bati = DogumYeri(
        ulkeKodu: 'XX',
        ad: 'Yok',
        saatDilimi: 'Mars/Olympus',
        enlem: 0,
        boylam: -73.99,
      );
      expect(bati.saatDilimiSonucu(DateTime.utc(2000)).farkDakika, -296);
    });
  });
}
