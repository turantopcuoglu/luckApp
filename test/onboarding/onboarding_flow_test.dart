import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/onboarding/calculating_screen.dart';
import 'package:kader/features/onboarding/onboarding_strings.dart';
import 'package:kader/features/onboarding/profile_form_screen.dart';
import 'package:kader/features/onboarding/welcome_screen.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  int testSayaci = 0;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('onboarding_test');
    Hive.init(geciciDizin.path);
    // Bu akış, buton callback'leri içinden (FakeAsync bölgesinde)
    // Hive'a yazar; o yazmaların disk kilidi test bitene dek açılmaz.
    // deleteFromDisk bu kilidi bekleyip KİLİTLENECEĞİ için kutular
    // test başına benzersiz adla açılır ve tearDown'da diskten
    // silinmez; geçici dizinler işletim sistemine bırakılır.
    // Repository'ler kutu adına bakmaz, davranış etkilenmez.
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'onb_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'onb_kayit_$testSayaci',
    );
  });

  Future<void> akisiBaslat(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          bugunProvider.overrideWithValue(DateTime(2026, 7, 6)),
        ],
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('karşılama: slogan ve Başla butonu görünür',
      (WidgetTester tester) async {
    await akisiBaslat(tester);

    expect(find.text(OnboardingStrings.slogan), findsOneWidget);
    expect(find.text(OnboardingStrings.basla), findsOneWidget);
  });

  testWidgets('Başla forma götürür; boş isim uyarı verir, geçirmez',
      (WidgetTester tester) async {
    await akisiBaslat(tester);

    await tester.tap(find.text(OnboardingStrings.basla));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ProfileFormScreen), findsOneWidget);

    // İsim boşken buton uyarı SnackBar'ı gösterir, ekran değişmez.
    await tester.tap(find.text(OnboardingStrings.kaderimiHesapla));
    await tester.pump();
    expect(find.text(OnboardingStrings.isimBosUyarisi), findsOneWidget);
    expect(find.byType(ProfileFormScreen), findsOneWidget);
  });

  testWidgets(
      'tam akış: isim gir → hesaplama ekranı → profil kayıtlı → ana ekran',
      (WidgetTester tester) async {
    await akisiBaslat(tester);

    // Adım 1 → 2
    await tester.tap(find.text(OnboardingStrings.basla));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Adım 2: isim yaz, devam et.
    await tester.enterText(find.byType(TextField), 'Turan');
    await tester.tap(find.text(OnboardingStrings.kaderimiHesapla));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Adım 3: hesaplama ekranı; profil bellekte kayıtlı (henüz
    // onboarding bayrağı false). Hive put bellek içi durumu senkron
    // günceller, disk yazmasını beklemeye gerek yoktur.
    expect(find.byType(CalculatingScreen), findsOneWidget);
    expect(find.text(OnboardingStrings.hesaplaniyor), findsOneWidget);
    final UserRepository repo = UserRepository(profilKutusu);
    final UserProfile? kayitli = repo.profil();
    expect(kayitli, isNotNull);
    expect(kayitli!.isim, 'Turan');
    expect(kayitli.onboardingTamam, isFalse);

    // Bugünün kaydı önceden tohumlanır: ana ekran açıldığında
    // getirVeyaUret senkron okuma yoluna girsin, diske yazmasın.
    await tester.runAsync(() async {
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: UserSeed.fromIsim(
          isim: 'Turan',
          dogumTarihi: DateTime(2000),
        ),
        gun: DateTime(2026, 7, 6),
      );
      await LuckHistoryRepository(kayitKutusu)
          .kaydet(DailyRecord(sonuc: sonuc));
    });

    // 2.5 sn animasyon + geçiş: ana ekran açılır, bayrak true olur.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(DailyLuckScreen), findsOneWidget);
    expect(repo.onboardingTamamlandiMi, isTrue);

    // Geri tuşu ana ekrandan onboarding'e dönememeli (yığın temiz).
    final NavigatorState gezgin = tester.state(find.byType(Navigator));
    expect(gezgin.canPop(), isFalse);
  });
}
