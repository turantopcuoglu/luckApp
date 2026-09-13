import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/core/theme/cosmic_config.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/feedback/notification_service.dart';
import 'package:kader/features/onboarding/calculating_screen.dart';
import 'package:kader/features/onboarding/onboarding_strings.dart';
import 'package:kader/features/onboarding/profile_form_screen.dart';
import 'package:kader/features/onboarding/welcome_screen.dart';
import 'package:kader/features/settings/settings_strings.dart';
import 'package:kader/features/shell/app_shell.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  late _TestUserRepository profilRepo;
  late _Notifications notifications;
  int testSayaci = 0;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('onboarding_test');
    Hive.init(geciciDizin.path);
    // UI profil adapter'ı bellekte çalışır; günlük Hive fixture yazımı
    // runAsync içinde beklenir. Test kutuları kapanışta temizlenebilir.
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'onb_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'onb_kayit_$testSayaci',
    );
    profilRepo = _TestUserRepository(profilKutusu);
    notifications = _Notifications();
  });

  tearDown(() async {
    await profilKutusu.deleteFromDisk();
    await kayitKutusu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  Future<void> akisiBaslat(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          cosmicMotionEnabledProvider.overrideWithValue(false),
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          userRepositoryProvider.overrideWithValue(profilRepo),
          notificationServiceProvider.overrideWithValue(notifications),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          bugunProvider.overrideWithValue(DateTime(2026, 7, 6)),
        ],
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('karşılama: slogan ve Başla butonu görünür', (
    WidgetTester tester,
  ) async {
    await akisiBaslat(tester);

    expect(find.text(OnboardingStrings.slogan(AppDil.tr)), findsOneWidget);
    expect(find.text(OnboardingStrings.basla(AppDil.tr)), findsOneWidget);
    // Yasal uyum ibaresi karşılama ekranında görünür (store zorunlu).
    expect(find.text(SettingsStrings.eglenceAmacli(AppDil.tr)), findsOneWidget);
  });

  testWidgets('Başla forma götürür; boş isim uyarı verir, geçirmez', (
    WidgetTester tester,
  ) async {
    await akisiBaslat(tester);

    await tester.tap(find.text(OnboardingStrings.basla(AppDil.tr)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProfileFormScreen), findsOneWidget);

    // Boş isimde alan altında hata gösterilir, ekran değişmez.
    await tester.ensureVisible(
      find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
    );
    await tester.tap(find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)));
    await tester.pump();
    expect(
      find.text(OnboardingStrings.isimBosUyarisi(AppDil.tr)),
      findsOneWidget,
    );
    expect(find.byType(ProfileFormScreen), findsOneWidget);
  });

  testWidgets('geri dönüp yeniden açınca taslak korunur, diske yazılmaz', (
    WidgetTester tester,
  ) async {
    await akisiBaslat(tester);
    await tester.tap(find.text(OnboardingStrings.basla(AppDil.tr)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Yarım rumuz');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(profilRepo.profil(), isNull);
    await tester.tap(find.text(OnboardingStrings.basla(AppDil.tr)));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Yarım rumuz',
    );
    expect(notifications.permissions, 0);
  });

  testWidgets(
    'tam akış: isim gir → hesaplama ekranı → profil kayıtlı → ana ekran',
    (WidgetTester tester) async {
      await akisiBaslat(tester);

      // Adım 1 → 2
      await tester.tap(find.text(OnboardingStrings.basla(AppDil.tr)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Adım 2: isim yaz, devam et.
      await tester.enterText(find.byType(TextField), 'Turan');
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('birth-date-button')),
      );
      await tester.tap(find.byKey(const ValueKey<String>('birth-date-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(OnboardingStrings.confirmDate(AppDil.tr)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
      );
      await tester.ensureVisible(
        find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
      );
      await tester.tap(find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Adım 3: hazırlama ekranı; test repository'sinde profil kayıtlı,
      // fakat onboarding henüz tamamlanmamıştır.
      expect(find.byType(CalculatingScreen), findsOneWidget);
      expect(
        find.text(OnboardingStrings.hesaplaniyor(AppDil.tr)),
        findsOneWidget,
      );
      final UserRepository repo = profilRepo;
      final UserProfile? kayitli = repo.profil();
      expect(kayitli, isNotNull);
      expect(kayitli!.isim, 'Turan');
      expect(kayitli.onboardingTamam, isFalse);
      expect(kayitli.seedSurumu, 2);
      expect(kayitli.dogumTarihi, DateTime(2000, 1, 1));
      expect(kayitli.bildirimlerAcik, isFalse);

      // Bugünün kaydı önceden tohumlanır: ana ekran açıldığında
      // getirVeyaUret senkron okuma yoluna girsin, diske yazmasın.
      await tester.runAsync(() async {
        final LuckResult sonuc = const LuckEngine().hesapla(
          kullanici: kayitli.seed,
          gun: DateTime(2026, 7, 6),
        );
        await LuckHistoryRepository(
          kayitKutusu,
        ).kaydet(DailyRecord(sonuc: sonuc));
      });

      // Hazırlama ve kayıt tamamlanınca ana ekran açılır, bayrak true olur.
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DailyLuckScreen), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
      expect(repo.onboardingTamamlandiMi, isTrue);
      expect(notifications.permissions, 0);
      expect(notifications.schedules, 0);

      // Geri tuşu ana ekrandan onboarding'e dönememeli (yığın temiz).
      final NavigatorState gezgin = tester.state(find.byType(Navigator));
      expect(gezgin.canPop(), isFalse);
    },
  );

  testWidgets(
    'profil yazımı çift dokunmayı ve geri dönüşü engeller; hata tekrar denenebilir',
    (WidgetTester tester) async {
      await akisiBaslat(tester);
      await tester.tap(find.text(OnboardingStrings.basla(AppDil.tr)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Ada');
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('birth-date-button')),
      );
      await tester.tap(find.byKey(const ValueKey<String>('birth-date-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(OnboardingStrings.confirmDate(AppDil.tr)));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
      );
      profilRepo.pending = Completer<void>();
      await tester.ensureVisible(
        find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
      );
      await tester.tap(find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)));
      await tester.ensureVisible(
        find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)),
      );
      await tester.tap(find.text(OnboardingStrings.kaderimiHesapla(AppDil.tr)));
      await tester.pump();
      expect(profilRepo.writes, 1);
      expect(find.byType(CalculatingScreen), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byType(ProfileFormScreen), findsOneWidget);
      profilRepo.pending!.completeError(StateError('disk'));
      await tester.pumpAndSettle();
      expect(
        find.text(OnboardingStrings.profilKayitHatasi(AppDil.tr)),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Ada',
      );
      profilRepo.pending = null;
      await tester.ensureVisible(
        find.text(OnboardingStrings.tekrarDene(AppDil.tr)),
      );
      await tester.tap(find.text(OnboardingStrings.tekrarDene(AppDil.tr)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CalculatingScreen), findsOneWidget);
      expect(profilRepo.writes, 2);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}

// UI akışında disk yerine deterministik tamamlanan kayıt kullanılır.
// Gerçek Hive kalıcılığı storage/schema_v2_test.dart ile ayrıca doğrulanır.
class _TestUserRepository extends UserRepository {
  _TestUserRepository(super.box);
  UserProfile? _profile;
  Completer<void>? pending;
  int writes = 0;

  @override
  UserProfile? profil() => _profile;

  @override
  Future<void> kaydet(UserProfile profil) async {
    writes++;
    if (pending != null) await pending!.future;
    _profile = profil;
  }
}

class _Notifications extends NotificationService {
  int permissions = 0;
  int schedules = 0;
  @override
  Future<bool> izinIste() async {
    permissions++;
    return true;
  }

  @override
  Future<void> gunlukBildirimleriPlanla({
    required DateTime simdi,
    required AppDil dil,
    int? aksamDakika,
    int? sabahDakika,
    int? sansliSaatBaslangiciSaati,
  }) async {
    schedules++;
  }
}
