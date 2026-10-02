import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/rapor_metinleri.dart';
import 'package:kader/core/content/rapor_okumasi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/legal/legal_texts.dart';
import 'package:kader/features/profile/kader_profili_screen.dart';
import 'package:kader/features/profile/numeroloji_raporu_screen.dart';
import 'package:kader/features/profile/profile_providers.dart';
import 'package:kader/features/profile/profile_strings.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  // 13.09.2026'da Ayşe (14.03.1994) 32 yaşında: 2. dönem, zirve 1.
  final DateTime sabitGun = DateTime(2026, 9, 13);
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
    uyariKabulSurumu: 1,
  );

  Future<void> hazirla({UserProfile? profil}) async {
    await ortam.kur('rapor_test');
    final UserProfile p = profil ?? ayse;
    await ortam.profil.put(StorageKeys.profilKaydi, p.toMap());
    await ortam.kayit.put(
      gunAnahtari(sabitGun),
      DailyRecord(
        sonuc: const LuckEngine().hesapla(kullanici: p.seed, gun: sabitGun),
      ).toMap(),
    );
  }

  Future<void> ac(
    WidgetTester tester,
    Widget ev, {
    bool premium = false,
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: sabitGun, premium: premium),
          child: MaterialApp(home: ev),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  group('raporOkumasiProvider', () {
    test('aktif profilin raporunu bugünün dönemiyle üretir', () async {
      await hazirla();
      final ProviderContainer c = ProviderContainer(
        overrides: ortam.overridelar(gun: sabitGun),
      );
      addTearDown(c.dispose);
      final RaporOkumasi o = c.read(raporOkumasiProvider);
      expect(o.bolumler.first.baslik, 'Şu anki dönemin · Zirve 1');
      expect(c.read(numerolojiRaporuProvider).olgunluk, 5);
    });
  });

  group('NumerolojiRaporuScreen', () {
    testWidgets('zaman çizelgesi ve aktif zirve açık; diğerleri kilitli', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(hazirla);
      await ac(tester, const NumerolojiRaporuScreen());

      expect(find.text(ProfileStrings.zamanCizelgesiBaslik), findsOneWidget);
      expect(find.text('32-41 yaş · Zirve 1'), findsOneWidget);
      expect(find.text(ProfileStrings.suAn), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Şu anki dönemin · Zirve 1'),
        200,
      );
      expect(find.text(RaporMetinleri.zirveler[1]!.uzun), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Karmik borç 13 · Emek ve sabır'),
        200,
      );
      expect(find.text(ProfileStrings.kilidiAc), findsWidgets);
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);
    });

    testWidgets('premium kullanıcıda kilit yok, tüm bölümler okunur', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(hazirla);
      await ac(tester, const NumerolojiRaporuScreen(), premium: true);

      await tester.scrollUntilVisible(find.text('Denge sayısı 8'), 300);
      expect(find.text(ProfileStrings.kilidiAc), findsNothing);
      expect(find.text(RaporMetinleri.dengeler[8]!), findsOneWidget);
    });

    testWidgets('tam ad yoksa uyarı kartı görünür, isim bölümleri yok', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(
        () => hazirla(
          profil: UserProfile(
            isim: 'Ayşe',
            dogumTarihi: DateTime(1994, 3, 14),
            onboardingTamam: true,
          ),
        ),
      );
      await ac(tester, const NumerolojiRaporuScreen(), premium: true);

      await tester.scrollUntilVisible(
        find.text(ProfileStrings.raporTamAdEksikBaslik),
        200,
      );
      expect(find.text(ProfileStrings.raporTamAdEksikBaslik), findsOneWidget);
      await tester.scrollUntilVisible(find.text(YasalMetinler.kisaNot), 300);
      expect(find.textContaining('Olgunluk sayısı'), findsNothing);
      expect(find.text(RaporMetinleri.gizliTutkuBasligi), findsNothing);
    });

    testWidgets('profil ekranındaki giriş kartı raporu açar', (
      WidgetTester tester,
    ) async {
      await tester.runAsync(hazirla);
      await ac(tester, const KaderProfiliScreen());

      await tester.scrollUntilVisible(
        find.text(ProfileStrings.raporGirisBaslik),
        200,
      );
      await tester.tap(find.text(ProfileStrings.raporGirisBaslik));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NumerolojiRaporuScreen), findsOneWidget);
      expect(find.text(ProfileStrings.zamanCizelgesiBaslik), findsOneWidget);
    });
  });
}
