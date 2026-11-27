/// Türkiye dışındaki doğum şehirleri ve ülke adları: veri biçimi ve arama
/// (K8-5). Saf Dart.
///
/// Kaynak GeoNames `cities15000` ve `admin1CodesASCII` (CC BY 4.0). Ham
/// dosya `tool/sehir_verisi.dart` ile kırpılır: ad, ASCII ad, ülke, enlem,
/// boylam, saat dilimi, büyük şehirlerin diğer adları ve (yalnız aynı adlı
/// şehirlerde) bölge adı kalır; satırlar nüfusa göre sıralanır ve nüfus
/// sütunu atılır (sıra, aramada kalabalık şehri öne alır). Türkiye
/// satırları alınmaz: Türkiye'de doğum yeri 81 il listesinden gelir
/// (bugünkü haritalar değişmesin diye).
///
/// Ülke adları Unicode CLDR'den (Türkçe ve İngilizce), bkz.
/// `tool/ulke_adlari.swift`.
library;

import 'dogum_yeri.dart';
import 'engine_config.dart';
import 'numeroloji.dart';

/// Şehir verisindeki bir şehir.
class DunyaSehri {
  /// Tüm alanlarıyla şehir oluşturur.
  const DunyaSehri({
    required this.ad,
    required this.asciiAd,
    required this.ulkeKodu,
    required this.enlem,
    required this.boylam,
    required this.saatDilimi,
    this.nufus = 0,
    this.digerAdlar = const <String>[],
    this.bolge = '',
  });

  // GeoNames ana tablosunun sütunları (geonames.org/export, "geoname").
  static const int _gnSutunSayisi = 19;
  static const int _gnAd = 1;
  static const int _gnAsciiAd = 2;
  static const int _gnDigerAdlar = 3;
  static const int _gnEnlem = 4;
  static const int _gnBoylam = 5;
  static const int _gnUlke = 8;
  static const int _gnBolge = 10;
  static const int _gnNufus = 14;
  static const int _gnSaatDilimi = 17;

  /// GeoNames `cities15000.txt` satırından şehir; Türkiye satırı, eksik
  /// saat dilimi ya da bozuk satırda null.
  ///
  /// [bolgeler] `admin1CodesASCII.txt`'ten okunan "ülke.kod" → bölge adı
  /// tablosudur (bkz. [bolgeTablosu]); kodu tabloda yoksa bölge boş kalır.
  static DunyaSehri? geoNamesSatirindan(
    String satir, {
    Map<String, String> bolgeler = const <String, String>{},
  }) {
    final List<String> s = satir.split('\t');
    if (s.length != _gnSutunSayisi) {
      return null;
    }
    final String ulke = s[_gnUlke];
    final String saatDilimi = s[_gnSaatDilimi];
    final double? enlem = double.tryParse(s[_gnEnlem]);
    final double? boylam = double.tryParse(s[_gnBoylam]);
    if (ulke.isEmpty ||
        ulke == EngineConfig.turkiyeUlkeKodu ||
        saatDilimi.isEmpty ||
        s[_gnAd].isEmpty ||
        enlem == null ||
        boylam == null) {
      return null;
    }
    final String ad = s[_gnAd];
    final String asciiAd = s[_gnAsciiAd].isEmpty ? ad : s[_gnAsciiAd];
    final int nufus = int.tryParse(s[_gnNufus]) ?? 0;
    return DunyaSehri(
      ad: ad,
      asciiAd: asciiAd,
      ulkeKodu: ulke,
      enlem: enlem,
      boylam: boylam,
      saatDilimi: saatDilimi,
      nufus: nufus,
      digerAdlar: nufus >= EngineConfig.sehirDigerAdNufusEsigi
          ? _digerAdlariSec(s[_gnDigerAdlar].split(','), <String>[ad, asciiAd])
          : const <String>[],
      bolge: bolgeler['$ulke.${s[_gnBolge]}'] ?? '',
    );
  }

  // GeoNames `admin1CodesASCII.txt` sütunları: "ülke.kod", ad, ASCII ad,
  // geonameid.
  static const int _bolgeSutunSayisi = 4;

