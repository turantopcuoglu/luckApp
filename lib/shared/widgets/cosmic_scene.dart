import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/cosmic_config.dart';

/// Ayrı bitmap atmosfer ve bağımsız ışık katmanı; etkileşim/semantics taşımaz.
class CosmicBackdrop extends StatelessWidget {
  /// Sürekli hareket yalnız açıkça istendiğinde başlar.
  const CosmicBackdrop({
    this.animated = false,
    this.tone = CosmicTone.sealed,
    this.vivid = false,
    super.key,
  });

  /// Görünür ekranın hareket tercihi.
  final bool animated;

  /// Kapalı kartta sonuçtan bağımsız sealed kullanılmalıdır.
  final CosmicTone tone;

  /// Ana sayfada özgün sahnenin ışığını korur; yardımcı sayfaları değiştirmez.
  final bool vivid;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            // Tek sakin sahne: kart görselini bir kez daha arka plana basma.
            CosmicConfig.atmosphere,
            fit: BoxFit.cover,
            cacheWidth: vivid
                ? CosmicConfig.backdropDecodeWidth(
                    MediaQuery.sizeOf(context),
                    MediaQuery.devicePixelRatioOf(context),
                  )
                : CosmicConfig.decodeWidth,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
          DecoratedBox(
            key: const ValueKey<String>('cosmic-backdrop-scrim'),
            decoration: BoxDecoration(
              gradient: vivid
                  ? CosmicConfig.vividBackdrop
                  : CosmicConfig.subduedBackdrop,
            ),
          ),
          CosmicAmbient(enabled: animated, tone: tone),
        ],
      ),
    ),
  );
}

/// Yaprak/kapı bitmap'ini yeniden kurmadan yalnız ışığı boyayan saat.
/// Gizli sekmede, uygulama arka planında ve reduced-motion'da gerçekten durur.
class CosmicAmbient extends StatefulWidget {
  /// İsteğe bağlı canlı atmosfer; sabit kare de aynı ressamı kullanır.
  const CosmicAmbient({
    required this.enabled,
    this.tone = CosmicTone.sealed,
    this.intensity = CosmicConfig.backgroundIntensity,
    this.ribbons = false,
    super.key,
  });

  /// Kullanıcı/ekran tercihi.
  final bool enabled;

  /// Işık varyantı.
  final CosmicTone tone;

  /// Arka plan ve odak sahnesi birbirinden bağımsız parlaklık bütçesi alır.
  final double intensity;

  /// Yalnız ana kapının alt/yan çevresindeki canlı ışık şeritleri.
  final bool ribbons;
  @override
  State<CosmicAmbient> createState() => _CosmicAmbientState();
}

class _CosmicAmbientState extends State<CosmicAmbient>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: CosmicConfig.ambientLoop,
  );
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  void _sync() {
    final bool active =
        widget.enabled &&
        _foreground &&
        TickerMode.valuesOf(context).enabled &&
        !AppMotion.reduceMotion(context);
    if (active && !_clock.isAnimating) _clock.repeat();
    if (!active && _clock.isAnimating) _clock.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(CosmicAmbient oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (mounted) _sync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: CosmicLightPainter(
            animation: _clock,
            tone: widget.tone,
            intensity: widget.intensity,
            ribbons: widget.ribbons,
          ),
          size: Size.infinite,
        ),
      ),
    ),
  );
}

/// Yeniden kullanılabilir yörünge şeritleri ve deterministik yıldız ressamı.
class CosmicLightPainter extends CustomPainter {
  /// Animasyon widget ağacını değil bu ressamı yeniler.
  CosmicLightPainter({
    required this.animation,
    this.tone = CosmicTone.sealed,
    this.intensity = .5,
    this.ribbons = false,
  }) : super(repaint: animation);

  /// 0–1 çevrim veya açılış ilerlemesi.
  final Animation<double> animation;

  /// Işık varyantı.
  final CosmicTone tone;

  /// Ana içerik arkasında düşük, açılışta daha yüksek yoğunluk.
  final double intensity;

