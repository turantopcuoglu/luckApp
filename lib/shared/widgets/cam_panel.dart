import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'app_images.dart';
import 'sahne_config.dart';

/// Sahne üzerinde duran yarı saydam "cam" panel: koyu yüzey, ince altın
/// kenar, isteğe bağlı soluk mermer dokusu ve arka plan bulanıklığı.
///
/// Yeni stilde düz renkli `Card` yerine kullanılır; içerik [child]'dır.
class CamPanel extends StatelessWidget {
  /// [child] içeriğiyle cam panel kurar.
  const CamPanel({
    required this.child,
    this.dolgu = const EdgeInsets.all(AppSpacing.md),
    this.kenarRengi = AppColors.gold,
    this.mermer = false,
    this.bulanik = false,
    this.yaricap = AppRadius.md,
    this.onTap,
    super.key,
  });

  /// Panel içeriği.
  final Widget child;

  /// İç boşluk.
  final EdgeInsetsGeometry dolgu;

  /// Kenar çizgisinin rengi (opaklığı [SahneConfig.camKenarOpakligi]).
  final Color kenarRengi;

  /// Zemine soluk mermer dokusu eklensin mi?
  final bool mermer;

  /// Arkadaki sahne bulanıklaştırılsın mı? (pahalı; kaydırılan uzun
  /// listelerde kapalı tutulur).
  final bool bulanik;

  /// Köşe yarıçapı.
  final double yaricap;

  /// Panele dokunma (null ise dokunulmaz).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius kose = BorderRadius.circular(yaricap);
    final Decoration dekor = BoxDecoration(
      color: AppColors.surface.withValues(alpha: SahneConfig.camZeminOpakligi),
      borderRadius: kose,
      border: Border.all(
        color: kenarRengi.withValues(alpha: SahneConfig.camKenarOpakligi),
      ),
      image: mermer
          ? const DecorationImage(
              image: AssetImage(AppImages.mermerDoku),
              fit: BoxFit.cover,
              opacity: SahneConfig.camDokuOpakligi,
            )
          : null,
    );
    final Widget icerik = Padding(padding: dolgu, child: child);
    // Dokunulabilir panelde dalga efekti zeminin üstünde görünsün diye
    // dekorasyon Ink ile Material'a boyanır.
    Widget panel = onTap == null
        ? DecoratedBox(
            decoration: dekor,
            // İçteki ListTile'lar dalga efektini bu Material'a boyar
            // (renkli dekorasyonun altında kalmasın).
            child: Material(type: MaterialType.transparency, child: icerik),
          )
        : Material(
            type: MaterialType.transparency,
            child: Ink(
              decoration: dekor,
              child: InkWell(borderRadius: kose, onTap: onTap, child: icerik),
            ),
          );
    if (bulanik) {
      panel = ClipRRect(
        borderRadius: kose,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SahneConfig.camBulanikligi,
            sigmaY: SahneConfig.camBulanikligi,
          ),
          child: panel,
        ),
      );
    }
    return panel;
  }
}
