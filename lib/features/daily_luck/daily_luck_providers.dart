import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunluk_okuma.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/daily_record.dart';
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
/// Onboarding tamamlanana kadar kayıtlı profil yoksa misafir profiline
/// düşer; böylece ekran her koşulda çalışır. Profil düzenlendiğinde
/// yazan taraf bu provider'ı invalidate eder.
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

/// Bugünün kişiye özel, bölümlü okuması.
///
/// Persist edilmez; saklanan [LuckResult] + sabit profil + ÖNCEKİ
/// günlerin bölüm geri bildirimlerinden her açılışta aynı şekilde
/// yeniden türetilir (kural 8). Bugün verilen geri bildirim bugünün
/// metnini değiştirmez.
final FutureProvider<GunlukOkuma> gunlukOkumaProvider =
    FutureProvider<GunlukOkuma>((Ref ref) async {
  final LuckResult sonuc = await ref.watch(gununSansiProvider.future);
  return gunlukOkuma(
    motor: ref.watch(luckEngineProvider),
    okuyucu: ref.watch(aktifProfilProvider).okuyucu,
    sonuc: sonuc,
    begenilmeyenler: ref
        .watch(luckHistoryRepositoryProvider)
        .begenilmeyenKimlikler(once: ref.watch(bugunProvider)),
  );
});

/// Bugünün kaydı (bölüm cevapları ve akşam geri bildirimi için).
///
/// Yazan taraf invalidate eder; kayıt henüz yoksa null. Günün sonucu
/// üretilip kaydedildiğinde de yeniden okunsun diye onu dinler.
final Provider<DailyRecord?> bugunKaydiProvider = Provider<DailyRecord?>(
  (Ref ref) {
    ref.watch(gununSansiProvider);
    return ref
        .watch(luckHistoryRepositoryProvider)
        .getir(ref.watch(bugunProvider));
  },
);
