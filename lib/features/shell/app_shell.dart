import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_dil.dart';
import '../../shared/widgets/kader_bottom_navigation.dart';
import '../daily_luck/daily_luck_providers.dart';
import '../daily_luck/daily_luck_screen.dart';
import '../settings/settings_screen.dart';
import 'patterns_entry_screen.dart';
import 'shell_state.dart';
import 'shell_strings.dart';

/// Tek kök Navigator altında state koruyan üç sekmeli uygulama kabuğu.
/// Detay/bildirim rotaları kabuğun üstüne açılır; geri ile aynı sekmeye dönülür.
class AppShell extends ConsumerWidget {
  /// Varsayılan kurucu.
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ShellState state = ref.watch(shellProvider);
    final AppDil dil = ref.watch(dilProvider);
    void select(ShellTab tab) {
      FocusManager.instance.primaryFocus?.unfocus();
      ref.read(shellProvider.notifier).select(tab);
    }

    return PopScope(
      canPop: state.selected == ShellTab.today,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && state.selected != ShellTab.today) select(ShellTab.today);
      },
      child: Scaffold(
        // Klavye alanını aktif iç Scaffold yönetir; iki kere düşülmez.
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: state.selected.index,
          children: <Widget>[
            for (final ShellTab tab in ShellTab.values)
              TickerMode(
                key: ValueKey<ShellTab>(tab),
                enabled: state.selected == tab,
                child: HeroMode(
                  enabled: state.selected == tab,
                  child: ExcludeFocus(
                    excluding: state.selected != tab,
                    child: state.visited.contains(tab)
                        ? switch (tab) {
                            ShellTab.today => const DailyLuckScreen(),
                            ShellTab.patterns => const PatternsEntryScreen(),
                            ShellTab.profile => SettingsScreen(
                              title: ShellStrings.profile(dil),
                            ),
                          }
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: KaderBottomNavigation(
          items: <KaderNavigationItem>[
            KaderNavigationItem(
              label: ShellStrings.today(dil),
              icon: Icons.wb_sunny_outlined,
            ),
            KaderNavigationItem(
              label: ShellStrings.patterns(dil),
              icon: Icons.menu_book_outlined,
            ),
            KaderNavigationItem(
              label: ShellStrings.profile(dil),
              icon: Icons.person_outline_rounded,
            ),
          ],
          selectedIndex: state.selected.index,
          onSelected: (int index) => select(ShellTab.values[index]),
        ),
      ),
    );
  }
}
