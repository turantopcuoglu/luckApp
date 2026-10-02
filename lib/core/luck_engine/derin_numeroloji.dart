/// Derin numeroloji hesapları — saf Dart (CLAUDE.md kural 3).
///
/// Temel sayıların (yaşam yolu, isim, ruh, kişilik) üzerine kişisel
/// raporun dayandığı ikinci katman:
/// - Zirveler ve zorluklar: hayatın dört dönemi, yaş aralıklarıyla.
/// - Karmik borç sayıları (13, 14, 16, 19) ve kaynakları.
/// - Karmik dersler (isimde hiç geçmeyen sayılar) ve gizli tutku (isimde
///   en sık geçen sayı).
/// - Olgunluk sayısı, temel taşı / tepe taşı harfleri, denge sayısı.
///
/// Tüm sonuçlar yalnızca doğum tarihi ve tam addan türetilir; aynı girdi
/// HER ZAMAN aynı raporu verir (CLAUDE.md kural 8). Harf değerleri ve
/// indirgeme kuralları [Numeroloji] ile aynıdır.
library;

import 'engine_config.dart';
import 'numeroloji.dart';

/// Karmik borç sayısının görüldüğü hesap.
enum KarmikKaynak {
  /// Yaşam yolu toplamı (ay + gün + yıl, indirgenmeden önce).
  yasamYolu,

  /// Doğulan gün (ayın 13'ü, 14'ü, 16'sı ya da 19'u).
  dogumGunu,

  /// İsim sayısının harf toplamı.
  isim,

  /// Ruh sayısının (sesli harfler) toplamı.
  ruh,

  /// Kişilik sayısının (sessiz harfler) toplamı.
  kisilik,
}

/// Bir karmik borç bulgusu: [sayi] (13/14/16/19), [kaynak] hesabında.
class KarmikBorc {
  /// [sayi] ve [kaynak] ile bulgu oluşturur.
  const KarmikBorc({required this.sayi, required this.kaynak});

  /// Karmik borç sayısı.
  final int sayi;

  /// Sayının görüldüğü hesap.
  final KarmikKaynak kaynak;

  @override
  bool operator ==(Object other) =>
      other is KarmikBorc && other.sayi == sayi && other.kaynak == kaynak;

  @override
  int get hashCode => Object.hash(sayi, kaynak);

  @override
  String toString() => 'KarmikBorc($sayi, ${kaynak.name})';
}

/// Hayatın bir dönemi: zirve (fırsat teması) ve zorluk (ders teması).
class YasamDonemi {
  /// Tüm alanlarıyla dönem oluşturur.
  const YasamDonemi({
    required this.sira,
    required this.zirve,
    required this.zorluk,
    required this.baslangicYasi,
    required this.bitisYasi,
  });

  /// Dönem sırası (1-4).
  final int sira;

  /// Zirve sayısı (1-9, 11, 22, 33).
  final int zirve;

  /// Zorluk sayısı (0-8; 0 "seçim özgürlüğü" demektir).
  final int zorluk;

  /// Dönemin başladığı yaş (dahil).
  final int baslangicYasi;

  /// Dönemin bittiği yaş (hariç); son dönemde null (ömür boyu sürer).
  final int? bitisYasi;

  /// [yas] bu dönemin içinde mi?
  bool kapsar(int yas) =>
      yas >= baslangicYasi && (bitisYasi == null || yas < bitisYasi!);
}

/// Bir harf ve Pitagor değeri (temel taşı / tepe taşı için).
class HarfBilgisi {
  /// [harf] ve [deger] ile bilgi oluşturur.
  const HarfBilgisi({required this.harf, required this.deger});

  /// Büyük harf (Türkçe kurallarla: i → İ, ı → I).
  final String harf;

  /// Harfin Pitagor değeri (1-9).
  final int deger;

  @override
  bool operator ==(Object other) =>
      other is HarfBilgisi && other.harf == harf && other.deger == deger;

  @override
  int get hashCode => Object.hash(harf, deger);
}

/// Derin numeroloji fonksiyonları.
abstract final class DerinNumeroloji {
  /// [sayi]dan başlayıp [Numeroloji.indirge] ile aynı kuralla (usta sayıda
  /// durarak) tek haneye inene kadar görülen tüm değerler.
  ///
  /// Örnek: 49 → [49, 13, 4]; 29 → [29, 11]; 7 → [7].
  static List<int> indirgemeZinciri(int sayi) {
    final List<int> zincir = <int>[sayi.abs()];
    while (zincir.last > EngineConfig.numerolojiTabani &&
        !EngineConfig.ustaSayilar.contains(zincir.last)) {
      zincir.add(Numeroloji.rakamToplami(zincir.last));
    }
    return zincir;
  }

