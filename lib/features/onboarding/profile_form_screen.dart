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
import '../profile/dogum_bilgisi_duzenle.dart';
import 'calculating_screen.dart';
import 'onboarding_config.dart';
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

/// Formda seçili doğum saati (gece yarısından itibaren dakika); kullanıcı
/// saatini bilmiyorsa null kalır.
final StateProvider<int?> secilenDogumSaatiProvider = StateProvider<int?>(
  (Ref ref) => null,
);

/// Formda seçili doğum ilinin plaka kodu; seçilmediyse null.
final StateProvider<int?> secilenDogumIliProvider = StateProvider<int?>(
  (Ref ref) => null,
);

/// Onboarding'in TEK veri adımı: doğumdaki tam ad, doğum tarihi, (biliniyorsa)
/// doğum saati ve doğum yeri.
///
/// Kullanıcıya kendini tarif ettiren sorular (enerji, karar tarzı, ilişki
/// durumu, uğraş) BİLEREK sorulmaz: okumada geri duyulduğunda "bana sordu,
/// şimdi cevabımı bana satıyor" hissi yaratıyordu. Okuma yalnızca doğum
/// verisinden kurulur.
///
/// Hitap adı ayrıca sorulmaz, tam adın ilk kelimesidir ("Ayşe Yılmaz" →
/// "Ayşe"). Rakip uygulamanın en çok 1★ aldığı nokta giriş formuydu (iki
/// göbek adı, tire, soyad girilemiyordu); burada tam ad serbest metindir:
/// boşluk, tire ve Türkçe karakterler hesapta doğru ele alınır.
/// Geri tuşu varsayılan pop davranışıyla uyarı ekranına döner.
class ProfileFormScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  /// Tam ad alanının denetleyicisi (setState gerektirmez).
  final TextEditingController _tamAdKontrol = TextEditingController();

  @override
  void dispose() {
    _tamAdKontrol.dispose();
    super.dispose();
  }

  /// Ad doğrulanır, profil (uyarı onayıyla) kaydedilir ve hazırlık
  /// ekranına geçilir.
  ///
  /// Hive yazması bilinçli olarak await edilmez: bellek içi kutu anında
  /// güncellenir, disk yazması arkada tamamlanır; akış beklemesin.
  void _devamEt() {
    final String tamAd = _tamAdKontrol.text.trim().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (tamAd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).onboardingIsimBosUyarisi),
        ),
      );
      return;
    }
    // Hitap adı: tam adın ilk kelimesi. Günün skoru bu ad ve doğum
    // tarihinden tohumlanır (bkz. UserProfile.seed).
    final String isim = tamAd.split(' ').first;

    unawaited(
      ref
          .read(userRepositoryProvider)
          .kaydet(
            UserProfile(
              isim: isim,
              dogumTarihi: ref.read(secilenDogumTarihiProvider),
              tamAd: tamAd,
              uyariKabulSurumu: LegalConfig.uyariSurumu,
              dogumSaatiDakika: ref.read(secilenDogumSaatiProvider),
              dogumIliPlaka: ref.read(secilenDogumIliProvider),
            ),
          ),
    );
    Navigator.of(
      context,
    ).push(fadeThroughRoute<void>(const CalculatingScreen()));
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
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.onboardingDogumSaatiYeriEtiketi,
                      style: yaziTemasi.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l.onboardingDogumSaatiYeriAciklama,
                      style: aciklamaStili,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DogumSaatiYeriAlanlari(
                      saat: ref.watch(secilenDogumSaatiProvider),
                      plaka: ref.watch(secilenDogumIliProvider),
                      onSaat: (int? dakika) =>
                          ref.read(secilenDogumSaatiProvider.notifier).state =
                              dakika,
                      onIl: (int plaka) =>
                          ref.read(secilenDogumIliProvider.notifier).state =
                              plaka,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AltinButon(
                  genislik: null,
                  metin: l.onboardingKaderimiHesapla,
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