  /// `admin1CodesASCII.txt` metninden "ülke.kod" → bölge adı tablosu
  /// ("US.IL" → "Illinois"). Bozuk satırlar atlanır.
  static Map<String, String> bolgeTablosu(String metin) => <String, String>{
    for (final List<String> s
        in metin.split('\n').map((String l) => l.split('\t')))
      if (s.length == _bolgeSutunSayisi && s[0].isNotEmpty && s[1].isNotEmpty)
        s[0]: s[1],
  };

  // Havaalanı ve kısaltma kodları ("MUC", "NYC"): aramada gürültü.
  static final RegExp _kod = RegExp(r'^[A-Z]{2,4}$');

  // Latin harf, boşluk ve ad içinde geçen işaretler.
  static final RegExp _latinAd = RegExp(r"^[a-z .'’\-()]+$");

  /// GeoNames'in dil etiketsiz diğer adlarından aramaya değer olanlar:
  /// Latin yazılı, kod olmayan, [EngineConfig.sehirDigerAdEnUzun]
  /// karakteri aşmayan ve aksansız hâli [bilinen] adlardan ve birbirinden
  /// farklı olanlar ("München", "Münih", "Wien", "Viyana").
  static List<String> _digerAdlariSec(
    List<String> adaylar,
    List<String> bilinen,
  ) {
    final Set<String> bilinenSade = <String>{
      for (final String b in bilinen) Numeroloji.latinSadelestir(b),
    };
    // Aksansız hâli aynı olanlardan aksanlısı tutulur ("München" >
    // "Munchen"): kullanıcıya gösterilen ad doğru yazılmış olsun.
    final Map<String, String> secilen = <String, String>{};
    for (final String a in adaylar) {
      if (a.isEmpty ||
          a.length > EngineConfig.sehirDigerAdEnUzun ||
          _kod.hasMatch(a) ||
          // Küçük harfle başlayanlar çoğunlukla başka yazıdan
          // çeviriyazıdır ("wei ye na"); ad değil.
          a[0] == a[0].toLowerCase()) {
        continue;
      }
      final String sade = Numeroloji.latinSadelestir(a);
      if (!_latinAd.hasMatch(sade) || bilinenSade.contains(sade)) {
        continue;
      }
      final String? onceki = secilen[sade];
      if (onceki == null || (_aksanli(a) && !_aksanli(onceki))) {
        secilen[sade] = a;
      }
    }
    return secilen.values.toList();
  }

  /// [a]da ASCII dışı harf var mı?
  static bool _aksanli(String a) => a.runes.any((int r) => r > 0x7F);

  /// Yerel ad (ör. "München").
  final String ad;

  /// ASCII ad (ör. "Munich"); aramada yerel adla birlikte bakılır.
  final String asciiAd;

  /// ISO 3166-1 iki harfli ülke kodu.
  final String ulkeKodu;

  /// Enlem (kuzey pozitif).
  final double enlem;

  /// Boylam (doğu pozitif).
  final double boylam;

  /// IANA saat dilimi kimliği.
  final String saatDilimi;

  /// Nüfus; yalnız hazırlama betiğinde sıralama için (asset'te yok, 0).
  final int nufus;

  /// Aramada bakılan diğer adlar (yalnız kalabalık şehirlerde; ör.
  /// "Munich" için "München", "Münih"). GeoNames ana adı bazen İngilizce
  /// verir; kullanıcı yerel ya da Türkçe adla da bulabilsin diye tutulur.
  final List<String> digerAdlar;

  /// Birinci düzey idari bölge adı ("Illinois", "Bavaria"); bilinmiyorsa
  /// boş. Asset'te yalnız ülkesinde adı tekrar eden şehirlerde tutulur:
  /// listede "Springfield, Illinois" diye ayırmaya yeter.
  final String bolge;

  /// Profile yazılacak doğum yeri.
  DogumYeri dogumYeri() => DogumYeri(
    ulkeKodu: ulkeKodu,
    ad: ad,
    saatDilimi: saatDilimi,
    enlem: enlem,
    boylam: boylam,
  );
}

