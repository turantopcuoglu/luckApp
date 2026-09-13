import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../core/storage/providers.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_motion.dart';
import '../../shared/widgets/app_route.dart';
import '../../shared/widgets/cosmic_scene.dart';
import '../../shared/widgets/kader_button.dart';
import '../../shared/widgets/kader_scaffold.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../shell/app_shell.dart';
import 'card_preparation_motion.dart';
import 'onboarding_config.dart';
import 'onboarding_strings.dart';

/// Hazırlama başarısızlığını ekranın ömrü boyunca tutar.
final AutoDisposeStateProvider<bool> hazirlamaHatasiProvider =
    StateProvider.autoDispose<bool>((Ref ref) => false);

/// Mühürlü kartın modern hazırlama geçişi. Skor veya arketip sızdırmaz.
class CalculatingScreen extends ConsumerStatefulWidget {
  /// Varsayılan kurucu.
  const CalculatingScreen({super.key});

  @override
  ConsumerState<CalculatingScreen> createState() => _CalculatingScreenState();
}

class _CalculatingScreenState extends ConsumerState<CalculatingScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _kontrol = AnimationController(
    vsync: this,
    duration: OnboardingConfig.hesaplamaSuresi,
  );
  bool _started = false;
  bool _finishing = false;
  bool _reduced = false;
  bool _foreground = true;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _kontrol.addStatusListener((AnimationStatus state) {
      if (state == AnimationStatus.completed) unawaited(_tamamla());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduced = AppMotion.reduceMotion(context);
    final bool visible = _foreground && TickerMode.valuesOf(context).enabled;
    if (visible &&
        (!_started || (reduced && !_reduced && !_kontrol.isCompleted))) {
      _kontrol.duration = reduced
          ? AppMotion.reduced
          : OnboardingConfig.hesaplamaSuresi;
      _kontrol.forward();
      _started = true;
    }
    _reduced = reduced;
    if (!visible && _kontrol.isAnimating) {
      _kontrol.stop();
      _paused = true;
    } else if (visible && _paused) {
      _paused = false;
      _kontrol.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _kontrol.isAnimating) {
      _kontrol.stop();
      _paused = true;
    } else if (_foreground &&
        (_paused || !_started) &&
        TickerMode.valuesOf(context).enabled) {
      _paused = false;
      _started = true;
      _kontrol.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kontrol.dispose();
    super.dispose();
  }

  Future<void> _tamamla() async {
    if (!mounted || _finishing) return;
    _finishing = true;
    ref.read(hazirlamaHatasiProvider.notifier).state = false;
    try {
      // Kalıcı kayıt bitmeden başarılı geçiş gösterilmez.
      await ref.read(userRepositoryProvider).onboardingTamamla();
      if (!mounted) return;
      // İlk karttan önce izin istenmez veya bildirim planlanmaz.
      ref
        ..invalidate(aktifProfilProvider)
        ..invalidate(gununSansiProvider);
      Navigator.of(context).pushAndRemoveUntil(
        fadeThroughRoute<void>(const AppShell()),
        (Route<dynamic> route) => false,
      );
    } catch (_) {
      if (mounted) {
        _finishing = false;
        ref.read(hazirlamaHatasiProvider.notifier).state = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppDil dil = ref.watch(dilProvider);
    final bool failed = ref.watch(hazirlamaHatasiProvider);
    final TextTheme text = Theme.of(context).textTheme;
    return PopScope(
      canPop: failed,
      child: KaderScaffold(
        background: const CosmicBackdrop(),
        scrollable: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: CardPreparationMotion(
                animation: _kontrol,
                reducedMotion: _reduced,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Semantics(
              liveRegion: true,
              child: Text(
                failed
                    ? OnboardingStrings.hazirlamaHatasi(dil)
                    : OnboardingStrings.hesaplaniyor(dil),
                style: text.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              OnboardingStrings.hazirlamaAciklama(dil),
              style: text.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (failed) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              KaderButton(
                cosmic: true,
                label: OnboardingStrings.tekrarDene(dil),
                onPressed: () => unawaited(_tamamla()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
