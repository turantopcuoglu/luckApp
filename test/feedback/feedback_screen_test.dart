import 'dart:async';
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
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/feedback/feedback_screen.dart';
import 'package:kader/features/feedback/feedback_strings.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  int testSayaci = 0;

  final DateTime sabitGun = DateTime(2026, 7, 6);

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('feedback_test');
    Hive.init(geciciDizin.path);
    // Kaydet butonu FakeAsync bölgesinden Hive'a yazar; bu yazmanın
    // kilidi test bitene dek açılmaz. deleteFromDisk kilitleneceği
    // için kutular test başına benzersiz adla açılır, diskten
    // silinmez (onboarding testleriyle aynı strateji).
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'fb_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'fb_kayit_$testSayaci',
    );
  });

  Future<void> ekraniAc(WidgetTester tester) async {
    // Bugünün kaydı önceden tohumlanır: kaydetme akışı senkron okuma
    // yoluna girsin (getirVeyaUret motoru çalıştırıp diske yazmasın).
    await tester.runAsync(() async {
      final LuckResult sonuc = const LuckEngine().hesapla(
        kullanici: UserSeed.fromIsim(
          isim: 'Misafir',
          dogumTarihi: DateTime(2000),
        ),
        gun: sabitGun,
      );
      await LuckHistoryRepository(
        kayitKutusu,
      ).kaydet(DailyRecord(sonuc: sonuc));
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          bugunProvider.overrideWithValue(sabitGun),
        ],
        // Üretimdeki gibi: feedback ekranı bir ana ekranın ÜSTÜNE
        // push edilir; pop sonrası SnackBar'ın tutunacağı Scaffold
        // (ev sahibi) ekranda kalır.
        child: const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    final NavigatorState gezgin = tester.state(find.byType(Navigator));
    unawaited(
      gezgin.push(
        MaterialPageRoute<void>(builder: (_) => const FeedbackScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('soru, seçenekler ve emojiler görünür; Kaydet kapalı başlar', (
    WidgetTester tester,
  ) async {
    await ekraniAc(tester);

    expect(find.text(FeedbackStrings.aksamSorusu(AppDil.tr)), findsOneWidget);
    expect(find.text(FeedbackStrings.evetEmoji), findsOneWidget);
    expect(find.text(FeedbackStrings.hayirEmoji), findsOneWidget);
    for (final String emoji in FeedbackStrings.emojiSecenekleri) {
      expect(find.text(emoji), findsOneWidget);
    }

    final FilledButton kaydet = tester.widget<FilledButton>(
      find.byType(FilledButton),
    );
    expect(kaydet.onPressed, isNull); // 👍/👎 seçilmeden kapalı
  });

  testWidgets('👍 + emoji seçip kaydetmek bugünün kaydına işlenir', (
    WidgetTester tester,
  ) async {
    await ekraniAc(tester);

    await tester.tap(find.text(FeedbackStrings.evetEmoji));
    await tester.pump();
    await tester.tap(find.text('🍀'));
    await tester.pump();
    await tester.tap(find.text(FeedbackStrings.kaydet(AppDil.tr)));
    await tester.pump();
    // Pop geçiş animasyonunun bitmesini bekle.
    await tester.pump(const Duration(seconds: 1));

    // Hive bellek içi durumu senkron günceller; kayıt hemen okunabilir.
    final DailyRecord kayit = LuckHistoryRepository(
      kayitKutusu,
    ).getir(sabitGun)!;
    expect(kayit.feedbackPozitif, isTrue);
    expect(kayit.feedbackEmoji, '🍀');
    // Teşekkür mesajı gösterilir ve ekran kapanır.
    expect(find.text(FeedbackStrings.tesekkur(AppDil.tr)), findsOneWidget);
    expect(find.text(FeedbackStrings.aksamSorusu(AppDil.tr)), findsNothing);
  });

  testWidgets('👎 emoji olmadan da kaydedilebilir', (
    WidgetTester tester,
  ) async {
    await ekraniAc(tester);

    await tester.tap(find.text(FeedbackStrings.hayirEmoji));
    await tester.pump();
    await tester.tap(find.text(FeedbackStrings.kaydet(AppDil.tr)));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final DailyRecord kayit = LuckHistoryRepository(
      kayitKutusu,
    ).getir(sabitGun)!;
    expect(kayit.feedbackPozitif, isFalse);
    expect(kayit.feedbackEmoji, isNull);
  });
}