  /// [sayi]nın indirgenme zincirindeki ilk karmik borç sayısı; yoksa null.
  static int? karmikBorcSayisi(int sayi) {
    for (final int ara in indirgemeZinciri(sayi)) {
      if (EngineConfig.karmikBorcSayilari.contains(ara)) {
        return ara;
      }
    }
    return null;
  }

  /// [dogumTarihi] ve [tamAd]'da görülen tüm karmik borçlar.
  ///
  /// Sıra: yaşam yolu, doğum günü, isim, ruh, kişilik. İsim tabanlı
  /// kaynaklar yalnızca [tamAd] harf içeriyorsa değerlendirilir.
  static List<KarmikBorc> karmikBorclar(DateTime dogumTarihi, String? tamAd) {
    final List<KarmikBorc> borclar = <KarmikBorc>[];
    void ekle(int? sayi, KarmikKaynak kaynak) {
      if (sayi != null) {
        borclar.add(KarmikBorc(sayi: sayi, kaynak: kaynak));
      }
    }

    // Yaşam yolu: indirgenmiş ay + gün + yıl toplamı (son adımın ham hali).
    final SayiHesabi yasamYolu = Numeroloji.yasamYolu(dogumTarihi);
    ekle(
      karmikBorcSayisi(yasamYolu.adimlar.last.hamToplam),
      KarmikKaynak.yasamYolu,
    );
    // Doğum günü yalnızca doğrudan 13/14/16/19 ise sayılır.
    ekle(
      EngineConfig.karmikBorcSayilari.contains(dogumTarihi.day)
          ? dogumTarihi.day
          : null,
      KarmikKaynak.dogumGunu,
    );
    final String ad = tamAd ?? '';
    final Map<KarmikKaynak, SayiHesabi?> isimHesaplari =
        <KarmikKaynak, SayiHesabi?>{
          KarmikKaynak.isim: Numeroloji.isimSayisi(ad),
          KarmikKaynak.ruh: Numeroloji.ruhSayisi(ad),
          KarmikKaynak.kisilik: Numeroloji.kisilikSayisi(ad),
        };
    isimHesaplari.forEach((KarmikKaynak kaynak, SayiHesabi? hesap) {
      if (hesap != null) {
        ekle(karmikBorcSayisi(hesap.adimlar.last.hamToplam), kaynak);
      }
    });
    return borclar;
  }

  /// [tamAd]daki harflerin 1-9 değerlerine göre dağılımı.
  ///
  /// Anahtarlar her zaman 1..9'dur (geçmeyen sayı 0). Harf yoksa null.
  static Map<int, int>? sayiDagilimi(String tamAd) {
    final Map<int, int> dagilim = <int, int>{
      for (int s = 1; s <= EngineConfig.numerolojiTabani; s++) s: 0,
    };
    bool harfVar = false;
    for (final int kod in tamAd.runes) {
      final int? deger = Numeroloji.harfDegeri(String.fromCharCode(kod));
      if (deger == null) {
        continue;
      }
      harfVar = true;
      dagilim[deger] = dagilim[deger]! + 1;
    }
    return harfVar ? dagilim : null;
  }

  /// Karmik dersler: [tamAd]da hiç geçmeyen sayılar (artan sırada).
  ///
  /// Harf yoksa null; tüm sayılar geçiyorsa boş liste.
  static List<int>? karmikDersler(String tamAd) {
    final Map<int, int>? dagilim = sayiDagilimi(tamAd);
    if (dagilim == null) {
      return null;
    }
    return <int>[
      for (final MapEntry<int, int> e in dagilim.entries)
        if (e.value == 0) e.key,
    ];
  }

  /// Gizli tutku: [tamAd]da en sık geçen sayı(lar) (eşitlikte hepsi, artan).
  ///
  /// Harf yoksa null.
  static List<int>? gizliTutku(String tamAd) {
    final Map<int, int>? dagilim = sayiDagilimi(tamAd);
    if (dagilim == null) {
      return null;
    }
    final int enCok = dagilim.values.reduce((int a, int b) => a > b ? a : b);
    return <int>[
      for (final MapEntry<int, int> e in dagilim.entries)
        if (e.value == enCok) e.key,
    ];
  }

  /// Olgunluk sayısı: yaşam yolu + isim sayısı (usta sayılar korunur).
  ///
  /// [tamAd] harf içermiyorsa null.
  static int? olgunlukSayisi(DateTime dogumTarihi, String tamAd) {
    final SayiHesabi? isim = Numeroloji.isimSayisi(tamAd);
    if (isim == null) {
      return null;
    }
    return Numeroloji.indirge(
      Numeroloji.yasamYolu(dogumTarihi).deger + isim.deger,
    );
  }

