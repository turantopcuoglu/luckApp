import 'package:flutter/material.dart';

import '../../../core/content/gunluk_okuma.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../tr_strings.dart';

/// "Neden bugün?" çipleri: skoru ve yorumu belirleyen hesapları gösterir.
///
/// Her çip YALNIZCA kendi açıklamasını açar (ay evresine dokunan ay
/// evresini, gün sayısına dokunan gün sayısını görür).
class NedenCipleri extends StatelessWidget {
  /// [nedenler] listesiyle çip satırı oluşturur.
  const NedenCipleri({required this.nedenler, super.key});

  /// Gösterilecek neden öğeleri.
  final List<NedenOgesi> nedenler;

  void _ac(BuildContext context, NedenOgesi neden) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext _) => _NedenSayfasi(neden: neden),
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
  const _NedenSayfasi({required this.neden});

  final NedenOgesi neden;

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
