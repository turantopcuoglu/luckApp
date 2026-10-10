import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../daily_luck/daily_luck_providers.dart';

/// Tam ad düzenleme diyaloğunu açar ve kaydeder.
///
/// Tam ad yalnızca isim numerolojisini etkiler; skor tohumu görünen
/// isimden türediği için geçmiş ve gelecek skorlar değişmez.
Future<void> tamAdiDuzenle(BuildContext context, WidgetRef ref) async {
  final AppLocalizations l = AppLocalizations.of(context);
  final UserProfile profil = ref.read(aktifProfilProvider);
  final TextEditingController kontrol =
      TextEditingController(text: profil.tamAd ?? profil.isim);
  final String? sonuc = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(l.tamAdBaslik),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l.tamAdAciklama),
          TextField(
            key: const Key('tam-ad-alani'),
            controller: kontrol,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(hintText: l.tamAdIpucu),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(''),
          child: Text(l.tamAdKaldir),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l.tamAdVazgec),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(kontrol.text),
          child: Text(l.tamAdKaydet),
        ),
      ],
    ),
  );
  kontrol.dispose();
  if (sonuc == null) {
    return;
  }
  final String temiz = sonuc.trim().replaceAll(RegExp(r'\s+'), ' ');
  // Bellek içi kutu anında güncellenir; disk yazması beklenmez.
  unawaited(
    ref.read(userRepositoryProvider).kaydet(
          temiz.isEmpty
              ? profil.copyWith(tamAdiTemizle: true)
              : profil.copyWith(tamAd: temiz),
        ),
  );
  ref.invalidate(aktifProfilProvider);
}