  /// [tamAd]ı harflerden oluşan kelimelere böler (boşluk ve tire ayırır;
  /// kesme işareti gibi harf olmayan karakterler atlanır).
  static List<List<String>> _kelimeler(String tamAd) {
    final List<List<String>> kelimeler = <List<String>>[];
    List<String> mevcut = <String>[];
    for (final int kod in tamAd.runes) {
      final String k = String.fromCharCode(kod);
      if (Numeroloji.harfDegeri(k) != null) {
        mevcut.add(k);
      } else if (k.trim().isEmpty || k == '-') {
        if (mevcut.isNotEmpty) {
          kelimeler.add(mevcut);
          mevcut = <String>[];
        }
      }
    }
    if (mevcut.isNotEmpty) {
      kelimeler.add(mevcut);
    }
    return kelimeler;
  }

  /// [harf]i Türkçe kurallarla büyük harfe çevirir (i → İ, ı → I).
  static String _buyukHarf(String harf) => switch (harf) {
    'i' => 'İ',
    'ı' => 'I',
    _ => harf.toUpperCase(),
  };

  static HarfBilgisi _harfBilgisi(String harf) =>
      HarfBilgisi(harf: _buyukHarf(harf), deger: Numeroloji.harfDegeri(harf)!);

  /// Temel taşı: ilk adın ilk harfi (hayata yaklaşım biçimi). Harf yoksa
  /// null.
  static HarfBilgisi? temelTasi(String tamAd) {
    final List<List<String>> k = _kelimeler(tamAd);
    return k.isEmpty ? null : _harfBilgisi(k.first.first);
  }

  /// Tepe taşı: ilk adın son harfi (bir işi bitirme biçimi). Harf yoksa
  /// null.
  static HarfBilgisi? tepeTasi(String tamAd) {
    final List<List<String>> k = _kelimeler(tamAd);
    return k.isEmpty ? null : _harfBilgisi(k.first.last);
  }

  /// Denge sayısı: her ad parçasının baş harf değerleri toplamı, 1-9'a
  /// indirgenmiş (zor anlarda dengeyi bulma biçimi). Harf yoksa null.
  static int? dengeSayisi(String tamAd) {
    final List<List<String>> k = _kelimeler(tamAd);
    if (k.isEmpty) {
      return null;
    }
    final int toplam = k
        .map((List<String> kelime) => Numeroloji.harfDegeri(kelime.first)!)
        .fold(0, (int a, int b) => a + b);
    return Numeroloji.indirge(toplam, ustaKoru: false);
  }

  /// [dogumTarihi] sahibinin [tarih]teki tam yaşı.
  static int tamYas(DateTime dogumTarihi, DateTime tarih) {
    int yas = tarih.year - dogumTarihi.year;
    final bool dogumGunuGelmedi =
        tarih.month < dogumTarihi.month ||
        (tarih.month == dogumTarihi.month && tarih.day < dogumTarihi.day);
    if (dogumGunuGelmedi) {
      yas--;
    }
    return yas < 0 ? 0 : yas;
  }

  /// Dört yaşam dönemi: zirve ve zorluk sayıları, yaş aralıklarıyla.
  ///
  /// Bileşenler tek haneye indirgenmiş ay (A), gün (G) ve yıldır (Y):
  /// - Zirveler: 1 = A+G, 2 = G+Y, 3 = Z1+Z2, 4 = A+Y (usta sayılar
  ///   korunur; 3. zirvede usta zirveler taban değeriyle toplanır).
  /// - Zorluklar: 1 = |A−G|, 2 = |G−Y|, 3 = |Z1−Z2| (zorluklar), 4 = |A−Y|.
  /// - İlk dönem 0 yaştan (36 − yaşam yolu tabanı) yaşına kadar sürer;
  ///   ikinci ve üçüncü dokuzar yıldır; dördüncü ömür boyudur.
  ///
  /// Örnek: 14.03.1994 → A=3, G=5, Y=5; zirveler 8, 1, 9, 8; zorluklar
  /// 2, 0, 2, 2; dönemler 0-32, 32-41, 41-50, 50+.
  static List<YasamDonemi> yasamDonemleri(DateTime dogumTarihi) {
    final int a = Numeroloji.indirge(dogumTarihi.month, ustaKoru: false);
    final int g = Numeroloji.indirge(dogumTarihi.day, ustaKoru: false);
    final int y = Numeroloji.indirge(dogumTarihi.year, ustaKoru: false);

    final int z1 = Numeroloji.indirge(a + g);
    final int z2 = Numeroloji.indirge(g + y);
    final int z3 = Numeroloji.indirge(
      Numeroloji.tabanSayi(z1) + Numeroloji.tabanSayi(z2),
    );
    final int z4 = Numeroloji.indirge(a + y);

    final int c1 = (a - g).abs();
    final int c2 = (g - y).abs();
    final int c3 = (c1 - c2).abs();
    final int c4 = (a - y).abs();

    final int ilkBitis =
        EngineConfig.zirveIlkBitisTabani -
        Numeroloji.yasamYolu(dogumTarihi).taban;
    final int ikinciBitis = ilkBitis + EngineConfig.zirveDonemYili;
    final int ucuncuBitis = ikinciBitis + EngineConfig.zirveDonemYili;

    return <YasamDonemi>[
      YasamDonemi(
        sira: 1,
        zirve: z1,
        zorluk: c1,
        baslangicYasi: 0,
        bitisYasi: ilkBitis,
      ),
      YasamDonemi(
        sira: 2,
        zirve: z2,
        zorluk: c2,
        baslangicYasi: ilkBitis,
        bitisYasi: ikinciBitis,
      ),
      YasamDonemi(
        sira: 3,
        zirve: z3,
        zorluk: c3,
        baslangicYasi: ikinciBitis,
        bitisYasi: ucuncuBitis,
      ),
      YasamDonemi(
        sira: EngineConfig.zirveDonemSayisi,
        zirve: z4,
        zorluk: c4,
        baslangicYasi: ucuncuBitis,
        bitisYasi: null,
      ),
    ];
  }

