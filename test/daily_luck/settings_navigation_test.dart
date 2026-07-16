import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/feedback/notification_service.dart';
import 'package:kader/features/history/history_screen.dart';
import 'package:kader/features/settings/settings_screen.dart';
import 'package:kader/features/settings/settings_strings.dart';

/// Bildirim planlamasını yutan sahte servis (gerçek plugin yok).
class _SahteBildirim extends NotificationService {
  @override
  Future<void> gunlukBildirimleriPlanla({
    required DateTime simdi,
    required AppDil dil,
    int? aksamDakika,
    int? sabahDakika,
    int? sansliSaatBaslangiciSaati,
  }) async {}

  @override
  Future<void> iptalEt() async {}
}

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;

  final DateTime sabitGun = DateTime(2026, 7, 6);

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('settings_nav_test');
    Hive.init(geciciDizin.path);
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.userProfileBox,
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.dailyRecordsBox,
    );
  });

  tearDown(() async {
    await profilKutusu.deleteFromDisk();
    await kayitKutusu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  /// Ana ekranı gerçek (üretimdeki gibi) MaterialApp + push rotasıyla kurar.
  Future<void> anaEkraniAc(WidgetTester tester) async {
    await tester.runAsync(() async {
      // Profil + bugünün kaydı önceden yazılır ki ekran senkron kurulsun.
      final UserProfile profil = UserProfile(
        isim: 'Turan',
        dogumTarihi: DateTime(1990, 5, 15),
        onboardingTamam: true,
      );
      await profilKutusu.put(StorageKeys.profilKaydi, profil.toMap());
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: profil.seed,
        gun: sabitGun,
      );
      await LuckHistoryRepository(
        kayitKutusu,
      ).kaydet(DailyRecord(sonuc: sonuc));

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            userProfileBoxProvider.overrideWithValue(profilKutusu),
            dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
            bugunProvider.overrideWithValue(sabitGun),
            notificationServiceProvider.overrideWithValue(_SahteBildirim()),
          ],
          // Üretimdeki gibi: MaterialApp içinde ana ekran (push rotası buradan).
          child: const MaterialApp(home: DailyLuckScreen()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
  }

  testWidgets('dişliye dokununca Ayarlar gövdesi exception\'sız açılır', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    // Gövde build'inde bir istisna oluşmamalı (release'de boş ekran nedeni).
    expect(tester.takeException(), isNull);
    expect(find.byType(SettingsScreen), findsOneWidget);
    // Gövde gerçekten render oldu mu? (isim bölümü + disclaimer + saatler)
    expect(find.text(SettingsStrings.isimBolumu(AppDil.tr)), findsOneWidget);
    expect(find.text(SettingsStrings.eglenceAmacli(AppDil.tr)), findsOneWidget);
    expect(
      find.text(SettingsStrings.aksamHatirlatma(AppDil.tr)),
      findsOneWidget,
    );
  });

  testWidgets('takvim ikonuna dokununca Geçmiş exception\'sız açılır', (
    WidgetTester tester,
  ) async {
    await anaEkraniAc(tester);

    await tester.tap(find.byIcon(Icons.calendar_month_rounded));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HistoryScreen), findsOneWidget);
  });
}
