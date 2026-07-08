import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/features/daily_luck/tr_strings.dart';
import 'package:kader/features/share/share_config.dart';
import 'package:kader/features/share/share_service.dart';
import 'package:kader/features/share/share_strings.dart';
import 'package:kader/features/share/story_card.dart';

void main() {
  final LuckResult sonuc = const LuckEngine().hesapla(
    kullanici: UserSeed.fromIsim(
      isim: 'Turan',
      dogumTarihi: DateTime(1990, 5, 15),
    ),
    gun: DateTime(2026, 7, 6),
  );

  testWidgets('StoryCard skor, tarih, 5 kategori ve markayı gösterir',
      (WidgetTester tester) async {
    // Kart 1080x1920 tasarlandı; test yüzeyi ona ayarlanır.
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StoryCard(sonuc: sonuc),
      ),
    );

    expect(find.text('${sonuc.genelSkor}'), findsWidgets);
    expect(find.text(TrStrings.tarihMetni(sonuc.gun)), findsOneWidget);
    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsOneWidget);
    }
    expect(find.text(ShareStrings.marka), findsOneWidget);
    expect(find.text(ShareStrings.genelSkor), findsOneWidget);
  });

  testWidgets('kilitli kategorilerin skoru story kartına sızmaz',
      (WidgetTester tester) async {
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const Set<LuckCategory> kilitliler = <LuckCategory>{
      LuckCategory.ask,
      LuckCategory.para,
    };
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StoryCard(sonuc: sonuc, kilitliKategoriler: kilitliler),
      ),
    );

    // Her kilitli satırda skor yerine kilit ikonu var.
    expect(
      find.byIcon(Icons.lock_rounded),
      findsNWidgets(kilitliler.length),
    );

    // Kilitsiz içerik hâlâ tam: genel skor ve açık kategori skorları.
    expect(find.text('${sonuc.genelSkor}'), findsWidgets);

    // Kilitli skor metni kartta YOK. (Aynı sayı, görünür bir skorla
    // çakışıyorsa bu iddia atlanır; determinist seed ile stabil.)
    final Set<int> gorunenSkorlar = <int>{
      sonuc.genelSkor,
      for (final LuckCategory k in LuckCategory.values)
        if (!kilitliler.contains(k)) sonuc.kategoriSkorlari[k]!,
    };
    for (final LuckCategory k in kilitliler) {
      final int gizliSkor = sonuc.kategoriSkorlari[k]!;
      if (!gorunenSkorlar.contains(gizliSkor)) {
        expect(
          find.text('$gizliSkor'),
          findsNothing,
          reason: '${k.etiket} skoru paylaşım kartına sızdı',
        );
      }
    }
  });

  testWidgets('kartPngUret 1080x1920 boyutunda geçerli PNG üretir',
      (WidgetTester tester) async {
    // toImage ve PNG kodlama gerçek async işlemlerdir → runAsync.
    await tester.runAsync(() async {
      final ShareService servis = ShareService();
      final List<int> png =
          await servis.kartPngUret(StoryCard(sonuc: sonuc));

      expect(png, isNotEmpty);
      // PNG imzası: 89 50 4E 47.
      expect(png.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);

      // Boyut doğrulaması: gerçekten 1080x1920 mi?
      final ui.Codec cozucu =
          await ui.instantiateImageCodec(Uint8List.fromList(png));
      final ui.FrameInfo kare = await cozucu.getNextFrame();
      expect(kare.image.width, ShareConfig.kartBoyutu.width.toInt());
      expect(kare.image.height, ShareConfig.kartBoyutu.height.toInt());
    });
  });
}
