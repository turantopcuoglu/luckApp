import 'package:flutter/material.dart';
import '../../../core/theme/app_motion.dart';

/// Yeni sonuçta tek fade/yerleşme; depodan açılan kartta animasyon yoktur.
class TodayResultEntrance extends StatefulWidget {
  /// Ham skor taşımayan hazır, maskelenmiş sonuç alt ağacını sarar.
  const TodayResultEntrance({
    required this.animate,
    required this.child,
    super.key,
  });

  /// İlk açılışta true, kalıcı tekrar açılışta false.
  final bool animate;

  /// Yetki maskesi uygulanmış sonuç.
  final Widget child;
  @override
  State<TodayResultEntrance> createState() => _TodayResultEntranceState();
}

class _TodayResultEntranceState extends State<TodayResultEntrance>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    value: widget.animate ? 0 : 1,
  );
  bool _started = false;
  bool _paused = false;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool visible = _foreground && TickerMode.valuesOf(context).enabled;
    _animation.duration = AppMotion.duration(context, AppMotion.resultEntry);
    if (!_started && widget.animate && visible) {
      _started = true;
      _animation.forward();
    }
    if (!visible && _animation.isAnimating) {
      _animation.stop();
      _paused = true;
    } else if (visible && _paused) {
      _paused = false;
      _animation.forward();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (!_foreground && _animation.isAnimating) {
      _animation.stop();
      _paused = true;
    } else if (_foreground &&
        !_started &&
        widget.animate &&
        TickerMode.valuesOf(context).enabled) {
      _started = true;
      _animation.forward();
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

  @override
  Widget build(BuildContext context) =>
      _ResultProgress(animation: _animation, child: widget.child);
}

/// Sahneyi sabit tutarken yalnız sonuç metni ve eylemleri yumuşakça getirir.
class ResultContentFade extends StatelessWidget {
  /// Sonuç girişinin dışında kullanıldığında tam görünür kalır.
  const ResultContentFade({required this.child, super.key});

  /// Yerleşecek metin/kontrol katmanı.
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        context
            .dependOnInheritedWidgetOfExactType<_ResultProgress>()
            ?.animation ??
        const AlwaysStoppedAnimation<double>(1);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: AppMotion.enter.transform(animation.value),
        child: child,
      ),
    );
  }
}

/// Yalnız ilk açılışta nötr kapıdan skor sahnesine kesintisiz renk geçişi.
class ResultSceneBlend extends StatelessWidget {
  /// Her iki çocuk metinsizdir; seçilmiş sahne ancak kayıt sonrası verilir.
  const ResultSceneBlend({required this.base, required this.child, super.key});

  /// Açılışta görünen nötr ışıklı kapı.
  final Widget base;

  /// Açılmış genel skorun sahnesi.
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        context
            .dependOnInheritedWidgetOfExactType<_ResultProgress>()
            ?.animation ??
        const AlwaysStoppedAnimation<double>(1);
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedBuilder(
          animation: animation,
          child: base,
          builder: (BuildContext context, Widget? child) => Opacity(
            opacity: 1 - AppMotion.enter.transform(animation.value),
            child: child,
          ),
        ),
        AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (BuildContext context, Widget? child) => Opacity(
            opacity: AppMotion.enter.transform(animation.value),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _ResultProgress extends InheritedWidget {
  const _ResultProgress({required this.animation, required super.child});
  final Animation<double> animation;
  @override
  bool updateShouldNotify(_ResultProgress oldWidget) =>
      oldWidget.animation != animation;
}
