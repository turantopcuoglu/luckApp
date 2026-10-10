import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/okuyucu.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/app_route.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'calculating_screen.dart';
import 'onboarding_config.dart';
import 'widgets/astrolab.dart';
import 'widgets/onboarding_zemini.dart';

/// Formdaki tercih seçimleri (mevcut profilden başlar).
final AutoDisposeStateProvider<OkuyucuTercihleri> tercihSecimiProvider =
    StateProvider.autoDispose<OkuyucuTercihleri>(
      (Ref ref) =>
          ref.read(userRepositoryProvider).profil()?.tercihler ??
          const OkuyucuTercihleri(),
    );

/// "Seni tanıyalım" soruları: enerji tarzı, karar tarzı, ilişki durumu,
/// günlük uğraş.
///
/// Yorum isabetinin en somut kaynağı: bir öğrenciye "iş yerindeki"
/// cümlesi, bekar birine "partnerin" cümlesi gösterilmez. Tüm sorular
/// atlanabilir; atlanan soruya bağlı metinler genel havuzdan gelir.
///
/// [duzenleme] true ise (Ayarlar'dan açıldığında) kaydedip geri döner;
/// değilse onboarding'e hesaplama ekranıyla devam eder.
class TanismaScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const TanismaScreen({this.duzenleme = false, super.key});

  /// Ayarlar'dan düzenleme modu mu?
  final bool duzenleme;

  /// Tercihleri profile yazar ve akışa devam eder.
  ///
  /// Hive yazması await edilmez: bellek içi kutu anında güncellenir,
  /// disk yazması arkada tamamlanır (onboarding formuyla aynı yaklaşım).
  void _kaydet(
    BuildContext context,
    WidgetRef ref,
    OkuyucuTercihleri tercihler,
  ) {
    final UserProfile? profil = ref.read(userRepositoryProvider).profil();
    if (profil != null) {
      unawaited(
        ref
            .read(userRepositoryProvider)
            .kaydet(profil.copyWith(tercihler: tercihler)),
      );
      ref.invalidate(aktifProfilProvider);
    }
    if (duzenleme) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(
      context,
    ).push(fadeThroughRoute<void>(const CalculatingScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yazi = Theme.of(context).textTheme;
    final OkuyucuTercihleri t = ref.watch(tercihSecimiProvider);
    void guncelle(OkuyucuTercihleri yeni) =>
        ref.read(tercihSecimiProvider.notifier).state = yeni;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: <Widget>[
          if (!duzenleme)
            TextButton(
              onPressed: () => _kaydet(context, ref, const OkuyucuTercihleri()),
              child: Text(l.onboardingAtla),
            ),
        ],
      ),
      body: OnboardingZemini(
        yogun: true,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  children: <Widget>[
                    const Center(
                      child: Astrolab(boyut: OnboardingConfig.astrolabKucuk),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(l.onboardingTanismaBaslik, style: yazi.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l.onboardingTanismaAciklama,
                      style: yazi.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _Soru<EnerjiTarzi>(
                      soru: l.onboardingSoruEnerji,
                      secenekler: EnerjiTarzi.values,
                      etiket: (EnerjiTarzi e) => e.etiket,
                      secili: t.enerji,
                      onSec: (EnerjiTarzi? e) => guncelle(
                        OkuyucuTercihleri(
                          enerji: e,
                          karar: t.karar,
                          iliski: t.iliski,
                          ugras: t.ugras,
                        ),
                      ),
                    ),
                    _Soru<KararTarzi>(
                      soru: l.onboardingSoruKarar,
                      secenekler: KararTarzi.values,
                      etiket: (KararTarzi e) => e.etiket,
                      secili: t.karar,
                      onSec: (KararTarzi? e) => guncelle(
                        OkuyucuTercihleri(
                          enerji: t.enerji,
                          karar: e,
                          iliski: t.iliski,
                          ugras: t.ugras,
                        ),
                      ),
                    ),
                    _Soru<IliskiDurumu>(
                      soru: l.onboardingSoruIliski,
                      secenekler: IliskiDurumu.values,
                      etiket: (IliskiDurumu e) => e.etiket,
                      secili: t.iliski,
                      onSec: (IliskiDurumu? e) => guncelle(
                        OkuyucuTercihleri(
                          enerji: t.enerji,
                          karar: t.karar,
                          iliski: e,
                          ugras: t.ugras,
                        ),
                      ),
                    ),
                    _Soru<Ugras>(
                      soru: l.onboardingSoruUgras,
                      secenekler: Ugras.values,
                      etiket: (Ugras e) => e.etiket,
                      secili: t.ugras,
                      onSec: (Ugras? e) => guncelle(
                        OkuyucuTercihleri(
                          enerji: t.enerji,
                          karar: t.karar,
                          iliski: t.iliski,
                          ugras: e,
                        ),
                      ),
                    ),
                    Text(
                      l.onboardingTanismaGizlilik,
                      style: yazi.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AltinButon(
                  genislik: null,
                  onPressed: () => _kaydet(context, ref, t),
                  metin: duzenleme
                      ? l.onboardingKaydet
                      : l.onboardingKaderimiHesapla,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek seçimli soru; seçili seçeneğe tekrar dokunmak seçimi kaldırır.
class _Soru<T> extends StatelessWidget {
  const _Soru({
    required this.soru,
    required this.secenekler,
    required this.etiket,
    required this.secili,
    required this.onSec,
  });

  final String soru;
  final List<T> secenekler;
  final String Function(T) etiket;
  final T? secili;
  final ValueChanged<T?> onSec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(soru, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (final T secenek in secenekler)
                ChoiceChip(
                  label: Text(etiket(secenek)),
                  selected: secenek == secili,
                  onSelected: (bool secildi) => onSec(secildi ? secenek : null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
