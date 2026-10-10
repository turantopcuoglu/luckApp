import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/arac_okumalari.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../share/arac_story_card.dart';
import 'tools_config.dart';
import 'tools_providers.dart';

/// Seçili numara türünün indeksi ([_numaraTurleri]).
final AutoDisposeStateProvider<int> numaraTuruProvider =
    StateProvider.autoDispose<int>((Ref ref) => 0);

/// Hesaplanmak üzere gönderilen numara (null: henüz gönderilmedi).
final AutoDisposeStateProvider<String?> numaraGirdisiProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

/// Gönderilen numaranın okuması (rakam/harf yoksa null).
final AutoDisposeProvider<NumaraOkumasi?> numaraOkumasiProvider =
    Provider.autoDispose<NumaraOkumasi?>((Ref ref) {
      final String? girdi = ref.watch(numaraGirdisiProvider);
      final NumaraAnalizi? analiz = girdi == null
          ? null
          : NumaraAnalizcisi.analizEt(girdi);
      return analiz == null ? null : numaraOkumasi(analiz);
    });

/// Numara Analizi: telefon, plaka ya da ev numarasının sayısı (ücretsiz).
class NumaraAnaliziScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const NumaraAnaliziScreen({super.key});

  @override
  ConsumerState<NumaraAnaliziScreen> createState() =>
      _NumaraAnaliziScreenState();
}

class _NumaraAnaliziScreenState extends ConsumerState<NumaraAnaliziScreen> {
  final TextEditingController _numara = TextEditingController();

  @override
  void dispose() {
    _numara.dispose();
    super.dispose();
  }

  void _hesapla() {
    FocusScope.of(context).unfocus();
    ref.read(numaraGirdisiProvider.notifier).state = _numara.text;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final int tur = ref.watch(numaraTuruProvider);
    final String? girdi = ref.watch(numaraGirdisiProvider);
    final NumaraOkumasi? okuma = ref.watch(numaraOkumasiProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.araclarNumaraBaslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            SegmentedButton<int>(
              segments: <ButtonSegment<int>>[
                for (int i = 0; i < _numaraTurleri(l).length; i++)
                  ButtonSegment<int>(
                    value: i,
                    label: Text(_numaraTurleri(l)[i].$1),
                  ),
              ],
              selected: <int>{tur},
              onSelectionChanged: (Set<int> s) =>
                  ref.read(numaraTuruProvider.notifier).state = s.first,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _numara,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _hesapla(),
              decoration: InputDecoration(
                labelText: l.araclarNumaraEtiketi,
                hintText: _numaraTurleri(l)[tur].$2,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: _hesapla,
              child: Text(l.araclarHesapla),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (girdi != null && okuma == null)
              Text(
                l.araclarGecersiz,
                style: yazi.bodyMedium?.copyWith(color: AppColors.error),
              ),
            if (okuma != null)
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '${okuma.analiz.deger}',
                            style: yazi.displayMedium?.copyWith(
                              color: AppColors.gold,
                              fontSize: ToolsConfig.sonucSayiBoyutu,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(okuma.lakap, style: yazi.titleLarge),
                                Text(
                                  l.araclarHesapSatiri(okuma.analiz.zincir.join(' → ')),
                                  style: yazi.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(okuma.metin, style: yazi.bodyLarge),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () => unawaited(
                          ref.read(aracPaylasProvider)(
                            AracPaylasimi(
                              ustEtiket: l.araclarNumaraKartEtiketi,
                              baslik: girdi!.trim(),
                              sayi: '${okuma.analiz.deger}',
                              sayiEtiketi: okuma.lakap,
                              metin: okuma.metin,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.ios_share_rounded),
                        label: Text(l.araclarPaylas),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Numara türleri: (segment etiketi, alan ipucu), [l] dilinde.
List<(String, String)> _numaraTurleri(AppLocalizations l) =>
    <(String, String)>[
      (l.araclarTurTelefon, l.araclarTurTelefonIpucu),
      (l.araclarTurPlaka, l.araclarTurPlakaIpucu),
      (l.araclarTurEv, l.araclarTurEvIpucu),
    ];
