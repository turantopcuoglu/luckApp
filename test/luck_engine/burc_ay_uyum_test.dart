import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('Burc', () {
    test('sınır tarihleri doğru burca düşer', () {
      final Map<DateTime, Burc> beklenen = <DateTime, Burc>{
        DateTime(1994, 3, 14): Burc.balik,
        DateTime(1994, 3, 20): Burc.balik,
        DateTime(1994, 3, 21): Burc.koc,
        DateTime(1990, 1, 1): Burc.oglak,
        DateTime(1990, 1, 19): Burc.oglak,
        DateTime(1990, 1, 20): Burc.kova,
        DateTime(1990, 12, 21): Burc.yay,
        DateTime(1990, 12, 22): Burc.oglak,
        DateTime(1990, 7, 23): Burc.aslan,
        DateTime(1990, 8, 22): Burc.aslan,
        DateTime(1990, 8, 23): Burc.basak,
      };
      beklenen.forEach((DateTime tarih, Burc burc) {
        expect(Burc.dogumTarihinden(tarih), burc, reason: '$tarih');
      });
    });

    test('yılın her günü tam bir burca düşer ve 12 burç da görülür', () {
      final Set<Burc> gorulen = <Burc>{};
      for (int i = 0; i < 366; i++) {
        gorulen.add(Burc.dogumTarihinden(DateTime(2000, 1, 1 + i)));
      }
      expect(gorulen, Burc.values.toSet());
    });

    test('sınır günü: başlangıç günü ve bir önceki gün', () {
      expect(Burc.sinirGunuMu(DateTime(1994, 3, 21)), isTrue);
      expect(Burc.sinirGunuMu(DateTime(1994, 3, 20)), isTrue);
      expect(Burc.sinirGunuMu(DateTime(1994, 3, 14)), isFalse);
      expect(Burc.sinirGunuMu(DateTime(1994, 1, 19)), isTrue);
    });

    test('elementler üçer burçtan oluşur', () {
      for (final BurcElementi e in BurcElementi.values) {
        expect(
          Burc.values.where((Burc b) => b.element == e).length,
          3,
          reason: e.name,
        );
      }
    });
  });

  group('AyEvresi', () {
    test('referans yeniay anı yeni ay, yarım sinodik ay sonrası dolunay', () {
      expect(AyEvresi.bul(yeniayReferansi), AyEvresi.yeniAy);
      expect(
        AyEvresi.bul(yeniayReferansi.add(const Duration(days: 14, hours: 18))),
        AyEvresi.dolunay,
      );
    });

    test('bir sinodik ay boyunca sekiz evrenin hepsi sırayla görülür', () {
      final List<AyEvresi> sira = <AyEvresi>[];
      for (int saat = 0; saat < 27 * 24; saat += 6) {
        final AyEvresi e = AyEvresi.bul(
          yeniayReferansi.add(Duration(hours: saat)),
        );
        if (sira.isEmpty || sira.last != e) {
          sira.add(e);
        }
      }
      expect(sira, AyEvresi.values);
    });

    test('evre, ay evresi modifiyeriyle çelişmez (yeni ay ⇒ negatif)', () {
      for (int i = 0; i < 400; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        final AyEvresi e = AyEvresi.bul(gun);
        final int etki = ayEvresiModifiyeri(gun).etki;
        if (e == AyEvresi.yeniAy) {
          expect(etki, lessThan(0));
        }
        if (e == AyEvresi.dolunay) {
          expect(etki, greaterThan(0));
        }
      }
    });
  });

  group('gunNumerolojiSayisi', () {
    test('13.09.2026 → 5 ve modifiyer etkisi 0', () {
      expect(gunNumerolojiSayisi(DateTime(2026, 9, 13)), 5);
      expect(numerolojiModifiyeri(DateTime(2026, 9, 13)).etki, 0);
    });
  });

  group('uyumHesapla', () {
    KaderProfili p(DateTime d, [String? ad]) =>
        KaderProfili.hesapla(dogumTarihi: d, tamAd: ad);

    test('simetrik ve deterministik', () {
      final KaderProfili a = p(DateTime(1994, 3, 14), 'Ayşe');
      final KaderProfili b = p(DateTime(1990, 5, 15), 'Ali Veli');
      final UyumSonucu ab = uyumHesapla(a, b);
      final UyumSonucu ba = uyumHesapla(b, a);
      expect(ab.skor, ba.skor);
      expect(ab.derece, ba.derece);
      expect(uyumHesapla(a, b).skor, ab.skor);
    });

    test('skor her çift için 35-98 aralığında', () {
      for (int i = 0; i < 120; i++) {
        for (int j = 0; j < 12; j++) {
          final UyumSonucu s = uyumHesapla(
            p(DateTime(1980, 1, 1 + i * 3)),
            p(DateTime(1995, 1, 1 + j * 31)),
          );
          expect(
            s.skor,
            inInclusiveRange(EngineConfig.uyumMin, EngineConfig.uyumMaks),
          );
        }
      }
    });

    test('aynı yaşam yolu ayna, aynı element ayni', () {
      // İkisi de Balık (su) ve yaşam yolu 4.
      final UyumSonucu s = uyumHesapla(
        p(DateTime(1994, 3, 14)),
        p(DateTime(1994, 3, 14)),
      );
      expect(s.yasamYoluIliskisi, YasamYoluIliskisi.ayna);
      expect(s.elementIliskisi, ElementIliskisi.ayni);
      expect(s.ruhUyumlu, isNull);
    });

    test('ruh uyumu yalnızca iki tarafın da tam adı varsa hesaplanır', () {
      final UyumSonucu s = uyumHesapla(
        p(DateTime(1994, 3, 14), 'Ayşe'),
        p(DateTime(1990, 5, 15), 'Ali Veli'),
      );
      // Ayşe ruh 6, Ali Veli ruh 6 → aynı grup.
      expect(s.ruhUyumlu, isTrue);
    });

    test('uyum grupları geleneksel üçlüleri izler', () {
      expect(uyumGrubu(1), uyumGrubu(5));
      expect(uyumGrubu(5), uyumGrubu(7));
      expect(uyumGrubu(2), uyumGrubu(8));
      expect(uyumGrubu(3), uyumGrubu(9));
      expect(uyumGrubu(1), isNot(uyumGrubu(2)));
    });
  });

  group('donguselIndeks', () {
    const LuckEngine motor = LuckEngine();
    final UserSeed kullanici = UserSeed.fromIsim(
      isim: 'Ayşe',
      dogumTarihi: DateTime(1994, 3, 14),
    );

    test('bir döngü içinde tekrar yok, döngü tüm havuzu kapsar', () {
      const int boyut = 7;
      // Döngü başına hizalanmış ilk günü bul.
      DateTime gun = DateTime(2026, 9, 1);
      while (LuckEngine.gunNumarasi(gun) % boyut != 0) {
        gun = DateTime(gun.year, gun.month, gun.day + 1);
      }
      for (int dongu = 0; dongu < 10; dongu++) {
        final Set<int> gorulen = <int>{};
        for (int i = 0; i < boyut; i++) {
          gorulen.add(
            motor.donguselIndeks(
              kullanici: kullanici,
              gun: DateTime(gun.year, gun.month, gun.day + dongu * boyut + i),
              amac: 'test',
              havuzBoyutu: boyut,
            ),
          );
        }
        expect(gorulen.length, boyut, reason: 'döngü $dongu');
      }
    });

    test('deterministik ve saatten bağımsız', () {
      final int a = motor.donguselIndeks(
        kullanici: kullanici,
        gun: DateTime(2026, 9, 13, 1),
        amac: 'x',
        havuzBoyutu: 12,
      );
      final int b = motor.donguselIndeks(
        kullanici: kullanici,
        gun: DateTime(2026, 9, 13, 23, 59),
        amac: 'x',
        havuzBoyutu: 12,
      );
      expect(a, b);
    });

    test('havuz boyutu 1 her zaman 0, 0 hata fırlatır', () {
      expect(
        motor.donguselIndeks(
          kullanici: kullanici,
          gun: DateTime(2026, 9, 13),
          amac: 'x',
          havuzBoyutu: 1,
        ),
        0,
      );
      expect(
        () => motor.donguselIndeks(
          kullanici: kullanici,
          gun: DateTime(2026, 9, 13),
          amac: 'x',
          havuzBoyutu: 0,
        ),
        throwsArgumentError,
      );
    });

    test('referans öncesi tarihlerde de aralık içinde', () {
      for (int i = 0; i < 50; i++) {
        final int indeks = motor.donguselIndeks(
          kullanici: kullanici,
          gun: DateTime(1999, 12, 1 + i),
          amac: 'x',
          havuzBoyutu: 5,
        );
        expect(indeks, inInclusiveRange(0, 4));
      }
    });
  });
}
