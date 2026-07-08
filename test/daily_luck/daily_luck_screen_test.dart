import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunun_icerigi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/categories/categories_config.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/daily_luck/widgets/score_ring.dart';
import 'package:kader/features/share/share_button.dart';
import 'package:kader/features/share/share_service.dart';

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
  /// loop'a izin verilir, ardından pump veri durumunu çizer.
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
  }

  /// Kader kartına dokunur ve tüm açılış zincirini pompalar:
  /// flip+iniş (1.1sn) → count-up (1.2sn) + kutu açılışları + yorum.
  Future<void> kartiAc(WidgetTester tester) async {
    await tester.tap(find.byType(FortuneRevealCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200)); // flip + iniş
    await tester.pump(const Duration(milliseconds: 1500)); // sayaç+kutular
    await tester.pump(const Duration(milliseconds: 500)); // yorum fade
  }

  testWidgets('tarih, misafir selamlaması ve kapalı kart görünür',
      (WidgetTester tester) async {
    await ekraniAc(tester);

    expect(find.text('6 Temmuz 2026, Pazartesi'), findsOneWidget);
    expect(
      find.text(TrStrings.selamlama(TrStrings.misafirIsmi)),
      findsOneWidget,
    );
    expect(find.byType(FortuneRevealCard), findsOneWidget);
    expect(find.text(TrStrings.kartIpucu), findsOneWidget);
    // Kart kapalı: skor halkası ve skor etiketi henüz yok.
    expect(find.byType(ScoreRing), findsNothing);
    expect(find.text(TrStrings.genelSkorEtiketi), findsNothing);
  });

  testWidgets('karta dokununca motorun ürettiği skor halkada yazar',
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
    await kartiAc(tester);

    expect(find.byType(ScoreRing), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ScoreRing),
        matching: find.text('${beklenen.genelSkor}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'kutular kapalı başlar; kart açılınca etiketler, yorum ve şans '
      'ögeleri belirir', (WidgetTester tester) async {
    // Ekranın göstermesi beklenen deterministik içerik: misafir profil
    // + sabit gün için composer'ın üreteceği paket.
    final UserProfile misafir = UserProfile(
      isim: TrStrings.misafirIsmi,
      dogumTarihi: DateTime(2000),
    );
    const LuckEngine motor = LuckEngine();
    final LuckResult sonuc =
        motor.hesapla(kullanici: misafir.seed, gun: sabitGun);
    final GununIcerigi beklenen = gununIcerigi(
      motor: motor,
      kullanici: misafir.seed,
      sonuc: sonuc,
    );

    await ekraniAc(tester);

    // Kapalı durumda kategori etiketleri görünmez (yalnız ikonlar).
    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsNothing);
    }

    await kartiAc(tester);

    // Açılış sonrası: 5 etiket + kompoze yorum + şans ögeleri + paylaş.
    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsOneWidget);
    }
    expect(find.text(beklenen.yorum), findsOneWidget);
    expect(find.text(beklenen.sansRengi.ad), findsOneWidget);
    expect(find.text('${beklenen.sansliSayi}'), findsWidgets);
    expect(find.text(beklenen.tavsiye), findsOneWidget);
    expect(find.text(TrStrings.sansRengiEtiketi), findsOneWidget);
    expect(find.text(TrStrings.sansliSayiEtiketi), findsOneWidget);
    expect(find.text(TrStrings.tavsiyeEtiketi), findsOneWidget);
    expect(find.byType(ShareButton), findsOneWidget);
  });

  testWidgets('Paylaş butonu servisi günün sonucuyla çağırır',
      (WidgetTester tester) async {
    final _SahteShareService sahte = _SahteShareService();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            userProfileBoxProvider.overrideWithValue(profilKutusu),
            dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
            bugunProvider.overrideWithValue(sabitGun),
            shareServiceProvider.overrideWithValue(sahte),
          ],
          child: const MaterialApp(home: DailyLuckScreen()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await kartiAc(tester);

    await tester.ensureVisible(find.byType(ShareButton));
    await tester.tap(find.byType(ShareButton));
    await tester.pump();

    expect(sahte.paylasilanlar, hasLength(1));
    expect(sahte.paylasilanlar.single.gun, sabitGun);
    // Premium yokken kilitli kategoriler karta maskeli gitmeli.
    expect(
      sahte.kilitliSetler.single,
      CategoriesConfig.kilitliKategoriler,
    );
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

/// Paylaşımı kaydeden sahte servis (gerçek plugin çağrısı yapılmaz).
class _SahteShareService extends ShareService {
  /// paylas ile gelen sonuçlar.
  final List<LuckResult> paylasilanlar = <LuckResult>[];

  /// paylas ile gelen kilitli kategori setleri (sızıntı doğrulaması).
  final List<Set<LuckCategory>> kilitliSetler = <Set<LuckCategory>>[];

  @override
  Future<void> paylas({
    required LuckResult sonuc,
    Set<LuckCategory> kilitliKategoriler = const <LuckCategory>{},
  }) async {
    paylasilanlar.add(sonuc);
    kilitliSetler.add(kilitliKategoriler);
  }
}
