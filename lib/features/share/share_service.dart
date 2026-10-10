import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/dil_providers.dart';
import 'arac_story_card.dart';
import 'paylasim_temasi.dart';
import 'share_config.dart';
import 'story_card.dart';

/// [ShareService] örneğini sağlar (testte sahtesiyle override edilir).
final Provider<ShareService> shareServiceProvider = Provider<ShareService>(
  (Ref ref) => ShareService(metinler: ref.watch(arayuzMetinleriProvider)),
);

/// Story kartını off-screen PNG'ye çevirip sistem paylaşım menüsüne
/// veren servis.
class ShareService {
  /// Kartları ve paylaşım metnini [metinler] dilinde üretir.
  ShareService({required this.metinler});

  /// Kart ve paylaşım metinlerinin dili (uygulama dili).
  final AppLocalizations metinler;

  /// Günün [sonuc]unu (ve varsa kişisel [baslik]ını) seçilen [tema]
  /// arka planıyla story kartı olarak paylaşır; [skoruGizle] açıksa skor
  /// ve kategori puanları karta yazılmaz.
  Future<void> paylas({
    required LuckResult sonuc,
    String? baslik,
    PaylasimTemasi tema = PaylasimTemasi.gece,
    bool skoruGizle = false,
  }) async {
    final ui.Image zemin = await gorselCoz(tema.gorsel);
    try {
      await gorselPaylas(
        kart: StoryCard(
          sonuc: sonuc,
          metinler: metinler,
          baslik: baslik,
          skoruGizle: skoruGizle,
          arkaPlan: RawImage(image: zemin, fit: BoxFit.cover),
        ),
        metin: metinler.paylasimMetni,
        dosyaAdi: ShareConfig.dosyaAdi,
      );
    } finally {
      zemin.dispose();
    }
  }

  /// Bir Keşfet aracı sonucunu (gece temalı) story kartı olarak paylaşır.
  Future<void> aracPaylas(AracPaylasimi paylasim) async {
    final ui.Image zemin = await gorselCoz(PaylasimTemasi.gece.gorsel);
    try {
      await gorselPaylas(
        kart: AracStoryCard(
          paylasim: paylasim,
          metinler: metinler,
          arkaPlan: RawImage(image: zemin, fit: BoxFit.cover),
        ),
        metin: paylasim.paylasimMetni(metinler),
        dosyaAdi: ShareConfig.aracDosyaAdi,
      );
    } finally {
      zemin.dispose();
    }
  }

  /// [yol] asset görselini çözüp `ui.Image` döndürür. Off-screen render
  /// tek karede biter; görselin önceden çözülmüş olması gerekir.
  Future<ui.Image> gorselCoz(String yol) async {
    final ByteData veri = await rootBundle.load(yol);
    final ui.Codec cozucu = await ui.instantiateImageCodec(
      veri.buffer.asUint8List(),
    );
    return (await cozucu.getNextFrame()).image;
  }

  /// [kart]ı PNG'ye çevirip [metin] ile sistem paylaşım menüsüne verir.
  Future<void> gorselPaylas({
    required Widget kart,
    required String metin,
    required String dosyaAdi,
  }) async {
    final Uint8List png = await kartPngUret(kart);
    await Share.shareXFiles(
      <XFile>[XFile.fromData(png, mimeType: 'image/png', name: dosyaAdi)],
      text: metin,
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
