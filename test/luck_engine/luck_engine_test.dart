import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );
  final DateTime gun = DateTime(2026, 7, 6);

  group('determinizm (CLAUDE.md kural 8)', () {
    test('aynı (kullanıcı, gün) çifti aynı sonucu üretir', () {
      final LuckResult a = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult b = motor.hesapla(kullanici: turan, gun: gun);

      expect(a.genelSkor, b.genelSkor);
      expect(a.kategoriSkorlari, b.kategoriSkorlari);
      expect(a.modifiyerler, b.modifiyerler);
    });

    test('günün saati sonucu değiştirmez (yyyy-MM-dd anahtarı)', () {
      final LuckResult sabah = motor.hesapla(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 8, 30),
      );
      final LuckResult aksam = motor.hesapla(
        kullanici: turan,
        gun: DateTime(2026, 7, 6, 23, 59),
      );
      expect(sabah.genelSkor, aksam.genelSkor);
      expect(sabah.kategoriSkorlari, aksam.kategoriSkorlari);
    });

    test('isim normalizasyonu: "Turan " ile "turan" aynı kullanıcıdır', () {
      final UserSeed a = UserSeed.fromIsim(
        isim: 'Turan ',
        dogumTarihi: DateTime(1990, 5, 15),
      );
      expect(a.isimHash, turan.isimHash);
    });
  });

  group('motor golden regresyonu (Kader 2.0 Faz 0)', () {
    test('beş sabit kullanıcı/gün örneğinin tüm skorları değişmez', () {
      final goldenlar =
          <
            ({
              String isim,
              DateTime dogumTarihi,
              DateTime gun,
              int genelSkor,
              Map<LuckCategory, int> kategoriSkorlari,
            })
          >[
            (
              isim: 'Turan',
              dogumTarihi: DateTime(1990, 5, 15),
              gun: DateTime(2026, 7, 6),
              genelSkor: 62,
              kategoriSkorlari: const <LuckCategory, int>{
                LuckCategory.ask: 78,
                LuckCategory.para: 53,
                LuckCategory.saglik: 75,
                LuckCategory.risk: 49,
                LuckCategory.sosyal: 46,
              },
            ),
            (
              isim: 'Ayşe',
              dogumTarihi: DateTime(1988, 11, 2),
              gun: DateTime(2026, 1, 1),
              genelSkor: 55,
              kategoriSkorlari: const <LuckCategory, int>{
                LuckCategory.ask: 58,
                LuckCategory.para: 70,
                LuckCategory.saglik: 47,
                LuckCategory.risk: 47,
                LuckCategory.sosyal: 47,
              },
            ),
            (
              isim: 'Deniz',
              dogumTarihi: DateTime(2000, 2, 29),
              gun: DateTime(2024, 2, 29),
              genelSkor: 72,
              kategoriSkorlari: const <LuckCategory, int>{
                LuckCategory.ask: 58,
                LuckCategory.para: 79,
                LuckCategory.saglik: 74,
                LuckCategory.risk: 69,
                LuckCategory.sosyal: 83,
              },
            ),
            (
              isim: 'Misafir',
              dogumTarihi: DateTime(2000),
              gun: DateTime(2030, 12, 31),
              genelSkor: 64,
              kategoriSkorlari: const <LuckCategory, int>{
                LuckCategory.ask: 60,
                LuckCategory.para: 89,
                LuckCategory.saglik: 78,
                LuckCategory.risk: 39,
                LuckCategory.sosyal: 37,
              },
            ),
            (
              isim: 'Alex',
              dogumTarihi: DateTime(1975, 8, 23),
              gun: DateTime(2027, 3, 14),
              genelSkor: 52,
              kategoriSkorlari: const <LuckCategory, int>{
                LuckCategory.ask: 37,
                LuckCategory.para: 70,
                LuckCategory.saglik: 60,
                LuckCategory.risk: 40,
                LuckCategory.sosyal: 47,
              },
            ),
          ];

      for (final golden in goldenlar) {
        final LuckResult sonuc = motor.hesapla(
          kullanici: UserSeed.fromIsim(
            isim: golden.isim,
            dogumTarihi: golden.dogumTarihi,
          ),
          gun: golden.gun,
        );
        final String neden = '${golden.isim} / ${golden.gun} değişti';
        expect(sonuc.genelSkor, golden.genelSkor, reason: neden);
        expect(sonuc.kategoriSkorlari, golden.kategoriSkorlari, reason: neden);
      }
    });
  });

  group('kullanıcıya özgülük', () {
    test('farklı isim farklı skor üretir', () {
      final UserSeed ayse = UserSeed.fromIsim(
        isim: 'Ayşe',
        dogumTarihi: DateTime(1990, 5, 15),
      );
      final LuckResult a = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult b = motor.hesapla(kullanici: ayse, gun: gun);
      expect(a.kategoriSkorlari, isNot(equals(b.kategoriSkorlari)));
    });

    test('farklı doğum tarihi farklı skor üretir', () {
      final UserSeed digerTuran = UserSeed.fromIsim(
        isim: 'Turan',
        dogumTarihi: DateTime(1991, 5, 15),
      );
      final LuckResult a = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult b = motor.hesapla(kullanici: digerTuran, gun: gun);
      expect(a.kategoriSkorlari, isNot(equals(b.kategoriSkorlari)));
    });

    test('farklı gün farklı skor üretir', () {
      final LuckResult a = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult b = motor.hesapla(
        kullanici: turan,
        gun: DateTime(2026, 7, 7),
      );
      expect(a.kategoriSkorlari, isNot(equals(b.kategoriSkorlari)));
    });
  });

  group('sonuç yapısı', () {
    test('5 kategori de 0-100 aralığında skorlanır', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      expect(sonuc.kategoriSkorlari.keys, LuckCategory.values);
      for (final int skor in sonuc.kategoriSkorlari.values) {
        expect(
          skor,
          inInclusiveRange(EngineConfig.skorMin, EngineConfig.skorMaks),
        );
      }
      expect(
        sonuc.genelSkor,
        inInclusiveRange(EngineConfig.skorMin, EngineConfig.skorMaks),
      );
    });

    test('kategori ağırlıkları toplamı 1.0', () {
      final double toplam = LuckCategory.values.fold(
        0,
        (double t, LuckCategory k) => t + k.agirlik,
      );
      expect(toplam, closeTo(1.0, 1e-9));
    });

    test('ay evresi ve numeroloji modifiyerleri her zaman raporlanır', () {
      final LuckResult sonuc = motor.hesapla(kullanici: turan, gun: gun);
      final List<String> adlar = sonuc.modifiyerler
          .map((LuckModifier m) => m.ad)
          .toList();
      expect(adlar, containsAll(<String>[ayEvresiAdi, numerolojiAdi]));
    });

    test('100 günde genel skor daima 0-100 içinde kalır', () {
      for (int i = 0; i < 100; i++) {
        final LuckResult sonuc = motor.hesapla(
          kullanici: turan,
          gun: gun.add(Duration(days: i)),
        );
        expect(
          sonuc.genelSkor,
          inInclusiveRange(EngineConfig.skorMin, EngineConfig.skorMaks),
        );
      }
    });
  });

  group('seri dengesi bias\'ı (plan madde 6)', () {
    const List<int> dusukGecmis = <int>[30, 35, 40]; // ortalama 35 < 45
    const List<int> normalGecmis = <int>[60, 55, 70]; // ortalama 61.7

    test('düşük geçmişte +5..+10 bias modifiyeri eklenir', () {
      final LuckResult sonuc = motor.hesapla(
        kullanici: turan,
        gun: gun,
        sonUcGunSkorlari: dusukGecmis,
      );
      final LuckModifier bias = sonuc.modifiyerler.firstWhere(
        (LuckModifier m) => m.ad == seriDengesiAdi,
      );
      expect(
        bias.etki,
        inInclusiveRange(EngineConfig.seriBiasMin, EngineConfig.seriBiasMaks),
      );
    });

    test('düşük geçmiş skoru yükseltir', () {
      final LuckResult biassiz = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult biasli = motor.hesapla(
        kullanici: turan,
        gun: gun,
        sonUcGunSkorlari: dusukGecmis,
      );
      expect(biasli.genelSkor, greaterThan(biassiz.genelSkor));
    });

    test('normal geçmişte bias uygulanmaz ve skor değişmez', () {
      final LuckResult biassiz = motor.hesapla(kullanici: turan, gun: gun);
      final LuckResult normalli = motor.hesapla(
        kullanici: turan,
        gun: gun,
        sonUcGunSkorlari: normalGecmis,
      );
      expect(
        normalli.modifiyerler.any((LuckModifier m) => m.ad == seriDengesiAdi),
        isFalse,
      );
      expect(normalli.genelSkor, biassiz.genelSkor);
    });

    test('bias deterministiktir: aynı girdi aynı bias', () {
      final LuckResult a = motor.hesapla(
        kullanici: turan,
        gun: gun,
        sonUcGunSkorlari: dusukGecmis,
      );
      final LuckResult b = motor.hesapla(
        kullanici: turan,
        gun: gun,
        sonUcGunSkorlari: dusukGecmis,
      );
      expect(a.modifiyerler, b.modifiyerler);
      expect(a.genelSkor, b.genelSkor);
    });
  });
}
