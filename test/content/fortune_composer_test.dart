import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/dongu_metinleri.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gokyuzu_metinleri.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/neden_metinleri.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/tr_icerik_paketi.dart';
import 'package:kader/core/content/yorum_yonu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

void main() {
  const LuckEngine motor = LuckEngine();
  final DateTime dogum = DateTime(1994, 3, 14); // yaşam yolu 4
  final DateTime gun = DateTime(2026, 9, 13); // Ayşe için kişisel gün 4

  Okuyucu okuyucu({
    String isim = 'Ayşe',
    String? tamAd = 'Ayşe Yılmaz',
    DateTime? dogumTarihi,
    Burc? dogumAyi,
    Burc? yukselen,
  }) {
    final DateTime d = dogumTarihi ?? dogum;
    return Okuyucu(
      isim: isim,
      seed: UserSeed.fromIsim(isim: isim, dogumTarihi: d),
      profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: tamAd),
      dogumAyi: dogumAyi,
      yukselen: yukselen,
    );
  }

  LuckResult sonucKur({
    required int genel,
    required Map<LuckCategory, int> skorlar,
    DateTime? hangiGun,
  }) => LuckResult(
    gun: hangiGun ?? gun,
    genelSkor: genel,
    kategoriSkorlari: skorlar,
    modifiyerler: const <LuckModifier>[],
  );

  final Map<LuckCategory, int> ornekSkorlar = <LuckCategory, int>{
    LuckCategory.ask: 55,
    LuckCategory.para: 78,
    LuckCategory.saglik: 60,
    LuckCategory.risk: 50,
    LuckCategory.sosyal: 35,
  };

  /// Metni cümlelere böler (tekrar kontrolü için).
  List<String> cumleler(String metin) => metin
      .split(RegExp(r'(?<=[.!?])\s+'))
      .map((String c) => c.trim())
      .where((String c) => c.isNotEmpty)
      .toList();

  group('ayOnekisizHali', () {
    test("Ay'ı anan ilk yarıyı atar, Türkçe büyük harfle başlatır", () {
      expect(
        ayOnekisizHali(
          'Ay Yay burcunda, Balık burcunun elementine ters düşüyor; '
          'farklı fikirler çatışabilir.',
        ),
        'Farklı fikirler çatışabilir.',
      );
      expect(
        ayOnekisizHali('Ay Koç burcunda; içgüdülerin güçlü.'),
        'İçgüdülerin güçlü.',
      );
      expect(ayOnekisizHali('Ay Koç burcunda; ılık bir gün.'), 'Ilık bir gün.');
    });

    test('ikinci yarının başındaki "bugün" atılır', () {
      expect(
        ayOnekisizHali('Ay Boğa burcunda; bugün enerjin yüksek.'),
        'Enerjin yüksek.',
      );
    });

    test('ilk yarıya bağlı ya da ayraçsız cümlede null', () {
      expect(ayOnekisizHali('Ay Boğa burcunda; bu gerilim kıvılcım.'), isNull);
      expect(ayOnekisizHali('Ay Boğa burcunda; yine de temkinli ol.'), isNull);
      expect(
        ayOnekisizHali('Ay Boğa burcunda; yorgunluk hissi bundan.'),
        isNull,
      );
      expect(ayOnekisizHali('Ay Boğa burcunda: denge kolay.'), isNull);
    });
  });

  group('gunlukOkuma tutarlılığı', () {
    test('Ay burcu kategori bölümlerinde tekrar etmez (60 gün)', () {
      final Okuyucu o = okuyucu();
      for (int i = 0; i < 60; i++) {
        final DateTime g = DateTime(2026, 10, 1 + i);
        final GunlukOkuma r = gunlukOkuma(
          motor: motor,
          okuyucu: o,
          sonuc: motor.hesapla(kullanici: o.seed, gun: g),
        );
        final String ay = trIcerik.burcAdi(Astronomi.gununAyBurcu(g));
        for (final OkumaBolumu b in r.bolumler.skip(1)) {
          expect(b.metin, isNot(contains('$ay burcunda')), reason: '$g');
          expect(b.metin, isNot(contains('$ay burcundaki')), reason: '$g');
        }
      }
    });

    test('yalnız kalınca toparlanan okura kalabalık önerilmez (120 gün)', () {
      // 14 Mart: Balık (su), portresi içe dönük.
      final Okuyucu o = okuyucu();
      expect(o.portre.enerji, EnerjiTarzi.iceDonuk);
      for (int i = 0; i < 120; i++) {
        final DateTime g = DateTime(2026, 9, 1 + i);
        final String metin = gunlukOkuma(
          motor: motor,
          okuyucu: o,
          sonuc: motor.hesapla(kullanici: o.seed, gun: g),
        ).tamMetin.toLowerCase();
        for (final String ifade
            in ContentConfig.celiskiIfadeleri['iceDonuk']!) {
          expect(metin, isNot(contains(ifade)), reason: '$g: $ifade');
        }
      }
    });
  });

  group('gunlukOkuma', () {
    test('deterministik: aynı girdiler aynı okuma', () {
      final LuckResult s = motor.hesapla(kullanici: okuyucu().seed, gun: gun);
      final GunlukOkuma a = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: s,
      );
      final GunlukOkuma b = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: s,
      );
      expect(a.kartMetni, b.kartMetni);
      expect(a.baslik, b.baslik);
      expect(a.tavsiye, b.tavsiye);
      expect(a.sansRengi, b.sansRengi);
      expect(a.sansliSayi, b.sansliSayi);
    });

    test('yapı: üç bölüm (gün, öne çıkan alan, dikkat) + dönem cümlesi', () {
      final GunlukOkuma o = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar),
      );
      expect(o.bolumler.map((OkumaBolumu b) => b.tur), OkumaBolumTuru.values);
      expect(o.dongu.kisiselGun, 4);
      expect(DonguMetinleri.gunBasliklari[4], contains(o.baslik));
      expect(o.parlayanKategori, LuckCategory.para);
      expect(o.dikkatKategori, LuckCategory.sosyal);
      expect(
        YorumYonu.kapanisHavuzu(o.dongu.kisiselYil, o.dongu.kisiselAy),
        contains(o.kapanis),
      );
    });

    test('günün bölümü: tema durumu → günün gökyüzü → buluşma ya da sahne '
        '→ öneri', () {
      final Okuyucu o = okuyucu();
      final GunlukOkuma okuma = gunlukOkuma(
        motor: motor,
        okuyucu: o,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar),
      );
      final String metin = okuma.bolumler.first.metin;
      final KarakterYonu karakter = YorumYonu.karakterler[4]!;
      // Kişisel gün 4, yaşam yolu 4 için uyumlu → güç önerisi.
      expect(karakter.bulusma(4), BulusmaTuru.uyumlu);
      expect(karakter.gucTavsiyeleri.any(metin.contains), isTrue);
      expect(
        YorumYonu.gunTemalari[4]!.durum[GunTonu.yuksek]!.any(
          (String s) => metin.startsWith(s.replaceAll('{isim}', 'Ayşe')),
        ),
        isTrue,
      );
      // Günün Ay burcu açılışın hemen ardından anılır.
      expect(metin, contains(trIcerik.burcAdi(Astronomi.gununAyBurcu(gun))));
      // Buluşma cümlesi ve gündelik sahne gün aşırı dönüşümlüdür: sahne
      // burç günlerinde, buluşma (yaşam yolu) yaşam yolu günlerinde.
      final bool sahneVar = YorumYonu.gunSahneleri[4]!.any(metin.contains);
      expect(
        sahneVar,
        LuckEngine.gunNumarasi(gun) % ContentConfig.kisilikDonusumu == 0,
      );
    });

    test('aynı gün farklı karakterler farklı yön alır (zorlayıcı günde gölge '
        'önerisi)', () {
      // Yaşam yolu 5 (1990-05-15 → 5+6+1=12→3? hesapla ve seç).
      final List<DateTime> adaylar = <DateTime>[
        for (int i = 0; i < 400; i++) DateTime(1980, 1, 1 + i * 17),
      ];
      // Buluşma cümlesi (yaşam yolunun doğası) yaşam yolu günlerinde yer
      // alır (bkz. ContentConfig.kisilikDonusumu); test öyle bir günde.
      final DateTime sayiGunu =
          LuckEngine.gunNumarasi(gun) % ContentConfig.kisilikDonusumu != 0
          ? gun
          : DateTime(gun.year, gun.month, gun.day + 1);
      final Okuyucu ayse = okuyucu();
      final GunlukOkuma a = gunlukOkuma(
        motor: motor,
        okuyucu: ayse,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar, hangiGun: sayiGunu),
      );
      // Aynı takvim gününde zorlayıcı buluşma yaşayan bir kişi bul.
      final Okuyucu baska = adaylar
          .map((DateTime d) => okuyucu(isim: 'Deniz', dogumTarihi: d))
          .firstWhere((Okuyucu o) {
            final int k = GunDongusu.hesapla(
              dogumTarihi: o.profil.dogumTarihi,
              gun: sayiGunu,
            ).kisiselGun;
            return YorumYonu.karakterler[o.profil.yasamYolu.deger]!.bulusma(
                  k,
                ) ==
                BulusmaTuru.zorlayici;
          });
      final GunlukOkuma b = gunlukOkuma(
        motor: motor,
        okuyucu: baska,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar, hangiGun: sayiGunu),
      );
      final KarakterYonu kb =
          YorumYonu.karakterler[baska.profil.yasamYolu.deger]!;
      expect(kb.golgeTavsiyeleri.any(b.bolumler.first.metin.contains), isTrue);
      // Zorlayıcı buluşma cümlelerinden biri (slotları doldurulmuş hâliyle)
      // açılış paragrafında yer alır.
      expect(
        YorumYonu.bulusmaCumleleri[BulusmaTuru.zorlayici]!.any(
          (String sablon) => sablon
              .split(RegExp(r'\{[^}]+\}'))
              .map((String p) => p.trim())
              .where((String p) => p.length > 2)
              .every(b.bolumler.first.metin.contains),
        ),
        isTrue,
        reason: b.bolumler.first.metin,
      );
      expect(a.bolumler.first.metin, isNot(b.bolumler.first.metin));
    });

    test('öne çıkan Aşk bölümü ilişki durumu varsaymaz: genel sahne', () {
      final Map<LuckCategory, int> askBaskin = <LuckCategory, int>{
        LuckCategory.ask: 90,
        LuckCategory.para: 50,
        LuckCategory.saglik: 50,
        LuckCategory.risk: 50,
        LuckCategory.sosyal: 45,
      };
      final String parlayan = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: sonucKur(genel: 70, skorlar: askBaskin),
      ).bolumler[1].metin;
      expect(
        GokyuzuMetinleri.sahneler[LuckCategory.ask]![SahneYonu.akis]!.any(
          parlayan.contains,
        ),
        isTrue,
      );
    });

    test('2 yıl × harita durumları: yer tutucu, çift boşluk, cümle tekrarı '
        've numeroloji jargonu yok; okuma yeterince uzun', () {
      // (doğum Ay'ı, yükselen): yok; yalnız Ay; ikisi de.
      final List<(Burc?, Burc?)> haritalar = <(Burc?, Burc?)>[
        (null, null),
        (Burc.yengec, null),
        (Burc.akrep, Burc.terazi),
      ];
      final List<DateTime> dogumlar = <DateTime>[
        DateTime(1994, 3, 14),
        DateTime(1990, 5, 15),
        DateTime(1985, 11, 29),
        DateTime(2000, 11, 9), // usta sayı 22
      ];
      for (final (Burc? ay, Burc? yukselen) in haritalar) {
        for (final DateTime d in dogumlar) {
          final Okuyucu o = okuyucu(
            dogumTarihi: d,
            dogumAyi: ay,
            yukselen: yukselen,
          );
          for (int i = 0; i < 730; i += 5) {
            final LuckResult s = motor.hesapla(
              kullanici: o.seed,
              gun: DateTime(2026, 1, 1 + i),
            );
            final GunlukOkuma okuma = gunlukOkuma(
              motor: motor,
              okuyucu: o,
              sonuc: s,
            );
            final String metin = '${okuma.baslik} ${okuma.kartMetni}';
            expect(metin.contains('{'), isFalse, reason: metin);
            expect(metin.contains('  '), isFalse, reason: metin);
            final List<String> c = cumleler(okuma.tamMetin);
            expect(c.toSet().length, c.length, reason: 'tekrar: $metin');
            expect(metin.toLowerCase().contains('kişisel gün'), isFalse);
            expect(
              okuma.tamMetin.split(' ').length,
              greaterThanOrEqualTo(ContentConfig.gunlukEnAzKelime),
              reason: metin,
            );
          }
        }
      }
    });

    test('ardışık 30 günde günün bölümü büyük ölçüde farklı', () {
      final Okuyucu o = okuyucu();
      final Set<String> metinler = <String>{
        for (int i = 0; i < 30; i++)
          gunlukOkuma(
            motor: motor,
            okuyucu: o,
            sonuc: motor.hesapla(
              kullanici: o.seed,
              gun: DateTime(2026, 9, 1 + i),
            ),
          ).bolumler.first.metin,
      };
      // Tema ~9 günde bir tekrar eder; durum/buluşma varyantları ve tonlar
      // metni çoğu gün farklılaştırır.
      expect(metinler.length, greaterThanOrEqualTo(24));
    });

    test('beğenilmeyen durum cümlesi sonraki günlerde seçilmez', () {
      final Okuyucu o = okuyucu();
      final LuckResult s = sonucKur(genel: 70, skorlar: ornekSkorlar);
      final GunlukOkuma ilk = gunlukOkuma(motor: motor, okuyucu: o, sonuc: s);
      final GunlukOkuma filtreli = gunlukOkuma(
        motor: motor,
        okuyucu: o,
        sonuc: s,
        begenilmeyenler: <String>{
          for (final OkumaBolumu b in ilk.bolumler) b.kimlik,
        },
      );
      for (int i = 0; i < ilk.bolumler.length; i++) {
        expect(filtreli.bolumler[i].kimlik, isNot(ilk.bolumler[i].kimlik));
      }
    });

    test('begenilenleriSec en az bir varyant bırakır', () {
      final List<String> havuz = <String>['A.', 'B.'];
      String k(String m) => bolumKimligi(OkumaBolumTuru.enerji, m);
      expect(
        begenilenleriSec(havuz, OkumaBolumTuru.enerji, <String>{k('A.')}),
        <String>['B.'],
      );
      expect(
        begenilenleriSec(havuz, OkumaBolumTuru.enerji, <String>{
          k('A.'),
          k('B.'),
        }),
        havuz,
      );
    });

    test('neden öğeleri ayrı ayrı ve gerçek değerlerle', () {
      final DateTime g = DateTime(2026, 9, 13);
      final LuckResult s = motor.hesapla(kullanici: okuyucu().seed, gun: g);
      final GunlukOkuma okuma = gunlukOkuma(
        motor: motor,
        okuyucu: okuyucu(),
        sonuc: s,
      );
      final Set<String> etiketler = okuma.nedenler
          .map((NedenOgesi n) => n.etiket)
          .toSet();
      expect(etiketler.length, okuma.nedenler.length);
      // Ay evresi, Ay burcu ve günün sayısı çipleri var; denge çipi yok.
      final Set<NedenTuru> turler = okuma.nedenler
          .map((NedenOgesi n) => n.tur)
          .toSet();
      expect(
        turler,
        containsAll(<NedenTuru>[
          NedenTuru.ayEvresi,
          NedenTuru.ayBurcu,
          NedenTuru.gunSayisi,
        ]),
      );
      final NedenOgesi ayBurcu = okuma.nedenler.firstWhere(
        (NedenOgesi n) => n.tur == NedenTuru.ayBurcu,
      );
      expect(
        ayBurcu.etiket,
        contains(trIcerik.burcAdi(Astronomi.gununAyBurcu(g))),
      );
      final NedenOgesi kg = okuma.nedenler.firstWhere(
        (NedenOgesi n) => n.tur == NedenTuru.kisiselGun,
      );
      expect(kg.aciklama, contains(YorumYonu.gunTemalari[4]!.istek));
    });

    test('neden öğeleri hesaplama yöntemini ve puanı göstermez', () {
      // Düşük seri: motor denge etkisi uygular ama bu bir neden olarak
      // kullanıcıya gösterilmez.
      final LuckResult s = motor.hesapla(
        kullanici: okuyucu().seed,
        gun: gun,
        sonUcGunSkorlari: const <int>[10, 12, 15],
      );
      expect(
        s.modifiyerler.any((LuckModifier m) => m.ad == seriDengesiAdi),
        isTrue,
      );
      for (int i = 0; i < 40; i++) {
        final DateTime g = gun.add(Duration(days: i));
        final GunlukOkuma okuma = gunlukOkuma(
          motor: motor,
          okuyucu: okuyucu(),
          sonuc: i == 0 ? s : motor.hesapla(kullanici: okuyucu().seed, gun: g),
        );
        for (final NedenOgesi n in okuma.nedenler) {
          final String metin = '${n.etiket} ${n.aciklama}'.toLowerCase();
          for (final String yasak in <String>[
            'puan',
            'formül',
            'hesap',
            'toplan',
            'indirge',
            'herkes için aynı',
            'zor günlerin ardından',
            '+',
            '−',
            '±',
          ]) {
            expect(metin.contains(yasak), isFalse, reason: '$yasak: $metin');
          }
        }
      }
    });
  });

  group('çünkü satırı', () {
    /// 14 Mart doğumlu: Balık, su elementi.
    final DateTime dogum = DateTime(1992, 3, 14);

    test('dört element ilişkisinde de kişinin verisini adıyla söyler', () {
      // Ay'ın burcu: Yengeç (su, aynı), Boğa (toprak, tamamlayıcı),
      // Kova (hava, nötr), Koç (ateş, zıt).
      final Map<Burc, String> beklenen = <Burc, String>{
        Burc.yengec:
            'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık, elementin '
            'su. Ay da bugün bir su burcunda.',
        Burc.boga:
            'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık, elementin '
            'su. Ay bugün bir toprak burcunda, elementini besleyen yerde.',
        Burc.kova:
            'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık, elementin '
            'su. Ay bugün bir hava burcunda, elementine yabancı bir yerde.',
        Burc.koc:
            'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık, elementin '
            'su. Ay bugün bir ateş burcunda, elementinin tam karşısında.',
      };
      expect(
        beklenen.keys
            .map((Burc ay) => elementIliskisi(ay.element, Burc.balik.element))
            .toSet(),
        ElementIliskisi.values.toSet(),
      );
      for (final MapEntry<Burc, String> e in beklenen.entries) {
        expect(
          NedenMetinleri.cunku(
            dogumTarihi: dogum,
            gunesBurcu: Burc.balik,
            ayBurcu: e.key,
          ),
          e.value,
        );
      }
    });

    test('günlük okumada: doğum günü, burç ve element; Ay burç değiştirince '
        'değişir, aynı gün hep aynıdır', () {
      final Okuyucu o = Okuyucu(
        isim: 'Deniz',
        seed: UserSeed.fromIsim(isim: 'Deniz', dogumTarihi: dogum),
        profil: KaderProfili.hesapla(dogumTarihi: dogum),
      );
      final Set<String> satirlar = <String>{};
      for (int i = 0; i < 30; i++) {
        final DateTime g = DateTime(2026, 9, 1 + i);
        final LuckResult s = motor.hesapla(kullanici: o.seed, gun: g);
        final String cunku = gunlukOkuma(
          motor: motor,
          okuyucu: o,
          sonuc: s,
        ).cunku;
        expect(gunlukOkuma(motor: motor, okuyucu: o, sonuc: s).cunku, cunku);
        expect(
          cunku,
          NedenMetinleri.cunku(
            dogumTarihi: dogum,
            gunesBurcu: o.profil.burc,
            ayBurcu: Astronomi.gununAyBurcu(g),
          ),
        );
        expect(cunku, contains('14 Mart doğumlusun'));
        expect(cunku, contains('burcun Balık'));
        expect(cunku, contains('elementin su'));
        expect(cunku.contains('{'), isFalse, reason: cunku);
        satirlar.add(cunku);
      }
      // Bir ayda Ay dört elementi de dolaşır.
      expect(satirlar, hasLength(ElementIliskisi.values.length));
    });

    test('doğum haritası biliniyorsa üç noktayı da adıyla sayar', () {
      expect(
        NedenMetinleri.cunku(
          dogumTarihi: dogum,
          gunesBurcu: Burc.balik,
          ayBurcu: Burc.koc,
          dogumAyi: Burc.yengec,
          yukselen: Burc.aslan,
        ),
        'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık (su), Ay burcun '
        'Yengeç, yükselenin Aslan. Ay bugün bir ateş burcunda, elementinin '
        'tam karşısında.',
      );
      // Yalnızca Ay burcu (doğum saati ya da yeri yok).
      expect(
        NedenMetinleri.cunku(
          dogumTarihi: dogum,
          gunesBurcu: Burc.balik,
          ayBurcu: Burc.yengec,
          dogumAyi: Burc.yay,
        ),
        'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık (su), Ay burcun '
        'Yay. Ay da bugün bir su burcunda.',
      );
      // Yalnızca yükselen (Ay o gün burç değiştirdiği için kesin değil).
      expect(
        NedenMetinleri.cunku(
          dogumTarihi: dogum,
          gunesBurcu: Burc.balik,
          ayBurcu: Burc.yengec,
          yukselen: Burc.kova,
        ),
        'Sana özel, çünkü 14 Mart doğumlusun: burcun Balık (su), yükselenin '
        'Kova. Ay da bugün bir su burcunda.',
      );
    });

    test('yöntem, puan ya da yargı içermez; tek satır kadar kısadır', () {
      // En uzun hâl: uzun ay adı, en uzun burç adları, üç nokta birden.
      for (final Burc gunes in Burc.values) {
        for (final Burc ay in Burc.values) {
          final String cunku = NedenMetinleri.cunku(
            dogumTarihi: DateTime(1992, 11, 30),
            gunesBurcu: gunes,
            ayBurcu: ay,
            dogumAyi: Burc.ikizler,
            yukselen: Burc.ikizler,
          );
          final String kucuk = cunku.toLowerCase();
          for (final String yasak in <String>[
            'puan',
            'formül',
            'hesap',
            'toplan',
            'şans',
            'iyi',
            'kötü',
            '+',
            '−',
          ]) {
            expect(kucuk.contains(yasak), isFalse, reason: '$yasak: $cunku');
          }
          expect(
            cunku.length,
            lessThanOrEqualTo(ContentConfig.cunkuEnCokKarakter),
            reason: cunku,
          );
        }
      }
    });
  });

  group('baskın ve zayıf kategori', () {
    test('en yüksek skorlu kategori; eşitlikte enum sırası', () {
      expect(baskinKategori(ornekSkorlar), LuckCategory.para);
      expect(
        baskinKategori(<LuckCategory, int>{
          for (final LuckCategory k in LuckCategory.values) k: 50,
        }),
        LuckCategory.values.first,
      );
    });

    test('zayıf kategori baskından farklıdır, map sırası etkilemez', () {
      final Map<LuckCategory, int> ters = <LuckCategory, int>{
        for (final LuckCategory k in LuckCategory.values.reversed)
          k: ornekSkorlar[k]!,
      };
      expect(
        enZayifKategori(ters, haric: LuckCategory.para),
        LuckCategory.sosyal,
      );
    });
  });

  group('kategoriOkumasi', () {
    test('deterministik ve yer tutucusuz, her kategoride', () {
      final Okuyucu o = okuyucu();
      for (final LuckCategory kat in LuckCategory.values) {
        final KategoriOkumasi a = kategoriOkumasi(
          motor: motor,
          okuyucu: o,
          sonuc: sonucKur(genel: 50, skorlar: ornekSkorlar),
          kategori: kat,
        );
        final KategoriOkumasi b = kategoriOkumasi(
          motor: motor,
          okuyucu: o,
          sonuc: sonucKur(genel: 50, skorlar: ornekSkorlar),
          kategori: kat,
        );
        expect(a.paragraf, b.paragraf);
        expect(a.paragraf.contains('{'), isFalse);
        // Kategori paragrafı bilerek kısadır (başlık + üç cümle +
        // yap/yapma).
        expect(a.paragraf.split(' ').length, greaterThanOrEqualTo(15));
      }
    });
  });

  group('profilOkumasi', () {
    test('tam adla tüm bölümler, ücretsizler önce', () {
      final List<ProfilBolumu> bolumler = profilOkumasi(
        okuyucu: okuyucu(),
        gun: gun,
      );
      expect(bolumler.map((ProfilBolumu b) => b.tur), ProfilBolumTuru.values);
      expect(bolumler.first.baslik, contains('Kurucu'));
      expect(
        bolumler
            .where((ProfilBolumu b) => !b.premium)
            .map((ProfilBolumu b) => b.tur),
        <ProfilBolumTuru>[
          ProfilBolumTuru.oz,
          ProfilBolumTuru.gucluYanlar,
          ProfilBolumTuru.burc,
        ],
      );
      final ProfilBolumu yil = bolumler.firstWhere(
        (ProfilBolumu b) => b.tur == ProfilBolumTuru.yil,
      );
      expect(yil.metin, contains('2026 senin için bir 9 yılı'));
    });

    test('profil toplamı yeterince derin', () {
      final int kelime = profilOkumasi(okuyucu: okuyucu(), gun: gun)
          .map((ProfilBolumu b) => b.metin.split(' ').length)
          .fold(0, (int a, int b) => a + b);
      expect(
        kelime,
        greaterThanOrEqualTo(ContentConfig.profilToplamEnAzKelime),
      );
    });

    test('tam ad yoksa isim tabanlı bölümler çıkmaz', () {
      final Iterable<ProfilBolumTuru> turler = profilOkumasi(
        okuyucu: okuyucu(tamAd: null),
        gun: gun,
      ).map((ProfilBolumu b) => b.tur);
      expect(turler, isNot(contains(ProfilBolumTuru.icSes)));
      expect(turler, isNot(contains(ProfilBolumTuru.yansima)));
    });

    test('aşk bölümü ilişki durumu varsaymaz (bütün yaşam yolları)', () {
      // İlişki durumu sorulmuyor (K7); profil metni bekâr ya da partnerli
      // olduğunu varsayan bir ifade taşımamalı.
      final List<String> ifadeler = <String>[
        for (final String a in ContentConfig.iliskiVarsayimAnahtarlari)
          ...ContentConfig.celiskiIfadeleri[a]!,
      ];
      for (int i = 0; i < 400; i += 7) {
        final DateTime d = DateTime(1970, 1, 1 + i * 30);
        final String askta =
            profilOkumasi(
                  okuyucu: okuyucu(dogumTarihi: d),
                  gun: gun,
                )
                .firstWhere((ProfilBolumu b) => b.tur == ProfilBolumTuru.askta)
                .metin
                .toLowerCase();
        for (final String ifade in ifadeler) {
          expect(askta, isNot(contains(ifade)), reason: '$d: $ifade');
        }
      }
    });
  });

  group('uyumOkumasi', () {
    test('iki isim metinde yer alır, yer tutucu kalmaz', () {
      final UyumOkumasi u = uyumOkumasi(
        okuyucu: okuyucu(),
        digerIsim: 'Mert',
        digerProfil: KaderProfili.hesapla(
          dogumTarihi: DateTime(1991, 7, 30),
          tamAd: 'Mert Kaya',
        ),
      );
      final String hepsi = u.bolumler
          .map((UyumBolumu b) => '${b.baslik} ${b.metin}')
          .join(' ');
      expect(hepsi, contains('Ayşe'));
      expect(hepsi, contains('Mert'));
      expect(hepsi.contains('{'), isFalse);
      expect(u.bolumler.last.baslik, 'Tavsiye');
    });
  });
}
