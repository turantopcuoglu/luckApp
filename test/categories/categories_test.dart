import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/fortune_composer.dart' as composer;
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/categories/categories_strings.dart';
import 'package:kader/features/categories/category_detail_screen.dart';
import 'package:kader/features/categories/entitlement.dart';
import 'package:kader/features/categories/paywall_screen.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/widgets/category_card.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;

  final DateTime sabitGun = DateTime(2026, 7, 6);
  final UserProfile misafir = UserProfile(
    isim: 'Misafir',
    dogumTarihi: DateTime(2000),
  );
  const LuckEngine motor = LuckEngine();

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('categories_test');
    Hive.init(geciciDizin.path);
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.userProfileBox,
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      StorageKeys.dailyRecordsBox,
    );
    // Bugünün kaydı tohumlanır: ekranlar diske yazmadan okusun.
    final LuckResult sonuc =
        motor.hesapla(kullanici: misafir.seed, gun: sabitGun);
    await kayitKutusu.put(
      gunAnahtari(sabitGun),
      DailyRecord(sonuc: sonuc).toMap(),
    );
  });

  tearDown(() async {
    await profilKutusu.deleteFromDisk();
    await kayitKutusu.deleteFromDisk();
    await geciciDizin.delete(recursive: true);
  });

  List<Override> temelOverridelar({bool premium = false}) => <Override>[
        userProfileBoxProvider.overrideWithValue(profilKutusu),
        dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
        bugunProvider.overrideWithValue(sabitGun),
        if (premium)
          entitlementProvider.overrideWith((Ref ref) => true),
      ];

  Future<void> ekraniAc(WidgetTester tester, Widget ev,
      {bool premium = false}) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: temelOverridelar(premium: premium),
          child: MaterialApp(home: ev),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  group('CategoryDetailScreen', () {
    testWidgets('skor, 2 cümle yorum ve şanslı saat gösterilir',
        (WidgetTester tester) async {
      final LuckResult sonuc =
          motor.hesapla(kullanici: misafir.seed, gun: sabitGun);
      final int beklenenSkor =
          sonuc.kategoriSkorlari[LuckCategory.saglik]!;
      final SansliSaat beklenenSaat = motor.sansliSaat(
        kullanici: misafir.seed,
        gun: sabitGun,
        kategori: LuckCategory.saglik,
      );

      await ekraniAc(
        tester,
        const CategoryDetailScreen(kategori: LuckCategory.saglik),
      );

      expect(find.text('$beklenenSkor'), findsWidgets);
      expect(find.text('SAĞLIK'), findsOneWidget);
      expect(
        find.text(
          composer.kategoriYorumu(
            motor: motor,
            kullanici: misafir.seed,
            sonuc: sonuc,
            kategori: LuckCategory.saglik,
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(CategoriesStrings.sansliSaatBaslik), findsOneWidget);
      expect(find.text(beklenenSaat.etiket), findsOneWidget);
    });

    testWidgets('kilitli kategoriye doğrudan gelinirse paywall gösterilir',
        (WidgetTester tester) async {
      // Savunma derinliği: ana ekran yönlendirmesi atlansa bile
      // (deep link, ileride eklenecek rota vs.) içerik kurulmamalı.
      await ekraniAc(
        tester,
        const CategoryDetailScreen(kategori: LuckCategory.ask),
      );

      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.text(CategoriesStrings.paywallBaslik), findsOneWidget);
      expect(find.text(CategoriesStrings.sansliSaatBaslik), findsNothing);
    });

    testWidgets('premium yetkisiyle kilitli kategori detayı açılır',
        (WidgetTester tester) async {
      await ekraniAc(
        tester,
        const CategoryDetailScreen(kategori: LuckCategory.ask),
        premium: true,
      );

      expect(find.byType(PaywallScreen), findsNothing);
      expect(find.text('AŞK'), findsOneWidget);
      expect(find.text(CategoriesStrings.sansliSaatBaslik), findsOneWidget);
    });
  });

  group('premium gate (ana ekran)', () {
    Future<void> anaEkraniAcVeKartiCevir(WidgetTester tester,
        {bool premium = false}) async {
      await ekraniAc(tester, const DailyLuckScreen(), premium: premium);
      await tester.tap(find.byType(FortuneRevealCard));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('aşk ve para kutuları kilit ikonu taşır',
        (WidgetTester tester) async {
      await ekraniAc(tester, const DailyLuckScreen());
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(2));
    });

    testWidgets('kilitli kutuya dokunmak paywall açar',
        (WidgetTester tester) async {
      await anaEkraniAcVeKartiCevir(tester);

      await tester.tap(find.text(LuckCategory.ask.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.text(CategoriesStrings.paywallBaslik), findsOneWidget);
    });

    testWidgets('kilitsiz kutuya dokunmak detay sayfası açar',
        (WidgetTester tester) async {
      await anaEkraniAcVeKartiCevir(tester);

      await tester.tap(find.text(LuckCategory.saglik.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CategoryDetailScreen), findsOneWidget);
      expect(find.byType(PaywallScreen), findsNothing);
    });

    testWidgets('kilitli kartta gerçek skor yerine maske gösterilir',
        (WidgetTester tester) async {
      final LuckResult sonuc =
          motor.hesapla(kullanici: misafir.seed, gun: sabitGun);

      await anaEkraniAcVeKartiCevir(tester);

      // İki kilitli kart da maske metni taşır.
      expect(
        find.text(CategoriesStrings.kilitliSkor),
        findsNWidgets(2),
      );

      // Kilitli skorlar kategori kartlarının İÇİNDE metin olarak yok
      // (blur'dan bağımsız gerçek gizlilik garantisi). Kilitli skor,
      // açık bir kategorinin skoruyla çakışıyorsa iddia atlanır.
      final Set<int> acikSkorlar = <int>{
        sonuc.kategoriSkorlari[LuckCategory.saglik]!,
        sonuc.kategoriSkorlari[LuckCategory.risk]!,
        sonuc.kategoriSkorlari[LuckCategory.sosyal]!,
      };
      for (final LuckCategory k in <LuckCategory>[
        LuckCategory.ask,
        LuckCategory.para,
      ]) {
        final int gizliSkor = sonuc.kategoriSkorlari[k]!;
        if (acikSkorlar.contains(gizliSkor)) {
          continue;
        }
        expect(
          find.descendant(
            of: find.byType(CategoryCard),
            matching: find.text('$gizliSkor'),
          ),
          findsNothing,
          reason: '${k.etiket} skoru ana ekranda sızdı',
        );
      }
    });

    testWidgets('premium yetkisi kilidi kaldırır: aşk detaya gider',
        (WidgetTester tester) async {
      await anaEkraniAcVeKartiCevir(tester, premium: true);

      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      await tester.tap(find.text(LuckCategory.ask.etiket));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(CategoryDetailScreen), findsOneWidget);
    });
  });
}
