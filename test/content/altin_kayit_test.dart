import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/arac_okumalari.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/content/harita_okumasi.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/content/rapor_okumasi.dart';
import 'package:kader/core/content/yillik_rapor.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';

/// Altın kayıt testleri (INGILIZCE_SURUM_PLANI.md, E1 / değişmez D7).
///
/// Türkçe içerik birleştiricilerinin çıktısını geniş bir girdi kümesi
/// üzerinde kararlı bir düz metne döker ve FNV-1a (32 bit) özetini
/// aşağıdaki [_altinKayit] tablosuyla karşılaştırır. i18n işi sırasında
/// Türkçe kullanıcının gördüğü tek bir harf, bölüm sırası, premium
/// bayrağı ya da geri bildirim kimliği değişirse bu test kırılır.
///
/// Bir değişiklik BİLİNÇLİ ise (ör. Türkçe metin düzeltmesi, i18n
/// dışında), tabloyu yeniden üretmek için:
///
/// ```sh
/// ALTIN_KAYIT_YAZDIR=1 flutter test test/content/altin_kayit_test.dart
/// ```
///
/// Çıktıdaki tabloyu [_altinKayit]'ın yerine yapıştır ve sebebi commit
/// mesajında açıkla. i18n oturumlarında (E2–E9) tablo DEĞİŞMEMELİDİR.
void main() {
  const LuckEngine motor = LuckEngine();

  /// Hesaplanan tüm özetler (anahtar → onaltılık özet); yazdırma modu için.
  final Map<String, String> hesaplanan = <String, String>{};

  tearDownAll(() {
    if (Platform.environment['ALTIN_KAYIT_YAZDIR'] == null) {
      return;
    }
    final StringBuffer b = StringBuffer(
      'const Map<String, String> _altinKayit = <String, String>{\n',
    );
    final List<String> anahtarlar = hesaplanan.keys.toList()..sort();
    for (final String a in anahtarlar) {
      b.writeln("  '$a': '${hesaplanan[a]}',");
    }
    b.write('};');
    // Bilinçli olarak print: geliştirici tabloyu buradan kopyalar.
    // ignore: avoid_print
    print(b);
  });

  /// [grup] önekli anahtarların hesaplanan özetlerini kayıtla karşılaştırır.
  void dogrula(String grup, Map<String, String> ozetler) {
    hesaplanan.addAll(ozetler);
    final Map<String, String> beklenen = <String, String>{
      for (final MapEntry<String, String> e in _altinKayit.entries)
        if (e.key.startsWith('$grup/')) e.key: e.value,
    };
    final List<String> farklar = <String>[
      for (final String a in <String>{...beklenen.keys, ...ozetler.keys})
        if (beklenen[a] != ozetler[a])
          '$a: kayıt ${beklenen[a]} ≠ şimdi ${ozetler[a]}',
    ]..sort();
    expect(
      farklar,
      isEmpty,
      reason:
          '$grup çıktısı altın kayıttan saptı (${farklar.length} anahtar). '
          'Türkçe çıktı değişmemeliydi (D7).',
    );
  }

  // ---------------------------------------------------------------------
  // Girdi kümesi
  // ---------------------------------------------------------------------

  /// Tüm yaşam yolu sayıları (1-9 ve usta sayılar).
  const List<int> yasamYollari = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 22, 33];

  /// Yaşam yolu başına bir isim; Türkçe ek kuralları (ünlü uyumu,
  /// yumuşama, kaynaştırma) için farklı son harfler seçildi.
  const List<String> isimler = <String>[
    'Ayşe',
    'Mehmet',
    'Işıl',
    'Ömer',
    'Gül',
    'Umut',
    'Deniz',
    'Çağrı',
    'Su',
    'Ali',
    'Ece',
    'Oğuz',
  ];

  /// Tercih setleri: 0 = hiç cevap yok (tam ad da yok), 1 ve 2 dolu.
  const List<OkuyucuTercihleri> tercihSetleri = <OkuyucuTercihleri>[
    OkuyucuTercihleri(),
    OkuyucuTercihleri(
      enerji: EnerjiTarzi.iceDonuk,
      karar: KararTarzi.kalp,
      iliski: IliskiDurumu.bekar,
      ugras: Ugras.ogrenci,
    ),
    OkuyucuTercihleri(
      enerji: EnerjiTarzi.disaDonuk,
      karar: KararTarzi.akil,
      iliski: IliskiDurumu.evli,
      ugras: Ugras.calisiyor,
    ),
  ];

  /// Farklı ay, yıl, artık gün ve yıl dönümlerine yayılmış 10 gün.
  final List<DateTime> gunler = <DateTime>[
    DateTime(2026, 10, 8),
    DateTime(2026, 12, 31),
    DateTime(2027, 1, 1),
    DateTime(2027, 2, 14),
    DateTime(2027, 7, 20),
    DateTime(2028, 2, 29),
    DateTime(2028, 11, 11),
    DateTime(2029, 5, 5),
    DateTime(2030, 3, 21),
    DateTime(2031, 8, 30),
  ];

  /// [yasamYolu] sayısını veren ilk doğum tarihini [baslangic]tan arar.
  DateTime dogumBul(int yasamYolu, DateTime baslangic) {
    DateTime d = baslangic;
    while (Numeroloji.yasamYolu(d).deger != yasamYolu) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }

  /// Yaşam yolu indeksi [i] için doğum tarihi (yıllara yayılmış).
  DateTime dogum(int i) =>
      dogumBul(yasamYollari[i], DateTime(1960 + i * 4, 1 + i, 1));

  /// Tam ad (tercih seti 0'da yok: isim tabanlı bölümler düşer).
  String? tamAd(int i, int t) => t == 0 ? null : '${isimler[i]} Yılmaz';

  /// (yaşam yolu indeksi, tercih seti) için okuyucu.
  Okuyucu okuyucu(int i, int t) {
    final DateTime d = dogum(i);
    return Okuyucu(
      isim: isimler[i],
      seed: UserSeed.fromIsim(isim: isimler[i], dogumTarihi: d),
      profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: tamAd(i, t)),
      tercihler: tercihSetleri[t],
    );
  }

  /// Okuyucu anahtarı: "yy<yaşam yolu>/t<tercih seti>".
  String okuyucuAnahtari(int i, int t) => 'yy${yasamYollari[i]}/t$t';

  // ---------------------------------------------------------------------
  // Testler
  // ---------------------------------------------------------------------

  test('günlük okuma: 12 yaşam yolu × 3 tercih × 10 gün', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      for (int t = 0; t < tercihSetleri.length; t++) {
        final Okuyucu o = okuyucu(i, t);
        final _Doku d = _Doku();
        for (final DateTime g in gunler) {
          final LuckResult sonuc = motor.hesapla(kullanici: o.seed, gun: g);
          d.gunluk(gunlukOkuma(motor: motor, okuyucu: o, sonuc: sonuc));
        }
        ozetler['gunluk/${okuyucuAnahtari(i, t)}'] = d.ozet;
      }
    }
    dogrula('gunluk', ozetler);
  });

  test('günlük okuma: önceki günün bölümleri beğenilmediğinde', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      final Okuyucu o = okuyucu(i, 1);
      final _Doku d = _Doku();
      // İlk günün tüm bölümleri "beni anlatmadı" işaretlenir; sonraki
      // günler bu kimlikleri havuzdan dışlar.
      final GunlukOkuma ilk = gunlukOkuma(
        motor: motor,
        okuyucu: o,
        sonuc: motor.hesapla(kullanici: o.seed, gun: gunler.first),
      );
      final Set<String> begenilmeyenler = <String>{
        for (final OkumaBolumu b in ilk.bolumler) b.kimlik,
      };
      for (final DateTime g in gunler.skip(1)) {
        d.gunluk(
          gunlukOkuma(
            motor: motor,
            okuyucu: o,
            sonuc: motor.hesapla(kullanici: o.seed, gun: g),
            begenilmeyenler: begenilmeyenler,
          ),
        );
      }
      ozetler['begeni/yy${yasamYollari[i]}'] = d.ozet;
    }
    dogrula('begeni', ozetler);
  });

  test('kategori okuması: 5 kategori × 10 gün', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      for (int t = 0; t < tercihSetleri.length; t++) {
        final Okuyucu o = okuyucu(i, t);
        final _Doku d = _Doku();
        for (final DateTime g in gunler) {
          final LuckResult sonuc = motor.hesapla(kullanici: o.seed, gun: g);
          for (final LuckCategory k in LuckCategory.values) {
            d.kategori(
              kategoriOkumasi(
                motor: motor,
                okuyucu: o,
                sonuc: sonuc,
                kategori: k,
              ),
            );
          }
        }
        ozetler['kategori/${okuyucuAnahtari(i, t)}'] = d.ozet;
      }
    }
    dogrula('kategori', ozetler);
  });

  test('Kader Profili: 3 farklı yıl', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      for (int t = 0; t < tercihSetleri.length; t++) {
        final Okuyucu o = okuyucu(i, t);
        final _Doku d = _Doku();
        for (final DateTime g in <DateTime>[gunler[0], gunler[4], gunler[9]]) {
          for (final ProfilBolumu b in profilOkumasi(okuyucu: o, gun: g)) {
            d
              ..ekle('tur', b.tur.name)
              ..ekle('baslik', b.baslik)
              ..ekle('metin', b.metin)
              ..ekle('premium', b.premium);
          }
        }
        ozetler['profil/${okuyucuAnahtari(i, t)}'] = d.ozet;
      }
    }
    dogrula('profil', ozetler);
  });

  test('uyum: her okuyucu (tam adlı/adsız) × 6 kişi', () {
    // Element ve yaşam yolu ilişkilerini çeşitlendiren kişiler; biri tam
    // adsız (ruh bağı bölümü düşer).
    final List<(String, DateTime, String?)> kisiler =
        <(String, DateTime, String?)>[
          ('Mert', DateTime(1991, 7, 30), 'Mert Kaya'),
          ('Zeynep', DateTime(1988, 1, 5), 'Zeynep Arslan'),
          ('İlker', DateTime(1975, 4, 22), 'İlker Şahin'),
          ('Nur', DateTime(2000, 10, 13), null),
          ('Can', DateTime(1995, 12, 29), 'Can Öztürk'),
          ('Selin', DateTime(1983, 9, 9), 'Selin Doğan'),
        ];
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      // Uyum metni tercihlerden etkilenmez, yalnız tam addan: set 0 ve 1
      // yeterli (set 2'nin özeti set 1'inkiyle aynı çıkar).
      for (final int t in <int>[0, 1]) {
        final Okuyucu o = okuyucu(i, t);
        final _Doku d = _Doku();
        for (final (String ad, DateTime dt, String? tam) in kisiler) {
          final UyumOkumasi u = uyumOkumasi(
            okuyucu: o,
            digerIsim: ad,
            digerProfil: KaderProfili.hesapla(dogumTarihi: dt, tamAd: tam),
          );
          d
            ..ekle('skor', u.sonuc.skor)
            ..ekle('derece', u.sonuc.derece.name);
          for (final UyumBolumu b in u.bolumler) {
            d
              ..ekle('baslik', b.baslik)
              ..ekle('metin', b.metin);
          }
        }
        ozetler['uyum/${okuyucuAnahtari(i, t)}'] = d.ozet;
      }
    }
    dogrula('uyum', ozetler);
  });

  test('numeroloji raporu: tam adlı/adsız × 5 yaş', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      for (final int t in <int>[0, 1]) {
        final DateTime d0 = dogum(i);
        final NumerolojiRaporu rapor = NumerolojiRaporu.hesapla(
          dogumTarihi: d0,
          tamAd: tamAd(i, t),
        );
        final _Doku d = _Doku();
        // Dört dönemin hepsini ve son dönemi gezmek için farklı yaşlar.
        for (final int yas in <int>[8, 30, 45, 60, 85]) {
          final RaporOkumasi r = raporOkumasi(
            rapor: rapor,
            gun: DateTime(d0.year + yas, 6, 15),
          );
          for (final DonemOzeti z in r.zamanCizelgesi) {
            d
              ..ekle('yas', z.yasAraligi)
              ..ekle('zirve', z.zirveOzeti)
              ..ekle('zorluk', z.zorlukOzeti)
              ..ekle('aktif', z.aktif);
          }
          for (final RaporBolumu b in r.bolumler) {
            d
              ..ekle('tur', b.tur.name)
              ..ekle('baslik', b.baslik)
              ..ekle('metin', b.metin)
              ..ekle('premium', b.premium);
          }
        }
        ozetler['rapor/yy${yasamYollari[i]}/ad$t'] = d.ozet;
      }
    }
    dogrula('rapor', ozetler);
  });

  test('Kişisel Yıl Raporu: 2026–2034 (dokuz kişisel yıl)', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      final NumerolojiRaporu rapor = NumerolojiRaporu.hesapla(
        dogumTarihi: dogum(i),
        tamAd: tamAd(i, 1),
      );
      final _Doku d = _Doku();
      for (int yil = 2026; yil <= 2034; yil++) {
        final YillikRaporOkumasi y = yillikRaporOkumasi(rapor: rapor, yil: yil);
        d
          ..ekle('yil', y.yil)
          ..ekle('kisiselYil', y.kisiselYil)
          ..ekle('lakap', y.yilLakabi);
        for (final YillikBolum b in y.bolumler) {
          d
            ..ekle('tur', b.tur.name)
            ..ekle('baslik', b.baslik)
            ..ekle('metin', b.metin)
            ..ekle('premium', b.premium);
        }
        for (final YillikAy a in y.aylar) {
          d
            ..ekle('ay', a.ay)
            ..ekle('kisiselAy', a.kisiselAy)
            ..ekle('baslik', a.baslik)
            ..ekle('metin', a.metin)
            ..ekle('akis', a.akis.name)
            ..ekle('premium', a.premium);
        }
      }
      ozetler['yillik/yy${yasamYollari[i]}'] = d.ozet;
    }
    dogrula('yillik', ozetler);
  });

  test('doğum haritası: 3 bilgi durumu × 60 doğum', () {
    final Map<String, String> ozetler = <String, String>{};
    // (anahtar, saat biliniyor, konum biliniyor). Saat bilinmezken konum
    // kullanılmaz; "ikisi de yok" durumu "saatsiz" ile aynı çıktıyı verir.
    const List<(String, bool, bool)> durumlar = <(String, bool, bool)>[
      ('tam', true, true),
      ('konumsuz', true, false),
      ('saatsiz', false, true),
    ];
    for (final (String ad, bool saat, bool konum) in durumlar) {
      final _Doku d = _Doku();
      for (int n = 0; n < 60; n++) {
        // Yıllara, saatlere ve illere yayılmış doğumlar (1975 öncesi
        // belirsiz saat dilimi dönemleri dahil).
        final DateTime yerel = DateTime(
          1950,
          1,
          1,
          5,
        ).add(Duration(days: n * 331, hours: n * 7 % 24, minutes: n * 13));
        final Il il = TurkiyeIlleri.hepsi[n * 17 % TurkiyeIlleri.hepsi.length];
        final SaatDilimiSonucu dilim = TurkiyeSaatDilimi.utcFarki(yerel);
        final HaritaOkumasi h = haritaOkumasi(
          harita: DogumHaritasi.hesapla(
            yerelDogum: yerel,
            utcFarkiSaat: dilim.farkSaat.toDouble(),
            saatBiliniyor: saat,
            enlem: konum ? il.enlem : null,
            boylam: konum ? il.boylam : null,
          ),
          saatBiliniyor: saat,
          konumBiliniyor: konum,
          saatDilimiKesin: dilim.kesin,
        );
        d
          ..ekle('gunes', h.gunes.name)
          ..ekle('ay', h.ay.name)
          ..ekle('yukselen', h.yukselen?.name)
          ..ekle('ozet', h.ozet);
        for (final HaritaBolumu b in h.bolumler) {
          d
            ..ekle('tur', b.tur.name)
            ..ekle('burc', b.burc.name)
            ..ekle('baslik', b.baslik)
            ..ekle('metin', b.metin)
            ..ekle('alternatif', b.alternatif)
            ..ekle('premium', b.premium);
        }
        for (final String not in h.notlar) {
          d.ekle('not', not);
        }
      }
      ozetler['harita/$ad'] = d.ozet;
    }
    dogrula('harita', ozetler);
  });

  test('isim analizi: 16 ad', () {
    const List<String> adlar = <String>[
      'Ayşe Yılmaz',
      'Mehmet Ali Kaya',
      'Işıl Çağlar',
      'Ömer Faruk Öztürk',
      'Gülşen Ünal',
      'Şş',
      'Zeynep',
      'Can',
      'İbrahim Halil Doğan',
      'Ece Su Arslan',
      'Yusuf Yıldız',
      'Büşra Güneş',
      'Ahmet',
      'Kader Kuşu',
      'Elif Naz Şahin',
      'Oğuzhan Çelik',
    ];
    final Map<String, String> ozetler = <String, String>{};
    for (final String ad in adlar) {
      final _Doku d = _Doku();
      for (final AracBolumu b in isimOkumasi(IsimAnalizi.hesapla(ad)!)) {
        d
          ..ekle('baslik', b.baslik)
          ..ekle('metin', b.metin)
          ..ekle('premium', b.premium);
      }
      ozetler['isim/$ad'] = d.ozet;
    }
    dogrula('isim', ozetler);
  });

  test('numara analizi: geniş tarama + biçimli numaralar', () {
    final Map<String, String> ozetler = <String, String>{};
    // Tüm numara metinlerini gezmek için tarama 4 parçaya bölünür.
    for (int parca = 0; parca < 4; parca++) {
      final _Doku d = _Doku();
      for (int n = 1 + parca * 1250; n < (parca + 1) * 1250; n += 7) {
        d.numara(numaraOkumasi(NumaraAnalizcisi.analizEt('$n')!));
      }
      ozetler['numara/tarama$parca'] = d.ozet;
    }
    final _Doku bicimli = _Doku();
    for (final String metin in <String>[
      '0532 123 45 67',
      '+90 (212) 555-0101',
      '34 ABC 123',
      '1907',
      '22',
      '11',
      '33',
    ]) {
      final NumaraAnalizi? a = NumaraAnalizcisi.analizEt(metin);
      bicimli.ekle('girdi', metin);
      if (a != null) {
        bicimli.numara(numaraOkumasi(a));
      }
    }
    ozetler['numara/bicimli'] = bicimli.ozet;
    dogrula('numara', ozetler);
  });

  test('bebek ismi: 10 aday × 3 ebeveyn seti', () {
    const List<String> adaylar = <String>[
      'Ali Yılmaz',
      'Defne Yılmaz',
      'Çınar Yılmaz',
      'Ela Yılmaz',
      'Kerem Yılmaz',
      'Asel Yılmaz',
      'Ömer Yılmaz',
      'Zeynep Yılmaz',
      'Aras Yılmaz',
      'Lina Yılmaz',
    ];
    final List<(String, List<DateTime>, List<String>)> setler =
        <(String, List<DateTime>, List<String>)>[
          (
            'iki',
            <DateTime>[DateTime(1994, 3, 14), DateTime(1990, 2, 9)],
            <String>['Anne', 'Baba'],
          ),
          ('tek', <DateTime>[DateTime(1987, 11, 29)], <String>['Annesi']),
          (
            'uc',
            <DateTime>[
              DateTime(1992, 6, 6),
              DateTime(1989, 8, 17),
              DateTime(2018, 5, 1),
            ],
            <String>['Anne', 'Baba', 'Abla'],
          ),
        ];
    final Map<String, String> ozetler = <String, String>{};
    for (final (String ad, List<DateTime> dogumlar, List<String> adlar)
        in setler) {
      final _Doku d = _Doku();
      for (final String aday in adaylar) {
        final BebekIsmiOkumasi b = bebekIsmiOkumasi(
          BebekIsmi.uyum(aday, dogumlar)!,
          adlar,
        );
        d
          ..ekle('aday', aday)
          ..ekle('puan', b.uyum.puan)
          ..ekle('bant', b.bant.etiket)
          ..ekle('bantAciklama', b.bant.aciklama);
        for (final String c in b.iliskiCumleleri) {
          d.ekle('iliski', c);
        }
      }
      ozetler['bebek/$ad'] = d.ozet;
    }
    dogrula('bebek', ozetler);
  });
}

