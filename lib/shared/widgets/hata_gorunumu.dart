import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'app_images.dart';
import 'sahne_config.dart';

/// Hata / boş durum görünümü: hilali yarı örten bulut görseli
/// ([AppImages.hataDurumu]) ve altında sakin bir [metin].
class HataGorunumu extends StatelessWidget {
  /// [metin] açıklamalı hata görünümü.
  const HataGorunumu({required this.metin, super.key});

  /// Görselin altındaki açıklama.
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              AppImages.hataDurumu,
              width: SahneConfig.hataGorselBoyutu,
              height: SahneConfig.hataGorselBoyutu,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              metin,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
