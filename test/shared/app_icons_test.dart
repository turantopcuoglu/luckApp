import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/shared/widgets/app_icons.dart';

void main() {
  /// Repodaki tüm elle yazılmış SVG asset'leri.
  const List<String> svgDosyalari = <String>[
    'assets/svg/kategori_kalp.svg',
    'assets/svg/kategori_para.svg',
    'assets/svg/kategori_yaprak.svg',
    'assets/svg/kategori_zar.svg',
    'assets/svg/kategori_sosyal.svg',
    'assets/svg/arka_plan_yildizlar.svg',
    'assets/svg/bos_durum_kristal_kure.svg',
    'assets/svg/app_icon_yonca.svg',
  ];

  test('her SVG dosyası mevcut ve açıklama yorumuyla başlıyor', () {
    for (final String yol in svgDosyalari) {
      final File dosya = File(yol);
      expect(dosya.existsSync(), isTrue, reason: '$yol bulunamadı');
      expect(
        dosya.readAsStringSync().trimLeft().startsWith('<!--'),
        isTrue,
        reason: '$yol açıklama yorumuyla başlamalı (plan Session 4)',
      );
    }
  });

  testWidgets('her SVG flutter_svg tarafından hatasız parse edilip çizilir',
      (WidgetTester tester) async {
    for (final String yol in svgDosyalari) {
      final String icerik = File(yol).readAsStringSync();
      // SvgPicture.string senkron parse eder; bozuk SVG burada
      // exception olarak yüzeye çıkar ve testi kırar.
      await tester.pumpWidget(
        MaterialApp(home: SvgPicture.string(icerik)),
      );
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: '$yol render sırasında hata verdi',
      );
    }
  });

  testWidgets('AppIcons.kategori her kategori için widget üretir',
      (WidgetTester tester) async {
    for (final LuckCategory kategori in LuckCategory.values) {
      await tester.pumpWidget(
        MaterialApp(home: AppIcons.kategori(kategori)),
      );
      expect(find.byType(SvgPicture), findsOneWidget);
    }
  });
}
