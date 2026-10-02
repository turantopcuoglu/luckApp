import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../daily_luck/daily_luck_providers.dart';

/// Tam ad düzenleme diyaloğunun metinleri.
abstract final class TamAdStrings {
  /// Diyalog başlığı.
  static const String baslik = 'Doğumdaki tam adın';

  /// Açıklama.
  static const String aciklama =
      'Nüfus kaydındaki gibi, göbek adların dahil yaz (ör. Ayşe Nur '
      'Yılmaz). Kısaltma ve lakap kullanma; isim sayıları bu adla '
      'hesaplanır. Günlük skorun değişmez.';

  /// Alan ipucu.
  static const String ipucu = 'Ad Göbek adı Soyad';

  /// Kaydet.
  static const String kaydet = 'Kaydet';

  /// Temizle.
  static const String temizle = 'Kaldır';

  /// Vazgeç.
  static const String vazgec = 'Vazgeç';
}

/// Tam ad düzenleme diyaloğunu açar ve kaydeder.
///
/// Tam ad yalnızca isim numerolojisini etkiler; skor tohumu görünen
/// isimden türediği için geçmiş ve gelecek skorlar değişmez.
Future<void> tamAdiDuzenle(BuildContext context, WidgetRef ref) async {
  final UserProfile profil = ref.read(aktifProfilProvider);
  final TextEditingController kontrol =
      TextEditingController(text: profil.tamAd ?? profil.isim);
  final String? sonuc = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text(TamAdStrings.baslik),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(TamAdStrings.aciklama),
          TextField(
            key: const Key('tam-ad-alani'),
            controller: kontrol,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: TamAdStrings.ipucu),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(''),
          child: const Text(TamAdStrings.temizle),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(TamAdStrings.vazgec),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(kontrol.text),
          child: const Text(TamAdStrings.kaydet),
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
