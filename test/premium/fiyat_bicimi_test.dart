import 'package:flutter_test/flutter_test.dart';
import 'package:kader/features/premium/fiyat_bicimi.dart';

/// E6d: yıllık planın aylık karşılığının para biçimi.
void main() {
  String yaz(double tutar, String ornek, String? kod, String dil) =>
      FiyatBicimi.bicimle(
        tutar: tutar,
        ornekMetin: ornek,
        paraBirimiKodu: kod,
        dilKodu: dil,
      );

  test('Türkçe, TRY: sembol mağazadan, virgüllü ondalık', () {
    expect(yaz(50, '₺600,00', 'TRY', 'tr'), '₺50,00');
  });

  test('binlik ayırıcılı mağaza fiyatı sayıyı bozmaz (eski hata)', () {
    // Eski kod "$1,299.99" metnindeki binlik virgülünü ondalık sanıp
    // "$108,33" yazıyordu.
    expect(yaz(1299.99 / 12, r'$1,299.99', 'USD', 'en'), r'$108.33');
    expect(yaz(1234.5, r'$1,299.99', 'USD', 'en'), r'$1,234.50');
    expect(yaz(1234.5, '₺1.299,99', 'TRY', 'tr'), '₺1.234,50');
  });

  test('hane sayısı para biriminden: yen ondalıksız', () {
    expect(yaz(1000, '¥12,000', 'JPY', 'en'), '¥1,000');
  });

  test('sembolü sonda olan mağaza metni', () {
    expect(yaz(5, '59,99 €', 'EUR', 'tr'), '€5,00');
  });

  test('kod bilinmiyorsa iki hane ve mağaza sembolü', () {
    expect(yaz(50, '₺600,00', null, 'tr'), '₺50,00');
  });
}