  /// [yil] boyunca her takvim ayının kişisel ay sayısı (Ocak → Aralık).
  ///
  /// Yıllık raporun "ay ay" bölümünün dayanağıdır.
  static List<int> kisiselAylar(DateTime dogumTarihi, int yil) => <int>[
    for (int ay = 1; ay <= DateTime.monthsPerYear; ay++)
      Numeroloji.kisiselAy(dogumTarihi, DateTime(yil, ay)),
  ];
}

/// Bir kişinin derin numeroloji raporunun ham verisi.
///
/// Metin içermez; içerik katmanı bu sayılara göre metin seçer. İsim
/// tabanlı alanlar, tam ad harf içermiyorsa null'dur.
class NumerolojiRaporu {
  /// Tüm alanlarıyla rapor oluşturur (genelde [hesapla] kullanılır).
  const NumerolojiRaporu({
    required this.dogumTarihi,
    required this.donemler,
    required this.karmikBorclar,
    required this.olgunluk,
    required this.karmikDersler,
    required this.gizliTutku,
    required this.temelTasi,
    required this.tepeTasi,
    required this.dengeSayisi,
  });

  /// [dogumTarihi] ve [tamAd]'dan raporu hesaplar.
  factory NumerolojiRaporu.hesapla({
    required DateTime dogumTarihi,
    String? tamAd,
  }) {
    final DateTime gun = DateTime(
      dogumTarihi.year,
      dogumTarihi.month,
      dogumTarihi.day,
    );
    final String ad = tamAd ?? '';
    return NumerolojiRaporu(
      dogumTarihi: gun,
      donemler: DerinNumeroloji.yasamDonemleri(gun),
      karmikBorclar: DerinNumeroloji.karmikBorclar(gun, ad),
      olgunluk: DerinNumeroloji.olgunlukSayisi(gun, ad),
      karmikDersler: DerinNumeroloji.karmikDersler(ad),
      gizliTutku: DerinNumeroloji.gizliTutku(ad),
      temelTasi: DerinNumeroloji.temelTasi(ad),
      tepeTasi: DerinNumeroloji.tepeTasi(ad),
      dengeSayisi: DerinNumeroloji.dengeSayisi(ad),
    );
  }

  /// Raporun hesaplandığı doğum tarihi (saatten arındırılmış).
  final DateTime dogumTarihi;

  /// Dört yaşam dönemi (sırayla).
  final List<YasamDonemi> donemler;

  /// Karmik borç bulguları (boş olabilir).
  final List<KarmikBorc> karmikBorclar;

  /// Olgunluk sayısı.
  final int? olgunluk;

  /// İsimde hiç geçmeyen sayılar.
  final List<int>? karmikDersler;

  /// İsimde en sık geçen sayı(lar).
  final List<int>? gizliTutku;

  /// İlk adın ilk harfi.
  final HarfBilgisi? temelTasi;

  /// İlk adın son harfi.
  final HarfBilgisi? tepeTasi;

  /// Baş harflerin denge sayısı.
  final int? dengeSayisi;

  /// [tarih]te içinde bulunulan yaşam dönemi.
  YasamDonemi aktifDonem(DateTime tarih) {
    final int yas = DerinNumeroloji.tamYas(dogumTarihi, tarih);
    return donemler.firstWhere((YasamDonemi d) => d.kapsar(yas));
  }
}
