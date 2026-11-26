import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/fortune_pools.dart';
import 'package:kader/core/content/gokyuzu_metinleri.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/kisilik_metinleri.dart';
import 'package:kader/core/content/kisisel_havuzlar.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Çelişki kapısı ve çekirdek portre testleri.
///
/// Kapının sözü: okuyucunun portresiyle (burç elementinden türetilen
/// tarzı) ya da bir ilişki varsayımıyla çelişen hiçbir cümle günlük okumaya
/// ya da kategori okumasına giremez.
void main() {
  const LuckEngine motor = LuckEngine();

  /// On iki burcu kapsayan doğum tarihleri (her ayın 5'i; yıllar farklı
  /// yaşam yolu sayıları verecek şekilde kayar).
  final List<DateTime> dogumlar = <DateTime>[
    for (int ay = 1; ay <= DateTime.monthsPerYear; ay++)
      DateTime(1975 + ay * 2, ay, 5),
  ];

  /// Doğum haritası durumları: yok; yalnız Ay; Ay ve yükselen (K7'den
  /// beri cevap seti yok, okuyucu yalnız doğum verisiyle değişir).
  const int haritaDurumu = 3;

  Okuyucu okuyucu(DateTime dogum, int h) => Okuyucu(
    isim: 'Deniz',
    seed: UserSeed.fromIsim(isim: 'Deniz', dogumTarihi: dogum),
    profil: KaderProfili.hesapla(dogumTarihi: dogum),
    dogumAyi: h >= 1 ? Burc.values[dogum.month % Burc.values.length] : null,
    yukselen: h >= 2
        ? Burc.values[(dogum.month + 5) % Burc.values.length]
        : null,
  );

  /// Olası bütün portreler (enerji × karar).
  final List<Portre> portreler = <Portre>[
    for (final EnerjiTarzi e in EnerjiTarzi.values)
      for (final KararTarzi k in KararTarzi.values) Portre(enerji: e, karar: k),
  ];

  group('çekirdek portre', () {
    test('doğum tarihleri on iki burcu kapsar', () {
      expect(
        dogumlar
            .map((DateTime d) => KaderProfili.hesapla(dogumTarihi: d).burc)
            .toSet(),
        Burc.values.toSet(),
      );
    });

    test('element eşlemeleri dört elementi de kapsar', () {
      expect(Okuyucu.elementEnerjisi.keys.toSet(), BurcElementi.values.toSet());
      expect(Okuyucu.elementKarari.keys.toSet(), BurcElementi.values.toSet());
    });

    test('portre burcun elementinden türetilir', () {
      for (final DateTime d in dogumlar) {
        final Okuyucu o = okuyucu(d, 0);
        final BurcElementi element = o.profil.burc.element;
        expect(o.portre.enerji, Okuyucu.elementEnerjisi[element]);
        expect(o.portre.karar, Okuyucu.elementKarari[element]);
      }
    });

    test('portre doğum haritasından etkilenmez', () {
      for (final DateTime d in dogumlar) {
        expect(okuyucu(d, 2).portre, okuyucu(d, 0).portre);
      }
    });
  });

  group('çelişki eşleştirmesi', () {
    const Portre disaDonuk = Portre(
      enerji: EnerjiTarzi.disaDonuk,
      karar: KararTarzi.kalp,
    );
    const Portre akil = Portre(
      enerji: EnerjiTarzi.iceDonuk,
      karar: KararTarzi.akil,
    );

    test('ifade yalnızca kelime başında eşleşir', () {
      // "az ama" ifadesi "biraz ama" içinde geçer ama kelime başında değil.
      expect(KisilikMetinleri.celisir('Az ama iyi insan.', disaDonuk), isTrue);
      expect(
        KisilikMetinleri.celisir('Biraz ama yeterince dinlen.', disaDonuk),
        isFalse,
      );
    });

    test('büyük İ ile başlayan cümle de yakalanır', () {
      expect(
        KisilikMetinleri.celisir('İlk hissin isabetli olabilir.', akil),
        isTrue,
      );
    });

    test('ilişki durumu bilinmediği için iki varsayım da her portrede '
        'elenir', () {
      const String partnerVarsayan =
          'Partnerinin mutluluğunu kendi mutluluğunun önüne koymaya yatkınsın.';
      const String bekarVarsayan =
          'Flört senin için bir oyun gibi; ama ciddileştiğinde sandığından '
          'derin bağlanırsın.';
      for (final Portre p in portreler) {
        expect(KisilikMetinleri.celisir(partnerVarsayan, p), isTrue);
        expect(KisilikMetinleri.celisir(bekarVarsayan, p), isTrue);
      }
    });

    test('kapı çelişenleri çıkarır; yeterli cümle kalmazsa havuzu korur', () {
      const List<String> havuz = <String>[
        'Az ama iyi insan.',
        'Bir dosta haber ver.',
      ];
      expect(KisilikMetinleri.uyumlular(havuz, disaDonuk), <String>[
        'Bir dosta haber ver.',
      ]);
      expect(KisilikMetinleri.uyumlular(havuz, disaDonuk, enAz: 2), havuz);
    });
  });

  group('genel havuzlar her portrede yeterli cümle bırakır', () {
    /// [havuz]da [p] portresiyle çelişmeyen cümle sayısı.
    int kalan(List<String> havuz, Portre p) =>
        havuz.where((String m) => !KisilikMetinleri.celisir(m, p)).length;

    /// İç içe haritalardaki bütün metin havuzları.
    Iterable<List<String>> havuzlar(Object? dugum) sync* {
      if (dugum is List<String>) {
        yield dugum;
      } else if (dugum is Map) {
        for (final Object? alt in dugum.values) {
          yield* havuzlar(alt);
        }
      }
    }

    void yeterli(Object? kaynak, int enAz, String ad) {
      for (final List<String> h in havuzlar(kaynak)) {
        for (final Portre p in portreler) {
          expect(
            kalan(h, p),
            greaterThanOrEqualTo(enAz),
            reason: '$ad · ${p.enerji.name}/${p.karar.name}: ${h.first}',
          );
        }
      }
    }

    test('kategori gökyüzü cümleleri ve başlıklar: en az iki seçenek', () {
      // Tek seçenek kalırsa aynı cümle Ay o elementteyken her gün gelir.
      yeterli(GokyuzuMetinleri.gokyuzu, 2, 'gokyuzu');
      yeterli(GokyuzuMetinleri.basliklar, 2, 'basliklar');
    });

    test('günün gökyüzü cümleleri: ardışık tekrarsızlık için tam havuz', () {
      yeterli(
        GokyuzuMetinleri.gunler,
        ContentConfig.tekrarsizEnAzHavuz,
        'gunler',
      );
    });

    test('Yap / Yapma: gösterilen öneri sayısı kadar cümle kalır', () {
      yeterli(GokyuzuMetinleri.yap, ContentConfig.gokyuzuYapSayisi, 'yap');
      yeterli(
        GokyuzuMetinleri.yapma,
        ContentConfig.gokyuzuYapmaSayisi,
        'yapma',
      );
    });

    test('eylem, tavsiye ve gölgesiz gün havuzları', () {
      yeterli(KisiselHavuzlar.eylemCumleleri, 2, 'eylem');
      yeterli(
        <String, List<String>>{
          'golgesizGun': KisiselHavuzlar.golgesizGun,
          'gununTavsiyeleri': FortunePools.gununTavsiyeleri,
        },
        2,
        'genel',
      );
    });
  });

  group('hiçbir okuma portreyle çelişmez', () {
    /// Taranan gün sayısı ve gün adımı: Ay burcu, kişisel gün ve skor
    /// tonlarının farklı birleşimlerine denk gelsin diye günler aralıklıdır.
    const int gunSayisi = 10;
    const int gunAdimi = 3;

    test('12 burç × $haritaDurumu harita durumu × $gunSayisi gün: günlük '
        'okuma ve beş kategori okuması', () {
      final List<String> sizintilar = <String>[];
      for (final DateTime dogum in dogumlar) {
        for (int h = 0; h < haritaDurumu; h++) {
          final Okuyucu o = okuyucu(dogum, h);
          final Portre portre = o.portre;
          for (int g = 0; g < gunSayisi; g++) {
            final DateTime gun = DateTime(2026, 9, 1 + g * gunAdimi);
            final LuckResult sonuc = motor.hesapla(kullanici: o.seed, gun: gun);
            final GunlukOkuma gunluk = gunlukOkuma(
              motor: motor,
              okuyucu: o,
              sonuc: sonuc,
            );
            final List<String> metinler = <String>[
              gunluk.baslik,
              gunluk.tamMetin,
              gunluk.kapanis,
              gunluk.tavsiye,
            ];
            for (final LuckCategory k in LuckCategory.values) {
              final KategoriOkumasi ko = kategoriOkumasi(
                motor: motor,
                okuyucu: o,
                sonuc: sonuc,
                kategori: k,
              );
              // Yap / Yapma listeleri her portrede tam gelir.
              expect(ko.yap, hasLength(ContentConfig.gokyuzuYapSayisi));
              expect(ko.yapma, hasLength(ContentConfig.gokyuzuYapmaSayisi));
              metinler.addAll(<String>[
                ?ko.baslik,
                ko.paragraf,
                ...ko.yap,
                ...ko.yapma,
                ko.eylem,
              ]);
            }
            for (final String metin in metinler) {
              if (KisilikMetinleri.celisir(metin, portre)) {
                sizintilar.add(
                  '${o.profil.burc.name} '
                  '${portre.enerji.name}/${portre.karar.name} h$h '
                  '$gun: $metin',
                );
              }
            }
          }
        }
      }
      expect(sizintilar, isEmpty);
    });
  });
}
