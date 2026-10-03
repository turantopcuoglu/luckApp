import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'sahne_config.dart';

/// Yatay görsel afiş: sağda sahne (kemer içinde odak nesnesi), solda koyu
/// gökyüzüne yazılan [child]. Görseller "sol %45 boş" kuralıyla çizildi
/// (yıl afişleri, Keşfet araç kartları).
///
/// [yukseklik] null ise afiş kendi oranında (3:2) tam genişlik çizilir;
/// yüksekliği [SahneConfig.afisAzamiYukseklik] ile sınırlıdır.
class GorselAfis extends StatelessWidget {
  /// [gorsel] asset yoluyla afiş kurar.
  const GorselAfis({
    required this.gorsel,
    required this.child,
    this.yukseklik,
    super.key,
  });

  /// Afiş görselinin asset yolu.
  final String gorsel;

  /// Sol taraftaki yazı içeriği.
  final Widget child;

  /// Sabit yükseklik (kart biçimi); null ise 3:2 oran.
  final double? yukseklik;

  @override
  Widget build(BuildContext context) {
    final Widget icerik = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          gorsel,
          fit: BoxFit.cover,
          // Sahne sağda: dar kartta da kemer görünür kalsın.
          alignment: Alignment.centerRight,
          gaplessPlayback: true,
          excludeFromSemantics: true,
        ),
        // Sol yarıda yazının okunması için gece laciverti gradyan.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.background.withValues(
                  alpha: SahneConfig.afisKarartmasi,
                ),
                AppColors.background.withValues(alpha: 0),
              ],
              stops: const <double>[0, SahneConfig.afisYaziBolgesi],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: SahneConfig.afisYaziGenislikOrani,
              child: child,
            ),
          ),
        ),
      ],
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints kisit) => SizedBox(
          // Oran korunur ama geniş ekranda (tablet) afiş aşırı uzamaz.
          height:
              yukseklik ??
              min(
                kisit.maxWidth / SahneConfig.afisOrani,
                SahneConfig.afisAzamiYukseklik,
              ),
          child: icerik,
        ),
      ),
    );
  }
}
