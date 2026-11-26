/// Türkiye dışındaki doğum şehirleri: veri biçimi ve arama (K8-5).
/// Saf Dart.
///
/// Kaynak GeoNames `cities15000` (CC BY 4.0). Ham dosya bir hazırlama
/// betiğiyle [DunyaSehri.geoNamesSatirindan] üzerinden kırpılır ve
/// [DunyaSehri.kompaktSatir] biçiminde asset olarak yazılır; uygulama
/// bunu [DunyaSehirleri.kompaktOku] ile okur. Türkiye satırları alınmaz:
/// Türkiye'de doğum yeri 81 il listesinden gelir (bugünkü haritalar
/// değişmesin diye).
library;

import 'dogum_yeri.dart';
import 'engine_config.dart';
import 'numeroloji.dart';

/// Şehir verisindeki bir şehir.
class DunyaSehri {
  /// Tüm alanlarıyla şehir oluşturur.
  const DunyaSehri({
    required this.kimlik,
    required this.ad,
    required this.asciiAd,
    required this.ulkeKodu,
    required this.enlem,
    required this.boylam,
    required this.saatDilimi,
    required this.nufus,
  });

  // GeoNames ana tablosunun sütunları (geonames.org/export, "geoname").
  static const int _gnSutunSayisi = 19;
  static const int _gnKimlik = 0;
  static const int _gnAd = 1;
  static const int _gnAsciiAd = 2;
  static const int _gnEnlem = 4;
  static const int _gnBoylam = 5;
  static const int _gnUlke = 8;
  static const int _gnNufus = 14;
  static const int _gnSaatDilimi = 17;

  // Kompakt biçimin sütunları.
  static const int _kSutunSayisi = 8;

  /// GeoNames `cities15000.txt` satırından şehir; Türkiye satırı, eksik
  /// saat dilimi ya da bozuk satırda null.
  static DunyaSehri? geoNamesSatirindan(String satir) {
    final List<String> s = satir.split('\t');
    if (s.length != _gnSutunSayisi) {
      return null;
    }
    final String ulke = s[_gnUlke];
    final String saatDilimi = s[_gnSaatDilimi];
    if (ulke.isEmpty ||
        ulke == EngineConfig.turkiyeUlkeKodu ||
        saatDilimi.isEmpty) {
      return null;
    }
    return _kur(
      kimlik: s[_gnKimlik],
      ad: s[_gnAd],
      asciiAd: s[_gnAsciiAd],
      ulke: ulke,
      enlem: s[_gnEnlem],
      boylam: s[_gnBoylam],
      saatDilimi: saatDilimi,
      nufus: s[_gnNufus],
    );
  }

  /// [kompaktSatir] biçiminden şehir; bozuk satırda null.
  static DunyaSehri? kompaktSatirdan(String satir) {
    final List<String> s = satir.split('\t');
    if (s.length != _kSutunSayisi) {
      return null;
    }
    return _kur(
      kimlik: s[0],
      ad: s[1],
      asciiAd: s[2],
      ulke: s[3],
      enlem: s[4],
      boylam: s[5],
      saatDilimi: s[6],
      nufus: s[7],
    );
  }

  static DunyaSehri? _kur({
    required String kimlik,
    required String ad,
    required String asciiAd,
    required String ulke,
    required String enlem,
    required String boylam,
    required String saatDilimi,
    required String nufus,
  }) {
    final int? k = int.tryParse(kimlik);
    final double? e = double.tryParse(enlem);
    final double? b = double.tryParse(boylam);
    if (k == null || e == null || b == null || ad.isEmpty) {
      return null;
    }
    return DunyaSehri(
      kimlik: k,
      ad: ad,
      asciiAd: asciiAd.isEmpty ? ad : asciiAd,
      ulkeKodu: ulke,
      enlem: e,
      boylam: b,
      saatDilimi: saatDilimi,
      nufus: int.tryParse(nufus) ?? 0,
    );
  }

  /// GeoNames kimliği.
  final int kimlik;

  /// Yerel ad (ör. "München").
  final String ad;

  /// ASCII ad (ör. "Munchen").
  final String asciiAd;

  /// ISO 3166-1 iki harfli ülke kodu.
  final String ulkeKodu;

  /// Enlem (kuzey pozitif).
  final double enlem;

  /// Boylam (doğu pozitif).
  final double boylam;

  /// IANA saat dilimi kimliği.
  final String saatDilimi;

  /// Nüfus (aramada sıralama için).
  final int nufus;

  /// Sekmeyle ayrılmış tek satır: kimlik, ad, ASCII ad, ülke, enlem,
  /// boylam, saat dilimi, nüfus. Koordinat
  /// [EngineConfig.sehirKoordinatHanesi] haneye yuvarlanır.
  String kompaktSatir() => <String>[
    '$kimlik',
    ad,
    asciiAd,
    ulkeKodu,
    enlem.toStringAsFixed(EngineConfig.sehirKoordinatHanesi),
    boylam.toStringAsFixed(EngineConfig.sehirKoordinatHanesi),
    saatDilimi,
    '$nufus',
  ].join('\t');

  /// Profile yazılacak doğum yeri.
  DogumYeri dogumYeri() => DogumYeri(
    ulkeKodu: ulkeKodu,
    ad: ad,
    saatDilimi: saatDilimi,
    enlem: enlem,
    boylam: boylam,
    sehirKimligi: kimlik,
  );
}

/// Şehir verisini okuma ve arama.
abstract final class DunyaSehirleri {
  /// Kompakt metni okur. `#` ile başlayan satırlar (başlık, atıf) ve boş
  /// ya da bozuk satırlar atlanır.
  static List<DunyaSehri> kompaktOku(String metin) => <DunyaSehri>[
    for (final String satir in metin.split('\n'))
      if (satir.isNotEmpty && !satir.startsWith('#'))
        ?DunyaSehri.kompaktSatirdan(satir),
  ];

  /// [ulkeKodu] ülkesindeki şehirlerde [sorgu] araması.
  ///
  /// Ad ya da ASCII ad, aksan ve büyük/küçük harf gözetmeden karşılaştırılır
  /// ("munchen", "MÜNCHEN" ve "München" aynıdır). Adı sorguyla başlayanlar
  /// önce, içinde geçenler sonra gelir; her grupta kalabalık şehir önce.
  /// Boş sorguda ülkenin en kalabalık şehirleri döner.
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
      if (ad.startsWith(s) || ascii.startsWith(s)) {
        baslayan.add(sehir);
      } else if (ad.contains(s) || ascii.contains(s)) {
        iceren.add(sehir);
      }
    }
    int sirala(DunyaSehri a, DunyaSehri b) {
      final int n = b.nufus.compareTo(a.nufus);
      return n != 0 ? n : a.ad.compareTo(b.ad);
    }

    baslayan.sort(sirala);
    iceren.sort(sirala);
    return <DunyaSehri>[...baslayan, ...iceren].take(enFazla).toList();
  }
}
