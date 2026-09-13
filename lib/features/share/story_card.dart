import 'package:flutter/material.dart';
import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/cosmic_config.dart';
import '../daily_luck/today_strings.dart';
import '../daily_luck/tr_strings.dart';
import 'share_config.dart';
import 'share_strings.dart';
import 'story_style.dart';

/// Tek sahne, okunaklı canlı metin ve gerçek kayıttan üretilen 9:16 Story.
class StoryCard extends StatelessWidget {
  /// Kilitli veya kullanıcının gizlediği değerleri PNG'ye de eklemez.
  const StoryCard({
    required this.sonuc,
    required this.dil,
    this.kilitliKategoriler = const <LuckCategory>{},
    this.style = StoryStyle.portal,
    this.hideScore = false,
    super.key,
  });

  /// Yeniden hesaplanmayan günlük kayıt.
  final LuckResult sonuc;

  /// Paylaşım dili.
  final AppDil dil;

  /// Yetkisi olmayan kategoriler.
  final Set<LuckCategory> kilitliKategoriler;

  /// Seçilen sahne.
  final StoryStyle style;

  /// Genel skor ve bütün kategori değerlerini kaldırır.
  final bool hideScore;

  /// Skora ait tipografik vurgu.
  CosmicTone get tone => CosmicTone.fromScore(sonuc.genelSkor);

  /// Off-screen yakalamadan önce çözülecek tek sahne.
  String get sceneAsset => style.sceneAsset;

  /// Önizleme ve PNG aynı görsel anahtarını kullanır.
  ImageProvider<Object> get sceneProvider =>
      ResizeImage(AssetImage(sceneAsset), width: ShareConfig.captureImageWidth);

  TextStyle _text(
    double size, {
    bool serif = false,
    Color color = Colors.white,
  }) => TextStyle(
    fontFamily: serif ? AppTypography.headingFamily : AppTypography.bodyFamily,
    fontSize: size,
    height: 1.2,
    color: color,
    shadows: const <Shadow>[
      Shadow(color: Color(0xE6000815), blurRadius: 16),
      Shadow(color: Color(0xFF000711), offset: Offset(0, 2), blurRadius: 4),
    ],
  );

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: const MediaQueryData(
      size: ShareConfig.kartBoyutu,
      textScaler: TextScaler.noScaling,
    ),
    child: SizedBox.fromSize(
      size: ShareConfig.kartBoyutu,
      child: ColoredBox(
        color: const Color(0xFF041428),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: sceneProvider,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0x00041020),
                    Color(0xA6041020),
                    Color(0x33041020),
                    Color(0xE6041020),
                  ],
                  stops: <double>[0, .42, .65, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShareConfig.kenarBoslugu,
                ShareConfig.storySafeTop,
                ShareConfig.kenarBoslugu,
                ShareConfig.storySafeBottom,
              ),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 3),
                  Text(
                    hideScore
                        ? dil.sec('Bugünün kartı', 'Today’s card')
                        : ShareStrings.genelSkor(dil),
                    style: _text(ShareConfig.skorEtiketPunto, serif: true),
                  ),
                  if (!hideScore)
                    Text(
                      '${sonuc.genelSkor}',
                      style: _text(
                        ShareConfig.skorPunto,
                        serif: true,
                        color: CosmicConfig.goldLight,
                      ),
                    ),
                  const SizedBox(height: ShareConfig.elementGap),
                  Text(
                    TrStrings.tarihMetni(dil, sonuc.gun),
                    style: _text(ShareConfig.tarihPunto),
                  ),
                  const Spacer(flex: 3),
                  Text(
                    TodayStrings.scoreTitle(dil, sonuc.genelSkor),
                    textAlign: TextAlign.center,
                    style: _text(ShareConfig.quoteSize, serif: true),
                  ),
                  const SizedBox(height: ShareConfig.sectionGap),
                  if (!hideScore)
                    Row(
                      children: <Widget>[
                        for (final LuckCategory category in LuckCategory.values)
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    category.etiket(dil),
                                    style: _text(ShareConfig.categoryLabelSize),
                                  ),
                                ),
                                const SizedBox(height: ShareConfig.elementGap),
                                if (kilitliKategoriler.contains(category))
                                  Icon(
                                    Icons.lock_rounded,
                                    size: ShareConfig.kilitIkonBoyutu,
                                    color: CosmicConfig.goldLight,
                                    semanticLabel: ShareStrings.locked(dil),
                                  )
                                else
                                  Text(
                                    '${sonuc.kategoriSkorlari[category] ?? 0}',
                                    style: _text(
                                      ShareConfig.kategoriPunto,
                                      color: CosmicConfig.goldLight,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: ShareConfig.sectionGap),
                  const Icon(
                    Icons.nightlight_round,
                    size: ShareConfig.markaPunto,
                    color: CosmicConfig.goldLight,
                  ),
                  Text(
                    ShareStrings.marka,
                    style: _text(
                      ShareConfig.markaPunto,
                      serif: true,
                      color: CosmicConfig.goldLight,
                    ),
                  ),
                  const SizedBox(height: ShareConfig.elementGap),
                  Text(
                    TodayStrings.scoreNote(dil),
                    textAlign: TextAlign.center,
                    style: _text(ShareConfig.noteSize),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
