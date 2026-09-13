import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/cosmic_config.dart';
import 'card_reveal_motion.dart';
import 'result_entry_motion.dart';

/// Başlık ve kartın arkasındaki tek sahne; alttaki kontrollere kadar devam eder.
/// Gerçek içerik boyutu sahneyi belirler, sabit ekran görüntüsü oranı değil.
class TodaySceneStage extends StatelessWidget {
  /// Kapalı/açılış halinde sonuçtan bağımsız [opening] kullanılır.
  const TodaySceneStage({
    required this.header,
    required this.stage,
    this.opened = false,
    this.tone = CosmicTone.sealed,
    this.opening = const AlwaysStoppedAnimation<double>(0),
    super.key,
  });

  /// İçeriğin üstündeki gerçek ve ölçeklenebilir marka/tarih/selamlama.
  final Widget header;

  /// Kapalı kartın kanatları veya açılmış skor; ayrı bir bitmap alanı değildir.
  final Widget stage;

  /// Yalnız başarılı kalıcı yazımdan sonra true olur.
  final bool opened;

  /// Genel skorun açıldıktan sonra kullanılabilen renk ailesi.
  final CosmicTone tone;

  /// Kart açılışı ile ortak saat; ikinci koreografi başlatılmaz.
  final Animation<double> opening;

  @override
  Widget build(BuildContext context) {
    final Widget scene = opened
        ? ResultSceneBlend(
            base: const _SanctuaryImage(asset: CosmicConfig.sanctuaryRadiant),
            child: _SanctuaryImage(
              asset: tone == CosmicTone.calm
                  ? CosmicConfig.sanctuaryTwilight
                  : CosmicConfig.sanctuaryRadiant,
            ),
          )
        : Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const _SanctuaryImage(asset: CosmicConfig.sanctuarySealed),
              AnimatedBuilder(
                animation: opening,
                child: const _SanctuaryImage(
                  asset: CosmicConfig.sanctuaryRadiant,
                ),
                builder: (BuildContext context, Widget? child) => Opacity(
                  opacity: RevealFrame.at(opening.value).sceneOpacity,
                  child: child,
                ),
              ),
            ],
          );
    return Stack(
      key: const ValueKey<String>('today-continuous-scene'),
      clipBehavior: Clip.none,
      children: <Widget>[
        // Aynı resim başlığın, kartın ve alt kontrollerin arkasındadır.
        // Hero sınırında hiçbir clip/gradient yoktur.
        Positioned(
          top: -AppSpacing.md,
          left: -AppSpacing.md,
          right: -AppSpacing.md,
          bottom: -CosmicConfig.sceneUnderlayReach,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: ShaderMask(
                  key: const ValueKey<String>('sanctuary-bottom-only'),
                  shaderCallback: CosmicConfig.sanctuaryEdgeBlend.createShader,
                  blendMode: BlendMode.dstIn,
                  child: scene,
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[header, stage],
        ),
      ],
    );
  }
}

class _SanctuaryImage extends StatelessWidget {
  const _SanctuaryImage({required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) => Image.asset(
      asset,
      key: ValueKey<String>(asset),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      cacheWidth: CosmicConfig.sanctuaryDecodeWidth(
        constraints.maxWidth,
        MediaQuery.devicePixelRatioOf(context),
      ),
      excludeFromSemantics: true,
      filterQuality: FilterQuality.medium,
    ),
  );
}
