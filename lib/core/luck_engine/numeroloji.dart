/// Pitagor numerolojisi hesapları — saf Dart (CLAUDE.md kural 3).
///
/// Sistem seçimi (bilinçli ve sabit): Pitagor harf tablosu
/// (A=1 … I=9, J=1 … R=9, S=1 … Z=8); Türkçe harfler Latin
/// karşılıklarının değerini alır (Ç=C=3, Ğ=G=7, I/İ/ı=9, Ö=O=6,
/// Ş=S=1, Ü=U=3). Y sessiz harf sayılır. 11, 22 ve 33 "usta sayı"
/// olarak kişilik sayılarında korunur; kişisel döngü sayıları (yıl,
/// ay, gün) her zaman 1-9'a indirgenir.
///
/// Tüm fonksiyonlar deterministiktir ve hesap adımlarını da döndürür ki
/// arayüz "Nasıl hesaplandı?" açıklamasını gösterebilsin — kullanıcının
/// sonucun rastgele olmadığını görmesi yorumun güvenilirliğinin
/// temelidir.
library;

import 'engine_config.dart';

/// Bir hesap adımının türü (arayüz etiketi seçimi için).
enum HesapAdimTuru {
  /// Doğum ayının indirgenmesi.
  ay,

  /// Doğum gününün indirgenmesi.
  gun,

  /// Doğum yılının indirgenmesi.
  yil,

  /// Ara sonuçların toplanıp indirgenmesi.
  toplam,

  /// Tüm harflerin değerlerinin toplanması.
  harfler,

  /// Yalnızca sesli harflerin toplanması.
  sesliler,

  /// Yalnızca sessiz harflerin toplanması.
  sessizler,
}

/// Tek bir hesap adımı: [kaynak] verisinden [terimler] toplanıp
/// [sonuc]a indirgenmiştir.
class HesapAdimi {
  /// Tüm alanlarıyla adım oluşturur.
  const HesapAdimi({
    required this.tur,
    required this.kaynak,
    required this.terimler,
    required this.sonuc,
  });

  /// Adımın türü.
  final HesapAdimTuru tur;

  /// Ham kaynak (ör. "03", "1994", "AYŞE").
  final String kaynak;

  /// Toplanan terimler (ör. harf değerleri ya da rakamlar).
  final List<int> terimler;

  /// Adımın indirgenmiş sonucu.
  final int sonuc;

  /// Terimlerin ham toplamı (indirgenmeden önce).
  int get hamToplam => terimler.fold(0, (int a, int b) => a + b);
}

/// Bir numeroloji sayısı ve ona götüren adımlar.
class SayiHesabi {
  /// [deger] ve [adimlar] ile hesap sonucu oluşturur.
  const SayiHesabi({required this.deger, required this.adimlar});

  /// Hesaplanan sayı (1-9, 11, 22 veya 33).
  final int deger;

  /// Değere götüren adımlar (sırasıyla).
  final List<HesapAdimi> adimlar;

  /// Usta sayıysa taban sayısı (11→2, 22→4, 33→6), değilse kendisi.
  int get taban => Numeroloji.tabanSayi(deger);

  /// [deger] bir usta sayı mı?
  bool get ustaMi => EngineConfig.ustaSayilar.contains(deger);
}

/// Pitagor numerolojisi fonksiyonları.
abstract final class Numeroloji {
  /// Harf → değer tablosu (küçük harf anahtarlı).
  ///
  /// Latin a-z sırası 1..9 döngüsüyle değer alır; Türkçe ve şapkalı
  /// harfler Latin karşılıklarına eşlenir.
  static final Map<String, int> _harfTablosu = _tabloKur();

  /// Sesli harfler (küçük harf). Y bilinçli olarak dışarıdadır.
  static const Set<String> _sesliler = <String>{
    'a',
    'e',
    'ı',
    'i',
    'o',
    'ö',
    'u',
    'ü',
    'â',
    'î',
    'û',
  };

