import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Biçim testi: satırlar GeoNames `cities15000` sütun düzenindedir
/// (geonames.org/export/ "geoname" tablosu, 19 sütun). Değerler örnektir,
/// kaynak verisi değildir.
String gn({
  required int kimlik,
  required String ad,
  required String ascii,
  required String ulke,
  required String enlem,
  required String boylam,
  required String tz,
  int nufus = 100000,
}) => <String>[
  '$kimlik',
  ad,
  ascii,
  'alt1,alt2',
  enlem,
  boylam,
  'P',
  'PPL',
  ulke,
  '',
  '01',
  '',
  '',
  '',
  '$nufus',
  '',
  '34',
  tz,
  '2024-01-01',
].join('\t');

void main() {
  final List<String> ham = <String>[
    gn(
      kimlik: 1,
      ad: 'München',
      ascii: 'Munich',
      ulke: 'DE',
      enlem: '48.13743',
      boylam: '11.57549',
      tz: 'Europe/Berlin',
      nufus: 1260391,
    ),
    gn(
      kimlik: 2,
      ad: 'Berlin',
      ascii: 'Berlin',
      ulke: 'DE',
      enlem: '52.52437',
      boylam: '13.41053',
      tz: 'Europe/Berlin',
      nufus: 3426354,
    ),
    gn(
      kimlik: 3,
      ad: 'Mönchengladbach',
      ascii: 'Moenchengladbach',
      ulke: 'DE',
      enlem: '51.18539',
      boylam: '6.44172',
      tz: 'Europe/Berlin',
      nufus: 261454,
    ),
    gn(
      kimlik: 4,
      ad: 'Łódź',
      ascii: 'Lodz',
      ulke: 'PL',
      enlem: '51.75',
      boylam: '19.46667',
      tz: 'Europe/Warsaw',
      nufus: 768755,
    ),
    gn(
      kimlik: 5,
      ad: 'İzmir',
      ascii: 'Izmir',
      ulke: 'TR',
      enlem: '38.41273',
      boylam: '27.13838',
      tz: 'Europe/Istanbul',
    ),
    gn(
      kimlik: 6,
      ad: 'Yok',
      ascii: 'Yok',
      ulke: 'DE',
      enlem: '1',
      boylam: '1',
      tz: '',
    ),
    'bozuk\tsatir',
  ];

  group('GeoNames satırı', () {
    test('sütunlar doğru okunur', () {
      final DunyaSehri m = DunyaSehri.geoNamesSatirindan(ham[0])!;
      expect(m.kimlik, 1);
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

  group('kompakt biçim', () {
    final List<DunyaSehri> sehirler = ham
        .map(DunyaSehri.geoNamesSatirindan)
        .nonNulls
        .toList();

    test('yaz-oku: koordinat 4 haneye yuvarlanır, öbür alanlar aynı', () {
      final String metin = <String>[
        '# Şehir verisi: GeoNames (geonames.org), CC BY 4.0',
        '',
        ...sehirler.map((DunyaSehri s) => s.kompaktSatir()),
        'bozuk',
      ].join('\n');
      final List<DunyaSehri> okunan = DunyaSehirleri.kompaktOku(metin);
      expect(okunan.length, sehirler.length);
      expect(okunan.first.ad, 'München');
      expect(okunan.first.enlem, 48.1374);
      expect(okunan.first.boylam, 11.5755);
      expect(okunan.first.saatDilimi, 'Europe/Berlin');
      expect(okunan[3].ad, 'Łódź');
    });

    test('doğum yerine dönüşür', () {
      final DogumYeri yer = sehirler[1].dogumYeri();
      expect(yer.ulkeKodu, 'DE');
      expect(yer.sehirKimligi, 2);
      expect(yer.ilPlaka, isNull);
      expect(yer.turkiyeMi, isFalse);
      expect(
        yer.saatDilimiSonucu(DateTime.utc(1990, 7, 1, 12)).farkDakika,
        120,
      );
    });
  });

  group('arama', () {
    final List<DunyaSehri> sehirler = ham
        .map(DunyaSehri.geoNamesSatirindan)
        .nonNulls
        .toList();
    List<String> ara(String ulke, String sorgu) => DunyaSehirleri.ara(
      sehirler,
      ulkeKodu: ulke,
      sorgu: sorgu,
    ).map((DunyaSehri s) => s.ad).toList();

    test('aksan ve büyük harf gözetmez; ASCII ad da bulunur', () {
      expect(ara('DE', 'munchen'), <String>['München']);
      expect(ara('DE', 'MÜNCHEN'), <String>['München']);
      expect(ara('DE', 'Munich'), <String>['München']);
      expect(ara('PL', 'lodz'), <String>['Łódź']);
    });

    test('yalnız seçilen ülke; başlayan önce, sonra içeren', () {
      expect(ara('PL', 'berlin'), isEmpty);
      // "mon" Mönchengladbach'ın başı; München'de geçmiyor.
      expect(ara('DE', 'mon'), <String>['Mönchengladbach']);
      // "en": hiçbiri "en" ile başlamıyor; içerenler nüfusa göre.
      expect(ara('DE', 'en'), <String>['München', 'Mönchengladbach']);
    });

    test('boş sorgu: ülkenin en kalabalık şehirleri, sınırla', () {
      expect(ara('DE', ''), <String>['Berlin', 'München', 'Mönchengladbach']);
      expect(
        DunyaSehirleri.ara(
          sehirler,
          ulkeKodu: 'DE',
          sorgu: '',
          enFazla: 1,
        ).single.ad,
        'Berlin',
      );
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
