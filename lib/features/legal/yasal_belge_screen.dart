import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import 'legal_config.dart';
import 'legal_texts.dart';

/// Yasal belge türleri.
enum YasalBelge {
  /// Gizlilik Politikası.
  gizlilik(baslik: 'Gizlilik Politikası', url: LegalConfig.gizlilikUrl),

  /// Kullanım Koşulları.
  kosullar(baslik: 'Kullanım Koşulları', url: LegalConfig.kosullarUrl);

  const YasalBelge({required this.baslik, required this.url});

  /// Ekran başlığı.
  final String baslik;

  /// Web sürümünün adresi.
  final String url;

  /// Belgenin bölümleri.
  List<YasalBolum> get bolumler => switch (this) {
        YasalBelge.gizlilik => YasalMetinler.gizlilikPolitikasi,
        YasalBelge.kosullar => YasalMetinler.kullanimKosullari,
      };
}

/// Bir yasal belgeyi okunaklı bölümler halinde gösterir.
///
/// Metin seçilebilir; web adresi en altta yazılıdır (harici tarayıcı
/// açmak ek paket gerektirdiğinden adres kopyalanabilir metin olarak
/// verilir).
class YasalBelgeScreen extends StatelessWidget {
  /// [belge] ile ekran oluşturur.
  const YasalBelgeScreen({required this.belge, super.key});

  /// Gösterilecek belge.
  final YasalBelge belge;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(belge.baslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            for (final YasalBolum bolum in belge.bolumler) ...<Widget>[
              Text(bolum.baslik, style: yazi.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                bolum.metin,
                style: yazi.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            SelectableText(
              belge.url,
              style: yazi.bodySmall?.copyWith(color: AppColors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
