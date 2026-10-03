import 'package:flutter/material.dart';

import '../../../core/content/gunluk_okuma.dart';
import '../../../core/luck_engine/ay_evresi.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/app_images.dart';
import '../daily_luck_config.dart';
import '../tr_strings.dart';

/// "Neden bugün?" çipleri: skoru ve yorumu belirleyen hesapları gösterir.
///
/// Her çip YALNIZCA kendi açıklamasını açar (ay evresine dokunan ay
/// evresini, gün sayısına dokunan gün sayısını görür).
class NedenCipleri extends StatelessWidget {
  /// [nedenler] listesiyle çip satırı oluşturur.
  const NedenCipleri({required this.nedenler, this.gun, super.key});

  /// Gösterilecek neden öğeleri.
  final List<NedenOgesi> nedenler;

  /// Okumanın günü: ay evresi çipine o günün ay görseli konur (null
  /// ise görselsiz çip).
  final DateTime? gun;

  /// [n] ay evresi çipiyse o günün ay evresi görseli, değilse null.
  String? _ayGorseli(NedenOgesi n) => n.tur == NedenTuru.ayEvresi && gun != null
      ? AppImages.ayEvresi(AyEvresi.bul(gun!).index)
      : null;

  void _ac(BuildContext context, NedenOgesi neden) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext _) =>
          _NedenSayfasi(neden: neden, ayGorseli: _ayGorseli(neden)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          TrStrings.nedenBugun,
          style: yazi.labelMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            for (final NedenOgesi n in nedenler)
              ActionChip(
                avatar: _ayGorseli(n) == null
                    ? null
                    : Image.asset(_ayGorseli(n)!, excludeFromSemantics: true),
                label: Text(n.etiket),
                onPressed: () => _ac(context, n),
              ),
          ],
        ),
      ],
    );
  }
}

class _NedenSayfasi extends StatelessWidget {
  const _NedenSayfasi({required this.neden, required this.ayGorseli});

  final NedenOgesi neden;

  /// Ay evresi açıklamasında gösterilecek ay görseli (yoksa null).
  final String? ayGorseli;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (ayGorseli != null) ...<Widget>[
              Center(
                child: Image.asset(
                  ayGorseli!,
                  width: DailyLuckConfig.nedenAyBoyutu,
                  height: DailyLuckConfig.nedenAyBoyutu,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(
              neden.etiket,
              style: yazi.titleLarge?.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              neden.aciklama,
              style: yazi.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              TrStrings.nedenNotu,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
