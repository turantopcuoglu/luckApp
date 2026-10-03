import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'sahne_config.dart';

/// Altın gradyanlı, hafif parlayan hap buton (yeni stilin ana CTA'sı).
///
/// [onPressed] null ise buton pasifleşir: gradyan ve hale söner.
/// [genislik] null ise ebeveynin genişliğini doldurur.
class AltinButon extends StatelessWidget {
  /// [metin] etiketli, [onPressed] dokunuşlu altın buton.
  const AltinButon({
    required this.metin,
    required this.onPressed,
    this.genislik = SahneConfig.altinButonGenisligi,
    this.sonIkon,
    this.basIkon,
    super.key,
  });

  /// Buton etiketi.
  final String metin;

  /// Dokunuş; null ise pasif.
  final VoidCallback? onPressed;

  /// Sabit genişlik; null ise tam genişlik.
  final double? genislik;

  /// Metnin sağındaki ikon (ör. ileri oku).
  final IconData? sonIkon;

  /// Metnin solundaki ikon (ör. paylaş).
  final IconData? basIkon;

  @override
  Widget build(BuildContext context) {
    final bool aktif = onPressed != null;
    final double opaklik = aktif ? 1 : SahneConfig.camZeminOpakligi;
    return SizedBox(
      width: genislik ?? double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          gradient: LinearGradient(
            colors: <Color>[
              AppColors.goldAcik.withValues(alpha: opaklik),
              AppColors.gold.withValues(alpha: opaklik),
            ],
          ),
          boxShadow: aktif
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.gold.withValues(
                      alpha: SahneConfig.altinButonGolgeOpakligi,
                    ),
                    blurRadius: SahneConfig.altinButonGolgesi,
                  ),
                ]
              : null,
        ),
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledForegroundColor: AppColors.background,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (basIkon != null) ...<Widget>[
                Icon(basIkon),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(child: Text(metin, overflow: TextOverflow.ellipsis)),
              if (sonIkon != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Icon(sonIkon),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
