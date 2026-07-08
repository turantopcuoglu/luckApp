import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/core/storage/user_repository.dart';
import 'package:kader/features/feedback/notification_service.dart';
import 'package:kader/features/settings/settings_screen.dart';
import 'package:kader/features/settings/settings_strings.dart';

/// Bildirim çağrılarını kaydeden sahte servis (gerçek plugin çağrısı yok).
class FakeNotificationService extends NotificationService {
  bool iptalEtCagrildi = false;
  int planlaCagriSayisi = 0;
  int? sonAksamDakika;
  int? sonSabahDakika;

  @override
  Future<void> iptalEt() async {
    iptalEtCagrildi = true;
  }

  @override
  Future<void> gunlukBildirimleriPlanla({
    required DateTime simdi,
    int? aksamDakika,
    int? sabahDakika,
  }) async {
    planlaCagriSayisi++;
    sonAksamDakika = aksamDakika;
    sonSabahDakika = sabahDakika;
  }
}

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  int testSayaci = 0;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('settings_test');
    Hive.init(geciciDizin.path);
    // Benzersiz kutu adları (feedback/onboarding testleriyle aynı strateji).
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'set_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'set_kayit_$testSayaci',
    );
  });

  UserProfile temelProfil({
    bool bildirimlerAcik = true,
    int? aksamBildirimDakika,
  }) =>
      UserProfile(
        isim: 'Turan',
        dogumTarihi: DateTime(1990, 5, 15),
        onboardingTamam: true,
        bildirimlerAcik: bildirimlerAcik,
        aksamBildirimDakika: aksamBildirimDakika,
      );

  Future<FakeNotificationService> ekraniAc(
    WidgetTester tester,
    UserProfile profil,
  ) async {
    // Seed yazması GERÇEK disk I/O'sudur; FakeAsync bölgesinde await
    // edilirse tamamlanmaz (askıda kalır). runAsync ile gerçek saatte
    // çalıştırılır (feedback/onboarding testleriyle aynı strateji).
    await tester.runAsync(() async {
      await UserRepository(profilKutusu).kaydet(profil);
    });
    final FakeNotificationService sahte = FakeNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          notificationServiceProvider.overrideWithValue(sahte),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
    return sahte;
  }

  testWidgets('disclaimer Hakkında bölümünde görünür',
      (WidgetTester tester) async {
    await ekraniAc(tester, temelProfil());
    expect(find.text(SettingsStrings.eglenceAmacli), findsOneWidget);
  });

  testWidgets('isim değiştirme uyarı gösterir ve onayda persist eder',
      (WidgetTester tester) async {
    await ekraniAc(tester, temelProfil());

    await tester.enterText(find.byType(TextField), 'Elif');
    await tester.tap(find.text(SettingsStrings.isimKaydet));
    await tester.pump();

    // Yeniden-hesaplama uyarısı görünür.
    expect(find.text(SettingsStrings.isimUyariMetin), findsOneWidget);

    await tester.tap(find.text(SettingsStrings.uyariDevam));
    await tester.pump();

    expect(UserRepository(profilKutusu).profil()!.isim, 'Elif');
  });

  testWidgets('isim uyarısında vazgeçmek değişikliği uygulamaz',
      (WidgetTester tester) async {
    await ekraniAc(tester, temelProfil());

    await tester.enterText(find.byType(TextField), 'Elif');
    await tester.tap(find.text(SettingsStrings.isimKaydet));
    await tester.pump();
    await tester.tap(find.text(SettingsStrings.uyariVazgec));
    await tester.pump();

    expect(UserRepository(profilKutusu).profil()!.isim, 'Turan');
  });

  testWidgets('boş isim kaydı SnackBar ile reddedilir',
      (WidgetTester tester) async {
    await ekraniAc(tester, temelProfil());

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text(SettingsStrings.isimKaydet));
    await tester.pump();

    expect(find.text(SettingsStrings.isimBosUyarisi), findsOneWidget);
    // Uyarı diyaloğu açılmaz.
    expect(find.text(SettingsStrings.isimUyariMetin), findsNothing);
  });

  testWidgets('bildirimleri kapatmak iptalEt çağırır ve persist eder',
      (WidgetTester tester) async {
    final FakeNotificationService sahte =
        await ekraniAc(tester, temelProfil());

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(sahte.iptalEtCagrildi, isTrue);
    expect(UserRepository(profilKutusu).profil()!.bildirimlerAcik, isFalse);
  });

  testWidgets('bildirimleri açmak yeniden planlar ve persist eder',
      (WidgetTester tester) async {
    final FakeNotificationService sahte = await ekraniAc(
      tester,
      temelProfil(bildirimlerAcik: false),
    );

    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    expect(sahte.planlaCagriSayisi, greaterThan(0));
    expect(UserRepository(profilKutusu).profil()!.bildirimlerAcik, isTrue);
  });

  testWidgets('akşam saati değiştirmek yeni dakikayla yeniden planlar',
      (WidgetTester tester) async {
    final FakeNotificationService sahte =
        await ekraniAc(tester, temelProfil());

    await tester.tap(find.text(SettingsStrings.aksamHatirlatma));
    await tester.pumpAndSettle();

    // Saat seçicide "Tamam"a bas: initial saat korunur ama planlama
    // tetiklenir ve o dakika persist edilir (21:00 = 1260).
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(sahte.planlaCagriSayisi, greaterThan(0));
    expect(sahte.sonAksamDakika, 1260);
    expect(
      UserRepository(profilKutusu).profil()!.aksamBildirimDakika,
      1260,
    );
  });
}
