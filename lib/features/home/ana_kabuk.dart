import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../compatibility/uyum_screen.dart';
import '../daily_luck/daily_luck_screen.dart';
import '../profile/kader_profili_screen.dart';
import '../settings/ayarlar_screen.dart';
import '../tools/tools_screen.dart';
import 'ana_sekme.dart';
import 'home_config.dart';

/// Onboarding sonrası uygulamanın kabuğu: beş sekme + altın vurgulu alt
/// gezinme (mockup `42699425` / `9635f67f` menü stili).
///
/// Sekmeler [IndexedStack] içinde yaşar ki ana ekrandaki kart açılışı ve
/// kaydırma konumu sekme değişiminde kaybolmasın; görünmeyen sekmelerin
/// animasyonları [TickerMode] ile durdurulur (pil). Reklamlar gezinme
/// çubuğunun yanına KONMAZ (kazara tıklama politikası); banner'lar
/// içeriğin en altındadır.
class AnaKabuk extends ConsumerWidget {
  /// Varsayılan kurucu.
  const AnaKabuk({super.key});

  /// Sekme sırasıyla ekranlar ([AnaSekme] sırası).
  static const List<Widget> _ekranlar = <Widget>[
    DailyLuckScreen(),
    KaderProfiliScreen(),
    UyumScreen(),
    ToolsScreen(),
    AyarlarScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int secili = ref.watch(anaSekmeProvider);
    return Scaffold(
      body: IndexedStack(
        index: secili,
        children: <Widget>[
          for (int i = 0; i < _ekranlar.length; i++)
            TickerMode(enabled: i == secili, child: _ekranlar[i]),
        ],
      ),
      bottomNavigationBar: _AltinGezinme(
        secili: secili,
        onSec: (int i) => ref.read(anaSekmeProvider.notifier).state = i,
      ),
    );
  }
}

/// Koyu cam zeminli alt gezinme: seçili sekme altın renkte ve altında
/// parlayan ince bir ışık çizgisiyle işaretlenir.
class _AltinGezinme extends StatelessWidget {
  const _AltinGezinme({required this.secili, required this.onSec});

  final int secili;
  final ValueChanged<int> onSec;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: HomeConfig.zeminOpakligi),
        border: const Border(top: BorderSide(color: AppColors.camKenar)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: HomeConfig.cubukYuksekligi,
          child: Row(
            children: <Widget>[
              for (final AnaSekme sekme in AnaSekme.values)
                Expanded(
                  child: _GezinmeOgesi(
                    sekme: sekme,
                    secili: sekme.index == secili,
                    onTap: () => onSec(sekme.index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek gezinme öğesi: ikon, etiket ve (seçiliyse) ışık çizgisi.
class _GezinmeOgesi extends StatelessWidget {
  const _GezinmeOgesi({
    required this.sekme,
    required this.secili,
    required this.onTap,
  });

  final AnaSekme sekme;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color renk = secili
        ? AppColors.gold
        : AppColors.textSecondary.withValues(alpha: HomeConfig.pasifOpaklik);
    return Semantics(
      button: true,
      selected: secili,
      child: InkResponse(
        onTap: onTap,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              secili ? sekme.seciliIkon : sekme.ikon,
              color: renk,
              size: HomeConfig.ikonBoyutu,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sekme.etiket,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: renk),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Seçili sekmenin altında parlayan altın çizgi.
            AnimatedContainer(
              duration: HomeConfig.gecisSuresi,
              width: secili ? HomeConfig.isikCizgisiGenisligi : 0,
              height: HomeConfig.isikCizgisiKalinligi,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: secili
                    ? const <BoxShadow>[
                        BoxShadow(
                          color: AppColors.gold,
                          blurRadius: HomeConfig.isikHalesi,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
