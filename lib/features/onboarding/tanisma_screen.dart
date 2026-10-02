import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content/okuyucu.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'calculating_screen.dart';
import 'onboarding_strings.dart';

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
    Navigator.of(context).push(
      fadeThroughRoute<void>(const CalculatingScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yazi = Theme.of(context).textTheme;
    final OkuyucuTercihleri t = ref.watch(tercihSecimiProvider);
    void guncelle(OkuyucuTercihleri yeni) =>
        ref.read(tercihSecimiProvider.notifier).state = yeni;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          if (!duzenleme)
            TextButton(
              onPressed: () =>
                  _kaydet(context, ref, const OkuyucuTercihleri()),
              child: const Text(OnboardingStrings.atla),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: <Widget>[
                  Text(OnboardingStrings.tanismaBaslik, style: yazi.headlineMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    OnboardingStrings.tanismaAciklama,
                    style: yazi.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Soru<EnerjiTarzi>(
                    soru: OnboardingStrings.soruEnerji,
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
                    soru: OnboardingStrings.soruKarar,
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
                    soru: OnboardingStrings.soruIliski,
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
                    soru: OnboardingStrings.soruUgras,
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
                    OnboardingStrings.tanismaGizlilik,
                    style: yazi.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: FilledButton(
                onPressed: () => _kaydet(context, ref, t),
                child: Text(
                  duzenleme
                      ? OnboardingStrings.kaydet
                      : OnboardingStrings.kaderimiHesapla,
                ),
              ),
            ),
          ],
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
