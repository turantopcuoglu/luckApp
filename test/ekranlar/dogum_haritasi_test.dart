import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/harita_okumasi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/profile/dogum_haritasi_screen.dart';
import 'package:kader/features/profile/profile_config.dart';
import 'package:kader/features/profile/profile_providers.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 10, 3);
  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
    uyariKabulSurumu: 1,
  );
  // 08:30, İstanbul.
  final UserProfile ayseTam = ayse.copyWith(
    dogumSaatiDakika: 8 * 60 + 30,
    dogumIliPlaka: 34,
  );

  Future<void> hazirla(UserProfile p) async {
    await ortam.kur('harita_test');
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
    Widget ev,
    UserProfile p, {
    bool premium = false,
  }) async {
    await tester.runAsync(() => hazirla(p));
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: sabitGun, premium: premium),
          child: testUygulamasi(
            Scaffold(body: ListView(children: <Widget>[ev])),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  group('UserProfile doğum bilgisi alanları', () {
    test('kaydedilip okunur; eski kayıtlarda null', () {
      final UserProfile okunan = UserProfile.fromMap(ayseTam.toMap());
      expect(okunan.dogumSaatiDakika, 510);
      expect(okunan.dogumIliPlaka, 34);
      final Map<String, dynamic> eski = ayse.toMap()
        ..remove('dogumSaatiDakika')
        ..remove('dogumIliPlaka');
      final UserProfile eskiProfil = UserProfile.fromMap(eski);
      expect(eskiProfil.dogumSaatiDakika, isNull);
      expect(eskiProfil.dogumIliPlaka, isNull);
    });

    test('copyWith temizleme bayrakları; skor tohumu değişmez', () {
      final UserProfile temiz = ayseTam.copyWith(
        dogumSaatiniTemizle: true,
        dogumIliniTemizle: true,
      );
      expect(temiz.dogumSaatiDakika, isNull);
      expect(temiz.dogumIliPlaka, isNull);
      expect(ayseTam.seed.isimHash, ayse.seed.isimHash);
      expect(ayseTam.seed.dogumTarihi, ayse.seed.dogumTarihi);
    });
  });

  group('haritaOkumasiProvider', () {
    test('saat ve il yoksa Yükselen yok; varsa hesaplanır', () async {
      await hazirla(ayse);
      final ProviderContainer c = ProviderContainer(
        overrides: ortam.overridelar(gun: sabitGun),
      );
      addTearDown(c.dispose);
      final HaritaOkumasi eksik = c.read(haritaOkumasiProvider);
      expect(eksik.gunes, Burc.balik);
      expect(eksik.yukselen, isNull);

      await UserRepository(ortam.profil).kaydet(ayseTam);
      // Profil önbelleğe alındığı için yeni kayıt yeni bir kapsayıcıyla okunur.
      final ProviderContainer c2 = ProviderContainer(
        overrides: ortam.overridelar(gun: sabitGun),
      );
      addTearDown(c2.dispose);
      final HaritaOkumasi tam = c2.read(haritaOkumasiProvider);
      expect(tam.yukselen, isNotNull);
      expect(tam.ozet, startsWith('Güneş Balık · Ay '));
      expect(tam.ozet.endsWith('?'), isFalse);
    });
  });

  group('BuyukUcluKarti', () {
    testWidgets('bilgi yokken "Yükselenini öğren" düzenleyiciyi açar; il '
        'seçilip kaydedilir', (WidgetTester tester) async {
      await ac(tester, const BuyukUcluKarti(), ayse);
      expect(find.text('Balık'), findsOneWidget);
      expect(find.text(ProfileConfig.bilinmeyenDeger), findsOneWidget);

      await tester.tap(find.text(trMetinler.profilYukseleniniOgren));
      await tester.pumpAndSettle();
      expect(find.text(trMetinler.profilDogumBilgisiBaslik), findsOneWidget);

      await tester.enterText(find.byKey(const Key('dogum-ili-alani')), 'ist');
      await tester.pumpAndSettle();
      await tester.tap(find.text('İstanbul').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(trMetinler.profilKaydet));
      await tester.pumpAndSettle();

      final UserProfile kayitli = UserRepository(ortam.profil).profil()!;
      expect(kayitli.dogumIliPlaka, 34);
      expect(kayitli.dogumSaatiDakika, isNull);
      // Saat hâlâ bilinmediği için Yükselen yok; düğme duruyor.
      expect(find.text(trMetinler.profilYukseleniniOgren), findsOneWidget);
    });

    testWidgets('saat ve il varsa üç burç ve "Haritanı oku" görünür', (
      WidgetTester tester,
    ) async {
      await ac(tester, const BuyukUcluKarti(), ayseTam);
      expect(find.text(ProfileConfig.bilinmeyenDeger), findsNothing);
      expect(find.text(trMetinler.profilHaritaniOku), findsOneWidget);
    });
  });

  group('DogumHaritasiScreen', () {
    Future<void> ekraniAc(WidgetTester tester, {bool premium = false}) async {
      await tester.runAsync(() => hazirla(ayseTam));
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: ortam.overridelar(gun: sabitGun, premium: premium),
            child: testUygulamasi(const DogumHaritasiScreen()),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
    }

    testWidgets('Güneş ve Ay açık, Yükselen kilitli', (
      WidgetTester tester,
    ) async {
      await ekraniAc(tester);
      expect(find.text(trMetinler.profilGunesBasligi('Balık')), findsOneWidget);
      expect(find.textContaining('Ay burcun · '), findsWidgets);
      await tester.scrollUntilVisible(
        find.textContaining('Yükselenin · '),
        200,
      );
      expect(find.text(trMetinler.profilKilidiAc), findsWidgets);
    });

    testWidgets('premium kullanıcıda kilit yok', (WidgetTester tester) async {
      await ekraniAc(tester, premium: true);
      await tester.scrollUntilVisible(
        find.textContaining('Yükselenin · '),
        200,
      );
      expect(find.text(trMetinler.profilKilidiAc), findsNothing);
    });
  });
}
