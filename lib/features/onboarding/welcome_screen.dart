import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_route.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../settings/settings_strings.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';
import 'profile_form_screen.dart';

/// Onboarding adım 1: uygulama ikonu + slogan + "Başla" butonu.
///
/// Geri tuşu burada varsayılan davranıştadır (uygulamadan çıkar).
class WelcomeScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    final AppDil dil = ref.watch(dilProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  OnboardingConfig.ikonKoseYaricapi,
                ),
                child: AppIllustrations.uygulamaIkonu(
                  boyut: OnboardingConfig.ikonBoyutu,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                OnboardingStrings.uygulamaAdi,
                style: yaziTemasi.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                OnboardingStrings.slogan(dil),
                style: yaziTemasi.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(fadeThroughRoute<void>(const ProfileFormScreen())),
                child: Text(OnboardingStrings.basla(dil)),
              ),
              const SizedBox(height: AppSpacing.md),
              // Yasal uyum ibaresi (store reddi riskine karşı zorunlu).
              Text(
                SettingsStrings.eglenceAmacli(dil),
                style: yaziTemasi.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
