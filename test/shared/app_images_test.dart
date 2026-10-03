import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/shared/widgets/app_images.dart';

void main() {
  test('AppImages\'taki her yol assets/images altında mevcut', () {
    final List<String> yollar = <String>[
      AppImages.kartArkaYuzuMuhursuz,
      AppImages.muhur,
      AppImages.sahneKapali,
      AppImages.sahneYuksek,
      AppImages.sahneOrtaKapili,
      AppImages.sahneDusuk,
      AppImages.onPlanSutunlar,
      AppImages.parilti,
      AppImages.sahneAksam,
      AppImages.mermerDoku,
      AppImages.hataDurumu,
      AppImages.sahneOnboarding,
      AppImages.astrolabCekirdek,
      AppImages.astrolabHalkalar,
      AppImages.kureCam,
      AppImages.kureSivi,
      AppImages.kureCerceve,
      AppImages.kartHazir,
      AppImages.paylasimGece,
      AppImages.paylasimIsik,
      AppImages.paylasimMor,
      AppImages.sahneProfil,
      AppImages.madalyonGunes,
      AppImages.madalyonAy,
      AppImages.madalyonYukselen,
      for (final Burc b in Burc.values) AppImages.burc(b.name),
      for (final AyEvresi e in AyEvresi.values) AppImages.ayEvresi(e.index),
      for (int yil = 1; yil <= 9; yil++) AppImages.yilAfisi(yil),
      AppImages.raporKitap,
      AppImages.kilit,
      AppImages.sayiMadalyonu,
      AppImages.uyumBos,
      AppImages.uyumGuclu,
      AppImages.uyumDengeli,
      AppImages.uyumGelistiren,
      AppImages.aracIsim,
      AppImages.aracNumara,
      AppImages.aracBebek,
      AppImages.cerceveNormal,
      AppImages.cerceveNadir,
    ];
    for (final String yol in yollar) {
      expect(File(yol).existsSync(), isTrue, reason: '$yol bulunamadı');
    }
  });

  test('assets/images altında kaynak PNG kalmadı (paket boyutu)', () {
    final List<String> pngler = Directory('assets/images')
        .listSync()
        .map((FileSystemEntity d) => d.path)
        .where((String p) => p.toLowerCase().endsWith('.png'))
        .toList();
    expect(pngler, isEmpty, reason: 'İşlenmemiş PNG: $pngler');
  });
}
