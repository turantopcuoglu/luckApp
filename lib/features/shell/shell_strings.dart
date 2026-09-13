import '../../core/localization/app_dil.dart';

/// Ana gezinme ve geçici Desenlerim giriş ekranının TR/EN metinleri.
abstract final class ShellStrings {
  /// Bugün sekmesi.
  static String today(AppDil dil) => dil.sec('Bugün', 'Today');

  /// Desenlerim sekmesi.
  static String patterns(AppDil dil) => dil.sec('Koleksiyon', 'Collection');

  /// Profil sekmesi.
  static String profile(AppDil dil) => dil.sec('Profil', 'Profile');

  /// Geçmiş/koleksiyon girişinin başlığı.
  static String rhythmTitle(AppDil dil) =>
      dil.sec('Kendi ritmine bak', 'Explore your rhythm');

  /// Mevcut kayıtları betimleyen, doğruluk veya gelecek iddiası olmayan metin.
  static String rhythmBody(AppDil dil) => dil.sec(
    'Günlük kayıtlarını ve biriken kartlarını bir arada bul.',
    'Find your daily records and collected cards in one place.',
  );

  /// Mevcut geçmiş ekranını açar.
  static String history(AppDil dil) =>
      dil.sec('Günlük geçmişin', 'Your daily history');

  /// Mevcut koleksiyon ekranını açar.
  static String collection(AppDil dil) =>
      dil.sec('Günlük kartların', 'Your daily cards');
}
