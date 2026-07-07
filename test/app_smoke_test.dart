import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/main.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('smoke_test');
    Hive.init(geciciDizin.path);
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.userProfileBox,
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.dailyRecordsBox,
    );
    // Onboarding tamamlanmış profil: uygulama doğrudan ana ekrana
    // açılmalı (onboarding akışının kendi testi ayrı dosyada).
    await profilKutusu.put(
      StorageKeys.profilKaydi,
      UserProfile(
        isim: 'Turan',
        dogumTarihi: DateTime(1990, 5, 15),
        onboardingTamam: true,
      ).toMap(),
    );
  });

  tearDown(() async {
    await profilKutusu.deleteFromDisk();
    await kayitKutusu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  testWidgets('uygulama açılır ve ana ekran yüklenir',
      (WidgetTester tester) async {
    // Smoke test FakeAsync'te kalır (runAsync YOK): gerçek event loop,
    // GoogleFonts'un gerçek HTTP font indirmesini tetikleyip patlatır.
    // FakeAsync'te ise Hive'ın disk yazması hiç bitmeyeceğinden, günün
    // sonucu diske dokunmayan bir override ile sabitlenir; kutu
    // override'ları profil okuma (senkron) için yine gereklidir.
    final DateTime sabitGun = DateTime(2026, 7, 6);
    final LuckResult sabitSonuc = const LuckEngine().hesapla(
      kullanici: UserSeed.fromIsim(
        isim: 'Misafir',
        dogumTarihi: DateTime(2000),
      ),
      gun: sabitGun,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          bugunProvider.overrideWithValue(sabitGun),
          gununSansiProvider.overrideWith(
            (Ref ref) => Future<LuckResult>.value(sabitSonuc),
          ),
        ],
        child: const KaderApp(),
      ),
    );
    await tester.pump();
    await tester.pump();
    // Count-up animasyonunun hedefe ulaşmasını bekle (1.2 sn + pay).
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(DailyLuckScreen), findsOneWidget);
    expect(find.text('${sabitSonuc.genelSkor}'), findsWidgets);
  });
}
