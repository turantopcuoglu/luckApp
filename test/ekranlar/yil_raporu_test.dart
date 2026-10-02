import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/yillik_rapor_metinleri.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/premium/premium_strings.dart';
import 'package:kader/features/profile/profile_strings.dart';
import 'package:kader/features/profile/yil_raporu_karti.dart';
import 'package:kader/features/profile/yil_raporu_screen.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  // 14.03.1994 doğumlu için 2027 kişisel yıl 1 (Tohum Yılı); Ocak kişisel
  // ay 2 (yaşam yolu 4 için akışta), Şubat 3 (zorlayıcı).
  final DateTime ekim2026 = DateTime(2026, 10, 3);
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
    uyariKabulSurumu: 1,
  );

  Future<void> hazirla(DateTime gun) async {
    await ortam.kur('yil_raporu_test');
    await ortam.profil.put(StorageKeys.profilKaydi, ayse.toMap());
    await ortam.kayit.put(
      gunAnahtari(gun),
      DailyRecord(
        sonuc: const LuckEngine().hesapla(kullanici: ayse.seed, gun: gun),
      ).toMap(),
    );
  }

  Future<void> ac(
    WidgetTester tester,
    Widget ev, {
    required DateTime gun,
    bool premium = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: gun, premium: premium),
          child: MaterialApp(
            home: Scaffold(body: ListView(children: <Widget>[ev])),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  group('YilRaporuKarti.gosterilmeli', () {
    test('satıştaki yıldan önceki Ekim\'den yıl sonuna kadar görünür', () {
      expect(YilRaporuKarti.gosterilmeli(DateTime(2026, 9, 30), 2027), isFalse);
      expect(YilRaporuKarti.gosterilmeli(DateTime(2026, 10, 1), 2027), isTrue);
      expect(YilRaporuKarti.gosterilmeli(DateTime(2027, 6, 1), 2027), isTrue);
      expect(YilRaporuKarti.gosterilmeli(DateTime(2027, 12, 31), 2027), isTrue);
      expect(YilRaporuKarti.gosterilmeli(DateTime(2028, 1, 1), 2027), isFalse);
    });
  });

  group('YilRaporuKarti', () {
    testWidgets('tanıtım döneminde kişinin yıl lakabıyla görünür ve raporu '
        'açar', (WidgetTester tester) async {
      await tester.runAsync(() => hazirla(ekim2026));
      await ac(tester, const YilRaporuKarti(), gun: ekim2026);

      expect(
        find.text(ProfileStrings.yilRaporuKartBaslik(2027)),
        findsOneWidget,
      );
      expect(
        find.text(ProfileStrings.yilRaporuKartAciklama(2027, 'Tohum Yılı')),
        findsOneWidget,
      );

      await tester.tap(find.text(ProfileStrings.yilRaporuKartBaslik(2027)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(YilRaporuScreen), findsOneWidget);
    });

    testWidgets('tanıtım dönemi dışında görünmez', (WidgetTester tester) async {
      final DateTime haziran = DateTime(2026, 6, 1);
      await tester.runAsync(() => hazirla(haziran));
      await ac(tester, const YilRaporuKarti(), gun: haziran);
      expect(find.text(ProfileStrings.yilRaporuKartBaslik(2027)), findsNothing);
    });
  });

  group('YilRaporuScreen', () {
    Future<void> ekraniAc(WidgetTester tester, {bool premium = false}) async {
      await tester.runAsync(() => hazirla(ekim2026));
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: ortam.overridelar(gun: ekim2026, premium: premium),
            child: const MaterialApp(home: YilRaporuScreen(yil: 2027)),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }

    testWidgets('başlık, ücretsiz tema ve Ocak; diğer aylar kilitli, akış '
        'çipleri görünür', (WidgetTester tester) async {
      await ekraniAc(tester);

      expect(find.text(ProfileStrings.yilRaporuBaslik(2027)), findsOneWidget);
      expect(find.text('Tohum Yılı'), findsOneWidget);
      expect(find.text('2027 · Tohum Yılı · Kişisel yıl 1'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Ocak · Sabır ve iş birliği ayı'),
        300,
      );
      expect(
        find.text(YillikRaporMetinleri.aylar[2]!.varyantlar[0]),
        findsOneWidget,
      );
      expect(find.text(ProfileStrings.akisCipi), findsWidgets);

      await tester.scrollUntilVisible(
        find.text('Şubat · İfade ve paylaşım ayı'),
        300,
      );
      expect(find.text(ProfileStrings.zorluCipi), findsWidgets);
      // Şubat kilitli: tam metin görünmez.
      expect(
        find.text(YillikRaporMetinleri.aylar[3]!.varyantlar[0]),
        findsNothing,
      );
    });

    testWidgets('kilit, yıl raporu satın alma penceresini açar', (
      WidgetTester tester,
    ) async {
      await ekraniAc(tester);
      await tester.scrollUntilVisible(
        find.text(YillikRaporMetinleri.firsatlarBasligi),
        300,
      );
      await tester.ensureVisible(find.text(ProfileStrings.kilidiAc).first);
      await tester.pump();
      await tester.tap(find.text(ProfileStrings.kilidiAc).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text(PremiumStrings.yilRaporuKilitBaslik(2027)),
        findsOneWidget,
      );
      expect(find.text(PremiumStrings.reklamlaAc), findsNothing);
    });

    testWidgets('premium kullanıcıda kilit yok; yılın sorusu en sonda', (
      WidgetTester tester,
    ) async {
      await ekraniAc(tester, premium: true);
      await tester.scrollUntilVisible(
        find.text(YillikRaporMetinleri.niyetBasligi),
        400,
      );
      expect(find.text(ProfileStrings.kilidiAc), findsNothing);
      expect(
        find.text(YillikRaporMetinleri.rehberler[1]!.niyet),
        findsOneWidget,
      );
    });
  });
}
