import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/theme/app_dimens.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cosmic_scene.dart';
import '../../shared/widgets/kader_button.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../settings/settings_strings.dart';
import 'onboarding_strings.dart';
import 'profile_form_screen.dart';

/// Tam genişlikte ortalanan, kısa ekranda ve büyük metinde kaydırılabilen karşılama.
class WelcomeScreen extends ConsumerWidget {
  /// Varsayılan kurucu.
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final AppDil dil = ref.watch(dilProvider);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const CosmicBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppLayout.maxContentWidth,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: math.max(
                                0,
                                constraints.maxHeight - AppSpacing.lg * 2,
                              ),
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const Spacer(),
                                  const Center(
                                    child: CosmicCardFace(width: 160),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    OnboardingStrings.uygulamaAdi,
                                    style: text.displayMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    OnboardingStrings.slogan(dil),
                                    style: text.bodyLarge?.copyWith(
                                      color: muted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  const Spacer(),
                                  KaderButton(
                                    cosmic: true,
                                    label: OnboardingStrings.basla(dil),
                                    onPressed: () => Navigator.of(context).push(
                                      fadeThroughRoute<void>(
                                        const ProfileFormScreen(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    SettingsStrings.eglenceAmacli(dil),
                                    style: text.bodySmall?.copyWith(
                                      color: muted,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
