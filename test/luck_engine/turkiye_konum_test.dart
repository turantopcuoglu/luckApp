import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('TurkiyeIlleri', () {
    test('81 il, plaka sırasıyla, adlar benzersiz, koordinatlar Türkiye '
        'sınırları içinde', () {
      expect(TurkiyeIlleri.hepsi, hasLength(81));
      for (int i = 0; i < TurkiyeIlleri.hepsi.length; i++) {
        final Il il = TurkiyeIlleri.hepsi[i];
        expect(il.plaka, i + 1);
        expect(il.enlem, inInclusiveRange(35.8, 42.2), reason: il.ad);
        expect(il.boylam, inInclusiveRange(25.6, 44.9), reason: il.ad);
      }
      expect(TurkiyeIlleri.hepsi.map((Il il) => il.ad).toSet(), hasLength(81));
    });

    test('bilinen il merkezleri ve plaka araması', () {
      final Il ankara = TurkiyeIlleri.plakadan(6)!;
      expect(ankara.ad, 'Ankara');
      expect(ankara.enlem, closeTo(39.93, 0.1));
      expect(ankara.boylam, closeTo(32.86, 0.1));
      expect(TurkiyeIlleri.plakadan(34)!.ad, 'İstanbul');
      expect(TurkiyeIlleri.plakadan(0), isNull);
      expect(TurkiyeIlleri.plakadan(82), isNull);
    });

    test(
      'arama: Türkçe harf ve büyük-küçük harf duyarsız; başlayanlar önce',
      () {
        List<String> ad(String s) =>
            TurkiyeIlleri.ara(s).map((Il il) => il.ad).toList();
        expect(ad('istanbul'), <String>['İstanbul']);
        expect(ad('IZM'), <String>['İzmir']);
        expect(ad('çan'), <String>['Çanakkale', 'Çankırı', 'Erzincan']);
        expect(ad('can'), <String>['Çanakkale', 'Çankırı', 'Erzincan']);
        expect(ad('IĞDIR'), <String>['Iğdır']);
        // "ur" ile başlayan yok; içerenler plaka sırasında.
        expect(ad('urfa'), <String>['Şanlıurfa']);
        expect(TurkiyeIlleri.ara('  '), hasLength(81));
        expect(TurkiyeIlleri.ara('xyz'), isEmpty);
      },
    );
  });

  group('TurkiyeSaatDilimi', () {
    SaatDilimiSonucu f(int y, int a, int g, [int s = 12, int d = 0]) =>
        TurkiyeSaatDilimi.utcFarki(DateTime(y, a, g, s, d));

    test('2016 sonrası kalıcı UTC+3', () {
      expect(f(2020, 1, 15).farkSaat, 3);
      expect(f(2020, 6, 1).kesin, isTrue);
      expect(f(2016, 12, 1).farkSaat, 3);
      expect(f(2016, 1, 15).farkSaat, 2);
      // 27 Mart 2016 01:00 UTC'de yaz saati başladı ve bitmedi.
      expect(f(2016, 3, 27, 5).farkSaat, 3);
    });

    test('AB kuralı yılları ve geçiş gecesi belirsizliği', () {
      expect(f(2010, 7, 1).farkSaat, 3);
      expect(f(2010, 12, 1).farkSaat, 2);
      // 28 Mart 2010 01:00 UTC = 03:00 yerel; 02:30 henüz standart ama
      // geçişe yarım saat kala: kesin değil.
      final SaatDilimiSonucu ilkbahar = f(2010, 3, 28, 2, 30);
      expect(ilkbahar.farkSaat, 2);
      expect(ilkbahar.kesin, isFalse);
      // 31 Ekim 2010 03:30 yerel tekrarlanan saat: kesin değil.
      expect(f(2010, 10, 31, 3, 30).kesin, isFalse);
      expect(f(2010, 10, 31, 12).farkSaat, 2);
      expect(f(2010, 10, 31, 12).kesin, isTrue);
    });

    test('istisnalar: 2011 ve 2014 geç başlangıç, 2015 geç bitiş', () {
      expect(f(2011, 3, 27).farkSaat, 2);
      expect(f(2011, 3, 28).farkSaat, 3);
      expect(f(2014, 3, 30).farkSaat, 2);
      expect(f(2014, 3, 31).farkSaat, 3);
      expect(f(2015, 10, 30).farkSaat, 3);
      expect(f(2015, 11, 7).farkSaat, 3);
      expect(f(2015, 11, 10).farkSaat, 2);
    });

    test('1986–2006 Türkiye kuralı: Eylül/Ekim bitişi ve 1994 istisnası', () {
      expect(f(1990, 9, 29).farkSaat, 3);
      expect(f(1990, 10, 1).farkSaat, 2);
      expect(f(1994, 3, 19).farkSaat, 2);
      expect(f(1994, 3, 21).farkSaat, 3);
      expect(f(2000, 10, 1).farkSaat, 3);
      expect(f(2000, 11, 1).farkSaat, 2);
      expect(f(1995, 9, 30).farkSaat, 2);
      expect(f(1996, 9, 30).farkSaat, 3);
      expect(f(1999, 1, 10).kesin, isTrue);
    });

    test('1978–1985 (IANA): UTC+3 standart, yalnızca 1983 yazı UTC+4; '
        '1985 yeniden UTC+2', () {
      final SaatDilimiSonucu yaz80 = f(1980, 7, 1);
      expect(yaz80.farkSaat, 3);
      expect(yaz80.kesin, isTrue);
      expect(f(1982, 1, 10).farkSaat, 3);
      expect(f(1983, 7, 30).farkSaat, 3);
      expect(f(1983, 8, 15).farkSaat, 4);
      expect(f(1983, 10, 3).farkSaat, 3);
      expect(f(1984, 12, 1).farkSaat, 2);
      expect(f(1985, 1, 10).farkSaat, 2);
      expect(f(1985, 1, 10).kesin, isTrue);
      expect(f(1985, 7, 1).farkSaat, 3);
      expect(f(1985, 10, 1).farkSaat, 2);
    });

    test('1978 öncesi (IANA): düzensiz yaz saatleri, kesin değil', () {
      expect(f(1975, 1, 10).farkSaat, 2);
      expect(f(1975, 1, 10).kesin, isFalse);
      expect(f(1975, 7, 10).farkSaat, 3);
      // 1973 bitişi "Ekim'in 31'i ya da sonraki pazar" = 4 Kasım 1973.
      expect(f(1973, 11, 1).farkSaat, 3);
      expect(f(1973, 11, 5).farkSaat, 2);
      // Savaş yıllarında kış dahil kesintisiz yaz saati.
      expect(f(1944, 1, 15).farkSaat, 3);
      expect(f(1968, 7, 1).farkSaat, 2);
      expect(f(1963, 1, 1).farkSaat, 3);
      // 1977: Nisan'ın ilk pazarı (3 Nisan) başlangıç.
      expect(f(1977, 4, 2).farkSaat, 2);
      expect(f(1977, 4, 4).farkSaat, 3);
    });

    test('her gün için fark 2 ya da 3 (1986–2030)', () {
      for (
        DateTime g = DateTime(1986, 1, 1);
        g.isBefore(DateTime(2031, 1, 1));
        g = g.add(const Duration(days: 3))
      ) {
        expect(
          TurkiyeSaatDilimi.utcFarki(g).farkSaat,
          anyOf(2, 3),
          reason: '$g',
        );
      }
    });
  });

  test('doğum haritası: il ve saat diliminden Yükselen', () {
    final Il istanbul = TurkiyeIlleri.plakadan(34)!;
    final DateTime dogum = DateTime(1994, 3, 14, 8, 30);
    final SaatDilimiSonucu dilim = TurkiyeSaatDilimi.utcFarki(dogum);
    expect(dilim.farkSaat, 2);
    final DogumHaritasi h = DogumHaritasi.hesapla(
      yerelDogum: dogum,
      utcFarkiSaat: dilim.farkSaat.toDouble(),
      saatBiliniyor: true,
      enlem: istanbul.enlem,
      boylam: istanbul.boylam,
    );
    expect(h.gunesBurcu, Burc.balik);
    expect(h.yukselen, isNotNull);
  });
}
