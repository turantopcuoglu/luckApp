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
    required this.dogumTarihi,
    this.onboardingTamam = false,
    this.bildirimlerAcik = true,
    this.aksamBildirimDakika,
    this.sabahBildirimDakika,
  });

  /// Hive'dan okunan map'ten profil kurar.
  ///
  /// Bildirim alanları geriye uyumlu okunur: eski kayıtlar bu
  /// anahtarları içermez, o yüzden `?? varsayılan` uygulanır.
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      isim: map[_isimAnahtari] as String,
      dogumTarihi: DateTime.parse(map[_dogumTarihiAnahtari] as String),
      onboardingTamam: map[_onboardingAnahtari] as bool,
      bildirimlerAcik: map[_bildirimlerAcikAnahtari] as bool? ?? true,
      aksamBildirimDakika: map[_aksamDakikaAnahtari] as int?,
      sabahBildirimDakika: map[_sabahDakikaAnahtari] as int?,
    );
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';
  static const String _bildirimlerAcikAnahtari = 'bildirimlerAcik';
  static const String _aksamDakikaAnahtari = 'aksamBildirimDakika';
  static const String _sabahDakikaAnahtari = 'sabahBildirimDakika';

  /// Kullanıcının girdiği görünen isim (selamlama için).
  final String isim;

  /// Kullanıcının doğum tarihi.
  final DateTime dogumTarihi;

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

  /// Şans motoru için deterministik kullanıcı tohumu üretir.
  ///
  /// Yalnızca [isim] ve [dogumTarihi]'ne bağlıdır — bildirim
  /// tercihleri sonucu ETKİLEMEZ (kural 8).
  UserSeed get seed => UserSeed.fromIsim(isim: isim, dogumTarihi: dogumTarihi);

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _isimAnahtari: isim,
        _dogumTarihiAnahtari: dogumTarihi.toIso8601String(),
        _onboardingAnahtari: onboardingTamam,
        _bildirimlerAcikAnahtari: bildirimlerAcik,
        _aksamDakikaAnahtari: aksamBildirimDakika,
        _sabahDakikaAnahtari: sabahBildirimDakika,
      };

  /// Seçili alanları değiştirilmiş bir kopya döndürür.
  ///
  /// Not: [aksamBildirimDakika]/[sabahBildirimDakika] için `??`
  /// deseni bir değeri `null`'a geri döndüremez; Phase 1'de saat
  /// seçici her zaman somut değer verdiği için bu kabul edilebilir.
  UserProfile copyWith({
    String? isim,
    bool? onboardingTamam,
    bool? bildirimlerAcik,
    int? aksamBildirimDakika,
    int? sabahBildirimDakika,
  }) =>
      UserProfile(
        isim: isim ?? this.isim,
        dogumTarihi: dogumTarihi,
        onboardingTamam: onboardingTamam ?? this.onboardingTamam,
        bildirimlerAcik: bildirimlerAcik ?? this.bildirimlerAcik,
        aksamBildirimDakika: aksamBildirimDakika ?? this.aksamBildirimDakika,
        sabahBildirimDakika: sabahBildirimDakika ?? this.sabahBildirimDakika,
      );
}