  /// Metnin önünden geçmeyen, sahneye özgü ışık akışı.
  final bool ribbons;
  @override
  void paint(Canvas canvas, Size size) {
    // Son kare ilk kareyle aynıdır; 18 saniyede bir parçacık sıçraması yoktur.
    final double phase = (animation.value % 1) * math.pi * 2;
    final Paint paint = Paint();
    final Offset center = Offset(size.width / 2, size.height * .44);
    final Rect halo = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.width * 1.4,
    );
    paint.shader = RadialGradient(
      colors: <Color>[
        tone.mist.withValues(alpha: intensity * .10),
        Colors.transparent,
      ],
    ).createShader(halo);
    canvas.drawOval(halo, paint);
    paint.shader = null;
    if (ribbons) _paintRibbons(canvas, size, phase);
    if (tone == CosmicTone.rare) {
      final Rect foil = Rect.fromCenter(
        center: center,
        width: size.width * .78,
        height: size.width * .24,
      );
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = CosmicConfig.goldLight.withValues(alpha: intensity * .65);
      canvas.drawArc(foil, phase, math.pi * .8, false, paint);
      canvas.drawArc(foil, phase + math.pi, math.pi * .8, false, paint);
    }
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < CosmicConfig.particles; i++) {
      final double x =
          ((i * .6180339 + math.sin(phase + i) * .025) % 1) * size.width;
      final double y =
          ((i * .381966 +
                  1 -
                  math.sin(phase + i) * (tone == CosmicTone.calm ? .03 : .10)) %
              1) *
          size.height;
      final double alpha =
          (.35 + .3 * math.sin(phase + i)).clamp(0, 1) * intensity;
      paint.color = (i.isEven ? tone.light : tone.mist).withValues(
        alpha: alpha,
      );
      canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 1.7 : .8, paint);
    }
  }

  void _paintRibbons(Canvas canvas, Size size, double phase) {
    final double tempo = tone == CosmicTone.calm ? 1 : 2;
    for (int i = 0; i < CosmicConfig.ribbonCount; i++) {
      final double drift = math.sin(phase + i) * .018;
      final double level = .64 + i * .095;
      final Path path = Path()
        ..moveTo(-size.width * .05, size.height * (level + drift))
        ..cubicTo(
          size.width * .28,
          size.height * (level + .20),
          size.width * .60,
          size.height * (level + .12 - drift),
          size.width * 1.05,
          size.height * (level - .02),
        );
      final Color light = i.isEven ? tone.mist : tone.light;
      final double pulse = .65 + .20 * math.sin(phase + i);
      final Paint glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = CosmicConfig.ribbonGlowWidth
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..color = light.withValues(alpha: intensity * pulse * .27);
      canvas.drawPath(path, glow);
      glow
        ..maskFilter = null
        ..strokeWidth = CosmicConfig.ribbonCoreWidth
        ..color = light.withValues(alpha: intensity * pulse * .50);
      canvas.drawPath(path, glow);
      final metric = path.computeMetrics().first;
      final double travel = ((phase / (math.pi * 2) * tempo + i / 3) % 1);
      final Offset pos = metric
          .getTangentForOffset(metric.length * travel)!
          .position;
      // Söndürerek uçtan geri al; çevrimde görünür bir sıçrama oluşturma.
      final double alpha = math.sin(math.pi * travel) * intensity;
      glow
        ..style = PaintingStyle.fill
        ..color = light.withValues(alpha: alpha * .7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(pos, 5, glow);
      glow
        ..maskFilter = null
        ..color = CosmicConfig.goldLight.withValues(alpha: alpha);
      canvas.drawCircle(pos, 1.4, glow);
    }
  }

  @override
  bool shouldRepaint(CosmicLightPainter oldDelegate) =>
      animation != oldDelegate.animation ||
      tone != oldDelegate.tone ||
      ribbons != oldDelegate.ribbons ||
      intensity != oldDelegate.intensity;
}

/// Metinsiz kart dokusu; sonuç bilgisi almaz ve iki kanada bölünebilir.
class CosmicCardFace extends StatelessWidget {
  /// Tam doku içinde aynı geometri korunur.
  const CosmicCardFace({this.width = CosmicConfig.cardWidth, super.key});

  /// Kartın mantıksal genişliği.
  final double width;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: width * 1.5,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.asset(
        CosmicConfig.card,
        fit: BoxFit.fill,
        cacheWidth: CosmicConfig.decodeWidth,
        excludeFromSemantics: true,
      ),
    ),
  );
}

/// Işığı doğrudan çizimden alan açık kapı; yalnız birleşim kenarı yumuşatılır.
class CosmicPortal extends StatelessWidget {
  /// Yalnız açılmış genel skorun görsel ailesi.
  const CosmicPortal({this.tone = CosmicTone.sealed, super.key});

  /// Seçilen sahne; bir kategori skoru taşımaz.
  final CosmicTone tone;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth + AppSpacing.md * 2;
        return OverflowBox(
          minWidth: width,
          maxWidth: width,
          child: ShaderMask(
            key: const ValueKey<String>('portal-edge-only'),
            shaderCallback: CosmicConfig.portalEdgeBlend.createShader,
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              tone.homeSceneAsset,
              key: ValueKey<String>('home-scene-${tone.name}'),
              width: width,
              height: constraints.maxHeight,
              fit: BoxFit.cover,
              cacheWidth: CosmicConfig.sceneDecodeWidth(
                width,
                MediaQuery.devicePixelRatioOf(context),
              ),
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
          ),
        );
      },
    ),
  );
}
