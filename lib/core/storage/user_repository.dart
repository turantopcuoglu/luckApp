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

  /// Eski sürümlerin profil kaydına yazdığı tanışma cevaplarını siler
  /// (K7; KARARLAR 2026-11-26, soru 4).
  ///
  /// Yalnız [StorageKeys.eskiTanismaCevaplari] anahtarları çıkarılır;
  /// kayıttaki diğer alanlara dokunulmaz. Kayıtta bu anahtarlar yoksa hiç
  /// yazmaz, bu yüzden açılışta her seferinde çağrılabilir: silme işi
  /// fiilen bir kez olur. Bir şey sildiyse `true` döner.
  Future<bool> eskiTanismaCevaplariniSil() async {
    final Map<dynamic, dynamic>? map = _box.get(StorageKeys.profilKaydi);
    if (map == null ||
        !StorageKeys.eskiTanismaCevaplari.any(map.containsKey)) {
      return false;
    }
    final Map<dynamic, dynamic> temiz = Map<dynamic, dynamic>.of(map)
      ..removeWhere(
        (dynamic anahtar, dynamic _) =>
            StorageKeys.eskiTanismaCevaplari.contains(anahtar),
      );
    await _box.put(StorageKeys.profilKaydi, temiz);
    return true;
  }

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
  /// Kabul edilen uyarı/koşullar sürümünü profile işler.
  ///
  /// Profil yoksa [StateError] fırlatır.
  Future<void> uyariKabulEt(int surum) {
    final UserProfile? mevcut = profil();
    if (mevcut == null) {
      throw StateError('Uyarı kabulü kaydedilemez: kayıtlı profil yok.');
    }
    return kaydet(mevcut.copyWith(uyariKabulSurumu: surum));
  }
}
