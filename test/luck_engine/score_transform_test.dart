import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('sekillendir', () {
    test('10.000 örnekte değerlerin %90+ kısmı 40-85 bandında', () {
      final Random rnd = Random(42);
      const int ornekSayisi = 10000;

      int bantIci = 0;
      int altUc = 0;
      int ustUc = 0;
      for (int i = 0; i < ornekSayisi; i++) {
        final int skor = sekillendir(rnd.nextDouble());
        if (skor >= EngineConfig.bandAlt && skor <= EngineConfig.bandUst) {
          bantIci++;
        }
        if (skor < EngineConfig.ucAltSinir) {
          altUc++;
        }
        if (skor > EngineConfig.ucUstSinir) {
          ustUc++;
        }
      }

      expect(bantIci, greaterThanOrEqualTo((ornekSayisi * 0.9).round()));
      // Uçlar nadir ama var olmalı (her biri ~%1.5 beklenir).
      expect(altUc, greaterThan(0));
      expect(ustUc, greaterThan(0));
      expect(altUc + ustUc, lessThan((ornekSayisi * 0.05).round()));
    });

    test('sınır girdilerde 0-100 aralığında kalır', () {
      expect(sekillendir(0), inInclusiveRange(0, 100));
      expect(sekillendir(0.999999), inInclusiveRange(0, 100));
      expect(sekillendir(0.5), inInclusiveRange(40, 85));
    });

    test('deterministiktir: aynı girdi aynı çıktıyı verir', () {
      for (final double ham in <double>[0.001, 0.2, 0.5, 0.8, 0.99]) {
        expect(sekillendir(ham), sekillendir(ham));
      }
    });

    test('monotoniktir: daha yüksek ham değer daha düşük skor üretmez', () {
      int onceki = sekillendir(0);
      for (double ham = 0.001; ham < 1; ham += 0.001) {
        final int simdiki = sekillendir(ham);
        expect(simdiki, greaterThanOrEqualTo(onceki));
        onceki = simdiki;
      }
    });
  });
}
