import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/cosmic_config.dart';
import 'cosmic_scene.dart';

/// Mevcut ekranların SafeArea/kaydırma davranışını koruyan kozmik yüzey.
class CosmicPage extends StatelessWidget {
  /// Gövde kendi SafeArea ve kaydırmasını yönetir.
  const CosmicPage({
    required this.body,
    this.appBar,
    this.tone = CosmicTone.balanced,
    super.key,
  });

  /// Mevcut ekran gövdesi.
  final Widget body;

  /// Geri ve sayfa başlığı.
  final PreferredSizeWidget? appBar;

  /// Statik zemin ailesi; yardımcı sayfalarda sürekli GPU işi yoktur.
  final CosmicTone tone;
  @override
  Widget build(BuildContext context) {
    final ThemeData base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: CosmicConfig.gold,
            foregroundColor: const Color(0xFF07162F),
          ),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
                  ? CosmicConfig.gold
                  : CosmicConfig.textPlate,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (Set<WidgetState> states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF07162F)
                  : Colors.white,
            ),
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          selectedColor: CosmicConfig.goldShade,
        ),
      ),
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CosmicBackdrop(tone: tone),
            const ColoredBox(color: Color(0x6607162F)),
            body,
          ],
        ),
      ),
    );
  }
}

/// Parlak sahnenin üzerinde metni koruyan opak lacivert-altın panel.
class CosmicPanel extends StatelessWidget {
  /// Sadece içerik alır; davranış/erişim yetkisi değiştirmez.
  const CosmicPanel({required this.child, super.key});

  /// Form, açıklama veya kontroller.
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.lg),
    decoration: BoxDecoration(
      color: CosmicConfig.textPlate,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: CosmicConfig.gold.withValues(alpha: .25)),
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

/// Yazısız sahne ile gerçek, okunaklı başlığı birleştirir.
class CosmicPageHeader extends StatelessWidget {
  /// Metin ve görsel birbirinden bağımsızdır.
  const CosmicPageHeader({
    required this.title,
    this.asset = CosmicConfig.observatory,
    super.key,
  });

  /// Yerelleştirilmiş kısa başlık.
  final String title;

  /// Dekoratif hero görseli.
  final String asset;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(AppRadius.lg),
    child: SizedBox(
      height: CosmicConfig.pageHeroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            asset,
            fit: BoxFit.cover,
            cacheWidth: CosmicConfig.decodeWidth,
            excludeFromSemantics: true,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Colors.transparent, CosmicConfig.textPlate],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
