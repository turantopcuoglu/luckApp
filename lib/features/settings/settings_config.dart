import '../feedback/feedback_config.dart';

/// Ayarlar ekranına özgü sabitler.
abstract final class SettingsConfig {
  /// Hakkında bölümünde gösterilen uygulama sürümü.
  ///
  /// ONAY NOTU: pubspec.yaml `version:` alanı ile elle senkron
  /// tutulur. Çalışma zamanında otomatik okumak `package_info_plus`
  /// paketini gerektirir; anayasa gereği pubspec'e sormadan paket
  /// eklenmez, o yüzden şimdilik sabit tutuldu.
  static const String uygulamaSurumu = '1.0.0';

  /// Akşam hatırlatmasının varsayılan gün-içi dakikası (21:00).
  ///
  /// Profilde özel saat yoksa ([UserProfile.aksamBildirimDakika] null)
  /// bu değer gösterilir; [FeedbackConfig] tek kaynaktan türetilir.
  static const int varsayilanAksamDakika =
      FeedbackConfig.aksamSaat * 60 + FeedbackConfig.aksamDakika;

  /// Sabah hatırlatmasının varsayılan gün-içi dakikası (08:30).
  static const int varsayilanSabahDakika =
      FeedbackConfig.sabahSaat * 60 + FeedbackConfig.sabahDakika;
}
