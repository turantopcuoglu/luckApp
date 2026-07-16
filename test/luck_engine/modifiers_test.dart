import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('ayEvresiModifiyeri', () {
    test('referans yeniay gününde etki -8', () {
      final LuckModifier m = ayEvresiModifiyeri(
        DateTime.utc(2000, 1, 6, 18, 14),
      );
      expect(m.ad, ayEvresiAdi);
      expect(m.etki, -EngineConfig.modifiyerMaksEtki);
    });

    test('dolunayda (yarım sinodik ay sonra) etki +8', () {
      // Referans yeniay + 14.77 gün ≈ dolunay.
      final DateTime dolunay = DateTime.utc(
        2000,
        1,
        6,
        18,
        14,
      ).add(const Duration(days: 14, hours: 18));
      expect(ayEvresiModifiyeri(dolunay).etki, EngineConfig.modifiyerMaksEtki);
    });

    test('1000 gün boyunca etki -8..+8 aralığında ve deterministik', () {
      final DateTime baslangic = DateTime(2026, 1, 1);
      for (int i = 0; i < 1000; i++) {
        final DateTime gun = baslangic.add(Duration(days: i));
        final LuckModifier m = ayEvresiModifiyeri(gun);
        expect(
          m.etki,
          inInclusiveRange(
            -EngineConfig.modifiyerMaksEtki,
            EngineConfig.modifiyerMaksEtki,
          ),
        );
        expect(m, ayEvresiModifiyeri(gun));
      }
    });

    test('referanstan önceki tarihlerde de geçerli evre üretir', () {
      final LuckModifier m = ayEvresiModifiyeri(DateTime(1990, 5, 15));
      expect(
        m.etki,
        inInclusiveRange(
          -EngineConfig.modifiyerMaksEtki,
          EngineConfig.modifiyerMaksEtki,
        ),
      );
    });
  });

  group('numerolojiModifiyeri', () {
    test('rakam toplamı 5 olan gün nötr (0) etki verir', () {
      // 2026-07-06 → 2+0+2+6+0+7+0+6 = 23 → 2+3 = 5 → etki 0.
      final LuckModifier m = numerolojiModifiyeri(DateTime(2026, 7, 6));
      expect(m.ad, numerolojiAdi);
      expect(m.etki, 0);
    });

    test('uç haneler -8 ve +8 üretir', () {
      // 2026-07-02 → toplam 19 → 10 → 1 → etki -8.
      expect(numerolojiModifiyeri(DateTime(2026, 7, 2)).etki, -8);
      // 2026-07-01 → toplam 18 → 9 → etki +8.
      expect(numerolojiModifiyeri(DateTime(2026, 7, 1)).etki, 8);
    });

    test('1000 gün boyunca etki -8..+8 aralığında', () {
      final DateTime baslangic = DateTime(2026, 1, 1);
      for (int i = 0; i < 1000; i++) {
        final int etki = numerolojiModifiyeri(
          baslangic.add(Duration(days: i)),
        ).etki;
        expect(
          etki,
          inInclusiveRange(
            -EngineConfig.modifiyerMaksEtki,
            EngineConfig.modifiyerMaksEtki,
          ),
        );
      }
    });
  });
}
