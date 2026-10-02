/// İsim ve numara analizleri — saf Dart (CLAUDE.md kural 3).
///
/// Doğum tarihine ihtiyaç duymayan, paylaşmaya uygun "eğlence" araçları:
/// - [NumaraAnalizcisi]: telefon, plaka, ev/daire numarası gibi rakam ve
///   harf karışık metinlerin sayısı.
/// - [IsimAnalizi]: herhangi bir tam adın isim, ruh ve kişilik sayıları,
///   karmik dersleri, gizli tutkusu ve harfleri.
/// - [BebekIsmi]: aday isimlerin, ebeveynlerin (ya da bebeğin) yaşam yolu
///   sayılarıyla geleneksel uyumu ve sıralaması.
///
/// Harf değerleri ve indirgeme kuralları [Numeroloji] ile aynıdır; tüm
/// sonuçlar deterministiktir.
library;

import 'derin_numeroloji.dart';
import 'engine_config.dart';
import 'numeroloji.dart';
import 'uyum.dart';

/// Bir sembolün (rakam ya da harf) numeroloji değeri.
class SembolDegeri {
  /// [sembol] ve [deger] ile oluşturur.
  const SembolDegeri({required this.sembol, required this.deger});

  /// Metindeki karakter ("5", "A", "Ş").
  final String sembol;

  /// Değeri (rakamlar kendi değeri, harfler Pitagor değeri).
  final int deger;

  @override
  bool operator ==(Object other) =>
      other is SembolDegeri && other.sembol == sembol && other.deger == deger;

  @override
  int get hashCode => Object.hash(sembol, deger);
}

/// Bir numaranın (telefon, plaka, kapı numarası…) analizi.
class NumaraAnalizi {
  /// Tüm alanlarıyla analiz oluşturur.
  const NumaraAnalizi({
    required this.semboller,
    required this.hamToplam,
    required this.deger,
    required this.karmikBorc,
  });

  /// Hesaba giren semboller (boşluk, tire, + gibi işaretler hariç).
  final List<SembolDegeri> semboller;

  /// Değerlerin indirgenmemiş toplamı.
  final int hamToplam;

  /// Numaranın sayısı (1-9, usta sayılar 11/22/33 korunur).
  final int deger;

  /// İndirgenme zincirinde bir karmik borç sayısı varsa o sayı.
  final int? karmikBorc;

  /// [deger] bir usta sayı mı?
  bool get ustaMi => EngineConfig.ustaSayilar.contains(deger);

  /// İndirgenme zinciri ("38 → 11").
  List<int> get zincir => DerinNumeroloji.indirgemeZinciri(hamToplam);
}

/// Numara analizi fonksiyonları.
abstract final class NumaraAnalizcisi {
  /// [metin]deki rakam ve harflerden numaranın sayısını hesaplar.
  ///
  /// Rakamlar kendi değerini (0 dahil), harfler Pitagor değerini alır;
  /// diğer karakterler atlanır. Hiç rakam/harf yoksa ya da toplam 0 ise
  /// (ör. "000") null döner.
  ///
  /// Örnek: "0532 123 45 67" → 38 → 11.
  static NumaraAnalizi? analizEt(String metin) {
    final List<SembolDegeri> semboller = <SembolDegeri>[];
    for (final int kod in metin.runes) {
      final String k = String.fromCharCode(kod);
      final int? rakam = int.tryParse(k);
      if (rakam != null && k.length == 1) {
        semboller.add(SembolDegeri(sembol: k, deger: rakam));
        continue;
      }
      final int? harf = Numeroloji.harfDegeri(k);
      if (harf != null) {
        semboller.add(SembolDegeri(sembol: k.toUpperCase(), deger: harf));
      }
    }
    final int toplam = semboller.fold(
      0,
      (int a, SembolDegeri s) => a + s.deger,
    );
    if (toplam == 0) {
      return null;
    }
    return NumaraAnalizi(
      semboller: semboller,
      hamToplam: toplam,
      deger: Numeroloji.indirge(toplam),
      karmikBorc: DerinNumeroloji.karmikBorcSayisi(toplam),
    );
  }
}

/// Herhangi bir tam adın doğum tarihinden bağımsız analizi.
class IsimAnalizi {
  /// Tüm alanlarıyla analiz oluşturur (genelde [hesapla] kullanılır).
  const IsimAnalizi({
    required this.tamAd,
    required this.isim,
    required this.ruh,
    required this.kisilik,
    required this.karmikBorclar,
    required this.karmikDersler,
    required this.gizliTutku,
    required this.temelTasi,
    required this.tepeTasi,
    required this.denge,
  });

