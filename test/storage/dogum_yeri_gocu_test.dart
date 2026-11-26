import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/harita_metinleri.dart';
import 'package:kader/core/content/harita_okumasi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';

/// K8-4: doğum yeri il → ülke + şehir + saat dilimi.
void main() {
  late Directory dizin;
  late Box<Map<dynamic, dynamic>> kutu;

  setUp(() async {
    dizin = await Directory.systemTemp.createTemp('dogum_yeri_gocu');
    Hive.init(dizin.path);
    kutu = await Hive.openBox<Map<dynamic, dynamic>>('p');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dizin.delete(recursive: true);
  });

  const DogumYeri berlin = DogumYeri(
    ulkeKodu: 'DE',
    ad: 'Berlin',
    saatDilimi: 'Europe/Berlin',
    enlem: 52.52437,
    boylam: 13.41053,
    sehirKimligi: 2950159,
  );

  /// K8-4 öncesi sürümün yazdığı kayıt (il plakası, saat dakikası).
  Map<String, dynamic> eskiKayit({int? plaka, int? dakika}) =>
      <String, dynamic>{
        'isim': 'Ayşe',
        'dogumTarihi': DateTime(1994, 3, 14).toIso8601String(),
        'onboardingTamam': true,
        'dogumSaatiDakika': dakika,
        'dogumIliPlaka': plaka,
      };

  group('eski kayıt', () {
    test('il plakası Türkiye doğum yerine dönüşür, yazma gerekmez', () {
      final UserProfile p = UserProfile.fromMap(
        eskiKayit(plaka: 35, dakika: 8 * 60 + 30),
      );
      final DogumYeri yer = p.dogumYeri!;
      expect(yer.ulkeKodu, 'TR');
      expect(yer.ilPlaka, 35);
      expect(yer.saatDilimi, 'Europe/Istanbul');
      expect(yer.enlem, TurkiyeIlleri.plakadan(35)!.enlem);
      expect(p.yabanciDogumYeri, isNull);
    });

    test('yer yoksa null, saat dilimi Türkiye kuralı (eski davranış)', () {
      final UserProfile p = UserProfile.fromMap(eskiKayit(dakika: 600));
      expect(p.dogumYeri, isNull);
      expect(
        p.dogumSaatDilimi.farkDakika,
        TurkiyeSaatDilimi.utcFarki(p.yerelDogumAni).farkSaat * 60,
      );
      expect(p.dogumHaritasi.yukselen, isNull);
    });

    test('Türkiye haritası eski hesapla birebir aynı (81 il, 4 saat, '
        '6 tarih)', () {
      final List<DateTime> tarihler = <DateTime>[
        DateTime(1942, 8, 3),
        DateTime(1965, 7, 1),
        DateTime(1979, 4, 2),
        DateTime(1994, 3, 14),
        DateTime(2007, 10, 28),
        DateTime(2016, 9, 8),
      ];
      int sayac = 0;
      for (final Il il in TurkiyeIlleri.hepsi) {
        for (final DateTime t in tarihler) {
          for (final int dakika in <int>[
            0,
            3 * 60 + 30,
            9 * 60 + 15,
            23 * 60 + 59,
          ]) {
            final UserProfile p = UserProfile(
              isim: 'A',
              dogumTarihi: t,
              dogumSaatiDakika: dakika,
              dogumIliPlaka: il.plaka,
            );
            // K8-4 öncesi UserProfile.dogumHaritasi'nın birebir kopyası.
            final DateTime yerel = DateTime(
              t.year,
              t.month,
              t.day,
              dakika ~/ 60,
              dakika % 60,
            );
            final DogumHaritasi eski = DogumHaritasi.hesapla(
              yerelDogum: yerel,
              utcFarkiSaat: TurkiyeSaatDilimi.utcFarki(
                yerel,
              ).farkSaat.toDouble(),
              saatBiliniyor: true,
              enlem: il.enlem,
              boylam: il.boylam,
            );
            final DogumHaritasi yeni = p.dogumHaritasi;
            expect(yeni.yukselenBoylami, eski.yukselenBoylami);
            expect(yeni.ayBoylami, eski.ayBoylami);
            expect(yeni.gunesBurcu, eski.gunesBurcu);
            sayac++;
          }
        }
      }
      expect(sayac, 81 * 6 * 4);
    });
  });

  group('yabancı doğum yeri', () {
    test('kayda yazılır ve geri okunur; il plakası yazılmaz', () async {
      final UserRepository repo = UserRepository(kutu);
      await repo.kaydet(
        UserProfile(
          isim: 'Ayşe',
          dogumTarihi: DateTime(1990, 7, 1),
          dogumSaatiDakika: 12 * 60,
          yabanciDogumYeri: berlin,
        ),
      );
      final Map<dynamic, dynamic> ham = kutu.values.first;
      expect(ham['dogumIliPlaka'], isNull);
      expect(ham['dogumUlkeKodu'], 'DE');
      expect(ham['dogumSaatDilimi'], 'Europe/Berlin');

      final UserProfile p = repo.profil()!;
      final DogumYeri yer = p.dogumYeri!;
      expect(yer.ulkeKodu, 'DE');
      expect(yer.ad, 'Berlin');
      expect(yer.sehirKimligi, 2950159);
      expect(yer.enlem, 52.52437);
      expect(yer.boylam, 13.41053);
      expect(p.dogumSaatDilimi.farkDakika, 120);
      expect(p.dogumSaatDilimi.kesin, isTrue);
    });

    test('eksik yabancı alan: yer okunmaz (yarım kayıt haritayı bozmaz)', () {
      final Map<String, dynamic> m = eskiKayit()
        ..addAll(<String, dynamic>{
          'dogumUlkeKodu': 'DE',
          'dogumSehirAdi': 'Berlin',
          'dogumSaatDilimi': 'Europe/Berlin',
          'dogumEnlem': 52.5,
        });
      expect(UserProfile.fromMap(m).dogumYeri, isNull);
    });

    test('Hive tam sayı koordinatı da okunur', () {
      final Map<String, dynamic> m = eskiKayit()
        ..addAll(<String, dynamic>{
          'dogumUlkeKodu': 'GH',
          'dogumSehirAdi': 'Ekvator',
          'dogumSaatDilimi': 'Africa/Accra',
          'dogumEnlem': 0,
          'dogumBoylam': 0,
        });
      expect(UserProfile.fromMap(m).dogumYeri!.boylam, 0.0);
    });

    test('Yükselen yabancı şehrin koordinatı ve saat dilimiyle hesaplanır', () {
      final UserProfile p = UserProfile(
        isim: 'A',
        dogumTarihi: DateTime(1990, 7, 1),
        dogumSaatiDakika: 12 * 60,
        yabanciDogumYeri: berlin,
      );
      final DogumHaritasi beklenen = DogumHaritasi.hesapla(
        yerelDogum: DateTime.utc(1990, 7, 1, 12),
        utcFarkiSaat: 2,
        saatBiliniyor: true,
        enlem: berlin.enlem,
        boylam: berlin.boylam,
      );
      expect(p.dogumHaritasi.yukselenBoylami, beklenen.yukselenBoylami);
    });
  });

  group('copyWith: doğum yeri tek yerdir', () {
    final UserProfile tr = UserProfile(
      isim: 'A',
      dogumTarihi: DateTime(1990),
      dogumIliPlaka: 6,
    );

    test('yabancı yer seçilince il silinir', () {
      final UserProfile p = tr.copyWith(dogumYeri: berlin);
      expect(p.dogumIliPlaka, isNull);
      expect(p.dogumYeri!.ulkeKodu, 'DE');
    });

    test('il seçilince yabancı yer silinir', () {
      final UserProfile p = tr
          .copyWith(dogumYeri: berlin)
          .copyWith(dogumIliPlaka: 34);
      expect(p.yabanciDogumYeri, isNull);
      expect(p.dogumYeri!.ilPlaka, 34);
    });

    test('Türkiye ili DogumYeri olarak verilirse plaka olarak saklanır', () {
      final UserProfile p = tr
          .copyWith(dogumYeri: berlin)
          .copyWith(dogumYeri: DogumYeri.il(TurkiyeIlleri.plakadan(35)!));
      expect(p.dogumIliPlaka, 35);
      expect(p.yabanciDogumYeri, isNull);
    });

    test('dogumIliniTemizle ikisini de siler; başka alan yeri korur', () {
      final UserProfile y = tr.copyWith(dogumYeri: berlin);
      expect(y.copyWith(dogumIliniTemizle: true).dogumYeri, isNull);
      expect(y.copyWith(tamAd: 'A B').dogumYeri!.ad, 'Berlin');
    });
  });

  group('yerel doğum anı', () {
    test('cihaz diliminde atlanan saat kaymaz', () {
      // 28 Mart 2010 03:30 İstanbul'da hiç yaşanmadı; yerel kurucu cihaz
      // İstanbul'dayken bunu 04:30 yapardı.
      final UserProfile p = UserProfile(
        isim: 'A',
        dogumTarihi: DateTime(2010, 3, 28),
        dogumSaatiDakika: 3 * 60 + 30,
        dogumIliPlaka: 34,
      );
      expect(p.yerelDogumAni.hour, 3);
      expect(p.yerelDogumAni.minute, 30);
      expect(p.dogumSaatDilimi.durum, YerelSaatDurumu.atlanan);
      expect(p.dogumSaatDilimi.kesin, isFalse);
    });
  });

  group('Yükselen güvenilirlik notu (nedene göre)', () {
    List<String> notlar(UserProfile p) => haritaOkumasi(
      harita: p.dogumHaritasi,
      saatBiliniyor: p.dogumSaatiBiliniyor,
      konumBiliniyor: p.dogumYeri != null,
      saatDilimiKesin: p.dogumSaatDilimi.kesin,
      saatDurumu: p.dogumSaatDilimi.durum,
      yurtDisi: !(p.dogumYeri?.turkiyeMi ?? true),
    ).notlar;

    test('Türkiye 1978 öncesi: Türkiye kaydı notu (eskisi gibi)', () {
      final List<String> n = notlar(
        UserProfile(
          isim: 'A',
          dogumTarihi: DateTime(1965, 7, 1),
          dogumSaatiDakika: 9 * 60,
          dogumIliPlaka: 6,
        ),
      );
      expect(n, contains(HaritaMetinleri.saatDilimiBelirsiz));
    });

    test('geçiş gecesi: geçiş notu', () {
      final List<String> n = notlar(
        UserProfile(
          isim: 'A',
          dogumTarihi: DateTime(2010, 3, 28),
          dogumSaatiDakika: 3 * 60 + 30,
          dogumIliPlaka: 34,
        ),
      );
      expect(n, contains(HaritaMetinleri.saatDilimiGecisGecesi));
      expect(n, isNot(contains(HaritaMetinleri.saatDilimiBelirsiz)));
    });

    test('yurt dışı 1970 öncesi: bölge notu, Türkiye adı geçmez', () {
      final List<String> n = notlar(
        UserProfile(
          isim: 'A',
          dogumTarihi: DateTime(1965, 7, 1),
          dogumSaatiDakika: 9 * 60,
          yabanciDogumYeri: berlin,
        ),
      );
      expect(n, contains(HaritaMetinleri.saatDilimiBelirsizYurtDisi));
      expect(n.join(' '), isNot(contains('Türkiye')));
    });

    test('yurt dışı 1990: not yok', () {
      final List<String> n = notlar(
        UserProfile(
          isim: 'A',
          dogumTarihi: DateTime(1990, 7, 1),
          dogumSaatiDakika: 9 * 60,
          yabanciDogumYeri: berlin,
        ),
      );
      expect(n, isNot(contains(HaritaMetinleri.saatDilimiBelirsizYurtDisi)));
      expect(n, isNot(contains(HaritaMetinleri.saatDilimiGecisGecesi)));
    });
  });
}
