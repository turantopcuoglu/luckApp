import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ana gezinmenin sabit üç hedefi; enum sırası alt çubuk sırasıdır.
enum ShellTab {
  /// Günlük kart.
  today,

  /// Geçmiş ve koleksiyon.
  patterns,

  /// Kişisel ayarlar.
  profile,
}

/// Seçili ve ilk kez ziyaret edilmiş sekmeler; ekranlar ilk ziyarette kurulur.
class ShellState {
  /// Değiştirilemez gezinme durumu.
  const ShellState({
    this.selected = ShellTab.today,
    this.visited = const <ShellTab>{ShellTab.today},
  });

  /// Görünen sekme.
  final ShellTab selected;

  /// Widget state'i korunacak sekmeler.
  final Set<ShellTab> visited;
}

/// Shell kapanınca sıfırlanan Riverpod gezinme kontrolü.
class ShellController extends AutoDisposeNotifier<ShellState> {
  @override
  ShellState build() => const ShellState();

  /// Ziyaret edilen ekranları kaybetmeden hedefe geçer; tekrar seçim no-op'tur.
  void select(ShellTab tab) {
    if (state.selected == tab) return;
    state = ShellState(
      selected: tab,
      visited: Set<ShellTab>.unmodifiable(<ShellTab>{...state.visited, tab}),
    );
  }
}

/// Kalıcı kullanıcı verisinden bağımsız oturum içi sekme durumu.
final AutoDisposeNotifierProvider<ShellController, ShellState> shellProvider =
    NotifierProvider.autoDispose<ShellController, ShellState>(
      ShellController.new,
    );
