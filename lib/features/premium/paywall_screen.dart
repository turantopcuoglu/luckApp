import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/app_images.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cam_panel.dart';
import '../../shared/widgets/sahne_arka_plani.dart';
import '../../shared/widgets/sahne_config.dart';
import '../legal/yasal_belge_screen.dart';
import 'magaza_servisi.dart';
import 'premium_kontrolcu.dart';
import 'premium_strings.dart';

/// Paywall'da seçili plan kimliği (null = varsayılan: yıllık/ilk plan).
final AutoDisposeStateProvider<String?> seciliPlanProvider =
    StateProvider.autoDispose<String?>((Ref ref) => null);

/// Paywall ve kilit pencerelerinin ölçüleri.
abstract final class PaywallConfig {
  /// Başlığın üstünde kahraman sahnesine (açık altın kapı) bırakılan boşluk
  /// (ekran yüksekliği oranı).
  static const double kahramanBoslukOrani = 0.27;

  /// Sahnenin alt karartmasının başladığı yükseklik (ekran oranı).
  static const double karartmaBaslangici = 0.16;

  /// Sahnenin tamamen zemine indiği yükseklik (ekran oranı).
  static const double karartmaSonu = 0.50;

  /// Başlığın parlak sahne üstünde okunması için gölge bulanıklığı.
  static const double baslikGolgesi = 16;

  /// Özellik satırlarındaki parıltı ikonunun boyutu.
  static const double ozellikIkonBoyutu = 20;

  /// Seçili plan kartındaki onay rozetinin boyutu.
  static const double secimRozetiBoyutu = 22;

  /// Seçili plan kartının zemin opaklığı (seçili olmayan cam panel
  /// opaklığındadır).
  static const double seciliPlanOpakligi = 0.9;

  /// Seçili olmayan plan kartının kenar opaklığı.
  static const double pasifPlanKenarOpakligi = 0.25;

  /// Kilit penceresindeki kilit ambleminin boyutu.
  static const double kilitPencereAmblemi = 56;

  /// Rapor kilidi penceresindeki kitap görselinin yüksekliği.
  static const double raporKitapBoyutu = 120;

  /// Yıllık planın aylığa bölüneceği ay sayısı.
  static const int yildakiAy = 12;
}

/// Premium abonelik ekranı: açık altın kapı sahnesinin önünde başlık,
/// özellikler, yan yana iki plan, altın CTA, geri yükleme ve zorunlu
/// yenileme bilgisi (mockup `9635f67f` 4. ekran).
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

    final List<Widget> planKartlari = <Widget>[
      for (final AbonelikPlani plan in planlar)
        _PlanKarti(
          plan: plan,
          secili: plan.urunId == seciliId,
          aylikPlan: aylikPlan,
          onTap: () =>
              ref.read(seciliPlanProvider.notifier).state = plan.urunId,
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const <Widget>[CloseButton()],
      ),
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: SahneArkaPlani(
              gorsel: AppImages.sahneOrtaKapili,
              hizalama: Alignment.topCenter,
              altKarartmaBaslangici: PaywallConfig.karartmaBaslangici,
              altKarartmaSonu: PaywallConfig.karartmaSonu,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.sizeOf(context).height *
                      PaywallConfig.kahramanBoslukOrani,
                ),
                Text(
                  PremiumStrings.baslik,
                  style: yazi.displaySmall?.copyWith(
                    color: AppColors.goldAcik,
                    shadows: const <Shadow>[
                      Shadow(
                        color: AppColors.background,
                        blurRadius: PaywallConfig.baslikGolgesi,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  PremiumStrings.altBaslik,
                  style:
                      yazi.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final String ozellik in PremiumStrings.ozellikler)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          AppImages.parilti,
                          width: PaywallConfig.ozellikIkonBoyutu,
                          height: PaywallConfig.ozellikIkonBoyutu,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(ozellik, style: yazi.bodyMedium)),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                if (durum.aktif)
                  CamPanel(
                    child: Text(
                      PremiumStrings.zatenPremium,
                      style: yazi.titleMedium?.copyWith(color: AppColors.gold),
                      textAlign: TextAlign.center,
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
                  // İki plan yan yana (mockup); daha fazlası alt alta.
                  if (planKartlari.length <= 2)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          for (int i = 0; i < planKartlari.length; i++)
                            ...<Widget>[
                              if (i > 0) const SizedBox(width: AppSpacing.sm),
                              Expanded(child: planKartlari[i]),
                            ],
                        ],
                      ),
                    )
                  else
                    for (final Widget kart in planKartlari)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: kart,
                      ),
                  const SizedBox(height: AppSpacing.md),
                  if (durum.islemde)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    )
                  else
                    AltinButon(
                      genislik: null,
                      metin: secili?.denemeGunu != null
                          ? PremiumStrings.denemeBaslat
                          : PremiumStrings.abonelikBaslat,
                      onPressed: secili == null
                          ? null
                          : () => unawaited(
                                ref
                                    .read(premiumKontrolcuProvider.notifier)
                                    .satinAl(secili),
                              ),
                    ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  PremiumStrings.puanNotu,
                  style: yazi.bodySmall?.copyWith(color: AppColors.goldAcik),
                  textAlign: TextAlign.center,
                ),
                if (!durum.aktif)
                  TextButton(
                    onPressed: durum.islemde
                        ? null
                        : () => unawaited(
                              ref
                                  .read(premiumKontrolcuProvider.notifier)
                                  .geriYukle(),
                            ),
                    child: const Text(PremiumStrings.geriYukle),
                  ),
                Text(
                  PremiumStrings.yenilemeBilgisi,
                  style:
                      yazi.bodySmall?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: <Widget>[
                    for (final YasalBelge belge in YasalBelge.values)
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          fadeThroughRoute<void>(
                            YasalBelgeScreen(belge: belge),
                          ),
                        ),
                        child: Text(belge.baslik(AppLocalizations.of(context))),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Seçilebilir abonelik planı kartı: cam zemin, seçiliyken altın kenar
/// ve sağ üstte onay rozeti.
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
    final BorderRadius kose = BorderRadius.circular(AppRadius.md);
    return Semantics(
      selected: secili,
      button: true,
      child: Material(
        color: AppColors.surface.withValues(
          alpha: secili
              ? PaywallConfig.seciliPlanOpakligi
              : SahneConfig.camZeminOpakligi,
        ),
        borderRadius: kose,
        child: InkWell(
          onTap: onTap,
          borderRadius: kose,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: kose,
              border: Border.all(
                color: secili
                    ? AppColors.gold
                    : AppColors.gold.withValues(
                        alpha: PaywallConfig.pasifPlanKenarOpakligi,
                      ),
                width: secili ? 2 : 1,
              ),
            ),
            child: Stack(
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Text(
                        plan.yillikMi
                            ? PremiumStrings.yillik
                            : PremiumStrings.aylik,
                        style: yazi.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${plan.fiyatMetni} '
                        '${PremiumStrings.donem(yillik: plan.yillikMi)}',
                        style: yazi.titleSmall?.copyWith(color: AppColors.gold),
                        textAlign: TextAlign.center,
                      ),
                      for (final String satir in altSatirlar)
                        Text(
                          satir,
                          style: yazi.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      if (plan.yillikMi) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
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
                ),
                if (secili)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.gold,
                      size: PaywallConfig.secimRozetiBoyutu,
                    ),
                  ),
              ],
            ),
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
