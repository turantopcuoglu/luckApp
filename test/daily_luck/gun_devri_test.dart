import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_config.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/daily_luck/widgets/gun_devri_gozcusu.dart';
import 'package:kader/features/daily_luck/widgets/gunun_puani.dart';

import '../test_ortami.dart';

/// Belirli bir andan başlayan gün kontrolcüsü (üretimde cihaz saati).
class _SabitGunDevri extends GunDevri {
  _SabitGunDevri(this.baslangic);

  final DateTime baslangic;

  @override
  DateTime build() => baslangic;
}

/// Gün devri: uygulama kapatılmadan ertesi güne kalırsa yeni günün kartı
/// gösterilir.
void main() {
  final DateTime aksam = DateTime(2026, 7, 6, 22, 30);

  ProviderContainer kapsayici(DateTime baslangic) {
    final ProviderContainer k = ProviderContainer(
      overrides: <Override>[
        gunDevriProvider.overrideWith(() => _SabitGunDevri(baslangic)),
      ],
    );
    addTearDown(k.dispose);
    return k;
  }

  group('GunDevri', () {
    test('aynı gün içinde hiçbir şey değişmez', () {
      final ProviderContainer k = kapsayici(aksam);
      int bildirim = 0;
      k.listen<DateTime>(bugunProvider, (_, _) => bildirim++);

      expect(
        k.read(gunDevriProvider.notifier).tazele(DateTime(2026, 7, 6, 23, 59)),
        isFalse,
      );
      expect(k.read(bugunProvider), aksam);
      expect(bildirim, 0);
    });

    test('ertesi gün bugün ilerler ve izleyenler bir kez haberdar olur', () {
      final ProviderContainer k = kapsayici(aksam);
      int bildirim = 0;
      k.listen<DateTime>(bugunProvider, (_, _) => bildirim++);
      final DateTime sabah = DateTime(2026, 7, 7, 8);

      expect(k.read(gunDevriProvider.notifier).tazele(sabah), isTrue);
      expect(k.read(bugunProvider), sabah);
      expect(bildirim, 1);
    });

    test('ay ve yıl sınırında da gün değişimini görür', () {
      final ProviderContainer k = kapsayici(DateTime(2026, 12, 31, 23));
      // Gün numarası aynı (31 → 31 değil; 1 Ocak) ama ay ve yıl farklı.
      expect(
        k.read(gunDevriProvider.notifier).tazele(DateTime(2027, 1, 1, 0, 1)),
        isTrue,
      );
      // Aynı gün numarası, farklı ay: yine yeni gün.
      expect(
        k.read(gunDevriProvider.notifier).tazele(DateTime(2027, 2, 1)),
        isTrue,
      );
    });

    test('cihaz saati geri alınırsa da o güne geçer', () {
      final ProviderContainer k = kapsayici(aksam);
      final DateTime dun = DateTime(2026, 7, 5, 12);
      expect(k.read(gunDevriProvider.notifier).tazele(dun), isTrue);
      expect(k.read(bugunProvider), dun);
    });
  });

  group('GunDevriGozcusu', () {
    /// Gözcüyü sahte [saat] ile kurar; kapsayıcıyı döndürür.
    Future<ProviderContainer> gozcuyuKur(
      WidgetTester tester,
      DateTime Function() saat,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            gunDevriProvider.overrideWith(() => _SabitGunDevri(saat())),
          ],
          child: GunDevriGozcusu(saat: saat, child: const SizedBox()),
        ),
      );
      final ProviderContainer k = ProviderScope.containerOf(
        tester.element(find.byType(GunDevriGozcusu)),
      );
      // Provider tembel kurulur: başlangıç anı şimdi okunup sabitlenir
      // (uygulamada ilk okuma açılışta, günlük ekran kurulurken olur).
      k
        ..read(bugunProvider)
        ..read(aksamOlduProvider);
      return k;
    }

    /// Uygulamayı arka plana alıp yeniden öne getirir.
    void arkaPlandanDon(WidgetTester tester) {
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }

    testWidgets('aynı gün öne gelince gün değişmez', (
      WidgetTester tester,
    ) async {
      DateTime simdi = aksam;
      final ProviderContainer k = await gozcuyuKur(tester, () => simdi);

      simdi = DateTime(2026, 7, 6, 23, 10);
      arkaPlandanDon(tester);

      expect(k.read(bugunProvider), aksam);
    });

    testWidgets('ertesi sabah öne gelince yeni güne geçer', (
      WidgetTester tester,
    ) async {
      DateTime simdi = aksam;
      final ProviderContainer k = await gozcuyuKur(tester, () => simdi);

      simdi = DateTime(2026, 7, 7, 8, 15);
      arkaPlandanDon(tester);

      expect(k.read(bugunProvider), simdi);
    });

    testWidgets('ekrandayken gece yarısı geçince yeni güne geçer ve ertesi '
        'gece için yeniden kurulur', (WidgetTester tester) async {
      DateTime simdi = DateTime(2026, 7, 6, 23, 59, 30);
      final ProviderContainer k = await gozcuyuKur(tester, () => simdi);
      const Duration geceYarisinaKadar = Duration(seconds: 30);

      // Gece yarısından hemen önce: zamanlayıcı henüz çalışmadı.
      await tester.pump(geceYarisinaKadar - const Duration(seconds: 1));
      expect(k.read(bugunProvider).day, 6);

      // Gece yarısı + pay: gün ilerler.
      simdi = DateTime(2026, 7, 7, 0, 0, 1);
      await tester.pump(
        const Duration(seconds: 1) + DailyLuckConfig.gunDevriPayi,
      );
      expect(k.read(bugunProvider), simdi);

      expect(k.read(aksamOlduProvider), isFalse);

      // Zamanlayıcı kendini sıradaki sınıra kurdu: akşam kartı saati.
      final DateTime geceYarisi = simdi;
      simdi = DateTime(2026, 7, 7, DailyLuckConfig.aksamKartiSaati, 0, 1);
      await tester.pump(simdi.difference(geceYarisi));
      expect(k.read(aksamOlduProvider), isTrue);
      expect(k.read(bugunProvider), geceYarisi);

      // Ardından yine gece yarısı: ertesi güne geçer, akşam sıfırlanır.
      final DateTime aksamAni = simdi;
      simdi = DateTime(2026, 7, 8, 0, 0, 1);
      await tester.pump(simdi.difference(aksamAni));
      expect(k.read(bugunProvider), simdi);
      expect(k.read(aksamOlduProvider), isFalse);
    });

    testWidgets('sabah açılıp akşam öne gelince akşam olur, gün değişmez', (
      WidgetTester tester,
    ) async {
      final DateTime sabah = DateTime(2026, 7, 6, 10);
      DateTime simdi = sabah;
      final ProviderContainer k = await gozcuyuKur(tester, () => simdi);
      expect(k.read(aksamOlduProvider), isFalse);

      simdi = DateTime(2026, 7, 6, 20, 30);
      arkaPlandanDon(tester);

      expect(k.read(aksamOlduProvider), isTrue);
      // "Bugün" aynı kalır: skor ve okuma yeniden yüklenmez.
      expect(k.read(bugunProvider), sabah);
    });

    testWidgets('ekrandayken akşam kartı saati gelince akşam olur', (
      WidgetTester tester,
    ) async {
      DateTime simdi = DateTime(
        2026,
        7,
        6,
        DailyLuckConfig.aksamKartiSaati - 1,
        59,
        30,
      );
      final ProviderContainer k = await gozcuyuKur(tester, () => simdi);

      await tester.pump(const Duration(seconds: 29));
      expect(k.read(aksamOlduProvider), isFalse);

      simdi = DateTime(2026, 7, 6, DailyLuckConfig.aksamKartiSaati, 0, 1);
      await tester.pump(
        const Duration(seconds: 1) + DailyLuckConfig.gunDevriPayi,
      );
      expect(k.read(aksamOlduProvider), isTrue);
    });
  });

  group('AksamDevri', () {
    final DateTime sabah = DateTime(2026, 7, 6, 10);

    test('başlangıçta bugünün saatinden kurulur', () {
      expect(kapsayici(sabah).read(aksamOlduProvider), isFalse);
      expect(
        kapsayici(
          DateTime(2026, 7, 6, DailyLuckConfig.aksamKartiSaati),
        ).read(aksamOlduProvider),
        isTrue,
      );
    });

    test('gün içinde yalnızca akşam saati geçilince değişir', () {
      final ProviderContainer k = kapsayici(sabah);
      int bildirim = 0;
      k.listen<bool>(aksamOlduProvider, (_, _) => bildirim++);
      final AksamDevri aksam = k.read(aksamOlduProvider.notifier);

      aksam.tazele(
        DateTime(2026, 7, 6, DailyLuckConfig.aksamKartiSaati - 1, 59),
      );
      expect(k.read(aksamOlduProvider), isFalse);
      expect(bildirim, 0);

      aksam.tazele(DateTime(2026, 7, 6, DailyLuckConfig.aksamKartiSaati));
      expect(k.read(aksamOlduProvider), isTrue);
      expect(bildirim, 1);

      // Akşam içinde tekrar kontrol: değişiklik yok, bildirim yok.
      aksam.tazele(DateTime(2026, 7, 6, 23));
      expect(bildirim, 1);
    });

    test('başka bir günün saatine dokunmaz; gün ilerleyince yeni günün '
        'saatinden yeniden kurulur', () {
      final ProviderContainer k = kapsayici(sabah);
      k.read(aksamOlduProvider.notifier).tazele(DateTime(2026, 7, 7, 21));
      expect(k.read(aksamOlduProvider), isFalse);

      // Akşam olur, sonra ertesi sabaha geçilir.
      k.read(aksamOlduProvider.notifier).tazele(DateTime(2026, 7, 6, 21));
      expect(k.read(aksamOlduProvider), isTrue);
      k.read(gunDevriProvider.notifier).tazele(DateTime(2026, 7, 7, 8));
      expect(k.read(aksamOlduProvider), isFalse);
    });
  });

  group('günlük ekran', () {
    final TestOrtami ortam = TestOrtami();
    const LuckEngine motor = LuckEngine();
    final DateTime ilkGun = DateTime(2026, 7, 6);
    final DateTime ikinciGun = DateTime(2026, 7, 7);
    final UserProfile ayse = UserProfile(
      isim: 'Ayşe',
      dogumTarihi: DateTime(1994, 3, 14),
      tamAd: 'Ayşe Yılmaz',
      onboardingTamam: true,
    );

    setUp(() async {
      await ortam.kur('gun_devri_test');
      await ortam.profil.put(StorageKeys.profilKaydi, ayse.toMap());
      // İki günün kaydı da tohumlanır: ekran diske yazmadan senkron okusun.
      for (final DateTime g in <DateTime>[ilkGun, ikinciGun]) {
        await ortam.kayit.put(
          gunAnahtari(g),
          DailyRecord(
            sonuc: motor.hesapla(kullanici: ayse.seed, gun: g),
          ).toMap(),
        );
      }
    });

    /// Ekranı [ilkGun]'de (gece yarısı, akşam değil) kurar.
    Future<void> ekraniKur(WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: <Override>[
              userProfileBoxProvider.overrideWithValue(ortam.profil),
              dailyRecordsBoxProvider.overrideWithValue(ortam.kayit),
              appStateBoxProvider.overrideWithValue(ortam.durum),
              kisilerBoxProvider.overrideWithValue(ortam.kisiler),
              gunDevriProvider.overrideWith(() => _SabitGunDevri(ilkGun)),
            ],
            child: testUygulamasi(const DailyLuckScreen()),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }

    /// Kartı açar ve açılış zincirini pompalar.
    Future<void> kartiAc(WidgetTester tester) async {
      await tester.tap(find.byType(FortuneRevealCard));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    ProviderContainer kapsayiciyiBul(WidgetTester tester) =>
        ProviderScope.containerOf(tester.element(find.byType(DailyLuckScreen)));

    testWidgets('akşam olunca akşam kartı belirir, açılmış kart kapanmaz', (
      WidgetTester tester,
    ) async {
      await ekraniKur(tester);
      await kartiAc(tester);
      expect(find.byType(GununPuani), findsOneWidget);
      expect(find.text(trMetinler.gunlukAksamBaslik), findsNothing);

      kapsayiciyiBul(
        tester,
      ).read(aksamOlduProvider.notifier).tazele(DateTime(2026, 7, 6, 19));
      await tester.pump();

      expect(find.text(trMetinler.gunlukAksamBaslik), findsOneWidget);
      // Aynı gün: kart açık kalır, skor yerinde.
      expect(find.byType(GununPuani), findsOneWidget);
      expect(find.text('6 Temmuz 2026, Pazartesi'), findsOneWidget);
    });

    testWidgets('gün değişince açılmış kart kapanır ve yeni günün kartı '
        'gelir', (WidgetTester tester) async {
      await ekraniKur(tester);

      // İlk gün: kart açılır, skor görünür.
      expect(find.text('6 Temmuz 2026, Pazartesi'), findsOneWidget);
      await kartiAc(tester);
      final int ilkSkor = motor
          .hesapla(kullanici: ayse.seed, gun: ilkGun)
          .genelSkor;
      expect(
        find.descendant(
          of: find.byType(GununPuani),
          matching: find.text('$ilkSkor'),
        ),
        findsOneWidget,
      );

      // Gece yarısı geçti: gün ilerler.
      final ProviderContainer k = kapsayiciyiBul(tester);
      await tester.runAsync(() async {
        k.read(gunDevriProvider.notifier).tazele(ikinciGun);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // İkinci gün: tarih yeni, kart yeniden kapalı, dünün skoru yok.
      expect(find.text('7 Temmuz 2026, Salı'), findsOneWidget);
      expect(find.text('6 Temmuz 2026, Pazartesi'), findsNothing);
      expect(find.byType(GununPuani), findsNothing);
      expect(find.text(trMetinler.gunlukKartimiAc), findsOneWidget);
    });
  });
}