  static Map<String, int> _tabloKur() {
    final Map<String, int> tablo = <String, int>{};
    const int aKodu = 97; // 'a'
    const int harfSayisi = 26;
    for (int i = 0; i < harfSayisi; i++) {
      // Pitagor tablosu: 1..9 değerleri alfabede döngüyle tekrarlar.
      tablo[String.fromCharCode(aKodu + i)] =
          i % EngineConfig.numerolojiTabani + 1;
    }
    // Türkçe ve şapkalı harfler Latin karşılığının değerini alır.
    const Map<String, String> karsiliklar = <String, String>{
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'â': 'a',
      'î': 'i',
      'û': 'u',
    };
    karsiliklar.forEach((String tr, String latin) {
      tablo[tr] = tablo[latin]!;
    });
    return tablo;
  }

  /// Tek karakteri Türkçe kurallarla küçük harfe çevirir.
  ///
  /// Dart'ın `toLowerCase`'i 'I' → 'i' ve 'İ' → 'i̇' (birleşik nokta)
  /// üretir; ikisi de 9 değerinde olduğundan sonuç değişmez, ama
  /// birleşik nokta ayrı bir karakter olarak atlanmalıdır.
  static String _kucukHarf(String karakter) {
    switch (karakter) {
      case 'I':
        return 'ı';
      case 'İ':
        return 'i';
      default:
        return karakter.toLowerCase();
    }
  }

  /// [harf]in Pitagor değerini döndürür; harf değilse null.
  static int? harfDegeri(String harf) => _harfTablosu[_kucukHarf(harf)];

  /// [harf] sesli mi? (harf değilse false).
  static bool sesliMi(String harf) => _sesliler.contains(_kucukHarf(harf));

  /// [sayi]nın ondalık rakamları toplamı.
  static int rakamToplami(int sayi) {
    int kalan = sayi.abs();
    int toplam = 0;
    while (kalan > 0) {
      toplam += kalan % 10;
      kalan ~/= 10;
    }
    return toplam;
  }

  /// [sayi]yı rakam toplamıyla tek haneye indirger.
  ///
  /// [ustaKoru] true ise 11, 22, 33'e ulaşıldığında durulur.
  static int indirge(int sayi, {bool ustaKoru = true}) {
    int kalan = sayi.abs();
    while (kalan > EngineConfig.numerolojiTabani) {
      if (ustaKoru && EngineConfig.ustaSayilar.contains(kalan)) {
        return kalan;
      }
      kalan = rakamToplami(kalan);
    }
    return kalan;
  }

  /// Usta sayının taban karşılığı (11→2, 22→4, 33→6); diğerleri aynen.
  static int tabanSayi(int sayi) => sayi > EngineConfig.numerolojiTabani
      ? indirge(sayi, ustaKoru: false)
      : sayi;

  /// [sayi]nın rakamlarını soldan sağa liste olarak döndürür.
  static List<int> _rakamlar(int sayi) =>
      sayi.abs().toString().split('').map(int.parse).toList(growable: false);

  /// Yaşam Yolu sayısı: ay, gün ve yıl ayrı ayrı indirgenir, sonra
  /// toplanıp yeniden indirgenir (usta sayılar korunur).
  ///
  /// Örnek: 14.03.1994 → ay 3, gün 1+4=5, yıl 1+9+9+4=23→5;
  /// 3+5+5 = 13 → 4.
  static SayiHesabi yasamYolu(DateTime dogumTarihi) {
    final HesapAdimi ay = _tarihAdimi(
      HesapAdimTuru.ay,
      dogumTarihi.month,
      dogumTarihi.month.toString().padLeft(2, '0'),
    );
    final HesapAdimi gun = _tarihAdimi(
      HesapAdimTuru.gun,
      dogumTarihi.day,
      dogumTarihi.day.toString().padLeft(2, '0'),
    );
    final HesapAdimi yil = _tarihAdimi(
      HesapAdimTuru.yil,
      dogumTarihi.year,
      dogumTarihi.year.toString(),
    );
    final List<int> araSonuclar = <int>[ay.sonuc, gun.sonuc, yil.sonuc];
    final int deger = indirge(araSonuclar.fold(0, (int a, int b) => a + b));
    return SayiHesabi(
      deger: deger,
      adimlar: <HesapAdimi>[
        ay,
        gun,
        yil,
        HesapAdimi(
          tur: HesapAdimTuru.toplam,
          kaynak: '',
          terimler: araSonuclar,
          sonuc: deger,
        ),
      ],
    );
  }

