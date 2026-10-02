import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import 'bebek_ismi_screen.dart';
import 'isim_analizi_screen.dart';
import 'numara_analizi_screen.dart';
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
    final List<(IconData, String, String, Widget)> araclar =
        <(IconData, String, String, Widget)>[
          (
            Icons.badge_outlined,
            ToolsStrings.isimBaslik,
            ToolsStrings.isimAciklama,
            const IsimAnaliziScreen(),
          ),
          (
            Icons.dialpad_rounded,
            ToolsStrings.numaraBaslik,
            ToolsStrings.numaraAciklama,
            const NumaraAnaliziScreen(),
          ),
          (
            Icons.child_care_rounded,
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
            for (final (IconData, String, String, Widget) a in araclar)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(a.$1, color: AppColors.gold),
                    title: Text(a.$2),
                    subtitle: Text(a.$3),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => unawaited(
                      Navigator.of(context).push(fadeThroughRoute<void>(a.$4)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
