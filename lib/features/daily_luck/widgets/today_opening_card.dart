import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_dil.dart';
import '../../../core/theme/app_motion.dart';
import '../reveal_config.dart';
import '../reveal_controller.dart';
import '../today_strings.dart';
import 'card_reveal_motion.dart';
import 'today_content.dart';

export 'result_entry_motion.dart' show TodayResultEntrance;

/// Günlük açılışı tek controller ile süren, görünmezken duran kart.
class TodayOpeningCard extends ConsumerStatefulWidget {
  /// Gün anahtarı widget key'i ile birlikte sabitlenmelidir.
  const TodayOpeningCard({
    required this.day,
    required this.language,
    required this.onStart,
    this.header,
    super.key,
  });

  /// Açılan kaydın günü; saat değişse de hedef değişmez.
  final DateTime day;

  /// Aktif dil.
  final AppDil language;

  /// Açılış başında sahneyi görünür konuma getirir.
  final VoidCallback onStart;

  /// Ana ekranda tek sahnenin içinde gösterilecek başlık.
  final Widget? header;
  @override
  ConsumerState<TodayOpeningCard> createState() => _TodayOpeningCardState();
}

class _TodayOpeningCardState extends ConsumerState<TodayOpeningCard>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: RevealConfig.opening,
  );
  bool _reduced = false;
  bool _sealSent = false;
  bool _paused = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _animation.addListener(() {
      if (!_reduced && !_sealSent && _animation.value >= RevealConfig.sealAt) {
        _sealSent = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Aynı frame'de değişen erişilebilirlik/sekme tercihi de dikkate alınır.
          if (mounted &&
              !AppMotion.reduceMotion(context) &&
              _foreground &&
              TickerMode.valuesOf(context).enabled) {
            unawaited(ref.read(revealHapticsProvider).seal());
          }
        });
      }
    });
    _animation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        // Reduced-motion tercihi build sırasında değişebilir. Riverpod yazımı
        // frame sonrasına bırakılır; dispose olmuş ekrana callback gönderilmez.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            unawaited(
              ref
                  .read(revealControllerProvider(widget.day).notifier)
                  .complete(),
            );
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = AppMotion.reduceMotion(context);
    final bool visible = _foreground && TickerMode.valuesOf(context).enabled;
    if (!visible && _animation.isAnimating) {
      _animation.stop();
      _paused = true;
    } else if (visible && _paused) {
      _paused = false;
      _animation.forward();
    }
    if (_reduced && _animation.isAnimating) {
      // Sistem tercihi açılış sırasında değişirse kalan hareketi kaldır.
      _animation.duration = Duration.zero;
      _animation.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _animation.isAnimating) {
      _animation.stop();
      _paused = true;
    } else if (_foreground && _paused && TickerMode.valuesOf(context).enabled) {
      _paused = false;
      _animation.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animation.dispose();
    super.dispose();
  }

  void _start() {
    if (!ref.read(revealControllerProvider(widget.day).notifier).start()) {
      return;
    }
    widget.onStart();
    if (_reduced) {
      // Sonuç, başarılı yazımdan sonra 180 ms fade ile gelir; tilt/haptic yok.
      unawaited(
        ref.read(revealControllerProvider(widget.day).notifier).complete(),
      );
    } else {
      _animation.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final RevealPhase phase = ref
        .watch(revealControllerProvider(widget.day))
        .phase;
    return TodayConcealedCard(
      header: widget.header,
      sceneAnimation: phase == RevealPhase.error
          ? const AlwaysStoppedAnimation<double>(0)
          : _animation,
      language: widget.language,
      onOpen: phase == RevealPhase.error
          ? () => unawaited(
              ref.read(revealControllerProvider(widget.day).notifier).retry(),
            )
          : _start,
      busy: phase == RevealPhase.revealing || phase == RevealPhase.saving,
      error: phase == RevealPhase.error,
      statusLabel: phase == RevealPhase.saving
          ? TodayStrings.saving(widget.language)
          : TodayStrings.opening(widget.language),
      card: CardRevealMotion(
        showScene: widget.header == null,
        animation: phase == RevealPhase.error
            ? const AlwaysStoppedAnimation<double>(0)
            : _animation,
        reducedMotion: _reduced,
      ),
    );
  }
}
