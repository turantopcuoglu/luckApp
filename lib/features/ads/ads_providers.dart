import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_config.dart';
import 'reklam_servisi.dart';

/// Reklam servisi. Üretimde `main` içinde [AdMobReklamServisi] ile
/// override edilir; override edilmezse reklamsız [BosReklamServisi].
final Provider<ReklamServisi> reklamServisiProvider =
    Provider<ReklamServisi>((Ref ref) => const BosReklamServisi());

/// Reklam SDK'sı rıza akışından sonra hazır oldu mu?
///
/// Başlatma asenkron olduğu için `main` başlatma bitince bu durumu
/// günceller; banner alanları buna göre kendini gösterir.
final StateProvider<bool> reklamHazirProvider =
    StateProvider<bool>((Ref ref) => false);

/// Geçiş (interstitial) reklamı şimdi gösterilebilir mi?
///
/// Saf fonksiyon: kullanıcı premium değilse, kurulumdan beri en az
/// [AdsConfig.gecisIcinEnAzGun] gün geçmişse ve son gösterimden bu yana
/// [AdsConfig.gecisReklamiAraligi] dolmuşsa true.
bool gecisReklamiGosterilebilir({
  required DateTime simdi,
  required bool premium,
  required DateTime? ilkAcilis,
  required DateTime? sonGosterim,
}) {
  if (premium || ilkAcilis == null) {
    return false;
  }
  if (simdi.difference(ilkAcilis).inDays < AdsConfig.gecisIcinEnAzGun) {
    return false;
  }
  return sonGosterim == null ||
      simdi.difference(sonGosterim) >= AdsConfig.gecisReklamiAraligi;
}
