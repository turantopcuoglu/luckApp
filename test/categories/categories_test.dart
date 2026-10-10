import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/fortune_composer.dart' as composer;
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/categories/category_detail_screen.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/premium/paywall_screen.dart';
import 'package:kader/features/premium/premium_providers.dart';
import 'package:kader/features/premium/premium_strings.dart';
import 'package:kader/shared/widgets/kilit_amblemi.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 7, 6);
  const LuckEngine motor = LuckEngine();
  final UserProfile profil = UserProfile(
    isim: 'Mert',
    dogumTarihi: DateTime(1991, 7, 30),
    onboardingTamam: true,
  );

  Future<void> hazirla({Set<String> kilitler = const <String>{}}) async {
    await ortam.kur('categories_test');
    await ortam.profil.put(StorageKeys.profilKaydi, profil.toMap());
    await ortam.kayit.put(
      gunAnahtari(sabitGun),
      DailyRecord(
        sonuc: motor.hesapla(kullanici: profil.seed, gun: sabitGun),
        reklamKilitleri: kilitler,
      ).toMap(),
    );
  }

  Future<void> ekraniAc(
    WidgetTester tester,
    Widget ev, {
    bool premium = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: sabitGun, premium: premium),
          child: testUygulamasi(ev),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  Future<void> anaEkraniAcVeKartiCevir(
    WidgetTester tester, {
    bool premium = false,
  }) async {
    await ekraniAc(tester, const DailyLuckScreen(), premium: premium);
    await tester.tap(find.byType(FortuneRevealCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('CategoryDetailScreen', () {
    testWidgets('skor, kişisel paragraf, eylem ve şanslı saat gösterilir',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      final LuckResult sonuc =
          motor.hesapla(kullanici: profil.seed, gun: sabitGun);
      final KategoriOkumasi beklenen = composer.kategoriOkumasi(
        motor: motor,
        okuyucu: profil.okuyucu,
        sonuc: sonuc,
        kategori: LuckCategory.saglik,
      );

      await ekraniAc(
        tester,
        const CategoryDetailScreen(kategori: LuckCategory.saglik),
      );

      expect(find.text('${beklenen.skor}'), findsWidgets);
      expect(find.text('SAĞLIK'), findsOneWidget);
      // Orijinal düzen: tek yorum kartı (paragraf + eylem) ve saat kartı.
      expect(
        find.text('${beklenen.paragraf}\n\n${beklenen.eylem}'),
        findsOneWidget,
      );
      expect(find.text(trMetinler.kategoriSansliSaat), findsOneWidget);
      expect(find.text(beklenen.sansliSaat.etiket), findsOneWidget);
    });
  });

  group('premium kilidi (ana ekran)', () {
    testWidgets('aşk ve para kutuları kilit ikonu taşır',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await ekraniAc(tester, const DailyLuckScreen());
      expect(find.byType(KilitAmblemi), findsNWidgets(2));
    });

    testWidgets('kilitli kutu kilit seçeneklerini, oradan paywall açılır',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await anaEkraniAcVeKartiCevir(tester);

      await tester.ensureVisible(find.text(LuckCategory.ask.etiket));
      await tester.tap(find.text(LuckCategory.ask.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(PremiumStrings.kilitBaslik), findsOneWidget);
      expect(
        find.text(trMetinler.kategoriKilitAciklamasi(LuckCategory.ask.etiket)),
        findsOneWidget,
      );
      // Reklam SDK'sı hazır değilken reklam seçeneği gösterilmez.
      expect(find.text(PremiumStrings.reklamlaAc), findsNothing);

      await tester.tap(find.text(PremiumStrings.premiumaGec));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.text(PremiumStrings.baslik), findsOneWidget);
      // Mağaza yok (test): plan bulunamadı mesajı ve yenileme bilgisi.
      expect(find.text(PremiumStrings.planYok), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text(PremiumStrings.yenilemeBilgisi),
        100,
      );
      expect(find.text(PremiumStrings.yenilemeBilgisi), findsOneWidget);
    });

    testWidgets('kilitsiz kutuya dokunmak detay sayfası açar',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await anaEkraniAcVeKartiCevir(tester);

      await tester.ensureVisible(find.text(LuckCategory.saglik.etiket));
      await tester.tap(find.text(LuckCategory.saglik.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CategoryDetailScreen), findsOneWidget);
    });

    testWidgets('premium yetkisi kilidi kaldırır: aşk detaya gider',
        (WidgetTester tester) async {
      await tester.runAsync(hazirla);
      await anaEkraniAcVeKartiCevir(tester, premium: true);

      expect(find.byType(KilitAmblemi), findsNothing);

      await tester.ensureVisible(find.text(LuckCategory.ask.etiket));
      await tester.tap(find.text(LuckCategory.ask.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CategoryDetailScreen), findsOneWidget);
    });

    testWidgets('bugün reklamla açılan kategori kilitsiz görünür',
        (WidgetTester tester) async {
      await tester.runAsync(
        () => hazirla(
          kilitler: <String>{KilitAnahtarlari.kategori(LuckCategory.ask)},
        ),
      );
      await ekraniAc(tester, const DailyLuckScreen());
      expect(find.byType(KilitAmblemi), findsOneWidget);
    });
  });
}
