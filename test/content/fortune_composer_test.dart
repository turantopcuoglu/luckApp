import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/content_config.dart';
import 'package:kader/core/content/dongu_metinleri.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/kisisel_havuzlar.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/slot_doldurucu.dart';
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
    OkuyucuTercihleri tercihler = const OkuyucuTercihleri(),
  }) {
    final DateTime d = dogumTarihi ?? dogum;
    return Okuyucu(
      isim: isim,
      seed: UserSeed.fromIsim(isim: isim, dogumTarihi: d),
      profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: tamAd),
      tercihler: tercihler,
    );
  }

  LuckResult sonucKur({
    required int genel,
    required Map<LuckCategory, int> skorlar,
    DateTime? hangiGun,
  }) =>
      LuckResult(
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

  group('gunlukOkuma', () {
    test('deterministik: aynı girdiler aynı okuma', () {
      final LuckResult s = motor.hesapla(kullanici: okuyucu().seed, gun: gun);
      final GunlukOkuma a =
          gunlukOkuma(motor: motor, okuyucu: okuyucu(), sonuc: s);
      final GunlukOkuma b =
          gunlukOkuma(motor: motor, okuyucu: okuyucu(), sonuc: s);
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
      expect(YorumYonu.donemCumleleri[o.dongu.kisiselYil], contains(o.kapanis));
    });

    test('günün bölümü: tema durumu → doğayla buluşma → sahne → öneri', () {
      final Okuyucu o = okuyucu(
        tercihler: const OkuyucuTercihleri(ugras: Ugras.ogrenci),
      );
      final GunlukOkuma okuma = gunlukOkuma(
        motor: motor,
        okuyucu: o,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar),
      );
      final String metin = okuma.bolumler.first.metin;
      final KarakterYonu karakter = YorumYonu.karakterler[4]!;
      // Kişisel gün 4, yaşam yolu 4 için uyumlu → güç önerisi.
      expect(karakter.bulusma(4), BulusmaTuru.uyumlu);
      expect(metin, contains(karakter.gucTavsiyesi));
      expect(metin, contains(YorumYonu.gunSahneleri[4]!['ogrenci']));
      expect(
        YorumYonu.gunTemalari[4]!.durum[GunTonu.yuksek]!.any(
          (String s) => metin.startsWith(s.replaceAll('{isim}', 'Ayşe')),
        ),
        isTrue,
      );
    });

    test('aynı gün farklı karakterler farklı yön alır (zorlayıcı günde gölge '
        'önerisi)', () {
      // Yaşam yolu 5 (1990-05-15 → 5+6+1=12→3? hesapla ve seç).
      final List<DateTime> adaylar = <DateTime>[
        for (int i = 0; i < 400; i++) DateTime(1980, 1, 1 + i * 17),
      ];
      final Okuyucu ayse = okuyucu();
      final GunlukOkuma a = gunlukOkuma(
        motor: motor,
        okuyucu: ayse,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar),
      );
      // Aynı takvim gününde zorlayıcı buluşma yaşayan bir kişi bul.
      final Okuyucu baska = adaylar
          .map((DateTime d) => okuyucu(isim: 'Deniz', dogumTarihi: d))
          .firstWhere((Okuyucu o) {
        final int k =
            GunDongusu.hesapla(dogumTarihi: o.profil.dogumTarihi, gun: gun)
                .kisiselGun;
        return YorumYonu.karakterler[o.profil.yasamYolu.deger]!.bulusma(k) ==
            BulusmaTuru.zorlayici;
      });
      final GunlukOkuma b = gunlukOkuma(
        motor: motor,
        okuyucu: baska,
        sonuc: sonucKur(genel: 70, skorlar: ornekSkorlar),
      );
      final KarakterYonu kb =
          YorumYonu.karakterler[baska.profil.yasamYolu.deger]!;
      expect(b.bolumler.first.metin, contains(kb.golgeTavsiyesi));
      expect(b.bolumler.first.metin, contains(kb.doga));
      expect(a.bolumler.first.metin, isNot(b.bolumler.first.metin));
    });

    test('öne çıkan alan kişinin durumuna göre: bekar ve evli farklı havuz', () {
      final Map<LuckCategory, int> askBaskin = <LuckCategory, int>{
        LuckCategory.ask: 90,
        LuckCategory.para: 50,
        LuckCategory.saglik: 50,
        LuckCategory.risk: 50,
        LuckCategory.sosyal: 45,
      };
      String parlayan(IliskiDurumu d) => gunlukOkuma(
            motor: motor,
            okuyucu: okuyucu(tercihler: OkuyucuTercihleri(iliski: d)),
            sonuc: sonucKur(genel: 70, skorlar: askBaskin),
          ).bolumler[1].metin;
      final List<String> bekarHavuz = YorumYonu
          .kategoriDurumlari[LuckCategory.ask]!['bekar']![KategoriTonu.yuksek]!;
      final List<String> partnerHavuz = YorumYonu.kategoriDurumlari[
          LuckCategory.ask]!['partnerli']![KategoriTonu.yuksek]!;
      expect(bekarHavuz.any(parlayan(IliskiDurumu.bekar).startsWith), isTrue);
      expect(partnerHavuz.any(parlayan(IliskiDurumu.evli).startsWith), isTrue);
      // Kişinin aşk tarzı ve günün temasının aşka etkisi de yer alır.
      expect(
        parlayan(IliskiDurumu.bekar),
        contains(YorumYonu.karakterler[4]!.kategoriTarzi[LuckCategory.ask]),
      );
      expect(
        parlayan(IliskiDurumu.bekar),
        contains(YorumYonu.temaKategori[4]![LuckCategory.ask]),
      );
    });

    test('2 yıl × farklı tercihler: yer tutucu, çift boşluk, cümle tekrarı ve '
        'numeroloji jargonu yok; okuma yeterince uzun', () {
      final List<OkuyucuTercihleri> setler = <OkuyucuTercihleri>[
        const OkuyucuTercihleri(),
        const OkuyucuTercihleri(
          enerji: EnerjiTarzi.iceDonuk,
          karar: KararTarzi.kalp,
          iliski: IliskiDurumu.bekar,
          ugras: Ugras.ogrenci,
        ),
        const OkuyucuTercihleri(
          enerji: EnerjiTarzi.disaDonuk,
          karar: KararTarzi.akil,
          iliski: IliskiDurumu.evli,
          ugras: Ugras.girisimci,
        ),
      ];
      final List<DateTime> dogumlar = <DateTime>[
        DateTime(1994, 3, 14),
        DateTime(1990, 5, 15),
        DateTime(1985, 11, 29),
        DateTime(2000, 11, 9), // usta sayı 22
      ];
      for (final OkuyucuTercihleri t in setler) {
        for (final DateTime d in dogumlar) {
          final Okuyucu o = okuyucu(dogumTarihi: d, tercihler: t);
          for (int i = 0; i < 730; i += 5) {
            final LuckResult s = motor.hesapla(
              kullanici: o.seed,
              gun: DateTime(2026, 1, 1 + i),
            );
            final GunlukOkuma okuma =
                gunlukOkuma(motor: motor, okuyucu: o, sonuc: s);
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
            sonuc:
                motor.hesapla(kullanici: o.seed, gun: DateTime(2026, 9, 1 + i)),
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
        begenilenleriSec(havuz, OkumaBolumTuru.enerji, <String>{k('A.'), k('B.')}),
        havuz,
      );
    });

    test('neden öğeleri ayrı ayrı ve gerçek değerlerle', () {
      final DateTime g = DateTime(2026, 9, 13);
      final LuckResult s = motor.hesapla(kullanici: okuyucu().seed, gun: g);
      final GunlukOkuma okuma =
          gunlukOkuma(motor: motor, okuyucu: okuyucu(), sonuc: s);
      final Set<String> etiketler =
          okuma.nedenler.map((NedenOgesi n) => n.etiket).toSet();
      expect(etiketler.length, okuma.nedenler.length);
      final NedenOgesi ay = okuma.nedenler
          .firstWhere((NedenOgesi n) => n.tur == NedenTuru.ayEvresi);
      expect(ay.etki, ayEvresiModifiyeri(g).etki);
      final NedenOgesi kg = okuma.nedenler
          .firstWhere((NedenOgesi n) => n.tur == NedenTuru.kisiselGun);
      expect(kg.aciklama, contains(YorumYonu.gunTemalari[4]!.istek));
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
    test('durum + günün etkisi + kişinin tarzı + tavsiye; eylem saatli', () {
      final Okuyucu o = okuyucu(
        tercihler: const OkuyucuTercihleri(enerji: EnerjiTarzi.iceDonuk),
      );
      final KategoriOkumasi k = kategoriOkumasi(
        motor: motor,
        okuyucu: o,
        sonuc: sonucKur(genel: 50, skorlar: ornekSkorlar),
        kategori: LuckCategory.sosyal,
      );
      expect(k.ton, KategoriTonu.dusuk);
      expect(
        YorumYonu.kategoriDurumlari[LuckCategory.sosyal]!['iceDonuk']![
                KategoriTonu.dusuk]!
            .any(k.paragraf.startsWith),
        isTrue,
      );
      expect(k.paragraf, contains(YorumYonu.temaKategori[4]![LuckCategory.sosyal]));
      expect(
        k.paragraf,
        contains(YorumYonu.karakterler[4]!.kategoriTarzi[LuckCategory.sosyal]),
      );
      expect(k.eylem, contains(k.sansliSaat.etiket));
      expect(
        KisiselHavuzlar.eylemCumleleri[LuckCategory.sosyal]!.any(
          (String e) => slotDoldur(e, <String, String>{
            'saat': k.sansliSaat.etiket,
          }) ==
              k.eylem,
        ),
        isTrue,
      );
    });

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
        expect(a.paragraf.split(' ').length, greaterThanOrEqualTo(30));
      }
    });
  });

  group('profilOkumasi', () {
    test('tam adla tüm bölümler, ücretsizler önce', () {
      final List<ProfilBolumu> bolumler =
          profilOkumasi(okuyucu: okuyucu(), gun: gun);
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
      final ProfilBolumu yil =
          bolumler.firstWhere((ProfilBolumu b) => b.tur == ProfilBolumTuru.yil);
      expect(yil.metin, contains('2026 senin için bir 9 yılı'));
    });

    test('profil toplamı yeterince derin', () {
      final int kelime = profilOkumasi(okuyucu: okuyucu(), gun: gun)
          .map((ProfilBolumu b) => b.metin.split(' ').length)
          .fold(0, (int a, int b) => a + b);
      expect(kelime, greaterThanOrEqualTo(ContentConfig.profilToplamEnAzKelime));
    });

    test('tam ad yoksa isim tabanlı bölümler çıkmaz', () {
      final Iterable<ProfilBolumTuru> turler =
          profilOkumasi(okuyucu: okuyucu(tamAd: null), gun: gun)
              .map((ProfilBolumu b) => b.tur);
      expect(turler, isNot(contains(ProfilBolumTuru.icSes)));
      expect(turler, isNot(contains(ProfilBolumTuru.yansima)));
    });

    test('tercihler aşk ve iş bölümlerine kişisel cümle ekler', () {
      final List<ProfilBolumu> bolumler = profilOkumasi(
        okuyucu: okuyucu(
          tercihler: const OkuyucuTercihleri(
            iliski: IliskiDurumu.iliskide,
            ugras: Ugras.isArayan,
          ),
        ),
        gun: gun,
      );
      expect(
        bolumler
            .firstWhere((ProfilBolumu b) => b.tur == ProfilBolumTuru.askta)
            .metin,
        contains(KisiselHavuzlar.profilIliskiEki[true]),
      );
      expect(
        bolumler
            .firstWhere(
              (ProfilBolumu b) => b.tur == ProfilBolumTuru.isteVeParada,
            )
            .metin,
        contains(KisiselHavuzlar.profilUgrasEki[Ugras.isArayan]),
      );
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