  /// [tamAd]ı analiz eder; harf içermiyorsa null.
  static IsimAnalizi? hesapla(String tamAd) {
    final SayiHesabi? isim = Numeroloji.isimSayisi(tamAd);
    if (isim == null) {
      return null;
    }
    final SayiHesabi? ruh = Numeroloji.ruhSayisi(tamAd);
    final SayiHesabi? kisilik = Numeroloji.kisilikSayisi(tamAd);
    final List<KarmikBorc> borclar = <KarmikBorc>[
      for (final (KarmikKaynak, SayiHesabi?) k in <(KarmikKaynak, SayiHesabi?)>[
        (KarmikKaynak.isim, isim),
        (KarmikKaynak.ruh, ruh),
        (KarmikKaynak.kisilik, kisilik),
      ])
        if (k.$2 != null &&
            DerinNumeroloji.karmikBorcSayisi(k.$2!.adimlar.last.hamToplam) !=
                null)
          KarmikBorc(
            sayi: DerinNumeroloji.karmikBorcSayisi(
              k.$2!.adimlar.last.hamToplam,
            )!,
            kaynak: k.$1,
          ),
    ];
    return IsimAnalizi(
      tamAd: tamAd.trim(),
      isim: isim,
      ruh: ruh,
      kisilik: kisilik,
      karmikBorclar: borclar,
      karmikDersler: DerinNumeroloji.karmikDersler(tamAd)!,
      gizliTutku: DerinNumeroloji.gizliTutku(tamAd)!,
      temelTasi: DerinNumeroloji.temelTasi(tamAd)!,
      tepeTasi: DerinNumeroloji.tepeTasi(tamAd)!,
      denge: DerinNumeroloji.dengeSayisi(tamAd)!,
    );
  }

  /// Analiz edilen ad (baştaki/sondaki boşluklar atılmış).
  final String tamAd;

  /// İsim (ifade) sayısı.
  final SayiHesabi isim;

  /// Ruh sayısı; sesli harf yoksa null.
  final SayiHesabi? ruh;

  /// Kişilik sayısı; sessiz harf yoksa null.
  final SayiHesabi? kisilik;

  /// İsimden gelen karmik borçlar (isim, ruh, kişilik).
  final List<KarmikBorc> karmikBorclar;

  /// İsimde hiç geçmeyen sayılar.
  final List<int> karmikDersler;

  /// İsimde en sık geçen sayı(lar).
  final List<int> gizliTutku;

  /// İlk adın ilk harfi.
  final HarfBilgisi temelTasi;

  /// İlk adın son harfi.
  final HarfBilgisi tepeTasi;

  /// Baş harflerin denge sayısı.
  final int denge;
}

/// Bir aday ismin referans kişilerle uyumu.
class IsimUyumu {
  /// Tüm alanlarıyla uyum oluşturur.
  const IsimUyumu({
    required this.analiz,
    required this.iliskiler,
    required this.puan,
  });

  /// Aday ismin analizi.
  final IsimAnalizi analiz;

  /// Her referans kişinin yaşam yolu ile isim sayısının ilişkisi (referans
  /// sırasıyla).
  final List<YasamYoluIliskisi> iliskiler;

  /// Ortalama uyum puanı (0-100).
  final int puan;
}

/// Bebek ismi uyumu fonksiyonları.
abstract final class BebekIsmi {
  /// [ilişki] türünün uyum puanı.
  static int iliskiPuani(YasamYoluIliskisi iliski) => switch (iliski) {
    YasamYoluIliskisi.ayniGrup => EngineConfig.isimUyumAyniGrupPuani,
    YasamYoluIliskisi.ayna => EngineConfig.isimUyumAynaPuani,
    YasamYoluIliskisi.destekleyici => EngineConfig.isimUyumDestekleyiciPuani,
    YasamYoluIliskisi.zorlayici => EngineConfig.isimUyumZorlayiciPuani,
  };

  /// [aday] tam adının, [referansDogumlar] (ebeveynler ya da bebek)
  /// yaşam yollarıyla uyumu.
  ///
  /// Aday ismin isim sayısı her referansın yaşam yolu tabanıyla
  /// karşılaştırılır; puan, ilişki puanlarının yuvarlanmış ortalamasıdır.
  /// [aday] harf içermiyorsa null. [referansDogumlar] boşsa [ArgumentError].
  static IsimUyumu? uyum(String aday, List<DateTime> referansDogumlar) {
    if (referansDogumlar.isEmpty) {
      throw ArgumentError.value(
        referansDogumlar,
        'referansDogumlar',
        'En az bir doğum tarihi gerekli',
      );
    }
    final IsimAnalizi? analiz = IsimAnalizi.hesapla(aday);
    if (analiz == null) {
      return null;
    }
    final List<YasamYoluIliskisi> iliskiler = <YasamYoluIliskisi>[
      for (final DateTime d in referansDogumlar)
        sayiIliskisi(analiz.isim.taban, Numeroloji.yasamYolu(d).taban),
    ];
    final int toplam = iliskiler.fold(
      0,
      (int a, YasamYoluIliskisi i) => a + iliskiPuani(i),
    );
    return IsimUyumu(
      analiz: analiz,
      iliskiler: iliskiler,
      puan: (toplam / iliskiler.length).round(),
    );
  }

  /// [adaylar]ı [referansDogumlar] ile uyum puanına göre (yüksekten
  /// düşüğe) sıralar; eşitlikte giriş sırası korunur. Harf içermeyen
  /// adaylar atlanır.
  static List<IsimUyumu> sirala(
    List<String> adaylar,
    List<DateTime> referansDogumlar,
  ) {
    final List<IsimUyumu> sonuc = <IsimUyumu>[
      for (final String a in adaylar)
        if (uyum(a, referansDogumlar) case final IsimUyumu u) u,
    ];
    // List.sort kararlı değildir: eşitlikte giriş sırası indeksle korunur.
    final List<int> sira = List<int>.generate(sonuc.length, (int i) => i)
      ..sort((int x, int y) {
        final int fark = sonuc[y].puan.compareTo(sonuc[x].puan);
        return fark != 0 ? fark : x.compareTo(y);
      });
    return <IsimUyumu>[for (final int i in sira) sonuc[i]];
  }
}