  static HesapAdimi _tarihAdimi(HesapAdimTuru tur, int deger, String kaynak) {
    final List<int> rakamlar = _rakamlar(deger);
    // Tek haneli bir ay/gün (ör. 3) zaten indirgenmiştir; 11 ve 22
    // gibi usta sayılar da korunur.
    final int sonuc = indirge(deger);
    return HesapAdimi(
      tur: tur,
      kaynak: kaynak,
      terimler: rakamlar,
      sonuc: sonuc,
    );
  }

  /// İsim (Kader/İfade) sayısı: tüm harflerin değer toplamı.
  ///
  /// [tamAd] içinde hiç harf yoksa null döner.
  static SayiHesabi? isimSayisi(String tamAd) =>
      _harfHesabi(tamAd, HesapAdimTuru.harfler, (String h) => true);

  /// Ruh (Kalbin Arzusu) sayısı: yalnızca sesli harflerin toplamı.
  static SayiHesabi? ruhSayisi(String tamAd) =>
      _harfHesabi(tamAd, HesapAdimTuru.sesliler, sesliMi);

  /// Kişilik sayısı: yalnızca sessiz harflerin toplamı.
  static SayiHesabi? kisilikSayisi(String tamAd) =>
      _harfHesabi(tamAd, HesapAdimTuru.sessizler, (String h) => !sesliMi(h));

  static SayiHesabi? _harfHesabi(
    String tamAd,
    HesapAdimTuru tur,
    bool Function(String harf) dahilMi,
  ) {
    final StringBuffer kaynak = StringBuffer();
    final List<int> terimler = <int>[];
    // Runes üzerinden gezilir ki çok baytlı Türkçe harfler bölünmesin;
    // boşluk, tire, kesme ve birleşik noktalar harf olmadığı için atlanır.
    for (final int kod in tamAd.runes) {
      final String karakter = String.fromCharCode(kod);
      final int? deger = harfDegeri(karakter);
      if (deger == null || !dahilMi(karakter)) {
        continue;
      }
      kaynak.write(karakter);
      terimler.add(deger);
    }
    if (terimler.isEmpty) {
      return null;
    }
    final int deger = indirge(terimler.fold(0, (int a, int b) => a + b));
    return SayiHesabi(
      deger: deger,
      adimlar: <HesapAdimi>[
        HesapAdimi(
          tur: tur,
          kaynak: kaynak.toString(),
          terimler: terimler,
          sonuc: deger,
        ),
      ],
    );
  }

  /// Doğum günü sayısı: doğulan günün indirgenmişi (usta korunur).
  static int dogumGunuSayisi(DateTime dogumTarihi) => indirge(dogumTarihi.day);

  /// Kişisel Yıl (1-9): doğum ayı + doğum günü + [yil], her biri
  /// indirgenip toplanır. Takvim yılı başında değişir.
  ///
  /// Örnek: 14.03 doğumlu için 2026 → 3 + 5 + (2+0+2+6=10→1) = 9.
  static int kisiselYil(DateTime dogumTarihi, int yil) => indirge(
    indirge(dogumTarihi.month, ustaKoru: false) +
        indirge(dogumTarihi.day, ustaKoru: false) +
        indirge(yil, ustaKoru: false),
    ustaKoru: false,
  );

  /// Kişisel Ay (1-9): kişisel yıl + takvim ayı.
  static int kisiselAy(DateTime dogumTarihi, DateTime gun) => indirge(
    kisiselYil(dogumTarihi, gun.year) + indirge(gun.month, ustaKoru: false),
    ustaKoru: false,
  );

  /// Kişisel Gün (1-9): kişisel ay + takvim günü.
  ///
  /// Örnek: 14.03 doğumlu için 13 Eylül 2026 → ay 9 + (1+3=4) = 13 → 4.
  static int kisiselGun(DateTime dogumTarihi, DateTime gun) => indirge(
    kisiselAy(dogumTarihi, gun) + indirge(gun.day, ustaKoru: false),
    ustaKoru: false,
  );
}
