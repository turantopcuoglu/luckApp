import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunun_icerigi.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/luck_history_repository.dart';
import 'package:kader/core/storage/providers.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/collection/collection_screen.dart';
import 'package:kader/features/collection/collection_strings.dart';
import 'package:kader/features/collection/widgets/kart_minik.dart';
import 'package:kader/features/daily_luck/daily_luck_providers.dart';
import 'package:kader/features/daily_luck/widgets/comment_card.dart';

void main() {
  late Directory geciciDizin;
  late Box<Map<dynamic, dynamic>> profilKutusu;
  late Box<Map<dynamic, dynamic>> kayitKutusu;
  int testSayaci = 0;

  const LuckEngine motor = LuckEngine();
  // Profilin seed'i bu UserSeed ile birebir aynıdır (isim + doğum);
  // kayıtlar da bu seed'le üretildiğinden yorum yeniden türetilebilir.
  final UserProfile turanProfil = UserProfile(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
    onboardingTamam: true,
  );
  final UserSeed turan = turanProfil.seed;

  setUp(() async {
    geciciDizin = await Directory.systemTemp.createTemp('collection_test');
    Hive.init(geciciDizin.path);
    testSayaci++;
    profilKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'coll_profil_$testSayaci',
    );
    kayitKutusu = await Hive.openBox<Map<dynamic, dynamic>>(
      'coll_kayit_$testSayaci',
    );
  });

  /// Belirli gün/skor ile kayıt kurar (kategori haritası gerçek motordan
  /// alınır ki mapper round-trip'i ve içerik türetimi sorunsuz olsun).
  DailyRecord kayitKur(int gunNo, int skor) {
    final DateTime gun = DateTime(2026, 7, gunNo);
    final LuckResult temel = motor.hesapla(kullanici: turan, gun: gun);
    return DailyRecord(
      sonuc: LuckResult(
        gun: gun,
        genelSkor: skor,
        kategoriSkorlari: temel.kategoriSkorlari,
        modifiyerler: temel.modifiyerler,
      ),
    );
  }

  Future<void> ekraniAc(
    WidgetTester tester,
    List<DailyRecord> kayitlar,
  ) async {
    // Seed yazması gerçek I/O → runAsync (FakeAsync'te asılmasın).
    await tester.runAsync(() async {
      final LuckHistoryRepository repo = LuckHistoryRepository(kayitKutusu);
      for (final DailyRecord k in kayitlar) {
        await repo.kaydet(k);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          userProfileBoxProvider.overrideWithValue(profilKutusu),
          dailyRecordsBoxProvider.overrideWithValue(kayitKutusu),
          // Profil seed'i deterministik olsun (yorum doğrulaması için).
          aktifProfilProvider.overrideWithValue(turanProfil),
        ],
        child: const MaterialApp(home: CollectionScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('kayıt yokken kristal küre + boş metin, kart yok',
      (WidgetTester tester) async {
    await ekraniAc(tester, <DailyRecord>[]);

    expect(find.text(CollectionStrings.bosMetin), findsOneWidget);
    expect(find.byType(KartMinik), findsNothing);
  });

  testWidgets('kayıt varken kartlar + özet + Altın Gün rozeti görünür',
      (WidgetTester tester) async {
    // 95 → Altın Gün (≥92), 60 ve 30 sıradan.
    await ekraniAc(tester, <DailyRecord>[
      kayitKur(1, 95),
      kayitKur(2, 60),
      kayitKur(3, 30),
    ]);

    expect(find.byType(KartMinik), findsNWidgets(3));
    // Özet: 3 kart, 1 Altın Gün.
    expect(find.text(CollectionStrings.ozet(3, 1)), findsOneWidget);
    // Yalnız tek altın kart → tek 🌟 rozeti (özet emoji kullanmaz).
    expect(find.text(CollectionStrings.altinRozet), findsOneWidget);
  });

  testWidgets('Altın karta dokununca o günün yorumu bottom sheet\'te belirir',
      (WidgetTester tester) async {
    final DailyRecord altinKayit = kayitKur(1, 95);
    await ekraniAc(tester, <DailyRecord>[
      altinKayit,
      kayitKur(2, 60),
      kayitKur(3, 30),
    ]);

    // Beklenen yorum: aynı motor + seed + saklanan sonuçtan türetilir.
    final GununIcerigi beklenen = gununIcerigi(
      motor: motor,
      kullanici: turan,
      sonuc: altinKayit.sonuc,
    );

    await tester.tap(
      find.byWidgetPredicate(
        (Widget w) => w is KartMinik && w.kayit.sonuc.genelSkor == 95,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CommentCard), findsOneWidget);
    expect(find.text(beklenen.yorum), findsOneWidget);
  });
}
