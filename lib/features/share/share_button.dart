import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import 'share_service.dart';
import 'share_strings.dart';

/// Ana ekrandaki "Paylaş" butonu: günün sonucunu story kartı olarak
/// sistem paylaşım menüsüne verir (plan Session 7, madde 1).
class ShareButton extends ConsumerWidget {
  /// Paylaşılacak [sonuc] ile buton oluşturur.
  const ShareButton({required this.sonuc, super.key});

  /// Günün sonucu.
  final LuckResult sonuc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () =>
          unawaited(ref.read(shareServiceProvider).paylas(sonuc: sonuc)),
      icon: const Icon(Icons.ios_share, color: AppColors.gold),
      label: Text(
        ShareStrings.paylas,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: AppColors.gold),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.gold),
      ),
    );
  }
}
