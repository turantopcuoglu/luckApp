import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  // 14.03.1994 → ay 3, gün 5, yıl 23→5; yaşam yolu 3+5+5 = 13 → 4.
  final DateTime ayseDogum = DateTime(1994, 3, 14);
  const String ayseAd = 'Ayşe Yılmaz';

  group('indirgeme zinciri ve karmik borç sayısı', () {
    test('zincir usta sayıda durur, tek hanede biter', () {
      expect(DerinNumeroloji.indirgemeZinciri(49), <int>[49, 13, 4]);
      expect(DerinNumeroloji.indirgemeZinciri(29), <int>[29, 11]);
      expect(DerinNumeroloji.indirgemeZinciri(7), <int>[7]);
      expect(DerinNumeroloji.indirgemeZinciri(199), <int>[199, 19, 10, 1]);
    });

    test('zincirdeki ilk karmik sayı bulunur', () {
      expect(DerinNumeroloji.karmikBorcSayisi(49), 13);
      expect(DerinNumeroloji.karmikBorcSayisi(14), 14);
      expect(DerinNumeroloji.karmikBorcSayisi(199), 19);
      expect(DerinNumeroloji.karmikBorcSayisi(46), isNull);
      expect(DerinNumeroloji.karmikBorcSayisi(29), isNull);
    });
  });

  group('karmik borçlar', () {
    test('Ayşe Yılmaz 14.03.1994: yaşam yolu 13, doğum günü 14, ruh 16', () {
      // Ruh: a + e + ı + a = 1 + 5 + 9 + 1 = 16. İsim: 46 → 10 → 1 (yok).
      // Kişilik: y + ş + y + l + m + z = 7+1+7+3+4+8 = 30 → 3 (yok).
      expect(DerinNumeroloji.karmikBorclar(ayseDogum, ayseAd), <KarmikBorc>[
        const KarmikBorc(sayi: 13, kaynak: KarmikKaynak.yasamYolu),
        const KarmikBorc(sayi: 14, kaynak: KarmikKaynak.dogumGunu),
        const KarmikBorc(sayi: 16, kaynak: KarmikKaynak.ruh),
      ]);
    });

    test('13.07.1985: yaşam yolu toplamı 16, doğum günü 13', () {
      // 7 + (1+3) + (1+9+8+5=23→5) = 16 → 7.
      final List<KarmikBorc> b = DerinNumeroloji.karmikBorclar(
        DateTime(1985, 7, 13),
        null,
      );
      expect(b, <KarmikBorc>[
        const KarmikBorc(sayi: 16, kaynak: KarmikKaynak.yasamYolu),
        const KarmikBorc(sayi: 13, kaynak: KarmikKaynak.dogumGunu),
      ]);
    });

    test('ad yoksa yalnızca tarih kaynakları değerlendirilir', () {
      // 09.02.1990 → 2 + 9 + 1 = 12: karmik borç yok.
      expect(DerinNumeroloji.karmikBorclar(DateTime(1990, 2, 9), ''), isEmpty);
    });
  });

  group('isim dağılımı', () {
    test('Ayşe Yılmaz: sayı dağılımı, karmik dersler, gizli tutku', () {
      // A1 Y7 Ş1 E5 Y7 I9 L3 M4 A1 Z8.
      expect(DerinNumeroloji.sayiDagilimi(ayseAd), <int, int>{
        1: 3,
        2: 0,
        3: 1,
        4: 1,
        5: 1,
        6: 0,
        7: 2,
        8: 1,
        9: 1,
      });
      expect(DerinNumeroloji.karmikDersler(ayseAd), <int>[2, 6]);
      expect(DerinNumeroloji.gizliTutku(ayseAd), <int>[1]);
    });

    test('eşitlikte gizli tutku tüm sayıları döndürür', () {
      // A1 B2 → her ikisi birer kez.
      expect(DerinNumeroloji.gizliTutku('Ab'), <int>[1, 2]);
    });

    test('harf yoksa isim tabanlı sonuçlar null', () {
      for (final String ad in <String>['', '  ', "-'"]) {
        expect(DerinNumeroloji.sayiDagilimi(ad), isNull, reason: ad);
        expect(DerinNumeroloji.karmikDersler(ad), isNull, reason: ad);
        expect(DerinNumeroloji.gizliTutku(ad), isNull, reason: ad);
        expect(DerinNumeroloji.temelTasi(ad), isNull, reason: ad);
        expect(DerinNumeroloji.tepeTasi(ad), isNull, reason: ad);
        expect(DerinNumeroloji.dengeSayisi(ad), isNull, reason: ad);
        expect(DerinNumeroloji.olgunlukSayisi(ayseDogum, ad), isNull);
      }
    });
  });

  group('olgunluk, temel taşı, tepe taşı, denge', () {
    test('Ayşe Yılmaz: olgunluk 4 + 1 = 5, temel A, tepe E, denge 8', () {
      expect(DerinNumeroloji.olgunlukSayisi(ayseDogum, ayseAd), 5);
      expect(
        DerinNumeroloji.temelTasi(ayseAd),
        const HarfBilgisi(harf: 'A', deger: 1),
      );
      expect(
        DerinNumeroloji.tepeTasi(ayseAd),
        const HarfBilgisi(harf: 'E', deger: 5),
      );
      // A(1) + Y(7) = 8.
      expect(DerinNumeroloji.dengeSayisi(ayseAd), 8);
    });

    test('Türkçe büyük harf ve tireli adlar', () {
      expect(DerinNumeroloji.temelTasi('ilknur şahin')!.harf, 'İ');
      expect(DerinNumeroloji.temelTasi('ılgın')!.harf, 'I');
      // Ali-Rıza Kaya: kelimeler Ali, Rıza, Kaya; tepe taşı Ali'nin i'si.
      expect(
        DerinNumeroloji.tepeTasi('Ali-Rıza Kaya'),
        const HarfBilgisi(harf: 'İ', deger: 9),
      );
      // A(1) + R(9) + K(2) = 12 → 3.
      expect(DerinNumeroloji.dengeSayisi('Ali-Rıza Kaya'), 3);
    });
  });

  group('yaşam dönemleri', () {
    test('14.03.1994: zirveler 8,1,9,8; zorluklar 2,0,2,2; yaşlar', () {
      final List<YasamDonemi> d = DerinNumeroloji.yasamDonemleri(ayseDogum);
      expect(d.map((YasamDonemi x) => x.zirve), <int>[8, 1, 9, 8]);
      expect(d.map((YasamDonemi x) => x.zorluk), <int>[2, 0, 2, 2]);
      expect(d.map((YasamDonemi x) => x.sira), <int>[1, 2, 3, 4]);
      // İlk dönem 36 − 4 = 32 yaşa kadar, sonra dokuzar yıl.
      expect(d.map((YasamDonemi x) => x.baslangicYasi), <int>[0, 32, 41, 50]);
      expect(d.map((YasamDonemi x) => x.bitisYasi), <int?>[32, 41, 50, null]);
    });

    test('usta zirve korunur, 3. zirvede taban değeriyle toplanır', () {
      // 09.02.1990 → A=2, G=9, Y=19→1; Z1 = 11, Z2 = 10→1, Z3 = 2+1 = 3,
      // Z4 = 3. Zorluklar: 7, 8, 1, 1. Yaşam yolu 12 → 3, ilk bitiş 33.
      final List<YasamDonemi> d = DerinNumeroloji.yasamDonemleri(
        DateTime(1990, 2, 9),
      );
      expect(d.map((YasamDonemi x) => x.zirve), <int>[11, 1, 3, 3]);
      expect(d.map((YasamDonemi x) => x.zorluk), <int>[7, 8, 1, 1]);
      expect(d.first.bitisYasi, 33);
    });

    test('usta yaşam yolunda ilk dönem taban sayıyla hesaplanır', () {
      // Yaşam yolu 11 olan bir tarih bul: ilk dönem 36 − 2 = 34'te biter.
      DateTime t = DateTime(1980);
      while (Numeroloji.yasamYolu(t).deger != 11) {
        t = t.add(const Duration(days: 1));
      }
      expect(DerinNumeroloji.yasamDonemleri(t).first.bitisYasi, 34);
    });

    test('dönemler kesintisiz ve her yaş tek bir döneme düşer', () {
      for (int i = 0; i < 400; i++) {
        final DateTime t = DateTime(1950, 1, 1 + i * 53);
        final List<YasamDonemi> d = DerinNumeroloji.yasamDonemleri(t);
        for (int k = 1; k < d.length; k++) {
          expect(d[k].baslangicYasi, d[k - 1].bitisYasi);
        }
        for (final YasamDonemi x in d) {
          expect(x.zorluk, inInclusiveRange(0, 8));
          expect(
            x.zirve <= EngineConfig.numerolojiTabani ||
                EngineConfig.ustaSayilar.contains(x.zirve),
            isTrue,
          );
        }
        for (int yas = 0; yas < 100; yas++) {
          expect(
            d.where((YasamDonemi x) => x.kapsar(yas)).length,
            1,
            reason: '$t yaş $yas',
          );
        }
      }
    });
  });

  group('yaş ve yıl takvimi', () {
    test('tam yaş doğum gününde artar', () {
      expect(DerinNumeroloji.tamYas(ayseDogum, DateTime(2026, 3, 13)), 31);
      expect(DerinNumeroloji.tamYas(ayseDogum, DateTime(2026, 3, 14)), 32);
      expect(DerinNumeroloji.tamYas(ayseDogum, DateTime(1990)), 0);
    });

    test('kişisel aylar: 14.03 doğumlu, 2026 (kişisel yıl 9)', () {
      expect(DerinNumeroloji.kisiselAylar(ayseDogum, 2026), <int>[
        1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, //
      ]);
    });
  });

  group('NumerolojiRaporu', () {
    test('hesapla tüm alanları doldurur ve deterministiktir', () {
      final NumerolojiRaporu a = NumerolojiRaporu.hesapla(
        dogumTarihi: DateTime(1994, 3, 14, 17, 45),
        tamAd: ayseAd,
      );
      final NumerolojiRaporu b = NumerolojiRaporu.hesapla(
        dogumTarihi: ayseDogum,
        tamAd: ayseAd,
      );
      expect(a.dogumTarihi, ayseDogum);
      expect(a.donemler.map((YasamDonemi x) => x.zirve), <int>[8, 1, 9, 8]);
      expect(a.karmikBorclar, b.karmikBorclar);
      expect(a.olgunluk, 5);
      expect(a.karmikDersler, <int>[2, 6]);
      expect(a.gizliTutku, <int>[1]);
      expect(a.temelTasi, b.temelTasi);
      expect(a.tepeTasi, b.tepeTasi);
      expect(a.dengeSayisi, 8);
    });

    test('ad yoksa isim alanları null, tarih alanları dolu', () {
      final NumerolojiRaporu r = NumerolojiRaporu.hesapla(
        dogumTarihi: ayseDogum,
      );
      expect(r.donemler, hasLength(EngineConfig.zirveDonemSayisi));
      expect(r.karmikBorclar.map((KarmikBorc k) => k.kaynak), <KarmikKaynak>[
        KarmikKaynak.yasamYolu,
        KarmikKaynak.dogumGunu,
      ]);
      expect(r.olgunluk, isNull);
      expect(r.karmikDersler, isNull);
      expect(r.gizliTutku, isNull);
      expect(r.temelTasi, isNull);
      expect(r.tepeTasi, isNull);
      expect(r.dengeSayisi, isNull);
    });

    test('aktif dönem yaşa göre seçilir', () {
      final NumerolojiRaporu r = NumerolojiRaporu.hesapla(
        dogumTarihi: ayseDogum,
      );
      expect(r.aktifDonem(DateTime(2026, 3, 13)).sira, 1);
      expect(r.aktifDonem(DateTime(2026, 3, 14)).sira, 2);
      expect(r.aktifDonem(DateTime(2060)).sira, 4);
    });
  });
}
