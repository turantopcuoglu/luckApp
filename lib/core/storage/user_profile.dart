import '../luck_engine/luck_engine.dart';

/// Kullanıcı profili: isim, doğum tarihi ve onboarding durumu.
///
/// user_profile kutusunda tek bir map kaydı olarak saklanır
/// (plan Session 2, madde 1).
class UserProfile {
  /// Tüm alanlarıyla profil oluşturur.
  const UserProfile({
    required this.isim,
    required this.dogumTarihi,
    this.onboardingTamam = false,
  });

  /// Hive'dan okunan map'ten profil kurar.
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      isim: map[_isimAnahtari] as String,
      dogumTarihi: DateTime.parse(map[_dogumTarihiAnahtari] as String),
      onboardingTamam: map[_onboardingAnahtari] as bool,
    );
  }

  static const String _isimAnahtari = 'isim';
  static const String _dogumTarihiAnahtari = 'dogumTarihi';
  static const String _onboardingAnahtari = 'onboardingTamam';

  /// Kullanıcının girdiği görünen isim (selamlama için).
  final String isim;

  /// Kullanıcının doğum tarihi.
  final DateTime dogumTarihi;

  /// Onboarding akışı tamamlandı mı?
  final bool onboardingTamam;

  /// Şans motoru için deterministik kullanıcı tohumu üretir.
  UserSeed get seed => UserSeed.fromIsim(isim: isim, dogumTarihi: dogumTarihi);

  /// Hive'a yazılacak map gösterimi.
  Map<String, dynamic> toMap() => <String, dynamic>{
        _isimAnahtari: isim,
        _dogumTarihiAnahtari: dogumTarihi.toIso8601String(),
        _onboardingAnahtari: onboardingTamam,
      };

  /// Seçili alanları değiştirilmiş bir kopya döndürür.
  UserProfile copyWith({String? isim, bool? onboardingTamam}) => UserProfile(
        isim: isim ?? this.isim,
        dogumTarihi: dogumTarihi,
        onboardingTamam: onboardingTamam ?? this.onboardingTamam,
      );
}
