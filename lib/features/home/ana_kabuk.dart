import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../compatibility/uyum_screen.dart';
import '../daily_luck/daily_luck_screen.dart';
import '../profile/kader_profili_screen.dart';
import '../settings/ayarlar_screen.dart';
import 'ana_sekme.dart';

/// Onboarding sonrası uygulamanın kabuğu: dört sekme + alt gezinme.
///
/// Sekmeler [IndexedStack] içinde yaşar ki ana ekrandaki kart açılışı ve
/// kaydırma konumu sekme değişiminde kaybolmasın. Reklamlar gezinme
/// çubuğunun yanına KONMAZ (kazara tıklama politikası); banner'lar
/// içeriğin en altındadır.
class AnaKabuk extends ConsumerWidget {
  /// Varsayılan kurucu.
  const AnaKabuk({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int secili = ref.watch(anaSekmeProvider);
    return Scaffold(
      body: IndexedStack(
        index: secili,
        children: const <Widget>[
          DailyLuckScreen(),
          KaderProfiliScreen(),
          UyumScreen(),
          AyarlarScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: secili,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.gold.withValues(alpha: 0.2),
        onDestinationSelected: (int i) =>
            ref.read(anaSekmeProvider.notifier).state = i,
        destinations: <Widget>[
          for (final AnaSekme sekme in AnaSekme.values)
            NavigationDestination(
              icon: Icon(sekme.ikon),
              selectedIcon: Icon(sekme.ikon, color: AppColors.gold),
              label: sekme.etiket,
            ),
        ],
      ),
    );
  }
}
