import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/home/ana_kabuk.dart';
import 'package:kader/features/legal/legal_config.dart';
import 'package:kader/features/legal/uyari_screen.dart';
import 'package:kader/main.dart';

import 'test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 7, 6);
  final UserProfile turan = UserProfile(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
    onboardingTamam: true,
    uyariKabulSurumu: LegalConfig.uyariSurumu,
  );

  setUp(() => ortam.kur('smoke_test'));

  /// Uygulamayı kökten açar. Smoke test FakeAsync'te kalır (runAsync YOK):
  /// gerçek event loop GoogleFonts'un HTTP font indirmesini tetikler.
  /// Günün sonucu diske dokunmayan bir override ile sabitlenir.
  Future<LuckResult> uygulamayiAc(WidgetTester tester) async {
    final LuckResult sonuc =
        const LuckEngine().hesapla(kullanici: turan.seed, gun: sabitGun);
    await tester.pumpWidget(
      ProviderScope(
        overrides: ortam.overridelar(
          gun: sabitGun,
          ek: <Override>[
            gununSansiProvider.overrideWith(
              (Ref ref) => Future<LuckResult>.value(sonuc),
            ),
          ],
        ),
        child: const KaderApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    return sonuc;
  }

  testWidgets('onboarding bitmiş kullanıcı ana kabuğa ve ana ekrana açılır',
      (WidgetTester tester) async {
    await tester.runAsync(
      () => ortam.profil.put(StorageKeys.profilKaydi, turan.toMap()),
    );
    final LuckResult sonuc = await uygulamayiAc(tester);

    expect(find.byType(AnaKabuk), findsOneWidget);
    expect(find.byType(DailyLuckScreen), findsOneWidget);

    await tester.tap(find.byType(FortuneRevealCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('${sonuc.genelSkor}'), findsWidgets);
  });

  testWidgets('uyarıyı onaylamamış eski kullanıcıya önce uyarı kapısı açılır',
      (WidgetTester tester) async {
    await tester.runAsync(
      () => ortam.profil.put(
        StorageKeys.profilKaydi,
        UserProfile(
          isim: 'Turan',
          dogumTarihi: DateTime(1990, 5, 15),
          onboardingTamam: true,
        ).toMap(),
      ),
    );
    await uygulamayiAc(tester);

    expect(find.byType(UyariScreen), findsOneWidget);
    expect(find.byType(AnaKabuk), findsNothing);
  });
}
