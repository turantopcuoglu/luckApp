import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/content/fortune_composer.dart';
import 'core/content/gunun_icerigi.dart';
import 'core/luck_engine/luck_engine.dart';
import 'core/storage/app_storage.dart';
import 'core/storage/luck_history_repository.dart';
import 'core/storage/providers.dart';
import 'core/storage/user_profile.dart';
import 'core/storage/user_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_luck/daily_luck_screen.dart';
import 'features/feedback/feedback_screen.dart';
import 'features/feedback/notification_service.dart';
import 'features/home_widget/home_widget_service.dart';
import 'features/home_widget/widget_payload.dart';
import 'features/onboarding/welcome_screen.dart';
import 'shared/widgets/app_route.dart';

/// Kök gezgin anahtarı: bildirim dokunuşları context olmadan
/// feedback ekranını açabilsin diye globaldir.
final GlobalKey<NavigatorState> anaGezginAnahtari = GlobalKey<NavigatorState>();

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive kutuları açılır ve provider'lara override ile bağlanır;
  // kutu provider'ları bilerek override'sız çalışmaz (bkz. providers.dart).
  await AppStorage.baslat();

  // Bildirim altyapısı: uygulama bir akşam bildirimiyle mi açıldı?
  final NotificationService bildirimler = NotificationService();
  final bool bildirimdenAcildi = await bildirimler.baslat(
    bildirimeDokunuldu: _feedbackEkraniniAc,
  );

  // Onboarding bitmiş VE kullanıcı bildirimleri açık bırakmışsa
  // bildirim penceresi her açılışta tazelenir (sabah metin
  // varyasyonları 14 gün ileriye planlanır). Kullanıcı Ayarlar'dan
  // kapatmışsa hiçbir şey planlanmaz (kapatma anında iptal edilmişti).
  final UserRepository kullanicilar = UserRepository(AppStorage.userProfileBox);
  final UserProfile? profil = kullanicilar.profil();
  if (profil != null && profil.onboardingTamam) {
    const LuckEngine motor = LuckEngine();

    // Bugünün sonucunu üret/oku (kaydı erken üretmek streak'e de yarar).
    // Hesaplanamazsa (herhangi bir hata) açılış asla bloklanmaz/çökmez.
    LuckResult? sonuc;
    try {
      sonuc = await LuckHistoryRepository(AppStorage.dailyRecordsBox)
          .getirVeyaUret(
            motor: motor,
            kullanici: profil.seed,
            gun: DateTime.now(),
          );
      // ignore: avoid_catches_without_on_clauses - açılış opsiyonel
      // özellikler yüzünden bloklanmamalı.
    } catch (_) {
      sonuc = null;
    }

    // Ana ekran widget'ı: bildirim tercihinden BAĞIMSIZ, her açılışta
    // bugünün skoruyla güncellenir (widget yoksa/başarısızsa yutulur).
    if (sonuc != null) {
      try {
        final GununIcerigi icerik = gununIcerigi(
          motor: motor,
          kullanici: profil.seed,
          sonuc: sonuc,
        );
        unawaited(
          HomeWidgetService().yaz(
            widgetYuku(
              skor: sonuc.genelSkor,
              gun: sonuc.gun,
              yorum: icerik.yorum,
            ),
          ),
        );
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        // Widget güncellemesi opsiyoneldir.
      }
    }

    // Bildirimler yalnız kullanıcı açık bıraktıysa planlanır.
    if (profil.bildirimlerAcik) {
      // Şanslı saat hesabı OPSİYONEL: hesaplanamazsa null geçilir,
      // bildirimler yine planlanır.
      int? sansliSaat;
      try {
        sansliSaat = sonuc == null
            ? null
            : gununSansliSaatBaslangici(
                motor: motor,
                kullanici: profil.seed,
                sonuc: sonuc,
              );
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        sansliSaat = null;
      }
      unawaited(
        bildirimler.gunlukBildirimleriPlanla(
          simdi: DateTime.now(),
          aksamDakika: profil.aksamBildirimDakika,
          sabahDakika: profil.sabahBildirimDakika,
          sansliSaatBaslangiciSaati: sansliSaat,
        ),
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: <Override>[
        userProfileBoxProvider.overrideWithValue(AppStorage.userProfileBox),
        dailyRecordsBoxProvider.overrideWithValue(AppStorage.dailyRecordsBox),
        notificationServiceProvider.overrideWithValue(bildirimler),
      ],
      child: const KaderApp(),
    ),
  );

  // Uygulama kapalıyken bildirime dokunularak açıldıysa ilk kareden
  // sonra feedback ekranına gidilir.
  if (bildirimdenAcildi) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _feedbackEkraniniAc());
  }
}

/// Uygulamanın kök widget'ı: temayı bağlar ve açılış ekranını seçer.
///
/// Onboarding tamamlanmışsa doğrudan ana ekran, değilse karşılama
/// açılır (onboarding bir kez gösterilir — Session 6).
class KaderApp extends ConsumerWidget {
  /// Varsayılan kurucu.
  const KaderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool onboardingTamam = ref
        .watch(userRepositoryProvider)
        .onboardingTamamlandiMi;
    return MaterialApp(
      title: 'Kader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      navigatorKey: anaGezginAnahtari,
      scaffoldMessengerKey: anaMesajciAnahtari,
      // Uygulama Türkçe: cihaz dilinden bağımsız Türkçe Material
      // bileşenleri (showTimePicker, tarih/saat diyalogları) sağlar.
      locale: const Locale('tr'),
      supportedLocales: const <Locale>[Locale('tr'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingTamam ? const DailyLuckScreen() : const WelcomeScreen(),
    );
  }
}
