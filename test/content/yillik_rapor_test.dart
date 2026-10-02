import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/yillik_rapor.dart';
import 'package:kader/core/content/yillik_rapor_metinleri.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

import 'fortune_pools_test.dart' show havuzuDogrula;

int _kelime(String metin) =>
    metin.split(RegExp(r'\s+')).where((String k) => k.isNotEmpty).length;

/// Yıllık rapor havuzlarındaki tüm metinler.
List<String> _tumMetinler() => <String>[
  for (final YilRehberi r in YillikRaporMetinleri.rehberler.values) ...<String>[
    r.firsatlar,
    r.dikkat,
    r.ask,
    r.isVePara,
    r.niyet,
  ],
  for (final AyTemasi a in YillikRaporMetinleri.aylar.values) ...a.varyantlar,
  YillikRaporMetinleri.akisAciklamasi,
  YillikRaporMetinleri.zorluAciklamasi,
];

void main() {
  // 14.03.1994: yaşam yolu 4 (uyumlu kişisel sayılar 2, 4, 8; zorlayıcı
  // 3, 5, 9). 2027: 3 + 5 + (2+0+2+7=11→2) = 10 → kişisel yıl 1.
  final DateTime ayseDogum = DateTime(1994, 3, 14);
  final NumerolojiRaporu ayse = NumerolojiRaporu.hesapla(
    dogumTarihi: ayseDogum,
    tamAd: 'Ayşe Yılmaz',
  );

  group('Yıllık rapor metin havuzları', () {
    test('her kişisel yıl ve ay için metin var, yeterince derin', () {
      for (int s = 1; s <= EngineConfig.numerolojiTabani; s++) {
        final YilRehberi? r = YillikRaporMetinleri.rehberler[s];
        expect(r, isNotNull, reason: 'yıl $s');
        for (final String m in <String>[
          r!.firsatlar,
          r.dikkat,
          r.ask,
          r.isVePara,
        ]) {
          expect(
            _kelime(m),
            greaterThanOrEqualTo(ContentConfig.raporUzunEnAzKelime),
            reason: m,
          );
        }
        expect(
          _kelime(r.niyet),
          greaterThanOrEqualTo(ContentConfig.raporKisaEnAzKelime),
        );
        final AyTemasi? a = YillikRaporMetinleri.aylar[s];
        expect(a, isNotNull, reason: 'ay $s');
        expect(a!.varyantlar, hasLength(ContentConfig.yillikAyVaryanti));
        for (final String v in a.varyantlar) {
          expect(
            _kelime(v),
            greaterThanOrEqualTo(ContentConfig.raporKisaEnAzKelime),
          );
        }
      }
      expect(YillikRaporMetinleri.ayAdlari, hasLength(DateTime.monthsPerYear));
    });

    test('biçim, tekrar ve yasaklı ifade', () {
      final List<String> metinler = _tumMetinler();
      havuzuDogrula('yıllık', metinler);
      for (final String m in metinler) {
        expect(m.contains('  '), isFalse, reason: m);
        expect(m.contains('{'), isFalse, reason: m);
        final String kucuk = m.toLowerCase();
        for (final String yasak in ContentConfig.yasakliIfadeler) {
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(yasak)}',
          );
          expect(desen.hasMatch(kucuk), isFalse, reason: '"$yasak": $m');
        }
      }
    });

    test(
      'dönem geçişi girişi iki noktayla biter (ardından zirve özeti gelir)',
      () {
        expect(YillikRaporMetinleri.donemGecisiGirisi.endsWith(':'), isTrue);
        expect(YillikRaporMetinleri.donemGecisiGirisi.contains('  '), isFalse);
      },
    );

    test('ay listesi Türkçe bağlaçla birleşir', () {
      expect(YillikRaporMetinleri.ayListesi(<int>[3]), 'Mart');
      expect(YillikRaporMetinleri.ayListesi(<int>[3, 7]), 'Mart ve Temmuz');
      expect(
        YillikRaporMetinleri.ayListesi(<int>[1, 3, 12]),
        'Ocak, Mart ve Aralık',
      );
    });
  });

  group('yillikRaporOkumasi', () {
    test('Ayşe 2027: Tohum Yılı, ay dizisi, varyantlar ve akış', () {
      final YillikRaporOkumasi o = yillikRaporOkumasi(rapor: ayse, yil: 2027);
      expect(o.kisiselYil, 1);
      expect(o.yilLakabi, 'Tohum Yılı');
      expect(o.aylar.map((YillikAy a) => a.kisiselAy), <int>[
        2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, //
      ]);
      // Ocak ve Ekim ikisi de kişisel ay 2: farklı varyant.
      expect(o.aylar[0].metin, YillikRaporMetinleri.aylar[2]!.varyantlar[0]);
      expect(o.aylar[9].metin, YillikRaporMetinleri.aylar[2]!.varyantlar[1]);
      expect(o.aylar[2].baslik, 'Mart · Emek ve düzen ayı');
      // Yaşam yolu 4: 2, 4, 8 akış; 3, 5, 9 zorlu.
      expect(o.aylar.map((YillikAy a) => a.akis), <AyAkisi>[
        AyAkisi.akis, // Ocak 2
        AyAkisi.zorlu, // Şubat 3
        AyAkisi.akis, // Mart 4
        AyAkisi.zorlu, // Nisan 5
        AyAkisi.dengeli, // Mayıs 6
        AyAkisi.dengeli, // Haziran 7
        AyAkisi.akis, // Temmuz 8
        AyAkisi.zorlu, // Ağustos 9
        AyAkisi.dengeli, // Eylül 1
        AyAkisi.akis, // Ekim 2
        AyAkisi.zorlu, // Kasım 3
        AyAkisi.akis, // Aralık 4
      ]);
      // Yalnızca Ocak ücretsiz.
      expect(
        o.aylar.where((YillikAy a) => !a.premium).map((YillikAy a) => a.ay),
        <int>[1],
      );
    });

    test('Ayşe 2027: bölüm sırası, başlıklar ve ücretsiz kısım', () {
      final YillikRaporOkumasi o = yillikRaporOkumasi(rapor: ayse, yil: 2027);
      expect(o.bolumler.map((YillikBolum b) => b.tur), <YillikBolumTuru>[
        YillikBolumTuru.tema,
        YillikBolumTuru.firsatlar,
        YillikBolumTuru.dikkat,
        YillikBolumTuru.ask,
        YillikBolumTuru.isVePara,
        YillikBolumTuru.akisAylari,
        YillikBolumTuru.zorluAylar,
        YillikBolumTuru.niyet,
      ]);
      expect(o.bolumler.first.baslik, '2027 · Tohum Yılı · Kişisel yıl 1');
      expect(o.bolumler.first.metin, startsWith('2027 senin için bir 1 yılı'));
      expect(o.bolumler[1].metin, YillikRaporMetinleri.rehberler[1]!.firsatlar);
      expect(
        o.bolumler[5].metin,
        startsWith('Ocak, Mart, Temmuz, Ekim ve Aralık. '),
      );
      expect(
        o.bolumler[6].metin,
        startsWith('Şubat, Nisan, Ağustos ve Kasım. '),
      );
      expect(
        o.bolumler
            .where((YillikBolum b) => !b.premium)
            .map((YillikBolum b) => b.tur),
        <YillikBolumTuru>[YillikBolumTuru.tema],
      );
    });

    test('yıl içinde yeni döneme geçiş varsa bölümü eklenir', () {
      // Ayşe 2026'da 32 yaşına girer: 2. dönemin (32-41) başlangıcı.
      final YillikRaporOkumasi o2026 = yillikRaporOkumasi(
        rapor: ayse,
        yil: 2026,
      );
      final YillikBolum gecis = o2026.bolumler[1];
      expect(gecis.tur, YillikBolumTuru.donemGecisi);
      expect(gecis.baslik, 'Yeni bir dönem başlıyor · 32-41 yaş');
      expect(gecis.metin, startsWith(YillikRaporMetinleri.donemGecisiGirisi));
      // 2027'de geçiş yok; 2044'te 50 yaşı (4. dönem) var.
      expect(
        yillikRaporOkumasi(
          rapor: ayse,
          yil: 2027,
        ).bolumler.any((YillikBolum b) => b.tur == YillikBolumTuru.donemGecisi),
        isFalse,
      );
      expect(
        yillikRaporOkumasi(rapor: ayse, yil: 2044).bolumler[1].baslik,
        'Yeni bir dönem başlıyor · 50 yaş ve sonrası',
      );
    });

    test('deterministik ve geniş tarama: her yıl 12 ay, aynı metin en fazla '
        'bir kez', () {
      for (int i = 0; i < 200; i++) {
        final DateTime d = DateTime(1945, 1, 1 + i * 131);
        final NumerolojiRaporu r = NumerolojiRaporu.hesapla(dogumTarihi: d);
        for (final int yil in <int>[2026, 2027, 2028]) {
          final YillikRaporOkumasi a = yillikRaporOkumasi(rapor: r, yil: yil);
          final YillikRaporOkumasi b = yillikRaporOkumasi(rapor: r, yil: yil);
          expect(a.aylar, hasLength(DateTime.monthsPerYear));
          expect(
            a.aylar.map((YillikAy x) => x.metin).toSet(),
            hasLength(DateTime.monthsPerYear),
            reason: '$d $yil',
          );
          expect(
            a.bolumler.map((YillikBolum x) => x.metin),
            b.bolumler.map((YillikBolum x) => x.metin),
          );
          for (final YillikBolum x in a.bolumler) {
            expect(x.metin.trim(), isNotEmpty);
            expect(x.metin.contains('{'), isFalse);
          }
        }
      }
    });
  });
}
