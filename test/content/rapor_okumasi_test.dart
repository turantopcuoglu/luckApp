import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/rapor_metinleri.dart';
import 'package:kader/core/content/rapor_okumasi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

import 'fortune_pools_test.dart' show havuzuDogrula;

/// Zirve ve olgunluk sayılarının alabileceği tüm değerler.
const List<int> _zirveSayilari = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];

/// İsimlerin başında yer alabilen Türk alfabesi harfleri (Ğ hariç).
const String _ilkHarfler = 'ABCÇDEFGHIİJKLMNOÖPRSŞTUÜVYZ';

int _kelime(String metin) =>
    metin.split(RegExp(r'\s+')).where((String k) => k.isNotEmpty).length;

/// Rapor havuzlarındaki tüm metinler.
List<String> _tumMetinler() => <String>[
  for (final DonemMetni m in RaporMetinleri.zirveler.values) ...<String>[
    m.kisa,
    m.uzun,
  ],
  for (final DonemMetni m in RaporMetinleri.zorluklar.values) ...<String>[
    m.kisa,
    m.uzun,
  ],
  for (final KarmikBorcMetni m in RaporMetinleri.karmikBorclar.values) m.metin,
  RaporMetinleri.karmikBorcYok,
  ...RaporMetinleri.karmikDersler.values,
  RaporMetinleri.karmikDersYok,
  ...RaporMetinleri.gizliTutkular.values,
  ...RaporMetinleri.olgunluk.values,
  ...RaporMetinleri.temelTaslari.values,
  ...RaporMetinleri.temelTasiDegere.values,
  ...RaporMetinleri.tepeTaslari.values,
  ...RaporMetinleri.dengeler.values,
];

