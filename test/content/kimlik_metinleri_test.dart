import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/kimlik_metinleri.dart';
import 'package:kader/core/content/kisilik_metinleri.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/user_profile.dart';

/// Doğum haritası portresi: yükselen × Ay burcu cümleleri ve günlük
/// okumadaki yeri.
void main() {
  const LuckEngine motor = LuckEngine();

  group('KimlikMetinleri', () {
    test('on iki burcun dış görünüş ve iç dünya ifadeleri var', () {
      expect(KimlikMetinleri.disGorunus.keys.toSet(), Burc.values.toSet());
      expect(KimlikMetinleri.icDunya.keys.toSet(), Burc.values.toSet());
      for (final Burc b in Burc.values) {
        // En az iki ifade: tek ifade gün aşırı aynı cümleyi getirirdi.
        expect(
          KimlikMetinleri.disGorunus[b]!.length,
          greaterThanOrEqualTo(2),
          reason: '$b',
        );
        expect(
          KimlikMetinleri.icDunya[b]!.length,
          greaterThanOrEqualTo(2),
          reason: '$b',
        );
        // İç dünya ifadeleri cümle ortasına oturur: küçük harfle başlar,
        // noktayla bitmez.
        for (final String ic in KimlikMetinleri.icDunya[b]!) {
          expect(ic[0], ic[0].toLowerCase(), reason: ic);
          expect(ic.endsWith('.'), isFalse, reason: ic);
        }
      }
    });

    test('hiçbiri bilinmiyorsa portre yok', () {
      expect(KimlikMetinleri.portreler(), isEmpty);
    });

    test('ikisi de biliniyorsa dışarı/içeri karşıtlığı kurulur', () {
      final List<String> p = KimlikMetinleri.portreler(
        dogumAyi: Burc.koc,
        yukselen: Burc.boga,
      );
      expect(
        p,
        hasLength(
          KimlikMetinleri.ikiliKaliplar.length *
              KimlikMetinleri.disGorunus[Burc.boga]!.length *
              KimlikMetinleri.icDunya[Burc.koc]!.length,
        ),
      );
      expect(
        p,
        contains(
          'Dışarıdan sakin, güvenilir ve sıcak görünürsün; içinde ise '
          'duygularını hızlı ve doğrudan yaşarsın.',
        ),
      );
      expect(
        p,
        contains(
          'Yükselenin Boğa seni sakin, güvenilir ve sıcak gösterir; Ay '
          'burcun Koç ise içeride başka konuşur: duygularını hızlı ve '
          'doğrudan yaşarsın.',
        ),
      );
      // Büyük harfle başlayan kalıp: Türkçe büyük harf.
      expect(
        KimlikMetinleri.portreler(dogumAyi: Burc.boga, yukselen: Burc.koc),
        contains(
          'Huzuru istikrarda ve tanıdık yüzlerde ararsın; dışarıya ise çoğu '
          'zaman enerjik, cesur ve doğrudan görünürsün.',
        ),
      );
    });

    test('yalnızca biri biliniyorsa o tarafı anlatır', () {
      final List<String> ay = KimlikMetinleri.portreler(dogumAyi: Burc.yay);
      expect(
        ay,
        contains(
          'Ay burcun Yay olduğu için iç dünyanda özgürlüğe ve umuda '
          'ihtiyaç duyarsın.',
        ),
      );
      expect(ay.any((String m) => m.contains('Yükselen')), isFalse);

      final List<String> yukselen = KimlikMetinleri.portreler(
        yukselen: Burc.oglak,
      );
      expect(
        yukselen,
        contains(
          'Yükselenin Oğlak olduğu için ilk izlenimde ciddi, olgun ve '
          'güvenilir görünürsün.',
        ),
      );
      expect(yukselen.any((String m) => m.contains('Ay burcun')), isFalse);
    });

    test('bütün birleşimlerde cümleler tam: yer tutucu ve çift boşluk yok, '
        'tekrar yok', () {
      for (final Burc? ay in <Burc?>[null, ...Burc.values]) {
        for (final Burc? yukselen in <Burc?>[null, ...Burc.values]) {
          final List<String> p = KimlikMetinleri.portreler(
            dogumAyi: ay,
            yukselen: yukselen,
          );
          expect(p.toSet(), hasLength(p.length), reason: '$ay $yukselen');
          for (final String m in p) {
            expect(m.contains('{'), isFalse, reason: m);
            expect(m.contains('  '), isFalse, reason: m);
            expect(m.endsWith('.'), isTrue, reason: m);
            expect(m[0], m[0].toUpperCase(), reason: m);
          }
        }
      }
    });

    test('hiçbir portre cümlesi çelişki kapısına takılmaz', () {
      // Portre haritanın kendi verisidir; hangi çekirdek portreyle
      // okunursa okunsun elenmemeli.
      for (final EnerjiTarzi e in EnerjiTarzi.values) {
        for (final KararTarzi k in KararTarzi.values) {
          final Portre t = Portre(enerji: e, karar: k);
          for (final Burc ay in Burc.values) {
            for (final Burc yukselen in Burc.values) {
              for (final String m in KimlikMetinleri.portreler(
                dogumAyi: ay,
                yukselen: yukselen,
              )) {
                expect(KisilikMetinleri.celisir(m, t), isFalse, reason: m);
              }
            }
          }
        }
      }
    });
  });

  group('günlük okumada portre', () {
    final DateTime dogum = DateTime(1992, 3, 14);

    Okuyucu okuyucu({Burc? dogumAyi, Burc? yukselen}) => Okuyucu(
      isim: 'Deniz',
      seed: UserSeed.fromIsim(isim: 'Deniz', dogumTarihi: dogum),
      profil: KaderProfili.hesapla(dogumTarihi: dogum),
      dogumAyi: dogumAyi,
      yukselen: yukselen,
    );

    String enerji(Okuyucu o, DateTime gun) => gunlukOkuma(
      motor: motor,
      okuyucu: o,
      sonuc: motor.hesapla(kullanici: o.seed, gun: gun),
    ).bolumler.first.metin;

    /// Sayı sesinin konuşmadığı (portre) günü mü?
    bool portreGunu(DateTime gun) =>
        LuckEngine.gunNumarasi(gun) % ContentConfig.kisilikDonusumu == 0;

    test('portre gün aşırı açılış paragrafında yer alır; ardışık iki '
        'kullanımda cümle değişir', () {
      final Okuyucu o = okuyucu(dogumAyi: Burc.koc, yukselen: Burc.boga);
      final List<String> havuz = KimlikMetinleri.portreler(
        dogumAyi: Burc.koc,
        yukselen: Burc.boga,
      );
      String? onceki;
      int gorulen = 0;
      for (int i = 0; i < 40; i++) {
        final DateTime gun = DateTime(2026, 9, 1 + i);
        final String metin = enerji(o, gun);
        final List<String> bulunan = havuz.where(metin.contains).toList();
        if (portreGunu(gun)) {
          expect(bulunan, hasLength(1), reason: '$gun: $metin');
          expect(bulunan.single, isNot(onceki), reason: '$gun');
          onceki = bulunan.single;
          gorulen++;
        } else {
          expect(bulunan, isEmpty, reason: '$gun: $metin');
        }
      }
      expect(gorulen, greaterThan(15));
    });

    test('harita bilinmiyorsa okuma eskisi gibi kurulur (portresiz)', () {
      final Okuyucu o = okuyucu();
      for (int i = 0; i < 20; i++) {
        final String metin = enerji(o, DateTime(2026, 9, 1 + i));
        expect(metin.contains('Yükselenin'), isFalse, reason: metin);
        expect(metin.contains('Ay burcun'), isFalse, reason: metin);
        expect(metin.contains('Dışarıdan'), isFalse, reason: metin);
      }
    });

    test('aynı gün hep aynı portre (deterministik)', () {
      final Okuyucu o = okuyucu(dogumAyi: Burc.yay, yukselen: Burc.akrep);
      final DateTime gun = DateTime(2026, 9, 14);
      expect(enerji(o, gun), enerji(o, gun));
    });
  });

  group('profilden okuyucuya doğum haritası', () {
    final DateTime dogum = DateTime(1992, 3, 14);

    test('saat ve yer yoksa yükselen aktarılmaz; Ay kesinse aktarılır', () {
      final UserProfile p = UserProfile(isim: 'Deniz', dogumTarihi: dogum);
      expect(p.okuyucu.yukselen, isNull);
      expect(
        p.okuyucu.dogumAyi,
        p.dogumHaritasi.ayBurcuKesin ? p.dogumHaritasi.ayBurcu : isNull,
      );
    });

    test('saat ve yer varsa yükselen de aktarılır (sınırda değilse)', () {
      final UserProfile p = UserProfile(
        isim: 'Deniz',
        dogumTarihi: dogum,
        dogumSaatiDakika: 9 * Duration.minutesPerHour + 30,
        dogumIliPlaka: 35,
      );
      final DogumHaritasi h = p.dogumHaritasi;
      expect(h.yukselen, isNotNull);
      expect(p.okuyucu.yukselen, h.yukselenSinirda ? isNull : h.yukselen);
      expect(p.okuyucu.dogumAyi, h.ayBurcuKesin ? h.ayBurcu : isNull);
    });

    test('kesin olmayan Ay burcu aktarılmaz', () {
      // Ay'ın o gün burç değiştirdiği bir doğum günü bulunur (saat yok).
      UserProfile? belirsiz;
      for (int i = 0; i < 60 && belirsiz == null; i++) {
        final UserProfile aday = UserProfile(
          isim: 'Deniz',
          dogumTarihi: DateTime(1990, 1, 1 + i),
        );
        if (!aday.dogumHaritasi.ayBurcuKesin) {
          belirsiz = aday;
        }
      }
      expect(belirsiz, isNotNull);
      expect(belirsiz!.okuyucu.dogumAyi, isNull);
    });
  });
}
