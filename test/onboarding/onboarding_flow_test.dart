import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/okuyucu.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/home/ana_kabuk.dart';
import 'package:kader/features/legal/legal_config.dart';
import 'package:kader/features/legal/uyari_screen.dart';
import 'package:kader/features/onboarding/calculating_screen.dart';
import 'package:kader/features/onboarding/profile_form_screen.dart';
import 'package:kader/features/onboarding/tanisma_screen.dart';
import 'package:kader/features/onboarding/welcome_screen.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 7, 6);

  setUp(() => ortam.kur('onboarding_test'));

  Future<void> akisiBaslat(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: ortam.overridelar(gun: sabitGun),
        child: testUygulamasi(const WelcomeScreen()),
      ),
    );
    await tester.pump();
  }

  Future<void> gecis(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Karşılama → uyarı → onay → profil formu.
  Future<void> formaKadarIlerle(WidgetTester tester) async {
    await tester.tap(find.text(trMetinler.onboardingBasla));
    await gecis(tester);
    await tester.tap(find.byKey(const Key('uyari-onay')));
    await tester.pump();
    await tester.tap(find.text(trMetinler.yasalDevam));
    await gecis(tester);
  }

  testWidgets('karşılama: slogan ve Başla butonu görünür',
      (WidgetTester tester) async {
    await akisiBaslat(tester);
    expect(find.text(trMetinler.onboardingSlogan), findsOneWidget);
    expect(find.text(trMetinler.onboardingBasla), findsOneWidget);
  });

  testWidgets('Başla önce uyarıyı açar; onaysız devam edilemez',
      (WidgetTester tester) async {
    await akisiBaslat(tester);
    await tester.tap(find.text(trMetinler.onboardingBasla));
    await gecis(tester);

    expect(find.byType(UyariScreen), findsOneWidget);
    final FilledButton devam =
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(devam.onPressed, isNull);

    await tester.tap(find.byKey(const Key('uyari-onay')));
    await tester.pump();
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('form: boş isim uyarı verir, geçirmez',
      (WidgetTester tester) async {
    await akisiBaslat(tester);
    await formaKadarIlerle(tester);
    expect(find.byType(ProfileFormScreen), findsOneWidget);

    await tester.tap(find.text(trMetinler.onboardingDevam));
    await tester.pump();
    expect(find.text(trMetinler.onboardingIsimBosUyarisi), findsOneWidget);
    expect(find.byType(ProfileFormScreen), findsOneWidget);
  });

  testWidgets(
      'tam akış: uyarı → isim + tam ad → tanışma → hesaplama → ana kabuk',
      (WidgetTester tester) async {
    await akisiBaslat(tester);
    await formaKadarIlerle(tester);

    // Profil formu: hitap adı ve tam ad.
    await tester.enterText(find.byKey(const Key('isim-alani')), 'Turan');
    await tester.enterText(
      find.byKey(const Key('tam-ad-form-alani')),
      '  Turan   Ali Kaya ',
    );
    await tester.tap(find.text(trMetinler.onboardingDevam));
    await gecis(tester);

    // Profil bellekte kayıtlı: tam ad boşlukları temizlenmiş, uyarı
    // sürümü işlenmiş, onboarding henüz bitmemiş.
    final UserRepository repo = UserRepository(ortam.profil);
    final UserProfile kayitli = repo.profil()!;
    expect(kayitli.isim, 'Turan');
    expect(kayitli.tamAd, 'Turan Ali Kaya');
    expect(kayitli.uyariKabulSurumu, LegalConfig.uyariSurumu);
    expect(kayitli.onboardingTamam, isFalse);

    // Tanışma: bir soruyu cevapla.
    expect(find.byType(TanismaScreen), findsOneWidget);
    // Alttaki rotanın (profil formu) listesi de ağaçta: tanışma listesi
    // açıkça seçilir.
    await tester.scrollUntilVisible(
      find.text(Ugras.ogrenci.etiket),
      100,
      scrollable: find
          .descendant(
            of: find.byType(TanismaScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.ensureVisible(find.text(Ugras.ogrenci.etiket));
    await tester.pump();
    await tester.tap(find.text(Ugras.ogrenci.etiket));
    await tester.pump();
    await tester.tap(find.text(trMetinler.onboardingKaderimiHesapla));
    await gecis(tester);

    expect(find.byType(CalculatingScreen), findsOneWidget);
    expect(repo.profil()!.tercihler.ugras, Ugras.ogrenci);

    // Bugünün kaydı önceden tohumlanır: ana ekran diske yazmasın.
    await tester.runAsync(() async {
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: repo.profil()!.seed,
        gun: sabitGun,
      );
      await LuckHistoryRepository(ortam.kayit)
          .kaydet(DailyRecord(sonuc: sonuc));
    });

    // 2.5 sn ışık dolumu: bayrak true olur, "Kartın hazır" belirir.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    expect(repo.onboardingTamamlandiMi, isTrue);
    expect(find.text(trMetinler.onboardingKartinHazir), findsOneWidget);

    // "Kartıma geç": ana kabuk açılır.
    await tester.tap(find.text(trMetinler.onboardingKartimaGec));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(AnaKabuk), findsOneWidget);

    // Geri tuşu ana kabuktan onboarding'e dönememeli (yığın temiz).
    final NavigatorState gezgin = tester.state(find.byType(Navigator).first);
    expect(gezgin.canPop(), isFalse);
  });
}
