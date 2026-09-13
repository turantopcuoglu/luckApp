import '../../core/localization/app_dil.dart';

/// Kimlikleri korunan, her günlük karta uygulanabilen üç sahne.
enum StoryStyle {
  /// Ay ışığında mavi kapı.
  portal,

  /// Açık şampanya tonlarında bulutlu kapı.
  orbit,

  /// Yumuşak mor gece kapısı.
  keepsake;

  /// Her tema kendi çizimini kullanır; skor verisini değiştirmez.
  String get sceneAsset => switch (this) {
    portal => 'assets/images/story_night_v4.png',
    orbit => 'assets/images/story_light_v4.png',
    keepsake => 'assets/images/story_violet_v4.png',
  };

  /// Tasarım seçicisindeki yerelleştirilmiş etiket.
  String label(AppDil dil) => switch (this) {
    portal => dil.sec('Gece', 'Night'),
    orbit => dil.sec('Işık', 'Light'),
    keepsake => dil.sec('Mor', 'Violet'),
  };
}
