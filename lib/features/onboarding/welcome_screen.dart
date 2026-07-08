import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_icons.dart';
import '../../shared/widgets/app_route.dart';
import '../settings/settings_strings.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';
import 'profile_form_screen.dart';

/// Onboarding adım 1: uygulama ikonu + slogan + "Başla" butonu.
///
/// Geri tuşu burada varsayılan davranıştadır (uygulamadan çıkar).
class WelcomeScreen extends StatelessWidget {
  /// Varsayılan kurucu.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme yaziTemasi = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              const Spacer(),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(OnboardingConfig.ikonKoseYaricapi),
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
                OnboardingStrings.slogan,
                style: yaziTemasi.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  fadeThroughRoute<void>(const ProfileFormScreen()),
                ),
                child: const Text(OnboardingStrings.basla),
              ),
              const SizedBox(height: AppSpacing.md),
              // Yasal uyum ibaresi (store reddi riskine karşı zorunlu).
              Text(
                SettingsStrings.eglenceAmacli,
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
