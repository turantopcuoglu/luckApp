import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/fortune_composer.dart';
import '../../core/content/gunun_icerigi.dart';
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import 'tr_strings.dart';

/// Bugünün tarihini sağlar.
///
/// Testlerde sabit bir güne override edilir; üretimde cihaz saatidir.
final Provider<DateTime> bugunProvider = Provider<DateTime>(
  (Ref ref) => DateTime.now(),
);

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

/// Cihazın türetilmiş uygulama dili (kullanıcı açık tercih yapmadıysa).
///
/// Varsayılan [AppDil.tr]'dir; böylece testler (override etmedikçe)
/// Türkçe çözer. Üretimde `main.dart` cihaz diliyle override eder
/// (`AppDil.cihazdan(PlatformDispatcher.instance.locale.languageCode)`).
final Provider<AppDil> cihazDiliProvider = Provider<AppDil>(
  (Ref ref) => AppDil.tr,
);

/// Aktif uygulama dili.
///
/// Kullanıcının açık tercihi (`profil.dil`) varsa o; yoksa cihaz dili.
/// Ayarlar'da dil değişip profil kaydedilince `aktifProfilProvider`
/// invalidate edildiğinden bu da tazelenir → tüm ağaç yeniden kurulur.
final Provider<AppDil> dilProvider = Provider<AppDil>(
  (Ref ref) =>
      ref.watch(aktifProfilProvider).dil ?? ref.watch(cihazDiliProvider),
);

/// Bugünün şans sonucu.
///
/// Kayıt varsa depodan okur, yoksa motorla üretip saklar; aynı gün
/// içinde motor ikinci kez çalıştırılmaz (Session 2 garantisi).
final FutureProvider<LuckResult> gununSansiProvider =
    FutureProvider<LuckResult>((Ref ref) {
      return ref
          .watch(luckHistoryRepositoryProvider)
          .getirVeyaUret(
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
        dil: ref.watch(dilProvider),
      );
    });

/// Bugünün şanslı saatinin başlangıç saati (0-23).
///
/// Bildirim planlamasında kullanılır; bugünün sonucu üzerinden baskın
/// kategorinin deterministik şanslı saatini verir. Testlerde sabit bir
/// saate override edilebilir (gerçek I/O'ya girmeden).
final FutureProvider<int> gununSansliSaatiProvider = FutureProvider<int>((
  Ref ref,
) async {
  final LuckResult sonuc = await ref.watch(gununSansiProvider.future);
  return gununSansliSaatBaslangici(
    motor: ref.watch(luckEngineProvider),
    kullanici: ref.watch(aktifProfilProvider).seed,
    sonuc: sonuc,
  );
});
