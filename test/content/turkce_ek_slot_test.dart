import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
import 'package:kader/core/content/turkce_ek.dart';

void main() {
  group('TurkceEk.ilgi', () {
    test('ünlüyle biten isimler n kaynaştırması alır', () {
      expect(TurkceEk.ilgi('Ayşe'), "Ayşe'nin");
      expect(TurkceEk.ilgi('Derya'), "Derya'nın");
      expect(TurkceEk.ilgi('Oya'), "Oya'nın");
      expect(TurkceEk.ilgi('Onur'), "Onur'un");
      expect(TurkceEk.ilgi('Ümmü'), "Ümmü'nün");
      expect(TurkceEk.ilgi('Songül'), "Songül'ün");
    });

    test('ünsüzle biten isimler ünlü uyumuna göre ek alır', () {
      expect(TurkceEk.ilgi('Turan'), "Turan'ın");
      expect(TurkceEk.ilgi('Kerem'), "Kerem'in");
      expect(TurkceEk.ilgi('Umut'), "Umut'un");
      expect(TurkceEk.ilgi('Gönül'), "Gönül'ün");
      expect(TurkceEk.ilgi('Işık'), "Işık'ın");
      expect(TurkceEk.ilgi('İlker'), "İlker'in");
    });

    test('baştaki/sondaki boşluklar kırpılır', () {
      expect(TurkceEk.ilgi(' Ali '), "Ali'nin");
    });
  });

  group('TurkceEk yönelme/belirtme', () {
    test('yönelme', () {
      expect(TurkceEk.yonelme('Ayşe'), "Ayşe'ye");
      expect(TurkceEk.yonelme('Turan'), "Turan'a");
      expect(TurkceEk.yonelme('Mert'), "Mert'e");
      expect(TurkceEk.yonelme('Aslı'), "Aslı'ya");
    });

    test('belirtme', () {
      expect(TurkceEk.belirtme('Ayşe'), "Ayşe'yi");
      expect(TurkceEk.belirtme('Turan'), "Turan'ı");
      expect(TurkceEk.belirtme('Burcu'), "Burcu'yu");
    });
  });

  group('TurkceEk.sayiIlgi', () {
    test('sayının okunuşuna göre ek', () {
      expect(TurkceEk.sayiIlgi(1), "1'in");
      expect(TurkceEk.sayiIlgi(2), "2'nin");
      expect(TurkceEk.sayiIlgi(3), "3'ün");
      expect(TurkceEk.sayiIlgi(4), "4'ün");
      expect(TurkceEk.sayiIlgi(6), "6'nın");
      expect(TurkceEk.sayiIlgi(9), "9'un");
      expect(TurkceEk.sayiIlgi(11), "11'in");
      expect(TurkceEk.sayiIlgi(22), "22'nin");
      expect(TurkceEk.sayiIlgi(33), "33'ün");
    });
  });

  group('slotDoldur', () {
    test('tüm yer tutucuları doldurur', () {
      expect(
        slotDoldur('{isim}, bugün {kisiselGun}.', <String, String>{
          'isim': 'Ayşe',
          'kisiselGun': '4',
        }),
        'Ayşe, bugün 4.',
      );
    });

    test('eksik anahtarda StateError fırlatır', () {
      expect(
        () => slotDoldur('{isim} {burc}', <String, String>{'isim': 'A'}),
        throwsStateError,
      );
    });

    test('slotlariBul yer tutucuları çıkarır', () {
      expect(slotlariBul('{a} x {b} {a}'), <String>{'a', 'b'});
      expect(slotlariBul('yer tutucu yok'), isEmpty);
    });
  });

  group('metinKimligi', () {
    test('kararlı ve metne duyarlı', () {
      expect(metinKimligi('Merhaba'), metinKimligi('Merhaba'));
      expect(metinKimligi('Merhaba'), isNot(metinKimligi('Merhaba.')));
      expect(metinKimligi(''), '811c9dc5');
      expect(metinKimligi('a'), 'e40c292c');
    });
  });
}