/// Okuma çıktılarını kararlı bir düz metne döküp özetleyen yardımcı.
///
/// Her alan `ad=değer` satırı olarak eklenir; alan adları da özete
/// girdiği için iki alanın yer değiştirmesi de yakalanır.
class _Doku {
  final StringBuffer _metin = StringBuffer();

  /// [ad] alanını [deger] ile ekler (`null` açıkça "∅" yazılır).
  void ekle(String ad, Object? deger) {
    _metin
      ..write(ad)
      ..write('=')
      ..write(deger ?? '∅')
      ..write('␞');
  }

  /// Günlük okumanın kullanıcıya görünen tüm alanlarını ekler.
  void gunluk(GunlukOkuma o) {
    ekle('baslik', o.baslik);
    ekle('kisiselGun', o.dongu.kisiselGun);
    for (final OkumaBolumu b in o.bolumler) {
      ekle('tur', b.tur.name);
      ekle('kimlik', b.kimlik);
      ekle('kategori', b.kategori?.name);
      ekle('metin', b.metin);
    }
    ekle('kapanis', o.kapanis);
    ekle('kartMetni', o.kartMetni);
    for (final NedenOgesi n in o.nedenler) {
      ekle('neden', n.tur.name);
      ekle('etiket', n.etiket);
      ekle('aciklama', n.aciklama);
      ekle('etki', n.etki);
    }
    ekle('renk', o.sansRengi.ad);
    ekle('renkHex', o.sansRengi.hexArgb);
    ekle('sayi', o.sansliSayi);
    ekle('tavsiye', o.tavsiye);
    ekle('parlayan', o.parlayanKategori.name);
    ekle('dikkat', o.dikkatKategori.name);
    ekle('saat', o.sansliSaat.etiket);
  }

