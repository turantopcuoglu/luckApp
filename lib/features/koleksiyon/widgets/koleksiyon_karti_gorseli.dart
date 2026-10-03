import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_images.dart';
import '../../../shared/widgets/kilit_amblemi.dart';
import '../koleksiyon_config.dart';
import '../koleksiyon_katalogu.dart';

/// Koleksiyon kartının görseli: kart illüstrasyonu + nadirliğe göre
/// altın çerçeve. Kazanılmamışsa kart bulanık ve karartılmış, ortada kilit.
///
/// Genişliği ebeveyn belirler; yükseklik kart oranından (2:3) türer.
class KoleksiyonKartiGorseli extends StatelessWidget {
  /// [kart] görseli; [kazanildi] değilse kilitli görünür.
  const KoleksiyonKartiGorseli({
    required this.kart,
    required this.kazanildi,
    this.nadir = false,
    super.key,
  });

  /// Gösterilen kart.
  final KoleksiyonKarti kart;

  /// Kart koleksiyonda mı?
  final bool kazanildi;

  /// Nadir çerçeveyle mi gösterilsin?
  final bool nadir;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: KoleksiyonConfig.kartOrani,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints kisit) {
          final double w = kisit.maxWidth;
          final BorderRadius kose = BorderRadius.circular(
            w * KoleksiyonConfig.koseOrani,
          );
          Widget resim = Image.asset(
            kart.gorsel,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            excludeFromSemantics: true,
          );
          if (!kazanildi) {
            // Henüz gelmemiş kart: biçimi sezilir ama seçilemez.
            resim = ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: KoleksiyonConfig.kilitliBulaniklik,
                sigmaY: KoleksiyonConfig.kilitliBulaniklik,
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  AppColors.background.withValues(
                    alpha: KoleksiyonConfig.kilitliKarartma,
                  ),
                  BlendMode.srcATop,
                ),
                child: resim,
              ),
            );
          }
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: kose,
              boxShadow: nadir && kazanildi
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.gold.withValues(
                          alpha: KoleksiyonConfig.nadirHaleOpakligi,
                        ),
                        blurRadius: KoleksiyonConfig.nadirHalesi,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(borderRadius: kose, child: resim),
                // Çerçeve kartla aynı tuvalde çizildi: üst üste birebir oturur.
                Opacity(
                  opacity: kazanildi ? 1 : KoleksiyonConfig.kilitliKarartma,
                  child: Image.asset(
                    nadir && kazanildi
                        ? AppImages.cerceveNadir
                        : AppImages.cerceveNormal,
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                    excludeFromSemantics: true,
                  ),
                ),
                if (!kazanildi)
                  Center(
                    child: KilitAmblemi(boyut: w * KoleksiyonConfig.kilitOrani),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
