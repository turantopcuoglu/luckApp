import 'dart:async';

import 'package:flutter/cupertino.dart'
    show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/storage/providers.dart';
import '../../core/storage/user_profile.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../daily_luck/daily_luck_providers.dart';
import 'calculating_screen.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';

/// Formda seçili doğum tarihi.
///
/// Form durumu Riverpod'da tutulur (CLAUDE.md kural 5: setState yalnız
/// lokal animasyon için); geri dönülüp gelinirse seçim korunur.
final StateProvider<DateTime> secilenDogumTarihiProvider =
    StateProvider<DateTime>(
      (Ref ref) => OnboardingConfig.varsayilanDogumTarihi,
    );

/// Onboarding adım 2: isim girişi + doğum tarihi seçici.
///
/// Geri tuşu varsayılan pop davranışıyla karşılamaya döner.
class ProfileFormScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  /// İsim alanının denetleyicisi (setState gerektirmez).
  final TextEditingController _isimKontrol = TextEditingController();

  @override
  void dispose() {
    _isimKontrol.dispose();
    super.dispose();
  }

  /// İsim doğrulanır, profil kaydedilir ve hesaplama ekranına geçilir.
  ///
  /// Hive yazması bilinçli olarak await edilmez: bellek içi kutu anında
  /// güncellenir, disk yazması arkada tamamlanır; akış beklemesin.
  void _devamEt() {
    final String isim = _isimKontrol.text.trim();
    if (isim.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            OnboardingStrings.isimBosUyarisi(ref.read(dilProvider)),
          ),
        ),
      );
      return;
    }

    unawaited(
      ref
          .read(userRepositoryProvider)
          .kaydet(
            UserProfile(
              isim: isim,
              dogumTarihi: ref.read(secilenDogumTarihiProvider),
            ),
          ),
    );
    Navigator.of(
      context,
    ).push(fadeThroughRoute<void>(const CalculatingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final AppDil dil = ref.watch(dilProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                OnboardingStrings.isimEtiketi(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _isimKontrol,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: OnboardingStrings.isimIpucu(dil),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                OnboardingStrings.dogumTarihiEtiketi(dil),
                style: yaziTemasi.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: OnboardingConfig.tarihSeciciYuksekligi,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: ref.read(secilenDogumTarihiProvider),
                  minimumDate: DateTime(OnboardingConfig.enEskiDogumYili),
                  maximumDate: DateTime.now(),
                  backgroundColor: AppColors.background,
                  onDateTimeChanged: (DateTime yeni) =>
                      ref.read(secilenDogumTarihiProvider.notifier).state =
                          yeni,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _devamEt,
                child: Text(OnboardingStrings.kaderimiHesapla(dil)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
