import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/content/experience_dimension.dart';
import '../../../core/localization/app_dil.dart';
import '../../../core/luck_engine/luck_category.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/cosmic_config.dart';
import '../../../shared/widgets/cosmic_scene.dart';
import '../../../shared/widgets/kader_button.dart';
import '../../../shared/widgets/kader_card.dart';
import '../../settings/settings_strings.dart';
import '../today_strings.dart';
import 'card_reveal_motion.dart';
import 'category_jewel_surface.dart';
import 'result_entry_motion.dart';
import 'today_scene_stage.dart';

/// Görünüm sınırından önce maskelenmiş kategori; kilitli skor yalnız null.
class TodayDimensionData {
  /// Ham kilitli sayı bu nesneye aktarılmaz.
  const TodayDimensionData({required this.dimension, required this.score});

  /// Depolamayı değiştirmeyen deneyim eşlemesi.
  final ExperienceDimension dimension;

  /// Yetki varsa sayı, yoksa null.
  final int? score;
}

/// Sonuç bilgisi almayan, merkezli kapalı kart ve tek açma eylemi.
class TodayConcealedCard extends StatelessWidget {
  /// Kalıcı yazım sırasında buton kilitlidir.
  const TodayConcealedCard({
    required this.language,
    required this.onOpen,
    this.card,
    this.busy = false,
    this.error = false,
    this.statusLabel,
    this.header,
    this.sceneAnimation = const AlwaysStoppedAnimation<double>(0),
    super.key,
  });

  /// Aktif dil.
  final AppDil language;

  /// Açma/tekrar deneme.
  final VoidCallback onOpen;

  /// İmza hareketi.
  final Widget? card;

  /// Açılış/yazım devam ediyor.
  final bool busy;

  /// Kayıt hatası.
  final bool error;

  /// İşlem aşaması.
  final String? statusLabel;

  /// Verilirse sahne, selamlamadan alt kontrollere kadar ortak arka plandır.
  final Widget? header;

