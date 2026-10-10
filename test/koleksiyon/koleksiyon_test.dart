import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/koleksiyon_repository.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/koleksiyon/koleksiyon_katalogu.dart';
import 'package:kader/features/koleksiyon/koleksiyon_providers.dart';
import 'package:kader/features/koleksiyon/koleksiyon_screen.dart';
import 'package:kader/features/koleksiyon/koleksiyon_strings.dart';
import 'package:kader/features/koleksiyon/widgets/koleksiyon_panelleri.dart';
import 'package:kader/shared/widgets/app_images.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime gun = DateTime(2026, 7, 6);
  const LuckEngine motor = LuckEngine();
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
  );

  group('KoleksiyonKatalogu', () {
    test('24 kart, kimlikler benzersiz, her kartın metni ve görseli var', () {
      const List<KoleksiyonKarti> k = KoleksiyonKatalogu.kartlar;
      expect(k, hasLength(24));
      expect(k.map((KoleksiyonKarti x) => x.id).toSet(), hasLength(24));
      for (final KoleksiyonKarti kart in k) {
        expect(kart.ad, isNotEmpty);
        expect(kart.soz, isNotEmpty);
        expect(File(kart.gorsel).existsSync(), isTrue, reason: kart.gorsel);
      }
      expect(KoleksiyonStrings.kartlar, hasLength(24));
    });

    test('çerçeve görselleri var; bul kimlikle kartı döndürür', () {
      expect(File(AppImages.cerceveNormal).existsSync(), isTrue);
      expect(File(AppImages.cerceveNadir).existsSync(), isTrue);
      expect(KoleksiyonKatalogu.bul('pusula')!.ad, 'Pusula');
      expect(KoleksiyonKatalogu.bul('yok'), isNull);
    });
  });

  setUp(() async {
    await ortam.kur('koleksiyon_test');
    await ortam.profil.put(StorageKeys.profilKaydi, ayse.toMap());
    await ortam.kayit.put(
      gunAnahtari(gun),
      DailyRecord(sonuc: motor.hesapla(kullanici: ayse.seed, gun: gun)).toMap(),
    );
  });

  /// Bugünün kartı motorla aynı hesapla.
  KoleksiyonKarti beklenenKart() => KoleksiyonKatalogu.kartlar[motor
      .gununKarti(
        kullanici: ayse.seed,
        gun: gun,
        kartSayisi: KoleksiyonKatalogu.kartlar.length,
      )
      .indeks];

  Future<void> ac(WidgetTester tester, Widget ekran) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: gun),
          child: testUygulamasi(ekran),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  testWidgets('gununKartiProvider motorun çekilişini katalogdan döndürür',
      (WidgetTester tester) async {
    late GununKarti okunan;
    await ac(
      tester,
      Consumer(
        builder: (BuildContext c, WidgetRef ref, Widget? _) {
          okunan = ref.watch(gununKartiProvider);
          return const SizedBox();
        },
      ),
    );
    expect(okunan.kart, beklenenKart());
  });

  testWidgets('boş koleksiyon: sayaç 0/24 ve davet metni',
      (WidgetTester tester) async {
    await ac(tester, const KoleksiyonScreen());
    expect(find.text(KoleksiyonStrings.sayac(0, 24)), findsOneWidget);
    expect(find.text(KoleksiyonStrings.bosDurum), findsOneWidget);
  });

  testWidgets('kazanılan kart öne çıkar; dokununca detay ve söz görünür',
      (WidgetTester tester) async {
    await tester.runAsync(
      () => KoleksiyonRepository(
        ortam.durum,
      ).kazan(kartId: 'pusula', gun: gun, nadir: true),
    );
    await ac(tester, const KoleksiyonScreen());

    expect(find.text(KoleksiyonStrings.sayac(1, 24)), findsOneWidget);
    expect(find.text(KoleksiyonStrings.nadir), findsOneWidget);
    expect(find.text(KoleksiyonStrings.gunSayisi(1)), findsOneWidget);

    await tester.tap(find.text('Pusula').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(KartDetayScreen), findsOneWidget);
    expect(find.text(KoleksiyonKatalogu.bul('pusula')!.soz), findsOneWidget);
  });

  testWidgets('kazanılmamış kartın detayı kilitli açıklamayı gösterir',
      (WidgetTester tester) async {
    await ac(
      tester,
      KartDetayScreen(kart: KoleksiyonKatalogu.bul('dolunay')!),
    );
    expect(find.text(KoleksiyonStrings.kilitliAciklama), findsOneWidget);
  });

  testWidgets('ana ekranda kart açılınca günün kartı koleksiyona katılır',
      (WidgetTester tester) async {
    await ac(tester, const DailyLuckScreen());
    expect(KoleksiyonRepository(ortam.durum).kartlar(), isEmpty);

    await tester.tap(find.byType(FortuneRevealCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));

    final KoleksiyonKarti kart = beklenenKart();
    expect(KoleksiyonRepository(ortam.durum).kartlar().keys, <String>[
      kart.id,
    ]);
    await tester.ensureVisible(find.byType(GununKartiPaneli));
    expect(find.text(kart.ad), findsOneWidget);
  });
}
