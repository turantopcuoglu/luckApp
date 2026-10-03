import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/gorsel_afis.dart';
import '../../shared/widgets/sahne_config.dart';
import 'bebek_ismi_screen.dart';
import 'isim_analizi_screen.dart';
import 'numara_analizi_screen.dart';
import 'tools_config.dart';
import 'tools_strings.dart';

/// Keşfet sekmesi: paylaşmaya uygun numeroloji araçları.
///
/// Araçların sonuçları ücretsizdir (yeni kullanıcı getiren paylaşımlar
/// için); derin isim bölümleri ve aday sıralaması Premium'dur.
class ToolsScreen extends StatelessWidget {
  /// Varsayılan kurucu.
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final List<(String, String, String, Widget)> araclar =
        <(String, String, String, Widget)>[
          (
            AppImages.aracIsim,
            ToolsStrings.isimBaslik,
            ToolsStrings.isimAciklama,
            const IsimAnaliziScreen(),
          ),
          (
            AppImages.aracNumara,
            ToolsStrings.numaraBaslik,
            ToolsStrings.numaraAciklama,
            const NumaraAnaliziScreen(),
          ),
          (
            AppImages.aracBebek,
            ToolsStrings.bebekBaslik,
            ToolsStrings.bebekAciklama,
            const BebekIsmiScreen(),
          ),
        ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Text(ToolsStrings.baslik, style: yazi.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ToolsStrings.aciklama,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final (String, String, String, Widget) a in araclar)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _AracKarti(
                  gorsel: a.$1,
                  baslik: a.$2,
                  aciklama: a.$3,
                  onTap: () => unawaited(
                    Navigator.of(context).push(fadeThroughRoute<void>(a.$4)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Araç kartı: sağda aracın sahnesi (kemer içinde ışık şeridi, takımyıldız,
/// hilal beşik), solda başlık ve açıklama.
class _AracKarti extends StatelessWidget {
  const _AracKarti({
    required this.gorsel,
    required this.baslik,
    required this.aciklama,
    required this.onTap,
  });

  final String gorsel;
  final String baslik;
  final String aciklama;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.camKenar),
          ),
          child: GorselAfis(
            gorsel: gorsel,
            yukseklik: SahneConfig.afisKartYuksekligi,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        baslik,
                        style: yazi.titleMedium?.copyWith(
                          color: AppColors.goldAcik,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  aciklama,
                  maxLines: ToolsConfig.kartAciklamaSatiri,
                  overflow: TextOverflow.ellipsis,
                  style: yazi.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
