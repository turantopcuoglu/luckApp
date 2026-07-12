import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../categories/entitlement.dart';
import 'share_service.dart';
import 'share_strings.dart';

/// Ana ekrandaki "Paylaş" butonu: günün sonucunu story kartı olarak
/// sistem paylaşım menüsüne verir (plan Session 7, madde 1).
class ShareButton extends ConsumerWidget {
  /// Paylaşılacak [sonuc] ile buton oluşturur.
  const ShareButton({required this.sonuc, required this.dil, super.key});

  /// Günün sonucu.
  final LuckResult sonuc;

  /// Aktif uygulama dili.
  final AppDil dil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () {
        // Kilitli kategoriler karta maskeli gider: paylaşılan görsel,
        // uygulamada kilitli olan skorları sızdırmamalı.
        final Set<LuckCategory> kilitliler = LuckCategory.values
            .where((LuckCategory k) => ref.read(kategoriKilitliProvider(k)))
            .toSet();
        unawaited(
          ref
              .read(shareServiceProvider)
              .paylas(sonuc: sonuc, kilitliKategoriler: kilitliler, dil: dil),
        );
      },
      icon: const Icon(Icons.ios_share, color: AppColors.gold),
      label: Text(
        ShareStrings.paylas(dil),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: AppColors.gold),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.gold),
      ),
    );
  }
}
