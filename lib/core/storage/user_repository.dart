import 'package:hive/hive.dart';

import 'storage_keys.dart';
import 'user_profile.dart';

/// Kullanıcı profili üzerinde okuma/yazma işlemleri.
///
/// user_profile kutusunu sarmalar; UI katmanı kutuya doğrudan dokunmaz.
class UserRepository {
  /// Açık bir user_profile kutusuyla repository oluşturur.
  const UserRepository(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  /// Kayıtlı profili döndürür; onboarding yapılmadıysa null.
  UserProfile? profil() {
    final Map<dynamic, dynamic>? map = _box.get(StorageKeys.profilKaydi);
    return map == null ? null : UserProfile.fromMap(map);
  }

  /// Profili kaydeder (mevcutsa üzerine yazar).
  Future<void> kaydet(UserProfile profil) =>
      _box.put(StorageKeys.profilKaydi, profil.toMap());

  /// Onboarding akışı tamamlanmış mı?
  bool get onboardingTamamlandiMi => profil()?.onboardingTamam ?? false;

  /// Mevcut profili onboarding tamamlandı olarak işaretler.
  ///
  /// Profil yoksa [StateError] fırlatır: akış gereği önce isim ve doğum
  /// tarihi kaydedilmiş olmalıdır.
  Future<void> onboardingTamamla() {
    final UserProfile? mevcut = profil();
    if (mevcut == null) {
      throw StateError('Onboarding tamamlanamaz: kayıtlı profil yok.');
    }
    return kaydet(mevcut.copyWith(onboardingTamam: true));
  }
}
