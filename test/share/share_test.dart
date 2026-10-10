import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kader/core/luck_engine/luck_engine.dart';
import 'package:kader/features/share/arac_story_card.dart';
import 'package:kader/features/share/paylasim_temasi.dart';
import 'package:kader/features/share/share_config.dart';
import 'package:kader/features/share/share_service.dart';
import 'package:kader/features/share/story_card.dart';
import 'package:kader/l10n/app_localizations.dart';
import 'package:kader/l10n/app_localizations_en.dart';
import 'package:kader/l10n/tarih_bicimi.dart';

import '../test_ortami.dart';

void main() {
  final LuckResult sonuc = const LuckEngine().hesapla(
    kullanici: UserSeed.fromIsim(
      isim: 'Turan',
      dogumTarihi: DateTime(1990, 5, 15),
    ),
    gun: DateTime(2026, 7, 6),
  );

  // Kart widget testleri MaterialApp'sız çizilir; ay/gün adları için intl
  // tarih verisi elle yüklenir (uygulamada GlobalMaterialLocalizations
  // yükler).
  setUpAll(() async {
    await initializeDateFormatting('tr');
    await initializeDateFormatting('en');
  });

  testWidgets('StoryCard skor, tarih, 5 kategori ve markayı gösterir', (
    WidgetTester tester,
  ) async {
    // Kart 1080x1920 tasarlandı; test yüzeyi ona ayarlanır.
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StoryCard(sonuc: sonuc, metinler: trMetinler),
      ),
    );

    expect(find.text('${sonuc.genelSkor}'), findsWidgets);
    expect(find.text(tarihMetni(trMetinler, sonuc.gun)), findsOneWidget);
    for (final LuckCategory kategori in LuckCategory.values) {
      expect(find.text(kategori.etiket), findsOneWidget);
    }
    expect(find.text(trMetinler.paylasimMarka), findsOneWidget);
    expect(find.text(trMetinler.paylasimGenelSkor), findsOneWidget);
  });

  testWidgets('StoryCard İngilizce metinler ve tarih biçimiyle çizilir', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final AppLocalizations en = AppLocalizationsEn();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StoryCard(sonuc: sonuc, metinler: en),
      ),
    );

    expect(find.text('Monday, July 6, 2026'), findsOneWidget);
    expect(find.text(en.paylasimGenelSkor), findsOneWidget);
    expect(find.text(trMetinler.paylasimGenelSkor), findsNothing);
  });

  testWidgets('StoryCard "skoru gizle" açıkken skor ve puanları yazmaz, '
      'başlığı ortaya alır', (WidgetTester tester) async {
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StoryCard(sonuc: sonuc, metinler: trMetinler, baslik: 'Şefkat Günü', skoruGizle: true),
      ),
    );

    expect(find.text('${sonuc.genelSkor}'), findsNothing);
    expect(find.text(trMetinler.paylasimGenelSkor), findsNothing);
    expect(find.text(LuckCategory.ask.etiket), findsNothing);
    expect(find.text('Şefkat Günü'), findsOneWidget);
    expect(find.text(trMetinler.paylasimMarka), findsOneWidget);
  });

  testWidgets('her paylaşım teması görseli çözülüp kartla PNG üretilir', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      final ShareService servis = ShareService(metinler: trMetinler);
      for (final PaylasimTemasi tema in PaylasimTemasi.values) {
        final ui.Image zemin = await servis.gorselCoz(tema.gorsel);
        expect(zemin.width, greaterThan(0), reason: tema.name);
        final List<int> png = await servis.kartPngUret(
          StoryCard(
            sonuc: sonuc,
            metinler: trMetinler,
            arkaPlan: RawImage(image: zemin, fit: BoxFit.cover),
          ),
        );
        expect(png.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
        zemin.dispose();
      }
    });
  });

  testWidgets('kartPngUret 1080x1920 boyutunda geçerli PNG üretir', (
    WidgetTester tester,
  ) async {
    // toImage ve PNG kodlama gerçek async işlemlerdir → runAsync.
    await tester.runAsync(() async {
      final ShareService servis = ShareService(metinler: trMetinler);
      final List<int> png = await servis.kartPngUret(StoryCard(sonuc: sonuc, metinler: trMetinler));

      expect(png, isNotEmpty);
      // PNG imzası: 89 50 4E 47.
      expect(png.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);

      // Boyut doğrulaması: gerçekten 1080x1920 mi?
      final ui.Codec cozucu = await ui.instantiateImageCodec(
        Uint8List.fromList(png),
      );
      final ui.FrameInfo kare = await cozucu.getNextFrame();
      expect(kare.image.width, ShareConfig.kartBoyutu.width.toInt());
      expect(kare.image.height, ShareConfig.kartBoyutu.height.toInt());
    });
  });
  const AracPaylasimi numara = AracPaylasimi(
    ustEtiket: 'NUMARA ANALİZİ',
    baslik: '0532 123 45 67',
    sayi: '11',
    sayiEtiketi: 'Usta İlham',
    metin: 'Bu numara usta sayı 11 enerjisini taşır.',
  );

  testWidgets('AracStoryCard etiket, başlık, dev sayı, metin, marka ve '
      'daveti gösterir', (WidgetTester tester) async {
    tester.view.physicalSize = ShareConfig.kartBoyutu;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AracStoryCard(paylasim: numara, metinler: trMetinler),
      ),
    );

    for (final String m in <String>[
      numara.ustEtiket,
      numara.baslik,
      numara.sayi,
      numara.sayiEtiketi,
      numara.metin,
      trMetinler.paylasimMarka,
      trMetinler.paylasimAracDavet,
    ]) {
      expect(find.text(m), findsOneWidget, reason: m);
    }
  });

  test('paylaşım metni başlık, etiket, sayı ve daveti içerir', () {
    expect(
      numara.paylasimMetni(trMetinler),
      '0532 123 45 67 · Usta İlham 11\n${trMetinler.paylasimAracDavet}',
    );
  });

  testWidgets('AracStoryCard uzun metinle de 1080x1920 PNG üretir', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      final List<int> png = await ShareService(metinler: trMetinler).kartPngUret(
        AracStoryCard(
          metinler: trMetinler,
          paylasim: AracPaylasimi(
            ustEtiket: numara.ustEtiket,
            baslik: 'Çok Uzun Bir Ad Soyad Örneği İçin Şimşek Ünal Öztürk',
            sayi: numara.sayi,
            sayiEtiketi: numara.sayiEtiketi,
            metin: List<String>.filled(40, 'Uzun bir cümle.').join(' '),
          ),
        ),
      );
      final ui.Codec cozucu = await ui.instantiateImageCodec(
        Uint8List.fromList(png),
      );
      final ui.FrameInfo kare = await cozucu.getNextFrame();
      expect(kare.image.width, ShareConfig.kartBoyutu.width.toInt());
      expect(kare.image.height, ShareConfig.kartBoyutu.height.toInt());
    });
  });
}
