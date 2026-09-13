import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';

/// Açık/koyu temayı izleyen, içeriğine göre büyüyen ortak kart kabuğu.
/// Etkileşim gerekiyorsa içine gerçek buton konur; dekoratif kart buton sayılmaz.
class KaderCard extends StatelessWidget {
  /// Kart içeriği ve isteğe bağlı iç boşluk.
  const KaderCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  /// Kartın erişilebilir gerçek widget içeriği.
  final Widget child;

  /// İç boşluk; küçük gömülü kartlarda azaltılabilir.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}
