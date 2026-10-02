import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/harita_metinleri.dart';
import 'package:kader/core/content/harita_okumasi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

import 'fortune_pools_test.dart' show havuzuDogrula;

int _kelime(String metin) =>
    metin.split(RegExp(r'\s+')).where((String k) => k.isNotEmpty).length;

void main() {
  group('Harita metin havuzları', () {
    test('12 Ay ve 12 Yükselen metni; doğru açılış ve derinlik', () {
      for (final Burc b in Burc.values) {
        final String ay = HaritaMetinleri.aylar[b]!;
        final String yuk = HaritaMetinleri.yukselenler[b]!;
        expect(ay, startsWith('Ay burcun ${b.etiket}:'));
        expect(yuk, startsWith('Yükselenin ${b.etiket}:'));
        for (final String m in <String>[ay, yuk]) {
          expect(
            _kelime(m),
            greaterThanOrEqualTo(ContentConfig.raporUzunEnAzKelime),
            reason: m,
          );
        }
      }
    });

    test('biçim, tekrar ve yasaklı ifade', () {
      final List<String> metinler = <String>[
        ...HaritaMetinleri.aylar.values,
        ...HaritaMetinleri.yukselenler.values,
        HaritaMetinleri.saatDilimiBelirsiz,
        HaritaMetinleri.yukselenIcinBilgiEksik,
        HaritaMetinleri.ayGunIcindeDegisiyor(Burc.koc, Burc.boga),
        HaritaMetinleri.aySinirda(Burc.koc, Burc.boga),
        HaritaMetinleri.yukselenSinirda(Burc.koc, Burc.boga),
      ];
      havuzuDogrula('harita', metinler);
      for (final String m in metinler) {
        expect(m.contains('  '), isFalse, reason: m);
        final String kucuk = m.toLowerCase();
        for (final String yasak in ContentConfig.yasakliIfadeler) {
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(yasak)}',
          );
          expect(desen.hasMatch(kucuk), isFalse, reason: '"$yasak": $m');
        }
      }
    });
  });

  group('komsuBurc', () {
    test('en yakın sınırın öbür tarafı', () {
      expect(komsuBurc(31), Burc.koc); // Boğa'nın başı → Koç
      expect(komsuBurc(58), Burc.ikizler); // Boğa'nın sonu → İkizler
      expect(komsuBurc(1), Burc.balik); // Koç'un başı → Balık
      expect(komsuBurc(359), Burc.koc); // Balık'ın sonu → Koç
    });
  });

  group('haritaOkumasi', () {
    // Ay 100° (Yengeç ortası), Yükselen 200° (Terazi ortası).
    const DogumHaritasi net = DogumHaritasi(
      gunesBoylami: 355,
      ayBoylami: 100,
      ayBurcu: Burc.yengec,
      ayBurcuKesin: true,
      yukselenBoylami: 200,
    );

    test('net harita: iki bölüm, not yok, büyük üçlü özeti', () {
      final HaritaOkumasi o = haritaOkumasi(
        harita: net,
        saatBiliniyor: true,
        konumBiliniyor: true,
      );
      expect(o.ozet, 'Güneş Balık · Ay Yengeç · Yükselen Terazi');
      expect(o.bolumler.map((HaritaBolumu b) => b.baslik), <String>[
        'Ay burcun · Yengeç',
        'Yükselenin · Terazi',
      ]);
      expect(o.bolumler.first.premium, isFalse);
      expect(o.bolumler.last.premium, isTrue);
      expect(o.notlar, isEmpty);
    });

    test('saat bilinmiyor ve Ay gün içinde değişiyor: alternatif Ay ve '
        'eksik bilgi notu', () {
      // Ay 2° (Koç başı, sabah Balık'taydı).
      const DogumHaritasi h = DogumHaritasi(
        gunesBoylami: 10,
        ayBoylami: 2,
        ayBurcu: Burc.koc,
        ayBurcuKesin: false,
        yukselenBoylami: null,
      );
      final HaritaOkumasi o = haritaOkumasi(
        harita: h,
        saatBiliniyor: false,
        konumBiliniyor: false,
      );
      expect(o.ozet, 'Güneş Koç · Ay Koç · Yükselen ?');
      expect(o.bolumler.map((HaritaBolumu b) => b.baslik), <String>[
        'Ay burcun · Koç',
        'Ay burcun Balık ise',
      ]);
      expect(o.bolumler.last.alternatif, isTrue);
      expect(o.notlar, <String>[
        HaritaMetinleri.ayGunIcindeDegisiyor(Burc.koc, Burc.balik),
        HaritaMetinleri.yukselenIcinBilgiEksik,
      ]);
    });

    test('Yükselen sınırda ve saat dilimi belirsiz: alternatif Yükselen, '
        'iki not sırayla', () {
      // Yükselen 239° (Akrep sonu → Yay).
      const DogumHaritasi h = DogumHaritasi(
        gunesBoylami: 355,
        ayBoylami: 100,
        ayBurcu: Burc.yengec,
        ayBurcuKesin: true,
        yukselenBoylami: 239,
      );
      final HaritaOkumasi o = haritaOkumasi(
        harita: h,
        saatBiliniyor: true,
        konumBiliniyor: true,
        saatDilimiKesin: false,
      );
      expect(o.bolumler.map((HaritaBolumu b) => b.baslik), <String>[
        'Ay burcun · Yengeç',
        'Yükselenin · Akrep',
        'Yükselenin Yay ise',
      ]);
      expect(o.notlar, <String>[
        HaritaMetinleri.saatDilimiBelirsiz,
        HaritaMetinleri.yukselenSinirda(Burc.akrep, Burc.yay),
      ]);
    });

    test('saat biliniyor ama Ay sınırda: "sınırda" notu', () {
      const DogumHaritasi h = DogumHaritasi(
        gunesBoylami: 355,
        ayBoylami: 89.8,
        ayBurcu: Burc.ikizler,
        ayBurcuKesin: false,
        yukselenBoylami: 200,
      );
      final HaritaOkumasi o = haritaOkumasi(
        harita: h,
        saatBiliniyor: true,
        konumBiliniyor: true,
      );
      expect(
        o.notlar.first,
        HaritaMetinleri.aySinirda(Burc.ikizler, Burc.yengec),
      );
    });

    test('gerçek hesaplarla geniş tarama: her harita okunur, yer tutucu '
        'kalmaz', () {
      final Il ankara = TurkiyeIlleri.plakadan(6)!;
      for (int i = 0; i < 300; i++) {
        final DateTime d = DateTime(
          1980,
          1,
          1,
          6,
        ).add(Duration(days: i * 41, hours: i % 24));
        final SaatDilimiSonucu dilim = TurkiyeSaatDilimi.utcFarki(d);
        final HaritaOkumasi o = haritaOkumasi(
          harita: DogumHaritasi.hesapla(
            yerelDogum: d,
            utcFarkiSaat: dilim.farkSaat.toDouble(),
            saatBiliniyor: true,
            enlem: ankara.enlem,
            boylam: ankara.boylam,
          ),
          saatBiliniyor: true,
          konumBiliniyor: true,
          saatDilimiKesin: dilim.kesin,
        );
        expect(o.yukselen, isNotNull);
        for (final HaritaBolumu b in o.bolumler) {
          expect(b.metin.contains('{'), isFalse);
        }
      }
    });
  });
}
