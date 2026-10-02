import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/arac_okumalari.dart';
import '../../core/luck_engine/luck_engine.dart';
import '../../core/storage/kayitli_kisi.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../compatibility/uyum_screen.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_providers.dart';
import '../profile/kilitli_bolum_karti.dart';
import '../share/arac_story_card.dart';
import 'tools_config.dart';
import 'tools_providers.dart';
import 'tools_strings.dart';

/// Aktif kullanıcıyı temsil eden referans kimliği.
const String benKimligi = 'ben';

/// Karşılaştırmaya seçilen kişilerin kimlikleri ([benKimligi] ya da
/// kayıtlı kişi kimliği).
final AutoDisposeStateProvider<Set<String>> secilenKisilerProvider =
    StateProvider.autoDispose<Set<String>>((Ref ref) => <String>{benKimligi});

/// Hesaplanmak üzere gönderilen aday isimler (null: henüz gönderilmedi).
final AutoDisposeStateProvider<List<String>?> adaylarProvider =
    StateProvider.autoDispose<List<String>?>((Ref ref) => null);

/// Seçilebilir referans kişiler: (kimlik, görünen ad, doğum tarihi).
final AutoDisposeProvider<List<(String, String, DateTime)>>
referansKisilerProvider =
    Provider.autoDispose<List<(String, String, DateTime)>>((Ref ref) {
      final UserProfile ben = ref.watch(aktifProfilProvider);
      return <(String, String, DateTime)>[
        (benKimligi, ben.isim, ben.dogumTarihi),
        for (final KayitliKisi k in ref.watch(kisilerProvider))
          (k.id, k.kisaAd, k.dogumTarihi),
      ];
    });

/// Bebek ismi sonucu: ilk adayın okuması (ücretsiz) ve tüm adayların
/// sıralaması (Premium).
class BebekIsmiSonucu {
  /// Tüm alanlarıyla sonuç oluşturur.
  const BebekIsmiSonucu({required this.ilkAday, required this.siralama});

  /// İlk girilen geçerli adayın okuması.
  final BebekIsmiOkumasi ilkAday;

  /// Tüm geçerli adayların puana göre sıralaması.
  final List<IsimUyumu> siralama;
}

/// Gönderilen adaylar ve seçili kişilerle sonuç (eksik girdide null).
final AutoDisposeProvider<BebekIsmiSonucu?> bebekIsmiSonucuProvider =
    Provider.autoDispose<BebekIsmiSonucu?>((Ref ref) {
      final List<String>? adaylar = ref.watch(adaylarProvider);
      final Set<String> secili = ref.watch(secilenKisilerProvider);
      final List<(String, String, DateTime)> kisiler =
          <(String, String, DateTime)>[
            for (final (String, String, DateTime) k in ref.watch(
              referansKisilerProvider,
            ))
              if (secili.contains(k.$1)) k,
          ];
      if (adaylar == null || kisiler.isEmpty) {
        return null;
      }
      final List<DateTime> dogumlar = <DateTime>[
        for (final (String, String, DateTime) k in kisiler) k.$3,
      ];
      IsimUyumu? ilk;
      for (final String a in adaylar) {
        ilk = BebekIsmi.uyum(a, dogumlar);
        if (ilk != null) {
          break;
        }
      }
      if (ilk == null) {
        return null;
      }
      return BebekIsmiSonucu(
        ilkAday: bebekIsmiOkumasi(ilk, <String>[
          for (final (String, String, DateTime) k in kisiler) k.$2,
        ]),
        siralama: BebekIsmi.sirala(adaylar, dogumlar),
      );
    });

/// Aday isim metnini satır ve virgüllerden ayırır (en fazla
/// [ToolsConfig.enFazlaAday] aday).
List<String> adaylariAyir(String metin) => metin
    .split(RegExp(r'[\n,]'))
    .map((String a) => a.trim())
    .where((String a) => a.isNotEmpty)
    .take(ToolsConfig.enFazlaAday)
    .toList(growable: false);

/// Bebek İsmi: aday isimlerin seçili kişilerle numerolojik uyumu.
class BebekIsmiScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const BebekIsmiScreen({super.key});

  @override
  ConsumerState<BebekIsmiScreen> createState() => _BebekIsmiScreenState();
}

