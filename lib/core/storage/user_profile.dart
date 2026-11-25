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
    );
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';
  static const String _tamAdAnahtari = 'tamAd';
  static const String _uyariAnahtari = 'uyariKabulSurumu';
  static const String _dogumSaatiAnahtari = 'dogumSaatiDakika';
  static const String _dogumIliAnahtari = 'dogumIliPlaka';

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

  /// Doğum ilinin plaka kodu (1-81); bilinmiyorsa null.
  final int? dogumIliPlaka;

  /// Şans motoru için deterministik kullanıcı tohumu üretir.
  UserSeed get seed => UserSeed.fromIsim(isim: isim, dogumTarihi: dogumTarihi);

  /// Sabit kimlik katmanı (numeroloji + burç).
  KaderProfili get kaderProfili =>
      KaderProfili.hesapla(dogumTarihi: dogumTarihi, tamAd: tamAd);

  /// Doğum saati girilmiş mi?
  bool get dogumSaatiBiliniyor => dogumSaatiDakika != null;

  /// Doğum anının yerel saati; saat bilinmiyorsa günün ortası
  /// ([EngineConfig.bilinmeyenSaat]).
  DateTime get yerelDogumAni {
    final int? dakika = dogumSaatiDakika;
    return DateTime(
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

  /// Doğum haritası (Güneş, Ay ve biliniyorsa Yükselen).
  ///
  /// Doğum saati yoksa Ay öğlen için hesaplanır ve Yükselen hesaplanmaz;
  /// saat dilimi Türkiye'nin o tarihteki kuralından bulunur.
  DogumHaritasi get dogumHaritasi {
    final DateTime yerel = yerelDogumAni;
    final Il? il = dogumIli;
    return DogumHaritasi.hesapla(
      yerelDogum: yerel,
      utcFarkiSaat: TurkiyeSaatDilimi.utcFarki(yerel).farkSaat.toDouble(),
      saatBiliniyor: dogumSaatiBiliniyor,
      enlem: il?.enlem,
      boylam: il?.boylam,
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
      };

  /// Seçili alanları değiştirilmiş bir kopya döndürür.
  ///
  /// [tamAdiTemizle] true ise tam ad null'a çekilir (copyWith null'ı
  /// "değiştirme" olarak yorumladığı için ayrı bayrak gerekir);
  /// [dogumSaatiniTemizle] ve [dogumIliniTemizle] de aynı amaçla vardır.
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
  }) =>
      UserProfile(
        isim: isim ?? this.isim,
        dogumTarihi: dogumTarihi,
        onboardingTamam: onboardingTamam ?? this.onboardingTamam,
        tamAd: tamAdiTemizle ? null : (tamAd ?? this.tamAd),
        uyariKabulSurumu: uyariKabulSurumu ?? this.uyariKabulSurumu,
        dogumSaatiDakika: dogumSaatiniTemizle
            ? null
            : (dogumSaatiDakika ?? this.dogumSaatiDakika),
        dogumIliPlaka:
            dogumIliniTemizle ? null : (dogumIliPlaka ?? this.dogumIliPlaka),
      );
}