void main() {
  final DateTime ayseDogum = DateTime(1994, 3, 14);
  const String ayseAd = 'Ayşe Yılmaz';
  // 2 Ekim 2026'da Ayşe 32 yaşında: 2. dönem (32-41).
  final DateTime bugun = DateTime(2026, 10, 2);

  group('Rapor metin havuzları', () {
    test('her sayı için metin var ve yeterince derin', () {
      for (final int s in _zirveSayilari) {
        final DonemMetni? z = RaporMetinleri.zirveler[s];
        expect(z, isNotNull, reason: 'zirve $s');
        expect(
          _kelime(z!.uzun),
          greaterThanOrEqualTo(ContentConfig.raporUzunEnAzKelime),
          reason: 'zirve $s',
        );
        expect(
          _kelime(z.kisa),
          greaterThanOrEqualTo(ContentConfig.raporKisaEnAzKelime),
        );
        expect(RaporMetinleri.olgunluk[s], isNotNull, reason: 'olgunluk $s');
      }
      for (int s = 0; s <= EngineConfig.numerolojiTabani - 1; s++) {
        final DonemMetni? z = RaporMetinleri.zorluklar[s];
        expect(z, isNotNull, reason: 'zorluk $s');
        expect(
          _kelime(z!.uzun),
          greaterThanOrEqualTo(ContentConfig.raporUzunEnAzKelime),
          reason: 'zorluk $s',
        );
      }
      for (final int s in EngineConfig.karmikBorcSayilari) {
        final KarmikBorcMetni? k = RaporMetinleri.karmikBorclar[s];
        expect(k, isNotNull, reason: 'karmik $s');
        expect(
          _kelime(k!.metin),
          greaterThanOrEqualTo(ContentConfig.raporUzunEnAzKelime),
        );
      }
      for (int s = 1; s <= EngineConfig.numerolojiTabani; s++) {
        for (final Map<int, String> havuz in <Map<int, String>>[
          RaporMetinleri.karmikDersler,
          RaporMetinleri.gizliTutkular,
          RaporMetinleri.temelTasiDegere,
          RaporMetinleri.tepeTaslari,
          RaporMetinleri.dengeler,
        ]) {
          expect(havuz[s], isNotNull, reason: 'sayı $s');
          expect(
            _kelime(havuz[s]!),
            greaterThanOrEqualTo(ContentConfig.raporKisaEnAzKelime),
            reason: havuz[s],
          );
        }
      }
      for (final String harf in _ilkHarfler.split('')) {
        expect(RaporMetinleri.temelTaslari[harf], isNotNull, reason: harf);
        expect(RaporMetinleri.temelTaslari[harf]!.startsWith(harf), isTrue);
      }
      for (final KarmikKaynak k in KarmikKaynak.values) {
        expect(RaporMetinleri.karmikKaynaklar[k], isNotNull, reason: '$k');
      }
    });

    test('biçim: noktalama, tekrar yok, çift boşluk yok', () {
      final List<String> metinler = _tumMetinler();
      havuzuDogrula('rapor', metinler);
      for (final String m in metinler) {
        expect(m.contains('  '), isFalse, reason: m);
        expect(m.contains('{'), isFalse, reason: m);
      }
    });

    test('yasaklı ifade içermez', () {
      for (final String m in _tumMetinler()) {
        final String kucuk = m.toLowerCase();
        for (final String yasak in ContentConfig.yasakliIfadeler) {
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(yasak)}',
          );
          expect(desen.hasMatch(kucuk), isFalse, reason: '"$yasak": $m');
        }
      }
    });

    test('yaş aralığı etiketleri', () {
      const YasamDonemi ilk = YasamDonemi(
        sira: 1,
        zirve: 1,
        zorluk: 0,
        baslangicYasi: 0,
        bitisYasi: 32,
      );
      const YasamDonemi ara = YasamDonemi(
        sira: 2,
        zirve: 1,
        zorluk: 0,
        baslangicYasi: 32,
        bitisYasi: 41,
      );
      const YasamDonemi son = YasamDonemi(
        sira: 4,
        zirve: 1,
        zorluk: 0,
        baslangicYasi: 50,
        bitisYasi: null,
      );
      expect(RaporMetinleri.yasAraligi(ilk), 'Doğumdan 32 yaşa');
      expect(RaporMetinleri.yasAraligi(ara), '32-41 yaş');
      expect(RaporMetinleri.yasAraligi(son), '50 yaş ve sonrası');
    });

    test('Türkçe sıralama bağlacı', () {
      expect(
        RaporMetinleri.karmikKaynakCumlesi(<KarmikKaynak>[KarmikKaynak.ruh]),
        'Bu sayı ruh sayında görülüyor.',
      );
      expect(
        RaporMetinleri.karmikKaynakCumlesi(<KarmikKaynak>[
          KarmikKaynak.yasamYolu,
          KarmikKaynak.isim,
          KarmikKaynak.kisilik,
        ]),
        'Bu sayı yaşam yolu hesabında, isim sayında ve kişilik sayında '
        'görülüyor.',
      );
      expect(
        RaporMetinleri.gizliTutkuGirisi(<int>[1, 7]),
        'İsminde 1 ve 7 sayıları eşit sıklıkta öne çıkıyor.',
      );
    });
  });

  group('raporOkumasi', () {
    final NumerolojiRaporu ayse = NumerolojiRaporu.hesapla(
      dogumTarihi: ayseDogum,
      tamAd: ayseAd,
    );

    test('Ayşe Yılmaz: bölüm sırası, başlıklar ve ücretsiz kısım', () {
      final RaporOkumasi o = raporOkumasi(rapor: ayse, gun: bugun);
      expect(o.bolumler.map((RaporBolumu b) => b.tur), <RaporBolumTuru>[
        RaporBolumTuru.aktifZirve,
        RaporBolumTuru.aktifZorluk,
        RaporBolumTuru.sonrakiDonem,
        RaporBolumTuru.karmikBorc, // 13
        RaporBolumTuru.karmikBorc, // 14
        RaporBolumTuru.karmikBorc, // 16
        RaporBolumTuru.karmikDers,
        RaporBolumTuru.gizliTutku,
        RaporBolumTuru.olgunluk,
        RaporBolumTuru.harfler,
        RaporBolumTuru.denge,
      ]);
      // 2. dönem: zirve 1, zorluk 0; sıradaki 41-50 yaş, zirve 9, zorluk 2.
      expect(o.bolumler[0].baslik, 'Şu anki dönemin · Zirve 1');
      expect(o.bolumler[0].metin, RaporMetinleri.zirveler[1]!.uzun);
      expect(o.bolumler[1].baslik, 'Bu dönemin dersi · Zorluk 0');
      expect(o.bolumler[2].baslik, 'Sıradaki dönem · 41-50 yaş');
      expect(o.bolumler[2].metin, contains(RaporMetinleri.zirveler[9]!.kisa));
      expect(o.bolumler[3].baslik, 'Karmik borç 13 · Emek ve sabır');
      expect(o.bolumler[3].metin, startsWith('Bu sayı yaşam yolu hesabında'));
      expect(o.bolumler[5].metin, startsWith('Bu sayı ruh sayında'));
      // Eksik sayılar 2 ve 6.
      expect(o.bolumler[6].metin, contains('İsminde 2 sayısı yok'));
      expect(o.bolumler[6].metin, contains('İsminde 6 sayısı yok'));
      expect(
        o.bolumler[7].metin,
        startsWith('İsminde en sık tekrar eden sayı 1.'),
      );
      expect(o.bolumler[8].baslik, 'Olgunluk sayısı 5');
      expect(o.bolumler[9].baslik, 'İsminin ilk ve son harfi · A … E');
      expect(o.bolumler[9].metin, startsWith('A ile başlayan isimler'));
      expect(o.bolumler[10].baslik, 'Denge sayısı 8');
      // Yalnızca aktif zirve ücretsiz.
      expect(
        o.bolumler
            .where((RaporBolumu b) => !b.premium)
            .map((RaporBolumu b) => b.tur),
        <RaporBolumTuru>[RaporBolumTuru.aktifZirve],
      );
    });

    test('zaman çizelgesi dört dönem, aktif olan işaretli', () {
      final RaporOkumasi o = raporOkumasi(rapor: ayse, gun: bugun);
      expect(o.zamanCizelgesi, hasLength(EngineConfig.zirveDonemSayisi));
      expect(o.zamanCizelgesi.map((DonemOzeti d) => d.aktif), <bool>[
        false,
        true,
        false,
        false,
      ]);
      expect(o.zamanCizelgesi.map((DonemOzeti d) => d.yasAraligi), <String>[
        'Doğumdan 32 yaşa',
        '32-41 yaş',
        '41-50 yaş',
        '50 yaş ve sonrası',
      ]);
      expect(
        o.zamanCizelgesi.first.zirveOzeti,
        RaporMetinleri.zirveler[8]!.kisa,
      );
    });

    test('deterministik: aynı rapor ve gün aynı okuma', () {
      final RaporOkumasi a = raporOkumasi(rapor: ayse, gun: bugun);
      final RaporOkumasi b = raporOkumasi(
        rapor: NumerolojiRaporu.hesapla(dogumTarihi: ayseDogum, tamAd: ayseAd),
        gun: bugun,
      );
      expect(
        a.bolumler.map((RaporBolumu x) => '${x.baslik}|${x.metin}'),
        b.bolumler.map((RaporBolumu x) => '${x.baslik}|${x.metin}'),
      );
    });

    test('son dönemde "sıradaki dönem" bölümü yok', () {
      final RaporOkumasi o = raporOkumasi(rapor: ayse, gun: DateTime(2060));
      expect(o.zamanCizelgesi.last.aktif, isTrue);
      expect(
        o.bolumler.any((RaporBolumu b) => b.tur == RaporBolumTuru.sonrakiDonem),
        isFalse,
      );
    });

    test('ad yoksa isim bölümleri yok, tarih bölümleri var', () {
      final RaporOkumasi o = raporOkumasi(
        rapor: NumerolojiRaporu.hesapla(dogumTarihi: ayseDogum),
        gun: bugun,
      );
      expect(o.bolumler.map((RaporBolumu b) => b.tur), <RaporBolumTuru>[
        RaporBolumTuru.aktifZirve,
        RaporBolumTuru.aktifZorluk,
        RaporBolumTuru.sonrakiDonem,
        RaporBolumTuru.karmikBorc,
        RaporBolumTuru.karmikBorc,
      ]);
    });

    test('aynı karmik sayı birden çok hesapta: tek bölümde birleşir; hiç '
        'yoksa "borç yok" bölümü', () {
      NumerolojiRaporu kur(List<KarmikBorc> borclar) => NumerolojiRaporu(
        dogumTarihi: ayseDogum,
        donemler: ayse.donemler,
        karmikBorclar: borclar,
        olgunluk: null,
        karmikDersler: <int>[],
        gizliTutku: null,
        temelTasi: null,
        tepeTasi: null,
        dengeSayisi: null,
      );
      final List<RaporBolumu> birlesik =
          raporOkumasi(
                rapor: kur(const <KarmikBorc>[
                  KarmikBorc(sayi: 19, kaynak: KarmikKaynak.yasamYolu),
                  KarmikBorc(sayi: 19, kaynak: KarmikKaynak.isim),
                ]),
                gun: bugun,
              ).bolumler
              .where((RaporBolumu b) => b.tur == RaporBolumTuru.karmikBorc)
              .toList();
      expect(birlesik, hasLength(1));
      expect(
        birlesik.single.metin,
        startsWith('Bu sayı yaşam yolu hesabında ve isim sayında görülüyor.'),
      );

      final RaporOkumasi temiz = raporOkumasi(
        rapor: kur(const <KarmikBorc>[]),
        gun: bugun,
      );
      final RaporBolumu borc = temiz.bolumler.firstWhere(
        (RaporBolumu b) => b.tur == RaporBolumTuru.karmikBorc,
      );
      expect(borc.metin, RaporMetinleri.karmikBorcYok);
      // Eksik sayı yoksa "tüm sayılar var" metni.
      expect(
        temiz.bolumler
            .firstWhere((RaporBolumu b) => b.tur == RaporBolumTuru.karmikDers)
            .metin,
        RaporMetinleri.karmikDersYok,
      );
    });

    test('alfabe dışı ilk harf değer metnine düşer', () {
      // W: 23. harf → 5.
      final RaporOkumasi o = raporOkumasi(
        rapor: NumerolojiRaporu.hesapla(
          dogumTarihi: ayseDogum,
          tamAd: 'William Doğan',
        ),
        gun: bugun,
      );
      final RaporBolumu harf = o.bolumler.firstWhere(
        (RaporBolumu b) => b.tur == RaporBolumTuru.harfler,
      );
      expect(harf.metin, startsWith(RaporMetinleri.temelTasiDegere[5]!));
    });

    test('geniş tarama: her tarih ve isim için eksiksiz metin', () {
      const List<String> adlar = <String>[
        'Ayşe Yılmaz',
        'Mehmet Öztürk',
        'Çağrı Şen',
        'İlknur Ünal',
        'Ğ',
        'Zeynep Nur Kaya',
      ];
      for (int i = 0; i < 300; i++) {
        final DateTime d = DateTime(1940, 1, 1 + i * 97);
        for (final String ad in adlar) {
          final RaporOkumasi o = raporOkumasi(
            rapor: NumerolojiRaporu.hesapla(dogumTarihi: d, tamAd: ad),
            gun: bugun,
          );
          for (final RaporBolumu b in o.bolumler) {
            expect(b.baslik.trim(), isNotEmpty);
            expect(b.metin.trim(), isNotEmpty, reason: '$d $ad ${b.tur}');
            expect(b.metin.contains('  '), isFalse);
          }
          expect(
            o.zamanCizelgesi.where((DonemOzeti x) => x.aktif),
            hasLength(1),
          );
        }
      }
    });
  });
}
