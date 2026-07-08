import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunun_icerigi.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import 'tr_strings.dart';

/// Bugünün tarihini sağlar.
///
/// Testlerde sabit bir güne override edilir; üretimde cihaz saatidir.
final Provider<DateTime> bugunProvider =
    Provider<DateTime>((Ref ref) => DateTime.now());

/// Aktif kullanıcı profili.
///
/// Onboarding (Session 6) tamamlanana kadar kayıtlı profil yoksa
/// misafir profiline düşer; böylece ekran her koşulda çalışır.
final Provider<UserProfile> aktifProfilProvider = Provider<UserProfile>(
  (Ref ref) =>
      ref.watch(userRepositoryProvider).profil() ??
      UserProfile(
        isim: TrStrings.misafirIsmi,
        // Misafir için sabit doğum tarihi: deterministik skor üretimi
        // isteyen kural 8 gereği rastgele bir değer KULLANILAMAZ.
        dogumTarihi: DateTime(2000),
      ),
);

/// Bugünün şans sonucu.
///
/// Kayıt varsa depodan okur, yoksa motorla üretip saklar; aynı gün
/// içinde motor ikinci kez çalıştırılmaz (Session 2 garantisi).
final FutureProvider<LuckResult> gununSansiProvider =
    FutureProvider<LuckResult>((Ref ref) {
  return ref.watch(luckHistoryRepositoryProvider).getirVeyaUret(
        motor: ref.watch(luckEngineProvider),
        kullanici: ref.watch(aktifProfilProvider).seed,
        gun: ref.watch(bugunProvider),
      );
});

/// Bugünün zenginleştirilmiş içeriği: yorum, şans rengi, şanslı sayı
/// ve günün tavsiyesi.
///
/// Persist edilmez; saklanan [LuckResult] + deterministik içerik
/// tohumundan her açılışta aynı şekilde yeniden türetilir (kural 8).
final FutureProvider<GununIcerigi> gununIcerigiProvider =
    FutureProvider<GununIcerigi>((Ref ref) async {
  final LuckResult sonuc = await ref.watch(gununSansiProvider.future);
  return gununIcerigi(
    motor: ref.watch(luckEngineProvider),
    kullanici: ref.watch(aktifProfilProvider).seed,
    sonuc: sonuc,
  );
});