class _BebekIsmiScreenState extends ConsumerState<BebekIsmiScreen> {
  final TextEditingController _adaylar = TextEditingController();

  @override
  void dispose() {
    _adaylar.dispose();
    super.dispose();
  }

  void _hesapla() {
    FocusScope.of(context).unfocus();
    ref.read(adaylarProvider.notifier).state = adaylariAyir(_adaylar.text);
  }

  void _kisiDegistir(String kimlik, {required bool secili}) {
    final Set<String> mevcut = ref.read(secilenKisilerProvider);
    ref
        .read(secilenKisilerProvider.notifier)
        .state = secili ? <String>{...mevcut, kimlik} : <String>{...mevcut}
      ..remove(kimlik);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final List<(String, String, DateTime)> kisiler = ref.watch(
      referansKisilerProvider,
    );
    final Set<String> secili = ref.watch(secilenKisilerProvider);
    final List<String>? adaylar = ref.watch(adaylarProvider);
    final BebekIsmiSonucu? sonuc = ref.watch(bebekIsmiSonucuProvider);
    final bool premium = ref.watch(entitlementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(ToolsStrings.bebekBaslik)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            TextField(
              controller: _adaylar,
              minLines: ToolsConfig.adayAlaniSatiri,
              maxLines: null,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: ToolsStrings.adaylarEtiketi,
                hintText: ToolsStrings.adaylarIpucu,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(ToolsStrings.ebeveynBaslik, style: yazi.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ToolsStrings.ebeveynAciklama,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                for (final (String, String, DateTime) k in kisiler)
                  FilterChip(
                    label: Text(
                      k.$1 == benKimligi ? ToolsStrings.ben(k.$2) : k.$2,
                    ),
                    selected: secili.contains(k.$1),
                    onSelected: (bool s) => _kisiDegistir(k.$1, secili: s),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: secili.isEmpty ? null : _hesapla,
              child: const Text(ToolsStrings.hesapla),
            ),
            if (secili.isEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                ToolsStrings.kisiSec,
                style: yazi.bodySmall?.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (adaylar != null && sonuc == null && secili.isNotEmpty)
              Text(
                ToolsStrings.gecersiz,
                style: yazi.bodyMedium?.copyWith(color: AppColors.error),
              ),
            if (sonuc != null) ...<Widget>[
              _IlkAdayKarti(okuma: sonuc.ilkAday),
              if (sonuc.siralama.length > 1) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                KilitliBolumKarti(
                  baslik: ToolsStrings.siralamaBaslik,
                  metin: premium
                      ? <String>[
                          for (int i = 0; i < sonuc.siralama.length; i++)
                            ToolsStrings.siraSatiri(
                              i + 1,
                              sonuc.siralama[i].analiz.tamAd,
                              sonuc.siralama[i].puan,
                            ),
                        ].join('\n')
                      : ToolsStrings.siralamaKilitli,
                  kilitli: !premium,
                  onKilidiAc: () => unawaited(
                    Navigator.of(
                      context,
                    ).push(fadeThroughRoute<void>(const PaywallScreen())),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: () => unawaited(
                  ref.read(aracPaylasProvider)(
                    AracPaylasimi(
                      ustEtiket: ToolsStrings.bebekKartEtiketi,
                      baslik: sonuc.ilkAday.uyum.analiz.tamAd,
                      sayi: '${sonuc.ilkAday.uyum.puan}',
                      sayiEtiketi: sonuc.ilkAday.bant.etiket,
                      metin: <String>[
                        sonuc.ilkAday.bant.aciklama,
                        ...sonuc.ilkAday.iliskiCumleleri,
                      ].join(' '),
                    ),
                  ),
                ),
                icon: const Icon(Icons.ios_share_rounded),
                label: const Text(ToolsStrings.paylas),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// İlk adayın sonuç kartı: ad, puan, bant ve kişi bazında ilişki.
class _IlkAdayKarti extends StatelessWidget {
  const _IlkAdayKarti({required this.okuma});

  final BebekIsmiOkumasi okuma;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(okuma.uyum.analiz.tamAd, style: yazi.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${ToolsStrings.puan(okuma.uyum.puan)} · ${okuma.bant.etiket}',
              style: yazi.titleMedium?.copyWith(color: AppColors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(okuma.bant.aciklama, style: yazi.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final String c in okuma.iliskiCumleleri)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  c,
                  style: yazi.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
