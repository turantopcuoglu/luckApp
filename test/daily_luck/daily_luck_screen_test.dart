import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/content/fortune_composer.dart';
import 'package:kader/core/content/gunluk_okuma.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/core/storage/storage_keys.dart';
import 'package:kader/core/storage/user_profile.dart';
import 'package:kader/features/daily_luck/daily_luck_screen.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/daily_luck/widgets/comment_card.dart';
import 'package:kader/features/daily_luck/widgets/fortune_reveal_card.dart';
import 'package:kader/features/daily_luck/widgets/score_ring.dart';
import 'package:kader/features/share/share_button.dart';
import 'package:kader/features/share/share_service.dart';

import '../test_ortami.dart';

void main() {
  final TestOrtami ortam = TestOrtami();
  final DateTime sabitGun = DateTime(2026, 7, 6);
  const LuckEngine motor = LuckEngine();

  final UserProfile ayse = UserProfile(
    isim: 'Ayşe',
    dogumTarihi: DateTime(1994, 3, 14),
    tamAd: 'Ayşe Yılmaz',
    onboardingTamam: true,
  );

  setUp(() async {
    await ortam.kur('daily_luck_test');
    await ortam.profil.put(StorageKeys.profilKaydi, ayse.toMap());
    // Bugünün kaydı tohumlanır: ekran diske yazmadan senkron okusun.
    await ortam.kayit.put(
      gunAnahtari(sabitGun),
      DailyRecord(sonuc: motor.hesapla(kullanici: ayse.seed, gun: sabitGun))
          .toMap(),
    );
  });

  GunlukOkuma beklenenOkuma() => gunlukOkuma(
        motor: motor,
        okuyucu: ayse.okuyucu,
        sonuc: motor.hesapla(kullanici: ayse.seed, gun: sabitGun),
      );

  Future<void> ekraniAc(
    WidgetTester tester, {
    List<Override> ek = const <Override>[],
  }) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: ortam.overridelar(gun: sabitGun, ek: ek),
          child: const MaterialApp(home: DailyLuckScreen()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  /// Kader kartına dokunur ve tüm açılış zincirini pompalar.
  Future<void> kartiAc(WidgetTester tester) async {
    await tester.tap(find.byType(FortuneRevealCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('tarih, isimle selamlama ve kapalı kart (orijinal üst blok)',
      (WidgetTester tester) async {
    await ekraniAc(tester);

    expect(find.text('6 Temmuz 2026, Pazartesi'), findsOneWidget);
    expect(find.text(TrStrings.selamlama('Ayşe')), findsOneWidget);
    expect(find.byType(FortuneRevealCard), findsOneWidget);
    expect(find.byType(ScoreRing), findsNothing);
  });

  testWidgets('karta dokununca kayıtlı skor halkada yazar',
      (WidgetTester tester) async {
    final LuckResult beklenen =
        motor.hesapla(kullanici: ayse.seed, gun: sabitGun);
    await ekraniAc(tester);
    await kartiAc(tester);

    expect(
      find.descendant(
        of: find.byType(ScoreRing),
        matching: find.text('${beklenen.genelSkor}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'kart açılınca başlık, tek yorum kartında okuma ve şans ögeleri belirir',
      (WidgetTester tester) async {
    final GunlukOkuma beklenen = beklenenOkuma();
    await ekraniAc(tester);

    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsNothing);
    }

    await kartiAc(tester);

    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsOneWidget);
    }
    expect(find.text(beklenen.baslik), findsOneWidget);
    expect(find.byType(CommentCard), findsOneWidget);
    expect(find.text(beklenen.kartMetni), findsOneWidget);
    expect(find.text(beklenen.sansRengi.ad), findsOneWidget);
    expect(find.text(beklenen.tavsiye), findsOneWidget);
    expect(find.text(TrStrings.nedenBugun), findsOneWidget);
    expect(find.byType(ShareButton), findsOneWidget);
  });

  testWidgets('👎 okumanın tüm bölümleri için cevabı bugünün kaydına işler',
      (WidgetTester tester) async {
    await ekraniAc(tester);
    await kartiAc(tester);

    final Finder asagi = find.byIcon(Icons.thumb_down_alt_outlined);
    await tester.ensureVisible(asagi);
    await tester.tap(asagi);
    await tester.pump();

    final DailyRecord kayit = DailyRecord.fromMap(
      ortam.kayit.get(gunAnahtari(sabitGun))!,
    );
    expect(
      kayit.bolumGeriBildirimleri.keys.toSet(),
      beklenenOkuma().bolumler.map((OkumaBolumu b) => b.kimlik).toSet(),
    );
    expect(kayit.bolumGeriBildirimleri.values, everyElement(isFalse));
    expect(find.text(TrStrings.anlatmadiTesekkur), findsOneWidget);
    expect(find.byIcon(Icons.thumb_down_alt_rounded), findsOneWidget);
  });

  testWidgets('her "Neden bugün?" çipi yalnızca kendi açıklamasını açar',
      (WidgetTester tester) async {
    final GunlukOkuma beklenen = beklenenOkuma();
    await ekraniAc(tester);
    await kartiAc(tester);

    for (final NedenOgesi neden in beklenen.nedenler) {
      final Finder cip = find.widgetWithText(ActionChip, neden.etiket);
      await tester.ensureVisible(cip);
      await tester.tap(cip);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(neden.aciklama), findsOneWidget);
      for (final NedenOgesi diger in beklenen.nedenler) {
        if (diger.aciklama != neden.aciklama) {
          expect(find.text(diger.aciklama), findsNothing);
        }
      }
      // Sayfayı kapat.
      await tester.tapAt(const Offset(10, 10));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  });

  testWidgets('Paylaş butonu servisi sonuç ve günün başlığıyla çağırır',
      (WidgetTester tester) async {
    final _SahteShareService sahte = _SahteShareService();
    await ekraniAc(
      tester,
      ek: <Override>[shareServiceProvider.overrideWithValue(sahte)],
    );
    await kartiAc(tester);

    await tester.ensureVisible(find.byType(ShareButton));
    await tester.tap(find.byType(ShareButton));
    await tester.pump();

    expect(sahte.paylasilanlar.single.gun, sabitGun);
    expect(sahte.basliklar.single, beklenenOkuma().baslik);
  });
}

/// Paylaşımı kaydeden sahte servis (gerçek plugin çağrısı yapılmaz).
class _SahteShareService extends ShareService {
  /// paylas ile gelen sonuçlar.
  final List<LuckResult> paylasilanlar = <LuckResult>[];

  /// paylas ile gelen başlıklar.
  final List<String?> basliklar = <String?>[];

  @override
  Future<void> paylas({required LuckResult sonuc, String? baslik}) async {
    paylasilanlar.add(sonuc);
    basliklar.add(baslik);
  }
}
