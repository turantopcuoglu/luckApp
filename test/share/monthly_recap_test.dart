import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/history/aylik_ozet.dart';
import 'package:kader/core/localization/app_dil.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/share/monthly_recap_card.dart';
import 'package:kader/features/share/recap_strings.dart';
import 'package:kader/features/share/share_config.dart';
import 'package:kader/features/share/share_service.dart';

void main() {
  const AylikOzet ozet = AylikOzet(
    yil: 2026,
    ay: 7,
    gunSayisi: 12,
    ortalamaSkor: 63,
    enSansliGun: null,
    enSansliSkor: 94,
    baskinKategori: LuckCategory.para,
    altinGunSayisi: 2,
    enUzunSeri: 5,
  );

  // enSansliGun null olamaz gerçekte; testte somut değerle kurulur.
  final AylikOzet doluOzet = AylikOzet(
    yil: ozet.yil,
    ay: ozet.ay,
    gunSayisi: ozet.gunSayisi,
    ortalamaSkor: ozet.ortalamaSkor,
    enSansliGun: DateTime(2026, 7, 9),
    enSansliSkor: ozet.enSansliSkor,
    baskinKategori: ozet.baskinKategori,
    altinGunSayisi: ozet.altinGunSayisi,
    enUzunSeri: ozet.enUzunSeri,
  );

  testWidgets('MonthlyRecapCard ay başlığı ve öne çıkanları gösterir', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MonthlyRecapCard(ozet: doluOzet, dil: AppDil.tr),
      ),
    );

    expect(
      find.text('${TrStrings.ayAdlari(AppDil.tr)[6]} 2026'),
      findsOneWidget,
    );
    expect(find.text(RecapStrings.ustBaslik(AppDil.tr)), findsOneWidget);
    expect(find.text(RecapStrings.altinGunDegeri(2)), findsOneWidget);
    expect(find.text(RecapStrings.enUzunSeriDegeri(5)), findsOneWidget);
    expect(find.text(LuckCategory.para.etiket(AppDil.tr)), findsOneWidget);
  });

  testWidgets('aylık recap kartı 1080x1920 geçerli PNG üretir', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      final ShareService servis = ShareService();
      final List<int> png = await servis.kartPngUret(
        MonthlyRecapCard(ozet: doluOzet, dil: AppDil.tr),
      );

      expect(png, isNotEmpty);
      expect(png.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);

      final ui.Codec cozucu = await ui.instantiateImageCodec(
        Uint8List.fromList(png),
      );
      final ui.FrameInfo kare = await cozucu.getNextFrame();
      expect(kare.image.width, ShareConfig.kartBoyutu.width.toInt());
      expect(kare.image.height, ShareConfig.kartBoyutu.height.toInt());
    });
  });
}
