import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  group('harf tablosu', () {
    test('Pitagor değerleri: A=1, I=9, J=1, S=1, Z=8', () {
      expect(Numeroloji.harfDegeri('A'), 1);
      expect(Numeroloji.harfDegeri('i'), 9);
      expect(Numeroloji.harfDegeri('J'), 1);
      expect(Numeroloji.harfDegeri('s'), 1);
      expect(Numeroloji.harfDegeri('Z'), 8);
    });

    test('Türkçe harfler Latin karşılığının değerini alır', () {
      expect(Numeroloji.harfDegeri('Ç'), Numeroloji.harfDegeri('C'));
      expect(Numeroloji.harfDegeri('ğ'), Numeroloji.harfDegeri('g'));
      expect(Numeroloji.harfDegeri('Ş'), Numeroloji.harfDegeri('S'));
      expect(Numeroloji.harfDegeri('ö'), Numeroloji.harfDegeri('o'));
      expect(Numeroloji.harfDegeri('Ü'), Numeroloji.harfDegeri('U'));
      for (final String i in <String>['I', 'İ', 'ı', 'i']) {
        expect(Numeroloji.harfDegeri(i), 9, reason: i);
      }
    });

    test('harf olmayan karakterler null', () {
      for (final String k in <String>[' ', '-', "'", '3', '.']) {
        expect(Numeroloji.harfDegeri(k), isNull, reason: k);
      }
    });

    test('sesli harfler Türkçe dahil; Y sessiz', () {
      for (final String s in <String>['a', 'E', 'ı', 'İ', 'o', 'Ö', 'u', 'ü']) {
        expect(Numeroloji.sesliMi(s), isTrue, reason: s);
      }
      expect(Numeroloji.sesliMi('y'), isFalse);
      expect(Numeroloji.sesliMi('ş'), isFalse);
    });
  });

  group('indirge', () {
    test('tek haneye indirger', () {
      expect(Numeroloji.indirge(1994), 5);
      expect(Numeroloji.indirge(9), 9);
      expect(Numeroloji.indirge(10), 1);
    });

    test('usta sayıları korur, istenirse indirger', () {
      expect(Numeroloji.indirge(29), 11);
      expect(Numeroloji.indirge(22), 22);
      expect(Numeroloji.indirge(33), 33);
      expect(Numeroloji.indirge(29, ustaKoru: false), 2);
      expect(Numeroloji.tabanSayi(33), 6);
      expect(Numeroloji.tabanSayi(7), 7);
    });
  });

  group('yaşam yolu', () {
    test('14.03.1994 → 4, adımlar ay/gün/yıl/toplam', () {
      final SayiHesabi h = Numeroloji.yasamYolu(DateTime(1994, 3, 14));
      expect(h.deger, 4);
      expect(h.adimlar.map((HesapAdimi a) => a.tur).toList(), <HesapAdimTuru>[
        HesapAdimTuru.ay,
        HesapAdimTuru.gun,
        HesapAdimTuru.yil,
        HesapAdimTuru.toplam,
      ]);
      expect(h.adimlar[1].terimler, <int>[1, 4]);
      expect(h.adimlar[2].sonuc, 5);
      expect(h.adimlar[3].terimler, <int>[3, 5, 5]);
    });

    test('toplam usta sayıya ulaşırsa korunur: 09.11.2000 → 22', () {
      final SayiHesabi h = Numeroloji.yasamYolu(DateTime(2000, 11, 9));
      expect(h.deger, 22);
      expect(h.ustaMi, isTrue);
      expect(h.taban, 4);
    });

    test('1920-2026 arasında her gün geçerli değer üretir', () {
      DateTime gun = DateTime(1920);
      final Set<int> gecerli = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33};
      while (gun.year < 2026) {
        expect(gecerli, contains(Numeroloji.yasamYolu(gun).deger));
        gun = DateTime(gun.year, gun.month, gun.day + 13);
      }
    });
  });

  group('isim sayıları', () {
    test('AYŞE: isim 5, ruh 6, kişilik 8', () {
      expect(Numeroloji.isimSayisi('Ayşe')!.deger, 5);
      expect(Numeroloji.ruhSayisi('Ayşe')!.deger, 6);
      expect(Numeroloji.kisilikSayisi('Ayşe')!.deger, 8);
    });

    test('Ali Veli: isim 7, ruh 6, kişilik 1; boşluk atlanır', () {
      expect(Numeroloji.isimSayisi('Ali Veli')!.deger, 7);
      expect(Numeroloji.ruhSayisi('Ali Veli')!.deger, 6);
      expect(Numeroloji.kisilikSayisi('Ali Veli')!.deger, 1);
      expect(
        Numeroloji.isimSayisi('Ali Veli')!.adimlar.single.kaynak,
        'AliVeli',
      );
    });

    test('büyük/küçük harf ve İ/I farkı sonucu değiştirmez', () {
      expect(
        Numeroloji.isimSayisi('IŞIK')!.deger,
        Numeroloji.isimSayisi('ışık')!.deger,
      );
      expect(
        Numeroloji.isimSayisi('İPEK')!.deger,
        Numeroloji.isimSayisi('ipek')!.deger,
      );
    });

    test('tire ve kesme atlanır: Ayşe-Nur → 4', () {
      expect(Numeroloji.isimSayisi('Ayşe-Nur')!.deger, 4);
      expect(
        Numeroloji.isimSayisi("Ayşe'Nur")!.deger,
        Numeroloji.isimSayisi('Ayşe Nur')!.deger,
      );
    });

    test('harf yoksa null; sessiz harf yoksa ruh dışındakiler hesaplanır', () {
      expect(Numeroloji.isimSayisi('123 -'), isNull);
      expect(Numeroloji.ruhSayisi('Brk'), isNull);
      expect(Numeroloji.kisilikSayisi('Brk'), isNotNull);
    });
  });

  group('kişisel döngüler', () {
    final DateTime dogum = DateTime(1994, 3, 14);

    test('14.03 doğumlu: 2026 yılı 9, Eylül 9, 13 Eylül 4', () {
      expect(Numeroloji.kisiselYil(dogum, 2026), 9);
      expect(Numeroloji.kisiselAy(dogum, DateTime(2026, 9, 13)), 9);
      expect(Numeroloji.kisiselGun(dogum, DateTime(2026, 9, 13)), 4);
    });

    test('kişisel döngüler her zaman 1-9 (usta sayı yok)', () {
      for (int i = 0; i < 800; i++) {
        final DateTime gun = DateTime(2026, 1, 1 + i);
        expect(Numeroloji.kisiselGun(dogum, gun), inInclusiveRange(1, 9));
        expect(Numeroloji.kisiselAy(dogum, gun), inInclusiveRange(1, 9));
      }
    });

    test('ardışık günlerde kişisel gün 1 artar (9 → 1), ay içinde', () {
      // Aynı ay içinde gün rakam toplamı birer artar; 9'dan sonra 1 gelir.
      final int a = Numeroloji.kisiselGun(dogum, DateTime(2026, 9, 1));
      final int b = Numeroloji.kisiselGun(dogum, DateTime(2026, 9, 2));
      expect(b, a % 9 + 1);
    });
  });

  group('KaderProfili & GunDongusu', () {
    test('tam adsız profilde isim sayıları null, burç hesaplanır', () {
      final KaderProfili p = KaderProfili.hesapla(
        dogumTarihi: DateTime(1994, 3, 14),
      );
      expect(p.yasamYolu.deger, 4);
      expect(p.isimSayisi, isNull);
      expect(p.burc, Burc.balik);
      expect(p.burcSinirGunu, isFalse);
    });

    test('tam adlı profil tüm sayıları doldurur', () {
      final KaderProfili p = KaderProfili.hesapla(
        dogumTarihi: DateTime(1994, 3, 14),
        tamAd: 'Ayşe',
      );
      expect(p.isimSayisi!.deger, 5);
      expect(p.ruhSayisi!.deger, 6);
      expect(p.kisilikSayisi!.deger, 8);
      expect(p.dogumGunuSayisi, 5);
    });

    test('GunDongusu örnek günle eşleşir', () {
      final GunDongusu d = GunDongusu.hesapla(
        dogumTarihi: DateTime(1994, 3, 14),
        gun: DateTime(2026, 9, 13, 22, 30),
      );
      expect(d.kisiselYil, 9);
      expect(d.kisiselAy, 9);
      expect(d.kisiselGun, 4);
    });
  });
}
