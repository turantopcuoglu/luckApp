import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Biçim testi: satırlar GeoNames `cities15000` sütun düzenindedir
/// (geonames.org/export/ "geoname" tablosu, 19 sütun). Değerler örnektir,
/// kaynak verisi değildir.
String gn({
  required String ad,
  required String ascii,
  required String ulke,
  required String enlem,
  required String boylam,
  required String tz,
  int nufus = 100000,
  String diger = 'alt1,alt2',
}) => <String>[
  '1', ad, ascii, diger, enlem, boylam, 'P', 'PPL', ulke, '', '01', //
  '', '', '', '$nufus', '', '34', tz, '2024-01-01',
].join('\t');

void main() {
  final List<String> ham = <String>[
    gn(
      ad: 'München',
      ascii: 'Munich',
      ulke: 'DE',
      enlem: '48.13743',
      boylam: '11.57549',
      tz: 'Europe/Berlin',
      nufus: 1260391,
    ),
    gn(
      ad: 'Berlin',
      ascii: 'Berlin',
      ulke: 'DE',
      enlem: '52.52437',
      boylam: '13.41053',
      tz: 'Europe/Berlin',
      nufus: 3426354,
    ),
    gn(
      ad: 'Mönchengladbach',
      ascii: 'Moenchengladbach',
      ulke: 'DE',
      enlem: '51.18539',
      boylam: '6.44172',
      tz: 'Europe/Berlin',
      nufus: 261454,
    ),
    gn(
      ad: 'Łódź',
      ascii: 'Lodz',
      ulke: 'PL',
      enlem: '51.75',
      boylam: '19.46667',
      tz: 'Europe/Warsaw',
      nufus: 768755,
    ),
    gn(
      ad: 'İzmir',
      ascii: 'Izmir',
      ulke: 'TR',
      enlem: '38.41273',
      boylam: '27.13838',
      tz: 'Europe/Istanbul',
    ),
    gn(ad: 'Yok', ascii: 'Yok', ulke: 'DE', enlem: '1', boylam: '1', tz: ''),
    'bozuk\tsatir',
  ];
  // Betiğin yaptığı gibi: oku, nüfusa göre sırala.
  final List<DunyaSehri> sirali =
      ham.map(DunyaSehri.geoNamesSatirindan).nonNulls.toList()
        ..sort((DunyaSehri a, DunyaSehri b) => b.nufus.compareTo(a.nufus));

  group('GeoNames satırı', () {
    test('sütunlar doğru okunur', () {
      final DunyaSehri m = DunyaSehri.geoNamesSatirindan(ham[0])!;
      expect(m.ad, 'München');
      expect(m.asciiAd, 'Munich');
      expect(m.ulkeKodu, 'DE');
      expect(m.enlem, 48.13743);
      expect(m.boylam, 11.57549);
      expect(m.saatDilimi, 'Europe/Berlin');
      expect(m.nufus, 1260391);
    });

    test('Türkiye, saat dilimsiz ve bozuk satır alınmaz', () {
      expect(DunyaSehri.geoNamesSatirindan(ham[4]), isNull);
      expect(DunyaSehri.geoNamesSatirindan(ham[5]), isNull);
      expect(DunyaSehri.geoNamesSatirindan(ham[6]), isNull);
    });
  });

  group('asset biçimi', () {
    test('yaz-oku: sıra ve alanlar korunur, koordinat 4 haneye yuvarlanır', () {
      final String metin = DunyaSehirleri.kompaktYaz(
        sirali,
        aciklama: <String>['Şehir verisi: GeoNames, CC BY 4.0'],
      );
      expect(metin, startsWith('# Şehir verisi: GeoNames, CC BY 4.0\n@'));
      final List<DunyaSehri> okunan = DunyaSehirleri.kompaktOku(
        '$metin\nbozuk\n\n',
      );
      expect(okunan.map((DunyaSehri s) => s.ad), <String>[
        'Berlin',
        'München',
        'Łódź',
        'Mönchengladbach',
      ]);
      final DunyaSehri m = okunan[1];
      expect(m.asciiAd, 'Munich');
      expect(m.enlem, 48.1374);
      expect(m.boylam, 11.5755);
      expect(m.saatDilimi, 'Europe/Berlin');
      expect(okunan[2].saatDilimi, 'Europe/Warsaw');
      // ASCII ad yerel adla aynıysa boş yazılır, okurken geri gelir.
      expect(okunan[0].asciiAd, 'Berlin');
      expect(metin, contains('Berlin\t\tDE\t52.5244\t13.4105\t'));
    });

    test('saat dilimi tablosu yoksa ya da sırası taşarsa satır atlanır', () {
      expect(DunyaSehirleri.kompaktOku('A\t\tDE\t1\t2\t0\t'), isEmpty);
      expect(
        DunyaSehirleri.kompaktOku('@Europe/Berlin\nA\t\tDE\t1\t2\t1\t'),
        isEmpty,
      );
      expect(
        DunyaSehirleri.kompaktOku(
          '@Europe/Berlin\nA\t\tDE\t1\t2\t0\t',
        ).single.ad,
        'A',
      );
    });

    test('doğum yerine dönüşür', () {
      final DogumYeri yer = sirali.first.dogumYeri();
      expect(yer.ulkeKodu, 'DE');
      expect(yer.ad, 'Berlin');
      expect(yer.ilPlaka, isNull);
      expect(yer.turkiyeMi, isFalse);
      expect(
        yer.saatDilimiSonucu(DateTime.utc(1990, 7, 1, 12)).farkDakika,
        120,
      );
    });
  });

  group('arama', () {
    List<String> ara(String ulke, String sorgu, {int enFazla = 20}) =>
        DunyaSehirleri.ara(
          sirali,
          ulkeKodu: ulke,
          sorgu: sorgu,
          enFazla: enFazla,
        ).map((DunyaSehri s) => s.ad).toList();

    test('aksan ve büyük harf gözetmez; ASCII ad da bulunur', () {
      expect(ara('DE', 'munchen'), <String>['München']);
      expect(ara('DE', 'MÜNCHEN'), <String>['München']);
      expect(ara('DE', 'Munich'), <String>['München']);
      expect(ara('PL', 'lodz'), <String>['Łódź']);
    });

    test('yalnız seçilen ülke; başlayan önce, sonra içeren; sıra korunur', () {
      expect(ara('PL', 'berlin'), isEmpty);
      expect(ara('DE', 'mon'), <String>['Mönchengladbach']);
      // "en": hiçbiri "en" ile başlamıyor; içerenler listedeki sırayla.
      expect(ara('DE', 'en'), <String>['München', 'Mönchengladbach']);
    });

    test('boş sorgu: ülkenin ilk (kalabalık) şehirleri, sınırla', () {
      expect(ara('DE', ''), <String>['Berlin', 'München', 'Mönchengladbach']);
      expect(ara('DE', '', enFazla: 1), <String>['Berlin']);
    });
  });

  group('diğer adlar (GeoNames ana adı İngilizce olabilir)', () {
    final DunyaSehri munich = DunyaSehri.geoNamesSatirindan(
      gn(
        ad: 'Munich',
        ascii: 'Munich',
        ulke: 'DE',
        enlem: '48.13743',
        boylam: '11.57549',
        tz: 'Europe/Berlin',
        nufus: 1260391,
        diger:
            'MUC,Munchen,München,Münih,Munich,wei ye na,Мюнхен,Monaco di Baviera',
      ),
    )!;

    test('Latin yazılı, kod olmayan, büyük harfle başlayan adlar tutulur; '
        'aksanlısı aksansızına yeğlenir', () {
      expect(munich.digerAdlar, <String>[
        'München',
        'Münih',
        'Monaco di Baviera',
      ]);
    });

    test('küçük şehirde diğer ad tutulmaz', () {
      final DunyaSehri kucuk = DunyaSehri.geoNamesSatirindan(
        gn(
          ad: 'Ort',
          ascii: 'Ort',
          ulke: 'DE',
          enlem: '1',
          boylam: '1',
          tz: 'Europe/Berlin',
          nufus: 20000,
          diger: 'Anderer Ort',
        ),
      )!;
      expect(kucuk.digerAdlar, isEmpty);
    });

    test('asset ile gidip gelir; aramada bulunur ve eşleşen ad döner', () {
      final List<DunyaSehri> okunan = DunyaSehirleri.kompaktOku(
        DunyaSehirleri.kompaktYaz(<DunyaSehri>[munich, ...sirali]),
      );
      expect(okunan.first.digerAdlar, munich.digerAdlar);
      for (final String sorgu in <String>[
        'münchen',
        'MUNCH',
        'münih',
        'munih',
      ]) {
        expect(
          DunyaSehirleri.ara(okunan, ulkeKodu: 'DE', sorgu: sorgu).first.ad,
          'Munich',
          reason: sorgu,
        );
      }
      expect(DunyaSehirleri.eslesenDigerAd(okunan.first, 'münih'), 'Münih');
      expect(DunyaSehirleri.eslesenDigerAd(okunan.first, 'mun'), isNull);
      expect(DunyaSehirleri.eslesenDigerAd(okunan.first, 'xyz'), isNull);
    });
  });

  group('aynı adlı şehirler', () {
    const DunyaSehri a = DunyaSehri(
      ad: 'Springfield',
      asciiAd: 'Springfield',
      ulkeKodu: 'US',
      enlem: 39.80172,
      boylam: -89.64371,
      saatDilimi: 'America/Chicago',
    );
    const DunyaSehri b = DunyaSehri(
      ad: 'Springfield',
      asciiAd: 'Springfield',
      ulkeKodu: 'US',
      enlem: 42.10148,
      boylam: -72.58981,
      saatDilimi: 'America/New_York',
    );
    const DunyaSehri c = DunyaSehri(
      ad: 'Springfield',
      asciiAd: 'Springfield',
      ulkeKodu: 'AU',
      enlem: -27.65,
      boylam: 152.9,
      saatDilimi: 'Australia/Brisbane',
    );

    test('aynı ülkede aynı ad koordinatla ayrılır; başka ülkede ayrılmaz', () {
      final Set<String> ayni = DunyaSehirleri.ayniAdlar(<DunyaSehri>[a, b, c]);
      expect(
        DunyaSehirleri.gorunenAd(a, ayni),
        'Springfield (39.80°, -89.64°)',
      );
      expect(
        DunyaSehirleri.gorunenAd(b, ayni),
        'Springfield (42.10°, -72.59°)',
      );
      expect(DunyaSehirleri.gorunenAd(c, ayni), 'Springfield');
    });
  });

  group('ülkeler', () {
    final List<Ulke> ulkeler = Ulkeler.kompaktOku(
      '# CLDR\n'
      'DE\tAlmanya\tGermany\n'
      'AT\tAvusturya\tAustria\n'
      'AU\tAvustralya\tAustralia\n'
      'NL\tHollanda\tNetherlands\n'
      'TR\tTürkiye\tTürkiye\n'
      'bozuk\n',
    );

    test('okunur; bozuk satır atlanır; ad dile göre', () {
      expect(ulkeler.length, 5);
      expect(ulkeler.first.ad('tr'), 'Almanya');
      expect(ulkeler.first.ad('en'), 'Germany');
    });

    test('arama: Türkçe ve İngilizce adla, aksansız, alfabetik', () {
      List<String> ara(String s, String dil) => Ulkeler.ara(
        ulkeler,
        sorgu: s,
        dilKodu: dil,
      ).map((Ulke u) => u.kod).toList();
      expect(ara('avu', 'tr'), <String>['AU', 'AT']); // Avustr < Avustu
      expect(ara('germ', 'tr'), <String>['DE']);
      expect(ara('almanya', 'en'), <String>['DE']);
      expect(ara('turkiye', 'tr'), <String>['TR']);
      expect(ara('nl', 'tr'), <String>['NL']);
    });
  });

  group('Numeroloji.latinSadelestir', () {
    test('Türkçe ve aksanlı harfler Latin temel harfe iner', () {
      expect(Numeroloji.latinSadelestir('İzmir'), 'izmir');
      expect(Numeroloji.latinSadelestir('IĞDIR'), 'igdir');
      expect(Numeroloji.latinSadelestir('Straße'), 'strasse');
      expect(Numeroloji.latinSadelestir('Ærø'), 'aero');
      expect(Numeroloji.latinSadelestir('São Paulo'), 'sao paulo');
      expect(Numeroloji.latinSadelestir('Москва'), 'москва');
    });
  });
}
