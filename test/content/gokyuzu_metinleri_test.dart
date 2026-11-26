import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/dongu_metinleri.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gokyuzu_metinleri.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/kisilik_metinleri.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/sayi_metinleri.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
import 'package:kader/core/content/tr_icerik_paketi.dart';
import 'package:kader/core/content/yorum_yonu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Gökyüzü havuzlarındaki tüm metinler.
List<String> _tumMetinler() => <String>[
  for (final Map<KategoriTonu, List<String>> t
      in GokyuzuMetinleri.basliklar.values)
    ...t.values.expand((List<String> l) => l),
  for (final Map<ElementIliskisi, Map<KategoriTonu, List<String>>> i
      in GokyuzuMetinleri.gokyuzu.values)
    for (final Map<KategoriTonu, List<String>> t in i.values)
      ...t.values.expand((List<String> l) => l),
  for (final Map<SahneYonu, List<String>> y in GokyuzuMetinleri.sahneler.values)
    ...y.values.expand((List<String> l) => l),
  for (final Map<KategoriTonu, List<String>> t in GokyuzuMetinleri.yap.values)
    ...t.values.expand((List<String> l) => l),
  for (final Map<KategoriTonu, List<String>> t in GokyuzuMetinleri.yapma.values)
    ...t.values.expand((List<String> l) => l),
  for (final Map<LuckCategory, List<String>> k in KisilikMetinleri.burc.values)
    ...k.values.expand((List<String> l) => l),
  for (final Map<GunTonu, List<String>> t in GokyuzuMetinleri.gunler.values)
    ...t.values.expand((List<String> l) => l),
  for (final Map<String, String> u
      in KisilikMetinleri.profilUyarlamalari.values)
    ...u.values,
];

/// Kelime başında [ifade] geçiyor mu? ("bölüm" içindeki "ölüm" serbest.)
bool _kelimeBasindaGecer(String metin, String ifade) => RegExp(
  '(^|[^a-zçğıöşüâîû])${RegExp.escape(ifade)}',
).hasMatch(metin.toLowerCase());

