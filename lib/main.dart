import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/storage/app_storage.dart';
import 'core/storage/providers.dart';
import 'core/storage/user_profile.dart';
import 'core/storage/user_repository.dart';
import 'core/storage/uygulama_durumu.dart';
import 'core/theme/app_theme.dart';
import 'features/ads/ads_providers.dart';
import 'features/ads/reklam_servisi.dart';
import 'features/feedback/feedback_screen.dart';
import 'features/feedback/notification_service.dart';
import 'features/home/ana_kabuk.dart';
import 'features/legal/legal_config.dart';
import 'features/legal/uyari_screen.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/premium/magaza_servisi.dart';
import 'features/premium/premium_kontrolcu.dart';
import 'l10n/app_localizations.dart';
import 'l10n/dil_providers.dart';
import 'shared/widgets/app_route.dart';

/// Kök gezgin anahtarı: bildirim dokunuşları context olmadan
/// feedback ekranını açabilsin diye globaldir.
final GlobalKey<NavigatorState> anaGezginAnahtari =
    GlobalKey<NavigatorState>();

/// Kök mesajcı anahtarı: ekranlar arası geçişlerde SnackBar
/// gösterebilmek için (örn. bildirim izni reddi mesajı).
final GlobalKey<ScaffoldMessengerState> anaMesajciAnahtari =
    GlobalKey<ScaffoldMessengerState>();

/// Akşam bildirimine dokunulunca feedback ekranını açar.
void _feedbackEkraniniAc() {
  anaGezginAnahtari.currentState?.push(
    fadeThroughRoute<void>(const FeedbackScreen()),
  );
}

/// Reklam ve satın alma eklentilerinin çalıştığı platform mu?
bool get _mobilPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive kutuları açılır ve provider'lara override ile bağlanır;
  // kutu provider'ları bilerek override'sız çalışmaz (bkz. providers.dart).
  await AppStorage.baslat();
  final UygulamaDurumuRepository durum =
      UygulamaDurumuRepository(AppStorage.appStateBox);
  await durum.ilkAcilisiIsaretle(DateTime.now());

  // Bildirim altyapısı: uygulama bir akşam bildirimiyle mi açıldı?
  final NotificationService bildirimler = NotificationService();
  final bool bildirimdenAcildi =
      await bildirimler.baslat(bildirimeDokunuldu: _feedbackEkraniniAc);

  final ReklamServisi reklamlar =
      _mobilPlatform ? AdMobReklamServisi() : const BosReklamServisi();
  final MagazaServisi magaza =
      _mobilPlatform ? PlayMagazaServisi() : const BosMagazaServisi();

  // Açılış sonrası asenkron servisler (reklam hazır durumu, premium
  // doğrulaması) provider'ları güncelleyebilsin diye kapsayıcı elde tutulur.
  final ProviderContainer kapsayici = ProviderContainer(
    overrides: <Override>[
      userProfileBoxProvider.overrideWithValue(AppStorage.userProfileBox),
      dailyRecordsBoxProvider.overrideWithValue(AppStorage.dailyRecordsBox),
      appStateBoxProvider.overrideWithValue(AppStorage.appStateBox),
      kisilerBoxProvider.overrideWithValue(AppStorage.kisilerBox),
      notificationServiceProvider.overrideWithValue(bildirimler),
      reklamServisiProvider.overrideWithValue(reklamlar),
      magazaServisiProvider.overrideWithValue(magaza),
    ],
  );

  // Onboarding bitmişse bildirim penceresi her açılışta tazelenir
  // (sabah metin varyasyonları 14 gün ileriye planlanır). Metinler
  // uygulama dilindedir; dil değiştiyse bu açılışta yeni dile geçer.
  final UserRepository kullanicilar =
      UserRepository(AppStorage.userProfileBox);
  if (kullanicilar.onboardingTamamlandiMi) {
    unawaited(
      bildirimler.gunlukBildirimleriPlanla(
        simdi: DateTime.now(),
        metinler: kapsayici.read(arayuzMetinleriProvider),
      ),
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: kapsayici,
      child: const KaderApp(),
    ),
  );

  // Premium: Google Play'den satın alımları geri yükle, planları getir.
  unawaited(kapsayici.read(premiumKontrolcuProvider.notifier).baslat());

  // Reklam: rıza akışı (gerekirse form) → SDK başlatma → hazır durumu.
  unawaited(() async {
    await reklamlar.baslat();
    kapsayici.read(reklamHazirProvider.notifier).state = reklamlar.hazir;
  }());

  // Uygulama kapalıyken bildirime dokunularak açıldıysa ilk kareden
  // sonra feedback ekranına gidilir.
  if (bildirimdenAcildi) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _feedbackEkraniniAc(),
    );
  }
}

/// Uygulamanın kök widget'ı: temayı ve dili bağlar, açılış ekranını seçer.
///
/// Dil [uygulamaDiliProvider]'dan gelir (Ayarlar'da değişince uygulama
/// yeniden çizilir); Material/Cupertino bileşenleri de aynı dile geçer.
///
/// - Onboarding tamamlanmadıysa: karşılama.
/// - Kullanıcı güncel uyarı/koşullar sürümünü onaylamadıysa (ör. eski
///   sürümden gelen kullanıcı): uyarı kapısı.
/// - Aksi halde: dört sekmeli ana kabuk.
class KaderApp extends ConsumerWidget {
  /// Varsayılan kurucu.
  const KaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserProfile? profil = ref.read(userRepositoryProvider).profil();
    final bool onboardingTamam = profil?.onboardingTamam ?? false;
    final bool uyariGuncel =
        (profil?.uyariKabulSurumu ?? 0) >= LegalConfig.uyariSurumu;

    final Widget acilis;
    if (!onboardingTamam) {
      acilis = const WelcomeScreen();
    } else if (!uyariGuncel) {
      acilis = UyariScreen(
        onKabul: (BuildContext c, WidgetRef r) async {
          await r.read(userRepositoryProvider).uyariKabulEt(
                LegalConfig.uyariSurumu,
              );
          if (c.mounted) {
            await Navigator.of(c).pushReplacement(
              fadeThroughRoute<void>(const AnaKabuk()),
            );
          }
        },
      );
    } else {
      acilis = const AnaKabuk();
    }

    return MaterialApp(
      title: 'Kader',
      debugShowCheckedModeBanner: false,
      locale: dilLocale(ref.watch(uygulamaDiliProvider)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      navigatorKey: anaGezginAnahtari,
      scaffoldMessengerKey: anaMesajciAnahtari,
      home: acilis,
    );
  }
}
