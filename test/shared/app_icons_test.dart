import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/shared/widgets/app_icons.dart';

void main() {
  /// Repodaki tüm elle yazılmış SVG asset'lerini ada göre sıralar.
  ///
  /// Listeyi elle tutmak yerine dizini tarar; yeni üretim asset'i teste
  /// eklenmeden sessizce repoya giremez.
  List<String> svgDosyalari() =>
      Directory('assets/svg')
          .listSync()
          .whereType<File>()
          .where((File dosya) => dosya.path.endsWith('.svg'))
          .map((File dosya) => dosya.path.replaceAll('\\', '/'))
          .toList()
        ..sort();

  /// Kart açıldığında kullanılacak beş üretim illüstrasyonu.
  const List<String> arketipDosyalari = <String>[
    'assets/images/archetypes/archetype_akis.webp',
    'assets/images/archetypes/archetype_bag.webp',
    'assets/images/archetypes/archetype_uretim.webp',
    'assets/images/archetypes/archetype_cesaret.webp',
    'assets/images/archetypes/archetype_denge.webp',
  ];

  /// Koleksiyonda kullanılacak on iki tam sahne Nadir İşaret kartı.
  const List<String> nadirIsaretDosyalari = <String>[
    'assets/images/rare_signs/rare_acik_kapi.webp',
    'assets/images/rare_signs/rare_kesisen_yollar.webp',
    'assets/images/rare_signs/rare_sessiz_tohum.webp',
    'assets/images/rare_signs/rare_ucan_not.webp',
    'assets/images/rare_signs/rare_dengeli_tas.webp',
    'assets/images/rare_signs/rare_yeni_patika.webp',
    'assets/images/rare_signs/rare_geri_donen_serit.webp',
    'assets/images/rare_signs/rare_kucuk_kopru.webp',
    'assets/images/rare_signs/rare_acik_pencere.webp',
    'assets/images/rare_signs/rare_beklenmedik_durak.webp',
    'assets/images/rare_signs/rare_yan_yana_izler.webp',
    'assets/images/rare_signs/rare_parlak_yol.webp',
  ];

  test('her SVG dosyası mevcut ve açıklama yorumuyla başlıyor', () {
    for (final String yol in svgDosyalari()) {
      final File dosya = File(yol);
      expect(dosya.existsSync(), isTrue, reason: '$yol bulunamadı');
      expect(
        dosya.readAsStringSync().trimLeft().startsWith('<!--'),
        isTrue,
        reason: '$yol açıklama yorumuyla başlamalı (plan Session 4)',
      );
    }
  });

  testWidgets('her SVG flutter_svg tarafından hatasız parse edilip çizilir', (
    WidgetTester tester,
  ) async {
    for (final String yol in svgDosyalari()) {
      final String icerik = File(yol).readAsStringSync();
      // SvgPicture.string senkron parse eder; bozuk SVG burada
      // exception olarak yüzeye çıkar ve testi kırar.
      await tester.pumpWidget(MaterialApp(home: SvgPicture.string(icerik)));
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: '$yol render sırasında hata verdi',
      );
    }
  });

  test('arketip WebP dosyaları mevcut, çözülebilir ve 4:3 oranında', () async {
    for (final String yol in arketipDosyalari) {
      final File dosya = File(yol);
      expect(dosya.existsSync(), isTrue, reason: '$yol bulunamadı');

      final ui.Codec codec = await ui.instantiateImageCodec(
        await dosya.readAsBytes(),
      );
      final ui.FrameInfo kare = await codec.getNextFrame();
      final ui.Image resim = kare.image;
      expect(resim.width * 3, resim.height * 4, reason: '$yol 4:3 olmalı');
      resim.dispose();
      codec.dispose();
    }
  });

  test(
    'Nadir İşaret WebP dosyaları mevcut, çözülebilir ve 5:7 oranında',
    () async {
      expect(nadirIsaretDosyalari, hasLength(12));

      for (final String yol in nadirIsaretDosyalari) {
        final File dosya = File(yol);
        expect(dosya.existsSync(), isTrue, reason: '$yol bulunamadı');

        final ui.Codec codec = await ui.instantiateImageCodec(
          await dosya.readAsBytes(),
        );
        final ui.FrameInfo kare = await codec.getNextFrame();
        final ui.Image resim = kare.image;
        expect(resim.width * 7, resim.height * 5, reason: '$yol 5:7 olmalı');
        resim.dispose();
        codec.dispose();
      }
    },
  );

  testWidgets('AppIcons.kategori her kategori için widget üretir', (
    WidgetTester tester,
  ) async {
    for (final LuckCategory kategori in LuckCategory.values) {
      await tester.pumpWidget(MaterialApp(home: AppIcons.kategori(kategori)));
      expect(find.byType(SvgPicture), findsOneWidget);
    }
  });
}
