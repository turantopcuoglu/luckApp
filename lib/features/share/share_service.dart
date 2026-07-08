import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/luck_engine/luck_engine.dart';
import 'share_config.dart';
import 'share_strings.dart';
import 'story_card.dart';

/// [ShareService] örneğini sağlar (testte sahtesiyle override edilir).
final Provider<ShareService> shareServiceProvider =
    Provider<ShareService>((Ref ref) => ShareService());

/// Story kartını off-screen PNG'ye çevirip sistem paylaşım menüsüne
/// veren servis.
class ShareService {
  /// Varsayılan kurucu.
  ShareService();

  /// Günün [sonuc]unu story kartı olarak paylaşır.
  ///
  /// [kilitliKategoriler]: premium kilidi altındaki kategoriler;
  /// skorları karta çizilmez (gizlilik — kilitli içerik sızmaz).
  Future<void> paylas({
    required LuckResult sonuc,
    Set<LuckCategory> kilitliKategoriler = const <LuckCategory>{},
  }) async {
    final Uint8List png = await kartPngUret(
      StoryCard(sonuc: sonuc, kilitliKategoriler: kilitliKategoriler),
    );
    await Share.shareXFiles(
      <XFile>[
        XFile.fromData(
          png,
          mimeType: 'image/png',
          name: ShareConfig.dosyaAdi,
        ),
      ],
      text: ShareStrings.paylasimMetni,
    );
  }

  /// [kart] widget'ını ekrana koymadan 1080x1920 PNG'ye çevirir.
  ///
  /// Kendi render ağacını kurar (RenderView + PipelineOwner +
  /// BuildOwner): widget hiçbir zaman ekrana çizilmez, layout ve
  /// boyama tamamen off-screen yapılır (plan Session 7, madde 2).
  /// Public ve UI'dan bağımsızdır ki tek başına test edilebilsin.
  Future<Uint8List> kartPngUret(Widget kart) async {
    final ui.FlutterView goruntu =
        ui.PlatformDispatcher.instance.implicitView!;
    final RenderRepaintBoundary sinir = RenderRepaintBoundary();

    // Kök render nesnesi: story kartı boyutuna sıkıştırılmış sahne.
    final RenderView kokGorunum = RenderView(
      view: goruntu,
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(ShareConfig.kartBoyutu),
        devicePixelRatio: 1,
      ),
      child: RenderPositionedBox(child: sinir),
    );

    final PipelineOwner boruHatti = PipelineOwner()..rootNode = kokGorunum;
    kokGorunum.prepareInitialFrame();

    // Widget ağacı, tema bağımsız çalışsın diye yalnızca yön sarmalanır
    // (StoryCard stillerini kendi sabitlerinden alır).
    final BuildOwner insaSahibi = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> eleman =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: sinir,
      child: Directionality(textDirection: TextDirection.ltr, child: kart),
    ).attachToRenderTree(insaSahibi);

    insaSahibi
      ..buildScope(eleman)
      ..finalizeTree();
    boruHatti
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image resim = await sinir.toImage();
    final ByteData? veri =
        await resim.toByteData(format: ui.ImageByteFormat.png);
    return veri!.buffer.asUint8List();
  }
}
