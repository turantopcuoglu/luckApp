import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/localization/app_dil.dart';

void main() {
  group('AppDil.cihazdan', () {
    test("'tr' ile başlayan kodlar Türkçe", () {
      expect(AppDil.cihazdan('tr'), AppDil.tr);
      expect(AppDil.cihazdan('tr_TR'), AppDil.tr);
      expect(AppDil.cihazdan('TR'), AppDil.tr);
    });

    test('Türkçe olmayan / null kodlar İngilizce (varsayılan)', () {
      expect(AppDil.cihazdan('en'), AppDil.en);
      expect(AppDil.cihazdan('de'), AppDil.en);
      expect(AppDil.cihazdan('fr_FR'), AppDil.en);
      expect(AppDil.cihazdan(null), AppDil.en);
      expect(AppDil.cihazdan(''), AppDil.en);
    });
  });

  group('AppDil.sec / localeKodu', () {
    test('sec aktif dile göre değer döndürür', () {
      expect(AppDil.tr.sec('a', 'b'), 'a');
      expect(AppDil.en.sec('a', 'b'), 'b');
    });

    test('localeKodu dil kodunu verir', () {
      expect(AppDil.tr.localeKodu, 'tr');
      expect(AppDil.en.localeKodu, 'en');
    });
  });
}
