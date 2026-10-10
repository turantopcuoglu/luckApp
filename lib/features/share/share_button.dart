import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_route.dart';
import 'paylasim_screen.dart';

/// Ana ekrandaki "Paylaş" butonu: tema ve "Skoru gizle" seçilen
/// "Kartını paylaş" ekranını açar ([PaylasimScreen]).
class ShareButton extends StatelessWidget {
  /// Paylaşılacak [sonuc] ile buton oluşturur.
  const ShareButton({required this.sonuc, this.baslik, super.key});

  /// Günün sonucu.
  final LuckResult sonuc;

  /// Günün kişisel başlığı ("Temel Atma Günü"); karta yazılır.
  final String? baslik;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      onPressed: () => unawaited(
        Navigator.of(context).push(
          fadeThroughRoute<void>(
            PaylasimScreen(sonuc: sonuc, baslik: baslik),
          ),
        ),
      ),
      icon: const Icon(Icons.ios_share, color: AppColors.gold),
      label: Text(
        l.paylasimPaylas,
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
