import 'package:hive/hive.dart';

import 'storage_keys.dart';
import 'user_profile.dart';
import 'user_profile_factory.dart';

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

  /// Kayıt yoksa bir v2 kimliği oluşturup kalıcılaştırır; mevcut profilin
  /// sürümünü veya kimliğini değiştirmez. Hive put belleği ilk await'ten
  /// önce günceller; art arda çağrılar aynı profili kullanır.
  Future<UserProfile> profilOlustur({
    required String isim,
    required UserProfileFactory factory,
  }) async {
    final UserProfile? mevcut = profil();
    if (mevcut != null) return mevcut;
    final UserProfile yeni = factory.olustur(isim: isim);
    await kaydet(yeni);
    return yeni;
  }

  /// Onboarding akışı tamamlanmış mı?
  bool get onboardingTamamlandiMi => profil()?.onboardingTamam ?? false;

  /// Mevcut profili onboarding tamamlandı olarak işaretler.
  ///
  /// Profil yoksa [StateError] fırlatır: akış gereği önce kalıcı profil
  /// ve tohum kimliği kaydedilmiş olmalıdır.
  Future<void> onboardingTamamla() {
    final UserProfile? mevcut = profil();
    if (mevcut == null) {
      throw StateError('Onboarding tamamlanamaz: kayıtlı profil yok.');
    }
    return kaydet(mevcut.copyWith(onboardingTamam: true));
  }
}
