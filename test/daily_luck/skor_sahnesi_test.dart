import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/features/daily_luck/skor_sahnesi.dart';

void main() {
  group('SkorSahnesi.skordan', () {
    test('bant sınırlarında doğru sahneyi seçer', () {
      expect(SkorSahnesi.skordan(0), SkorSahnesi.dusuk);
      expect(
        SkorSahnesi.skordan(ContentConfig.dusukEsik - 1),
        SkorSahnesi.dusuk,
      );
      expect(SkorSahnesi.skordan(ContentConfig.dusukEsik), SkorSahnesi.orta);
      expect(
        SkorSahnesi.skordan(ContentConfig.ortaEsik - 1),
        SkorSahnesi.orta,
      );
      expect(SkorSahnesi.skordan(ContentConfig.ortaEsik), SkorSahnesi.yuksek);
      expect(SkorSahnesi.skordan(100), SkorSahnesi.yuksek);
    });

    test('her skor için deterministik ve her sahnenin ayrı görseli var', () {
      for (int skor = 0; skor <= 100; skor++) {
        expect(SkorSahnesi.skordan(skor), SkorSahnesi.skordan(skor));
      }
      final Set<String> gorseller =
          SkorSahnesi.values.map((SkorSahnesi s) => s.gorsel).toSet();
      expect(gorseller, hasLength(SkorSahnesi.values.length));
    });
  });
}
