import '../content/okuyucu.dart';
import '../luck_engine/luck_engine.dart';

/// Kullanıcı profili: isim, doğum tarihi, tam ad, tercihler ve onaylar.
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
    this.tercihler = const OkuyucuTercihleri(),
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
      tercihler: OkuyucuTercihleri(
        enerji: _enumOku(EnerjiTarzi.values, map[_enerjiAnahtari]),
        karar: _enumOku(KararTarzi.values, map[_kararAnahtari]),
        iliski: _enumOku(IliskiDurumu.values, map[_iliskiAnahtari]),
        ugras: _enumOku(Ugras.values, map[_ugrasAnahtari]),
      ),
      uyariKabulSurumu: map[_uyariAnahtari] as int?,
      dogumSaatiDakika: map[_dogumSaatiAnahtari] as int?,
      dogumIliPlaka: map[_dogumIliAnahtari] as int?,
    );
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';
  static const String _tamAdAnahtari = 'tamAd';
  static const String _enerjiAnahtari = 'enerji';
  static const String _kararAnahtari = 'karar';
  static const String _iliskiAnahtari = 'iliski';
  static const String _ugrasAnahtari = 'ugras';
  static const String _uyariAnahtari = 'uyariKabulSurumu';
  static const String _dogumSaatiAnahtari = 'dogumSaatiDakika';
  static const String _dogumIliAnahtari = 'dogumIliPlaka';

  /// Kayıtlı enum adını değere çevirir; bilinmeyen/boş değer null olur
  /// (ileride bir seçenek kaldırılırsa eski kayıt uygulamayı çökertmez).
  static T? _enumOku<T extends Enum>(List<T> degerler, Object? ham) {
    if (ham is! String) {
      return null;
    }
    for (final T deger in degerler) {
      if (deger.name == ham) {
        return deger;
      }
    }
    return null;
  }

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

  /// Onboarding tercih cevapları.
  final OkuyucuTercihleri tercihler;

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

  /// İçerik birleştiricisinin girdisi.
  Okuyucu get okuyucu => Okuyucu(
        isim: isim,
        seed: seed,
        profil: kaderProfili,
        tercihler: tercihler,
      );

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _isimAnahtari: isim,
        _dogumTarihiAnahtari: dogumTarihi.toIso8601String(),
        _onboardingAnahtari: onboardingTamam,
        _tamAdAnahtari: tamAd,
        _enerjiAnahtari: tercihler.enerji?.name,
        _kararAnahtari: tercihler.karar?.name,
        _iliskiAnahtari: tercihler.iliski?.name,
        _ugrasAnahtari: tercihler.ugras?.name,
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
    OkuyucuTercihleri? tercihler,
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
        tercihler: tercihler ?? this.tercihler,
        uyariKabulSurumu: uyariKabulSurumu ?? this.uyariKabulSurumu,
        dogumSaatiDakika: dogumSaatiniTemizle
            ? null
            : (dogumSaatiDakika ?? this.dogumSaatiDakika),
        dogumIliPlaka:
            dogumIliniTemizle ? null : (dogumIliPlaka ?? this.dogumIliPlaka),
      );
}
