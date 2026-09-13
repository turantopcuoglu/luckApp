import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kader/features/shell/shell_state.dart';

void main() {
  test('Bugün ile başlar; ziyaretler korunur ve tekrar seçim no-op olur', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final ProviderSubscription<ShellState> subscription = container.listen(
      shellProvider,
      (_, _) {},
    );
    addTearDown(subscription.close);
    expect(container.read(shellProvider).selected, ShellTab.today);
    expect(container.read(shellProvider).visited, <ShellTab>{ShellTab.today});
    final ShellController controller = container.read(shellProvider.notifier);
    controller.select(ShellTab.profile);
    controller.select(ShellTab.patterns);
    controller.select(ShellTab.today);
    final ShellState state = container.read(shellProvider);
    expect(state.visited, ShellTab.values.toSet());
    expect(state.visited.clear, throwsUnsupportedError);
    controller.select(ShellTab.today);
    expect(container.read(shellProvider), same(state));
  });

  test(
    'kabuk dinleyicileri kapanınca gezinme yeni oturumda sıfırlanır',
    () async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);
      final ProviderSubscription<ShellState> subscription = container.listen(
        shellProvider,
        (_, _) {},
      );
      container.read(shellProvider.notifier).select(ShellTab.profile);
      subscription.close();
      await container.pump();
      expect(container.read(shellProvider).selected, ShellTab.today);
    },
  );
}
