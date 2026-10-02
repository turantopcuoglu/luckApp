import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/arac_metinleri.dart';
import 'package:kader/core/content/arac_okumalari.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/rapor_metinleri.dart';
import 'package:kader/core/content/sayi_metinleri.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

import 'fortune_pools_test.dart' show havuzuDogrula;

int _kelime(String metin) =>
    metin.split(RegExp(r'\s+')).where((String k) => k.isNotEmpty).length;

void main() {
  const List<int> tumSayilar = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];

  group('Araç metin havuzları', () {
    test('her sayı için numara metni; biçim, uzunluk, yasaklı ifade', () {
      final List<String> metinler = <String>[
        for (final int s in tumSayilar) AracMetinleri.numaralar[s]!.metin,
        for (final UyumBandi b in AracMetinleri.bebekBantlari) b.aciklama,
        ...AracMetinleri.bebekIliskileri.values,
      ];
      havuzuDogrula('araç', metinler);
      for (final int s in tumSayilar) {
        expect(
          _kelime(AracMetinleri.numaralar[s]!.metin),
          greaterThanOrEqualTo(ContentConfig.aracMetniEnAzKelime),
          reason: 'numara $s',
        );
      }
      for (final String m in metinler) {
        expect(m.contains('  '), isFalse, reason: m);
        final String kucuk = m.toLowerCase();
        for (final String yasak in ContentConfig.yasakliIfadeler) {
          final RegExp desen = RegExp(
            '(^|[^a-zçğıöşüâîû])${RegExp.escape(yasak)}',
          );
          expect(desen.hasMatch(kucuk), isFalse, reason: '"$yasak": $m');
        }
      }
    });

    test('bebek ilişki cümleleri her ilişki türü için var ve yalnızca '
        '{digerIsim} yer tutucusunu kullanır', () {
      for (final YasamYoluIliskisi i in YasamYoluIliskisi.values) {
        final String? c = AracMetinleri.bebekIliskileri[i];
        expect(c, isNotNull, reason: '$i');
        expect(slotlariBul(c!), <String>{SlotAnahtarlari.digerIsim});
      }
      expect(
        AracMetinleri.bebekBantlari.length,
        ContentConfig.bebekBantEsikleri.length + 1,
      );
    });
  });

  group('numaraOkumasi', () {
    test('telefon 11: usta lakap, karmik not yok', () {
      final NumaraOkumasi o = numaraOkumasi(
        NumaraAnalizcisi.analizEt('0532 123 45 67')!,
      );
      expect(o.baslik, 'Numaranın sayısı 11 · Usta İlham');
      expect(o.metin, AracMetinleri.numaralar[11]!.metin);
    });

    test('plaka 19 → 1: karmik notu eklenir', () {
      final NumaraOkumasi o = numaraOkumasi(
        NumaraAnalizcisi.analizEt('34 ABC 123')!,
      );
      expect(o.baslik, 'Numaranın sayısı 1 · Öncü');
      expect(o.metin, startsWith(AracMetinleri.numaralar[1]!.metin));
      expect(
        o.metin,
        endsWith(
          AracMetinleri.numaraKarmikNotu(
            19,
            RaporMetinleri.karmikBorclar[19]!.lakap,
          ),
        ),
      );
    });

    test('geniş tarama: her numara için okuma üretilir', () {
      for (int i = 1; i < 5000; i += 7) {
        final NumaraOkumasi o = numaraOkumasi(NumaraAnalizcisi.analizEt('$i')!);
        expect(o.metin, isNotEmpty);
      }
    });
  });

  group('isimOkumasi', () {
    test('Ayşe Yılmaz: ücretsiz sayılar, premium derin bölümler', () {
      final List<AracBolumu> b = isimOkumasi(
        IsimAnalizi.hesapla('Ayşe Yılmaz')!,
      );
      expect(b.map((AracBolumu x) => x.baslik), <String>[
        'İsim sayısı 1',
        'Ruh sayısı 7',
        'Kişilik sayısı 3',
        'Karmik borç 16 · Yıkım ve yeniden doğuş',
        RaporMetinleri.karmikDersBasligi,
        RaporMetinleri.gizliTutkuBasligi,
        'İsminin ilk ve son harfi · A … E',
      ]);
      expect(b.first.metin, SayiMetinleri.isimSayisi[1]);
      expect(b[3].metin, startsWith('Bu sayı ruh sayında görülüyor.'));
      expect(
        b.where((AracBolumu x) => !x.premium).map((AracBolumu x) => x.baslik),
        <String>['İsim sayısı 1', 'Ruh sayısı 7', 'Kişilik sayısı 3'],
      );
    });

    test('sesli harf yoksa ruh bölümü yok; karmik borç yoksa bölüm yok', () {
      final List<AracBolumu> b = isimOkumasi(IsimAnalizi.hesapla('Şş')!);
      expect(b.any((AracBolumu x) => x.baslik.startsWith('Ruh')), isFalse);
      expect(
        b.any((AracBolumu x) => x.baslik.startsWith('Karmik borç')),
        isFalse,
      );
    });
  });

  group('bebekIsmiOkumasi', () {
    final DateTime anne = DateTime(1994, 3, 14);
    final DateTime baba = DateTime(1990, 2, 9);

    test('bantlar eşiklere göre seçilir', () {
      expect(bebekBandi(95).etiket, 'Çok uyumlu');
      expect(bebekBandi(90).etiket, 'Çok uyumlu');
      expect(bebekBandi(78).etiket, 'Uyumlu');
      expect(bebekBandi(70).etiket, 'Dengeli');
      expect(bebekBandi(60).etiket, 'Öğretici');
    });

    test('Ali Yılmaz: puan 78, ilişki cümleleri kişi adlarıyla', () {
      final BebekIsmiOkumasi o = bebekIsmiOkumasi(
        BebekIsmi.uyum('Ali Yılmaz', <DateTime>[anne, baba])!,
        <String>['Anne', 'Baba'],
      );
      expect(o.bant.etiket, 'Uyumlu');
      expect(o.iliskiCumleleri, <String>[
        slotDoldur(
          AracMetinleri.bebekIliskileri[YasamYoluIliskisi.zorlayici]!,
          <String, String>{SlotAnahtarlari.digerIsim: 'Anne'},
        ),
        slotDoldur(
          AracMetinleri.bebekIliskileri[YasamYoluIliskisi.ayniGrup]!,
          <String, String>{SlotAnahtarlari.digerIsim: 'Baba'},
        ),
      ]);
      expect(o.iliskiCumleleri.first, startsWith('Anne ile'));
    });

    test('ad sayısı referans sayısıyla uyuşmazsa hata', () {
      expect(
        () => bebekIsmiOkumasi(
          BebekIsmi.uyum('Ali Yılmaz', <DateTime>[anne, baba])!,
          <String>['Anne'],
        ),
        throwsArgumentError,
      );
    });
  });
}