  /// Menteşelerle aynı saat; gizli skora bağlı değildir.
  final Animation<double> sceneAnimation;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      if (header != null)
        TodaySceneStage(
          header: header!,
          opening: sceneAnimation,
          stage: Center(child: card ?? const CosmicCardFace()),
        )
      else
        Center(child: card ?? const CosmicCardFace()),
      const SizedBox(height: AppSpacing.md),
      Text(
        TodayStrings.ready(language),
        style: Theme.of(context).textTheme.headlineSmall,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(TodayStrings.invitation(language), textAlign: TextAlign.center),
      const SizedBox(height: AppSpacing.lg),
      if (error) ...<Widget>[
        Semantics(
          liveRegion: true,
          child: Text(
            TodayStrings.revealError(language),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
      Semantics(
        liveRegion: busy,
        child: KaderButton(
          cosmic: true,
          label: busy
              ? statusLabel!
              : error
              ? TodayStrings.retry(language)
              : TodayStrings.open(language),
          onPressed: busy ? null : onOpen,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      _CategoryGrid(
        children: <Widget>[
          for (final LuckCategory category in _categoryOrder)
            _CategorySurface(category: category, language: language),
        ],
      ),
      const SizedBox(height: AppSpacing.lg),
      Text(
        SettingsStrings.eglenceAmacli(language),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.mutedOnInk),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

const List<LuckCategory> _categoryOrder = <LuckCategory>[
  LuckCategory.ask,
  LuckCategory.para,
  LuckCategory.saglik,
  LuckCategory.sosyal,
  LuckCategory.risk,
];
Color _categoryColor(LuckCategory category) =>
    CategoryJewelPalette.of(category).accent;
Widget _categoryIcon(LuckCategory category) => category == LuckCategory.para
    ? const CustomPaint(
        size: Size.square(CosmicConfig.categoryIconSize),
        painter: _CoinStackPainter(),
      )
    : Icon(
        switch (category) {
          LuckCategory.ask => Icons.favorite_rounded,
          LuckCategory.para => Icons.monetization_on_rounded,
          LuckCategory.saglik => Icons.spa_rounded,
          LuckCategory.sosyal => Icons.groups_rounded,
          LuckCategory.risk => Icons.bolt_rounded,
        },
        color: _categoryColor(category),
        size: CosmicConfig.categoryIconSize,
      );

class _CoinStackPainter extends CustomPainter {
  const _CoinStackPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CosmicConfig.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .065;
    final double left = size.width * .16;
    final double right = size.width * .84;
    for (final double row in <double>[.75, .56, .37]) {
      final Rect oval = Rect.fromLTRB(
        left,
        size.height * (row - .11),
        right,
        size.height * (row + .11),
      );
      canvas.drawArc(oval, 0, 3.141592653589793, false, paint);
      canvas.drawLine(
        Offset(left, size.height * (row - .15)),
        Offset(left, size.height * row),
        paint,
      );
      canvas.drawLine(
        Offset(right, size.height * (row - .15)),
        Offset(right, size.height * row),
        paint,
      );
    }
    canvas.drawOval(
      Rect.fromLTRB(left, size.height * .12, right, size.height * .36),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CoinStackPainter oldDelegate) => false;
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool large =
          MediaQuery.textScalerOf(context).scale(14) >
          CosmicConfig.largeTextThreshold;
      final int columns = large
          ? 2
          : constraints.maxWidth >= CosmicConfig.categoryFiveColumnWidth
          ? 5
          : 3;
      final double width =
          (constraints.maxWidth - AppSpacing.xs * (columns - 1)) / columns;
      return Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          for (final Widget child in children)
            SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class _CategorySurface extends StatelessWidget {
  const _CategorySurface({
    required this.category,
    required this.language,
    this.revealed = false,
    this.score,
    this.onTap,
  });
  final LuckCategory category;
  final AppDil language;
  final bool revealed;
  final int? score;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final Color color = _categoryColor(category);
    return CategoryJewelSurface(
      category: category,
      revealed: revealed,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CosmicConfig.categoryTileHeight,
          minWidth: AppLayout.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _categoryIcon(category),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.etiket(language),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              if (revealed && score == null)
                SizedBox(
                  height: CosmicConfig.categoryScoreSize,
                  child: Icon(Icons.lock_outline_rounded, color: color),
                )
              else
                Text(
                  revealed ? '$score' : '–',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFamily,
                    fontSize: CosmicConfig.categoryScoreSize,
                    height: 1,
                    color: revealed ? color : AppColors.mutedOnInk,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renkli dikdörtgen kategori; kilitli verinin sayısını veya oranını kurmaz.
class TodayDimensionTile extends StatelessWidget {
  /// Yalnız maskelenmiş veri alır.
  const TodayDimensionTile({
    required this.data,
    required this.language,
    required this.onTap,
    super.key,
  });

  /// Güvenli sunum.
  final TodayDimensionData data;

  /// Aktif dil.
  final AppDil language;

  /// Detay veya erişim sayfası.
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final LuckCategory category = data.dimension.kategori;
    final String label = category.etiket(language);
    return Semantics(
      label: data.score == null
          ? '$label, ${TodayStrings.locked(language)}'
          : '$label, ${data.score}/100',
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: _CategorySurface(
        category: category,
        language: language,
        revealed: true,
        score: data.score,
        onTap: onTap,
      ),
    );
  }
}

/// Açık skor için metinden ayrı kapı/ışık katmanları; sayı gerçek Flutter metni.
class CosmicScoreHero extends ConsumerWidget {
  /// Yalnız açılmış genel skoru kabul eder.
  const CosmicScoreHero({
    required this.score,
    required this.language,
    this.embeddedScene = false,
    super.key,
  });

  /// Herkese açık genel skor.
  final int score;

  /// Aktif dil.
  final AppDil language;

  /// Sahne başlıkla ortak katmanda çizildiğinde yerel bitmap kurulmaz.
  final bool embeddedScene;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CosmicTone tone = CosmicTone.fromScore(score);
    final TextTheme text = Theme.of(context).textTheme;
    return SizedBox(
      height: CosmicConfig.heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[
          if (!embeddedScene)
            ResultSceneBlend(
              base: const CosmicPortal(),
              child: CardRevealMotion(
                animation: const AlwaysStoppedAnimation<double>(1),
                reducedMotion: false,
                tone: tone,
              ),
            ),
          if (embeddedScene)
            CardRevealMotion(
              animation: const AlwaysStoppedAnimation<double>(1),
              reducedMotion: false,
              tone: tone,
              showScene: false,
            ),
          CosmicAmbient(
            enabled: ref.watch(cosmicMotionEnabledProvider),
            tone: tone,
            intensity: CosmicConfig.stageIntensity,
            ribbons: true,
          ),
          const DecoratedBox(
            key: ValueKey<String>('score-contrast-scrim'),
            decoration: BoxDecoration(gradient: CosmicConfig.scoreHalo),
          ),
          Positioned(
            top: CosmicConfig.heroHeight * CosmicConfig.scoreTopRatio,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            child: ResultContentFade(
              child: Column(
                children: <Widget>[
                  Semantics(
                    label: TodayStrings.scoreValue(language, score),
                    excludeSemantics: true,
                    child: SizedBox(
                      height: CosmicConfig.scoreHeight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$score',
                          style: text.displayLarge?.copyWith(
                            fontSize: CosmicConfig.scoreSize,
                            fontFamily: AppTypography.headingFamily,
                            fontWeight: FontWeight.w500,
                            height: 1,
                            color: tone == CosmicTone.calm
                                ? CosmicConfig.copper
                                : CosmicConfig.goldLight,
                            shadows: const <Shadow>[
                              Shadow(color: Colors.black, blurRadius: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    key: const ValueKey<String>('score-label-plate'),
                    decoration: BoxDecoration(
                      gradient: CosmicConfig.scoreCaptionHalo,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            '/100',
                            style: text.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            TodayStrings.score(language),
                            textAlign: TextAlign.center,
                            style: text.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (tone == CosmicTone.rare)
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: ExcludeSemantics(
                child: Icon(Icons.auto_awesome, color: tone.light),
              ),
            ),
        ],
      ),
    );
  }
}

/// Yeni görsel hiyerarşi; gizli kategori değerleri çağıran tarafından maskelenir.
class TodayRevealedContent extends StatelessWidget {
  /// Geçiş rotaları ve paylaşma akışı korunur.
  const TodayRevealedContent({
    required this.language,
    required this.score,
    required this.title,
    required this.dimension,
    required this.reflection,
    required this.mission,
    required this.dimensions,
    required this.onDimension,
    required this.onShare,
    required this.sharing,
    required this.onFeedback,
    this.header,
    super.key,
  });

  /// Aktif dil.
  final AppDil language;

  /// Açılmış genel skor.
  final int score;

  /// Kısa destekleyici başlık.
  final String title;

  /// Uyumluluk için günlük alan kimliği.
  final ExperienceDimension dimension;

  /// Sonuç vaadi taşımayan kısa cümle.
  final String reflection;

  /// Küçük isteğe bağlı eylem.
  final String mission;

  /// Maskelenmiş kategori listesi.
  final List<TodayDimensionData> dimensions;

  /// Kategori detayı/erişim.
  final ValueChanged<ExperienceDimension> onDimension;

  /// Sistem paylaşımı.
  final VoidCallback onShare;

  /// Tek işlem koruması.
  final bool sharing;

  /// Akşam değerlendirmesi.
  final VoidCallback onFeedback;

  /// Gerçek başlığı hero ile aynı kesintisiz sahneye yerleştirir.
  final Widget? header;
  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (header != null)
          TodaySceneStage(
            header: header!,
            opened: true,
            tone: CosmicTone.fromScore(score),
            stage: CosmicScoreHero(
              score: score,
              language: language,
              embeddedScene: true,
            ),
          )
        else
          CosmicScoreHero(score: score, language: language),
        ResultContentFade(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              DecoratedBox(
                key: const ValueKey<String>('today-reflection-plate'),
                decoration: BoxDecoration(
                  gradient: CosmicConfig.headingHalo,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        title,
                        style: text.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        reflection,
                        style: text.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                key: const ValueKey<String>('today-category-grid'),
                label: TodayStrings.dimensions(language),
                container: true,
                child: _CategoryGrid(
                  children: <Widget>[
                    for (final LuckCategory category in _categoryOrder)
                      for (final TodayDimensionData item in dimensions)
                        if (item.dimension.kategori == category)
                          TodayDimensionTile(
                            data: item,
                            language: language,
                            onTap: () => onDimension(item.dimension),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SmallStepPanel(
                language: language,
                mission: mission,
                onShare: onShare,
                sharing: sharing,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                TodayStrings.scoreNote(language),
                style: text.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              KaderCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      TodayStrings.evening(language),
                      style: text.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      TodayStrings.eveningBody(language),
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    KaderButton(
                      label: TodayStrings.reflect(language),
                      variant: KaderButtonVariant.secondary,
                      onPressed: onFeedback,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallStepPanel extends StatelessWidget {
  const _SmallStepPanel({
    required this.language,
    required this.mission,
    required this.onShare,
    required this.sharing,
  });
  final AppDil language;
  final String mission;
  final VoidCallback onShare;
  final bool sharing;
  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Widget copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(TodayStrings.mission(language), style: text.labelMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(mission, style: text.bodySmall),
      ],
    );
    final Widget share = OutlinedButton.icon(
      onPressed: sharing ? null : onShare,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          AppLayout.minTouchTarget,
          AppLayout.minTouchTarget,
        ),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        side: BorderSide(color: CosmicConfig.social.withValues(alpha: .4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        sharing ? TodayStrings.sharing(language) : TodayStrings.share(language),
        style: text.labelMedium,
      ),
    );
    return Semantics(
      container: true,
      label: TodayStrings.optional(language),
      child: Container(
        key: const ValueKey<String>('today-small-step'),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: CosmicConfig.social.withValues(alpha: .25)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xF2142636), CosmicConfig.navigationSurface],
          ),
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final bool stacked =
                box.maxWidth < 310 ||
                MediaQuery.textScalerOf(context).scale(14) >
                    CosmicConfig.largeTextThreshold;
            final Widget row = Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: CosmicConfig.missionIconSize,
                  height: CosmicConfig.missionIconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CosmicConfig.navigationSurface,
                    border: Border.all(
                      color: CosmicConfig.social.withValues(alpha: .25),
                    ),
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    color: CosmicConfig.health,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: copy),
                if (!stacked) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  share,
                ],
              ],
            );
            return stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      row,
                      const SizedBox(height: AppSpacing.sm),
                      Align(alignment: Alignment.centerRight, child: share),
                    ],
                  )
                : row;
          },
        ),
      ),
    );
  }
}
