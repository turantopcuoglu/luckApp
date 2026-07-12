import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/core/storage/daily_record.dart';
import 'package:kader/features/collection/widgets/kart_minik.dart';
import 'package:kader/features/daily_luck/widgets/category_card.dart';
import 'package:kader/features/daily_luck/widgets/score_ring.dart';

/// Erişilebilirlik (ekran okuyucu) semantics'i + kilitli-skor gizlilik
/// regresyonu. `ensureSemantics()` semantics ağacını açar; etiketler
/// `find.bySemanticsLabel` ile aranır.
void main() {
  const LuckEngine motor = LuckEngine();
  final UserSeed turan = UserSeed.fromIsim(
    isim: 'Turan',
    dogumTarihi: DateTime(1990, 5, 15),
  );

  Future<void> pompala(WidgetTester tester, Widget cocuk) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: Center(child: cocuk))),
    );
    await tester.pump();
  }

  testWidgets('ScoreRing skoru tek anlamlı düğüm olarak okunur',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pompala(tester, const ScoreRing(skor: 85));

    // Kopuk "85" + "GENEL SKOR" değil, birleşik etiket.
    expect(find.bySemanticsLabel('GENEL SKOR: 85 / 100'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('kilitli kategori skoru semantics\'e sızmaz (gizlilik)',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pompala(
      tester,
      const CategoryCard(kategori: LuckCategory.ask, skor: 72, kilitli: true),
    );

    // Hiçbir semantics etiketi gerçek skoru (72) içermemeli.
    expect(find.bySemanticsLabel(RegExp('72')), findsNothing);
    // "kilitli" içeren bir etiket bulunmalı.
    expect(find.bySemanticsLabel(RegExp('kilitli')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('kilidi açık kategori skoru etikette görünür',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pompala(
      tester,
      const CategoryCard(kategori: LuckCategory.ask, skor: 72),
    );

    expect(find.bySemanticsLabel('Aşk: 72 / 100'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('Altın gün koleksiyon kartı etiketi skor + "Altın Gün" içerir',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    final LuckResult temel =
        motor.hesapla(kullanici: turan, gun: DateTime(2026, 7, 6));
    final DailyRecord altinKayit = DailyRecord(
      sonuc: LuckResult(
        gun: DateTime(2026, 7, 6),
        genelSkor: 95,
        kategoriSkorlari: temel.kategoriSkorlari,
        modifiyerler: temel.modifiyerler,
      ),
    );

    await pompala(tester, KartMinik(kayit: altinKayit));

    expect(find.bySemanticsLabel(RegExp('95 / 100')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Altın Gün')), findsOneWidget);
    handle.dispose();
  });
}
