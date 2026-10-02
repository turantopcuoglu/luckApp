import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  // Yaşam yolu 4 (grup {2,4,8}) ve 3 (grup {3,6,9}) olan iki ebeveyn.
  final DateTime anne = DateTime(1994, 3, 14);
  final DateTime baba = DateTime(1990, 2, 9);

  group('NumaraAnalizcisi', () {
    test('telefon: rakamlar toplanır, usta sayı korunur', () {
      // 0+5+3+2+1+2+3+4+5+6+7 = 38 → 11.
      final NumaraAnalizi n = NumaraAnalizcisi.analizEt('0532 123 45 67')!;
      expect(n.hamToplam, 38);
      expect(n.deger, 11);
      expect(n.ustaMi, isTrue);
      expect(n.zincir, <int>[38, 11]);
      expect(n.semboller, hasLength(11));
      expect(n.karmikBorc, isNull);
    });

    test('plaka: harfler Pitagor değeriyle, karmik borç bulunur', () {
      // 3+4 + A1 B2 C3 + 1+2+3 = 19 → 10 → 1.
      final NumaraAnalizi n = NumaraAnalizcisi.analizEt('34 abc 123')!;
      expect(n.hamToplam, 19);
      expect(n.deger, 1);
      expect(n.karmikBorc, 19);
      expect(n.semboller.sublist(2, 5), const <SembolDegeri>[
        SembolDegeri(sembol: 'A', deger: 1),
        SembolDegeri(sembol: 'B', deger: 2),
        SembolDegeri(sembol: 'C', deger: 3),
      ]);
    });

    test('işaretler atlanır; rakam/harf yoksa ya da toplam 0 ise null', () {
      expect(
        NumaraAnalizcisi.analizEt('+90 (532) 123-45-67')!.hamToplam,
        38 + 9,
      );
      expect(NumaraAnalizcisi.analizEt('---'), isNull);
      expect(NumaraAnalizcisi.analizEt('000'), isNull);
      expect(NumaraAnalizcisi.analizEt(''), isNull);
    });

    test('Türkçe harfli adres: Daire 7 → 35 → 8', () {
      // D4 A1 İ9 R9 E5 + 7 = 35.
      expect(NumaraAnalizcisi.analizEt('Daire 7')!.deger, 8);
    });
  });

  group('IsimAnalizi', () {
    test('Ayşe Yılmaz: sayılar, ruhtaki karmik 16, harfler', () {
      final IsimAnalizi a = IsimAnalizi.hesapla('  Ayşe Yılmaz ')!;
      expect(a.tamAd, 'Ayşe Yılmaz');
      expect(a.isim.deger, 1);
      expect(a.ruh!.deger, 7);
      expect(a.kisilik!.deger, 3);
      expect(a.karmikBorclar, const <KarmikBorc>[
        KarmikBorc(sayi: 16, kaynak: KarmikKaynak.ruh),
      ]);
      expect(a.karmikDersler, <int>[2, 6]);
      expect(a.gizliTutku, <int>[1]);
      expect(a.temelTasi.harf, 'A');
      expect(a.tepeTasi.harf, 'E');
      expect(a.denge, 8);
    });

    test('harf yoksa null; tek harfli isimde sesli/sessiz eksik olabilir', () {
      expect(IsimAnalizi.hesapla('123'), isNull);
      final IsimAnalizi a = IsimAnalizi.hesapla('Ş')!;
      expect(a.ruh, isNull);
      expect(a.kisilik!.deger, 1);
    });
  });

  group('BebekIsmi', () {
    test('sayiIliskisi geleneksel grupları izler', () {
      expect(sayiIliskisi(4, 4), YasamYoluIliskisi.ayna);
      expect(sayiIliskisi(2, 8), YasamYoluIliskisi.ayniGrup);
      expect(sayiIliskisi(1, 9), YasamYoluIliskisi.destekleyici);
      expect(sayiIliskisi(4, 9), YasamYoluIliskisi.zorlayici);
    });

    test('uyum: isim sayısı her ebeveynin yaşam yoluyla karşılaştırılır', () {
      // Ali Yılmaz: A1 L3 İ9 + Y7 I9 L3 M4 A1 Z8 = 45 → 9 (grup {3,6,9}).
      // Anne 4 → zorlayıcı (60), baba 3 → aynı grup (95): (60+95)/2 → 78.
      final IsimUyumu u = BebekIsmi.uyum('Ali Yılmaz', <DateTime>[anne, baba])!;
      expect(u.analiz.isim.deger, 9);
      expect(u.iliskiler, <YasamYoluIliskisi>[
        YasamYoluIliskisi.zorlayici,
        YasamYoluIliskisi.ayniGrup,
      ]);
      expect(u.puan, 78);
    });

    test('usta isim sayısı taban değeriyle karşılaştırılır', () {
      // Ada Yılmaz: 6 + 32 = 38 → 11 (taban 2): anne 4 aynı grup (95),
      // baba 3 zorlayıcı (60) → 78.
      final IsimUyumu u = BebekIsmi.uyum('Ada Yılmaz', <DateTime>[anne, baba])!;
      expect(u.analiz.isim.deger, 11);
      expect(u.puan, 78);
    });

    test('sıralama: yüksekten düşüğe, eşitlikte giriş sırası korunur; '
        'harfsiz aday atlanır', () {
      // Can Yılmaz: C3 A1 N5 + 32 = 41 → 5 (grup {1,5,7}): anne 4
      // zorlayıcı (60), baba 3 destekleyici (80) → 70.
      final List<IsimUyumu> s = BebekIsmi.sirala(
        <String>['Can Yılmaz', '???', 'Ali Yılmaz', 'Ada Yılmaz'],
        <DateTime>[anne, baba],
      );
      expect(s.map((IsimUyumu u) => u.analiz.tamAd), <String>[
        'Ali Yılmaz',
        'Ada Yılmaz',
        'Can Yılmaz',
      ]);
      expect(s.map((IsimUyumu u) => u.puan), <int>[78, 78, 70]);
    });

    test('tek referans (ör. bebeğin kendi doğum tarihi) ve hatalı girdi', () {
      expect(BebekIsmi.uyum('Ali Yılmaz', <DateTime>[baba])!.puan, 95);
      expect(BebekIsmi.uyum('', <DateTime>[baba]), isNull);
      expect(
        () => BebekIsmi.uyum('Ali', const <DateTime>[]),
        throwsArgumentError,
      );
    });

    test('puanlar 0-100 aralığında ve deterministik', () {
      for (int i = 0; i < 200; i++) {
        final DateTime d = DateTime(1960, 1, 1 + i * 71);
        final IsimUyumu a = BebekIsmi.uyum('Deniz Kaya', <DateTime>[d])!;
        final IsimUyumu b = BebekIsmi.uyum('Deniz Kaya', <DateTime>[d])!;
        expect(a.puan, b.puan);
        expect(a.puan, inInclusiveRange(0, 100));
      }
    });
  });
}
