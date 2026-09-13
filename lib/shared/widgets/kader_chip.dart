import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';

/// Metni sarabilen, seçimini işaret ve semantics ile de anlatan alan chip'i.
/// Wrap içinde kullanılmalıdır; sıkışan bir Row içine zorlanmamalıdır.
class KaderChip extends StatelessWidget {
  /// Seçim üst katmanda tutulur; bu bileşen durum saklamaz.
  const KaderChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.reduceMotion,
    super.key,
  });

  /// Aktif dilde alan etiketi.
  final String label;

  /// Seçili görünüm ve ekran okuyucu durumu.
  final bool selected;

  /// Null ise devre dışıdır; sonraki seçim değeri çağırana iletilir.
  final ValueChanged<bool>? onSelected;

  /// Üst katmanın hareket tercihi; sistem tercihi de her zaman korunur.
  final bool? reduceMotion;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: OutlinedButton(
        onPressed: onSelected == null ? null : () => onSelected!(!selected),
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size.square(AppLayout.minTouchTarget),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? colors.surfaceContainerHighest
                : selected
                ? colors.primaryContainer
                : colors.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.disabled)
                ? colors.onSurfaceVariant
                : selected
                ? colors.onPrimaryContainer
                : colors.onSurface,
          ),
          side: WidgetStateProperty.resolveWith<BorderSide>(
            (Set<WidgetState> states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? colors.outlineVariant
                  : selected
                  ? colors.onPrimaryContainer
                  : colors.outline,
              width: states.contains(WidgetState.focused)
                  ? AppStroke.focus
                  : AppStroke.control,
            ),
          ),
          animationDuration:
              AppMotion.reduceMotion(context, userPreference: reduceMotion)
              ? Duration.zero
              : AppMotion.press,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (selected) ...<Widget>[
              const ExcludeSemantics(
                child: Icon(Icons.check, size: AppLayout.iconSize),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(child: Text(label, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
