import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:timezone/timezone.dart' as tz;

/// K8-2: dünya geneli doğum saat dilimi.
///
/// Beklenen farklar IANA tz veritabanının kayıtlarıdır (tzdata
/// `northamerica`, `europe`, `asia`, `australasia` dosyaları).
void main() {
  DogumSaatDilimiSonucu coz(
    String kimlik,
    int y,
    int a,
    int g, [
    int s = 12,
    int d = 0,
  ]) =>
      // Duvar saati UTC kurucusuyla taşınır: yerel kurucu, makinenin kendi
      // diliminde atlanan saati kaydırırdı (bkz. DogumSaatDilimi.cozumle).
      DogumSaatDilimi.cozumle(
        ianaKimligi: kimlik,
        yerel: DateTime.utc(y, a, g, s, d),
      )!;

  group('IANA farkları', () {
    test('New York: 1985 yazı EDT −4, kışı EST −5', () {
      final DogumSaatDilimiSonucu yaz = coz('America/New_York', 1985, 7, 4);
      expect(yaz.farkDakika, -240);
      expect(yaz.farkSaat, -4);
      expect(yaz.kesin, isTrue);
      expect(yaz.durum, YerelSaatDurumu.normal);
      expect(coz('America/New_York', 1985, 1, 15).farkDakika, -300);
    });

    test('Londra: BST +1, kış 0; 1968–71 deneyinde kışın da +1', () {
      expect(coz('Europe/London', 1985, 7, 1).farkDakika, 60);
      expect(coz('Europe/London', 1975, 1, 15).farkDakika, 0);
      // British Standard Time: 27 Ekim 1968 – 31 Ekim 1971, yıl boyu +1.
      expect(coz('Europe/London', 1969, 12, 15).farkDakika, 60);
      expect(coz('Europe/London', 1970, 2, 1).farkDakika, 60);
      // 1970 öncesi Türkiye dışında kesin değil.
      expect(coz('Europe/London', 1969, 12, 15).kesin, isFalse);
      expect(coz('Europe/London', 1970, 2, 1).kesin, isTrue);
    });

    test('Tokyo +9, yaz saati yok; 1948–51 yaz saati +10 ve kesin değil', () {
      expect(coz('Asia/Tokyo', 1990, 5, 1).farkDakika, 540);
      expect(coz('Asia/Tokyo', 1990, 12, 1).farkDakika, 540);
      final DogumSaatDilimiSonucu eski = coz('Asia/Tokyo', 1950, 7, 1);
      expect(eski.farkDakika, 600);
      expect(eski.kesin, isFalse);
    });

    test('yarım ve çeyrek saatlik farklar: Hindistan +5:30, Nepal +5:45, '
        'Adelaide yazı +10:30', () {
      expect(coz('Asia/Kolkata', 1990, 6, 1).farkDakika, 330);
      expect(coz('Asia/Kolkata', 1990, 6, 1).farkSaat, 5.5);
      expect(coz('Asia/Kathmandu', 1990, 6, 1).farkDakika, 345);
      // Güney yarım kürede ocak yazdır.
      expect(coz('Australia/Adelaide', 1990, 1, 15).farkDakika, 630);
      expect(coz('Australia/Adelaide', 1990, 7, 15).farkDakika, 570);
    });

    test('bilinmeyen kimlik null', () {
      expect(
        DogumSaatDilimi.cozumle(
          ianaKimligi: 'Mars/Olympus',
          yerel: DateTime(1990),
        ),
        isNull,
      );
      expect(DogumSaatDilimi.tanimliMi('Mars/Olympus'), isFalse);
      expect(DogumSaatDilimi.tanimliMi('Europe/Berlin'), isTrue);
    });
  });

  group('yaz saati geçiş gecesi', () {
    test('atlanan saat: New York 14 Mart 2021 02:30 hiç yaşanmadı; geçiş '
        'öncesi farkla (−5) yorumlanır, kesin değil', () {
      final DogumSaatDilimiSonucu r = coz(
        'America/New_York',
        2021,
        3,
        14,
        2,
        30,
      );
      expect(r.durum, YerelSaatDurumu.atlanan);
      expect(r.farkDakika, -300);
      expect(r.kesin, isFalse);
      // Bir saat önce ve sonra normal.
      expect(
        coz('America/New_York', 2021, 3, 14, 1, 30).durum,
        YerelSaatDurumu.normal,
      );
      expect(coz('America/New_York', 2021, 3, 14, 3, 30).farkDakika, -240);
    });

    test('iki kez yaşanan saat: New York 7 Kasım 2021 01:30; ilk yaşanış '
        '(EDT −4), kesin değil', () {
      final DogumSaatDilimiSonucu r = coz(
        'America/New_York',
        2021,
        11,
        7,
        1,
        30,
      );
      expect(r.durum, YerelSaatDurumu.tekrarlanan);
      expect(r.farkDakika, -240);
      expect(r.kesin, isFalse);
      expect(coz('America/New_York', 2021, 11, 7, 2, 30).farkDakika, -300);
    });

    test('güney yarım küre: Sidney 3 Ekim 2021 02:30 atlanır', () {
      final DogumSaatDilimiSonucu r = coz(
        'Australia/Sydney',
        2021,
        10,
        3,
        2,
        30,
      );
      expect(r.durum, YerelSaatDurumu.atlanan);
      expect(r.farkDakika, 600);
    });

    test('Türkiye: 2010 ilkbahar geçişinde 03:30 atlanır, kesin değil', () {
      // 28 Mart 2010: 03:00 → 04:00 (01:00 UTC).
      final DogumSaatDilimiSonucu r = coz(
        'Europe/Istanbul',
        2010,
        3,
        28,
        3,
        30,
      );
      expect(r.durum, YerelSaatDurumu.atlanan);
      expect(r.kesin, isFalse);
    });
  });

  group('Türkiye önceliği', () {
    test('Europe/Istanbul farkı TurkiyeSaatDilimi ile birebir aynı', () {
      for (
        DateTime d = DateTime(1940, 1, 1, 12);
        d.year <= 2030;
        d = DateTime(d.year, d.month, d.day + 11, 12)
      ) {
        final SaatDilimiSonucu tr = TurkiyeSaatDilimi.utcFarki(d);
        final DogumSaatDilimiSonucu r = DogumSaatDilimi.cozumle(
          ianaKimligi: 'Europe/Istanbul',
          yerel: d,
        )!;
        expect(r.farkDakika, tr.farkSaat * 60, reason: '$d');
        if (!tr.kesin) {
          expect(r.kesin, isFalse, reason: '$d');
        }
      }
    });

    test('Türkiye modülü IANA Europe/Istanbul kaydıyla aynı kuralları '
        'taşır (1940–2030, her 11 günde öğlen)', () {
      expect(DogumSaatDilimi.tanimliMi('Europe/Istanbul'), isTrue);
      final tz.Location ist = tz.getLocation('Europe/Istanbul');
      final List<String> farklar = <String>[];
      for (
        DateTime d = DateTime(1940, 1, 1, 12);
        d.year <= 2030;
        d = DateTime(d.year, d.month, d.day + 11, 12)
      ) {
        final int duvar = DateTime.utc(
          d.year,
          d.month,
          d.day,
          12,
        ).millisecondsSinceEpoch;
        // Öğlen geçiş saati değildir: farkı doğrudan oku.
        final int fark = ist.timeZone(duvar - 3 * 3600000).offset ~/ 60000;
        final int ianaFark = ist.timeZone(duvar - fark * 60000).offset ~/ 60000;
        final int tr = TurkiyeSaatDilimi.utcFarki(d).farkSaat * 60;
        if (ianaFark != tr) {
          farklar.add(
            '${d.toIso8601String().substring(0, 10)}: IANA $ianaFark, TR $tr',
          );
        }
      }
      expect(farklar, isEmpty);
    });
  });

  group('yabancı doğumda Yükselen (Astro-Databank, AA)', () {
    // Kaynak: astro.com/astro-databank, sayfalar 27 Kasım 2026'da okundu.
    // Yer koordinatları ve Yükselen ADB veri kutusundandır; fark ADB'nin
    // kendi saat dilimi etiketiyle karşılaştırılır.
    void yukselen({
      required String ad,
      required String kimlik,
      required DateTime duvar,
      required int adbFarkDakika,
      required double enlem,
      required double boylam,
      required Burc burc,
      required double adbBoylam,
    }) {
      final DogumSaatDilimiSonucu dilim = DogumSaatDilimi.cozumle(
        ianaKimligi: kimlik,
        yerel: duvar,
      )!;
      expect(dilim.farkDakika, adbFarkDakika, reason: '$ad: saat dilimi');
      final DogumHaritasi h = DogumHaritasi.hesapla(
        yerelDogum: duvar,
        utcFarkiSaat: dilim.farkSaat,
        saatBiliniyor: true,
        enlem: enlem,
        boylam: boylam,
      );
      expect(h.yukselen, burc, reason: ad);
      expect(h.yukselenBoylami, closeTo(adbBoylam, 1), reason: ad);
    }

    test('New York, yaz saati: Sean Lennon', () {
      // /Lennon,_Sean: 9 Ekim 1975 02:00, Manhattan 40n46 73w59,
      // "EDT h4w", Asc 15°20' Aslan, AA, "BC/BR in hand".
      yukselen(
        ad: 'Sean Lennon',
        kimlik: 'America/New_York',
        duvar: DateTime.utc(1975, 10, 9, 2),
        adbFarkDakika: -240,
        enlem: 40 + 46 / 60,
        boylam: -(73 + 59 / 60),
        burc: Burc.aslan,
        adbBoylam: 120 + 15 + 20 / 60,
      );
    });

    test('Londra, yaz saati: Prens William', () {
      // /William,_Prince_of_Wales: 21 Haziran 1982 21:03, Paddington
      // 51n32 0w12, "GDT h1e", Asc 27°26' Yay, AA, "BC/BR in hand".
      yukselen(
        ad: 'Prens William',
        kimlik: 'Europe/London',
        duvar: DateTime.utc(1982, 6, 21, 21, 3),
        adbFarkDakika: 60,
        enlem: 51 + 32 / 60,
        boylam: -12 / 60,
        burc: Burc.yay,
        adbBoylam: 240 + 27 + 26 / 60,
      );
    });

    test('İngiltere, 1968–71 yıl boyu +1 (kış): Gerard Butler', () {
      // /Butler,_Gerard: 13 Kasım 1969 05:21, Glasgow 55n53 4w15,
      // "MET h1e (is standard time)", Asc 15°20' Terazi, AA, "Quoted BC/BR".
      // Glasgow, IANA'da Europe/London kaydına bağlıdır.
      yukselen(
        ad: 'Gerard Butler',
        kimlik: 'Europe/London',
        duvar: DateTime.utc(1969, 11, 13, 5, 21),
        adbFarkDakika: 60,
        enlem: 55 + 53 / 60,
        boylam: -(4 + 15 / 60),
        burc: Burc.terazi,
        adbBoylam: 180 + 15 + 20 / 60,
      );
    });

    test('Tokyo: Prenses Mako', () {
      // /Mako,_Princess_of_Japan: 23 Ekim 1991 23:41, Tokyo 35n42 139e46,
      // "JST h9e", Asc 11°56' Aslan, AA, "Quoted BC/BR".
      yukselen(
        ad: 'Prenses Mako',
        kimlik: 'Asia/Tokyo',
        duvar: DateTime.utc(1991, 10, 23, 23, 41),
        adbFarkDakika: 540,
        enlem: 35 + 42 / 60,
        boylam: 139 + 46 / 60,
        burc: Burc.aslan,
        adbBoylam: 120 + 11 + 56 / 60,
      );
    });
  });

  test(
    'veri yüklüyse yeniden yüklenmez: paketin yerel konum ayarı korunur',
    () {
      expect(DogumSaatDilimi.tanimliMi('Asia/Tokyo'), isTrue);
      tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
      DogumSaatDilimi.cozumle(
        ianaKimligi: 'America/New_York',
        yerel: DateTime(2000),
      );
      expect(tz.local.name, 'Asia/Tokyo');
    },
  );

  test(
    'sonuç makinenin saat diliminden bağımsız: yalnız duvar saati okunur',
    () {
      final DogumSaatDilimiSonucu a = coz(
        'America/New_York',
        1985,
        7,
        4,
        9,
        15,
      );
      final DogumSaatDilimiSonucu b = DogumSaatDilimi.cozumle(
        ianaKimligi: 'America/New_York',
        yerel: DateTime(1985, 7, 4, 9, 15),
      )!;
      expect(a.farkDakika, b.farkDakika);
      expect(a.durum, b.durum);
    },
  );
}