  /// Kategori detay okumasının tüm alanlarını ekler.
  void kategori(KategoriOkumasi k) {
    ekle('kategori', k.kategori.name);
    ekle('skor', k.skor);
    ekle('ton', k.ton.name);
    ekle('paragraf', k.paragraf);
    ekle('eylem', k.eylem);
    ekle('saat', k.sansliSaat.etiket);
  }

  /// Numara okumasının metin alanlarını ekler.
  void numara(NumaraOkumasi n) {
    ekle('deger', n.analiz.deger);
    ekle('lakap', n.lakap);
    ekle('baslik', n.baslik);
    ekle('metin', n.metin);
  }

  /// Dökümün FNV-1a 32 bit özeti (8 haneli onaltılık).
  ///
  /// Kendi uygulamamız: `lib`'deki `metinKimligi` değişse bile kayıt
  /// bağımsız kalır.
  String get ozet {
    int h = 0x811c9dc5;
    for (final int bayt in utf8.encode(_metin.toString())) {
      h ^= bayt;
      h = (h * 0x01000193) & 0xffffffff;
    }
    return h.toRadixString(16).padLeft(8, '0');
  }
}

/// Altın kayıt: `ALTIN_KAYIT_YAZDIR=1` ile üretildi (E1, 8 Ekim 2026).
const Map<String, String> _altinKayit = <String, String>{
  'bebek/iki': 'de2a8413',
  'bebek/tek': 'ea5b4722',
  'bebek/uc': 'ace1960b',
  'begeni/yy1': 'a2bc986c',
  'begeni/yy11': 'a12a6a64',
  'begeni/yy2': '71ef0ca7',
  'begeni/yy22': 'f9157a18',
  'begeni/yy3': 'c197b928',
  'begeni/yy33': '6c3e5bd0',
  'begeni/yy4': '5ebdea2f',
  'begeni/yy5': '6d88c238',
  'begeni/yy6': '4c9ee14d',
  'begeni/yy7': '60def75f',
  'begeni/yy8': '5a794a36',
  'begeni/yy9': '21b5dce2',
  'gunluk/yy1/t0': '431d1715',
  'gunluk/yy1/t1': 'bb1c7739',
  'gunluk/yy1/t2': 'cea2dc02',
  'gunluk/yy11/t0': 'b54bad46',
  'gunluk/yy11/t1': '2a0c4eb8',
  'gunluk/yy11/t2': '8fee0572',
  'gunluk/yy2/t0': '3d128bcd',
  'gunluk/yy2/t1': '8df62720',
  'gunluk/yy2/t2': '869186e8',
  'gunluk/yy22/t0': '3d9e9762',
  'gunluk/yy22/t1': '7cf089e4',
  'gunluk/yy22/t2': '59adc1f9',
  'gunluk/yy3/t0': 'd1c5b79e',
  'gunluk/yy3/t1': 'fb712594',
  'gunluk/yy3/t2': '33ee1625',
  'gunluk/yy33/t0': 'de003302',
  'gunluk/yy33/t1': 'f6013439',
  'gunluk/yy33/t2': '5fe6bf0d',
  'gunluk/yy4/t0': 'ee539b00',
  'gunluk/yy4/t1': '1408300e',
  'gunluk/yy4/t2': 'e3b85293',
  'gunluk/yy5/t0': '879b87d6',
  'gunluk/yy5/t1': 'cdfbf3d5',
  'gunluk/yy5/t2': '0a3f399c',
  'gunluk/yy6/t0': '1c93c85a',
  'gunluk/yy6/t1': '97955cc6',
  'gunluk/yy6/t2': '4de15404',
  'gunluk/yy7/t0': '42c7d6aa',
  'gunluk/yy7/t1': '38a2d2b0',
  'gunluk/yy7/t2': '663ca569',
  'gunluk/yy8/t0': '1245f60a',
  'gunluk/yy8/t1': '528b164d',
  'gunluk/yy8/t2': '1b6ed71d',
  'gunluk/yy9/t0': '36f4f329',
  'gunluk/yy9/t1': 'e33a606f',
  'gunluk/yy9/t2': 'de139bd9',
  'harita/konumsuz': '2d7233eb',
  'harita/saatsiz': '34b70950',
  'harita/tam': 'b3e4c266',
  'isim/Ahmet': 'e4483034',
  'isim/Ayşe Yılmaz': '077331bb',
  'isim/Büşra Güneş': '11bee7f9',
  'isim/Can': '782e57cb',
  'isim/Ece Su Arslan': '0e2a50c1',
  'isim/Elif Naz Şahin': '730a3a66',
  'isim/Gülşen Ünal': '6ace4a66',
  'isim/Işıl Çağlar': '8015aa44',
  'isim/Kader Kuşu': '6c46f7a5',
  'isim/Mehmet Ali Kaya': 'd1c9b730',
  'isim/Oğuzhan Çelik': '72f6983d',
  'isim/Yusuf Yıldız': 'c5cb954d',
  'isim/Zeynep': '341d8df9',
  'isim/Ömer Faruk Öztürk': '1df999ab',
  'isim/İbrahim Halil Doğan': '715c2e88',
  'isim/Şş': 'db2359f7',
  'kategori/yy1/t0': '87335944',
  'kategori/yy1/t1': '3675d5a9',
  'kategori/yy1/t2': '53330c0a',
  'kategori/yy11/t0': 'ce530d70',
  'kategori/yy11/t1': 'eabe5935',
  'kategori/yy11/t2': '0eb8caf1',
  'kategori/yy2/t0': 'f4819cff',
  'kategori/yy2/t1': 'c8cd5fad',
  'kategori/yy2/t2': '46f0e41d',
  'kategori/yy22/t0': '63f914b5',
  'kategori/yy22/t1': '97255e76',
  'kategori/yy22/t2': '064bea5b',
  'kategori/yy3/t0': '84bb57e2',
  'kategori/yy3/t1': '5c1d7cf2',
  'kategori/yy3/t2': '044cd048',
  'kategori/yy33/t0': '52ebf998',
  'kategori/yy33/t1': '3dcc476c',
  'kategori/yy33/t2': '9b1fc135',
  'kategori/yy4/t0': '281dfca2',
  'kategori/yy4/t1': 'bd977448',
  'kategori/yy4/t2': '58f2d124',
  'kategori/yy5/t0': 'b7396184',
  'kategori/yy5/t1': 'f7b50b85',
  'kategori/yy5/t2': '4d029a35',
  'kategori/yy6/t0': 'fcee4ba4',
  'kategori/yy6/t1': '2bcfaa98',
  'kategori/yy6/t2': '7458ecfb',
  'kategori/yy7/t0': 'f7db37b4',
  'kategori/yy7/t1': '9771240e',
  'kategori/yy7/t2': 'c675f4ff',
  'kategori/yy8/t0': 'ae362d95',
  'kategori/yy8/t1': '280f3bf9',
  'kategori/yy8/t2': 'b9c11365',
  'kategori/yy9/t0': 'a42ead7d',
  'kategori/yy9/t1': '97e0392a',
  'kategori/yy9/t2': 'f1eabb3e',
  'numara/bicimli': '2576a398',
  'numara/tarama0': 'afbd21a0',
  'numara/tarama1': '30c556b1',
  'numara/tarama2': 'd397b701',
  'numara/tarama3': '59f0627e',
  'profil/yy1/t0': 'a1b56f09',
  'profil/yy1/t1': 'f57d9c24',
  'profil/yy1/t2': '6d0977ea',
  'profil/yy11/t0': 'e3dfaa57',
  'profil/yy11/t1': '123f8b4e',
  'profil/yy11/t2': 'e7a593a8',
  'profil/yy2/t0': '623baabb',
  'profil/yy2/t1': '9ce5603b',
  'profil/yy2/t2': '6653bd03',
  'profil/yy22/t0': '642f5c12',
  'profil/yy22/t1': '1a18f68f',
  'profil/yy22/t2': 'a7cbccf9',
  'profil/yy3/t0': '5443ceb0',
  'profil/yy3/t1': '789c530d',
  'profil/yy3/t2': 'a5d0f293',
  'profil/yy33/t0': '7221f06f',
  'profil/yy33/t1': '88688c22',
  'profil/yy33/t2': 'fb9478fe',
  'profil/yy4/t0': '9c3b53c6',
  'profil/yy4/t1': '9cda37c0',
  'profil/yy4/t2': 'ecdb7e0a',
  'profil/yy5/t0': 'ae89c895',
  'profil/yy5/t1': '1789bd8a',
  'profil/yy5/t2': '2f534c2c',
  'profil/yy6/t0': '9e22d8cd',
  'profil/yy6/t1': 'fe2746ea',
  'profil/yy6/t2': '0f5c05e0',
  'profil/yy7/t0': 'c05a8703',
  'profil/yy7/t1': 'f9481c3e',
  'profil/yy7/t2': '5acb361e',
  'profil/yy8/t0': '573d78e3',
  'profil/yy8/t1': 'ff361068',
  'profil/yy8/t2': '662e3f24',
  'profil/yy9/t0': '04475a01',
  'profil/yy9/t1': 'b923e87c',
  'profil/yy9/t2': '7abaddc0',
  'rapor/yy1/ad0': 'bb43acd0',
  'rapor/yy1/ad1': '11588388',
  'rapor/yy11/ad0': '3b461e6e',
  'rapor/yy11/ad1': '766acad5',
  'rapor/yy2/ad0': 'd2a615d4',
  'rapor/yy2/ad1': 'd375f3fc',
  'rapor/yy22/ad0': 'f045092a',
  'rapor/yy22/ad1': '889212e9',
  'rapor/yy3/ad0': 'a6807719',
  'rapor/yy3/ad1': 'a66fc721',
  'rapor/yy33/ad0': 'a96311f9',
  'rapor/yy33/ad1': 'decd925a',
  'rapor/yy4/ad0': 'c9b6ffa0',
  'rapor/yy4/ad1': '90542a8a',
  'rapor/yy5/ad0': '7e1b39f5',
  'rapor/yy5/ad1': '0c337e46',
  'rapor/yy6/ad0': '15be3246',
  'rapor/yy6/ad1': '1f7b505d',
  'rapor/yy7/ad0': '9b135458',
  'rapor/yy7/ad1': 'beb15ace',
  'rapor/yy8/ad0': '12e46f95',
  'rapor/yy8/ad1': '16ebdfb1',
  'rapor/yy9/ad0': '2cc193ba',
  'rapor/yy9/ad1': '2c81b30b',
  'uyum/yy1/t0': 'adcb9c43',
  'uyum/yy1/t1': '740a0fb0',
  'uyum/yy11/t0': 'd89b80fe',
  'uyum/yy11/t1': '064796e6',
  'uyum/yy2/t0': '0614de9e',
  'uyum/yy2/t1': '39188d8e',
  'uyum/yy22/t0': 'a7406817',
  'uyum/yy22/t1': '6845ff5f',
  'uyum/yy3/t0': '1984cdf7',
  'uyum/yy3/t1': '3071390d',
  'uyum/yy33/t0': 'aca22e7f',
  'uyum/yy33/t1': 'fa3ca96e',
  'uyum/yy4/t0': '8fa3f528',
  'uyum/yy4/t1': 'c793679d',
  'uyum/yy5/t0': '8b0ebac2',
  'uyum/yy5/t1': '9635460e',
  'uyum/yy6/t0': '682f16dd',
  'uyum/yy6/t1': 'e802231d',
  'uyum/yy7/t0': 'fd84d01c',
  'uyum/yy7/t1': '0fdc2718',
  'uyum/yy8/t0': 'a92b4776',
  'uyum/yy8/t1': 'a4de7bf2',
  'uyum/yy9/t0': '87fc78b9',
  'uyum/yy9/t1': '8bb876cf',
  'yillik/yy1': '9f130094',
  'yillik/yy11': '82ae01b4',
  'yillik/yy2': '4554ec4c',
  'yillik/yy22': '59119a8e',
  'yillik/yy3': 'f1a877ea',
  'yillik/yy33': '11e24d84',
  'yillik/yy4': 'f0c1063e',
  'yillik/yy5': '235229ec',
  'yillik/yy6': '6be47ee3',
  'yillik/yy7': '676f7fe0',
  'yillik/yy8': 'd4958c1f',
  'yillik/yy9': 'e2b9fd46',
};
