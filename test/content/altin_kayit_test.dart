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

  /// Okuyucu durumları (K7, 26 Kasım 2026'dan beri tanışma cevabı yok):
  /// 0 = tam ad yok, doğum haritası yok (eski "cevapsız" set, anahtarları
  /// değişmedi); 1 = tam ad var; 2 = tam ad, doğum Ay'ı ve yükselen var.
  const int durumSayisi = 3;

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
  ///
  /// Gün takvim alanlarıyla ilerler, `add(Duration(days: 1))` ile DEĞİL:
  /// süre eklemek yaz saati geçişinde doğumu 01:00'e kaydırır, motor
  /// tohumu da doğum tarihinin tam ISO dizgisini okur. Öyle olunca tablo
  /// makinenin saat dilimine bağlanıyordu (İstanbul'da yy2 ve yy33 kırık).
  DateTime dogumBul(int yasamYolu, DateTime baslangic) {
    DateTime d = baslangic;
    while (Numeroloji.yasamYolu(d).deger != yasamYolu) {
      d = DateTime(d.year, d.month, d.day + 1);
    }
    return d;
  }

  /// Yaşam yolu indeksi [i] için doğum tarihi (yıllara yayılmış).
  DateTime dogum(int i) =>
      dogumBul(yasamYollari[i], DateTime(1960 + i * 4, 1 + i, 1));

  /// Tam ad (durum 0'da yok: isim tabanlı bölümler düşer).
  String? tamAd(int i, int t) => t == 0 ? null : '${isimler[i]} Yılmaz';

  /// (yaşam yolu indeksi, durum) için okuyucu. Durum 2'nin harita burçları
  /// indeksten türetilir: on iki okuyucu on iki farklı Ay ve yükselen alır.
  Okuyucu okuyucu(int i, int t) {
    final DateTime d = dogum(i);
    return Okuyucu(
      isim: isimler[i],
      seed: UserSeed.fromIsim(isim: isimler[i], dogumTarihi: d),
      profil: KaderProfili.hesapla(dogumTarihi: d, tamAd: tamAd(i, t)),
      dogumAyi: t == 2 ? Burc.values[(i * 5) % Burc.values.length] : null,
      yukselen: t == 2 ? Burc.values[(i * 7 + 3) % Burc.values.length] : null,
    );
  }

  /// Okuyucu anahtarı: "yy<yaşam yolu>/t<durum>".
  String okuyucuAnahtari(int i, int t) => 'yy${yasamYollari[i]}/t$t';

  // ---------------------------------------------------------------------
  // Testler
  // ---------------------------------------------------------------------

  test('günlük okuma: 12 yaşam yolu × 3 durum × 10 gün', () {
    final Map<String, String> ozetler = <String, String>{};
    for (int i = 0; i < yasamYollari.length; i++) {
      for (int t = 0; t < durumSayisi; t++) {
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
      for (int t = 0; t < durumSayisi; t++) {
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
      for (int t = 0; t < durumSayisi; t++) {
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
      // Uyum metni yalnız tam addan etkilenir: durum 0 ve 1 yeterli
      // (durum 2'nin özeti durum 1'inkiyle aynı çıkar).
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
        // Süre UTC'de eklenir, sonra duvar saati alanlarından yerel tarih
        // kurulur: yerel DateTime'a Duration eklemek yaz saati geçişlerinde
        // saati makinenin saat dilimine göre kaydırıyor, kayıt makineden
        // makineye değişiyordu.
        final DateTime u = DateTime.utc(
          1950,
          1,
          1,
          5,
        ).add(Duration(days: n * 331, hours: n * 7 % 24, minutes: n * 13));
        final DateTime yerel = DateTime(
          u.year,
          u.month,
          u.day,
          u.hour,
          u.minute,
        );
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
    ekle('cunku', o.cunku);
    for (final NedenOgesi n in o.nedenler) {
      ekle('neden', n.tur.name);
      ekle('etiket', n.etiket);
      ekle('aciklama', n.aciklama);
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
///
/// 26 Kasım 2026 (K7): tanışma cevabı setleri üretim durumlarıyla
/// değiştirildi. t0 anahtarlarıyla birlikte 123 anahtar aynı kaldı;
/// yalnız gunluk/kategori/profil t1-t2 (eskiden cevaplı okuyucu) ve
/// begeni (cevaplı okuyucu kullanıyordu) yeniden üretildi.
///
/// 26 Kasım 2026 (K7 adım 2, KARARLAR soru 3): günün tavsiyesi burç
/// elementinin enerjisine bağlandı. Bilinçli değişiklik: gunluk t0-t2 ve
/// begeni (48 anahtar) yeniden üretildi; kategori, profil, uyum ve
/// kimlik anahtarları aynı (reports/k7_kanit/adim2_degisen_anahtarlar.txt).
const Map<String, String> _altinKayit = <String, String>{
  'bebek/iki': 'de2a8413',
  'bebek/tek': 'ea5b4722',
  'bebek/uc': 'ace1960b',
  'begeni/yy1': 'd556ece1',
  'begeni/yy11': '52913aa9',
  'begeni/yy2': '0d375447',
  'begeni/yy22': '4d8750f0',
  'begeni/yy3': 'b0cee279',
  'begeni/yy33': 'b1bdf011',
  'begeni/yy4': 'e54ff8c3',
  'begeni/yy5': 'f8fca0f4',
  'begeni/yy6': '118f5326',
  'begeni/yy7': '3b080414',
  'begeni/yy8': '77ea6210',
  'begeni/yy9': '607bd235',
  'gunluk/yy1/t0': '8c6f0d7b',
  'gunluk/yy1/t1': '8c6f0d7b',
  'gunluk/yy1/t2': '7b99309b',
  'gunluk/yy11/t0': '23499b39',
  'gunluk/yy11/t1': '23499b39',
  'gunluk/yy11/t2': '5aef5337',
  'gunluk/yy2/t0': '2bc51a18',
  'gunluk/yy2/t1': '2bc51a18',
  'gunluk/yy2/t2': '25c28a76',
  'gunluk/yy22/t0': '76a8647f',
  'gunluk/yy22/t1': '76a8647f',
  'gunluk/yy22/t2': 'd57c3c15',
  'gunluk/yy3/t0': '4fc71134',
  'gunluk/yy3/t1': '4fc71134',
  'gunluk/yy3/t2': 'e6b797ec',
  'gunluk/yy33/t0': 'c71dc030',
  'gunluk/yy33/t1': 'c71dc030',
  'gunluk/yy33/t2': '2c1ca27e',
  'gunluk/yy4/t0': '158dff93',
  'gunluk/yy4/t1': '158dff93',
  'gunluk/yy4/t2': '77c51731',
  'gunluk/yy5/t0': 'b65d33e1',
  'gunluk/yy5/t1': 'b65d33e1',
  'gunluk/yy5/t2': 'f8925953',
  'gunluk/yy6/t0': 'a3c9466c',
  'gunluk/yy6/t1': 'a3c9466c',
  'gunluk/yy6/t2': '238d02f2',
  'gunluk/yy7/t0': '9ed647b0',
  'gunluk/yy7/t1': '9ed647b0',
  'gunluk/yy7/t2': '61411b6e',
  'gunluk/yy8/t0': 'e014dea4',
  'gunluk/yy8/t1': 'e014dea4',
  'gunluk/yy8/t2': '58bdd500',
  'gunluk/yy9/t0': '811eb083',
  'gunluk/yy9/t1': '811eb083',
  'gunluk/yy9/t2': '59f202b5',
  'harita/konumsuz': 'd959da30',
  'harita/saatsiz': '34b70950',
  'harita/tam': '81d7d87b',
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
  'kategori/yy1/t0': '2558da60',
  'kategori/yy1/t1': '2558da60',
  'kategori/yy1/t2': '2558da60',
  'kategori/yy11/t0': 'b59040bd',
  'kategori/yy11/t1': 'b59040bd',
  'kategori/yy11/t2': 'b59040bd',
  'kategori/yy2/t0': 'b7542df7',
  'kategori/yy2/t1': 'b7542df7',
  'kategori/yy2/t2': 'b7542df7',
  'kategori/yy22/t0': '63a6a745',
  'kategori/yy22/t1': '63a6a745',
  'kategori/yy22/t2': '63a6a745',
  'kategori/yy3/t0': 'e62ebb26',
  'kategori/yy3/t1': 'e62ebb26',
  'kategori/yy3/t2': 'e62ebb26',
  'kategori/yy33/t0': '5d29ba3b',
  'kategori/yy33/t1': '5d29ba3b',
  'kategori/yy33/t2': '5d29ba3b',
  'kategori/yy4/t0': 'a84c4735',
  'kategori/yy4/t1': 'a84c4735',
  'kategori/yy4/t2': 'a84c4735',
  'kategori/yy5/t0': '6173754e',
  'kategori/yy5/t1': '6173754e',
  'kategori/yy5/t2': '6173754e',
  'kategori/yy6/t0': '2eb6c9d4',
  'kategori/yy6/t1': '2eb6c9d4',
  'kategori/yy6/t2': '2eb6c9d4',
  'kategori/yy7/t0': '505c45c7',
  'kategori/yy7/t1': '505c45c7',
  'kategori/yy7/t2': '505c45c7',
  'kategori/yy8/t0': '6a3ae4e5',
  'kategori/yy8/t1': '6a3ae4e5',
  'kategori/yy8/t2': '6a3ae4e5',
  'kategori/yy9/t0': '4d82e6f7',
  'kategori/yy9/t1': '4d82e6f7',
  'kategori/yy9/t2': '4d82e6f7',
  'numara/bicimli': '2576a398',
  'numara/tarama0': 'afbd21a0',
  'numara/tarama1': '30c556b1',
  'numara/tarama2': 'd397b701',
  'numara/tarama3': '59f0627e',
  'profil/yy1/t0': 'a1b56f09',
  'profil/yy1/t1': '690b115e',
  'profil/yy1/t2': '690b115e',
  'profil/yy11/t0': 'a8de184d',
  'profil/yy11/t1': '2a1822f2',
  'profil/yy11/t2': '2a1822f2',
  'profil/yy2/t0': 'bd68b922',
  'profil/yy2/t1': 'a84e73a0',
  'profil/yy2/t2': 'a84e73a0',
  'profil/yy22/t0': '0fb35be1',
  'profil/yy22/t1': 'b1e6c7f2',
  'profil/yy22/t2': 'b1e6c7f2',
  'profil/yy3/t0': 'd0ebc55d',
  'profil/yy3/t1': '6d870878',
  'profil/yy3/t2': '6d870878',
  'profil/yy33/t0': 'ec8cb955',
  'profil/yy33/t1': '3f3e397c',
  'profil/yy33/t2': '3f3e397c',
  'profil/yy4/t0': '737c8629',
  'profil/yy4/t1': '51c3d3c9',
  'profil/yy4/t2': '51c3d3c9',
  'profil/yy5/t0': 'aa173c5a',
  'profil/yy5/t1': 'bd7da0df',
  'profil/yy5/t2': 'bd7da0df',
  'profil/yy6/t0': '9e22d8cd',
  'profil/yy6/t1': 'dea3c332',
  'profil/yy6/t2': 'dea3c332',
  'profil/yy7/t0': '2865d377',
  'profil/yy7/t1': 'e15596f4',
  'profil/yy7/t2': 'e15596f4',
  'profil/yy8/t0': '582b65d8',
  'profil/yy8/t1': '334bce0f',
  'profil/yy8/t2': '334bce0f',
  'profil/yy9/t0': '04475a01',
  'profil/yy9/t1': '0cf3887a',
  'profil/yy9/t2': '0cf3887a',
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