/// Şehir verisini yazma, okuma ve arama.
///
/// Asset biçimi (UTF-8, satır satır):
/// - `#` ile başlayan satırlar açıklamadır (kaynak ve atıf).
/// - `@` ile başlayan TEK satır saat dilimi tablosudur: `@` ve ardından
///   sekmeyle ayrılmış IANA kimlikleri. Şehir satırları bu tablonun
///   sırasını kullanır (dosya ~%40 küçülür).
/// - Şehir satırı: ad, ASCII ad (adla aynıysa boş), ülke, enlem, boylam,
///   saat dilimi sırası, diğer adlar (virgülle; çoğu satırda boş), bölge
///   (yalnız ülkesinde adı tekrar eden şehirlerde; boyut için);
///   sekmeyle ayrılır. Satırlar kalabalıktan tenhaya sıralıdır.
abstract final class DunyaSehirleri {
  static const String _aciklamaOnEki = '#';
  static const String _saatDilimiOnEki = '@';
  static const int _sutunSayisi = 8;
  static const String _bolgeAyraci = ', ';

  /// [sehirler]i asset biçiminde yazar; [aciklama] satırları başa `#` ile
  /// eklenir. Sıra korunur; çağıran önce sıralamalıdır.
  static String kompaktYaz(
    List<DunyaSehri> sehirler, {
    List<String> aciklama = const <String>[],
  }) {
    final List<String> dilimler =
        sehirler.map((DunyaSehri s) => s.saatDilimi).toSet().toList()..sort();
    final Map<String, int> sira = <String, int>{
      for (int i = 0; i < dilimler.length; i++) dilimler[i]: i,
    };
    final Set<String> ayni = ayniAdlar(sehirler);
    final StringBuffer b = StringBuffer();
    for (final String a in aciklama) {
      b.writeln('$_aciklamaOnEki $a');
    }
    b.writeln('$_saatDilimiOnEki${dilimler.join('\t')}');
    for (final DunyaSehri s in sehirler) {
      b.writeln(
        <String>[
          s.ad,
          if (s.asciiAd == s.ad) '' else s.asciiAd,
          s.ulkeKodu,
          _koordinat(s.enlem),
          _koordinat(s.boylam),
          '${sira[s.saatDilimi]}',
          s.digerAdlar.join(','),
          if (ayni.contains(_adAnahtari(s))) s.bolge else '',
        ].join('\t'),
      );
    }
    return b.toString();
  }

  /// Koordinatı [EngineConfig.sehirKoordinatHanesi] haneye yuvarlar ve
  /// sondaki sıfırları atar ("48.1370" → "48.137").
  static String _koordinat(double d) {
    String m = d.toStringAsFixed(EngineConfig.sehirKoordinatHanesi);
    while (m.endsWith('0')) {
      m = m.substring(0, m.length - 1);
    }
    return m.endsWith('.') ? m.substring(0, m.length - 1) : m;
  }

  /// Asset metnini okur. Açıklama, boş ve bozuk satırlar atlanır; saat
  /// dilimi tablosu yoksa liste boştur.
  static List<DunyaSehri> kompaktOku(String metin) {
    List<String> dilimler = const <String>[];
    final List<DunyaSehri> sehirler = <DunyaSehri>[];
    for (final String satir in metin.split('\n')) {
      if (satir.isEmpty || satir.startsWith(_aciklamaOnEki)) {
        continue;
      }
      if (satir.startsWith(_saatDilimiOnEki)) {
        dilimler = satir.substring(1).split('\t');
        continue;
      }
      final List<String> s = satir.split('\t');
      if (s.length != _sutunSayisi) {
        continue;
      }
      final double? enlem = double.tryParse(s[3]);
      final double? boylam = double.tryParse(s[4]);
      final int? dilim = int.tryParse(s[5]);
      if (s[0].isEmpty ||
          enlem == null ||
          boylam == null ||
          dilim == null ||
          dilim < 0 ||
          dilim >= dilimler.length) {
        continue;
      }
      sehirler.add(
        DunyaSehri(
          ad: s[0],
          asciiAd: s[1].isEmpty ? s[0] : s[1],
          ulkeKodu: s[2],
          enlem: enlem,
          boylam: boylam,
          saatDilimi: dilimler[dilim],
          digerAdlar: s[6].isEmpty ? const <String>[] : s[6].split(','),
          bolge: s[7],
        ),
      );
    }
    return sehirler;
  }

