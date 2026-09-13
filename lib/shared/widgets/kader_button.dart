import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/cosmic_config.dart';

/// Ortak eylem önceliği.
enum KaderButtonVariant {
  /// Lime dolgulu ana eylem.
  primary,

  /// Kontrastlı sınırı olan ikincil eylem.
  secondary,
}

/// Metni kesmeden büyüyen, klavye ve ekran okuyucu destekli eylem butonu.
class KaderButton extends StatelessWidget {
  /// Yükleme sırasında tıklama kapanır; loadingLabel aktif dilde verilmelidir.
  const KaderButton({
    required this.label,
    required this.onPressed,
    this.variant = KaderButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.reduceMotion,
    this.cosmic = false,
    super.key,
  }) : assert(!isLoading || loadingLabel != null);

  /// Aktif dilde görünen tam eylem metni.
  final String label;

  /// Null ise kontrol devre dışıdır.
  final VoidCallback? onPressed;

  /// Ana veya ikincil görünüm.
  final KaderButtonVariant variant;

  /// Standart işlev ikonu; anlamı metin verir.
  final IconData? icon;

  /// İşlem sürüyor; tekrar eylem gönderilmez.
  final bool isLoading;

  /// Yükleme sırasında görünen/okunan yerelleştirilmiş metin.
  final String? loadingLabel;

  /// Kalıcı kullanıcı tercihini üst katman sağlar; sistem tercihi de izlenir.
  final bool? reduceMotion;

  /// Onaylı altın folyo eylem yüzeyi; mevcut sade tüketiciler etkilenmez.
  final bool cosmic;

  @override
  Widget build(BuildContext context) {
    final bool reduced = AppMotion.reduceMotion(
      context,
      userPreference: reduceMotion,
    );
    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading) ...<Widget>[
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: AppLayout.progressSize,
              child: CircularProgressIndicator(
                value: reduced ? 1 : null,
                strokeWidth: AppStroke.focus,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...<Widget>[
          ExcludeSemantics(child: Icon(icon, size: AppLayout.iconSize)),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            isLoading ? loadingLabel ?? label : label,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
    final ButtonStyle style = ButtonStyle(
      animationDuration: reduced ? Duration.zero : AppMotion.press,
      backgroundColor: cosmic
          ? WidgetStatePropertyAll<Color>(
              onPressed == null || isLoading
                  ? CosmicConfig.goldShade
                  : Colors.transparent,
            )
          : null,
      foregroundColor: cosmic
          ? const WidgetStatePropertyAll<Color>(AppColors.ink)
          : null,
    );
    final Widget button = Semantics(
      liveRegion: isLoading,
      child: variant == KaderButtonVariant.primary
          ? FilledButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: content,
            )
          : OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: style,
              child: content,
            ),
    );
    return cosmic && variant == KaderButtonVariant.primary
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: CosmicConfig.goldLight.withValues(alpha: .7),
              ),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  CosmicConfig.goldLight,
                  CosmicConfig.gold,
                  CosmicConfig.goldShade,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: CosmicConfig.gold.withValues(alpha: .12),
                  blurRadius: 16,
                ),
              ],
            ),
            child: button,
          )
        : button;
  }
}
