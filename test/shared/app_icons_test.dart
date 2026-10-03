import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/shared/widgets/app_icons.dart';

void main() {
  /// Repodaki elle yazılmış SVG asset'leri.
  const List<String> svgDosyalari = <String>[
    'assets/svg/bildirim_kapi.svg',
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

  test('her kategorinin glif dosyası var', () {
    for (final LuckCategory kategori in LuckCategory.values) {
      final String yol = AppIcons.kategoriDosyalari[kategori]!;
      expect(File(yol).existsSync(), isTrue, reason: '$yol bulunamadı');
    }
  });

  testWidgets('AppIcons.kategori her kategori için boyanmış glif üretir',
      (WidgetTester tester) async {
    for (final LuckCategory kategori in LuckCategory.values) {
      await tester.pumpWidget(
        MaterialApp(home: AppIcons.kategori(kategori)),
      );
      final Image glif = tester.widget<Image>(find.byType(Image));
      expect(glif.colorBlendMode, BlendMode.srcIn);
    }
  });
}
