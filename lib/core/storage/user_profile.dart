import '../content/okuyucu.dart';
import '../luck_engine/luck_engine.dart';

/// Kullanıcı profili: isim, doğum tarihi, tam ad, doğum saati/yeri ve
/// onaylar.
///
/// user_profile kutusunda tek bir map kaydı olarak saklanır
/// (plan Session 2, madde 1). Sonradan eklenen alanlar opsiyoneldir ve
/// eski kayıtlar (yalnızca isim + doğum tarihi) sorunsuz okunur.
class UserProfile {
  /// Tüm alanlarıyla profil oluşturur.
  const UserProfile({
    required this.isim,
    required this.dogumTarihi,
    this.onboardingTamam = false,
    this.tamAd,
    this.uyariKabulSurumu,
    this.dogumSaatiDakika,
    this.dogumIliPlaka,
    this.yabanciDogumYeri,
  });

  /// Hive'dan okunan map'ten profil kurar.
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      isim: map[_isimAnahtari] as String,
      dogumTarihi: DateTime.parse(map[_dogumTarihiAnahtari] as String),
      onboardingTamam: map[_onboardingAnahtari] as bool? ?? false,
      tamAd: map[_tamAdAnahtari] as String?,
      uyariKabulSurumu: map[_uyariAnahtari] as int?,
      dogumSaatiDakika: map[_dogumSaatiAnahtari] as int?,
      dogumIliPlaka: map[_dogumIliAnahtari] as int?,
      yabanciDogumYeri: _yabanciYeriOku(map),
    );
  }

  /// Türkiye dışı doğum yeri alanlarını okur; biri eksikse null.
  ///
  /// K8-4 öncesi kayıtlarda bu alanlar yoktur: doğum yeri yalnız
  /// [_dogumIliAnahtari]dan (Türkiye ili) gelir, göç için yazma gerekmez.
  static DogumYeri? _yabanciYeriOku(Map<dynamic, dynamic> map) {
    final String? ulke = map[_dogumUlkeAnahtari] as String?;
    final String? ad = map[_dogumSehirAdiAnahtari] as String?;
    final String? saatDilimi = map[_dogumSaatDilimiAnahtari] as String?;
    final num? enlem = map[_dogumEnlemAnahtari] as num?;
    final num? boylam = map[_dogumBoylamAnahtari] as num?;
    if (ulke == null ||
        ad == null ||
        saatDilimi == null ||
        enlem == null ||
        boylam == null) {
      return null;
    }
    return DogumYeri(
      ulkeKodu: ulke,
      ad: ad,
      saatDilimi: saatDilimi,
      enlem: enlem.toDouble(),
      boylam: boylam.toDouble(),
      sehirKimligi: map[_dogumSehirKimligiAnahtari] as int?,
    );
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';
  static const String _tamAdAnahtari = 'tamAd';
  static const String _uyariAnahtari = 'uyariKabulSurumu';
  static const String _dogumSaatiAnahtari = 'dogumSaatiDakika';
  static const String _dogumIliAnahtari = 'dogumIliPlaka';
  static const String _dogumUlkeAnahtari = 'dogumUlkeKodu';
  static const String _dogumSehirAdiAnahtari = 'dogumSehirAdi';
  static const String _dogumSehirKimligiAnahtari = 'dogumSehirKimligi';
  static const String _dogumSaatDilimiAnahtari = 'dogumSaatDilimi';
  static const String _dogumEnlemAnahtari = 'dogumEnlem';
  static const String _dogumBoylamAnahtari = 'dogumBoylam';

  /// Kullanıcının girdiği görünen isim (selamlama ve skor tohumu için).
  ///
  /// Skor tohumu bu isimden türetildiği için onboarding sonrası
  /// değiştirilemez; aksi halde geçmiş günlerin anlamı kayar.
  final String isim;

  /// Kullanıcının doğum tarihi.
  final DateTime dogumTarihi;

  /// Onboarding akışı tamamlandı mı?
  final bool onboardingTamam;

  /// Doğumdaki tam ad (isim numerolojisi için; opsiyonel, düzenlenebilir).
  final String? tamAd;

  /// Kabul edilen uyarı/koşullar metninin sürümü (null = kabul yok).
  final int? uyariKabulSurumu;

  /// Doğum saati, gece yarısından itibaren dakika (0-1439); bilinmiyorsa
  /// null. Yalnızca Ay burcu kesinliği ve Yükselen için kullanılır; skor
  /// tohumunu etkilemez.
  final int? dogumSaatiDakika;

  /// Doğum ilinin plaka kodu (1-81); Türkiye dışında ya da bilinmiyorsa
  /// null.
  final int? dogumIliPlaka;

  /// Türkiye dışındaki doğum yeri (K8-4); [dogumIliPlaka] doluysa
  /// yok sayılır. İkisi birlikte [dogumYeri]nde birleşir.
  final DogumYeri? yabanciDogumYeri;

  /// Şans motoru için deterministik kullanıcı tohumu üretir.
  UserSeed get seed => UserSeed.fromIsim(isim: isim, dogumTarihi: dogumTarihi);

  /// Sabit kimlik katmanı (numeroloji + burç).
  KaderProfili get kaderProfili =>
      KaderProfili.hesapla(dogumTarihi: dogumTarihi, tamAd: tamAd);

  /// Doğum saati girilmiş mi?
  bool get dogumSaatiBiliniyor => dogumSaatiDakika != null;

  /// Doğum anının yerel (doğum yerindeki) duvar saati; saat bilinmiyorsa
  /// günün ortası ([EngineConfig.bilinmeyenSaat]).
  ///
  /// Değer `DateTime.utc` ile taşınır ama UTC anı DEĞİLDİR: yalnız
  /// alanları okunur. Yerel kurucu, cihazın kendi diliminde atlanan saati
  /// (ör. cihaz İstanbul'dayken 28 Mart 2010 03:30) bir saat ileri
  /// kaydırırdı.
  DateTime get yerelDogumAni {
    final int? dakika = dogumSaatiDakika;
    return DateTime.utc(
      dogumTarihi.year,
      dogumTarihi.month,
      dogumTarihi.day,
      dakika == null
          ? EngineConfig.bilinmeyenSaat
          : dakika ~/ Duration.minutesPerHour,
      dakika == null ? 0 : dakika % Duration.minutesPerHour,
    );
  }

  /// Doğum ili; seçilmediyse null.
  Il? get dogumIli {
    final int? plaka = dogumIliPlaka;
    return plaka == null ? null : TurkiyeIlleri.plakadan(plaka);
  }

  /// Doğum yeri: Türkiye ili ya da yabancı şehir; seçilmediyse null.
  DogumYeri? get dogumYeri {
    final Il? il = dogumIli;
    return il != null ? DogumYeri.il(il) : yabanciDogumYeri;
  }

  /// Doğum anının UTC farkı ve güvenilirliği.
  ///
  /// Doğum yerinin o tarihteki kuralı kullanılır (bkz. [DogumSaatDilimi]).
  /// Yer seçilmediyse Türkiye kuralı: uygulamanın K8 öncesi davranışı.
  DogumSaatDilimiSonucu get dogumSaatDilimi {
    final DateTime yerel = yerelDogumAni;
    return dogumYeri?.saatDilimiSonucu(yerel) ??
        DogumSaatDilimi.cozumle(
          ianaKimligi: EngineConfig.turkiyeSaatDilimiKimligi,
          yerel: yerel,
        )!;
  }

  /// Doğum haritası (Güneş, Ay ve biliniyorsa Yükselen).
  ///
  /// Doğum saati yoksa Ay öğlen için hesaplanır ve Yükselen hesaplanmaz.
  /// UTC farkı [dogumSaatDilimi]nden gelir; Türkiye doğumlarında
  /// `TurkiyeSaatDilimi` ile aynıdır.
  DogumHaritasi get dogumHaritasi {
    final DogumYeri? yer = dogumYeri;
    return DogumHaritasi.hesapla(
      yerelDogum: yerelDogumAni,
      utcFarkiSaat: dogumSaatDilimi.farkSaat,
      saatBiliniyor: dogumSaatiBiliniyor,
      enlem: yer?.enlem,
      boylam: yer?.boylam,
    );
  }

  /// İçerik birleştiricisinin girdisi: yorumu okuyacak kişi.
  ///
  /// Doğum Ay'ı ve yükselen yalnızca KESİN olduklarında aktarılır (Ay o gün
  /// burç değiştirmediyse; yükselen burç sınırından yeterince uzaksa):
  /// okuma emin olmadığı bir burcu söylemez.
  Okuyucu get okuyucu {
    final DogumHaritasi harita = dogumHaritasi;
    return Okuyucu(
      isim: isim,
      seed: seed,
      profil: kaderProfili,
      dogumAyi: harita.ayBurcuKesin ? harita.ayBurcu : null,
      yukselen: harita.yukselenSinirda ? null : harita.yukselen,
    );
  }

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
    _isimAnahtari: isim,
    _dogumTarihiAnahtari: dogumTarihi.toIso8601String(),
    _onboardingAnahtari: onboardingTamam,
    _tamAdAnahtari: tamAd,
    _uyariAnahtari: uyariKabulSurumu,
    _dogumSaatiAnahtari: dogumSaatiDakika,
    _dogumIliAnahtari: dogumIliPlaka,
    // Türkiye ili seçiliyse yabancı yer yazılmaz ([dogumYeri] ile aynı).
    ..._yabanciYeriYaz(dogumIliPlaka == null ? yabanciDogumYeri : null),
  };

  static Map<String, dynamic> _yabanciYeriYaz(DogumYeri? yer) => yer == null
      ? const <String, dynamic>{}
      : <String, dynamic>{
          _dogumUlkeAnahtari: yer.ulkeKodu,
          _dogumSehirAdiAnahtari: yer.ad,
          _dogumSehirKimligiAnahtari: yer.sehirKimligi,
          _dogumSaatDilimiAnahtari: yer.saatDilimi,
          _dogumEnlemAnahtari: yer.enlem,
          _dogumBoylamAnahtari: yer.boylam,
        };

  /// Seçili alanları değiştirilmiş bir kopya döndürür.
  ///
  /// [tamAdiTemizle] true ise tam ad null'a çekilir (copyWith null'ı
  /// "değiştirme" olarak yorumladığı için ayrı bayrak gerekir);
  /// [dogumSaatiniTemizle] ve [dogumIliniTemizle] de aynı amaçla vardır.
  ///
  /// Doğum yeri tek bir yerdir: [dogumIliPlaka] verilirse yabancı yer
  /// silinir; [dogumYeri] verilirse (Türkiye ili ise plaka olarak) eski
  /// yerin yerine geçer. [dogumIliniTemizle] ikisini de siler.
  UserProfile copyWith({
    String? isim,
    bool? onboardingTamam,
    String? tamAd,
    bool tamAdiTemizle = false,
    int? uyariKabulSurumu,
    int? dogumSaatiDakika,
    bool dogumSaatiniTemizle = false,
    int? dogumIliPlaka,
    bool dogumIliniTemizle = false,
    DogumYeri? dogumYeri,
  }) {
    int? plaka = this.dogumIliPlaka;
    DogumYeri? yabanci = yabanciDogumYeri;
    if (dogumIliniTemizle) {
      plaka = null;
      yabanci = null;
    } else if (dogumIliPlaka != null) {
      plaka = dogumIliPlaka;
      yabanci = null;
    } else if (dogumYeri != null) {
      plaka = dogumYeri.ilPlaka;
      yabanci = dogumYeri.ilPlaka == null ? dogumYeri : null;
    }
    return UserProfile(
      isim: isim ?? this.isim,
      dogumTarihi: dogumTarihi,
      onboardingTamam: onboardingTamam ?? this.onboardingTamam,
      tamAd: tamAdiTemizle ? null : (tamAd ?? this.tamAd),
      uyariKabulSurumu: uyariKabulSurumu ?? this.uyariKabulSurumu,
      dogumSaatiDakika: dogumSaatiniTemizle
          ? null
          : (dogumSaatiDakika ?? this.dogumSaatiDakika),
      dogumIliPlaka: plaka,
      yabanciDogumYeri: yabanci,
    );
  }
}
