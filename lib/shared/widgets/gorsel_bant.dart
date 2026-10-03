import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'sahne_config.dart';

/// Ekranın üstüne oturan, alt kenarı zemine eriyen yatay görsel bant
/// (profil başlığı, rapor afişi gibi). Üstüne [child] bindirilebilir.
///
/// Bant genişliği ebeveyni doldurur; yüksekliği genişliğin
/// [yukseklikOrani] katıdır.
class GorselBant extends StatelessWidget {
  /// [gorsel] asset yoluyla bant kurar.
  const GorselBant({
    required this.gorsel,
    this.yukseklikOrani = SahneConfig.bantYukseklikOrani,
    this.hizalama = Alignment.center,
    this.child,
    super.key,
  });

  /// Bant görselinin asset yolu.
  final String gorsel;

  /// Yüksekliğin genişliğe oranı.
  final double yukseklikOrani;

  /// Görselin kırpılma hizası.
  final Alignment hizalama;

  /// Bandın üstüne ortalanarak bindirilen içerik.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints kisit) {
        final double h = kisit.maxWidth * yukseklikOrani;
        return SizedBox(
          height: h,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // Alt kısım zemine erisin: görsel alfa gradyanıyla maskelenir.
              ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (Rect r) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0),
                  ],
                  stops: const <double>[SahneConfig.bantErimeBaslangici, 1],
                ).createShader(r),
                child: Image.asset(
                  gorsel,
                  fit: BoxFit.cover,
                  alignment: hizalama,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
              ),
              if (child != null) child!,
            ],
          ),
        );
      },
    );
  }
}
