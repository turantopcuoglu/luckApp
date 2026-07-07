import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/daily_luck/widgets/score_ring.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;

  final DateTime sabitGun = DateTime(2026, 7, 6);

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('daily_luck_test');
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

  /// Ekranı sabit gün ve gerçek (geçici) kutularla pompalar.
  ///
  /// Hive'ın disk yazması gerçek async I/O'dur; widget testinin
  /// FakeAsync bölgesinde tamamlanmaz. runAsync ile gerçek event
  /// loop'a izin verilir, ardından tek pump veri durumunu çizer.
  Future<void> ekraniAc(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            userProfileBoxProvider.overrideWithValue(profilKutusu),
            dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
            bugunProvider.overrideWithValue(sabitGun),
          ],
          child: const MaterialApp(home: DailyLuckScreen()),
        ),
      );
      // getirVeyaUret'in disk yazmasının bitmesi için gerçek bekleme.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    // Giriş animasyonlarının (count-up, stagger) bitmesini bekle.
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('tarih, misafir selamlaması ve skor halkası görünür',
      (WidgetTester tester) async {
    await ekraniAc(tester);

    expect(find.text('6 Temmuz 2026, Pazartesi'), findsOneWidget);
    expect(
      find.text(TrStrings.selamlama(TrStrings.misafirIsmi)),
      findsOneWidget,
    );
    expect(find.byType(ScoreRing), findsOneWidget);
    expect(find.text(TrStrings.genelSkorEtiketi), findsOneWidget);
  });

  testWidgets('motorun ürettiği genel skor halkada yazar',
      (WidgetTester tester) async {
    // Ekranın göstermesi beklenen deterministik skoru motordan hesapla.
    final UserProfile misafir = UserProfile(
      isim: TrStrings.misafirIsmi,
      dogumTarihi: DateTime(2000),
    );
    final LuckResult beklenen = const LuckEngine().hesapla(
      kullanici: misafir.seed,
      gun: sabitGun,
    );

    await ekraniAc(tester);

    expect(
      find.descendant(
        of: find.byType(ScoreRing),
        matching: find.text('${beklenen.genelSkor}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('5 kategori kartı ve yorum kartı listelenir',
      (WidgetTester tester) async {
    await ekraniAc(tester);

    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsOneWidget);
    }

    // Yorum kartı kapalı başlar: davet metni görünür, yorum görünmez
    // (Session 5 flip davranışı).
    expect(find.text(TrStrings.kartArkaYuzMetni), findsOneWidget);
    expect(find.textContaining('skorunu'), findsNothing);

    // Dokununca flip tamamlanır ve yorum cümleleri açılır.
    await tester.tap(find.text(TrStrings.kartArkaYuzMetni));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('skorunu'), findsWidgets);
  });

  testWidgets('kayıtlı profil varsa selamlama onun ismiyle yapılır',
      (WidgetTester tester) async {
    // Kutuya yazma gerçek I/O'dur; FakeAsync'te takılmaması için
    // runAsync içinde yapılır.
    await tester.runAsync(
      () => profilKutusu.put(
        StorageKeys.profilKaydi,
        UserProfile(
          isim: 'Turan',
          dogumTarihi: DateTime(1990, 5, 15),
          onboardingTamam: true,
        ).toMap(),
      ),
    );

    await ekraniAc(tester);

    expect(find.text(TrStrings.selamlama('Turan')), findsOneWidget);
  });
}
