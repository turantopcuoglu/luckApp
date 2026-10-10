import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/altin_buton.dart';
import '../../shared/widgets/app_route.dart';
import '../legal/legal_config.dart';
import 'onboarding_config.dart';
import 'tanisma_screen.dart';
import 'widgets/astrolab.dart';
import 'widgets/onboarding_zemini.dart';

/// Formda seçili doğum tarihi.
///
/// Form durumu Riverpod'da tutulur (CLAUDE.md kural 5: setState yalnız
/// lokal animasyon için); geri dönülüp gelinirse seçim korunur.
final StateProvider<DateTime> secilenDogumTarihiProvider =
    StateProvider<DateTime>(
      (Ref ref) => OnboardingConfig.varsayilanDogumTarihi,
    );

/// Onboarding profil adımı: hitap adı, doğumdaki tam ad (opsiyonel) ve
/// doğum tarihi.
///
/// Rakip uygulamanın en çok 1★ aldığı nokta giriş formuydu (iki göbek
/// adı, tire, soyad girilemiyordu). Burada tam ad serbest metindir:
/// boşluk, tire ve Türkçe karakterler hesapta doğru ele alınır.
/// Geri tuşu varsayılan pop davranışıyla uyarı ekranına döner.
class ProfileFormScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  /// İsim alanının denetleyicisi (setState gerektirmez).
  final TextEditingController _isimKontrol = TextEditingController();

  /// Tam ad alanının denetleyicisi.
  final TextEditingController _tamAdKontrol = TextEditingController();

  @override
  void dispose() {
    _isimKontrol.dispose();
    _tamAdKontrol.dispose();
    super.dispose();
  }

  /// İsim doğrulanır, profil (uyarı onayıyla) kaydedilir ve tanışma
  /// sorularına geçilir.
  ///
  /// Hive yazması bilinçli olarak await edilmez: bellek içi kutu anında
  /// güncellenir, disk yazması arkada tamamlanır; akış beklemesin.
  void _devamEt() {
    final String isim = _isimKontrol.text.trim();
    if (isim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).onboardingIsimBosUyarisi),
        ),
      );
      return;
    }
    final String tamAd = _tamAdKontrol.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );

    unawaited(
      ref
          .read(userRepositoryProvider)
          .kaydet(
            UserProfile(
              isim: isim,
              dogumTarihi: ref.read(secilenDogumTarihiProvider),
              tamAd: tamAd.isEmpty ? null : tamAd,
              uyariKabulSurumu: LegalConfig.uyariSurumu,
            ),
          ),
    );
    Navigator.of(context).push(fadeThroughRoute<void>(const TanismaScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final TextStyle? aciklamaStili = yaziTemasi.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
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
                    Text(
                      l.onboardingIsimEtiketi,
                      style: yaziTemasi.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      key: const Key('isim-alani'),
                      controller: _isimKontrol,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l.onboardingIsimIpucu,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.onboardingTamAdEtiketi,
                      style: yaziTemasi.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      key: const Key('tam-ad-form-alani'),
                      controller: _tamAdKontrol,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: l.onboardingTamAdIpucu,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l.onboardingTamAdAciklama, style: aciklamaStili),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.onboardingDogumTarihiEtiketi,
                      style: yaziTemasi.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(l.onboardingDogumTarihiAciklama, style: aciklamaStili),
                    SizedBox(
                      height: OnboardingConfig.tarihSeciciYuksekligi,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime: ref.read(secilenDogumTarihiProvider),
                        minimumDate: DateTime(OnboardingConfig.enEskiDogumYili),
                        maximumDate: DateTime.now(),
                        backgroundColor: Colors.transparent,
                        onDateTimeChanged: (DateTime yeni) =>
                            ref
                                    .read(secilenDogumTarihiProvider.notifier)
                                    .state =
                                yeni,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AltinButon(
                  genislik: null,
                  metin: l.onboardingDevam,
                  onPressed: _devamEt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
