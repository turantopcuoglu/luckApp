import '../../core/localization/app_dil.dart';

/// Ana ekran widget'ının metinleri (TR + EN).
abstract final class WidgetStrings {
  /// Widget üstündeki marka etiketi (dil-nötr).
  static const String marka = 'Kader';

  /// Günün yorumu boşsa gösterilen yedek ipucu.
  static String yedekTeaser(AppDil dil) =>
      dil.sec('Bugünün kaderi seni bekliyor', "Today's fortune awaits you");
}
