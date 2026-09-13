import 'dart:math';

import 'user_profile.dart';

/// V2 profillerin tek seferlik kimliği; isteğe bağlı tarih seed'i etkilemez.
class UserProfileFactory {
  /// Testler deterministik bir [kimlikUret] işlevi sağlayabilir.
  const UserProfileFactory({String Function()? kimlikUret})
    : _kimlikUret = kimlikUret ?? _guvenliKimlik;

  static const int _kimlikBaytSayisi = 32;
  static const int _baytDegerSayisi = 256;
  final String Function() _kimlikUret;

  static String _guvenliKimlik() {
    final Random random = Random.secure();
    return List<String>.generate(
      _kimlikBaytSayisi,
      (_) => random.nextInt(_baytDegerSayisi).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  /// Henüz saklanmamış profil üretir; kalıcılık repository'nin görevidir.
  /// Yeni kullanıcı bildirim iznine kendisi karar verir.
  UserProfile olustur({required String isim, DateTime? dogumTarihi}) {
    final String kimlik = _kimlikUret();
    if (kimlik.trim().isEmpty) {
      throw const FormatException('Ritüel kimliği boş olamaz.');
    }
    return UserProfile(
      isim: isim,
      dogumTarihi: dogumTarihi,
      rituelKimligi: kimlik,
      seedSurumu: 2,
      bildirimlerAcik: false,
    );
  }
}