  /// `ülke<TAB>ad` anahtarı.
  static String _adAnahtari(DunyaSehri s) => '${s.ulkeKodu}\t${s.ad}';

  /// `ülke<TAB>ad<TAB>bölge` anahtarı.
  static String _bolgeAnahtari(DunyaSehri s) => '${_adAnahtari(s)}\t${s.bolge}';

  /// Ayırt edilmesi gereken adlar: aynı ülkede birden çok şehrin taşıdığı
  /// adlar (`ülke<TAB>ad`) ve bölgesi de aynı olanlar
  /// (`ülke<TAB>ad<TAB>bölge`). [gorunenAd] ile kullanılır.
  static Set<String> ayniAdlar(Iterable<DunyaSehri> sehirler) {
    final Set<String> gorulen = <String>{};
    final Set<String> ayni = <String>{};
    for (final DunyaSehri s in sehirler) {
      for (final String k in <String>[_adAnahtari(s), _bolgeAnahtari(s)]) {
        if (!gorulen.add(k)) {
          ayni.add(k);
        }
      }
    }
    return ayni;
  }

  /// Listede gösterilecek ad.
  ///
  /// Ülkede aynı adlı başka şehir varsa bölge eklenir: "Springfield,
  /// Illinois". Bölge bilinmiyorsa ya da aynı bölgede de aynı adlı şehir
  /// varsa koordinat da eklenir: "San Pedro, Coahuila (25.76°, -102.98°)",
  /// "Springfield (39.80°, -89.64°)".
  static String gorunenAd(DunyaSehri s, Set<String> ayniAdlar) {
    if (!ayniAdlar.contains(_adAnahtari(s))) {
      return s.ad;
    }
    final String ad = s.bolge.isEmpty ? s.ad : '${s.ad}$_bolgeAyraci${s.bolge}';
    if (s.bolge.isNotEmpty && !ayniAdlar.contains(_bolgeAnahtari(s))) {
      return ad;
    }
    const int h = EngineConfig.sehirAyirtKoordinatHanesi;
    return '$ad (${s.enlem.toStringAsFixed(h)}°, '
        '${s.boylam.toStringAsFixed(h)}°)';
  }

  /// [ulkeKodu] ülkesindeki şehirlerde [sorgu] araması.
  ///
  /// Ad ya da ASCII ad, aksan ve büyük/küçük harf gözetmeden karşılaştırılır
  /// ("munchen", "MÜNCHEN" ve "München" aynıdır). Adı sorguyla başlayanlar
  /// önce, içinde geçenler sonra gelir; her grupta listedeki sıra korunur
  /// (asset kalabalıktan tenhaya sıralıdır). Boş sorguda ülkenin ilk
  /// (en kalabalık) şehirleri döner.
  static List<DunyaSehri> ara(
    Iterable<DunyaSehri> sehirler, {
    required String ulkeKodu,
    required String sorgu,
    int enFazla = EngineConfig.sehirAramaEnFazla,
  }) {
    final String s = Numeroloji.latinSadelestir(sorgu.trim());
    final List<DunyaSehri> baslayan = <DunyaSehri>[];
    final List<DunyaSehri> iceren = <DunyaSehri>[];
    for (final DunyaSehri sehir in sehirler) {
      if (sehir.ulkeKodu != ulkeKodu) {
        continue;
      }
      final String ad = Numeroloji.latinSadelestir(sehir.ad);
      final String ascii = Numeroloji.latinSadelestir(sehir.asciiAd);
      if (ad.startsWith(s) ||
          ascii.startsWith(s) ||
          _digerAdla(sehir, s) != null) {
        baslayan.add(sehir);
        if (baslayan.length >= enFazla) {
          break; // Başlayanlar zaten listenin başına gelir.
        }
      } else if (iceren.length < enFazla &&
          (ad.contains(s) || ascii.contains(s))) {
        iceren.add(sehir);
      }
    }
    return <DunyaSehri>[...baslayan, ...iceren].take(enFazla).toList();
  }

