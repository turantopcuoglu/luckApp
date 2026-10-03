import 'dart:math';

import 'package:flutter/material.dart';

import '../../../shared/widgets/app_images.dart';
import '../onboarding_config.dart';

/// Onboarding kahramanı: üç eğik altın yörünge halkası yavaşça döner,
/// ortadaki ışık kristali nefes alır, bütün nesne hafifçe süzülür.
///
/// İki katman ayrı görsellerdir ([AppImages.astrolabHalkalar],
/// [AppImages.astrolabCekirdek]); aynı merkezde üst üste çizilir. Döngü
/// controller'ı lokal animasyon state'idir (kural 5); "Hareketi azalt"
/// açıksa nesne sabit durur.
class Astrolab extends StatefulWidget {
  /// [boyut] kenarlı astrolab.
  const Astrolab({required this.boyut, super.key});

  /// Halkaların kenar uzunluğu.
  final double boyut;

  @override
  State<Astrolab> createState() => _AstrolabState();
}

class _AstrolabState extends State<Astrolab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dongu = AnimationController(
    vsync: this,
    duration: OnboardingConfig.astrolabTurSuresi,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _dongu.stop();
    } else if (!_dongu.isAnimating) {
      _dongu.repeat();
    }
  }

  @override
  void dispose() {
    _dongu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.boyut;
    final Widget halkalar = Image.asset(
      AppImages.astrolabHalkalar,
      width: s,
      height: s,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    final Widget cekirdek = Image.asset(
      AppImages.astrolabCekirdek,
      width: s * OnboardingConfig.astrolabCekirdekOrani,
      height: s * OnboardingConfig.astrolabCekirdekOrani,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: s,
        child: AnimatedBuilder(
          animation: _dongu,
          builder: (BuildContext context, Widget? child) {
            final double a = _dongu.value * 2 * pi;
            final double nefes =
                (1 + sin(a * OnboardingConfig.astrolabNefesKati)) / 2;
            return Transform.translate(
              offset: Offset(
                0,
                sin(a * OnboardingConfig.astrolabSuzulmeKati) *
                    OnboardingConfig.astrolabSuzulme,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.rotate(angle: a, child: halkalar),
                  Transform.scale(
                    scale: 1 + OnboardingConfig.astrolabNefesOlcegi * nefes,
                    child: cekirdek,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
