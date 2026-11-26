import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/luck_result_mapper.dart';

/// K8-1 (26 Kasım 2026 kararı): günün gökyüzü kişinin yerel takvim gününden
/// ve açık bir UTC farkından hesaplanır; makinenin saat dilimi sonucu
/// etkilemez. Kural 8: aynı (kullanıcı, yerel gün, UTC farkı) aynı sonuç.
void main() {
  const int turkiye = EngineConfig.varsayilanUtcFarkiDakika;
  const int newYork = -300;
  const int tokyo = 540;

  group('yerelGunAni', () {
    test('Türkiye gece yarısı bir önceki günün 21:00 UTC anıdır', () {
      expect(
        yerelGunAni(DateTime(2026, 11, 26)),
        DateTime.utc(2026, 11, 25, 21),
      );
    });

    test('Türkiye öğleni 09:00 UTC: eski Ay burcu anıyla aynı', () {
      expect(
        yerelGunAni(
          DateTime(2026, 11, 26),
          saat: EngineConfig.gununAyBurcuYerelSaati,
        ),
        DateTime.utc(2026, 11, 26, 9),
      );
    });

    test('UTC farkı negatifse an ileri kayar', () {
      expect(
        yerelGunAni(DateTime(2026, 11, 26), utcFarkiDakika: newYork),
        DateTime.utc(2026, 11, 26, 5),
      );
    });

    test('günün saati ve DateTime türü (yerel/UTC) sonucu değiştirmez', () {
      final DateTime beklenen = yerelGunAni(DateTime(2026, 3, 29));
      expect(yerelGunAni(DateTime(2026, 3, 29, 23, 59)), beklenen);
      expect(yerelGunAni(DateTime.utc(2026, 3, 29, 14)), beklenen);
    });
  });

  group('AyEvresi.gunun', () {
    test('varsayılan fark Türkiye gece yarısındaki evredir', () {
      for (int i = 0; i < 60; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        expect(
          AyEvresi.gunun(gun),
          AyEvresi.bul(DateTime.utc(2026, 1, i, 21)),
          reason: '$gun',
        );
      }
    });

    test('UTC farkı kullanılır: farklı dilimlerde bazı günler değişir', () {
      int farkliGun = 0;
      for (int i = 0; i < 365; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        if (AyEvresi.gunun(gun, utcFarkiDakika: newYork) !=
            AyEvresi.gunun(gun, utcFarkiDakika: tokyo)) {
          farkliGun++;
        }
      }
      // 14 saatlik fark: evre dilimi ~3,7 gün, yani günlerin kabaca
      // altıda biri sınırı geçer. Hiç fark yoksa parametre okunmuyordur.
      expect(farkliGun, greaterThan(0));
      expect(farkliGun, lessThan(365 ~/ 2));
    });
  });

  group('Astronomi.gununAyBurcu', () {
    test('varsayılan fark 09:00 UTC anındaki Ay burcudur', () {
      for (int i = 0; i < 60; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        final double jd = Astronomi.julyenGunu(DateTime.utc(2026, 1, 1 + i, 9));
        expect(
          Astronomi.gununAyBurcu(gun),
          Astronomi.burc(Astronomi.ayBoylami(jd)),
          reason: '$gun',
        );
      }
    });

    test('UTC farkı kullanılır: farklı dilimlerde bazı günler değişir', () {
      int farkliGun = 0;
      for (int i = 0; i < 365; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        if (Astronomi.gununAyBurcu(gun, utcFarkiDakika: newYork) !=
            Astronomi.gununAyBurcu(gun, utcFarkiDakika: tokyo)) {
          farkliGun++;
        }
      }
      // Ay bir burçta ~2,5 gün kalır; 14 saatte günlerin ~%23'ü değişir.
      expect(farkliGun, greaterThan(0));
      expect(farkliGun, lessThan(365 ~/ 2));
    });
  });

  group('LuckEngine.hesapla ve UTC farkı', () {
    const LuckEngine motor = LuckEngine();
    final UserSeed kisi = UserSeed.fromIsim(
      isim: 'Turan',
      dogumTarihi: DateTime(1990, 5, 15),
    );

    test('varsayılan fark açıkça Türkiye vermekle aynıdır', () {
      final DateTime gun = DateTime(2026, 11, 26);
      final LuckResult a = motor.hesapla(kullanici: kisi, gun: gun);
      final LuckResult b = motor.hesapla(
        kullanici: kisi,
        gun: gun,
        utcFarkiDakika: turkiye,
      );
      expect(a.genelSkor, b.genelSkor);
      expect(a.kategoriSkorlari, b.kategoriSkorlari);
      expect(a.modifiyerler, b.modifiyerler);
      expect(a.utcFarkiDakika, turkiye);
    });

    test('aynı (kullanıcı, yerel gün, UTC farkı) aynı sonucu verir', () {
      final DateTime gun = DateTime(2026, 11, 26);
      final LuckResult a = motor.hesapla(
        kullanici: kisi,
        gun: gun,
        utcFarkiDakika: newYork,
      );
      final LuckResult b = motor.hesapla(
        kullanici: kisi,
        gun: DateTime(2026, 11, 26, 22, 30),
        utcFarkiDakika: newYork,
      );
      expect(a.genelSkor, b.genelSkor);
      expect(a.kategoriSkorlari, b.kategoriSkorlari);
      expect(a.modifiyerler, b.modifiyerler);
      expect(a.utcFarkiDakika, newYork);
    });

    test('ay evresi modifiyeri sonucun UTC farkındaki evreden gelir', () {
      for (int i = 0; i < 40; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        final LuckResult sonuc = motor.hesapla(
          kullanici: kisi,
          gun: gun,
          utcFarkiDakika: tokyo,
        );
        final LuckModifier ay = sonuc.modifiyerler.firstWhere(
          (LuckModifier m) => m.ad == ayEvresiAdi,
        );
        expect(
          ay,
          ayEvresiModifiyeri(yerelGunAni(gun, utcFarkiDakika: tokyo)),
          reason: '$gun',
        );
      }
    });
  });

  group('LuckResultMapper ve UTC farkı', () {
    const LuckEngine motor = LuckEngine();
    final UserSeed kisi = UserSeed.fromIsim(
      isim: 'Turan',
      dogumTarihi: DateTime(1990, 5, 15),
    );

    test('UTC farkı kayıttan kayıpsız döner', () {
      final LuckResult sonuc = motor.hesapla(
        kullanici: kisi,
        gun: DateTime(2026, 11, 26),
        utcFarkiDakika: newYork,
      );
      final LuckResult okunan = LuckResultMapper.fromMap(
        LuckResultMapper.toMap(sonuc),
      );
      expect(okunan.utcFarkiDakika, newYork);
    });

    test('alanı olmayan eski kayıt Türkiye saati sayılır', () {
      final LuckResult sonuc = motor.hesapla(
        kullanici: kisi,
        gun: DateTime(2026, 11, 26),
        utcFarkiDakika: tokyo,
      );
      final Map<String, dynamic> eski = LuckResultMapper.toMap(sonuc)
        ..remove('utcFarkiDakika');
      expect(LuckResultMapper.fromMap(eski).utcFarkiDakika, turkiye);
    });
  });
}
