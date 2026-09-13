import '../localization/app_dil.dart';
import '../luck_engine/luck_engine.dart';

/// Kullanıcı profili: isim, doğum tarihi, onboarding durumu ve
/// bildirim tercihleri.
///
/// user_profile kutusunda tek bir map kaydı olarak saklanır
/// (plan Session 2, madde 1). Bildirim tercihleri (Phase 1: Ayarlar)
/// bilinçli olarak [seed]'i beslemez; böylece anayasa kural 8
/// (determinizm) korunur.
class UserProfile {
  /// Tüm alanlarıyla profil oluşturur.
  const UserProfile({
    required this.isim,
    this.dogumTarihi,
    this.rituelKimligi,
    this.seedSurumu = 1,
    this.onboardingTamam = false,
    this.bildirimlerAcik = true,
    this.aksamBildirimDakika,
    this.sabahBildirimDakika,
    this.dil,
  });

  /// Hive'dan okunan map'ten profil kurar.
  ///
  /// Bildirim alanları geriye uyumlu okunur: eski kayıtlar bu
  /// anahtarları içermez, o yüzden `?? varsayılan` uygulanır.
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    try {
      final Object? surum = map.containsKey('seedSurumu')
          ? map['seedSurumu']
          : 1;
      final Object? tarih = map[_dogumTarihiAnahtari];
      final Object? kimlik = map['rituelKimligi'];
      if (surum is! int ||
          (surum != 1 && surum != 2) ||
          (surum == 1 && tarih is! String) ||
          (surum == 2 && (kimlik is! String || kimlik.trim().isEmpty))) {
        throw const FormatException(
          'Profil tohum bilgisi eksik veya sürüm desteklenmiyor.',
        );
      }
      return UserProfile(
        isim: map[_isimAnahtari] as String,
        dogumTarihi: tarih == null ? null : DateTime.parse(tarih as String),
        rituelKimligi: kimlik as String?,
        seedSurumu: surum,
        onboardingTamam: map[_onboardingAnahtari] as bool,
        bildirimlerAcik: map[_bildirimlerAcikAnahtari] as bool? ?? true,
        aksamBildirimDakika: map[_aksamDakikaAnahtari] as int?,
        sabahBildirimDakika: map[_sabahDakikaAnahtari] as int?,
        dil: _dilCoz(map[_dilAnahtari] as String?),
      );
    } on TypeError {
      throw const FormatException(
        'Profil kaydındaki alan türleri geçersiz; kayıt değiştirilmedi.',
      );
    } on FormatException {
      throw const FormatException(
        'Profil kaydı okunamadı: tarih veya tohum sürümü geçersiz; kayıt değiştirilmedi.',
      );
    }
  }

  /// Kayıtlı dil kodunu [AppDil]'e çevirir; yoksa/tanınmıyorsa null
  /// (null = cihaz dilini izle). Eski kayıtlar bu anahtarı içermez.
  static AppDil? _dilCoz(String? kod) {
    for (final AppDil d in AppDil.values) {
      if (d.name == kod) {
        return d;
      }
    }
    return null;
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';
  static const String _bildirimlerAcikAnahtari = 'bildirimlerAcik';
  static const String _aksamDakikaAnahtari = 'aksamBildirimDakika';
  static const String _sabahDakikaAnahtari = 'sabahBildirimDakika';
  static const String _dilAnahtari = 'dil';
  static const Object _degismedi = Object();

  /// Kullanıcının girdiği görünen isim (selamlama için).
  final String isim;

  /// V1'de motor girdisi; v2'de yalnız kullanıcının seçtiği profil bilgisi.
  final DateTime? dogumTarihi;

  /// Yeni profilde bir kez üretilip saklanan anonim kimlik.
  final String? rituelKimligi;

  /// 1: eski isim/doğum tarihi; 2: anonim ritüel kimliği.
  final int seedSurumu;

  /// Onboarding akışı tamamlandı mı?
  final bool onboardingTamam;

  /// Günlük hatırlatma bildirimleri açık mı?
  final bool bildirimlerAcik;

  /// Akşam hatırlatmasının gün-içi dakika değeri (0-1439);
  /// `null` ise [FeedbackConfig] varsayılanı (21:00) kullanılır.
  final int? aksamBildirimDakika;

  /// Sabah hatırlatmasının gün-içi dakika değeri (0-1439);
  /// `null` ise [FeedbackConfig] varsayılanı (08:30) kullanılır.
  final int? sabahBildirimDakika;

  /// Kullanıcının açık dil tercihi; `null` ise cihaz dili izlenir.
  ///
  /// Bildirim tercihleri gibi bilinçli olarak [seed]'i beslemez —
  /// dil skoru ETKİLEMEZ (kural 8).
  final AppDil? dil;

  /// Şans motoru için deterministik kullanıcı tohumu üretir.
  ///
  /// V1 girdileri aynen korunur. V2 görünen addan bağımsızdır.
  /// Bu getter rastgele kimlik üretmez veya bozuk profili onarmaz.
  UserSeed get seed {
    if (seedSurumu == 1 && dogumTarihi != null) {
      return UserSeed.fromIsim(isim: isim, dogumTarihi: dogumTarihi!);
    }
    if (seedSurumu == 2 &&
        rituelKimligi != null &&
        rituelKimligi!.trim().isNotEmpty) {
      return UserSeed.fromRituelKimligi(rituelKimligi!);
    }
    throw const FormatException('Profil tohum bilgisi geçersiz.');
  }

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
    _isimAnahtari: isim,
    _dogumTarihiAnahtari: dogumTarihi?.toIso8601String(),
    'rituelKimligi': rituelKimligi,
    'seedSurumu': seedSurumu,
    _onboardingAnahtari: onboardingTamam,
    _bildirimlerAcikAnahtari: bildirimlerAcik,
    _aksamDakikaAnahtari: aksamBildirimDakika,
    _sabahDakikaAnahtari: sabahBildirimDakika,
    _dilAnahtari: dil?.name,
  };

  /// Seçili alanları değiştirilmiş bir kopya döndürür.
  ///
  /// Nullable tercihler açık null ile varsayılana döner. Tohum kimliği
  /// ve v1 doğum tarihi bu yöntemle değiştirilemez; v2 tarihi seed'i etkilemez.
  UserProfile copyWith({
    String? isim,
    bool? onboardingTamam,
    bool? bildirimlerAcik,
    Object? aksamBildirimDakika = _degismedi,
    Object? sabahBildirimDakika = _degismedi,
    Object? dil = _degismedi,
    Object? dogumTarihi = _degismedi,
  }) {
    if (seedSurumu == 1 &&
        !identical(dogumTarihi, _degismedi) &&
        dogumTarihi != this.dogumTarihi) {
      throw ArgumentError('Eski profilin doğum tarihi motor girdisidir.');
    }
    return UserProfile(
      isim: isim ?? this.isim,
      dogumTarihi: identical(dogumTarihi, _degismedi)
          ? this.dogumTarihi
          : dogumTarihi as DateTime?,
      rituelKimligi: rituelKimligi,
      seedSurumu: seedSurumu,
      onboardingTamam: onboardingTamam ?? this.onboardingTamam,
      bildirimlerAcik: bildirimlerAcik ?? this.bildirimlerAcik,
      aksamBildirimDakika: identical(aksamBildirimDakika, _degismedi)
          ? this.aksamBildirimDakika
          : aksamBildirimDakika as int?,
      sabahBildirimDakika: identical(sabahBildirimDakika, _degismedi)
          ? this.sabahBildirimDakika
          : sabahBildirimDakika as int?,
      dil: identical(dil, _degismedi) ? this.dil : dil as AppDil?,
    );
  }
}
