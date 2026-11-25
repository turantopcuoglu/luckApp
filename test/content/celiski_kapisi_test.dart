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
/// Kapının sözü: okuyucunun portresiyle (cevabı ya da burç elementinden
/// türetilen tarzı) çelişen hiçbir cümle günlük okumaya ya da kategori
/// okumasına giremez.
void main() {
  const LuckEngine motor = LuckEngine();

  /// On iki burcu kapsayan doğum tarihleri (her ayın 5'i; yıllar farklı
  /// yaşam yolu sayıları verecek şekilde kayar).
  final List<DateTime> dogumlar = <DateTime>[
    for (int ay = 1; ay <= DateTime.monthsPerYear; ay++)
      DateTime(1975 + ay * 2, ay, 5),
  ];

  /// Cevaplanmış ve atlanmış soruların bütün kombinasyonları (enerji ×
  /// karar × ilişki); uğraş sırayla döner.
  final List<OkuyucuTercihleri> tercihSetleri = <OkuyucuTercihleri>[
    for (final EnerjiTarzi? e in <EnerjiTarzi?>[null, ...EnerjiTarzi.values])
      for (final KararTarzi? k in <KararTarzi?>[null, ...KararTarzi.values])
        for (final IliskiDurumu? i in <IliskiDurumu?>[
          null,
          ...IliskiDurumu.values,
        ])
          OkuyucuTercihleri(
            enerji: e,
            karar: k,
            iliski: i,
            ugras:
                <Ugras?>[null, ...Ugras.values][((e?.index ?? 2) +
                        (k?.index ?? 2) * 3 +
                        (i?.index ?? 3)) %
                    (Ugras.values.length + 1)],
          ),
  ];

  Okuyucu okuyucu(DateTime dogum, OkuyucuTercihleri tercihler) => Okuyucu(
    isim: 'Deniz',
    seed: UserSeed.fromIsim(isim: 'Deniz', dogumTarihi: dogum),
    profil: KaderProfili.hesapla(dogumTarihi: dogum),
    tercihler: tercihler,
  );

  /// Kapıdan geçen portreler: enerji ve karar her zaman doludur (cevap ya
  /// da türetme), ilişki durumu bilinmeyebilir.
  final List<OkuyucuTercihleri> portreler = <OkuyucuTercihleri>[
    for (final EnerjiTarzi e in EnerjiTarzi.values)
      for (final KararTarzi k in KararTarzi.values)
        for (final IliskiDurumu? i in <IliskiDurumu?>[
          null,
          ...IliskiDurumu.values,
        ])
          OkuyucuTercihleri(enerji: e, karar: k, iliski: i),
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

    test('verilen cevap esastır', () {
      for (final DateTime d in dogumlar) {
        for (final OkuyucuTercihleri t in tercihSetleri) {
          final OkuyucuTercihleri p = okuyucu(d, t).portre;
          if (t.enerji != null) {
            expect(p.enerji, t.enerji);
          }
          if (t.karar != null) {
            expect(p.karar, t.karar);
          }
        }
      }
    });

    test('atlanan enerji ve karar burcun elementinden türetilir; ilişki ve '
        'uğraş türetilmez', () {
      for (final DateTime d in dogumlar) {
        final Okuyucu o = okuyucu(d, const OkuyucuTercihleri());
        final BurcElementi element = o.profil.burc.element;
        expect(o.portre.enerji, Okuyucu.elementEnerjisi[element]);
        expect(o.portre.karar, Okuyucu.elementKarari[element]);
        expect(o.portre.iliski, isNull);
        expect(o.portre.ugras, isNull);
      }
    });
  });

  group('çelişki eşleştirmesi', () {
    const OkuyucuTercihleri disaDonuk = OkuyucuTercihleri(
      enerji: EnerjiTarzi.disaDonuk,
      iliski: IliskiDurumu.evli,
    );
    const OkuyucuTercihleri akil = OkuyucuTercihleri(
      karar: KararTarzi.akil,
      iliski: IliskiDurumu.evli,
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

    test('ilişki durumu bilinmiyorsa iki varsayım da elenir', () {
      const String partnerVarsayan =
          'Partnerinin mutluluğunu kendi mutluluğunun önüne koymaya yatkınsın.';
      const String bekarVarsayan =
          'Flört senin için bir oyun gibi; ama ciddileştiğinde sandığından '
          'derin bağlanırsın.';
      const OkuyucuTercihleri bilinmiyor = OkuyucuTercihleri();
      const OkuyucuTercihleri bekar = OkuyucuTercihleri(
        iliski: IliskiDurumu.bekar,
      );
      const OkuyucuTercihleri evli = OkuyucuTercihleri(
        iliski: IliskiDurumu.evli,
      );
      expect(KisilikMetinleri.celisir(partnerVarsayan, bilinmiyor), isTrue);
      expect(KisilikMetinleri.celisir(bekarVarsayan, bilinmiyor), isTrue);
      expect(KisilikMetinleri.celisir(partnerVarsayan, bekar), isTrue);
      expect(KisilikMetinleri.celisir(bekarVarsayan, bekar), isFalse);
      expect(KisilikMetinleri.celisir(partnerVarsayan, evli), isFalse);
      expect(KisilikMetinleri.celisir(bekarVarsayan, evli), isTrue);
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
    int kalan(List<String> havuz, OkuyucuTercihleri p) =>
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
        for (final OkuyucuTercihleri p in portreler) {
          expect(
            kalan(h, p),
            greaterThanOrEqualTo(enAz),
            reason:
                '$ad · ${p.enerji?.name}/${p.karar?.name}/'
                '${p.iliski?.name}: ${h.first}',
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

    test('12 burç × 36 cevap kombinasyonu × $gunSayisi gün: günlük okuma ve '
        'beş kategori okuması', () {
      final List<String> sizintilar = <String>[];
      for (final DateTime dogum in dogumlar) {
        for (final OkuyucuTercihleri t in tercihSetleri) {
          final Okuyucu o = okuyucu(dogum, t);
          final OkuyucuTercihleri portre = o.portre;
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
                  '${portre.enerji?.name}/${portre.karar?.name}/'
                  '${portre.iliski?.name} $gun: $metin',
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
