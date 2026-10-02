import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_route.dart';
import '../legal/yasal_belge_screen.dart';
import 'magaza_servisi.dart';
import 'premium_kontrolcu.dart';
import 'premium_strings.dart';

/// Paywall'da seçili plan kimliği (null = varsayılan: yıllık/ilk plan).
final AutoDisposeStateProvider<String?> seciliPlanProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

/// Paywall boyutları.
abstract final class PaywallConfig {
  /// Kristal küre çizimi boyutu.
  static const double illustrasyonBoyutu = 96;

  /// Yıllık planın aylığa bölüneceği ay sayısı.
  static const int yildakiAy = 12;
}

/// Premium abonelik ekranı: Google Play planları, satın alma, geri
/// yükleme ve zorunlu yenileme bilgisi.
///
/// Satın alma başarıyla sonuçlanınca ekran kendini kapatır.
class PaywallScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final PremiumDurumu durum = ref.watch(premiumKontrolcuProvider);

    // Premium açıldığında (satın alma ya da geri yükleme) kapat.
    ref.listen<PremiumDurumu>(premiumKontrolcuProvider,
        (PremiumDurumu? eski, PremiumDurumu yeni) {
      if (eski?.aktif == false && yeni.aktif) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(PremiumStrings.basarili)),
        );
        Navigator.of(context).maybePop();
      } else if (yeni.hataMesaji != null &&
          yeni.hataMesaji != eski?.hataMesaji) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(yeni.hataMesaji!)),
        );
      }
    });

    final List<AbonelikPlani> planlar = durum.planlar;
    final String? seciliId = ref.watch(seciliPlanProvider) ??
        (planlar.isEmpty ? null : planlar.first.urunId);
    final AbonelikPlani? secili = planlar
        .where((AbonelikPlani p) => p.urunId == seciliId)
        .firstOrNull;
    final AbonelikPlani? aylikPlan =
        planlar.where((AbonelikPlani p) => !p.yillikMi).firstOrNull;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: <Widget>[
            Center(
              child: AppIllustrations.kristalKure(
                boyut: PaywallConfig.illustrasyonBoyutu,
                renk: AppColors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              PremiumStrings.baslik,
              style: yazi.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              PremiumStrings.altBaslik,
              style: yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final String ozellik in PremiumStrings.ozellikler)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.gold,
                      size: AppSpacing.md + AppSpacing.xs,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(ozellik, style: yazi.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            if (durum.aktif)
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    PremiumStrings.zatenPremium,
                    style: yazi.titleMedium?.copyWith(color: AppColors.gold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (durum.planlarYukleniyor)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              )
            else if (planlar.isEmpty)
              _PlanYok(
                onTekrar: () => unawaited(
                  ref.read(premiumKontrolcuProvider.notifier).baslat(),
                ),
              )
            else ...<Widget>[
              for (final AbonelikPlani plan in planlar)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PlanKarti(
                    plan: plan,
                    secili: plan.urunId == seciliId,
                    aylikPlan: aylikPlan,
                    onTap: () => ref.read(seciliPlanProvider.notifier).state =
                        plan.urunId,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton(
                onPressed: durum.islemde || secili == null
                    ? null
                    : () => unawaited(
                          ref
                              .read(premiumKontrolcuProvider.notifier)
                              .satinAl(secili),
                        ),
                child: durum.islemde
                    ? const SizedBox.square(
                        dimension: AppSpacing.md,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        secili?.denemeGunu != null
                            ? PremiumStrings.denemeBaslat
                            : PremiumStrings.abonelikBaslat,
                      ),
              ),
            ],
            if (!durum.aktif)
              TextButton(
                onPressed: durum.islemde
                    ? null
                    : () => unawaited(
                          ref.read(premiumKontrolcuProvider.notifier).geriYukle(),
                        ),
                child: const Text(PremiumStrings.geriYukle),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              PremiumStrings.yenilemeBilgisi,
              style: yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                for (final YasalBelge belge in YasalBelge.values)
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      fadeThroughRoute<void>(YasalBelgeScreen(belge: belge)),
                    ),
                    child: Text(belge.baslik),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Seçilebilir abonelik planı kartı.
class _PlanKarti extends StatelessWidget {
  const _PlanKarti({
    required this.plan,
    required this.secili,
    required this.aylikPlan,
    required this.onTap,
  });

  final AbonelikPlani plan;
  final bool secili;
  final AbonelikPlani? aylikPlan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final List<String> altSatirlar = <String>[
      if (plan.denemeGunu != null) PremiumStrings.deneme(plan.denemeGunu!),
      if (plan.yillikMi && aylikPlan != null)
        PremiumStrings.ayliginaDusen(_aylikKarsilik()),
    ];
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: secili ? AppColors.gold : AppColors.surface,
              width: 2,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                secili
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: secili ? AppColors.gold : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          plan.yillikMi
                              ? PremiumStrings.yillik
                              : PremiumStrings.aylik,
                          style: yazi.titleMedium,
                        ),
                        if (plan.yillikMi) ...<Widget>[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs / 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              PremiumStrings.enAvantajli,
                              style: yazi.labelSmall
                                  ?.copyWith(color: AppColors.background),
                            ),
                          ),
                        ],
                      ],
                    ),
                    for (final String satir in altSatirlar)
                      Text(
                        satir,
                        style: yazi.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
              Text(
                '${plan.fiyatMetni} '
                '${PremiumStrings.donem(yillik: plan.yillikMi)}',
                style: yazi.titleSmall?.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Yıllık fiyatın aylık karşılığını, aylık planın para biçimini
  /// koruyarak yazar (sembol/ondalık ayırıcı mağazanın metninden alınır).
  String _aylikKarsilik() {
    final double aylik = plan.hamFiyat / PaywallConfig.yildakiAy;
    final String sayi = aylik.toStringAsFixed(2);
    final String ornek = plan.fiyatMetni;
    // Mağaza metni virgüllü ondalık kullanıyorsa aynısını uygula.
    final bool virgul = ornek.contains(',');
    final String bicimli = virgul ? sayi.replaceAll('.', ',') : sayi;
    final String sembol = ornek.replaceAll(RegExp(r'[\d.,\s]'), '');
    return ornek.trim().startsWith(RegExp(r'\d'))
        ? '$bicimli $sembol'.trim()
        : '$sembol$bicimli';
  }
}

/// Planlar yüklenemediğinde gösterilen durum.
class _PlanYok extends StatelessWidget {
  const _PlanYok({required this.onTekrar});

  final VoidCallback onTekrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          PremiumStrings.planYok,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        TextButton(onPressed: onTekrar, child: const Text(PremiumStrings.tekrarDene)),
      ],
    );
  }
}