void main() {
  const LuckEngine motor = LuckEngine();
  final DateTime gun = DateTime(2026, 10, 20);

  Okuyucu okuyucu({String isim = 'Ece', DateTime? dogumTarihi}) {
    final DateTime d = dogumTarihi ?? DateTime(1999, 10, 14); // Terazi
    return Okuyucu(
      isim: isim,
      seed: UserSeed.fromIsim(isim: isim, dogumTarihi: d),
      profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: '$isim Yılmaz'),
    );
  }

  LuckResult sonucKur(Map<LuckCategory, int> skorlar, {DateTime? hangiGun}) =>
      LuckResult(
        gun: hangiGun ?? gun,
        genelSkor: 60,
        kategoriSkorlari: skorlar,
        modifiyerler: const <LuckModifier>[],
      );

  final Map<LuckCategory, int> skorlar = <LuckCategory, int>{
    LuckCategory.ask: 55,
    LuckCategory.para: 50,
    LuckCategory.saglik: 82,
    LuckCategory.risk: 45,
    LuckCategory.sosyal: 30,
  };

  group('havuz bütünlüğü', () {
    test('her kategori × element ilişkisi × ton dolu ve varyantlı', () {
      expect(
        GokyuzuMetinleri.gokyuzu.keys.toSet(),
        LuckCategory.values.toSet(),
      );
      for (final LuckCategory k in LuckCategory.values) {
        for (final ElementIliskisi i in ElementIliskisi.values) {
          for (final KategoriTonu t in KategoriTonu.values) {
            final List<String> h = GokyuzuMetinleri.gokyuzu[k]![i]![t]!;
            expect(
              h.length,
              greaterThanOrEqualTo(ContentConfig.enAzGokyuzuVaryanti),
              reason: '$k $i $t',
            );
            expect(h.toSet(), hasLength(h.length), reason: 'tekrar: $k $i $t');
            for (final String m in h) {
              // Günün gerekçesi her zaman gökyüzüdür.
              expect(m, contains('{ayBurcu}'), reason: m);
              expect(m.startsWith('Bugün'), isFalse, reason: m);
            }
          }
          expect(
            GokyuzuMetinleri.basliklar[k]!.keys.toSet(),
            KategoriTonu.values.toSet(),
          );
          expect(
            GokyuzuMetinleri.yap[k]!.keys.toSet(),
            KategoriTonu.values.toSet(),
          );
          expect(
            GokyuzuMetinleri.yapma[k]!.keys.toSet(),
            KategoriTonu.values.toSet(),
          );
        }
        for (final KategoriTonu t in KategoriTonu.values) {
          for (final Map<LuckCategory, Map<KategoriTonu, List<String>>> havuz
              in <Map<LuckCategory, Map<KategoriTonu, List<String>>>>[
                GokyuzuMetinleri.basliklar,
                GokyuzuMetinleri.yap,
                GokyuzuMetinleri.yapma,
              ]) {
            expect(
              havuz[k]![t]!.length,
              greaterThanOrEqualTo(ContentConfig.enAzGokyuzuVaryanti),
            );
          }
          // Gösterilen öneri sayısı havuzdan büyük olamaz (tekrar olurdu).
          expect(
            GokyuzuMetinleri.yap[k]![t]!.length,
            greaterThanOrEqualTo(ContentConfig.gokyuzuYapSayisi),
          );
          expect(
            GokyuzuMetinleri.yapma[k]![t]!.length,
            greaterThanOrEqualTo(ContentConfig.gokyuzuYapmaSayisi),
          );
        }
      }
    });

    test('sahneler her kategoride iki yönü kapsar ve varyantlı', () {
      expect(
        GokyuzuMetinleri.sahneler.keys.toSet(),
        LuckCategory.values.toSet(),
      );
      for (final Map<SahneYonu, List<String>> y
          in GokyuzuMetinleri.sahneler.values) {
        expect(y.keys.toSet(), SahneYonu.values.toSet());
        for (final List<String> h in y.values) {
          expect(
            h.length,
            greaterThanOrEqualTo(ContentConfig.enAzGokyuzuVaryanti),
          );
        }
      }
    });
  });

  group('açılış paragrafı (günün gökyüzü)', () {
    test('her element ilişkisi × gün tonu dolu, Ay burcunu anar', () {
      for (final ElementIliskisi i in ElementIliskisi.values) {
        for (final GunTonu t in GunTonu.values) {
          final List<String> h = GokyuzuMetinleri.gunler[i]![t]!;
          expect(
            h.length,
            greaterThanOrEqualTo(ContentConfig.enAzGokyuzuVaryanti),
          );
          for (final String m in h) {
            expect(m, contains('{ayBurcu}'), reason: m);
            expect(m.startsWith('Bugün'), isFalse, reason: m);
          }
        }
      }
    });

    test('ikinci cümle günün gökyüzü; buluşma ve sahne gün aşırı', () {
      final Okuyucu o = okuyucu();
      final List<String> tumGunCumleleri = <String>[
        for (final Map<GunTonu, List<String>> t
            in GokyuzuMetinleri.gunler.values)
          for (final List<String> l in t.values)
            for (final String m in l)
              m
                  .replaceAll(
                    '{ayBurcu}',
                    trIcerik.burcAdi(Astronomi.gununAyBurcu(gun)),
                  )
                  .replaceAll('{burc}', trIcerik.burcAdi(o.profil.burc)),
      ];
      String? oncekiGokyuzu;
      for (int i = 0; i < 60; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final String ayBurcu = trIcerik.burcAdi(Astronomi.gununAyBurcu(g));
        final String acilis = gunlukOkuma(
          motor: motor,
          okuyucu: o,
          sonuc: motor.hesapla(kullanici: o.seed, gun: g),
        ).bolumler.first.metin;
        final List<String> cumleler = acilis
            .split(RegExp(r'(?<=[.!?])\s+'))
            .toList();
        // Açılış + gökyüzü + (buluşma | sahne) + öneri; buluşma iki
        // cümle olabilir.
        expect(cumleler.length, greaterThanOrEqualTo(4), reason: acilis);
        expect(cumleler[1], contains(ayBurcu), reason: acilis);
        if (i == 0) {
          expect(tumGunCumleleri, contains(cumleler[1]));
        }
        // Aynı cümle art arda iki gün gelmez.
        expect(cumleler[1], isNot(oncekiGokyuzu), reason: '$g');
        oncekiGokyuzu = cumleler[1];
      }
    });
  });

  group('kişilik cümleleri', () {
    // Olası bütün portreler (enerji × karar; K7'den beri element türetir).
    final List<Portre> kombinasyonlar = <Portre>[
      for (final EnerjiTarzi e in EnerjiTarzi.values)
        for (final KararTarzi k in KararTarzi.values)
          Portre(enerji: e, karar: k),
    ];

    test('her burç × kategori dolu; her portrede uyumlu cümle kalır', () {
      expect(KisilikMetinleri.burc.keys.toSet(), Burc.values.toSet());
      for (final Burc b in Burc.values) {
        for (final LuckCategory k in LuckCategory.values) {
          final List<String> h = KisilikMetinleri.burc[b]![k]!;
          expect(h.length, greaterThanOrEqualTo(3), reason: '$b $k');
          for (final Portre t in kombinasyonlar) {
            // En az iki uyumlu cümle: tek seçenek kalırsa aynı cümle
            // ayda çok kez tekrar eder.
            expect(
              h.where((String m) => !KisilikMetinleri.celisir(m, t)).length,
              greaterThanOrEqualTo(2),
              reason: '$b $k: $t',
            );
          }
        }
      }
    });

    test('her yaşam yolu × kategori tarzında da uyumlu cümle kalır', () {
      for (final MapEntry<int, KarakterYonu> e
          in YorumYonu.karakterler.entries) {
        for (final LuckCategory k in LuckCategory.values) {
          for (final Portre t in kombinasyonlar) {
            expect(
              e.value.kategoriTarzi[k]!
                  .where((String m) => !KisilikMetinleri.celisir(m, t))
                  .length,
              // Yeterli değilse okuma o gün burç cümlesine geçer (bkz.
              // ContentConfig.enAzKisilikSecenegi); boş kalmaması yeter.
              greaterThanOrEqualTo(1),
              reason: '${e.key} $k: $t',
            );
          }
        }
      }
    });

    test('günlük öneriler her portrede en az iki seçenek bırakır', () {
      for (final MapEntry<int, KarakterYonu> e
          in YorumYonu.karakterler.entries) {
        for (final BulusmaTuru b in BulusmaTuru.values) {
          for (final Portre t in kombinasyonlar) {
            expect(
              e.value
                  .tavsiyeler(b)
                  .where((String m) => !KisilikMetinleri.celisir(m, t))
                  .length,
              greaterThanOrEqualTo(2),
              reason: '${e.key} $b',
            );
          }
        }
      }
    });

    test('çelişki süzgeci bilinen çelişkileri ayıklar', () {
      const Portre disaDonuk = Portre(
        enerji: EnerjiTarzi.disaDonuk,
        karar: KararTarzi.kalp,
      );
      expect(
        KisilikMetinleri.celisir(
          'Kalabalık yerine az ve derin ilişkileri tercih edersin.',
          disaDonuk,
        ),
        isTrue,
      );
      expect(
        KisilikMetinleri.celisir(
          'Kalabalık yerine az ve derin ilişkileri tercih edersin.',
          const Portre(enerji: EnerjiTarzi.iceDonuk, karar: KararTarzi.kalp),
        ),
        isFalse,
      );
      expect(
        KisilikMetinleri.celisir(
          'Partnerinin mutluluğunu öne koyarsın.',
          disaDonuk,
        ),
        isTrue,
      );
    });

    test('profil metinleri hiçbir portrede portreyle çelişmez', () {
      for (final MapEntry<int, SayiKarakteri> e
          in SayiMetinleri.yasamYolu.entries) {
        final SayiKarakteri k = e.value;
        for (final Portre t in kombinasyonlar) {
          for (final String alan in <String>[
            k.oz,
            k.gucluYanlar,
            k.golgeYan,
            k.askta,
            k.isteVeParada,
            k.yasamDersi,
          ]) {
            final String uyarlanmis = KisilikMetinleri.profilMetniniUyarla(
              alan,
              t,
            );
            expect(
              KisilikMetinleri.celisir(uyarlanmis, t),
              isFalse,
              reason: '${e.key}: $uyarlanmis',
            );
          }
        }
      }
    });

    test('uyarlanan her cümle yaşam yolu metinlerinde gerçekten geçer', () {
      final String hepsi = <String>[
        for (final SayiKarakteri k
            in SayiMetinleri.yasamYolu.values) ...<String>[
          k.oz,
          k.gucluYanlar,
          k.golgeYan,
          k.askta,
          k.isteVeParada,
          k.yasamDersi,
        ],
      ].join(' ');
      for (final String cumle in KisilikMetinleri.profilUyarlamalari.keys) {
        expect(hepsi, contains(cumle));
      }
    });
  });

  group('metin kuralları', () {
    final List<String> metinler = _tumMetinler();

    test('onboarding cevaplarını geri söylemez', () {
      for (final String m in metinler) {
        for (final String yanki in ContentConfig.yankiIfadeleri) {
          expect(
            _kelimeBasindaGecer(m, yanki),
            isFalse,
            reason: '"$yanki" cevabı geri söylüyor: "$m"',
          );
        }
      }
    });

    test('yasaklı ifade ve numeroloji jargonu içermez', () {
      for (final String m in metinler) {
        for (final String yasak in <String>[
          ...ContentConfig.yasakliIfadeler,
          'kişisel gün',
          'yaşam yolu',
          'yıldız',
          'evren',
          'sayın',
          'uygun bir gün',
          'elverişli bir gün',
        ]) {
          expect(_kelimeBasindaGecer(m, yasak), isFalse, reason: '$yasak: $m');
        }
      }
    });

    test('yalnızca {ayBurcu} ve {burc} yer tutucuları; biçim temiz', () {
      for (final String m in metinler) {
        expect(
          slotlariBul(
            m,
          ).difference(<String>{SlotAnahtarlari.ayBurcu, SlotAnahtarlari.burc}),
          isEmpty,
          reason: m,
        );
        expect(m.trim(), m);
        expect(m.contains('  '), isFalse, reason: m);
        expect(RegExp(r'[.!?]$').hasMatch(m), isTrue, reason: m);
      }
    });
  });

  group('kategoriOkumasi (gökyüzü)', () {
    test('başlık, Ay burcunu anan paragraf, iki yap ve iki yapma', () {
      final String ayBurcu = trIcerik.burcAdi(Astronomi.gununAyBurcu(gun));
      for (final LuckCategory k in LuckCategory.values) {
        final KategoriOkumasi o = kategoriOkumasi(
          motor: motor,
          okuyucu: okuyucu(),
          sonuc: sonucKur(skorlar),
          kategori: k,
        );
        expect(o.baslik, isNotNull, reason: '$k');
        expect(o.paragraf, contains(ayBurcu), reason: o.paragraf);
        expect(o.paragraf.contains('{'), isFalse);
        expect(o.yap, hasLength(ContentConfig.gokyuzuYapSayisi));
        expect(o.yapma, hasLength(ContentConfig.gokyuzuYapmaSayisi));
        expect(o.yap.toSet(), hasLength(o.yap.length));
        expect(o.yapma.toSet(), hasLength(o.yapma.length));
        expect(o.eylem, contains(o.sansliSaat.etiket));
      }
    });

    test('kişilik cümlesi burçtan ya da yaşam yolundan gelir, portreyle '
        'çelişmez; günlük kart ve detay farklı kaynağı kullanır', () {
      final Okuyucu o = okuyucu();
      final Portre t = o.portre;
      final String burcAdi = trIcerik.burcAdi(o.profil.burc);
      final List<String> burcCumleleri = <String>[
        for (final List<String> h
            in KisilikMetinleri.burc[o.profil.burc]!.values)
          for (final String m in h) m.replaceAll('{burc}', burcAdi),
      ];
      final List<String> sayiCumleleri = <String>[
        for (final List<String> h
            in YorumYonu
                .karakterler[o.profil.yasamYolu.deger]!
                .kategoriTarzi
                .values)
          ...h,
      ];
      for (int i = 0; i < 20; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult s = motor.hesapla(kullanici: o.seed, gun: g);
        for (final LuckCategory k in LuckCategory.values) {
          final String p = kategoriOkumasi(
            motor: motor,
            okuyucu: o,
            sonuc: s,
            kategori: k,
          ).paragraf;
          final bool burctan = burcCumleleri.any(p.contains);
          final bool sayidan = sayiCumleleri.any(p.contains);
          expect(burctan != sayidan, isTrue, reason: '$g $k: $p');
          for (final String m in <String>[...burcCumleleri, ...sayiCumleleri]) {
            if (p.contains(m)) {
              expect(KisilikMetinleri.celisir(m, t), isFalse, reason: m);
            }
          }
          // Detay tek günlerde burç, çift günlerde yaşam yolu kullanır;
          // günlük kart tersini (bkz. ContentConfig.kisilikDonusumu).
          final bool sayiYeterli =
              YorumYonu.karakterler[o.profil.yasamYolu.deger]!.kategoriTarzi[k]!
                  .where((String m) => !KisilikMetinleri.celisir(m, t))
                  .length >=
              ContentConfig.enAzKisilikSecenegi;
          expect(
            burctan,
            LuckEngine.gunNumarasi(g) % ContentConfig.kisilikDonusumu != 0 ||
                !sayiYeterli,
            reason: '$g $k',
          );
        }
      }
    });

    test('sahne ve Yap önerileri her kategoride genel havuzdan gelir', () {
      for (final LuckCategory k in LuckCategory.values) {
        final KategoriOkumasi o = kategoriOkumasi(
          motor: motor,
          okuyucu: okuyucu(),
          sonuc: sonucKur(skorlar),
          kategori: k,
        );
        expect(
          GokyuzuMetinleri.sahneler[k]![SahneYonu.tondan(o.ton)]!.any(
            o.paragraf.endsWith,
          ),
          isTrue,
          reason: '$k: ${o.paragraf}',
        );
        for (final String y in o.yap) {
          expect(GokyuzuMetinleri.yap[k]![o.ton]!, contains(y), reason: '$k');
        }
      }
    });

    test('deterministik; tüm kategoriler gökyüzü yapısında', () {
      for (final LuckCategory k in LuckCategory.values) {
        KategoriOkumasi uret() => kategoriOkumasi(
          motor: motor,
          okuyucu: okuyucu(),
          sonuc: sonucKur(skorlar),
          kategori: k,
        );
        final KategoriOkumasi a = uret();
        final KategoriOkumasi b = uret();
        expect(a.paragraf, b.paragraf);
        expect(a.baslik, b.baslik);
        expect(a.yap, b.yap);
        expect(a.yapma, b.yapma);
        expect(a.baslik, isNotNull);
        expect(a.yap, isNotEmpty);
        expect(a.yapma, isNotEmpty);
      }
    });

    test('aynı gün herkes için aynı Ay burcu, kişiye göre farklı metin', () {
      final String ayBurcu = trIcerik.burcAdi(Astronomi.gununAyBurcu(gun));
      final KategoriOkumasi terazi = kategoriOkumasi(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: sonucKur(skorlar),
        kategori: LuckCategory.saglik,
      );
      final KategoriOkumasi yengec = kategoriOkumasi(
        motor: motor,
        okuyucu: okuyucu(isim: 'Deniz', dogumTarihi: DateTime(1997, 7, 2)),
        sonuc: sonucKur(skorlar),
        kategori: LuckCategory.saglik,
      );
      expect(terazi.paragraf, contains(ayBurcu));
      expect(yengec.paragraf, contains(ayBurcu));
      expect(terazi.paragraf, isNot(yengec.paragraf));
    });

    test('düşük günde koruyucu, iyi günde fırsat sahnesi seçilir', () {
      final Okuyucu o = okuyucu();
      for (final (int skor, SahneYonu yon) in <(int, SahneYonu)>[
        (20, SahneYonu.temkin),
        (55, SahneYonu.akis),
        (90, SahneYonu.akis),
      ]) {
        final KategoriOkumasi ok = kategoriOkumasi(
          motor: motor,
          okuyucu: o,
          sonuc: sonucKur(<LuckCategory, int>{
            ...skorlar,
            LuckCategory.saglik: skor,
          }),
          kategori: LuckCategory.saglik,
        );
        expect(
          GokyuzuMetinleri.sahneler[LuckCategory.saglik]![yon]!.any(
            ok.paragraf.endsWith,
          ),
          isTrue,
          reason: '$skor: ${ok.paragraf}',
        );
      }
    });

    test('detay sayfası aynı gün günlük kartla aynı cümleyi göstermez', () {
      final Okuyucu o = okuyucu();
      for (int i = 0; i < 30; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final LuckResult s = motor.hesapla(kullanici: o.seed, gun: g);
        final GunlukOkuma gunluk = gunlukOkuma(
          motor: motor,
          okuyucu: o,
          sonuc: s,
        );
        for (final OkumaBolumu b in gunluk.bolumler) {
          final LuckCategory? k = b.kategori;
          if (k == null) {
            continue;
          }
          final KategoriOkumasi detay = kategoriOkumasi(
            motor: motor,
            okuyucu: o,
            sonuc: s,
            kategori: k,
          );
          final List<String> detayCumleleri = detay.paragraf
              .split(RegExp(r'(?<=[.!?])\s+'))
              .toList();
          for (final String c in detayCumleleri) {
            expect(b.metin.contains(c), isFalse, reason: '$g $k: $c');
          }
        }
      }
    });

    test('30 günde aynı paragraf art arda gelmez ve sık tekrarlanmaz', () {
      final Okuyucu o = okuyucu();
      for (final LuckCategory k in LuckCategory.values) {
        final List<String> paragraflar = <String>[
          for (int i = 0; i < 30; i++)
            kategoriOkumasi(
              motor: motor,
              okuyucu: o,
              sonuc: motor.hesapla(
                kullanici: o.seed,
                gun: gun.add(Duration(days: i)),
              ),
              kategori: k,
            ).paragraf,
        ];
        for (int i = 1; i < paragraflar.length; i++) {
          expect(paragraflar[i], isNot(paragraflar[i - 1]), reason: '$k $i');
        }
        final Map<String, int> sayac = <String, int>{};
        for (final String p in paragraflar) {
          sayac[p] = (sayac[p] ?? 0) + 1;
        }
        expect(
          sayac.values.reduce((int a, int b) => a > b ? a : b),
          lessThan(3),
        );
      }
    });
  });

  group('gunlukOkuma (gökyüzü kategorileri)', () {
    test('öne çıkan Sağlık: gökyüzü + kişilik + sahne + eylem', () {
      final GunlukOkuma g = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: sonucKur(skorlar),
      );
      final OkumaBolumu parlayan = g.bolumler.firstWhere(
        (OkumaBolumu b) => b.tur == OkumaBolumTuru.parlayan,
      );
      expect(parlayan.kategori, LuckCategory.saglik);
      // Ay burcu açılış paragrafında anılır; öne çıkan alan onu tekrar
      // etmez (okuma makine işi gibi okunmasın).
      final String ayBurcu = trIcerik.burcAdi(Astronomi.gununAyBurcu(gun));
      expect(g.bolumler.first.metin, contains(ayBurcu));
      expect(parlayan.metin, isNot(contains(ayBurcu)));
      expect(parlayan.metin, contains(g.sansliSaat.etiket));
      final Okuyucu o = okuyucu();
      final String burcAdi = trIcerik.burcAdi(o.profil.burc);
      final List<String> kisilikler = <String>[
        for (final String m
            in KisilikMetinleri.burc[o.profil.burc]![LuckCategory.saglik]!)
          m.replaceAll('{burc}', burcAdi),
        ...YorumYonu
            .karakterler[o.profil.yasamYolu.deger]!
            .kategoriTarzi[LuckCategory.saglik]!,
      ];
      expect(kisilikler.any(parlayan.metin.contains), isTrue);
    });

    test('dikkat Sosyal: gökyüzü cümlesi + bir "yapma" önerisi', () {
      final GunlukOkuma g = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: sonucKur(skorlar),
      );
      final OkumaBolumu dikkat = g.bolumler.firstWhere(
        (OkumaBolumu b) => b.tur == OkumaBolumTuru.dikkat,
      );
      expect(dikkat.kategori, LuckCategory.sosyal);
      expect(
        GokyuzuMetinleri.yapma[LuckCategory.sosyal]![KategoriTonu.dusuk]!.any(
          dikkat.metin.endsWith,
        ),
        isTrue,
        reason: dikkat.metin,
      );
    });
  });
}
