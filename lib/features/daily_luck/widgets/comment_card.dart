import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';

/// Günün yorum metnini gösteren kart.
///
/// Session 5'te 3D flip animasyonuyla sarmalanacak; bu yüzden salt
/// içerik burada, davranış dışarıda tutulur.
class CommentCard extends StatelessWidget {
  /// [metin] içeriğiyle kart oluşturur.
  const CommentCard({required this.metin, super.key});

  /// Gösterilecek 2-3 cümlelik yorum.
  final String metin;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          metin,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