  /// [sehir] [sorgu]ya yalnız diğer adlarından biriyle uyuyorsa o ad
  /// ("münch" → Munich için "München"); ad ya da ASCII adla uyuyorsa ya da
  /// hiç uymuyorsa null. Listede "Munich (München)" yazmak için.
  static String? eslesenDigerAd(DunyaSehri sehir, String sorgu) {
    final String s = Numeroloji.latinSadelestir(sorgu.trim());
    if (s.isEmpty ||
        Numeroloji.latinSadelestir(sehir.ad).contains(s) ||
        Numeroloji.latinSadelestir(sehir.asciiAd).contains(s)) {
      return null;
    }
    return _digerAdla(sehir, s);
  }

  /// Sadeleşmiş [s] ile başlayan ilk diğer ad.
  static String? _digerAdla(DunyaSehri sehir, String s) {
    if (s.isEmpty) {
      return null;
    }
    for (final String a in sehir.digerAdlar) {
      if (Numeroloji.latinSadelestir(a).startsWith(s)) {
        return a;
      }
    }
    return null;
  }
}

/// Doğum ülkesi seçimi için bir ülke.
class Ulke {
  /// Tüm alanlarıyla ülke oluşturur.
  const Ulke({required this.kod, required this.trAd, required this.enAd});

  /// ISO 3166-1 iki harfli kod.
  final String kod;

  /// Türkçe ad (CLDR).
  final String trAd;

  /// İngilizce ad (CLDR).
  final String enAd;

  /// [dilKodu] dilindeki ad; Türkçe dışında İngilizce.
  String ad(String dilKodu) => dilKodu == 'tr' ? trAd : enAd;
}

/// Ülke listesini okuma ve arama.
abstract final class Ulkeler {
  static const int _sutunSayisi = 3;

  /// `kod<TAB>Türkçe ad<TAB>İngilizce ad` satırlarını okur; `#` ile
  /// başlayan, boş ve bozuk satırlar atlanır.
  static List<Ulke> kompaktOku(String metin) => <Ulke>[
    for (final String satir in metin.split('\n'))
      if (satir.isNotEmpty && !satir.startsWith('#'))
        if (satir.split('\t') case final List<String> s
            when s.length == _sutunSayisi && s[0].length == 2)
          Ulke(kod: s[0], trAd: s[1], enAd: s[2]),
  ];

  /// [dilKodu] dilindeki adla arama: aksan gözetmez, başlayanlar önce,
  /// her grupta alfabetik. Türkçe ve İngilizce adın ikisine de bakılır
  /// ("Germany" yazan Türkçe kullanıcı da Almanya'yı bulur). Boş sorguda
  /// bütün ülkeler alfabetik.
  static List<Ulke> ara(
    Iterable<Ulke> ulkeler, {
    required String sorgu,
    required String dilKodu,
  }) {
    final String s = Numeroloji.latinSadelestir(sorgu.trim());
    final List<Ulke> baslayan = <Ulke>[];
    final List<Ulke> iceren = <Ulke>[];
    for (final Ulke u in ulkeler) {
      final String yerel = Numeroloji.latinSadelestir(u.ad(dilKodu));
      final String obur = Numeroloji.latinSadelestir(
        dilKodu == 'tr' ? u.enAd : u.trAd,
      );
      if (yerel.startsWith(s) ||
          obur.startsWith(s) ||
          u.kod.toLowerCase() == s) {
        baslayan.add(u);
      } else if (yerel.contains(s) || obur.contains(s)) {
        iceren.add(u);
      }
    }
    int sirala(Ulke a, Ulke b) => Numeroloji.latinSadelestir(
      a.ad(dilKodu),
    ).compareTo(Numeroloji.latinSadelestir(b.ad(dilKodu)));
    return <Ulke>[...baslayan..sort(sirala), ...iceren..sort(sirala)];
  }
}
