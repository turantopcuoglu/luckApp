import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'profile_config.dart';
import 'profile_strings.dart';

/// Başlıklı metin kartı: kilitliyse ilk cümle görünür, gerisi bulanık ve
/// altında "Kilidi aç" düğmesi durur.
///
/// Kader Profili ve Numeroloji Raporu ekranları ortak kullanır.
class KilitliBolumKarti extends StatelessWidget {
  /// Tüm alanlarıyla kart oluşturur.
  const KilitliBolumKarti({
    super.key,
    required this.baslik,
    required this.metin,
    required this.kilitli,
    required this.onKilidiAc,
    this.etiket,
  });

  /// Kart başlığı.
  final String baslik;

  /// Kart metni.
  final String metin;

  /// Kilitli gösterilsin mi?
  final bool kilitli;

  /// "Kilidi aç" düğmesine basılınca çağrılır.
  final VoidCallback onKilidiAc;

  /// Başlık satırında, kilit ikonundan önce gösterilen küçük ek bilgi
  /// (ör. ay kartındaki "Akışta" çipi). Kilitliyken de görünür.
  final Widget? etiket;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final TextStyle? metinStili = yazi.bodyLarge?.copyWith(
      height: ProfileConfig.metinSatirAraligi,
    );
    final int nokta = metin.indexOf('. ');
    final String ilkCumle = nokta < 0 ? metin : metin.substring(0, nokta + 1);
    final String kalan = nokta < 0 ? '' : metin.substring(nokta + 2);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    baslik,
                    style: yazi.titleMedium?.copyWith(color: AppColors.gold),
                  ),
                ),
                if (etiket != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  etiket!,
                ],
                if (kilitli) ...<Widget>[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.gold,
                    size: AppSpacing.md + AppSpacing.xs,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (!kilitli)
              Text(metin, style: metinStili)
            else ...<Widget>[
              Text(ilkCumle, style: metinStili),
              if (kalan.isNotEmpty)
                ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: ProfileConfig.kilitBulanikligi,
                      sigmaY: ProfileConfig.kilitBulanikligi,
                    ),
                    child: Text(
                      kalan,
                      style: metinStili,
                      maxLines: ProfileConfig.kilitliSatirSayisi,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onKilidiAc,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text(ProfileStrings.kilidiAc),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
